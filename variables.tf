# ----------
# Required #
# ----------

variable "name" {
  description = "Identifier for the RDS Proxy. Must be unique per region."
  type        = string
}

variable "engine_family" {
  description = "Engine family the proxy supports. Valid values: MYSQL, POSTGRESQL, SQLSERVER."
  type        = string

  validation {
    condition     = contains(["MYSQL", "POSTGRESQL", "SQLSERVER"], var.engine_family)
    error_message = "engine_family must be one of: MYSQL, POSTGRESQL, SQLSERVER."
  }
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs to associate with the proxy."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of VPC security group IDs to associate with the proxy."
  type        = list(string)
}

variable "auth" {
  description = "Map of auth entries for the proxy. Each entry supports: auth_scheme, secret_arn, iam_auth (optional), username (optional), description (optional)."

  type = map(object({
    auth_scheme = string
    secret_arn  = string
    iam_auth    = optional(string, "DISABLED")
    username    = optional(string, null)
    description = optional(string, null)
  }))
}

# --------
# Target #
# --------

variable "db_instance_identifier" {
  description = "Identifier of the RDS DB instance to register as the proxy target. Mutually exclusive with db_cluster_identifier."
  type        = string
  default     = null
}

variable "db_cluster_identifier" {
  description = "Identifier of the Aurora DB cluster to register as the proxy target. Mutually exclusive with db_instance_identifier."
  type        = string
  default     = null
}

# -----
# IAM #
# -----

variable "iam_role_arn" {
  description = <<-EOT
    ARN of an existing IAM role for the proxy to use when accessing Secrets
    Manager. When set, the module does NOT create an IAM role or policy.
    When omitted, the module creates a least-privilege role automatically.
  EOT
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name for the IAM role created by the module. Defaults to '<name>-rds-proxy-role'. Ignored when iam_role_arn is set."
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the IAM role created by the module. Ignored when iam_role_arn is set."
  type        = string
  default     = "/"
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the IAM policy to use as a permissions boundary for the created role. Ignored when iam_role_arn is set."
  type        = string
  default     = null
}

variable "iam_policy_name" {
  description = "Name for the inline IAM policy attached to the created role. Defaults to '<name>-rds-proxy-policy'. Ignored when iam_role_arn is set."
  type        = string
  default     = null
}

# -----
# KMS #
# -----

variable "kms_key_arns" {
  description = "List of KMS key ARNs that the proxy IAM role is allowed to use for decrypting Secrets Manager secrets. Ignored when iam_role_arn is set."
  type        = list(string)
  default     = []
}

# -----------------
# Proxy behaviour #
# -----------------

variable "debug_logging" {
  description = "Whether the proxy includes detailed information about SQL statements in its logs."
  type        = bool
  default     = false
}

variable "idle_client_timeout" {
  description = "Number of seconds a client connection can remain idle before the proxy closes it. Range: 1–28800."
  type        = number
  default     = 1800

  validation {
    condition     = var.idle_client_timeout >= 1 && var.idle_client_timeout <= 28800
    error_message = "idle_client_timeout must be between 1 and 28800 seconds."
  }
}

variable "require_tls" {
  description = "Whether TLS encryption is required for connections to the proxy."
  type        = bool
  default     = true
}

# -----------------
# Connection pool #
# -----------------

variable "max_connections_percent" {
  description = "Maximum size of the connection pool as a percentage of max_connections for the RDS DB instance. Range: 1–100."
  type        = number
  default     = 100

  validation {
    condition     = var.max_connections_percent >= 1 && var.max_connections_percent <= 100
    error_message = "max_connections_percent must be between 1 and 100."
  }
}

variable "max_idle_connections_percent" {
  description = "Controls how actively the proxy closes idle database connections in the connection pool. Range: 0–100."
  type        = number
  default     = 50

  validation {
    condition     = var.max_idle_connections_percent >= 0 && var.max_idle_connections_percent <= 100
    error_message = "max_idle_connections_percent must be between 0 and 100."
  }
}

variable "connection_borrow_timeout" {
  description = "Number of seconds the proxy waits for a connection from the pool before returning a timeout error. Range: 1–3600."
  type        = number
  default     = 120

  validation {
    condition     = var.connection_borrow_timeout >= 1 && var.connection_borrow_timeout <= 3600
    error_message = "connection_borrow_timeout must be between 1 and 3600 seconds."
  }
}

variable "init_query" {
  description = "One or more SQL statements for the proxy to run when opening each new DB connection. Typically used for SET statements."
  type        = string
  default     = null
}

variable "session_pinning_filters" {
  description = "List of conditions that cause the proxy to pin a session to a specific DB connection. Supported value: EXCLUDE_VARIABLE_SETS."
  type        = list(string)
  default     = []
}

# -------------------
# Proxy Endpoints   #
# -------------------

variable "create_endpoint" {
  description = "Whether to create the proxy endpoint resources."
  type        = bool
  default     = true
}

variable "custom_endpoint" {
  description = "Map of custom proxy endpoints to create. Each key is used as the endpoint name unless overridden by the `name` field."
  type = map(object({
    name                   = optional(string, null)
    vpc_subnet_ids         = list(string)
    vpc_security_group_ids = optional(list(string), [])
    target_role            = optional(string, "READ_WRITE")
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.custom_endpoint : contains(["READ_WRITE", "READ_ONLY"], v.target_role)])
    error_message = "Each endpoint target_role must be either READ_WRITE or READ_ONLY."
  }
}

variable "region" {
  description = "AWS region to create the proxy endpoint in. Required when creating endpoints."
  type        = string
  default     = null
}

# ------
# Tags #
# ------

variable "tags" {
  description = "Map of tags to apply to all resources created by the module."
  type        = map(string)
  default     = {}
}
