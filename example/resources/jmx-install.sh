#!/bin/sh
set -e
JMX_AGENT_VERSION="{{ .Values.jmx.agentVersion }}"
JMX_AGENT_PATH="{{ .Values.jmx.agentPath }}"
AGENT_URL="https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/$JMX_AGENT_VERSION/jmx_prometheus_javaagent-$JMX_AGENT_VERSION.jar"
echo "Downloading JMX Agent version $JMX_AGENT_VERSION..."
wget -q -O "$JMX_AGENT_PATH/jmx_prometheus_javaagent-$JMX_AGENT_VERSION.jar" "$AGENT_URL"
echo "Download complete."
ls -la "$JMX_AGENT_PATH"
