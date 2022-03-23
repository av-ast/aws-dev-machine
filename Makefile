BUCKET := $(shell cat backend.tf | grep bucket | awk '{print $$3}')
REMOTE_TFVARS_PATH := "s3://$(BUCKET)/terraform.tfvars"
LOCAL_TFVARS_PATH := "./tfvars/terraform.tfvars"

push_vars:
	aws s3 cp --sse="AES256" $(LOCAL_TFVARS_PATH) $(REMOTE_TFVARS_PATH)

pull_vars:
	aws s3 cp --sse="AES256" $(REMOTE_TFVARS_PATH) $(LOCAL_TFVARS_PATH)

format:
	terragrunt fmt -recursive

ssh:
	ssh -i generated/ssh_keys/dev_machine.pem ec2-user@18.206.71.150

.SILENT:
