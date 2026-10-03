# Week 5 — Controlled Security Exercise, Detection & Forensics

This week turns the common platform into an **authorised evidence-driven security range**. The instructor supplies the secret scenario and role assignment. `Purple Team A` is not permanently labelled attacker or defender; both Purple teams must be capable of both roles.

## Safety and scope

- Operate only inside the explicitly authorised team/peer ranges and scenario.
- Do not probe production, public targets, other student projects or infrastructure outside the brief.
- Keep Hermes read/report-only for the core exercise.
- Do not develop destructive payloads or uncontrolled persistence.

## Execution order

```text
1. Receive/acknowledge secret Rules of Engagement
2. Freeze the accepted Week-4 Git SHA/image set
3. Verify time synchronisation across evidence sources
4. Capture a 10–15 minute normal telemetry baseline
5. Create run/scenario manifest and note UTC start time
6. Execute only the approved scenario
7. Defender records first observable/detection timestamps
8. Export/retain bounded Wazuh + Suricata + Prometheus evidence
9. Build a single incident timeline
10. Ask ACP/Hermes to explain curated evidence
11. Human review/correct the explanation
12. Record detection gaps/false positives/false negatives
13. Reset/replay
14. Swap roles for the instructor-approved second phase
```

## Baseline checks

```bash
# RUN ON: edge-01
sudo /var/ossec/bin/agent_control -l
sudo systemctl is-active suricata
sudo tail -n 5 /var/log/suricata/eve.json
```

```bash
# RUN ON: k8s-cp-01
kubectl -n monitoring get pods
kubectl -n wazuh get pods
kubectl -n agent-control-plane get pods
```

All evidence sources must agree on UTC/clock synchronization closely enough for a defensible timeline.

## Scenario manifest

Create `project/runs/<run-id>/manifest.yaml` before executing the exercise. Record:

- scenario ID supplied by instructor;
- team role for this phase;
- Git SHA and relevant image digests;
- authorised source/target logical names;
- UTC start/end;
- expected evidence layers (host/network/application);
- actual evidence references;
- detection timestamps and analyst timestamps.

Never publish secret scenario instructions until the instructor authorises disclosure.

## Detection metrics

Where meaningful calculate:

```text
T_detect   = first defender detection - scenario start
T_identify = correct interpretation - first detection
T_contain  = containment action/decision - identification (only if exercised)
T_recover  = restored service - containment/start of recovery
```

Also report false positives, false negatives and evidence gaps. Faster is not automatically better if classification is wrong.

## ACP/Hermes use

Supply **curated evidence**, not raw unrestricted shell/Kubernetes access. Ask Hermes to:

- summarize the timeline;
- explain relationships between host/network/platform evidence;
- identify uncertainty/missing data;
- cite/reference the evidence IDs supplied by the control plane.

A human analyst must review every material conclusion and record corrections.

## Required Week-5 deliverable

At minimum:

- one reproducible authorised scenario per role phase;
- incident timeline combining Wazuh + Suricata + operational context;
- at least one tested detection/rule/query per scenario;
- detection/response metrics and limitations;
- ACP task/evidence/result IDs;
- a reset/replay procedure;
- figures/tables suitable for the paper/poster.

## Exit gate

Another authorised student/mentor should be able to replay the scenario from the runbook and reconstruct what happened without relying on your verbal explanation.
