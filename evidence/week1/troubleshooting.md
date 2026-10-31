# Week 1 troubleshooting notes

## 1. Intermittent disk stalls on the original cloud (platform fault)

- **Symptom:** Ansible runs hung at random; plain SSH and sudo were fast (~0.45 s).
- **Diagnosis (outside in):** load average ~7 with CPU ~98% idle -> processes stuck in D state
  (xfsaild, xfs-cil, auditd, journald) -> kernel "task blocked for more than 245 seconds" ->
  a clean reboot did not help (stall returned within 4 minutes) -> every affected VM shared one
  hypervisor hostId; VMs on the other hypervisor were healthy.
- **Commands:** `uptime`, `cat /sys/block/vda/inflight`, `ps -eo state,pid,etime,cmd | awk '$1 ~ /D/'`,
  `dmesg -T | grep 'blocked for more than'`, `openstack server show <vm> -c hostId`.
- **Outcome:** reported to the instructor with evidence. The original environment was later lost in a
  platform incident; the stack was **rebuilt from Git on the new cloud** with only the private
  tfvars changed (new image/flavor IDs) - 27 resources, then `changed=0` on every playbook.
- **Lesson:** `ACTIVE` and a working ping prove nothing about disk health; measure each layer.

## 2. Subnet DNS change did not reach the VMs

- **Symptom:** after Terraform pointed the subnets at Pi-hole and the hosts were rebooted,
  `/etc/resolv.conf` still listed the public resolvers.
- **Cause:** cloud-init writes `resolv.conf` once at first boot and sets NetworkManager `dns = none`,
  so DNS received via DHCP is ignored.
- **Fix:** the `common` role adds a NetworkManager drop-in (`dns=default`) that sorts after
  cloud-init's file. Terraform remains the single source of truth for which DNS servers are used.

## 3. Pi-hole role reported `changed` on every run

- **Cause:** the role forced the data directory to `root:root`, while the container runs as UID 1000
  and re-owns it at start - the two kept fighting (and Pi-hole could not create new files).
- **Fix:** create the directory without forcing its owner. Second run: `changed=0`.

## 4. `hashicorp/openstack` provider not found

- **Cause:** child modules need their own `required_providers` block; the root module's does not carry over.
- **Fix:** a `versions.tf` in each module naming `terraform-provider-openstack/openstack`.

## 5. HAProxy "Broadcast message" noise during Ansible runs

- **Cause:** with no backend yet, HAProxy logs at emergency level; rsyslog broadcasts emergencies to all terminals.
- **Fix:** `log /dev/log local0 info notice` caps severity at `notice`. Backend DOWN is expected until Week 2.
