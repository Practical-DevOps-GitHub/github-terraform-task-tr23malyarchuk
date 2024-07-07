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

variable "deploy_key_public_key" {
  description = "Deploy Key Public Key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC00RZs1kEXlIPGt7FFcDtmsu+cPYmJQOzZNhoGNgH7UKX9awwl1TuxflN13PaJkhS6QLjXsCf7MZdfclcBjH93wzkay3KdLFpZ4ZUvxk1jayvgoNUg5LKAnHIbx0IgH27A528PBEto6DZ3fo88r0Epcz1N+H66NhYv1pvDrga4MBxI9pM8l/LBC/pcvzVQ94N3Dw9SSp10fkUCZLnPfO761QGyM1SO2buRy1QA3RpTl6+pncy4LoUXK8pxutLqqe0d8Q7F4K5xfku5gGKJ4T3MOGCKrXC8lt1N+Wkrzv/GPDfSYrtu+hzRt1pn2Wc4XvC4H2FcfMx0obqGjiQSF7l0LzvQcIdVH8hj/lL2pQy4Pnn1ke8JZ1jiv3pCM6hZUgFqOCzPlWffIaqY8JthvU+Y9/Ny7TU7Rxv+Du/jLkTjF3CZ3KaZ5mxP0fEpqVEZTuft93cty7I/AwmZ1gOHjV8Hq+IjfZFYtVk8fGWzwYTMnUwVauJuTPHZA2RYWHseQRKV0rz/6qRt+/n/F2Gp70kmbaV9BwQZUPB9ZD7+kGdtS4IqzsEFNzbgJ1yCJujfffJRgHN4fnaVETPkEzyMn885o8SmCnNrrANFipi6d6+t3fncmgNP+q//hxr9Jo2URb77aPMgvSaAuonG1BzHTRW/5R1/QrJu7QiSJ+d7DUcn/w== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}

