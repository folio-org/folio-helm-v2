<p align="center">
  <a href="https://github.com/folio-org/folio-helm-v2">
    <img src="https://avatars.githubusercontent.com/u/16495055" alt="FOLIO Helm Charts v2 logo" width="200px" height="200px">
  </a>
</p>

<h1 align="center">
  <div align="center" aria-colspan="0">FOLIO Helm Charts v2</div>
</h1>

<p align="center">
  <div align="center">
    <a href="https://kubernetes.io/releases/download/">
    <img src="https://img.shields.io/badge/K8S-1.22+-blue?style=for-the-badge" alt="K8S 1.22+" />
    </a>&nbsp;
    <a href="https://github.com/folio-org/folio-helm-v2/LICENSE">
    <img src="https://img.shields.io/badge/License-Apache_2.0-green?style=for-the-badge" alt="License Apache-2.0" />
    </a>&nbsp;
    <a href="https://helm.sh/docs/intro/install/">
    <img src="https://img.shields.io/badge/HELM-3.10+-blue?style=for-the-badge" alt="HELM 3.10+" />
    </a>&nbsp;
  </div>
</p>

## Introduction

This repository contains Helm charts for different modules of the FOLIO (The Future of Libraries is Open) project.
The FOLIO project aims to reimagine library software through a unique collaboration of libraries, developers, and
vendors.
It looks beyond the current model of an Integrated Library System to a new paradigm, where apps are built on an open
platform,
providing libraries with the ability to innovate and deliver extended services.

In this repository, you will find HELM charts for each FOLIO module.

## Structure

```markdown
folio-helm-v2/
├── README.md
├── example/ # module chart scaffold
│ ├── value.yaml # library entry point
│ ├── templates/
│ │ ├── application.yaml # main module template model
│ │ └── NOTES.txt # chart user instruction model
│ └── resources # resource file examples
│ ├── ephemeral.properties
│ └── log4j2.xml
└── charts/
├── <some-module>/ # FOLIO module HELM chart
│ ├── Chart.yaml # chart information
│ ├── values.yaml # default values for templates
│ ├── templates/
│ │ ├── application.yaml # main template
│ │ └── NOTES.txt # chart user instruction
│ └── resources/ # chart resource files
│ ├── ephemeral.properties
│ ├── ..................
│ └── log4j2.xml
├── ..................
└── folio-common/ # core helpers
├── Chart.yaml
├── values.yaml
└── templates/
├── _configmap.tpl
├── _deployment.tpl
├── _helpers.tpl
├── ...............
└── _volume.tpl
```

## Usage

### Chart usage

The charts in this repository allow users to deploy different modules of the FOLIO project to a Kubernetes cluster using
the Helm package manager. To deploy a module, follow these steps:

