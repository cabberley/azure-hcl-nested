# azure-hcl-nested

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Fazure-hcl-nested%2Fmain%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


Single Region Deployment:  All resources deployed using a single region.

The Azure Cloud Shell can be run from the Portal, VSCode, Windows Terminal and it is also able to be used as a stand-alone experience by navigating to the https://shell.azure.com address.

Run the following script from azure cloud shell.

> This script requires the logged in user to have an `owner` role on the subscription.

```bash
PASSWORD="<admin_password>"
wget -O - https://raw.githubusercontent.com/danielscholl/azure-hcl-nested/main/run.sh | bash -s -- $PASSWORD
```

__Manually Deploy a Template__

```bash
# Create a Service Principal
az ad sp create-for-rbac -n http://edge-principal --role contributor

# Deploy Template
az deployment sub create --template-file azuredeploy.json  --no-wait \
  --location eastus \
  --parameters azuredeploy.parameters.json \
  -ojsonc
```