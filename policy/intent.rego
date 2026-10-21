# Intent gate: compare a Terraform/OpenTofu plan (`show -json`) against an
# intent contract. Builds a relationship graph from plan references, walks
# everything reachable from the contract's root resource, and blocks any
# path the contract does not allow.
package main

import rego.v1

contract := data.contract

resources := input.configuration.root_module.resources

addr(r) := sprintf("%s.%s", [r.type, r.name])

# First resource address an expression refers to (e.g. aws_s3_bucket.x)
ref(expr) := [x | some x in expr.references; count(split(x, ".")) == 2][0]

account(a) := contract.accounts[r.provider_config_key] if {
	some r in resources
	addr(r) == a
}

# ---- Relationship graph: [from, to, edge type] ----
edges contains [ref(r.expressions.bucket), ref(r.expressions.target_bucket), "logsTo"] if {
	some r in resources
	r.type == "aws_s3_bucket_logging"
}

edges contains [ref(r.expressions.bucket), ref(t.topic_arn), "sendsNotification"] if {
	some r in resources
	r.type == "aws_s3_bucket_notification"
	some t in r.expressions.topic
}

edges contains [ref(r.expressions.topic_arn), r.expressions.endpoint.constant_value, "deliversTo"] if {
	some r in resources
	r.type == "aws_sns_topic_subscription"
}

nodes contains e[i] if {
	some e in edges
	some i in [0, 1]
}

adjacency[n] := {e[1] | some e in edges; e[0] == n} if some n in nodes

reachable := graph.reachable(adjacency, {contract.root})

# ---- Semantic change classes ----
deny contains msg if {
	some [from, to, "logsTo"] in edges
	from in reachable
	not to in contract.egress.logs_to
	msg := sprintf("BLOCK new egress route: %s -logsTo-> %s (account: %s). Contract allows logs_to %v", [from, to, account(to), contract.egress.logs_to])
}

deny contains msg if {
	some [from, to, "deliversTo"] in edges
	from in reachable
	not to in contract.egress.notify
	msg := sprintf("BLOCK new egress destination: %s -deliversTo-> %s. Contract allows notify %v", [from, to, contract.egress.notify])
}

deny contains msg if {
	some n in reachable
	acct := account(n)
	acct != contract.placement.account
	msg := sprintf("BLOCK data reaches another account: %s is in account %s, contract placement is %s", [n, acct, contract.placement.account])
}
