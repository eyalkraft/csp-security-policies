package compliance.cis_eks.rules.cis_5_4_1

import data.compliance.cis_eks
import data.compliance.cis_eks.data_adapter
import data.compliance.lib.common

default rule_evaluation = false

# Verify that private access is enabled
# Verify that public access is enabled
# Restrict the public access to the cluster's control plane to only an allowlist of authorized IPs.
rule_evaluation {
	input.resource.Cluster.ResourcesVpcConfig.EndpointPrivateAccess
	public_access_is_restricted
}

public_access_is_restricted {
	not input.resource.Cluster.ResourcesVpcConfig.EndpointPublicAccess
}

public_access_is_restricted {
	input.resource.Cluster.ResourcesVpcConfig.EndpointPublicAccess
	public_access_cidrs := input.resource.Cluster.ResourcesVpcConfig.PublicAccessCidrs

	# Ensure that publicAccessCidr has a valid filter
	allow_all_filter := "0.0.0.0/0"
	invalid_filters := [index | public_access_cidrs[index] == allow_all_filter]
	count(invalid_filters) == 0
}

# Ensure there Kuberenetes endpoint private access is enabled
finding = result {
	# filter
	data_adapter.is_aws_eks

	# set result
	result := {
		"evaluation": common.calculate_result(rule_evaluation),
		"evidence": {
			"endpoint_public_access": input.resource.Cluster.ResourcesVpcConfig.EndpointPublicAccess,
			"endpoint_private_access": input.resource.Cluster.ResourcesVpcConfig.EndpointPrivateAccess,
			"public_access_cidrs": input.resource.Cluster.ResourcesVpcConfig.PublicAccessCidrs,
		},
	}
}

metadata = {
	"name": "Restrict Access to the Control Plane Endpoint",
	"description": "Enable Endpoint Private Access to restrict access to the cluster's control plane to only an allowlist of authorized IPs.",
	"rationale": `Authorized networks are a way of specifying a restricted range of IP addresses that are permitted to access your cluster's control plane.
Kubernetes Engine uses both Transport Layer Security (TLS) and authentication to provide secure access to your cluster's control plane from the public internet.
This provides you the flexibility to administer your cluster from anywhere; however, you might want to further restrict access to a set of IP addresses that you control.
You can set this restriction by specifying an authorized network.
Restricting access to an authorized network can provide additional security benefits for your container cluster, including:
• Better protection from outsider attacks: Authorized networks provide an additiofnal layer of security by limiting external access to a specific set of addresses you designate, such as those that originate from your premises.
  This helps protect access to your cluster in the case of a vulnerability in the cluster's authentication or authorization mechanism.
• Better protection from insider attacks: Authorized networks help protect your fcluster from accidental leaks of master certificates from your company's premises.
Leaked certificates used from outside Amazon EC2 and outside the authorized IP  ranges (for example, from addresses outside your company) are still denied access.`,
	"impact": `When implementing Endpoint Private Access, be careful to ensure all desired networks are on the allowlist (whitelist) to prevent inadvertently blocking external access to your cluster's control plane.`,
	"tags": array.concat(cis_eks.default_tags, ["CIS 5.4.1", "Cluster Networking"]),
	"default_value": "By default, Endpoint Private Access is disabled.",
	"benchmark": cis_eks.benchmark_metadata,
	"remediation": `Complete the following steps using the AWS CLI version 1.18.10 or later.
You can check your current version with aws --version. To install or upgrade the AWS CLI, see Installing the AWS CLI.
Update your cluster API server endpoint access with the following AWS CLI command.
Substitute your cluster name and desired endpoint access values.
If you set endpointPublicAccess=true, then you can (optionally) enter single CIDR block, or a comma-separated list of CIDR blocks for publicAccessCidrs.
The blocks cannot include reserved addresses.
If you specify CIDR blocks, then the public API server endpoint will only receive requests from the listed blocks.
There is a maximum number of CIDR blocks that you can specify.
For more information, see Amazon EKS Service Quotas.
If you restrict access to your public endpoint using CIDR blocks, it is recommended that you also enable private endpoint access so that worker nodes and Fargate pods (if you use them) can communicate with the cluster.
Without the private endpoint enabled, your public access endpoint CIDR sources must include the egress sources from your VPC.
For example, if you have a worker node in a private subnet that communicates to the internet through a NAT Gateway, you will need to add the outbound IP address of the NAT gateway as part of a whitelisted CIDR block on your public endpoint.
If you specify no CIDR blocks, then the public API server endpoint receives requests from all (0.0.0.0/0) IP addresses.
Note The following command enables private access and public access from a single IP address for the API server endpoint.
Replace 203.0.113.5/32 with a single CIDR block, or a comma- separated list of CIDR blocks that you want to restrict network access to.
Example command:
aws eks update-cluster-config --region region-code --name dev --resources-vpc-config endpointPublicAccess=true publicAccessCidrs="203.0.113.5/32" gitendpointPrivateAccess=true`,
}
