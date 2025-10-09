#!/bin/bash
# User data simplificado para LocalStack

echo "Iniciando instancia webapp"
echo "App Version: ${app_version}"
echo "Environment: ${environment}"
echo "AMI: ami-webapp-1.0.0 (built with Packer)"

mkdir -p /opt/webapp
echo "Instance started at $(date)" > /opt/webapp/status.txt
