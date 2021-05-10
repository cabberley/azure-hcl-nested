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

if [ -z "$REGION" ]; then echo "Location not found." && exit 1; fi
if [ -z "$RESOURCEGROUP" ]; then echo "RESOURCEGROUP not found." && exit 1; fi

# Random string generator - don't change this.
if [ -z "$RAND" ]; then
    RAND="$(echo $RANDOM | tr '[0-9]' '[a-z]')"
fi

TEMPLATE="azuredeploy.json"


###############################
## RESOURCE CREATION         ##
###############################

#$az group update -n $RESOURCEGROUP --tag currentStatus=executorDownload:Ready
curl $TEMPLATE_URL -o $TEMPLATE

if [ -f "$TEMPLATE" ]; then
  printf "--Deploy ARM Template--"

  #$az group update -n $RESOURCEGROUP --tag currentStatus=executorTemplate:Ready > /dev/null 2>&1
  result=$($az deployment sub create --template-file $TEMPLATE --no-wait \
    --location $REGION \
    --parameters prefix=$RAND \
    --parameters serverUserName=$ADMIN_USER \
    --parameters serverPassword=$ADMIN_PASSWORD)
  echo $result
  #echo $result | jq -c '{Result: map({id: .id})}' > $AZ_SCRIPTS_OUTPUT_PATH"

  #$az group update -n $RESOURCEGROUP --tag currentStatus=executorTemplate:Submitted > /dev/null 2>&1
  sleep 30
else
  $az group update -n $RESOURCEGROUP --tag currentStatus=executorDownload:Failed
fi
