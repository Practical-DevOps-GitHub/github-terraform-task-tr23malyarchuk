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

variable "deploy_key_public_key" {
  description = "Deploy Key Public Key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDO5Tst9MOrhXKI7VPhGJszR7rxvXkTVb3ANDlWMMBL6VzZNJlpPyjWEaUarl8+xQ0CDXkZyD0OZ8BZRRsyV/e2/yn465N5UdiBJ14aJFhOrMAIP/YPg6ZmL1xOxrh8MPdW9VgjB9ez6/1QlMAZbQJJvQQgnMT8qU6RWEN6EokMdbQmDRpXodDicmHUMNMF3GDoiG8U6ArmWcn1g2uubEh7/6ZAmFhNuAhZCn+Afzi6fDQYbH18fVPVL1spHcOuoyJ0vh7QVf3zYom/+C1SEt36+Y3qsttjP5upTQWujKNEohFnuhkdV4wxAsZv2P20YXvQfFxoDDteAXnG1EICoSi4HE3CNQmKcVhFsBk7dvydu8v8nL8ZFcfvg/8UtBs/09C4MH6rVC5EmV7BlhIwOT85lgZC4snt7w2BVkFbIH7APmxbnsilnU1+VxHO+ndcT2gxh2GvfJRYkL1rAooydjHnkpvL46EXNachQDrlMKckHftOnsnv5GPrOWUUGMdsu09gfKXiAORBpUXCYDaabQXc/RSxau0wUvr4MDTQ/kGj9rOVY84sq+dCVKcmZj7/H2tqlPXvtILw6s9dwdKTM8RTM/AxxCY+loAnr3qqFK7PMpalwc/ceT2OUOFK6G3rYRSI4SBrlkAP5aQ2/SP27ob8yUEw33apsGi4sevxJ1J1wQ== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}

