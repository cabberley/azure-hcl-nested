#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    install.sh


###############################
## ARGUMENT INPUT            ##
###############################


# Check if the first parameter given is there or not
if [ -z "$subId" ]; then
    echo "Script cannot run if the subscription ID is not given"
    exit 1
fi

# Check if the first parameter given is there or not
if [ -z "$password" ]; then
    echo "Script cannot run if the admin password is not given"
    exit 1
fi

# Check if the first parameter given is there or not
if [ -z "$RAND" ]; then
    echo "Script cannot run if the RAND characters are not given"
    exit 1
fi

if [ -z $location ]; then
  location="eastus"
fi

# Check if az is installed, if not exit the script out.
var='az'
if ! which $var &>/dev/null; then
    echo "This script will not run until Azure CLI is installed and you have been are logged in."
    exit 1
fi

RESOURCEGROUP="edge-${RAND}"

az=$(which az)

# Login using the device code method.
$az login --allow-no-subscriptions --output none
sleep 5s
$az account set --subscription $subId
$az config set core.only-show-errors=true

login_user=$($az account show --query user.name -otsv)
user=(${login_user//@/ })

###############################
## FUNCTIONS                 ##
###############################

# Create Environment Service Principal
principalName="http://edge-$RAND-principal"
if [ "$($az ad sp list --display-name $principalName --query [].appId -otsv)" = "" ]; then
  echo "================================================================================="
  echo -n "Creating Service Principal..."
  clientPassword=$($az ad sp create-for-rbac -n $principalName --role contributor --query password -o tsv)
  if [ -z "$clientPassword" ]; then
      echo "Script cannot finish because service principal was not created."
      $az group update -n $RESOURCEGROUP --tag currentStatus=spFailed > /dev/null 2>&1
      exit 1
  fi
  clientId=$($az ad sp show --id $principalName --query appId -o tsv)
  clientOid=$($az ad sp show --id $principalName --query objectId -o tsv)
  echo "Service Principal Created."
  $az group update -n $RESOURCEGROUP --tag currentStatus=spSuccess > /dev/null 2>&1
fi
echo "done."


###############################
## Azure Intialize           ##
###############################

if [ ! -f azuredeploy.json ]
then
echo "================================================================================="
echo -n "Downloading Edge Solution Template..."
echo ""
  wget https://raw.githubusercontent.com/danielscholl/azure-hcl-nested/main/azuredeploy.json > /dev/null 2>&1
  sleep 3
  $az group update -n $RESOURCEGROUP --tag currentStatus=Download > /dev/null 2>&1
fi

echo "================================================================================="
echo -n "Deploying Edge Solution..."
echo ""
$az group update -n $RESOURCEGROUP --tag currentStatus=Deploy > /dev/null 2>&1
$az deployment sub create --template-file azuredeploy.json  --no-wait \
  --location $location \
  --parameters servicePrincipalClientId=$clientId \
  --parameters servicePrincipalClientKey=$clientPassword \
  --parameters servicePrincipalObjectId=$clientOid \
  --parameters prefix=$RAND \
  --parameters serverUserName=$user \
  --parameters serverPassword=$password \
  -ojsonc
