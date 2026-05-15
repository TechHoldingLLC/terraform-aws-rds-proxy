# -----------
# RDS Proxy #
# -----------

resource "aws_db_proxy" "rds_proxy" {
  name                   = var.name
  debug_logging          = var.debug_logging
  engine_family          = var.engine_family
  idle_client_timeout    = var.idle_client_timeout
  require_tls            = var.require_tls
  role_arn               = local.existing_iam_role_arn
  vpc_security_group_ids = var.security_group_ids
  vpc_subnet_ids         = var.vpc_subnet_ids

  dynamic "auth" {
    for_each = var.auth
    content {
      auth_scheme = auth.value.auth_scheme
      iam_auth    = auth.value.iam_auth
      secret_arn  = auth.value.secret_arn
      username    = auth.value.username
      description = auth.value.description
    }
  }

  tags = var.tags

  # The role must exist before the proxy can be created.
  depends_on = [aws_iam_role_policy.proxy_access]
}

# -------------------------------------------------
# Default Target Group — connection pool settings #
# -------------------------------------------------

resource "aws_db_proxy_default_target_group" "connection_pool" {
  db_proxy_name = aws_db_proxy.rds_proxy.name

  connection_pool_config {
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
    connection_borrow_timeout    = var.connection_borrow_timeout
    init_query                   = var.init_query
    session_pinning_filters      = var.session_pinning_filters
  }

  lifecycle {
    replace_triggered_by = [aws_db_proxy.rds_proxy.id] # If the proxy is replaced, the target group must be replaced as well.
  }
}

# ----------------------------------------------
# Proxy Target — DB instance or Aurora cluster #
# ----------------------------------------------

resource "aws_db_proxy_target" "db_instance" {
  count = var.db_instance_identifier != null ? 1 : 0

  db_proxy_name          = aws_db_proxy.rds_proxy.name
  target_group_name      = aws_db_proxy_default_target_group.connection_pool.name
  db_instance_identifier = var.db_instance_identifier

  lifecycle {
    replace_triggered_by = [aws_db_proxy.rds_proxy.id]
  }
}

resource "aws_db_proxy_target" "db_cluster" {
  count = var.db_cluster_identifier != null ? 1 : 0

  db_proxy_name         = aws_db_proxy.rds_proxy.name
  target_group_name     = aws_db_proxy_default_target_group.connection_pool.name
  db_cluster_identifier = var.db_cluster_identifier

  lifecycle {
    replace_triggered_by = [aws_db_proxy.rds_proxy.id]
  }
}

# ------------------
# Proxy Endpoints  #
# ------------------

resource "aws_db_proxy_endpoint" "custom_endpoint" {
  for_each = { for k, v in var.custom_endpoint : k => v if var.create_endpoint }

  region = var.region

  db_proxy_name          = aws_db_proxy.rds_proxy.name
  db_proxy_endpoint_name = coalesce(each.value.name, each.key)
  vpc_subnet_ids         = each.value.vpc_subnet_ids
  vpc_security_group_ids = each.value.vpc_security_group_ids
  target_role            = each.value.target_role
}
