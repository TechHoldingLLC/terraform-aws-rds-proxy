# -----------
# RDS Proxy #
# -----------

output "proxy_id" {
  description = "Identifier of the RDS Proxy."
  value       = aws_db_proxy.rds_proxy.id
}

output "proxy_arn" {
  description = "ARN of the RDS Proxy."
  value       = aws_db_proxy.rds_proxy.arn
}

output "proxy_endpoint" {
  description = "Endpoint that applications use to connect to the proxy."
  value       = aws_db_proxy.rds_proxy.endpoint
}

# ----------------------
# Default Target Group #
# ----------------------

output "proxy_target_group_id" {
  description = "Identifier of the proxy default target group."
  value       = aws_db_proxy_default_target_group.connection_pool.id
}

output "proxy_target_group_arn" {
  description = "ARN of the proxy default target group."
  value       = aws_db_proxy_default_target_group.connection_pool.arn
}

output "proxy_target_group_name" {
  description = "Name of the proxy default target group."
  value       = aws_db_proxy_default_target_group.connection_pool.name
}

# --------------
# Proxy Target #
# --------------

output "proxy_target_endpoint" {
  description = "Endpoint of the registered proxy target (instance or cluster)."
  value       = var.db_instance_identifier != null ? aws_db_proxy_target.db_instance[0].endpoint : aws_db_proxy_target.db_cluster[0].endpoint
}

output "proxy_target_port" {
  description = "Port of the registered proxy target (instance or cluster)."
  value       = var.db_instance_identifier != null ? aws_db_proxy_target.db_instance[0].port : aws_db_proxy_target.db_cluster[0].port
}

output "proxy_target_rds_resource_id" {
  description = "Identifier representing the DB instance or Aurora cluster."
  value       = var.db_instance_identifier != null ? aws_db_proxy_target.db_instance[0].rds_resource_id : aws_db_proxy_target.db_cluster[0].rds_resource_id
}

output "proxy_target_type" {
  description = "Type of the proxy target: RDS_INSTANCE or TRACKED_CLUSTER."
  value       = var.db_instance_identifier != null ? aws_db_proxy_target.db_instance[0].type : aws_db_proxy_target.db_cluster[0].type
}

# -------------------
# Proxy Endpoints   #
# -------------------

output "custom_endpoint" {
  description = "Map of custom proxy endpoints. Each value contains id, arn, endpoint, and target_role."
  value = {
    for k, ep in aws_db_proxy_endpoint.custom_endpoint : k => {
      id          = ep.id
      arn         = ep.arn
      endpoint    = ep.endpoint
      target_role = ep.target_role
    }
  }
}

# ----------
# IAM Role #
# ----------

output "iam_role_arn" {
  description = "ARN of the IAM role used by the proxy. Returns the provided iam_role_arn when one was supplied."
  value       = local.existing_iam_role_arn
}

output "iam_role_id" {
  description = "ID of the IAM role created by the module. Null when iam_role_arn was supplied by the caller."
  value       = var.iam_role_arn == null ? aws_iam_role.rds_proxy[0].id : null
}

output "iam_role_name" {
  description = "Name of the IAM role created by the module. Null when iam_role_arn was supplied by the caller."
  value       = var.iam_role_arn == null ? aws_iam_role.rds_proxy[0].name : null
}
