package compliance.cis_k8s.rules.cis_1_2_15

import data.compliance.cis_k8s
import data.compliance.lib.common
import data.compliance.lib.data_adapter

# Ensure that the admission control plugin PodSecurityPolicy is set (Automated)
finding = result {
	# filter
	data_adapter.is_kube_apiserver

	# evaluate
	process_args := cis_k8s.data_adapter.process_args
	rule_evaluation := common.arg_values_contains(process_args, "--enable-admission-plugins", "PodSecurityPolicy")

	# set result
	result := {
		"evaluation": common.calculate_result(rule_evaluation),
		"evidence": {"process_args": process_args},
	}
}
