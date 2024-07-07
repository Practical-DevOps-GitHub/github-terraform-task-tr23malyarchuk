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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCk4VEcvN/jz67Ps9q/C8B3RF9GCwUI3+yFek1n8urmHqlqsrnMylW1sr2SRFW/Wl2PNXlsrPiNIvkBBX0jh3uKlvRIwFDnz2dBartL/hraUPytUGYPwrvTAVmcvbNFUoQadgSGdX0fKG50vY1/EZBcVTenmJzz1rpkXubEaCfyS2YFvNDwh8LkN3vVZB6RrgFhyQaXcR4JhTivR6TapYo162YkNg8ZD45jhD81VkPUf0GjRtyiOjYBHYG/tjpfd3i/eVxAgyTW3AeaGLx0ETBIVmWUJ00GPsJ60X2XeG80dGiUVTRCAYVvyP4VKDFOxQJcbDmbSzWzZ861zoa3nn2QTofVCurTnlMs+k/Dukg1kGU/5Www3FMF2BD2c8IESp30j8rTa8japmtxST0Ig9hQWM6O4QR5azzCNwJPyK1Cyy430x7OU/+sVh/4+2xUaQRf9A7jgiJXlcKUYpp9y+7Lb7z8wc6sok51kvPfSAD2sLNrzRIOW3lHFry5d8rOtaVOLpVowkmb8nv1491Clf0h/ECnrFUJMOInDnzcIsGMdklgecAFboXMizJu8D7k5WYDCwyA+v+5upULuXfiiU7c0F2F35P0Z21Vy/dNeF8wlyBhd31McQ4C8kFosK/boD6ylWR4zoDE2k4EUtjz55uMrmsFrDdvdcGdQDXF82oNiw== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}
