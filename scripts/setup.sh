#!/usr/bin/env bash
#
#  Purpose: Initialize the deployable templates necessary for building the solution.
#  Usage:
#    setup.sh

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
    LOCATION="eastus2"
fi

if [ -z "$REGION_PAIR" ]; then
    REGION_PAIR=$($az account list-locations --query "[?name=='$LOCATION']".metadata.pairedRegion[0].name -otsv)
fi

RESOURCEGROUP="edge-${RAND}"


###############################
## RESOURCE CREATION         ##
###############################

echo "================================================================================="
echo -n "Deploying Edge Solution..."
echo ""
curl https://raw.githubusercontent.com/cabberley/azure-hcl-nested/main/azuredeploy.json -o azuredeploy2.json > /dev/null 2>&1
$az deployment sub create --template-file azuredeploy2.json  --no-wait \
  --location $LOCATION \
  --parameters prefix=$RAND \
  --parameters replicaRegion=$REGION_PAIR \
  --parameters serverUserName=$ADMIN_USER \
  --parameters serverPassword=$ADMIN_PASSWORD \
  -ojsonc
echo "done."
sleep 10


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

