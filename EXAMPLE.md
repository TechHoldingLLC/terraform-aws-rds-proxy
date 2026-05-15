## Examples

### DB Instance target

```hcl
module "rds_proxy" {
  source = "./terraform-aws-rds-proxy"

  name               = "my-app-proxy"
  engine_family      = "POSTGRESQL"
  vpc_subnet_ids     = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
  security_group_ids = ["sg-0a1b2c3d4e5f67890"]

  auth = {
    primary = {
      auth_scheme = "SECRETS"
      secret_arn  = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-db-secret-AbCdEf"
    }
  }

  db_instance_identifier = "my-postgres-db"
}
```

### Aurora Cluster target

```hcl
module "rds_proxy" {
  source = "./terraform-aws-rds-proxy"

  name               = "my-aurora-proxy"
  engine_family      = "MYSQL"
  vpc_subnet_ids     = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
  security_group_ids = ["sg-0a1b2c3d4e5f67890"]

  auth = {
    primary = {
      auth_scheme = "SECRETS"
      secret_arn  = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-aurora-secret-AbCdEf"
    }
  }

  db_cluster_identifier = "my-aurora-cluster"
}
```

### With Customer-Managed KMS Key

```hcl
module "rds_proxy" {
  source = "./terraform-aws-rds-proxy"

  name               = "my-app-proxy"
  engine_family      = "POSTGRESQL"
  vpc_subnet_ids     = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
  security_group_ids = ["sg-0a1b2c3d4e5f67890"]

  auth = {
    primary = {
      auth_scheme = "SECRETS"
      secret_arn  = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-db-secret-AbCdEf"
    }
  }

  kms_key_arns = ["arn:aws:kms:us-west-2:123456789012:key/mrk-1234abcd12ab34cd56ef1234567890ab"]

  db_instance_identifier = "my-postgres-db"
}
```

### With Existing IAM Role

When you supply `iam_role_arn`, no IAM role or policy is created by this module.

```hcl
module "rds_proxy" {
  source = "./terraform-aws-rds-proxy"

  name               = "my-app-proxy"
  engine_family      = "POSTGRESQL"
  vpc_subnet_ids     = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
  security_group_ids = ["sg-0a1b2c3d4e5f67890"]

  iam_role_arn = "arn:aws:iam::123456789012:role/my-existing-proxy-role"

  auth = {
    primary = {
      auth_scheme = "SECRETS"
      secret_arn  = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-db-secret-AbCdEf"
    }
  }

  db_instance_identifier = "my-postgres-db"
}
```

### With Multiple Auth Secrets

```hcl
module "rds_proxy" {
  source = "./terraform-aws-rds-proxy"

  name               = "my-app-proxy"
  engine_family      = "POSTGRESQL"
  vpc_subnet_ids     = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
  security_group_ids = ["sg-0a1b2c3d4e5f67890"]

  auth = {
    admin = {
      auth_scheme = "SECRETS"
      secret_arn  = "arn:aws:secretsmanager:us-west-2:123456789012:secret:admin-secret-AbCdEf"
      username    = "admin"
      description = "Admin user"
    }
    app = {
      auth_scheme = "SECRETS"
      secret_arn  = "arn:aws:secretsmanager:us-west-2:123456789012:secret:app-secret-AbCdEf"
      username    = "app_user"
      description = "Application user"
    }
  }

  db_instance_identifier = "my-postgres-db"
}
```

### With Custom Endpoints

Use `custom_endpoint` to create additional proxy endpoints with different roles (e.g. a read-only endpoint for reporting workloads).

```hcl
module "rds_proxy" {
  source = "./terraform-aws-rds-proxy"

  name               = "my-app-proxy"
  engine_family      = "POSTGRESQL"
  vpc_subnet_ids     = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
  security_group_ids = ["sg-0a1b2c3d4e5f67890"]
  region             = "us-west-2"

  auth = {
    primary = {
      auth_scheme = "SECRETS"
      secret_arn  = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-db-secret-AbCdEf"
    }
  }

  db_cluster_identifier = "my-aurora-cluster"

  custom_endpoint = {
    readonly = {
      vpc_subnet_ids         = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
      vpc_security_group_ids = ["sg-0a1b2c3d4e5f67890"]
      target_role            = "READ_ONLY"
    }
    readwrite = {
      name                   = "my-app-proxy-rw"
      vpc_subnet_ids         = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
      vpc_security_group_ids = ["sg-0a1b2c3d4e5f67890"]
      target_role            = "READ_WRITE"
    }
  }
}

output "readonly_endpoint" {
  value = module.rds_proxy.custom_endpoint["readonly"].endpoint
}
```

### Full Configuration

```hcl
module "rds_proxy" {
  source = "./terraform-aws-rds-proxy"

  name               = "my-app-proxy"
  engine_family      = "POSTGRESQL"
  vpc_subnet_ids     = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
  security_group_ids = ["sg-0a1b2c3d4e5f67890"]
  region             = "us-west-2"

  auth = {
    primary = {
      auth_scheme = "SECRETS"
      iam_auth    = "DISABLED"
      secret_arn  = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-db-secret-AbCdEf"
      username    = "app_user"
    }
  }

  debug_logging       = false
  idle_client_timeout = 1800
  require_tls         = true

  max_connections_percent      = 100
  max_idle_connections_percent = 50
  connection_borrow_timeout    = 120

  db_instance_identifier = "my-postgres-db"

  custom_endpoint = {
    readonly = {
      vpc_subnet_ids = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f6789012"]
      target_role    = "READ_ONLY"
    }
  }

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```
