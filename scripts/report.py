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
for f in fails:
    m = f["metadata"]
    print(f"[BLOCK] {m['class']}")
    print(f"  {m['path']}")
    if m["detail"]:
        print(f"  {m['detail']}")
    print(f"  contract: {m['contract']}")
print("-" * 44)
print(f"owner to approve: {contract['owner']}")
sys.exit(1 if fails else 0)
