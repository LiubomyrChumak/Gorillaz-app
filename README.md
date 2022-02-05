# Gorillaz fan page APP


## Table of contents
---
- [General info](#general-info)
- [Technologies](#technologies)
- [Setup](#setup)
- [Steps](#steps)


## General info

Complete guide how to deploy local docker image with web application on Azure App Services.


## Technologies
---
- Ubuntu
- Azure
- Docker
- Flask
 

## Setup
---
To run this project, you need to have installed:
- azure-cli
- docker
- latest pip version


## Steps


### Step 1
---
1. Download repo from GitHub:

`git clone https://github.com/LiubomyrChumak/Gorillaz-app/` 

2. Buid and test image locally:

`sudo docker image build -t flask_docker .`

`docker images`


### Step 2
---

1. Login to Azure:

`az login`

2. Create a resource group:

`az group create --name myResourceGroup --location westeurope`

3. Push the image to ACR: 

`az acr create --name gorillazpage --resource-group myResourceGroup --sku Basic --admin-enabled true`

4. Check credentials:

`az acr credential show -n gorillazpage`

5. Sign in to the container registry:

`sudo docker login gorillazpage.azurecr.io --username gorillazpage`

6. Tag your local Docker image for the registry:

`sudo docker tag flask_docker gorillazpage.azurecr.io/flask_docker:latest`

7. Push the image to the registry:

`docker tag flask_docker gorillazpage.azurecr.io/flask_docker:latest`

8. Verify that the push was succesful:

`az acr repository list -n gorillazpage`


### Step 3
---

1. Create an AppService plan:

`az appservice plan create --name myAppServicePlan --resource-group myResourceGroup --is-linux`

2. Create the web app:
```
az webapp create --resource-group myResourceGroup --plan myAppServicePlan --name gorillazpageapp --deployment-container-image-name gorillazpage.azurecr.io/flask_docker:latest
```
3. Use az webapp config appsettings set to set the 'WEBSITES_PORT' environment variable as expected by the app code:

`az webapp config appsettings set --resource-group myResourceGroup --name gorillazpageapp --settings WEBSITES_PORT=8000`

4. Enable the system-assigned managed identity for the web app by using the az webapp identity assign command:

`az webapp identity assign --resource-group myResourceGroup --name gorillazpageapp --query principalId --output tsv`

5. Retrieve your subscription ID with the az account show command, which you need in the next step:

`az account show --query id --output tsv`

6. Grant the managed identity permission to access the container registry:

`az role assignment create --assignee <principal-id> --scope /subscriptions/<subscription-id>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerRegistry/registries/gorillazpage --role "AcrPull"`

7. Configure your app to use the managed identity to pull from Azure Container Registry:

`az resource update --ids /subscriptions/<subscription-id>/resourceGroups/myResourceGroup/providers/Microsoft.Web/sites/gorillazpageapp/config/web --set properties.acrUseManagedIdentityCreds=True`


### Step 4
---
 
1. Use the az webapp config container set command to specify the container registry and the image to deploy for the web app: 

`az webapp config container set --name gorillazpage --resource-group myResourceGroup --docker-custom-image-name gorillazpage.azurecr.io/flask_docker:latest --docker-registry-server-url https://gorillazpage.azurecr.io`

2. Once the az webapp config container set command completes, the web app should be running in the container on App Service.

To test the app, browse to https://gorillazpageapp.azurewebsites.net
