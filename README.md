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

## 📌 Author

Nebat Nurhussen Taha
