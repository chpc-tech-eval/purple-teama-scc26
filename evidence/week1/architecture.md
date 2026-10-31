# Week 1 architecture and trust path

```mermaid
flowchart TB
    WS["Team workstations<br/>(Terraform, Ansible, WireGuard client)"] -->|"WireGuard UDP 51820"| FIP
    FIP(("1 floating IP<br/>(only public exposure)")) --> EDGE
    EXT["Public Internet<br/>(provider network)"] --- R

    subgraph MGMT["Management network - &lt;mgmt-net&gt;.0/24"]
        EDGE["edge-01 (.10) - C6.small<br/>WireGuard, Pi-hole (Podman), nftables"]
    end

    R{"purple-teama-router<br/>static route &lt;vpn-net&gt;.0/24 -> edge-01"}
    MGMT --- R
    R --- K8S

    subgraph K8S["Kubernetes network - &lt;k8s-net&gt;.0/24"]
        LB["api-lb-01 (.10) - C2.tiny<br/>HAProxy :6443"]
        CP["k8s-cp-01 (.11) - C4.small"]
        W1["k8s-worker-01 (.21) - C8.medium"]
        W2["k8s-worker-02 (.22) - C8.medium"]
    end
    LB -->|"TCP 6443 (backend DOWN until Week 2)"| CP
```

| Layer | Allowed in | Owner |
| --- | --- | --- |
| Security group `purple-teama-edge` | UDP 51820 only (temporary SSH /32 removed at step 22) | Terraform |
| Security group `purple-teama-internal` | all traffic from the three team ranges | Terraform |
| edge-01 nftables (`inet edge_filter`) | WireGuard; SSH from team ranges; DNS/Pi-hole UI to the container from team ranges; VPN forwarding to team networks | Ansible `firewall` role |
| DNS | subnets hand out Pi-hole (edge-01) then a public fallback | Terraform (subnet) + Ansible (`common` role) |
