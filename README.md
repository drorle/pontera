# pontera
Home assignment from Pontera

Made of two parts:

## terraform
It contains:

The required module under "terraform/module"

Example files under "terraform/" that will deploy the resources

### Notes
When calling the module you must provide some subnet (see example), otherwise the deployment will fail. 

All the other parameters are optional, although the default values are not always "ideal".

## kubernetes
It contains a yaml file with the necessary components for the deployment.

### Important note
The configuration assumes the existence of a role named "arn:aws:iam::123456789012:role/aws-cli-role" with the necessary permissions to access the secret.

Assuming such a role doesn't exist, it should either be created or if another relevant role exists, replace the arn in the yaml file with the relevant role's arn.
