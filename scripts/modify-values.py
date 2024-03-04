from ruamel.yaml import YAML
import sys
import requests


def modify_yaml(file_path, nested_keys, value):
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.indent(mapping=2, sequence=4, offset=2)
    with open(file_path, 'r') as f:
        data = yaml.load(f)

    # Traverse and modify the nested keys
    temp = data
    for key in nested_keys[:-1]:
        temp = temp[key]
    temp[nested_keys[-1]] = value

    with open(file_path, 'w') as f:
        yaml.dump(data, f)


def fetch_and_parse_json(url):
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an HTTPError for bad responses
        return response.json()  # Parses and returns the JSON content
    except requests.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
    except Exception as err:
        print(f"An error occurred: {err}")
        return None


def spring_module_descriptor(module_name):
    return f"https://raw.githubusercontent.com/folio-org/{module_name}/master/descriptors/ModuleDescriptor-template.json"

def rmb_module_descriptor(module_name):
    return f"https://github.com/folio-org/{module_name}/blob/master/service/src/main/okapi/ModuleDescriptor-template.json"


if __name__ == "__main__":
    try:
        file_path = '../charts/mod-consortia/values.yaml'
        keys_to_modify = ['replicaCount']
        new_value = 2
        modify_yaml(file_path, keys_to_modify, new_value)
        print(f"Updated {'.'.join(keys_to_modify)} in {file_path}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
