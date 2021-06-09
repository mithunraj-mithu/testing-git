Terraform Layout
================

All [terraform] files are kept in the `terraform` directory to ensure isolation.  This is purely
convention and is not required by the [terraform] application.

The [terraform] application runs in the current working directory, so all [terraform] operations
need to take place in the `terraform` directory.

Before [terraform] can be used it must first be initialised using the correct 'backend' then a workspace selected.

e.g.
```
export TF_ENV=development
terraform init -backend-config=./backends/${TF_ENV}.conf
terraform workspace select ${TF_ENV}
```

Terraform Version Management
----------------------------

It is strongly recommended that `tfenv` or some other form of version management be used.

Where possible it is suggested that the most recent terraform possible is used, however, sometimes
dependencies mean that older versions are required.


Terraform Configuration
-----------------------

Terraform loads all files in the current working directory (i.e. `terraform`) ending with `.tf`.

The naming of `.tf` files does not matter to [terraform] and as such is purely convention.  Whilst for smaller projects it is common to place the majority of the code in `main.tf` for medium size and above projects this is not practical, so it is strongly encouraged that `main.tf` is not used even for
simple projects.


### Specifically Named Files ###

These namings are just a suggested convention.

It is suggested that for local modules that a similar naming convention is used, so module specific
variables be stored in that modules `variables.tf` file.

#### `outputs.tf` ####

It is recommended that all `output` blocks be places in this file.

e.g.
```
output "example_output_name" {
  value = aws_resource.resource_name.id
}
```

#### `providers.tf` ####

It is recommended that all `provider` blocks be placed in this file.

e.g.
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.24.1"
    }
  }
  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}
```

#### `variables.tf` ####

It is recommended that all `variable` blocks be placed in this file.

e.g.

With default value:
```
variable "region" {
  default = "eu-west-1"
}
```

Requiring user input or `-var` / `-var-file` command line arguments:
```
variable "vpc_id" {}
```

#### `versions.tf` ####

It is recommended that this is used to store the `terraform` block and that such a block should contain
`required_version` bounded in both ends.

e.g.
```
terraform {
  required_version = ">= 0.14, < 0.15"
}
```


### Other Files ###

In general these files are named to indicate the purpose of the code within.

#### resources / data ####

It is recommended that all related `resource` (and `data`) blocks be given individual files with names that indicate the purpose of the group of resources.

Different groups of resources (and data) should have separate files.


Terraform Variable Values
-------------------------

By-default the only terraform variable files (files with the `.tfvar` extension) that are
loaded are either called `terraform.tfvars` or match `*.auto.tfvars`.  It is not recommended
that any of these automatically loaded files be used, instead `default` values should be inside `variables.tf` wherever possible.

All other such files are not loaded unless explicitly loaded using the command-line
option `-var-file`.

This way we can have environment specific variable values.

Please note however that `-var-file="workspace/<workspace>.tfvar"` is required on all `apply` and
`plan` calls to load those environment-specific variables.

### Manual Setting ###

If a required value is not specified in a variable file or via the command-line then the user will
be prompted to enter the value.

It is therefore sometimes useful to use the `-var` command-line option.

NB the `-var` command-line option has some issues with the `"` character in inputs.

The standard form (unix) for these command-line variables is usually:

```
-var 'region=us-west-2'
```

It should be noted that `-var-file` is more flexible in general as trying to parse complex
strings via `-var` can be rather tricky.


[terraform]:https://www.terraform.io/

[module]:https://www.terraform.io/docs/configuration/modules.html
[output]:https://www.terraform.io/docs/configuration/outputs.html
[provider]:https://www.terraform.io/docs/providers/index.html
[variable]:https://www.terraform.io/docs/configuration/variables.html
