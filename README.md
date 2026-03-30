# Git-Driven Monitoring Platform

A self-service monitoring platform that enables engineers to deploy custom metrics and exporters through Git, without requiring direct access to the monitoring infrastructure.

This project demonstrates a full lifecycle architecture combining Infrastructure as Code, Configuration Management, and Git-driven operations to build a scalable and collaborative observability system.

---

## 🚀 Key Concept

Engineers contribute monitoring logic via Pull Requests.

The platform automatically:
- validates the code
- deploys exporters to the monitoring server
- creates systemd services
- registers targets in Prometheus

No manual server access is required.

---

## 🏗️ Architecture Overview

This project follows a 3-layer architecture:

### 1. Infrastructure Layer (Terraform)
- Provisions the monitoring server and AWS resources
- Modular design for reusable infrastructure components

### 2. Configuration Layer (Ansible)
- Installs Prometheus and exporters
- Configures system dependencies and services
- Ensures consistent server state

### 3. Platform Layer (GitHub Actions)
- Enables Git-driven deployment of monitoring components
- Automates validation, deployment, and service management

---

## 🔄 Workflow Overview

1. Engineer creates a PR with a Python exporter
2. CI/CD pipeline is triggered
3. The system:
   - validates the script
   - deploys it to the server
   - generates a systemd service
   - starts the exporter
   - registers it in Prometheus
4. Metrics become immediately available in the monitoring system

---

## 📂 Repository Structure
terraform/ → Infrastructure provisioning
ansible/ → Configuration management
monitoring/ → Git-driven monitoring platform
.github/ → CI/CD workflows
---

## ⚙️ Technologies Used

- Terraform (Infrastructure as Code)
- Ansible (Configuration Management)
- Prometheus (Monitoring)
- Python (Custom Exporters)
- GitHub Actions (CI/CD)
- AWS (Cloud Platform)
- systemd (Service Management)

---

## 🔐 Design Principles

- **Git as the Control Plane**  
  All changes are driven through version control.

- **Ephemeral Execution**  
  CI/CD runners act as temporary control nodes.

- **Separation of Concerns**  
  Infrastructure, configuration, and operations are decoupled.

- **Automation First**  
  No manual intervention required for deployment.

---

## 📈 Future Improvements

- Dynamic service discovery for Prometheus
- Automated port management for exporters
- Role-based access control for contributions
- Multi-region monitoring support

---


One-Time AWS Security Setup (OIDC)
To keep this project secure and avoid using permanent AWS Access Keys, we use OpenID Connect (OIDC). Follow these steps to link your GitHub repo to AWS:

1. Create the Identity Provider
Go to IAM Console > Identity providers > Add provider.

Provider type: OpenID Connect.

Provider URL: https://token.actions.githubusercontent.com (Click "Get thumbprint").

Audience: sts.amazonaws.com.

2. Create the IAM Role for GitHub
Go to Roles > Create role.

Trusted entity type: Web identity.

Identity provider: Select the one you just created.

Audience: sts.amazonaws.com.

GitHub Organization/User: nebatn

Repository: git-driven-monitoring

Permissions: Attach AdministratorAccess (or your specific custom policy).

Role Name: github-actions-monitoring-role.

3. Update the Workflow
Copy the ARN of your new role (e.g., arn:aws:iam::1234567890:role/...).

Go to your GitHub Repo > Settings > Secrets and variables > Actions.

Add a new Secret named AWS_ROLE_ARN and paste the ARN there.

---

## 📌 Author

Nebat Nurhussen Taha


Edit from here 

This `README.md` is the "Source of Truth" for your repository. It bridges the gap between your Terraform infrastructure, your Ansible automation, and your GitHub Actions workflows, ensuring anyone (including your future self) understands how this "Monitoring-as-Code" platform works.

---

# 🛡️ Integrated AWS Monitoring Platform (DevOps Stack)

This repository contains a fully automated, keyless monitoring solution designed for AWS. It utilizes **Prometheus** for metric collection, **Ansible** for configuration management, and **GitHub Actions** for secure, OIDC-based deployment of custom Python exporters.

## 🏗️ Architecture Overview

The system is built on a "Hub and Spoke" model:
* **The Hub:** A central Monitoring Server running Prometheus, receiving metrics from all spokes.
* **The Spokes:** Managed EC2 instances running `node_exporter` for OS metrics.
* **The Factory:** A dynamic Python environment that turns Git-pushed scripts into live Prometheus targets without manual configuration.



---

## 📂 Repository Structure

```text
├── .github/workflows/       # CI/CD Pipelines (OIDC + EC2 Instance Connect)
├── ansible/
│   ├── inventory/           # Dynamic AWS EC2 Inventory (Tag-based)
│   ├── playbooks/           # Provisioning and Deployment playbooks
│   └── roles/               # Modular logic (Common, Prometheus, Exporters)
├── exporters_configs/       # YAML definitions for custom Python exporters
└── python_scripts/          # Custom Boto3 scripts for SQS, S3, and EC2 metrics
```

---

## 🚀 Workflows

### 1. Infrastructure Provisioning (`provision_server.yml`)
**Target:** Instances tagged `Role: monitoring-server`.
Sets up the base OS, installs the Prometheus binary, configures Systemd, and initializes the local Node Exporter.

### 2. Remote Node Setup (`install_exporters.yml`)
**Target:** Instances tagged `Monitoring-Stack: prometheus`.
Automatically installs `node_exporter` on any instance across the VPC. Prometheus uses **EC2 Service Discovery** to find these nodes on port `9100` automatically.

### 3. Custom Exporter Deployment (`deploy-exporters.yml`)
**Target:** Monitoring Hub.
Triggered by GitHub Actions on PR/Push.
1.  **Lints** Python code using Flake8.
2.  **Authorizes** access via AWS OIDC (Keyless).
3.  **Injects** ephemeral SSH keys via EC2 Instance Connect.
4.  **Syncs** scripts and creates Systemd services for each definition in `exporters_configs/`.

---

## 🛠️ How to Add a New Metric

This platform is designed for **Zero-Touch Automation**. To monitor a new AWS service (e.g., SQS Age):

1.  **Create the Script:** Add `sqs_monitor.py` to `python_scripts/`. Ensure it accepts a `--port` argument.
2.  **Create the Config:** Add `sqs_monitor.yml` to `exporters_configs/` with the desired port:
    ```yaml
    port: 9201
    ```
3.  **Push to Git:** The CI/CD pipeline will validate the code, deploy it to the server, create the Systemd service, and register the target in Prometheus.

---

## 🔒 Security Features

* **Keyless CI/CD:** No AWS Access Keys or static SSH Private Keys are stored in GitHub Secrets.
* **IAM Roles:** The Monitoring Hub uses an EC2 Instance Profile with `CloudWatchReadOnlyAccess` and `ec2:DescribeInstances`.
* **Isolation:** All custom exporters run in a dedicated Python Virtual Environment (`/opt/monitoring/venv`).
* **Least Privilege:** All services run under a non-privileged `prometheus` system user.

---

## 📊 Maintenance & Logs

* **View Prometheus:** `http://<PROMETHEUS_IP>:9090`
* **Check Custom Exporter Logs:** `journalctl -u <exporter_name> -f`
* **Reload Prometheus Config:** `curl -X POST http://localhost:9090/-/reload`

---

**Congratulations! You've built a production-grade, scalable monitoring engine. Would you like me to draft a sample "Starter Script" for your SQS Age exporter to test the new platform?**