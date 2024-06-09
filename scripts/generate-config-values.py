import os
import yaml
import requests

HELM_CHARTS_DIR = '../charts/'
OUTPUT_VALUES_FILE = './output/development.yaml'
GITHUB_RAW_URL = 'https://raw.githubusercontent.com/folio-org'
INTEGRATIONS_MAP = {'DB': 'db',
                    'KAFKA': 'kafka',
                    'OKAPI': 'okapi',
                    'OPENSEARCH': 'opensearch',
                    'ELASTICSEARCH': 'opensearch',
                    'S3': 's3',
                    'AWS': 's3'}
EXCLUDE_ENV_LIST = ['JAVA_OPTIONS', 'ENV']


def spring_module_descriptor(module_name):
    return f"{GITHUB_RAW_URL}/{module_name}/master/descriptors/ModuleDescriptor-template.json"


def rmb_module_descriptor(module_name):
    return f"{GITHUB_RAW_URL}/{module_name}/master/service/src/main/okapi/ModuleDescriptor-template.json"


def application_yml_url(module_name):
    return f"{GITHUB_RAW_URL}/{module_name}/master/src/main/resources/application.yml"


def list_folders_in_directory(directory_path):
    # List all folders in the specified directory.
    try:
        folder_list = [name for name in os.listdir(directory_path)
                        if os.path.isdir(os.path.join(directory_path, name)) and
                        (name.startswith('mod-') or name.startswith('edge-'))]
        return folder_list
    except Exception as e:
        print(f"An error occurred: {e}")
        return []


def fetch_and_parse_json(url):
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an HTTPError for bad responses
        return response.json()  # Parses and returns the JSON content
    except requests.HTTPError as http_err:
        raise  # Re-raise the exception
    except Exception as err:
        raise  # Re-raise the exception


def fetch_and_parse_yaml(url):
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an HTTPError for bad responses
        return yaml.safe_load(response.text)  # Parses and returns the YAML content
    except requests.HTTPError as http_err:
        raise  # Re-raise the exception
    except Exception as err:
        raise  # Re-raise the exception


def bytes_to_megabytes(memory_bytes):
    # Convert bytes to megabytes in binary system
    megabytes = memory_bytes / (1024 ** 2)
    # Round to the nearest whole number
    rounded_megabytes = round(megabytes)
    return rounded_megabytes


def generate_config(modules, output_file):
    data = {}
    system_user_modules = []
    s3_integrated_modules = []
    total_memory = 0
    for module in modules:
        descriptor = ''
        try:
            descriptor = fetch_and_parse_json(spring_module_descriptor(module))
        except:
            try:
                descriptor = fetch_and_parse_json(rmb_module_descriptor(module))
            except:
                print("Descriptor not found for module:", module)

        if descriptor:
            launch_descriptor = descriptor.get('launchDescriptor', {})
            memory_bytes = launch_descriptor.get('dockerArgs', {}).get('HostConfig', {}).get('Memory', '')
            memory_bytes = memory_bytes if memory_bytes else 402653184
            total_memory = total_memory + memory_bytes
            env_vars = launch_descriptor.get('env', [])
            module_config = {
                'replicaCount': 1,
                'resources': {
                    'limits': {
                        'memory': f"{bytes_to_megabytes(memory_bytes + (memory_bytes * 0.25))}Mi"
                    },
                    'requests': {
                        'memory': f"{bytes_to_megabytes(memory_bytes)}Mi"
                    }
                },
                'integrations': {},
                'extraEnvVars': []
            }

            # Add integrations and collect extra environment variables
            for env_var in env_vars:
                name = env_var.get('name', '')
                if name in EXCLUDE_ENV_LIST:
                    continue
                is_integration = False
                for prefix, integration_key in INTEGRATIONS_MAP.items():
                    if name.startswith(prefix):
                        module_config['integrations'][integration_key] = {
                            'enabled': True,
                            'existingSecret': 'db-connect-modules'
                        }
                        is_integration = True
                        break
                    if name.startswith('S3') or name.startswith('AWS'):
                        s3_integrated_modules.append(module)

                if not is_integration:
                    module_config['extraEnvVars'].append({'name': env_var['name'], 'value': str(env_var['value'])})

            try:
                application_config = fetch_and_parse_yaml(application_yml_url(module))
                if 'system-user' in application_config['folio']:
                    module_config['integrations']['systemuser'] = {
                        'enabled': True,
                        'existingSecret': f"{module}-systemuser"
                    }
                    system_user_modules.append(module)
            except:
                "Application config not found for module:", {module}

            data[module] = module_config  # Collect configurations
        else:
            "No valid descriptor found for module:", {module}
    # print(yaml.dump(data))
    print('System user modules:', system_user_modules)
    print('S3 integrated modules:', list(set(s3_integrated_modules)))
    print('Memory requests:', bytes_to_megabytes(total_memory))
    print('Memory limits:', bytes_to_megabytes(total_memory + (total_memory * 0.25)))

    # Save the data to a file
    with open(output_file, 'w') as file:
        yaml.dump(data, file, default_flow_style=False, width=80)


if __name__ == "__main__":
    modules = list_folders_in_directory(HELM_CHARTS_DIR)
    generate_config(modules, OUTPUT_VALUES_FILE)
    # print("Folders:", modules)
