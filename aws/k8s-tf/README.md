# EKS / Kasten Automation

> **Note**: This code is currently a work in progress.

This Terraform code deploys:

* [eks.tf](./eks.tf): an EKS cluster and managed node group, with most options configurable via variables.
* [iam.tf](./iam.tf): IAM roles and policies for the EKS cluster, worker nodes, EBS CSI driver, EFS CSI driver, AWS Load Balancer Controller, and Kasten K10.
* [main.tf](./main.tf): required provider versions and credential file information.
* [s3.tf](./s3.tf): an S3 bucket which is used for application backups via Kasten.
* [variables.tf](./variables.tf): variable declarations.
* [vpc.tf](./vpc.tf): a new VPC, public and private subnets across multiple availability zones, internet gateway, NAT gateway, and associated security groups and route tables.

Please see the [main readme](../../README.md) for information on how to deploy.

## Credentials

There is one main credential which is required:

* `aws_cred_file`: this variable should point to a local JSON file containing AWS credentials with the following format:
    ```text
    {
        "aws_access_key_id": "AKIAIOSFODNN7EXAMPLE",
        "aws_secret_access_key": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    }
    ```

## Other Settings

### AWS Settings

All of these variables *must* be updated to match your AWS region and credential file location.

### Authorized Networks

The bottom of the `tfvars` file contains an `authorized_networks` list which permits access to the deployed resources. You should update the values (and optionally add additional values) to match any IP ranges that you wish to access the environment from (`curl http://checkip.amazonaws.com` is a useful command to figure out your IP address).

## Output Variables

Once Terraform has finished deploying, there will be several output variables displayed, for example:

```text
_1_aws_kubeconfig_cmd = "aws eks update-kubeconfig --region us-east-2 --name mhaigh-default-cluster"
```

Additional detail on these outputs:

* `_1_aws_kubeconfig_cmd`: an `aws` CLI command to configure kubeconfig credentials