* Search for the particular FOLIO module you are interested in (For example, mod-users).
* Look at the values.yaml file to understand the default configurations available for this module. Usually,
  they have common [Parameters](#parameters) but some distinctions are possible.
* Use Helm to install the chart with your unique release name and appropriate configurations.

### Adding/Modifying Charts

For adding new charts or modifying existing ones, this repository is designed to make the process straightforward.

In the example directory, we have a scaffold that you can use as a base for creating new charts.

The key feature in this repository is the `charts/folio-common` directory. This directory contains core chart helpers
you need
to create Kubernetes deployments, services, ingresses, and so on.
The `folio-common` helpers are included in the `templates/application.yaml` file.

When creating new charts, use the existing pattern and make sure to cater for any unique characteristics
that the new module might have. But also it give a pattern that needs to be followed.

This approach ensures seamless deployments and maintenance of the FOLIO project modules.

Please DO NOT forget to increase the Chart version if changes were made.

After merging Pull Request to the master branch the
job https://jenkins-aws.indexdata.com/job/folioRancher/job/folioDevOpsTools/job/indexFolioHelmCharts/
will run, package and index chart in Nexus automatically.

## Prerequisites

- Kubernetes 1.22+
- Helm 3.10+

## Getting started

To add the repository locally, execute the following command before installing the first chart.
This command isn't necessary for subsequent chart installations.

```console
helm repo add folio-helm-v2 https://repository.folio.org/repository/folio-helm-v2/
```

## Install Chart

Should the repository have been added a while ago, run the following command to update the repository cache
with the latest changes before installing any chart.

```console
helm repo update folio-helm-v2
```

To install the chart invoke the following command.

```console
helm install my-install-name folio-helm-v2/CHART_NAME
```

> **Note**: Please make sure to replace `CHART_NAME` with the name of the chart that needs to be installed.
> The --version x.x.x attribute can be added at the end of the command to install a specific version of the chart.
> Otherwise, the latest version will be installed.

To get the exact name of a specific module chart, invoke the following command to see the full list of charts
and their latest version in the folio repository:

```console
helm search repo folio-helm-v2
```

The install command deploys a specific module on the Kubernetes cluster in the default configuration.
The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstall Chart

To uninstall/delete the `my-release-name` deployment invoke the command below.
This will remove all previously deployed Kubernetes components associated with the `my-release-name` deployment.

```console
helm uninstall my-release-name
```

## Parameters

### Common parameters

| Name                         | Description                                                                                                                                                                                                                                                                                                               | Common value                                           |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| `imagePullSecrets`           | Array provisioning credentials for pulling private Docker images.                                                                                                                                                                                                                                                         | `[]`                                                   |
| `nameOverride`               | Allows partial override names in template to prevent name conflicts/collisions across different environments or when multiple versions of the chart are installed in the same namespace.                                                                                                                                  | `""`                                                   |
| `fullnameOverride`           | Completely overrides names in template.                                                                                                                                                                                                                                                                                   | `""`                                                   |
| `replicaCount`               | Number of module's deployment replicas.                                                                                                                                                                                                                                                                                   | `1`                                                    |
| `startupProbe`               | Checks whether an application has started and identifies startup problems in applications with long initialization phases. Used with containers that don't start immediately.                                                                                                                                             | `{}`                                                   |
| `readinessProbe`             | Determines whether a container is ready to serve requests.                                                                                                                                                                                                                                                                | `{}`                                                   |
| `livenessProbe`              | Determines whether a container is healthy and running as expected.                                                                                                                                                                                                                                                        | `{}`                                                   |
| `podAnnotations`             | Pod annotations.                                                                                                                                                                                                                                                                                                          | `{}`                                                   |
| `podSecurityContext`         | Defines privilege and access control settings for pods. `securityContext` parameter directly applies to container and overrides this parameter.                                                                                                                                                                           | `{}`                                                   |
| `securityContext`            | Defines privilege and access control settings for containers.                                                                                                                                                                                                                                                             | `{}`                                                   |
| `nodeSelector`               | Controls on which nodes a pod gets scheduled.                                                                                                                                                                                                                                                                             | `{}`                                                   |
| `tolerations`                | Applied to pods allowing (but not requiring) the pods to schedule onto nodes with matching taints.                                                                                                                                                                                                                        | `[]`                                                   |
| `affinity`                   | Controls how the scheduler assigns pods to nodes.                                                                                                                                                                                                                                                                         | `{}`                                                   |
| `args`                       | Arguments passed to the command that is run in the container.                                                                                                                                                                                                                                                             | `[]`                                                   |
| `javaOpts`                   | Sets `JAVA_OPTIONS` environment variable for containers via env section.                                                                                                                                                                                                                                                  | `"-XX:MaxRAMPercentage=75.0"`                          |
| `extraJavaOpts`              | Adds additional values for `JAVA_OPTIONS` environment variable to containers via env section.                                                                                                                                                                                                                             | `[]`                                                   |
| `extraEnvVars`               | Adds additional env variables to containers via env section.                                                                                                                                                                                                                                                              | `[]`                                                   |
| `extraEnvVarsSecrets`        | Adds additional env variables to containers from either a ConfigMap or Secret without having to specify each one individually via envFrom section.                                                                                                                                                                        | `[]`                                                   |
| `heapDumpEnabled`            | If set to true, an emptydir volume is added, along with the `-XX:+HeapDumpOnOutOfMemoryError" "-XX:HeapDumpPath=/tmp/dump/"` arguments to receive heap dumps at the point of failure to understand what consumes the JVM's memory. Consider this option if the application encounters frequent `OutOfMemoryError` errors. | `false`                                                |
| `resources`                  | Adds resources section to the containers.                                                                                                                                                                                                                                                                                 | `limits:    memory: 384Mi   requests:   memory: 256Mi` |
| `autoscaling`                | Deploys HorizontalPodAutoscaler and disables `replicaCount` settings if `autoscaling.enabled` is true. Configure `minReplicas`, `maxReplicas`, etc. when enabling.                                                                                                                                                        | `autoscaling:    enabled: false`                       |
| `image.repository`           | Module's image repository (occasionally, it could be a URL).                                                                                                                                                                                                                                                              | `folioorg/IMAGE_NAME`                                  |
| `image.pullPolicy`           | Module's image pull policy (occasionally, it could be `Always`).                                                                                                                                                                                                                                                          | `IfNotPresent`                                         |
| `image.tag`                  | Module's image tag defaults to the chart appVersion (occasionally, it could be `"latest"`).                                                                                                                                                                                                                               | `""`                                                   |
| `serviceAccount.create`      | If `serviceAccount.create` is true, an additional ServiceAccount is created.                                                                                                                                                                                                                                              | `true`                                                 |
| `serviceAccount.annotations` | If `serviceAccount.create` is true, annotations are set inside the new ServiceAccount.                                                                                                                                                                                                                                    | `{}`                                                   |
| `serviceAccount.name`        | Defines the name of the new or existing ServiceAccount to be assigned to the pod, depending on the `serviceAccount.create` value.                                                                                                                                                                                         | `""`                                                   |
| `jmx.enabled`                | If `jmx.enabled` is true, `jmx.port` is exposed to allow JMX service to connect to the pod (e.g., a monitoring service or a JVM management console) and track its performance, memory usage, loaded classes, and other Java-related metrics.                                                                              | `false`                                                |
| `jmx.port`                   | Port for for prometheus jmx exporter.                                                                                                                                                                                                                                                                                     | `1099`                                                 |
| `jmx.agentPath`              | Location for prometheus jmx exporter agent and config.                                                                                                                                                                                                                                                                    | `1099`                                                 |
| `jmx.agentVersion`           | Version of Prometheus jmx exporter.                                                                                                                                                                                                                                                                                       | `1099`                                                 |

### Service parameters

| Name                          | Description                                                                                      | Common value |
|-------------------------------|--------------------------------------------------------------------------------------------------|--------------|
| `service.type`                | Service exposure strategy.                                                                       | `ClusterIP`  |
| `service.ports.name`          | Optional part of the port specification used when a service has multiple exposed ports.	         | `http`       |
| `service.ports.protocol`      | Network protocol that the service uses for the port.                                             | `TCP`        |
| `service.ports.port`          | Service port to be exposed.                                                                      | `80`         |
| `service.ports.containerPort` | Added to a Deployment specification to indicate the port that a container in the Pod listens on. | `8081`       |
| `service.ports.targetPort`    | Port name in the Pod and target port in the Service definition.                                  | `http`       |
| `service.annotations`         | Service annotations.                                                                             | `{}`         |

### Ingress parameters

| Name                           | Description                                                                       | Common value             |
|--------------------------------|-----------------------------------------------------------------------------------|--------------------------|
| `ingress.enabled`              | If `ingress.enabled` is true, a new Ingress is created.                           | `false`                  |
| `ingress.className`            | Name of the IngressClass in `ingressClassName` property of Ingress.               | `""`                     |
| `ingress.annotations`          | Ingress annotations.                                                              | `{}`                     |
| `ingress.tls`                  | An array of secrets and TLS hosts, optionally specifying the hosts they apply to. | `[]`                     |
| `ingress.hosts.host`           | Specifies the hostname to be matched so that the Ingress rules apply.             | `chart-example.local`    |
| `ingress.hosts.paths.path`     | Determines the path used to route HTTP(S) traffic to a specific service.          | `/*`                     |
| `ingress.hosts.paths.pathType` | Specifies how the path field should match incoming HTTP(S) requests.              | `ImplementationSpecific` |

### ConfigMaps parameters

| Name                             | Description                                                                                                                                                              | Common value                                                                                     |
|----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `configMaps.NAME`                | Defines existing or new ConfigMaps section with NAME (replace with the existing or desired name). Resource file used as a source for the data section of new ConfigMaps. | `ephemeral`, `apiconfig`, `log4j`, `sip2config`, `sip2tenants`                                   |
| `configMaps.NAME.enabled`        | If `configMaps.NAME.enabled` is true, volume with desired ConfigMaps is mounted as a volume to a container.                                                              | `true`                                                                                           |
| `configMaps.NAME.fileName`       | Name of a file used as a source for the data section of new ConfigMaps. Resides in the resource subfolder of the chart.                                                  | `ephemeral.properties`, `api_configuration.json`, `log4j2.xml`, `sip2.conf`, `sip2-tenants.conf` |
| `configMaps.NAME.mountPath`      | Mount path used in volume definition section with mapping of newly created ConfigMaps.                                                                                   | `/etc/edge`, `/etc/log4j2.xml`                                                                   |
| `configMaps.NAME.existingConfig` | Defines existing ConfigMaps name. If defined and `configMaps.NAME.enabled` is true, existing ConfigMaps are used and mapped to the volume.                               | `""`                                                                                             |

### Secret parameters

| Name                                | Description                                                                                                                                                      | Common value                                             |
|-------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| `integrations.NAME`                 | Defines either existing or new Secret with NAME (replace with the existing or desired name).                                                                     | `okapi`, `db`, `kafka`, `opensearch`, `systemuser`, `s3` |
| `integrations.NAME.enabled`         | If `integrations.NAME.enabled` is true, desired Secret is mapped via the secretRef section.                                                                      | `true`                                                   |
| `integrations.NAME.host`            | Host name that forms part of connection data in Secret. Can be omitted in some cases, depending on the the service requirements.                                 | `okapi`, `postgresql`, `kafka`, `localhost`              |
| `integrations.NAME.port`            | Port number forming part of connection data in Secret. Can be omitted in some cases depending on the the service requirements.                                   | `9130`, `5432`, `9092`, `443`                            |
| `integrations.NAME.url`             | URL forming part of connection data in Secret. Can be omitted in some cases depending on the the service requirements.                                           | `/etc/edge`, `/etc/log4j2.xml`                           |
| `integrations.NAME.username`        | Username that forms part of connection data in Secret. Can be omitted in some cases depending on the the service requirements.                                   | `/etc/edge`, `/etc/log4j2.xml`                           |
| `integrations.NAME.password`        | Password that forms part of connection data in Secret. Can be omitted in some cases depending on the the service requirements.                                   | `/etc/edge`, `/etc/log4j2.xml`                           |
| `integrations.NAME.name`            | A Name as a user name surrogate, consider it as user name data in Secret. Current utilization for the systemuser integration.                                    |                                                          |
| `integrations.NAME.hostReader`      | Host reader forming part of the data in Secret. Used for PostgreSQL integration.                                                                                 | `""`                                                     |
| `integrations.NAME.database`        | Database name forming part of connection data in Secret. Used in DB integration cases.                                                                           | `folio`                                                  |
| `integrations.NAME.charset`         | The charset used for working with database data. Used in DB integration cases.                                                                                   | `UTF-8`                                                  |
| `integrations.NAME.querytimeout`    | Refers to the amount of time that a single query or command can run before being automatically stopped or cancelled by the system. Used in DB integration cases. | `60000`                                                  |
| `integrations.NAME.maxpoolsize`     | Used to manage and limit the number of database connections kept open for future requests. Used in DB integration cases.                                         | `5`                                                      |
| `integrations.NAME.isAws`           | Flag that defines whether it's an AWS S3 or a Minio surrogate of AWS S3. Used in the AWS S3 integration case.                                                    | `true`                                                   |
| `integrations.NAME.sdk`             | An AWS SDK used in the AWS S3 integration case.                                                                                                                  | `/etc/edge`, `/etc/log4j2.xml`                           |
| `integrations.NAME.region`          | An AWS region for connection purpose. Used in AWS S3 integration case.                                                                                           | `""`                                                     |
| `integrations.NAME.bucket`          | Bucket to work with. Used in the AWS S3 integration case.                                                                                                        | `""`                                                     |
| `integrations.NAME.accessKeyId`     | An IAM user accessKeyId used for AWS CLI authorization. Used in AWS S3 integration case.                                                                         | `""`                                                     |
| `integrations.NAME.secretAccessKey` | An IAM user secretAccessKey used for AWS CLI authorization. Used in AWS S3 integration case.                                                                     | `""`                                                     |
| `integrations.NAME.forcepathstyle`  | A configuration setting that determines how the bucket name appears in the URL of your S3 objects.                                                               | `""`                                                     |
| `integrations.NAME.existingSecret`  | Defines an existing Secret name. If provided and `integrations.NAME.enabled` is true, the existing Secret will be utilised and mapped to the volume.             | `""`                                                     |

### Init container

| Name                                             | Description                                                                                                            | Common value |
|--------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|--------------|
| `initContainer.enabled`                          | If `initContainer.NAME.enabled` is true, a new init container will be added to the pod.                                | `false`      |
| `initContainer.image.repository`                 | An init container image name.                                                                                          |              |
| `initContainer.image.tag`                        | An init container image tag.                                                                                           | `latest`     |
| `initContainer.image.pullPolicy`                 | An init container image pull policy.                                                                                   | `Always`     |
| `initContainer.command`                          | Init container command list.                                                                                           | []           |
| `initContainer.args`                             | Arguments passed to the command that is run in the init container.                                                     | []           |
| `initContainer.extraVolumeMounts.NAME.enabled`   | If the extra volume mount element is enabled, a previously defined volume will be mounted to the pod's init container. | `false`      |
| `initContainer.extraVolumeMounts.NAME.name`      | A reference name to an existed extra volume.                                                                           |              |
| `initContainer.extraVolumeMounts.NAME.mountPath` | Extra volume mount path.                                                                                               |              |

### Volume claim (PVC) list element

| Name                                 | Description                                                                                                                                                    | Common value    |
|--------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------|
| `volumeClaims.NAME.enabled`          | If the volumeClaims element is enabled, a new PVC will be added to the namespace.                                                                              | `false`         |
| `volumeClaims.NAME.name`             | A new volume claim name.                                                                                                                                       |                 |
| `volumeClaims.NAME.storageClassName` | Storage class type name of the volume.                                                                                                                         | `gp2`           |
| `volumeClaims.NAME.size`             | Size of the PV to be allocated.                                                                                                                                | `10Gi`          |
| `volumeClaims.NAME.accessModes`      | Access mode type for the provided PV.                                                                                                                          | `ReadWriteOnce` |
| `volumeClaims.NAME.existingClaim`    | Defines an existing persistence volume claim. If provided and `volumeClaims.NAME.enabled` is true, the existing PVC will be utilized and mapped to the volume. |                 |

### Extra volume list element

| Name                                                | Description                                                                               | Common value |
|-----------------------------------------------------|-------------------------------------------------------------------------------------------|--------------|
| `extraVolumes.NAME.enabled`                         | If the extra volume element is enabled, a new volume will be added to the deployment pod. | `false`      |
| `extraVolumes.NAME.name`                            | An extra volume name.                                                                     |              |
| `extraVolumes.NAME.emptyDir`                        | Definition for the ephemeral local Kubernetes node volume (OPTIONAL).                     | `{}`         |
| `extraVolumes.NAME.persistentVolumeClaim.claimName` | A reference name for the existing PVC (defined or not in the chart) (OPTIONAL).           |              |

### Pod's container extra volume mount list element

| Name                               | Description                                                                                                       | Common value |
|------------------------------------|-------------------------------------------------------------------------------------------------------------------|--------------|
| `extraVolumeMounts.NAME.enabled`   | If the extra volume mount element is enabled, a previously defined volume will be mounted to the pod's container. | `false`      |
| `extraVolumeMounts.NAME.name`      | A reference name to an existed extra volume.                                                                      |              |
| `extraVolumeMounts.NAME.mountPath` | Extra volume mount path.                                                                                          |              |

### Eureka deployment parameters

| Name                                    | Description                                                                                | Common value                     |
|-----------------------------------------|--------------------------------------------------------------------------------------------|----------------------------------|
| `eureka.enabled`                        | If `eureka.enabled` is true, Eureka related resources are created. Is disabled by default. | `false`                          |
| `eureka.sidecarContainer.name`          | Sidecar Container Identificator Name.	                                                     | `sidecar`                        |
| `eureka.sidecarContainer.image`         | Sidecar Container Image Location to use for deployment.                                    | `folioorg/folio-module-sidecar`  |
| `eureka.sidecarContainer.tag`           | Sidecar Container Image Tag to be used.                                                    | `latest`                         |
| `eureka.sidecarContainer.containerPort` | Sidecar Container TCP port number in the Pod to listen on.                                 | `8082`                           |
| `eureka.sidecarContainer.port`          | Sidecar Container TCP port number to be exposed as a Service to outside world.             | `8082`                           |
| `eureka.sidecarContainer.amClientUrl`   | Sidecar Parameter: HTTP URL for Applications Manager service.                              | `http://mgr-applications`        |
| `eureka.sidecarContainer.teClientUrl`   | Sidecar Parameter: HTTP URL for Tenant Entitlements Manager service.                       | `http://mgr-tenant-entitlements` |
| `eureka.sidecarContainer.tmClientUrl`   | Sidecar Parameter: HTTP URL for Tenants Manager service.                                   | `http://mgr-tenants`             |

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install my-release-name \
    --set image.tag=latest \
    folio/CHART_NAME
```

> **Note**: Please make sure to replace `CHART_NAME` with the name of the chart that needs to be installed.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

```console
helm install my-release-name -f values.yaml folio/CHART_NAME
```

## License

Copyright (C) 2019-2023 The Open Library Foundation

This software is distributed under the terms of the Apache License,
Version 2.0. See the file "[LICENSE](LICENSE)" for more information.
