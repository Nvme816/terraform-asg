# terraform-asg-deployment
Static website deployed to S3 using Terraform ASG

## Objective
Deploy a resilient web hosting baseline that stays available during traffic surges using an Auto Scaling Group with minimum capacity enforcement and automated instance recovery.

## Services Used
- GitHub (Source Repository)
- Terraform (Infrastructure as Code)
- Amazon EC2 (Compute Instances)
- EC2 Launch Template (Standardized Instance Configuration)
- Amazon EC2 Auto Scaling (Auto Scaling Group)
- Amazon VPC (Default VPC and Subnets)
- Amazon Security Groups (Network Access Control)
- Amazon S3 (Terraform Remote Backend State Storage)
- Amazon DynamoDB (Terraform State Locking)

## Architecture
GitHub Repo + Terraform + Launch Template + Auto Scaling Group (2 Subnets in Default VPC) + EC2 Instances (Apache via User Data)  
Terraform Remote Backend + S3 Bucket  
Terraform State Locking + DynamoDB Table

## Steps Completed
1. Created Terraform project structure with separate folders for backend bootstrapping and ASG deployment.
2. Pulled the default VPC and selected two public subnets for high availability placement.
3. Created a security group allowing inbound HTTP access from the internet.
4. Created a launch template that installs and starts Apache using a user data script.
5. Deployed an Auto Scaling Group with capacity settings:
   - Min desired capacity: 2
   - Desired capacity: 2
   - Max desired capacity: 5
6. Verified two EC2 instances launched successfully and were marked Healthy and InService.
7. Verified both instance public IPs served the Apache web page in a browser.
8. Terminated one instance to confirm the Auto Scaling Group automatically launched a replacement instance.
9. Created an S3 bucket and configured it as the Terraform remote backend.
10. Enabled DynamoDB state locking to prevent concurrent Terraform state modification.
11. Migrated local Terraform state to the remote backend using `terraform init -migrate-state`.

## Deployment Details
- AWS Region: us-east-1
- Auto Scaling Group Name: cc-asg-foundational-asg
- Desired Capacity: 2
- Scaling Limits: Min 2 Max 5
- Instance Type: t2.micro
- Web Port: 80
- Terraform Remote Backend Bucket: tf-state-asg-ccfoundational-backend-us-east-1
- Terraform State Path: asg-foundational/terraform.tfstate
- DynamoDB Lock Table: terraform-state-locks

## How to Verify
1. Go to AWS Console → EC2 → Auto Scaling Groups.
2. Select the Auto Scaling Group and confirm:
   - Desired capacity is 2
   - Min desired capacity is 2
   - Max desired capacity is 5
3. Go to Instance management and confirm two instances are Healthy and InService.
4. Go to EC2 → Instances and copy the Public IPv4 address of each instance.
5. Open each public IP in a browser using:
   - http://<public-ip>
6. Confirm the Apache page loads and displays the user data deployed content.
7. Terminate one instance from the EC2 Instances page.
8. Return to the Auto Scaling Group Instance management view and confirm a new instance launches to restore capacity back to 2.
9. Go to Amazon S3 and confirm the backend bucket contains:
   - asg-foundational/terraform.tfstate
10. Run `terraform plan` from the `asg-stack` folder and confirm locking is active if multiple applies are attempted.

## Results
- Successfully deployed an Auto Scaling Group across two subnets in the default VPC for high availability.
- Confirmed Apache is installed automatically on each instance using user data.
- Verified public HTTP access works through the security group on port 80.
- Confirmed self healing behavior by terminating an instance and observing an automatic replacement.
- Implemented remote Terraform state storage using S3.
- Verified state locking protection using DynamoDB.
