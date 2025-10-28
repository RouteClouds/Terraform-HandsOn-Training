# Terraform Capstone Projects - Comprehensive Generation Prompt

## PROMPT FOR LLM GENERATION

Use this comprehensive prompt to generate complete Terraform capstone projects for the Terraform Associate Certification training program.

---

## GENERATION INSTRUCTIONS

### Context
You are creating comprehensive, production-ready Terraform capstone projects for students who have completed the Terraform Associate Certification training (12 topics). These projects provide hands-on experience with real-world AWS infrastructure scenarios.

### Requirements
Generate **5 complete Terraform capstone projects** following these specifications:

---

## PROJECT 1: MULTI-TIER WEB APPLICATION INFRASTRUCTURE

**Difficulty**: Intermediate | **Duration**: 8-10 hours

### Objective
Design and deploy a complete multi-tier web application infrastructure on AWS using Terraform.

### Components to Create

**1. Documentation (docs/)**
- README.md: Project overview, quick start, architecture summary
- docs/architecture.md: Detailed architecture, component descriptions, design decisions
- docs/theory.md: Terraform concepts (resources, variables, outputs, state management)
- docs/commands.md: Complete Terraform and AWS CLI command reference
- docs/troubleshooting.md: 10+ common issues with solutions
- docs/examples.md: Step-by-step deployment examples
- docs/validation.md: Testing and validation procedures

**2. Terraform Configuration (terraform-manifests/)**
- providers.tf: Terraform 1.13.0+, AWS provider 6.12.0+, S3 backend
- variables.tf: 20+ variables (VPC CIDR, instance types, DB config, etc.)
- terraform.tfvars: Default values
- main.tf: Main resource definitions
- outputs.tf: 15+ outputs (VPC ID, ALB DNS, RDS endpoint, etc.)
- locals.tf: Local values for naming, tags
- data.tf: Data sources (AMIs, AZs, account info)
- vpc.tf: VPC, 6 subnets (3 public, 3 private), IGW, 3 NAT gateways
- compute.tf: Launch template, Auto Scaling Group (2-6 instances)
- alb.tf: Application Load Balancer, target group, listeners
- rds.tf: PostgreSQL Multi-AZ, subnet group, parameter group
- s3.tf: S3 bucket for static assets, bucket policy, encryption
- security.tf: Security groups (ALB, EC2, RDS), IAM roles
- monitoring.tf: CloudWatch alarms, log groups, SNS topics
- route53.tf: Hosted zone, A records for ALB

**3. Diagrams (diagrams/)**
- generate_diagrams.py: Python script using diagrams library
- requirements.txt: diagrams, boto3
- hld.png: High-level architecture
- lld.png: Low-level architecture
- vpc_architecture.png: VPC with subnets, gateways
- network_topology.png: Network layout with routing
- compute_architecture.png: ASG, EC2, ALB
- database_architecture.png: RDS Multi-AZ setup
- cdn_architecture.png: CloudFront distribution
- security_groups.png: Security group rules
- deployment_flow.png: Deployment workflow
- resource_dependencies.png: Resource dependency graph

**4. Scripts (scripts/)**
- deploy.sh: Full deployment automation with validation
- validate.sh: Resource verification and health checks
- cleanup.sh: Safe resource cleanup with confirmation

**5. Automation**
- Makefile: Targets for init, validate, plan, apply, destroy, clean

### Key Learning Points
- VPC design with public/private subnets
- Auto Scaling Groups and launch templates
- Application Load Balancer configuration
- RDS Multi-AZ deployment
- S3 bucket policies and encryption
- Security groups and IAM roles
- CloudWatch monitoring
- Resource dependencies
- Remote state management

---

## PROJECT 2: MODULAR INFRASTRUCTURE WITH TERRAFORM MODULES

**Difficulty**: Intermediate-Advanced | **Duration**: 10-12 hours

### Objective
Create a library of reusable Terraform modules and compose them into complete infrastructure.

### Components to Create

**1. Documentation (docs/)**
- Same structure as Project 1
- docs/theory.md: Focus on module development, composition, versioning

**2. Modules (modules/)**

Create 8 reusable modules, each with:
- main.tf: Resource definitions
- variables.tf: Input variables with validation
- outputs.tf: Output values
- README.md: Module documentation with examples
- versions.tf: Version constraints

