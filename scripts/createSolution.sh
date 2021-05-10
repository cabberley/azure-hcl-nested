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

echo "================================================================================="
echo ""
echo -n "Deploying Edge Solution."
echo -n "  - TEMPLATE_URL: " $TEMPLATE_URL
echo -n "  - RESOURCEGROUP: " $RESOURCEGROUP
echo -n "  - Location: " $Location
echo -n "  - ADMIN_USER: " $ADMIN_USER
echo -n "  - RAND: " $RAND
$az group update -n $RESOURCEGROUP --tag currentStatus=executorStart > /dev/null 2>&1
sleep 3

wget $TEMPLATE_URL -O templateSpec.json
$az group update -n $RESOURCEGROUP --tag currentStatus=executorDownloaded > /dev/null 2>&1
sleep 3

$az deployment sub create --template-file azuredeploy.json  --no-wait \
  --location $Location \
  --parameters prefix=$RAND \
  --parameters identityId=$identityId \
  --parameters serverUserName=$ADMIN_USER \
  --parameters serverPassword=$ADMIN_PASSWORD \
  -ojsonc
$az group update -n $RESOURCEGROUP --tag currentStatus=executorCompleted > /dev/null 2>&1
sleep 3

echo "================================================================================="