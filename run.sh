#!/usr/bin/env bash
#
#  Purpose: Initialize the common resources necessary for building infrastructure.
#  Usage:
#    run.sh

# Get commandline for Azure CLI
az=$(which az)

###############################
## ARGUMENT INPUT            ##
###############################

if [ ! -z $1 ]; then ADMIN_PASSWORD=$1; else echo "Password Required." && exit 1; fi

# Fetch the subscription ID
subId=$($az account show --query id -o tsv 2>/dev/null)

# Random string generator - don't change this.
if [ -z "$RAND" ]; then
    RAND="$(echo $RANDOM | tr '[0-9]' '[a-z]')"
fi

# Establish the User
if [ -z "$ADMIN_USER" ]; then
  login_user=$($az account show --query user.name -otsv)
  ADMIN_USER=(${login_user//@/ })
fi

if [ -z "$LOCATION" ]; then
    LOCATION="eastus"
fi

RESOURCEGROUP="edge-${RAND}"


###############################
## RESOURCE CREATION         ##
###############################

# Create Resource Group
echo "================================================================================================================="
if [ ! "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "groupCreated" ]; then
    # Deploy the resource group and update Status Tag
    echo "Creating a resource group."
    $az group create -g "$RESOURCEGROUP" -l "$LOCATION" -o none > /dev/null 2>&1
    $az group update -n $RESOURCEGROUP --tag currentStatus=groupCreated > /dev/null 2>&1
    echo "Resource Group: " $RESOURCEGROUP
fi

# Create Managed Identity
# IDENTITY_NAME="edge-${RAND}-identity"
# echo "================================================================================================================="
# if [ "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "groupCreated" ]; then
#     # Deploy the user managed identity and update Status Tag
#     echo "Creating a user managed identity."
#     clientId=$($az identity create -g $RESOURCEGROUP -n $IDENTITY_NAME --query clientId -o tsv 2>/dev/null)
#     sleep 30
#     $az role assignment create --role "Contributor" --scope "/subscriptions/$subId" --assignee $clientId > /dev/null 2>&1
#     $az ad app permission add --id $clientId --api 00000002-0000-0000-c000-000000000000 --api-permissions 824c81eb-e3f8-4ee6-8f6d-de7f50d565b7=Role -o none 2>/dev/null
#     IDENTITY_ID=$($az identity list --query "[?name=='$IDENTITY_NAME'].id" -otsv)
#     $az group update -n $RESOURCEGROUP --tag currentStatus=identityCreated > /dev/null 2>&1
#     echo "Managed Identity:" $IDENTITY_NAME
#     echo "Managed Identity ID: $IDENTITY_ID"
# fi

echo "================================================================================="
echo -n "Deploying Edge Solution..."
echo ""
curl https://raw.githubusercontent.com/danielscholl/azure-hcl-nested/main/azuredeploy.json -o azuredeploy.json > /dev/null 2>&1
$az group update -n $RESOURCEGROUP --tag currentStatus=Deploy > /dev/null 2>&1

if [ -z "$DEPLOY" ]; then
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
else
  echo "================================================================================="
  echo -n "Deploying Edge Solution..."
  echo ""
  $az group update -n $RESOURCEGROUP --tag currentStatus=Deploy > /dev/null 2>&1
  $az deployment sub create --template-file azuredeploy.json  --no-wait \
    --location $LOCATION \
    --parameters prefix=$RAND \
    --parameters serverUserName=$ADMIN_USER \
    --parameters serverPassword=$ADMIN_PASSWORD \
    -ojsonc
fi