**Module List:**
- **vpc/**: Configurable VPC with subnets, gateways, route tables
- **compute/**: EC2 instances, ASG, launch templates
- **database/**: RDS with configurable engine (postgres, mysql)
- **load-balancer/**: ALB/NLB with target groups
- **storage/**: S3 buckets with policies and encryption
- **monitoring/**: CloudWatch dashboards, alarms, log groups
- **security/**: Security groups, IAM roles and policies
- **dns/**: Route53 zones and records

**3. Root Module (terraform-manifests/)**
- providers.tf: Provider configuration
- variables.tf: Root module variables
- main.tf: Module composition (call all 8 modules)
- outputs.tf: Aggregate outputs from modules
- terraform.tfvars: Values for all modules

**4. Diagrams (diagrams/)**
- module_architecture.png: Module structure
- module_dependencies.png: Inter-module dependencies
- module_composition.png: How modules compose
- vpc_module_design.png: VPC module internals
- compute_module_design.png: Compute module internals
- database_module_design.png: Database module internals
- module_registry.png: Module versioning strategy
- testing_strategy.png: Module testing approach
- Plus: hld.png, lld.png

**5. Testing**
- tests/: Module unit tests
- examples/: Usage examples for each module

### Key Learning Points
- Module design principles
- Input variables and outputs
- Module composition
- Module versioning
- DRY principles
- Module testing
- Private module registry
- Module best practices

---

## PROJECT 3: MULTI-ENVIRONMENT INFRASTRUCTURE PIPELINE

**Difficulty**: Advanced | **Duration**: 10-12 hours

### Objective
Implement multi-environment infrastructure with proper state isolation and CI/CD integration.

### Components to Create

**1. Documentation (docs/)**
- Same structure as Project 1
- docs/theory.md: Focus on workspaces, state management, CI/CD

**2. Terraform Configuration (terraform-manifests/)**
- providers.tf: S3 backend with workspace-specific state keys
- variables.tf: Environment-agnostic variables
- dev.tfvars: Development environment values (1 AZ, t3.micro)
- staging.tfvars: Staging environment values (2 AZs, t3.small)
- prod.tfvars: Production environment values (3 AZs, t3.medium)
- main.tf: Environment-aware resource definitions
- Use conditional expressions for environment differences

**3. State Management**
- S3 bucket configuration with versioning and encryption
- DynamoDB table for state locking
- Workspace strategy documentation
- State backup automation scripts

**4. CI/CD Pipeline (.github/workflows/)**
- terraform.yml: GitHub Actions workflow
  * Trigger on push/PR
  * Jobs: fmt, validate, plan, apply
  * Environment-specific jobs (dev auto-deploy, staging/prod manual approval)
  * Terraform plan output as PR comment
  * State drift detection
  * Notification on success/failure

**5. Diagrams (diagrams/)**
- multi_environment_architecture.png: All 3 environments
- state_isolation.png: State isolation strategy
- cicd_pipeline.png: CI/CD workflow
- workspace_strategy.png: Workspace usage
- state_backend.png: S3 + DynamoDB setup
- deployment_workflow.png: Deployment process
- approval_gates.png: Approval workflow
- drift_detection.png: Drift detection process
- Plus: hld.png, lld.png

### Key Learning Points
- Terraform workspaces
- Remote state backend
- State locking
- State encryption
- Environment-specific configurations
- CI/CD integration
- Approval workflows
- Drift detection

---

## PROJECT 4: INFRASTRUCTURE MIGRATION AND IMPORT

**Difficulty**: Advanced | **Duration**: 10-12 hours

### Objective
Import existing AWS infrastructure into Terraform and implement disaster recovery.

### Components to Create

**1. Documentation (docs/)**
- Same structure as Project 1
- docs/theory.md: Focus on import, state manipulation, migration strategies
- docs/migration-guide.md: Step-by-step migration procedures

**2. Pre-existing Resources**
- Document manually-created AWS resources to import:
  * VPC with subnets
  * EC2 instances
  * RDS database
  * S3 buckets
  * IAM roles

**3. Import Scripts (scripts/)**
- import-vpc.sh: Import VPC and networking
- import-compute.sh: Import EC2 instances
- import-database.sh: Import RDS with zero downtime
- import-storage.sh: Import S3 buckets
- import-iam.sh: Import IAM resources
- generate-config.sh: Generate Terraform config from state

**4. Terraform Configuration (terraform-manifests/)**
- Start with empty configuration
- Progressively add resources as they're imported
- Refactor imported resources into modules
- Document state manipulation commands used

**5. State Manipulation Examples**
- terraform state list
- terraform state show
- terraform state mv (refactoring examples)
- terraform state rm (removing resources)
- terraform import (all resource types)

**6. Disaster Recovery**
- Backup automation scripts
- Restore procedures
- State backup to S3
- Configuration backup to Git

**7. Diagrams (diagrams/)**
- migration_strategy.png: Overall migration approach
- import_workflow.png: Import process flow
- state_manipulation.png: State manipulation examples
- zero_downtime_migration.png: Zero-downtime strategy
- disaster_recovery.png: DR architecture
- backup_strategy.png: Backup procedures
- rollback_procedures.png: Rollback process
- refactoring_approach.png: Refactoring strategy
- Plus: hld.png, lld.png

### Key Learning Points
- terraform import command
- Resource addressing
- State manipulation
- Zero-downtime migration
- Disaster recovery
- Backup and restore
- Configuration generation
- Refactoring strategies

---

## PROJECT 5: ENTERPRISE-GRADE SECURE INFRASTRUCTURE

**Difficulty**: Advanced | **Duration**: 12-15 hours

### Objective
Implement comprehensive enterprise security with testing and troubleshooting.

### Components to Create

**1. Documentation (docs/)**
- Same structure as Project 1
- docs/theory.md: Focus on security, testing, troubleshooting
- docs/security-guide.md: Comprehensive security documentation
- docs/compliance.md: CIS benchmark compliance

**2. Terraform Configuration (terraform-manifests/)**
- providers.tf: Provider with enhanced security
- variables.tf: Sensitive variables properly marked
- secrets.tf: AWS Secrets Manager integration
- kms.tf: KMS keys for encryption
- vpc.tf: Private subnets only, VPC endpoints
- security.tf: Security groups (least privilege), NACLs
- iam.tf: IAM roles and policies (least privilege)
- cloudtrail.tf: CloudTrail with encryption
- cloudwatch.tf: CloudWatch Logs, alarms
- guardduty.tf: GuardDuty threat detection
- config.tf: AWS Config rules for compliance
- waf.tf: WAF rules for application protection

**3. Security Implementation**
- Secrets Manager for all sensitive data
- KMS encryption for all data at rest
- VPC endpoints for AWS services (no internet)
- Security groups with minimal access
- IAM roles with least privilege
- CloudTrail for audit logging
- GuardDuty for threat detection
- AWS Config for compliance
- Systems Manager Session Manager (no SSH)

**4. Testing (tests/)**
- Unit tests for individual resources
- Integration tests for multi-resource scenarios
- Security tests using tfsec
- Compliance tests using checkov
- Cost tests using infracost
- Custom validation tests

**5. Troubleshooting Scenarios (docs/troubleshooting.md)**
Document and solve 10+ scenarios:
- State lock conflicts
- Resource dependency cycles
- Provider authentication issues
- Resource creation failures
- State drift
- Performance issues
- Cost optimization
- Security vulnerabilities

**6. Diagrams (diagrams/)**
- security_architecture.png: Complete security design
- network_security.png: Network security layers
- iam_architecture.png: IAM structure
- encryption_strategy.png: Encryption at rest/transit
- secrets_management.png: Secrets Manager integration
- compliance_framework.png: Compliance architecture
- monitoring_architecture.png: Monitoring setup
- troubleshooting_workflow.png: Troubleshooting process
- Plus: hld.png, lld.png

### Key Learning Points
- Secrets management
- KMS encryption
- VPC security
- IAM least privilege
- CloudTrail logging
- Compliance validation
- Security testing
- Troubleshooting techniques

---

## GENERAL REQUIREMENTS FOR ALL PROJECTS

### Documentation Standards
- Professional formatting with proper markdown
- Clear section headers and navigation
- Code examples with syntax highlighting
- Embedded diagrams
- Links to official documentation
- Comprehensive and beginner-friendly

### Terraform Code Standards
- Terraform 1.13.0+ compatibility
- AWS Provider 6.12.0+ compatibility
- Proper formatting (terraform fmt)
- Comprehensive comments
- Meaningful resource names
- Consistent naming conventions
- All resources tagged
- Production-ready quality

### Diagram Standards
- Use Python diagrams library
- Professional appearance
- Proper AWS icons
- Clear labeling
- Logical grouping
- High resolution (300+ DPI)
- 10+ diagrams per project

### Script Standards
- Bash scripts with error handling
- Progress indicators
- Validation checks
- Confirmation prompts
- Detailed logging
- Executable permissions

### Testing Standards
- All configurations validated
- All scripts tested
- All commands verified
- All resources created successfully
- All cleanup procedures work

---

## OUTPUT STRUCTURE

For each project, create:

```
Project-N-[Name]/
├── README.md
├── Makefile
├── PROJECT-N-COMPLETION-SUMMARY.md
├── docs/
│   ├── architecture.md
│   ├── theory.md
│   ├── commands.md
│   ├── troubleshooting.md
│   ├── examples.md
│   └── validation.md
├── diagrams/
│   ├── generate_diagrams.py
│   ├── requirements.txt
│   └── [10+ PNG files]
├── terraform-manifests/
│   ├── providers.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── main.tf
│   ├── outputs.tf
│   └── [resource-specific .tf files]
├── modules/ (Project 2)
│   └── [8 modules]
├── scripts/
│   ├── deploy.sh
│   ├── validate.sh
│   └── cleanup.sh
└── .github/workflows/ (Project 3)
    └── terraform.yml
```

---

## SUCCESS CRITERIA

Each project must:
- [ ] Include all required documentation
- [ ] Include all required Terraform files
- [ ] Generate all required diagrams
- [ ] Include all required scripts
- [ ] Pass terraform validate
- [ ] Pass terraform plan
- [ ] Successfully deploy to AWS
- [ ] Pass all validation tests
- [ ] Successfully cleanup all resources
- [ ] Be production-ready quality

---

**Use this prompt to generate complete, production-ready Terraform capstone projects.**

