# Warning
Recently, November, 2020, [Official Docker](https://docs.docker.com/cloud/ecs-integration/) just announced the official ecs integration with docker compose which I think it has better implementation than the terraform-from-scratch approach like this repo. 

## Infrastructure as Code

- Fargate
- PostgreSQL
- Redis
- AWS Lambda and CloudWatch Event

## Setup Terraform Backend

On your local machine, run terraform init, passing in the following options, replacing `<YOUR-STATE-NAME>`, `<YOUR-PROJECT-ID>`, `<YOUR-USERNAME>` and `<YOUR-ACCESS-TOKEN>` with the relevant values. This command initializes your Terraform state, and stores that state within your GitLab project. The name of your state can contain only uppercase and lowercase letters, decimal digits, hyphens, and underscores.:

_[Source](https://docs.gitlab.com/ee/user/infrastructure/terraform_state.html)_

```
terraform init \
    -backend-config="address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>" \
    -backend-config="lock_address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>/lock" \
    -backend-config="unlock_address=https://gitlab.com/api/v4/projects/<YOUR-PROJECT-ID>/terraform/state/<YOUR-STATE-NAME>/lock" \
    -backend-config="username=<YOUR-USERNAME>" \
    -backend-config="password=<YOUR-ACCESS-TOKEN>" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"
```

You can now run `terraform plan` and `terraform apply` as you normally would.
