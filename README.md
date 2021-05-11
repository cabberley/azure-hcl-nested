# azure-hcl-nested

## Deployable Templates

_Option 1_

This method of deployment can host the templates in the cloud and then allow for repeatable deployments from within the Portal.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Fazure-hcl-nested%2Fmain%2Ftemplates%2FtemplateDeploy.json)

1. Deploy Operations Template
2. Deploy Mock On-Premises Template
3. Deploy Control Plane Template
4. Deploy Connect Operations Template
5. Deploy Connect Mock Template 

## Cloud Shell Single Solution

_Option 2_

This deployment uses the cloud shell to provision a full deployment automatically.

Run the following script from azure cloud shell.

```bash
PASSWORD="<admin_password>"
wget -O - https://raw.githubusercontent.com/danielscholl/azure-hcl-nested/main/scripts/setup.sh | bash -s -- $PASSWORD
```

> The Azure Cloud Shell can be run from the Portal, VSCode, Windows Terminal and it is also able to be used as a stand-alone experience by navigating to the https://shell.azure.com address.


## Architecture

This architecture is a demo to play with hybrid concepts of a cloud control plane with an on-prem data plane.

![[0]][0]
_Architecture Diagram_

[0]: ./images/Architecture.png "Architecture Diagram"