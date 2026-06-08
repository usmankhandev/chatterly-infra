# Makefile - Chatterly Infra for ENV=dev

ENV ?= dev
TFVARS = environments/$(ENV)/terraform.tfvars

help:
	@echo "Usage: make [target] ENV=[environment]"
	@echo "Targets:"
	@echo "  plan    - Run terraform plan"
	@echo "  apply   - Run terraform apply"
	@echo "  destroy - Run terraform destroy"

init:
	terraform init
plan:
	terraform plan -var-file=$(TFVARS)
apply:
	terraform apply -var-file=$(TFVARS)
apply-auto:
	terraform apply -var-file=$(TFVARS) -auto-approve
destroy:
	terraform destroy -var-file=$(TFVARS)
fmt:
	terraform fmt -recursive
validate:
	terraform validate
outpute:
	terraform output
kubeconfig:
	terraform output -raw kubeconfig > kubeconfig_$(ENV)
	

