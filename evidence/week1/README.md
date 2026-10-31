# Week 1 evidence - Purple Team A

Five-node POC on Sebowa, built by Terraform and converged by Ansible from branch `feature/week1-foundation`.
All values below are sanitised: real IPs/IDs are replaced with placeholders such as `<k8s-net>` and `<uuid>`.

## Acceptance ladder (week1/README.md Part H)

| Layer | Evidence | Result |
| --- | --- | --- |
| Git | [raw/01-git.txt](raw/01-git.txt) | feature branch from `dev`; SHA recorded |
| OpenStack auth | token issued during the session | succeeds |
| Quota | [raw/07-openstack-resources.txt](raw/07-openstack-resources.txt) | 28/50 vCPU, 56/100 GB RAM, 1/1 floating IP |
| Terraform | [raw/04-tf-fmt-validate.txt](raw/04-tf-fmt-validate.txt), [raw/03-provider-lock.txt](raw/03-provider-lock.txt) | fmt clean, valid, provider pinned 3.4.0 |
| Terraform drift | [raw/05-tf-drift-check.txt](raw/05-tf-drift-check.txt) | "No changes" |
| Nova/Neutron | [raw/07-openstack-resources.txt](raw/07-openstack-resources.txt), [raw/06-tf-state-list.txt](raw/06-tf-state-list.txt) | 5 hosts, 2 networks, 1 router, matches [architecture.md](architecture.md) |
| Public exposure | [raw/07-openstack-resources.txt](raw/07-openstack-resources.txt) | one floating IP on edge-01; only UDP 51820 inbound |
| SSH | [raw/10-access-dns-firewall.txt](raw/10-access-dns-firewall.txt) | private SSH over WireGuard; public SSH times out |
| Ansible inventory | [raw/08-inventory-graph.txt](raw/08-inventory-graph.txt) | README groups; private hosts under `via_edge` |
| Ansible convergence | [raw/09-convergence-recaps.txt](raw/09-convergence-recaps.txt) | `changed=0`, `failed=0` on all hosts (bootstrap, edge, api-lb) |
| WireGuard | [raw/10-access-dns-firewall.txt](raw/10-access-dns-firewall.txt) | proven before public SSH was removed via Terraform |
| HAProxy | [raw/11-haproxy-validation.txt](raw/11-haproxy-validation.txt) | config valid, active, listening :6443, SELinux enforcing; backend DOWN until Week 2 |
| GitHub | this PR | reviewed and merged into `dev` |

## Design decisions and deviations

- **Image:** Rocky 9 (README "Rocky Linux host convergence").
- **Flavors (best fit):** edge-01 C6.small (6 vCPU/12 GB) - **deviation**, no 4 vCPU/10 GB flavor exists;
  api-lb-01 C2.tiny, k8s-cp-01 C4.small, workers C8.medium (exact).
- **Networks:** management + Kubernetes networks and a WireGuard range, team-chosen (instructor approved),
  avoiding the Week 2 service range `10.96.0.0/12`. Fixed host IPs below `.100`; DHCP `.100-.250`.
- **Access:** temporary bootstrap SSH from one /32, removed through Terraform after WireGuard was proven.
- **DNS:** Pi-hole on edge-01 (Podman Quadlet, image pinned and fully qualified), with a public fallback.

## Known issues and assumptions

- Terraform state is local to the operator's workstation (no object storage on Sebowa); backend decision deferred to Week 6.
- All five instances currently share one hypervisor (single point of failure); anti-affinity not configured.
- Teammates' SSH and WireGuard public keys are added via private `group_vars` and re-running the playbooks.
- `StrictHostKeyChecking=accept-new` is used for private hosts (first contact accepted, changes refused).
- First bootstrap run showed `changed=4` per host; recaps here are from later convergence runs.

## Troubleshooting

See [troubleshooting.md](troubleshooting.md), including the disk-stall incident and the rebuild from Git.
