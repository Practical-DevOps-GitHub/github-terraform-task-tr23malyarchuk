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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpLJWeAjiwbSB39XdWlLcFGQy095FGDabnIwtWUdCXAstb33BXhwfKhOZCED3aLuGGbtt9PaWPqNtjsBc1Ky+XmRGGYqnmwo4N5u+9FpXuONonvhTfCiXA+//wW882T4FYRGL1euBeYSpdR8rAEVxRYOB26w+O3JpnbkRnpITKuPwaxeob+Udf5HRwwQOVEhjA70mCUTigH9sSSG18Ty6xy+DwU70Ugsw9JzvkeuSncHUXp+94cA1y524e3PoaosUZ2Xmher28DnogFO6xjmecIcOindmrKaosgaTnv76mVawlAHbikHp+AFm7mOhSvhYJCb3q1BKrTE8gH0pxXulvZ6z4us3gaL3x5KEwp3WMaDYLSx4DdR0oGapFqzpjgfr3YTB7PM7ow/KScskKuNmzAb3ekPuDtRLuTFYwi1a3uLbBllPlJ7cZiBZ0jpAUzuXfzm75X39fxj/66INJC3R0U5U1AXpR0yXec0SgD/KmvDp6HkYNYnfNMu+S0jEAvEJ8K4p3So52x6J38yl98XlX0fcz0iXn+O2ZFMyLFG48Czb54CbnPpHv/cwsddRHlVDNUurzK+fumCR99OELo2qvNXCmpz8e1+u3uhwJOYP///VqDXIPvfkRlb6qQL/YKSsnYGf8ReuH/fSFuUwHxghXxABQ0FDIxOe8Sh78V0MnFQ== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}
