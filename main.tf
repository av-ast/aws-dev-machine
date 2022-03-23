module "network" {
  source             = "./modules/network"
  cidr               = var.cidr
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

module "security_groups" {
  source = "./modules/security_groups"
  name   = var.project
  vpc_id = module.network.vpc_id
}

module "dev_machine" {
  source                = "./modules/dev_machine"
  project               = var.project
  subnet_id             = module.network.public_subnets[0].id
  security_groups       = module.security_groups
  ssh_pem_file          = "generated/ssh_keys/dev_machine.pem"
  instance_type         = "t3.medium"
  instance_ami          = var.instance_ami
  instance_volume_size  = 50
}
