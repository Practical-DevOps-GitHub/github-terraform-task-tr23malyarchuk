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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkg1Zc14MYkzjhi6195OLv+H0+27bByKN1S2/OAW0X1v8yRyvn+xBqmQgCwVqsYxQBmQoDjqRDM+t5fQXhi0YId4+lirh4hP37PlfAHxE6I/qX0WOZxh6IrtxfKlMkhCmLT9fepEaYZulshCt/B/ChtbmNak8A0K4dxhbXp5VUsL4w7gLhJM7QSrBtEFXkqP6gZy8MfjUtnLz4c5y1le1s/hv/0rU8th9kNNdQ8Xh6qkOiB5FeIDXx4nNiW5jTIoRUnjXjn6RPHKiUZKVujR5HYd2mVHL5EVbQd6LMbiefb1e/H6pV24QyKGeAZW1FljmKjlNQvrtZepgkOr92sBgWKP6HClwlObUSocidl/ntXVWm4ImSflzeLpS/BojVLgUGpYkNybbUBU6cFoONs8Qdx48dicfLFaGfRkeT98OBx1qDqS3N5aOSUb15fJeoS2r3LmUe8iwXrp6lekJjcOnmJfvrOEoenzECG2fbAAFzS4dA1Da9UdSrMhctd/Zvh6YR+xPfmRbiStZueJVTfQiFjQUKBHTUe7h1uFeIkzMYpjpAUEFh20pOSL7MyNY4OGU4vplL3J3sxY04QNCZ2JfwAEmPVz9VYjLIBbDVMqGacDltLc5vpGCvh8T6VC/k0SohBtN82cBjz0hrA77EUGhk02wUr+M1f8YFV8k0/4XF/w== malyarchuk.bogdan@lll.kpi.ua"
}

variable "discord_team_id" {
  description = "Discord Team ID"
  type        = string
  default     = "1254029963192041587"
}
