# Terraform Template

Template Terraform stack

Currently using Terraform 0.14.x

## Deploying Infrastructure Upgrades

If the infrastructure changes then follow the below instructions to deploy upgrades:

1. Move to the terraform folder: ```cd terraform```
2. Set the environment you want to work with as TF_ENV varible (development/staging/production) e.g.: ```export TF_ENV=development```
3. Authenticate with AWS to ensure the relevant AWS profile is active for your chosen workspace
4. Initialise the modules: ```terraform init -backend-config=./backends/${TF_ENV}.conf```
5. Select / create workspace: ```terraform workspace select ${TF_ENV}``` (or workspace new for the first run)
6. Check for updates to modules: ```terraform get -update=true```
7. Check for changes/errors: ```terraform plan -var-file=./workspaces/${TF_ENV}.tfvars```
8. Execute the deployment: ```terraform apply -var-file=./workspaces/${TF_ENV}.tfvars```
9. Acquire the output variables for updating the task definitions (when changed): ```terraform output```

## Switching between environments

To deploy stacks to different environments you need to switch backend configs using the ```-backend-config ``` flag of ```terraform init``` and use the appropriate .tfvars file in the /workspaces folder.

If you switch environments/backends after having run ```terraform plan``` in another environment **DO NOT COPY THE EXISTING STATE TO THE NEW BACKEND**

## Outputs available after deployment

Once deployed the following useful values are accessible by running ```terraform output```

- Bucket ARN
- Ingest bulk access key - For bulk ingestion of content
- Ingest bulk secret key

## Project Layout

The following files are in the root of the project:
- .github/workflows - configuration for Github actions
- .gitignore - set of files that Git will ignore.
- .nvmrc - configuration for Node version manager.
- package.json - configuration for Node.
- package-lock.json - configuration for Node.
- README.md - this README.

The Terraform files should live in the 'terraform' subfolder as this is where both the linter
and the validator will look for files to check.
Conventions and other useful information can be found here:
* [Setup](terraform/README.md)
* [Workspace configuration](terraform/workspaces/README.md)

## Technology Used

* [checkov] - Code analysis tool for Infrastructure-as-code.
* [docker] - Open platform for running applications in containers.
* [husky] - Provides git hooks for pre-commit and pre-push.
* [node.js] - A Javascript runtime built on Chrome's V8 Javascript engine.
* [nvm] - Node Version Manager.
* [semantic-release] - The semantic-release package which manages the versioning.
* [tflint] - A Terraform Linter.

### Node

This terraform project uses node to provide the semantic-release functionality.

### Node version manager

To make sure we are using a consistent version of node, we make use of the Node version manager.
The version is specified in the .npmrc file and can be selected by running:
```bash
nvm use
```

### Terraform Linter

A Terraform linter [tflint] is included in this project to help reduce errors.
It is run via a dockerised container and is invoked during the Jenkins build.
It can also be run locally using:
```bash
npm run tflint
```

### Terraform Validation Tool

A Terraform validator [checkov] is included in this project to help detect configuration errors.
It is run via a dockerised container and is invoked during the Jenkins build.
It can also be run locally using:
```bash
npm run checkov
```
Alternatively, to get the cli output which is more human readable:
```bash
npm run checkov:cli
```

Note: the dockerised container throws out some spurious escape characters after producing the
junit xml output. These are being stripped off using "grep -v '^.\[0m'" since this is more portable
than using "head -n -2" to trim off the bottom two lines.

### Terraform Security Check

A Terraform security check [tfsec] is included in this project to help detect security issues.
This is NOT currently run via Jenkins because it typically requires `terraform init`.
It can be run locally via a dockerised container to produce `security-report.xml` with:
```bash
npm run tfsec
```
Alternatively, to get the cli output which is more human readable:
```bash
npm run tfsec:cli
```

Note: if the terraform relies on other modules, then `terraform init` will need running first.
The following is provided for convenience but see [Terraform](Terraform.md) regarding the use
of `tfenv` to manage terraform versions.
```bash
npm run terraform-init
```

### Terraform Formatter

To help produce consistently formatted terraform files, the "format" script is included in the
package.json file. This runs "terraform fmt" recursively over the terraform folder structure.
It can be run with:
```bash
npm run format
```

### husky

Husky helps enforce commit message conventions, and provides some pre-commit and pre-push validation
for the terraform files to help catch errors in configuration.

Note:
Husky can cause issues as it no longer supports `nvm`. On a unix based machine it is possible
to add some support by adding a `.huskyrc` file to your home directory:
```bash
if [ -s '.nvmrc' ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm use > /dev/null
fi
```

### Semantic Release - Commit style

It is recommended for clarity that the ticket reference is included in the commit message body, the format should be as follows:

`fix|feat|perf(<short_feature_name>): <ticket> - <description_of_change>`

Here is an example of the release type that will be done based on a commit messages.

| Commit message  | Release type               |
|-----------------|----------------------------|
| `fix(logging): TICKET-1234 - Additional logging`  | Patch Release |
| `feat(publish-endpoint): TICKET-2345 - Addition of the /publish endpoint to the API` | ~~Minor~~ Feature Release  |
| `perf(event-model): TICKET-3456 - Event model update `<br><br>`BREAKING CHANGE: The time attribute has been removed.` | ~~Major~~ Breaking Release |

[checkov]:https://www.checkov.io/
[docker]:https://www.docker.com/
[husky]:https://github.com/typicode/husky
[node.js]:https://nodejs.org
[nvm]:https://github.com/creationix/nvm
[semantic-release]:https://github.com/semantic-release/semantic-release
[tflint]:https://github.com/terraform-linters/tflint
