# RUN Once before terraform init to create remote state storage account and container
#!/usr/bin/bash
set -euo pipefail

ENV=${1:-dev}
SUBSCRIPTION_ID="1f69f3b3-56e3-4f4e-aec6-6e4f06d45e9e"
LOCATION="eastus"
RG_NAME="rg-chatterly-tfstate"
SA_NAME="stchatterlystate${ENV}"
CONTAINER_NAME="tfsstate"

echo "Bootstrapping Terraform remote state storage for environment: ${ENV}"

# Login to Azure CLI

az account show &>/dev/null || az login --use-device-code

az account set --subscription "$SUBSCRIPTION_ID"

# Create resource group if it doesn't exist

az group create --name "$RG_NAME" --location "$LOCATION" --output none

# Create Storage Account

echo "Creating Storage Account: $SA_NAME"

az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --output none

# Enable blob versioning for state file safety

az storage account blob-service-properties update --account-name "$SA_NAME" \
  --enable-versioning true \
  --output none

# Create Blob Container

echo "Creating Blob Container: $CONTAINER_NAME"

az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$SA_NAME" \
  --output none

echo "Terraform remote state storage setup complete for environment: ${ENV}"
echo "Now run: terraform init -backend-config=backend-${ENV}.tfvars"

