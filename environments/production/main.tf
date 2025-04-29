module "swarm" {
  source                = "../../modules/cloud/aws/compute/swarm"
  private_key_path      = "${path.module}/private_key.pem"
  account_id            = var.account_id
  age_key_path          = "${path.module}/key.txt"
  compose_file          = "../../docker-compose.yml"
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  gh_pat                = var.gh_pat
  gh_owner              = "TheEndIsNear"
  image_to_deploy       = "ghcr.io/theendisnear/kanban:latest"
}

module "repository_secrets" {
  source = "../../modules/integrations/github/secrets"
  secrets = {
    "PRIVATE_KEY"           = module.swarm.private_key,
    "AWS_ACCESS_KEY"        = var.aws_access_key_id,
    "AWS_SECRET_ACCESS_KEY" = var.aws_secret_access_key,
    "AGE_KEY"               = var.age_key,
    "GH_PAT"                = var.gh_pat
  }
  repository   = "kanban"
  github_owner = "theendisnear"
}

module "contributing_workflow" {
  source       = "../../modules/integrations/github/contributing_workflow"
  repository   = "kanban"
  github_owner = "theendisnear"
  status_checks = [
    "Compile with mix test, format, dialyzer & unused deps check"
  ]
}

output "swarm_ssh_commands" {
  value = module.swarm.ssh_commands
}
