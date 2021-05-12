# azure-hcl-nested

The purpose of this repository is to perform a proof of concept for setting up a hybrid solution with a controlled and secure network layer to access resources in the public cloud.

## Deployable Individual Templates

_Option 1_

This method of deployment hosts the templates in Azure and then allow for repeatable deployments from within the Portal.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Fazure-hcl-nested%2Fmain%2Ftemplates%2FtemplateDeploy.json)


__Operations Template__

This template is designed to setup what would be assume to be the items owned by an enterprise operations team as part of a Cloud Adoption Framework.

- Log Analytics Workspace
- Network Topology Items
- Firewall

__Control Plane Template__

This template is designed to setup what would be an example of a control plane.

- Data Management Items
- Key Vault
- Private Link Network Items

__Mock On-Prem Template__

This template is designed to setup the Nested Virtualization items necessary to simulate a Hybrid Scenario

- Virtual Machine
- Network Items
- Configuration Scripts

__Connect Network Templates__

These 2 templates establish the VPN connections between the Hub Network and Mock On-Prem Networks.

## Cloud Shell Single Solution

_Option 2_

This deployment uses Azure Cloud Shell to provision a full deployment automatically.

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