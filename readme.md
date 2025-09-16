# 🛠️ AWS Terraform Config Project

This project provisions a complete AWS infrastructure using Terraform, including a VPC, public subnets, EC2 web servers, an S3 bucket, and an Application Load Balancer (ALB). It's designed as a reproducible demo for learning and showcasing infrastructure-as-code best practices.

---

## 📐 Architecture Overview

![AWS Terraform Infra](AWS%20Terraform%20Infra.jpg)

- Two public subnets across different AZs (`eu-north-1a`, `eu-north-1b`)
- Internet Gateway and route table for outbound access
- Security group allowing HTTP and SSH
- Two EC2 instances bootstrapped with Apache and custom HTML via `userdata.sh`
- S3 bucket for static asset storage
- Application Load Balancer distributing traffic across EC2s

---

## 🔧 Prerequisites

- Terraform ≥ 1.5.0
- AWS CLI configured with credentials
- IAM permissions to create VPC, EC2, S3, and ALB resources
- SSH key pair (if you plan to access EC2 manually)

---

## 🚀 Setup Instructions

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the infrastructure
terraform apply
```

> 💡 After deployment, Terraform will output the ALB DNS name. Visit it in your browser to verify the setup.

---

## 📁 File Structure

```
aws_terraform_config_project/
├── main.tf                  # Core infrastructure: VPC, EC2, ALB, S3
├── provider.tf              # AWS provider configuration
├── variables.tf             # Input variables (e.g., VPC CIDR)
├── userdata.sh              # EC2 bootstrap script for webserver1
├── userdata1.sh             # EC2 bootstrap script for webserver2
├── AWS Terraform Infra.jpg  # Architecture diagram
```

> ⚠️ `terraform.tfstate` and backup files are excluded via `.gitignore` for safety.

---

## 🔒 Security Notes

- No secrets or credentials are committed.
- `.gitignore` excludes sensitive files like `.tfstate`, `.pem`, `.env`, and AWS config.
- EC2 instances are publicly accessible via port 80 and 22 — restrict access in production.

---

## 🌐 Output

After `terraform apply`, you’ll see:

```bash
loadbalancerdns = <your-alb-dns-name>
```

Use this DNS to access the deployed portfolio page served by Apache.

---

## 👤 Author

**Kevin** — DevOps enthusiast and backend builder  
📍 Nairobi, Kenya  
🧠 Focused on reproducibility, clarity, and collaborative learning

---

## 📄 License

This project is open-source and available under the [MIT License](https://opensource.org/licenses/MIT).
