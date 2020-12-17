#Makefile
.PHONY: all

all: init plan build

init:
		rm -rf .terraform/modules/
		terraform init -reconfigure

plan: init fmt
		terraform plan -refresh=true

build: init fmt
		terraform apply -auto-approve

check: init fmt
		terraform plan -detailed-exitcode
 
refresh: init fmt
		terraform refresh

destroy: init fmt
		terraform destroy -force

docs:
		terraform-docs md . > README.md

valid:
		tflint
		terraform fmt -check=true -diff=true

fmt:
	terraform fmt -recursive -diff ../