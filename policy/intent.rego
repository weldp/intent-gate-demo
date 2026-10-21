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
# Each finding carries metadata so CI can render a semantic change report.
short(a) := split(a, ".")[1]

deny contains {"msg": msg, "metadata": m} if {
	some [from, to, "logsTo"] in edges
	from in reachable
	not to in contract.egress.logs_to
	m := {"class": "new egress route", "path": sprintf("%s -logsTo-> %s", [short(from), short(to)]), "detail": sprintf("%s is in account: %s", [short(to), account(to)]), "contract": sprintf("logs_to = %s", [concat(", ", [short(x) | some x in contract.egress.logs_to])])}
	msg := sprintf("BLOCK %s: %s (%s). Contract: %s", [m.class, m.path, m.detail, m.contract])
}

deny contains {"msg": msg, "metadata": m} if {
	some [from, to, "deliversTo"] in edges
	from in reachable
	not to in contract.egress.notify
	m := {"class": "new egress destination", "path": sprintf("%s -deliversTo-> %s", [short(from), to]), "detail": "", "contract": sprintf("notify = %s", [concat(", ", contract.egress.notify)])}
	msg := sprintf("BLOCK %s: %s. Contract: %s", [m.class, m.path, m.contract])
}

deny contains {"msg": msg, "metadata": m} if {
	some n in reachable
	acct := account(n)
	acct != contract.placement.account
	m := {"class": "data reaching another account", "path": short(n), "detail": sprintf("in account: %s", [acct]), "contract": sprintf("placement = %s", [contract.placement.account])}
	msg := sprintf("BLOCK %s: %s (%s). Contract: %s", [m.class, m.path, m.detail, m.contract])
}
