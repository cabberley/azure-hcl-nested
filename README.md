# azure-hcl-nested

Single Region Deployment:  All resources deployed using a single region.

The Azure Cloud Shell can be run from the Portal, VSCode, Windows Terminal and it is also able to be used as a stand-alone experience by navigating to the https://shell.azure.com address.

Run the following script from azure cloud shell.

> This script requires the logged in user to have an `owner` role on the subscription.

```bash
REGION="centralus"
wget -O - https://raw.githubusercontent.com/danielscholl/azure-hcl-nested/main/run.sh | bash -s -- $REGION
```

