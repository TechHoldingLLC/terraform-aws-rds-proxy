## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_proxy.rds_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy) | resource |
| [aws_db_proxy_default_target_group.connection_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_default_target_group) | resource |
| [aws_db_proxy_endpoint.custom_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_endpoint) | resource |
| [aws_db_proxy_target.db_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target) | resource |
| [aws_db_proxy_target.db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target) | resource |
| [aws_iam_role.rds_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.proxy_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.proxy_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Identifier for the RDS Proxy. Must be unique per region. | `string` | n/a | yes |
| <a name="input_engine_family"></a> [engine\_family](#input\_engine\_family) | Engine family the proxy supports. Valid values: `MYSQL`, `POSTGRESQL`, `SQLSERVER`. | `string` | n/a | yes |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | List of VPC subnet IDs to associate with the proxy. | `list(string)` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of VPC security group IDs to associate with the proxy. | `list(string)` | n/a | yes |
| <a name="input_auth"></a> [auth](#input\_auth) | Map of auth entries for the proxy. Each entry supports: `auth_scheme`, `secret_arn`, `iam_auth` (optional), `username` (optional), `description` (optional). | <pre>map(object({<br/>  auth_scheme = string<br/>  secret_arn  = string<br/>  iam_auth    = optional(string, "DISABLED")<br/>  username    = optional(string, null)<br/>  description = optional(string, null)<br/>}))</pre> | n/a | yes |
| <a name="input_db_instance_identifier"></a> [db\_instance\_identifier](#input\_db\_instance\_identifier) | Identifier of the RDS DB instance to register as the proxy target. Mutually exclusive with `db_cluster_identifier`. | `string` | `null` | no |
| <a name="input_db_cluster_identifier"></a> [db\_cluster\_identifier](#input\_db\_cluster\_identifier) | Identifier of the Aurora DB cluster to register as the proxy target. Mutually exclusive with `db_instance_identifier`. | `string` | `null` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | ARN of an existing IAM role for the proxy. When set, the module does not create an IAM role or policy. | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name for the IAM role created by the module. Defaults to `<name>-rds-proxy-role`. Ignored when `iam_role_arn` is set. | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path for the IAM role created by the module. Ignored when `iam_role_arn` is set. | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the IAM policy to use as a permissions boundary for the created role. Ignored when `iam_role_arn` is set. | `string` | `null` | no |
| <a name="input_iam_policy_name"></a> [iam\_policy\_name](#input\_iam\_policy\_name) | Name for the inline IAM policy attached to the created role. Defaults to `<name>-rds-proxy-policy`. Ignored when `iam_role_arn` is set. | `string` | `null` | no |
| <a name="input_kms_key_arns"></a> [kms\_key\_arns](#input\_kms\_key\_arns) | List of KMS key ARNs the proxy IAM role may use for decrypting Secrets Manager secrets. Ignored when `iam_role_arn` is set. | `list(string)` | `[]` | no |
| <a name="input_debug_logging"></a> [debug\_logging](#input\_debug\_logging) | Whether the proxy includes detailed information about SQL statements in its logs. | `bool` | `false` | no |
| <a name="input_idle_client_timeout"></a> [idle\_client\_timeout](#input\_idle\_client\_timeout) | Number of seconds a client connection can remain idle before the proxy closes it. Range: 1–28800. | `number` | `1800` | no |
| <a name="input_require_tls"></a> [require\_tls](#input\_require\_tls) | Whether TLS encryption is required for connections to the proxy. | `bool` | `true` | no |
| <a name="input_max_connections_percent"></a> [max\_connections\_percent](#input\_max\_connections\_percent) | Maximum size of the connection pool as a percentage of `max_connections` for the RDS DB instance. Range: 1–100. | `number` | `100` | no |
| <a name="input_max_idle_connections_percent"></a> [max\_idle\_connections\_percent](#input\_max\_idle\_connections\_percent) | Controls how actively the proxy closes idle database connections in the connection pool. Range: 0–100. | `number` | `50` | no |
| <a name="input_connection_borrow_timeout"></a> [connection\_borrow\_timeout](#input\_connection\_borrow\_timeout) | Number of seconds the proxy waits for a connection from the pool before returning a timeout error. Range: 1–3600. | `number` | `120` | no |
| <a name="input_init_query"></a> [init\_query](#input\_init\_query) | One or more SQL statements for the proxy to run when opening each new DB connection. Typically used for SET statements. | `string` | `null` | no |
| <a name="input_session_pinning_filters"></a> [session\_pinning\_filters](#input\_session\_pinning\_filters) | List of conditions that cause the proxy to pin a session to a specific DB connection. Supported value: `EXCLUDE_VARIABLE_SETS`. | `list(string)` | `[]` | no |
| <a name="input_create_endpoint"></a> [create\_endpoint](#input\_create\_endpoint) | Whether to create the custom proxy endpoint resources defined in `custom_endpoint`. | `bool` | `true` | no |
| <a name="input_custom_endpoint"></a> [custom\_endpoint](#input\_custom\_endpoint) | Map of custom proxy endpoints to create. Each key is used as the endpoint name unless overridden by the `name` field. Each entry supports: `name` (optional), `vpc_subnet_ids`, `vpc_security_group_ids` (optional), `target_role` (`READ_WRITE` or `READ_ONLY`, optional). | <pre>map(object({<br/>  name                   = optional(string, null)<br/>  vpc_subnet_ids         = list(string)<br/>  vpc_security_group_ids = optional(list(string), [])<br/>  target_role            = optional(string, "READ_WRITE")<br/>}))</pre> | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to create the proxy endpoint in. Required when creating custom endpoints. | `string` | `"us-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all resources created by the module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_proxy_id"></a> [proxy\_id](#output\_proxy\_id) | Identifier of the RDS Proxy. |
| <a name="output_proxy_arn"></a> [proxy\_arn](#output\_proxy\_arn) | ARN of the RDS Proxy. |
| <a name="output_proxy_endpoint"></a> [proxy\_endpoint](#output\_proxy\_endpoint) | Endpoint that applications use to connect to the proxy. |
| <a name="output_proxy_target_group_id"></a> [proxy\_target\_group\_id](#output\_proxy\_target\_group\_id) | Identifier of the proxy default target group. |
| <a name="output_proxy_target_group_arn"></a> [proxy\_target\_group\_arn](#output\_proxy\_target\_group\_arn) | ARN of the proxy default target group. |
| <a name="output_proxy_target_group_name"></a> [proxy\_target\_group\_name](#output\_proxy\_target\_group\_name) | Name of the proxy default target group. |
| <a name="output_proxy_target_endpoint"></a> [proxy\_target\_endpoint](#output\_proxy\_target\_endpoint) | Endpoint of the registered proxy target (instance or cluster). |
| <a name="output_proxy_target_port"></a> [proxy\_target\_port](#output\_proxy\_target\_port) | Port of the registered proxy target (instance or cluster). |
| <a name="output_proxy_target_rds_resource_id"></a> [proxy\_target\_rds\_resource\_id](#output\_proxy\_target\_rds\_resource\_id) | Identifier representing the DB instance or Aurora cluster. |
| <a name="output_proxy_target_type"></a> [proxy\_target\_type](#output\_proxy\_target\_type) | Type of the proxy target: `RDS_INSTANCE` or `TRACKED_CLUSTER`. |
| <a name="output_custom_endpoint"></a> [custom\_endpoint](#output\_custom\_endpoint) | Map of custom proxy endpoints. Each value contains `id`, `arn`, `endpoint`, and `target_role`. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role used by the proxy. Returns the provided `iam_role_arn` when one was supplied. |
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | ID of the IAM role created by the module. Null when `iam_role_arn` was supplied by the caller. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role created by the module. Null when `iam_role_arn` was supplied by the caller. |

## License

Apache 2 Licensed. See [LICENSE](https://github.com/TechHoldingLLC/terraform-aws-rds-proxy/blob/main/LICENSE) for full details.
