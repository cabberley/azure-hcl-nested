#!/usr/bin/env bash
#
#  Purpose: Initialize the common resources necessary for building infrastructure.
#  Usage:
#    run.sh

###############################
## ARGUMENT INPUT            ##
###############################

if [ ! -z $1 ]; then password=$1; else echo "Password Required." && exit 1; fi

# Random string generator - don't change this.
if [ -z "$RAND" ]; then
    RAND="$(echo $RANDOM | tr '[0-9]' '[a-z]')"
fi

if [ -z "$LOCATION" ]; then
    LOCATION="eastus"
fi

RESOURCEGROUP="edge-${RAND}"


# Get commandline for Azure CLI
az=$(which az)

# Fetch the CloudShell subscription ID
subId=$($az account show --query id -o tsv 2>/dev/null)

# Create Resource Group
echo "================================================================================================================="
if [ ! "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "groupCreated" ]; then
    # Deploy the resource group and update Status Tag
    echo "Deploying the resource group."
    $az group create -g "$RESOURCEGROUP" -l "$LOCATION" -o none > /dev/null 2>&1
    $az group update -n $RESOURCEGROUP --tag currentStatus=groupCreated > /dev/null 2>&1
    echo "Resource Group: " $RESOURCEGROUP
fi

# Create Managed Identity
managedIdentity="edge-${RAND}-identity"
echo "================================================================================================================="
if [ "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "groupCreated" ]; then
    # Deploy the user managed identity and update Status Tag
    echo "Deploying the user managed identity."
    clientId=$($az identity create -g $RESOURCEGROUP -n $managedIdentity --query clientId -o tsv 2>/dev/null)
    sleep 30
    $az role assignment create --role "Contributor" --scope "/subscriptions/$subId" --assignee $clientId > /dev/null 2>&1
    $az group update -n $RESOURCEGROUP --tag currentStatus=identityCreated > /dev/null 2>&1
    echo "Managed Identity:" $managedIdentity
fi

# Create Storage Account
storageName="edge${RAND}storage"
fileShare="scripts"
if [ "$($az storage account check-name --name $storageName --query nameAvailable -o tsv 2>/dev/null)" = "true" ]; then
    echo "============================================================================================================="
    echo "Deploying the storage account."
    $az storage account create --name $storageName --resource-group $RESOURCEGROUP --location $LOCATION --sku Standard_LRS -o none 2>/dev/null
    $az storage share create --account-name $storageName --name $fileShare -o none 2>/dev/null
    $az group update -n $RESOURCEGROUP --tag currentStatus=storageCreated > /dev/null 2>&1
    echo "Storage Account: " $storageName
fi


echo "================================================================================================================="
if [ "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "storageCreated" ]; then
    echo "Deploying the container (might take 2-3 minutes)..."
    $az container create -g $RESOURCEGROUP --name deployment --image danielscholl/hcl-nested  --restart-policy Never --environment-variables subId=$subId password=$password RAND=$RAND -o none 2>/dev/null
    $az group update -n $RESOURCEGROUP --tag currentStatus=containerCreated > /dev/null 2>&1
    echo "done."
fi

echo "================================================================================================================="
echo "================================================================================================================="
echo "If cloudshell times out copy this command and run it again when cloud shell is restarted:"
echo "     az container logs --follow -n deployment -g $RESOURCEGROUP"
echo "================================================================================================================="
echo "================================================================================================================="
sleep 10

if [ "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "containerCreated" ]; then
    echo "Tail Logs"
    $az container logs -n deployment -g $RESOURCEGROUP 2>/dev/null
fi
