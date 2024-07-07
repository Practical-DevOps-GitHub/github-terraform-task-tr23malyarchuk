terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

variable "github_pat_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

provider "github" {
  token = var.github_pat_token
}

resource "github_repository" "repo" {
  name        = "github-terraform-task-tr23malyarchuk"
  description = "Repository configured by Terraform"
  visibility  = "public"  # Changed visibility to public
}

resource "github_branch" "develop" {
  repository = github_repository.repo.name
  branch     = "develop"
}

resource "github_branch_default" "default_branch" {
  repository = github_repository.repo.name
  branch     = "develop"
}

resource "github_repository_collaborator" "softservedata" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.repo.id
  pattern       = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews       = true
    require_code_owner_reviews  = true
    required_approving_review_count = 1
  }

  enforce_admins = true

  required_status_checks {
    strict   = true
    contexts = []
  }
}

resource "github_branch_protection" "develop" {
  repository_id = github_repository.repo.id
  pattern       = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews       = true
    required_approving_review_count = 2
  }
}

resource "github_repository_file" "pull_request_template" {
  repository = github_repository.repo.name
  file       = ".github/pull_request_template.md"
  content    = <<-EOF
# Pull Request Template

## Describe your changes

## Issue ticket number and link

## Checklist before requesting a review
- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOF
  commit_message = "Add pull request template"
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = github_repository.repo.name
  title      = "DEPLOY_KEY"
  key        = var.deploy_key_public_key
  read_only  = false
}

resource "github_actions_secret" "pat" {
  repository       = github_repository.repo.name
  secret_name      = "PAT"
  plaintext_value  = var.github_pat_token
}

resource "github_repository_file" "codeowners" {
  repository = github_repository.repo.name
  file       = ".github/CODEOWNERS"
  content    = <<-EOF
# CODEOWNERS file

* @softservedata
EOF
  commit_message = "Add CODEOWNERS file"
}

variable "deploy_key_public_key" {
  description = "Deploy Key Public Key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCliadMujs5abAHxToy/iE6NihG8dZTVXw8xRsIs0+HEP6DvqhVaMjmzNft3M4oo6Cb3EULt5ZYKSWA/oRamPt7qrCp8sRi2s9azhNAwkVuyAKzR8mq2iacK1rsqQeYgmxlpj6iHB6X3yDRG4vm+KLbFiv8Vpbv7QsbVMwW7Q0kHVEI5E7xCLxXwPBicNCH8mwpoR82BNz3+e814vIRMBH3te28iHDYLkmB2P/VVB1AF0zwXt4i6FqlLEY16x7iX5qkGZt54C2hL5Mff0EDW3J37OMsY9amcM7gGFp2tS+EX3Mp7Qqr+m04DUKKdfUXnNbTEs2ns26E8GnkXZ/86o5yKkj3nfd+WzcFvau/wdpv7Hw0RhkwwcQbUA03QBpEj3obO57tBsR/ZLBo+YkJ2A+l3WOY0nGCJ7zSfmwEPA0px5gQNdOCrSG57hbxCEDbwsmfpfpePw0UfVEZSCNkSVgvSK+TxZFokNmdHU27l8guPfKyS13rtILIYkjibOQXASDCfJryQQnw4xrwaWIiNqQJzTQLki1TlouVOWX6MY/FrNMPKJwwoFSqf/Ck4yA3l9RAu/NmKhTaIAcqc0qy/QA4xYU5qGffw5Pk3+OXioVJC7/2gFL7/vAuZMPJVOF2omzoR4mr8OOuQkZ2Xpcze1u7hPN7qe1RvqfsUOLanxRNBw== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}

