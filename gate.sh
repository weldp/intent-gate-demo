#!/usr/bin/env bash
# Run the same steps as CI, offline (no AWS credentials needed).
# Requires: terraform or tofu, checkov, conftest.
set -uo pipefail
TF=${TF:-terraform}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-demo} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-demo} AWS_EC2_METADATA_DISABLED=true
mkdir -p out
( cd infra && $TF init -input=false >/dev/null &&
  $TF plan -input=false -refresh=false -var offline_demo=true -out=../out/tfplan >/dev/null &&
  $TF show -json ../out/tfplan > ../out/plan.json ) || exit 2

echo "== Existing scanners (Checkov) =="
checkov -f out/plan.json --framework terraform_plan --skip-check CKV_AWS_144 --compact --quiet --skip-download | grep -E "Passed checks|FAILED"

echo
echo "== Intent gate (conftest) =="
conftest test out/plan.json --policy policy --data intent
