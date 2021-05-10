#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    createTemplate.sh

###############################
## ARGUMENT INPUT            ##
###############################

if [ ! -z $1 ]; then TEMPLATE_URL=$1; else echo "TEMPLATE_URL not found." && exit 1; fi

if [ -z "$Location" ]; then echo "Location not found." && exit 1; fi
if [ -z "$RESOURCEGROUP" ]; then echo "RESOURCEGROUP not found." && exit 1; fi

# Get commandline for Azure CLI
az=$(which az)

echo "================================================================================="
echo "Creating the solution template"
wget $TEMPLATE_URL -O templateSpec.json > /dev/null 2>&1
sleep 3
$az ts create --name "edgeSolution"  --resource-group $RESOURCEGROUP --location $Location --version "1.0" --template-file "./templateSpec.json" -o none 2>/dev/null
$az group update -n $RESOURCEGROUP --tag currentStatus=templateCreated > /dev/null 2>&1
echo "================================================================================="