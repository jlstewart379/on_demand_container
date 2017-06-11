# on_demand_container
On demand docker container in aws

Usage
1. Clone
2. In root add terraform.tvfars file
3. In tfvars file add a line `bucket_name=<your_bucket_name>`and `region=<desired_region>`
4. From root run `terraform plan -out terraform.plan` and then `terraform apply terraform.plan`
5. In codebuild console or with cli start the `on_demand_container` build
6. On completion, navigate to your s3 bucket and view the produced artifact
