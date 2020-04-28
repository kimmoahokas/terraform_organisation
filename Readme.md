# Terraform code organization #

This repo contains two alternative approaches for structuring terraform code with multiple configurations. There are 2 environments, dev and prod, that both have base infrastructure and 1 application. Both environments have separate s3 backends so that it's possible to give certain people access to dev but not to prod environment etc.

The configurations are not complete and can't be run as such. But hopefully enough to illustrate the point and compare the differences between these approaches.

The terraform code for infrastructure and app are separated again so that we can restrict access to people who need it. For example the infrastructure should not change often and most developers should not need access to it. Infrastructure will contain things like VPC config and IAM config for human/CI access to the accounts. App config then uses that base infra for configuring the app specific parts (load balancers, ec2, s3 etc.)

Both approaches should be compatible with [Terraform workspaces](https://www.terraform.io/docs/state/workspaces.html) so that it's easy to create temporary duplicates of the infrastructure for development purposes. For example when developing new version of app1 the developer might create their own workspace in dev/app1, develop and test their changes to terraform code and then delete the workspace when the changes work as expected.

Both approaches require that you have appropriate AWS profiles and configs, see [AWS CLI named profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

Notice that this sample does not follow Terraform best practices in many parts. for example the configuration in modules should be split up to multiple files, usually named main.tf, variables.tf, outputs.tf and so on. For simplicity everything is in a single file where possible.

## Alternative 1: Only config and variables duplicated ##

This model has minimal amount of terraform code duplicated. However, this is not officially supported and we need to provide lots of cli parameters to terraform. Furthermore, we need to run `terraform init` every time changing between infrastructure and app1 or between environments. Some of the difficulties can be abstracted away by creating a wrapper script that calls the commands with correct arguments.

This model forces each environment to be pretty much identical, as terraform code can't be customized per environment.

Based on advice from https://aws-blog.de/2019/05/managing-multiple-stages-with-terraform.html

### Structure ###

```
.
├── app1
│   ├── configs
│   │   ├── dev-backend.config
│   │   ├── dev-vars.tfvars
│   │   ├── prod-backend.config
│   │   └── prod-vars.tfvars
│   └── main.tf
└── infrastructure
    ├── configs
    │   ├── dev-backend.config
    │   ├── dev-vars.tfvars
    │   ├── prod-backend.config
    │   └── prod-vars.tfvars
    ├── main.tf
    └── modules
        └── vpc
            └── main.tf
```

### Changing between environments ###

```shell
cd infrastructure
terraform init -reconfigure -backend-config=configs/dev-backend.config
terraform plan -var-file=configs/dev-vars.tfvars
terraform apply -var-file=configs/dev-vars.tfvars
```

## Alternative 2: Each environment as a terraform root module ##

This approach requires some code duplication, but is officially supported and rather easy to follow. The command are simple and don't need any special flags. If needed, the environments can differ from each other. It's outright evident from the shell working path on what environment or app you are working on.

To reduce amount of code deduplication, the root modules in each environment (for example `infrastructure/dev`) share some common terraform configuration. the shared parts are in root-modules-shared folder and then linked to each of the environments.

Based on advice from https://github.com/antonbabenko/terraform-best-practices/tree/master/examples/large-terraform

### Failure modes ###

- You forget to add module block to certain environment config file when adding modules. No harm done, nothing should break
- Changes to a module can't be pushed to all environments at the same time. Use tagged versions of modules in staging/production

### Structure ###

```
.
├── app1
│   ├── dev
│   │   └── dev-app1.tf
│   └── prod
│       └── prod-app1.tf
├── infrastructure
│   ├── dev
│   │   ├── dev-infra.tf
│   │   ├── outputs.tf -> ../root-module-shared/outputs.tf
│   │   ├── providers.tf -> ../root-module-shared/providers.tf
│   │   └── versions.tf -> ../root-module-shared/versions.tf
│   ├── prod
│   │   ├── outputs.tf -> ../root-module-shared/outputs.tf
│   │   ├── prod-infra.tf
│   │   ├── providers.tf -> ../root-module-shared/providers.tf
│   │   └── versions.tf -> ../root-module-shared/versions.tf
│   └── root-module-shared
│       ├── outputs.tf
│       ├── providers.tf
│       └── versions.tf
└── modules
    ├── app1-service
    │   └── main.tf
    └── vpc
        └── main.tf

```

### Changing between environments ###

```shell
cd infrastructure/dev
terraform init # not needed every time
terraform plan
terraform apply
```

`terraform init`, `terraform plan` and `terraform apply` need to be run in following directories:

- `infrastructure/dev`
- `infrastructure/prod`
- `app1/dev`
- `app1/prod`
