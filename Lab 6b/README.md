# END TO END ENCRYPTION USING AWS NLB running TCP LISTNERS

This repository contains a Terraform project that sets up a network architecture with load balancing and deploys instances in two Availability Zones (AZs) in the AWS US West 2 region. It encrypts traffic end to end. One at the NLB Listening for HTTPS and running TCP, and another on the server which generates a self-signed SSL certificate.

## Terraform Files
The project consists of the following Terraform files:

data.tf: Defines AWS IAM policy documents and retrieves information about AWS resources like IAM roles and network interfaces.

instances.tf: Creates AWS EC2 instances in two fleets, "Public_Instances_Fleet_1" and "Public_Instances_Fleet_2," with two instances in each fleet. The instances are launched in separate subnets in AZs 2A and 2B.

marketing.sh: Bash script that configures the web server and generates a self-signed SSL certificate for the Marketing department's web page.

networking.tf: Sets up the VPC, internet gateway, subnets, and route table. It also configures a Network Load Balancer (NLB) with two target groups for the Marketing and Sales departments.

output.tf: Defines output variables that display public IP addresses for the instances and DNS information for the Marketing and Sales web pages.

sales.sh: Bash script similar to marketing.sh but for the Sales department's web page.

security.tf: Creates an AWS security group to allow SSH, HTTPS, and ICMP inbound traffic. It also generates flow logs of the NLB ENI to check that traffics to the server are encrypted.

terraform.tf: Contains backend configuration for local state management and defines the required AWS provider version.

variables.tf: Declares input variables, including the hosted zone ID for Route53.

## Getting Started
Follow these steps to deploy the infrastructure:

Install Terraform: Ensure you have Terraform installed on your system. You can download it from terraform.io and follow the installation instructions.

Configuration: Update the variable.tf file with your specific values, such as the hosted_zone_id for Route53.

Initialize Terraform: Run terraform init in the project directory to initialize the working directory and download the required provider plugins.

Review the Plan: Run terraform plan to see a preview of the changes Terraform will make to the infrastructure.

Apply the Changes: If the plan looks good, apply the changes with terraform apply. Confirm the changes when prompted.

Access Web Pages: Once the Terraform deployment is complete, you can access the Marketing and Sales department web pages using the public IP addresses or DNS names provided in the output.

## Additional Notes
The instances run in two Availability Zones (AZs) to ensure high availability and redundancy.

The Marketing and Sales department web pages are accessible through HTTPS, which is configured on the Network Load Balancer using self-signed SSL certificates.

Flow logs are enabled for the network interfaces of the instances to capture network traffic.

The terraform.tf file specifies a local backend. For production usage, consider using remote state storage like Amazon S3.

Ensure that you have appropriate AWS credentials and permissions to create the required resources.

## Clean Up
To remove the infrastructure and clean up resources, run terraform destroy in the project directory. Confirm the destruction when prompted.

Remember that destroying the resources is irreversible and will result in data loss.

For further information about Terraform and AWS configurations, refer to the official Terraform documentation and AWS documentation.