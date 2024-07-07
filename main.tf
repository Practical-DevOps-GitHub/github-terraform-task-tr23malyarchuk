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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9mFfdWh+grIl+gzTyNaJhxJfcy5uZgvxoZivwk97Ef1QH9GrwvcDt9domon2iOy05CXGvBbSCxX5Lup6aengsFVpRY/KE3TV5NjInc8XIYp43xUow7J1YOxBWRfHTwZkeKAAWvIL6jVRbGqgck27CXDZdX5bDSw8jggE0eHu5bNJFmRp9DLe2a9CbifuoPVKNJzZIUZOOSyeEzFOKhYTeAuFZpWRjxoSUSEGwJ6XhSfThOst8uRtvAphoT/t95V5UGwvHcDrNSzYTnDxK4vMAi69t786snFG8QDzwH24d9u5g+cWoqBkJ25PIZaIyQUgoqhT4fiRrCmnzpt1sCL0aJ+YQFMH4cCxcKsck0cnnqgIw9aQjGiZXMWNmGyhIeOI6g5ERR8aKq5OKbfd2itWwL40mgAjmFhcBtT6qB83sR5xdmX8m4e+UL8+XfdieGVdRWYEckINFxQ4mpOfPBP1FAn9pI0WgxkDp0skzXGkn6nE4i+l1OjFvUkRU/hccd87zqutxxqK+CELVz1VddCWRC0wawtJHAZHILmvkyIgCZNddjpwl2YdNiIAMHUbtkOgzrawQpINXMTX73LYI91GNYDQROAHPHS7r23kB4xj+nF3Q+4hstP0aOPvdOop1meW3/AR/vHYIitgtu9CFCz0yGpR4y0pcYE6DSTbiXdCfsw== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}
