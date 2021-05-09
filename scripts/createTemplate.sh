#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    createTemplate.sh

wget $1 -O templateSpec.json
sleep 3
az ts create --name edgeSolution  --resource-group $RESOURCEGROUP --location $LOCATION --version 1.0 --template-file ./templateSpec.json