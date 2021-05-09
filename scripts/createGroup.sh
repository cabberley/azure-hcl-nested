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


# Create Resource Group
echo "================================================================================================================="
if [ ! "$($az group show -n $RESOURCEGROUP --query tags.currentStatus -o tsv 2>/dev/null)" = "groupCreated" ]; then
    # Deploy the resource group and update Status Tag
    echo "Creating a resource group."
    $az group create -g "$RESOURCEGROUP" -l "$Location" -o none > /dev/null 2>&1
    $az group lock create --lock-type CanNotDelete -n "DontDelete" -g $RESOURCEGROUP
    echo "Resource Group: " $RESOURCEGROUP
fi