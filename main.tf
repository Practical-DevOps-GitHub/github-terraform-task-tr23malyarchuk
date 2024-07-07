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
  branch         = "main"
}

variable "deploy_key_public_key" {
  description = "Deploy Key Public Key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw2CwBPsGNuW4nsrm/9Ze1vkxY7L+jdfHnCykltAnBNy09yYSX9L0+DjYWmxwcm5Dgu8q8gMHC05SUYhvCKCMMjai34Wrd7wtRAamXnZ0cXQFArVuQe9bEZcH/dukEm2cwHxb7kcf2x7JE3hGg/wwOtcuSMhHtmWq5p8xHXrsUUfJ20UFW+f7OeCWSbBeRFfUR/QHkVk9TSbrUX+4N0sWAhatQRNDQ4HoAfkC6Zip9Dmmm35sR7CWaz3oqIWrOxVCNszP1SxViRfs4CyFCMzZuDcafWPLm5KiJ4L26ClqCNIoociKUMZXwgUCoQiscLUe25gZWTu2kbTJ1BKC9Y82nVtDqpB0E6VdrbkCEIbP4c/uiFLYDDrqlrk3+bdAoMUy9Ph4oqUYELc0E69jpWRFOxhwkKFknQ3X7i2qnSBQV0GTsgRIAD0hQ4ESgHJoTCrrWfsGJLJGAdpUgQrnCHz66JS3H7ewoDEqBFyCqb/Bzy8tdxwv91MCjRb8a41ZVi9/ONUP1XE2Xje0a+2Mrfi4tLPTPV3xzQbl9GijaH+JBMZ2iLpeCHRYyPi1fvEOQDcDebr+P3nBLYKNraawxwMgmKDvbYR2cCq89j6HXNJ8u9jnXfUJcvbISNPfI21GX8vjW+Sb9ye2n0mMUTJgcICqE2B2+gMjm58Yk4f0J7TD4pQ== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}
