# Terraform environment - Week 1 POC

Creates the five-node topology: management + Kubernetes networks, router (with VPN return route),
security groups, five fixed-IP instances and one floating IP for edge-01.

## Prerequisites (each team member)

- Terraform >= 1.9 and your own OpenStack application credential in `~/.config/openstack/clouds.yaml` (never in Git).
- `cp terraform.tfvars.example terraform.tfvars` and fill in the real values (shared privately within the team).

## Workflow

```bash
terraform init
terraform fmt -recursive .. && terraform validate
terraform plan -out=tfplan        # review with a teammate before applying
terraform apply tfplan
terraform plan                    # expect "No changes"
terraform output                  # edge floating IP + private IPs for the Ansible inventory
```

## Bootstrap SSH

Set `bootstrap_ssh_cidrs = ["<your-ip>/32"]` only while building, before WireGuard exists.
Once private access over WireGuard is proven, set it to `[]` and apply (week1 README step 22).

## Never commit

`terraform.tfvars`, `terraform.tfstate*`, `tfplan`, `.terraform/` (all covered by `.gitignore`).
