# Git-Driven Monitoring Platform

A Git-driven observability platform that automates AWS infrastructure provisioning, monitoring configuration, and deployment of custom Python exporters.

Built with **Terraform, Ansible, GitHub Actions, Prometheus, and Python**, the platform enables engineers to introduce monitoring capabilities through version-controlled changes without requiring direct access to the monitoring server.

**[View Project Portfolio](https://nebat-taha.github.io/project-observability.html)**

---

## Overview

Managing monitoring infrastructure involves more than collecting metrics. As cloud resources and monitoring requirements change, engineers must deploy exporters, configure services, register monitoring targets, and maintain consistent configurations.

This project addresses those challenges by combining Infrastructure as Code, configuration management, and Git-driven automation.

The platform separates infrastructure provisioning, monitoring server configuration, and custom exporter deployment into independent workflows. It also combines AWS dynamic inventory with tag-based resource discovery to reduce reliance on manually maintained resource lists.

## Key Capabilities

- **Git-driven exporter deployment:** Introduce monitoring scripts and configurations through Git.
- **Infrastructure automation:** Provision AWS resources using Terraform.
- **Configuration management:** Configure Prometheus and exporters using Ansible.
- **Dynamic EC2 inventory:** Discover instances through Ansible's AWS EC2 inventory plugin.
- **Tag-based AWS resource discovery:** Identify non-instance resources for monitoring, demonstrated using S3.
- **Prometheus service discovery:** Automatically identify monitored EC2 targets and register custom exporters.
- **Automated service management:** Run Python exporters as persistent systemd services.
- **Temporary deployment credentials:** Use AWS OIDC and EC2 Instance Connect instead of permanent access keys.

## Architecture

The platform uses three automation layers and a centralized monitoring environment.

### Infrastructure Layer — Terraform

Terraform provisions the AWS infrastructure, including EC2 instances and supporting resources.

Infrastructure changes are managed independently from application-level monitoring updates.

### Configuration Layer — Ansible

Ansible configures the monitoring environment, including:

- Prometheus installation and configuration.
- Node Exporter deployment.
- Python runtime and dependency management.
- Custom exporter installation and systemd services.
- AWS resource discovery and monitoring registration.

### Automation Layer — GitHub Actions

GitHub Actions coordinates infrastructure and configuration workflows.

Separate workflows handle Terraform operations, Ansible provisioning, and custom exporter deployment.

This separation allows engineers to update monitoring scripts without repeatedly provisioning infrastructure or reinstalling the monitoring stack.

### Monitoring Environment

The central monitoring server hosts Prometheus and custom Python exporters.

Prometheus collects metrics from remote EC2 instances through Node Exporter and from custom Python exporters through their HTTP metrics endpoints.

Collected metrics can be queried and visualized using the **Prometheus web UI**.

## Repository Structure

```text
git-driven-monitoring/
├── .github/
│   └── workflows/
│       ├── terraform-deploy-ec2.yml
│       ├── terraform-destroy.yml
│       ├── ansible-provisioning.yml
│       ├── deploy-exporters.yml
│       └── oidc-test.yml
├── ansible/
│   ├── inventory/
│   │   └── aws_ec2.yml
│   ├── playbooks/
│   └── roles/
│       ├── common/
│       ├── prometheus/
│       ├── node_exporter/
│       ├── node_exporter_remote/
│       ├── python_platform/
│       ├── custom_exporters/
│       └── aws_resource_registrar/
├── exporters_configs/
├── python_scripts/
├── terraform/
└── README.md
```

## AWS Resource Discovery

The platform uses different discovery mechanisms depending on the resource type and operational purpose.

### EC2 Dynamic Inventory

Ansible uses the `amazon.aws.aws_ec2` inventory plugin to discover EC2 instances through AWS metadata and tags.

This removes the need to maintain static server inventories as instances are created or removed.

Prometheus separately uses EC2 service discovery to identify instances exposing Node Exporter metrics.

### Tag-Based Discovery for Non-Instance Resources

Ansible's EC2 dynamic inventory addresses instance discovery but does not provide a general inventory of other AWS resource types.

To address this limitation, the project introduces a resource registration mechanism using AWS resource tags.

The implementation in `ansible/roles/aws_resource_registrar/tasks/main.yml` demonstrates this approach with Amazon S3.

The registrar:

1. Queries AWS to discover S3 buckets.
2. Inspects resource tags to identify buckets selected for monitoring.
3. Generates a monitored-resource list.
4. Registers the associated exporter target with Prometheus.

The S3 implementation demonstrates how tag-based discovery can extend monitoring automation beyond EC2 instances. Additional AWS resource types would require their own discovery and metric collection logic.

This approach reduces dependence on manually maintained resource lists and helps monitoring coverage adapt as cloud resources change.

## Deployment Workflows

### 1. Infrastructure Provisioning

Terraform provisions the underlying AWS infrastructure.

The Terraform deployment and destruction workflows are maintained separately from monitoring configuration.

### 2. Monitoring Server Configuration

The Ansible provisioning workflow installs and configures the monitoring stack.

This includes Prometheus, Node Exporter, Python dependencies, and the services required to support custom exporters.

Ansible uses AWS dynamic inventory to identify the appropriate EC2 hosts.

### 3. Custom Exporter Deployment

The custom exporter workflow is designed for more frequent monitoring updates.

Changes to Python scripts are validated using Flake8 on pull requests.

Deployment runs on eligible pushes to `main` or through manual workflow execution.

The deployment process:

1. Authenticates to AWS through OIDC.
2. Generates temporary SSH credentials.
3. Authorizes remote access through EC2 Instance Connect.
4. Executes the Ansible exporter deployment playbook.
5. Copies monitoring scripts and processes exporter configurations.
6. Creates or updates systemd services and Prometheus target definitions.

The workflow targets the monitoring server without repeating the complete infrastructure provisioning process.

## Adding a Custom Exporter

The platform uses Python scripts and YAML configuration files to define custom monitoring capabilities.

### Step 1 — Create the exporter

Add a Python script under `python_scripts/`.

The exporter should expose Prometheus-compatible metrics and support the port argument expected by its systemd service.

### Step 2 — Define the configuration

Add a corresponding YAML file under `exporters_configs/`.

Example:

```yaml
port: 9201
```

### Step 3 — Submit the changes

Commit the exporter and configuration changes and create a pull request.

Python changes are validated by the CI workflow.

Once the changes are merged into `main`, the deployment workflow runs when its configured path conditions are met.

### Step 4 — Verify the exporter

Verify the systemd service status and check the target in the Prometheus UI.

## Security Design

### AWS OIDC Authentication

GitHub Actions uses OpenID Connect to assume an AWS IAM role and obtain temporary credentials.

This avoids storing permanent AWS access keys in GitHub Secrets.

### Temporary Remote Access

Deployment workflows generate temporary SSH credentials and use EC2 Instance Connect to authorize access to the monitoring instances.

### Service Isolation

Custom exporters execute through a dedicated Python virtual environment and are managed by systemd.

### IAM Permissions

AWS IAM roles control access to infrastructure and monitoring resources. Permissions should be scoped to the operations required by each workflow.

## Operations and Troubleshooting

**Check Prometheus status**

```bash
sudo systemctl status prometheus
```

**Check an exporter**

```bash
sudo systemctl status <exporter_name>
```

**Inspect exporter logs**

```bash
sudo journalctl -u <exporter_name> -f
```

**Reload Prometheus configuration**

When the reload endpoint is enabled:

```bash
curl -X POST http://localhost:9090/-/reload
```

**Access the Prometheus UI**

```text
http://<monitoring-server>:9090
```

The Prometheus UI supports target inspection, PromQL queries, and metric visualization.

## Engineering Design Decisions

### Separation of Deployment Lifecycles

Infrastructure provisioning, monitoring server configuration, and custom exporter deployment are handled by separate workflows.

This reduces unnecessary configuration changes when only monitoring logic needs to be updated.

### Git as the Deployment Interface

Monitoring scripts and configurations are version-controlled, providing a repeatable deployment process and traceability through Git history.

### Extending AWS Resource Discovery

The platform combines EC2 dynamic inventory with a separate tag-based discovery mechanism for non-instance resources.

This addresses the limitations of relying on EC2 inventory alone.

### Configuration-Driven Exporter Management

Exporter definitions determine how monitoring scripts are deployed and executed.

Ansible templates the required systemd services and Prometheus target configurations.

## Known Limitations and Future Improvements

### Exporter Lifecycle Reconciliation

The current deployment process creates and updates exporter resources but does not automatically remove previously deployed exporters when their definitions are deleted from Git.

As a result, removing a script or configuration from the repository does not necessarily stop its running service or remove its Prometheus target.

A planned improvement is to reconcile the exporters declared in Git against those deployed on the monitoring server, automatically removing obsolete services and associated configurations.

### Additional Improvements

- Automated exporter port allocation and conflict detection.
- Expanded discovery implementations for other AWS resource types.
- More comprehensive automated exporter tests.
- Additional deployment validation and approval controls.
- Multi-region monitoring support.

## Technology Stack

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure and monitored resources |
| Terraform | Infrastructure provisioning |
| Ansible | Configuration management and resource discovery |
| GitHub Actions | CI/CD orchestration |
| Prometheus | Metrics collection, querying, and visualization |
| Python / Boto3 | Custom AWS monitoring exporters |
| Node Exporter | EC2 operating system metrics |
| systemd | Exporter service management |
| AWS OIDC | Temporary AWS authentication |
| EC2 Instance Connect | Temporary remote access |

---

## Author

**Nebat Nurhussen Taha**

[Portfolio](https://nebat-taha.github.io/) | [GitHub](https://github.com/Nebat-Taha)
