package compliance.lib.data_adapter

import future.keywords.in

is_filesystem {
	input.type == "file"
}

filename = file_name {
	is_filesystem
	file_name := input.resource.filename
}

filemode = file_mode {
	is_filesystem
	file_mode := input.resource.mode
}

file_path = path {
	is_filesystem
	path := input.resource.path
}

owner_user_id = uid {
	is_filesystem
	uid := input.resource.uid
}

owner_group_id = gid {
	is_filesystem
	gid := input.resource.gid
}

is_process {
	input.type == "process"
}

process_name = name {
	is_process
	name = input.resource.stat.Name
}

process_args_list = args_list {
	is_process

	# Gets all the process arguments of the current process
	# Expects format as the following: --<key><delimiter><value> for example: --config=a.json
	# Notice that the first argument is always the process path
	args_list := split(input.resource.command, " --")
}

# This method creates a process args object
# The object will contain all the process `flags` and their matching values as object key,value accordingly
process_args(delimiter) = {flag: value | [flag, value] = parse_argument(process_args_list[_], delimiter)}

parse_argument(argument, delimiter) = [flag, value] {
	splitted_argument = split(argument, delimiter)
	flag = concat("", ["--", splitted_argument[0]])

	# We would like to take the entire string after the first delimiter
	value = concat(delimiter, array.slice(splitted_argument, 1, count(splitted_argument) + 1))
}

process_config = config {
	is_process
	config := {key: value | value = input.resource.external_data[key]}
}

is_kube_apiserver {
	process_name == "kube-apiserver"
}

is_kube_controller_manger {
	process_name == "kube-controller-manager"
}

is_kube_scheduler {
	process_name == "kube-scheduler"
}

is_etcd {
	process_name == "etcd"
}

is_kubelet {
	process_name == "kubelet"
}

is_kube_api {
	input.type == "kube-api"
}

is_cluster_roles {
	is_kube_api
	input.resource.kind in {"Role", "ClusterRole"}
}

cluster_roles := roles {
	is_cluster_roles
	roles = input.resource
}

service_account := account {
	input.resource.kind == "ServiceAccount"
	account = input.resource
}

is_kube_node {
	is_kube_api
	input.resource.kind == "Node"
}

pod = p {
	input.resource.kind == "Pod"
	p := input.resource
}

is_service_account_or_pod = pod

is_service_account_or_pod = service_account

containers = c {
	input.resource.kind == "Pod"
	container_types := {"containers", "initContainers"}
	c := pod.spec[container_types[t]]
}
