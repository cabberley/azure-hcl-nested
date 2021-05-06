#!/usr/bin/env bash
#
#  Purpose: Initialize the common resources necessary for building infrastructure.
#  Usage:
#    run.sh

###############################
## ARGUMENT INPUT            ##
###############################

# Random string generator - don't change this.
RAND="$(echo $RANDOM | tr '[0-9]' '[a-z]')"

if [ ! -z $1 ]; then password=$1; else echo "Password Required." && exit 1; fi

LOCATION="eastus"
RESOURCEGROUP="edge-${RAND}"

# Get commandline for Azure CLI
az=$(which az)

# Fetch the CloudShell subscription ID
subId=$($az account show --query id -o tsv 2>/dev/null)

echo "==============================================================================================================================================================="
if [ ! "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "groupCreated" ]; then
    # Deploy the resource group and update Status Tag
    echo "Deploying the resource group."
    $az group create -g "$RESOURCEGROUP" -l "$LOCATION" -o none 2>/dev/null
    $az group update -n $RESOURCEGROUP --tag currentStatus=groupCreated 2>/dev/null
    echo "done."
fi

echo "==============================================================================================================================================================="

if [ ! "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "containerCreated" ]; then
    echo "Deploying the container (might take 2-3 minutes)..."
    $az container create -g $RESOURCEGROUP --name deployment --image danielscholl/hcl-nested  --restart-policy Never --environment-variables subId=$subId password=$password RAND=$RAND -o none 2>/dev/null
    $az group update -n $RESOURCEGROUP --tag currentStatus=containerCreated 2>/dev/null
    echo "done."
fi

echo "==============================================================================================================================================================="
echo "==============================================================================================================================================================="
echo "If cloudshell times out copy this command and run it again when cloud shell is restarted:"
echo "     az container logs --follow -n deployment -g $RESOURCEGROUP"
echo "==============================================================================================================================================================="
echo "==============================================================================================================================================================="

if [ "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "containerCreated" ]; then
    echo "Tail Logs"
    $az container logs -n deployment -g $RESOURCEGROUP 2>/dev/null
fi
