#!/usr/bin/env bash
#
#  Purpose: Initialize the solution load.
#  Usage:
#    createSolution.sh

# Get commandline for Azure CLI
az=$(which az)

###############################
## ARGUMENT INPUT            ##
###############################

if [ ! -z $1 ]; then TEMPLATE_URL=$1; else echo "TEMPLATE_URL not found." && exit 1; fi
if [ ! -z $ADMIN_USER ]; then ADMIN_USER=$1; else echo "Admin Username Required." && exit 1; fi
if [ ! -z $ADMIN_PASSWORD ]; then ADMIN_PASSWORD=$1; else echo "Admin Password Required." && exit 1; fi

if [ -z "$Location" ]; then echo "Location not found." && exit 1; fi
if [ -z "$RESOURCEGROUP" ]; then echo "RESOURCEGROUP not found." && exit 1; fi

# Random string generator - don't change this.
if [ -z "$RAND" ]; then
    RAND="$(echo $RANDOM | tr '[0-9]' '[a-z]')"
fi

###############################
## RESOURCE CREATION         ##
###############################

printf "================================================================================="
printf "Deploying Edge Solution.\n"
echo -n "  - TEMPLATE_URL: " $TEMPLATE_URL
echo -n "  - RESOURCEGROUP: " $RESOURCEGROUP
echo -n "  - Location: " $Location
echo -n "  - ADMIN_USER: " $ADMIN_USER
echo -n "  - RAND: " $RAND
echo -n "  - IDENTITY: " $IDENTITY_NAME
$az group update -n $RESOURCEGROUP --tag currentStatus=executorStart
sleep 3

curl $TEMPLATE_URL -o azuredeploy.json
$az group update -n $RESOURCEGROUP --tag currentStatus=executorDownloaded > /dev/null 2>&1
sleep 3

$az deployment sub create --template-file azuredeploy.json \
  --location $Location \
  --parameters prefix=$RAND \
  --parameters userIdentityName=$IDENTITY_NAME \
  --parameters serverUserName=$ADMIN_USER \
  --parameters serverPassword=$ADMIN_PASSWORD \
  -ojsonc
$az group update -n $RESOURCEGROUP --tag currentStatus=executorCompleted > /dev/null 2>&1
sleep 3

echo "================================================================================="