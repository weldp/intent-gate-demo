#!/usr/bin/env python3
"""Render conftest JSON output as a semantic change report (PR comment / job summary)."""
import json, sys, yaml

results = json.load(open(sys.argv[1]))
contract = yaml.safe_load(open(sys.argv[2]))["contract"]
checkov = sys.argv[3] if len(sys.argv) > 3 else ""
fails = [f for r in results for f in (r.get("failures") or [])]
# conftest nests rule metadata one level down
for f in fails:
    f["metadata"] = f["metadata"].get("metadata", f["metadata"])
order = ["new egress route", "new egress destination", "data reaching another account"]
fails.sort(key=lambda f: (order.index(f["metadata"]["class"]), f["metadata"]["path"]))

status = f"BLOCKED ({len(fails)})" if fails else "PASS"
print(f"INTENT GATE  {contract['service']}  {status}")
if checkov:
    print(f"checkov: {checkov}")
print("-" * 44)
# Group findings of the same class and contract line into one block
groups = {}
for f in fails:
    m = f["metadata"]
    groups.setdefault((m["class"], m["detail"], m["contract"]), []).append(m["path"])
for (cls, detail, contract_line), paths in groups.items():
    print(f"[BLOCK] {cls}")
    if detail.startswith("in account"):
        print(f"  {', '.join(paths)} {detail}")
    else:
        for p in paths:
            print(f"  {p}")
        if detail:
            print(f"  {detail}")
    print(f"  contract: {contract_line}")
print("-" * 44)
print(f"owner to approve: {contract['owner']}")
sys.exit(1 if fails else 0)
