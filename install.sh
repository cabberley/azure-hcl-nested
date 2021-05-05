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
if [ -z "$RAND" ]; then
    echo "Script cannot run if the RAND characters are not given"
    exit 1
fi

# Check if the first parameter given is there or not
if [ -z "$ENVIRONMENT" ]; then
    echo "Script cannot run if the Environment is not given"
    exit 1
fi


if [ ! -z $1 ]; then ENVIRONMENT=$1; fi
if [ -z $ENVIRONMENT ]; then
  ENVIRONMENT="dev"
fi

if [ -z $AZURE_LOCATION ]; then
  AZURE_LOCATION="eastus"
fi

# Check if az is installed, if not exit the script out.
var='az'
if ! which $var &>/dev/null; then
    echo "This script will not run until Azure CLI is installed and you have been are logged in."
    exit 1
fi

az=$(which az)

# Login using the device code method.
$az login --allow-no-subscriptions --output none
sleep 5s
$az account set --subscription $subId
$az config set core.only-show-errors=true

AZURE_USER=$($az account show --query user.name -otsv)
CLEAN_USER=(${AZURE_USER//@/ })

###############################
## FUNCTIONS                 ##
###############################

# Create Environment Service Principal
principalName="http://edge-$ENVIRONMENT-$RAND-Principal"
if [ "$($az ad sp list --display-name $principalName --query [].appId -otsv)" = "" ]; then
  echo "============================================================================================================="
  echo -n "Creating Service Principal..."
  clientPassword=$($az ad sp create-for-rbac -n $principalName --role contributor --query password -o tsv)
  if [ -z "$clientPassword" ]; then
      echo "Script cannot finish because service principal was not created."
      $az group update -n $RESOURCEGROUP --tag currentStatus=spCreationFailed 2>/dev/null
      exit 1
  fi
  clientId=$($az ad sp show --id $principalName --query appId -o tsv)
  clientOid=$($az ad sp show --id $principalName --query objectId -o tsv)
  echo "Service Principal Created."
fi
echo "done."




###############################
## Azure Intialize           ##
###############################


echo "============================================================================================================="
echo -n "Deploying ARM Template..."
if [ ! -f azuredeploy.json ]
then
    curl https://raw.githubusercontent.com/danielscholl/azure-hcl-nested/main/azuredeploy.json -O azuredeploy.json
else
    echo "File found. Do something meaningful here"
fi
az deployment sub create --template-file azuredeploy.json  \
  --location $AZURE_LOCATION \
  --parameters servicePrincipalClientId=$clientId \
  --parameters servicePrincipalClientKey=$clientPassword \
  --parameters servicePrincipalObjectId=$clientOid \
  --parameters prefix=$ENVIRONMENT \
  --parameters serverUserName=$CLEAN_USER \
  -ojsonc
