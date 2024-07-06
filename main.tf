terraform {
  required_providers {
    github = {
      source = "hashicorp/github"
      version = "4.19.2"
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
  count       = length(data.github_repository.existing_repo) == 0 ? 1 : 0
  name        = "github-terraform-task-tr23malyarchuk"
  description = "Repository configured by Terraform"
  visibility  = "public"
}

data "github_repository" "existing_repo" {
  full_name = "tr23malyarchuk/github-terraform-task-tr23malyarchuk"
}

resource "github_branch" "develop" {
  count       = length(data.github_repository.existing_repo) == 0 ? 1 : 0
  repository  = github_repository.repo[0].name
  branch      = "develop"
}

resource "github_repository_collaborator" "softservedata" {
  count       = length(data.github_repository.existing_repo) == 0 ? 1 : 0
  repository  = github_repository.repo[0].name
  username    = "softservedata"
  permission  = "push"
}

resource "github_branch_protection" "main" {
  count         = length(data.github_repository.existing_repo) == 0 ? 1 : 0
  repository_id = github_repository.repo[0].id
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
  count         = length(data.github_repository.existing_repo) == 0 ? 1 : 0
  repository_id = github_repository.repo[0].id
  pattern       = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews       = true
    required_approving_review_count = 2
  }
}

resource "github_repository_file" "pull_request_template" {
  count       = length(data.github_repository.existing_repo) == 0 ? 1 : 0
  repository  = github_repository.repo[0].name
  file        = ".github/pull_request_template.md"
  content     = <<-EOF
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
  count       = length(data.github_repository.existing_repo) == 0 ? 1 : 0
  repository  = github_repository.repo[0].name
  title       = "DEPLOY_KEY"
  key         = var.deploy_key_public_key
  read_only   = false
}

resource "github_actions_secret" "pat" {
  count           = length(data.github_repository.existing_repo) == 0 ? 1 : 0
  repository      = github_repository.repo[0].name
  secret_name     = "PAT"
  plaintext_value = var.github_pat_token
}

variable "deploy_key_public_key" {
  description = "Deploy Key Public Key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsS2XMSYK4L2Ml6U6lgg0ji2uRg5U1wKwid0XuaS8+M2yREPkBW4pIfwuh1kQfYrCEy6jbq3Tu3WPcK/lilBddZpUw/WB477Dywb1yeEW3MC4QRK44xy3e9wFXAsfuHuH0W49TUZ3GG5IdJJXSgKlg6CM8g46wUXWUja02sqjrbZSRenKL4K010TiPAFo/JuJ9rZqu9SzhqtXp0qycxOJ/tTwzVQY9qWJqYRRDjIOngfbVTd+sFulxisgJwmZE/h+aJLXUZrJq/7xmRGdEwD7xw7y/Ow6SeY3XRN97K66CyRno3VICBl85oBYZXwG99FAS/+5Iu1TJ3/+LCOkksRf4i2Ku9GYuTphnKQNnuMg9wDPPbCrWqlIIFVHO3iITrq+1WwOjzU+7FZ1S+jbPuUNTMbhvJWqsXmCAf6pYxLmJC4F5z54kVWwrNYQuG/iLJaSVQo1qz2gswlH0+DiasDQAvoXQ7FXB8f9nzMUx+LIvM97VOasp3Ffon0KznQj5r4wOzo66L6eH3pB2wFH9bmloE0kmliLBxku8vLXIJU6tQI68A6lEca8quK8lcwpUwz32ZrNWJ1kpVIWdPzYicAuUA+XFx9z5sYuWOQVB6UUPVArljaBh2RhA/ZKwbB1rApmxFZJGSpC4b2DHLL4qYTkIzBCCzWI9TmFnpwaW1QxiIQ== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}

