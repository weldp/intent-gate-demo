# Intent gate demo

Companion repo for *Intent Contracts: Giving AI Agents the Missing Context for
Safe Infrastructure Changes* (Chris Wysopal, OWASP Global AppSec USA 2026).

It shows an AI-generated Terraform change that passes Checkov with zero
failures, and an intent gate that blocks it because it crosses a boundary only
this service's contract knows about.

## The story in two commits

| Branch | What it is | Checkov | Intent gate |
| --- | --- | --- | --- |
| `main` | Approved architecture: each account keeps its own access logs; prod alerts go to ops | pass | pass |
| `agent/centralized-logging` | Agent's change: one shared log bucket in the **test** account, alerts to **devs-mail** | pass | **4 blocks** |

The agent's change came from an ordinary request ("centralized access logging,
alerts to the engineering list, production-ready") plus a stale comment in
the repo asking for logs to be "accessible across environments".

## What's here

- `infra/` Terraform for two AWS accounts (provider aliases `aws.prod`, `aws.test`)
- `intent/customer-data-store.yaml` the intent contract
- `policy/intent.rego` ~70 lines of Rego: builds a relationship graph from the
  plan's references, walks everything reachable from the contract's root
  resource, and blocks paths the contract doesn't allow
- `.github/workflows/intent-gate.yml` CI: plan with a read-only role, scanners
  first, then the intent gate
- `scripts/report.py` turns the gate's findings into a semantic change report for the PR
- `gate.sh` the same steps locally, no AWS credentials needed

## Run it

```bash
git checkout main && ./gate.sh                        # passes
git checkout agent/centralized-logging && ./gate.sh   # blocked
```

Use `TF=tofu ./gate.sh` for OpenTofu.

## Notes

- Generic S3 hardening lives in `infra/hardening.tf` so the scanners have
  nothing to complain about. One documented skip: CKV_AWS_144 (cross-region
  replication), single-region by design.
- The policy covers three of the five semantic change classes for this
  service: new egress routes, new egress destinations, and data reaching
  another account. Identity expansion and weakened controls follow the same
  pattern with more edge types.
- The workflow is a reference. Plan roles, account IDs and the conftest
  version need adapting to your environment.
