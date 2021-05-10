# azure-hcl-nested

__Portal Deployable Templates__

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Fazure-hcl-nested%2Fmain%2Ftemplates%2FtemplateDeploy.json)

The Portal can be used to host the Templates and allow for Portal Deployable Manual Templates.


__Cloud Shell Single Solution__

The Azure Cloud Shell can be run from the Portal, VSCode, Windows Terminal and it is also able to be used as a stand-alone experience by navigating to the https://shell.azure.com address.

Run the following script from azure cloud shell.

> This script requires the logged in user to have an `owner` role on the subscription.

```bash
PASSWORD="<admin_password>"
wget -O - https://raw.githubusercontent.com/danielscholl/azure-hcl-nested/main/scripts/setup.sh | bash -s -- $PASSWORD
```