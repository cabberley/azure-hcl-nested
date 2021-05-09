#!/usr/bin/env bash
#
#  Purpose: Create a Resource Group and Lock
#  Usage:
#    createGroup.sh

###############################
## ARGUMENT INPUT            ##
###############################

if [ ! -z $1 ]; then RESOURCEGROUP=$1; else echo "RESOURCEGROUP not found." && exit 1; fi
if [ -z "$Location" ]; then echo "Location not found." && exit 1; fi

# Get commandline for Azure CLI
az=$(which az)

env

# Create Resource Group
echo "================================================================================================================="
local _result=$($az group show --name $RESOURCEGROUP)
if [ "$_result"  == "" ]
then
  OUTPUT=$($az group create --name $RESOURCEGROUP \
    --location $location \
    -ojsonc)
  $az group lock create --lock-type CanNotDelete -n "DontDelete" -g $RESOURCEGROUP
  echo "Resource Group: " $RESOURCEGROUP
else
  echo "Resource Group $RESOURCEGROUP already exists."
fi