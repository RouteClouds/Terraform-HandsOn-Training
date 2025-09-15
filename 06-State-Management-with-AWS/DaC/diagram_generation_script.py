#!/usr/bin/env python3
"""
Professional Diagram Generation Script for Topic 6: State Management with AWS

This script generates 5 high-quality architectural diagrams using Python and the diagrams library.
All diagrams follow AWS brand guidelines and are optimized for 300 DPI resolution.

Author: AWS Terraform Training Team
Version: 2.0
Date: January 2025
"""

import os
import sys
from pathlib import Path

# Import required libraries
try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.aws.compute import EC2, AutoScaling
    from diagrams.aws.database import RDS, DynamodbTable
    from diagrams.aws.network import VPC, PrivateSubnet, PublicSubnet, NATGateway, InternetGateway
    from diagrams.aws.security import IAM, SecretsManager, KMS
    from diagrams.generic.network import Firewall as SecurityGroup
    from diagrams.aws.storage import S3
    from diagrams.aws.management import Cloudwatch as CloudWatch, Cloudtrail as CloudTrail, Organizations
    from diagrams.aws.integration import SNS
    from diagrams.onprem.iac import Terraform
    from diagrams.programming.language import Python
    from diagrams.generic.blank import Blank
    from diagrams.generic.database import SQL
    from diagrams.generic.network import Firewall
    from diagrams.generic.storage import Storage
    from diagrams.onprem.vcs import Git
    from diagrams.onprem.ci import Jenkins
    from diagrams.onprem.client import Users as LocalUsers
    from diagrams.onprem.monitoring import Grafana
except ImportError as e:
    print(f"❌ Error importing diagram libraries: {e}")
    print("Please install required dependencies: pip install -r requirements.txt")
    sys.exit(1)

# AWS Brand Colors (Official AWS Color Palette)
COLORS = {
    'primary': '#FF9900',      # AWS Orange
    'secondary': '#232F3E',    # AWS Dark Blue
    'accent': '#146EB4',       # AWS Blue
    'success': '#7AA116',      # AWS Green
    'warning': '#FF9900',      # AWS Orange
    'background': '#F2F3F3',   # Light Gray
    'text': '#232F3E'          # Dark Blue
}

# Configuration for high-quality output
DIAGRAM_CONFIG = {
    'direction': 'TB',  # Top to Bottom
    'graph_attr': {
        'fontsize': '16',
        'fontname': 'Arial',
        'bgcolor': COLORS['background'],
        'pad': '1.0',
        'nodesep': '1.0',
        'ranksep': '1.5',
        'dpi': '300'  # High resolution for professional quality
    },
    'node_attr': {
        'fontsize': '12',
        'fontname': 'Arial',
        'style': 'rounded,filled',
        'fillcolor': 'white',
        'color': COLORS['secondary']
    },
    'edge_attr': {
        'fontsize': '10',
        'fontname': 'Arial',
        'color': COLORS['accent']
    }
}

def ensure_output_directory():
    """Create output directory if it doesn't exist"""
    output_dir = Path("generated_diagrams")
    output_dir.mkdir(exist_ok=True)
    return output_dir

def create_state_backend_architecture():
    """
    Figure 6.1: Terraform State Backend Architecture with AWS S3 and DynamoDB
    
    This diagram demonstrates enterprise-grade state backend architecture
    with security, versioning, and high availability patterns.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 6.1: Terraform State Backend Architecture",
        filename=str(output_dir / "figure_6_1_state_backend_architecture"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        # Terraform Client Layer
        with Cluster("Terraform Client Layer"):
            # Development Team
            with Cluster("Development Team"):
                developer_1 = LocalUsers("Developer 1")
                developer_2 = LocalUsers("Developer 2")
                developer_3 = LocalUsers("Developer 3")
                
            # CI/CD Systems
            with Cluster("CI/CD Systems"):
                jenkins_pipeline = Jenkins("Jenkins Pipeline")
                github_actions = Storage("GitHub Actions")
                gitlab_ci = Storage("GitLab CI")
                
            # Terraform Operations
            with Cluster("Terraform Operations"):
                terraform_init = Terraform("terraform init")
                terraform_plan = Terraform("terraform plan")
                terraform_apply = Terraform("terraform apply")
        
        # AWS Backend Services Layer
        with Cluster("AWS Backend Services Layer"):
            # S3 State Storage
            with Cluster("S3 State Storage"):
                state_bucket = S3("State Bucket")
                versioning = Storage("Versioning Enabled")
                encryption = KMS("Server-Side Encryption")
                lifecycle_policy = Storage("Lifecycle Policy")
                
            # DynamoDB State Locking
            with Cluster("DynamoDB State Locking"):
                lock_table = DynamodbTable("State Lock Table")
                point_in_time_recovery = Storage("Point-in-Time Recovery")
                backup_vault = Storage("Backup Vault")
                
            # Security Layer
            with Cluster("Security Layer"):
                iam_roles = IAM("IAM Roles")
                bucket_policy = Storage("Bucket Policy")
                kms_key = KMS("KMS Key")
                access_logging = CloudTrail("Access Logging")
        
        # Monitoring and Compliance Layer
        with Cluster("Monitoring and Compliance Layer"):
            # Monitoring Services
            with Cluster("Monitoring Services"):
                cloudwatch_metrics = CloudWatch("CloudWatch Metrics")
                cloudwatch_alarms = Storage("CloudWatch Alarms")
                sns_notifications = SNS("SNS Notifications")
                
            # Audit and Compliance
            with Cluster("Audit and Compliance"):
                cloudtrail_logs = CloudTrail("CloudTrail Logs")
                config_rules = Storage("AWS Config Rules")
                compliance_dashboard = Grafana("Compliance Dashboard")
        
        # Infrastructure Layer
        with Cluster("Infrastructure Layer"):
            # Network Infrastructure
            with Cluster("Network Infrastructure"):
                vpc = VPC("VPC")
                private_subnets = PrivateSubnet("Private Subnets")
                public_subnets = PublicSubnet("Public Subnets")
                
            # Compute Infrastructure
            with Cluster("Compute Infrastructure"):
                ec2_instances = EC2("EC2 Instances")
                auto_scaling_groups = AutoScaling("Auto Scaling Groups")
                
            # Data Infrastructure
            with Cluster("Data Infrastructure"):
                rds_databases = RDS("RDS Databases")
                additional_s3 = S3("Application S3 Buckets")
        
        # State Operations Flow
        # Client to Backend
        [developer_1, developer_2, developer_3] >> Edge(label="state operations", color=COLORS['primary']) >> terraform_init
        [jenkins_pipeline, github_actions, gitlab_ci] >> Edge(label="automated operations", color=COLORS['accent']) >> terraform_plan
        
        # Terraform to AWS Services
        terraform_init >> Edge(label="backend config", color=COLORS['success']) >> state_bucket
        terraform_plan >> Edge(label="state lock", color=COLORS['warning']) >> lock_table
        terraform_apply >> Edge(label="state update", color=COLORS['primary']) >> state_bucket
        
        # Security Integration
        state_bucket >> Edge(label="encrypts", color=COLORS['secondary']) >> encryption
        lock_table >> Edge(label="secures", color=COLORS['secondary']) >> iam_roles
        kms_key >> Edge(label="protects", color=COLORS['warning']) >> encryption
        
        # Monitoring Integration
        state_bucket >> Edge(label="metrics", color=COLORS['success']) >> cloudwatch_metrics
        lock_table >> Edge(label="monitoring", color=COLORS['success']) >> cloudwatch_metrics
        cloudwatch_metrics >> cloudwatch_alarms >> sns_notifications
        
        # Audit Integration
        [state_bucket, lock_table, iam_roles] >> cloudtrail_logs
        cloudtrail_logs >> compliance_dashboard
        
        # Infrastructure Management
        terraform_apply >> Edge(label="manages", color=COLORS['primary']) >> [vpc, ec2_instances, rds_databases]
        
        # Backup and Recovery
        state_bucket >> versioning >> lifecycle_policy
        lock_table >> point_in_time_recovery >> backup_vault

def create_state_locking_workflow():
    """
    Figure 6.2: State Locking Workflow and Conflict Resolution
    
    This diagram shows the detailed state locking mechanism with DynamoDB
    and conflict resolution patterns for team collaboration.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 6.2: State Locking Workflow and Conflict Resolution",
        filename=str(output_dir / "figure_6_2_state_locking_workflow"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        # Concurrent Operations
        with Cluster("Concurrent Terraform Operations"):
            # Team Member Operations
            with Cluster("Team Member A"):
                user_a = LocalUsers("Developer A")
                terraform_a = Terraform("terraform apply")
                
            with Cluster("Team Member B"):
                user_b = LocalUsers("Developer B")
                terraform_b = Terraform("terraform plan")
                
            with Cluster("CI/CD Pipeline"):
                ci_system = Jenkins("CI/CD System")
                automated_apply = Terraform("Automated Apply")
        
        # State Locking Mechanism
        with Cluster("State Locking Mechanism"):
            # Lock Acquisition
            with Cluster("Lock Acquisition Process"):
                lock_request = Storage("Lock Request")
                lock_validation = Storage("Lock Validation")
                lock_acquisition = Storage("Lock Acquisition")
                
            # DynamoDB Lock Table
            with Cluster("DynamoDB Lock Table"):
                lock_table = DynamodbTable("terraform-state-locks")
                lock_record = Storage("Lock Record")
                lock_metadata = Storage("Lock Metadata")
                
            # Lock Management
            with Cluster("Lock Management"):
                lock_timeout = Storage("Lock Timeout (15 min)")
                lock_renewal = Storage("Lock Renewal")
                lock_release = Storage("Lock Release")
        
        # Conflict Resolution
        with Cluster("Conflict Resolution"):
            # Conflict Detection
            with Cluster("Conflict Detection"):
                concurrent_access = Storage("Concurrent Access Detected")
                lock_conflict = Storage("Lock Conflict")
                queue_management = Storage("Queue Management")
                
            # Resolution Strategies
            with Cluster("Resolution Strategies"):
                wait_and_retry = Storage("Wait and Retry")
                force_unlock = Storage("Force Unlock (Admin)")
                operation_cancellation = Storage("Operation Cancellation")
                
            # Notification System
            with Cluster("Notification System"):
                conflict_alerts = SNS("Conflict Alerts")
                team_notifications = Storage("Team Notifications")
                admin_escalation = Storage("Admin Escalation")
        
        # Monitoring and Logging
        with Cluster("Monitoring and Logging"):
            # Lock Monitoring
            with Cluster("Lock Monitoring"):
                lock_metrics = CloudWatch("Lock Metrics")
                lock_duration = Storage("Lock Duration")
                lock_failures = Storage("Lock Failures")
                
            # Audit Logging
            with Cluster("Audit Logging"):
                lock_audit = CloudTrail("Lock Audit Trail")
                operation_logs = Storage("Operation Logs")
                security_logs = Storage("Security Logs")
        
        # State Operations
        with Cluster("State Operations"):
            # Protected Operations
            with Cluster("Protected Operations"):
                state_read = Storage("State Read")
                state_write = Storage("State Write")
                state_backup = Storage("State Backup")
                
            # State Storage
            with Cluster("State Storage"):
                s3_state_bucket = S3("State Bucket")
                state_versioning = Storage("State Versioning")
                state_encryption = KMS("State Encryption")
        
        # Workflow Flow
        # Lock Acquisition Flow
        user_a >> terraform_a >> Edge(label="requests lock", color=COLORS['primary']) >> lock_request
        user_b >> terraform_b >> Edge(label="requests lock", color=COLORS['accent']) >> lock_request
        ci_system >> automated_apply >> Edge(label="requests lock", color=COLORS['success']) >> lock_request
        
        # Lock Processing
        lock_request >> Edge(label="validates", color=COLORS['success']) >> lock_validation
        lock_validation >> Edge(label="acquires", color=COLORS['primary']) >> lock_acquisition
        lock_acquisition >> Edge(label="creates", color=COLORS['success']) >> lock_record
        
        # DynamoDB Integration
        lock_record >> Edge(label="stores", color=COLORS['accent']) >> lock_table
        lock_metadata >> Edge(label="tracks", color=COLORS['secondary']) >> lock_table
        
        # Conflict Handling
        lock_request >> Edge(label="detects conflict", color="red") >> concurrent_access
        concurrent_access >> Edge(label="triggers", color="red") >> lock_conflict
        lock_conflict >> Edge(label="manages", color=COLORS['warning']) >> queue_management
        
        # Resolution Flow
        queue_management >> [wait_and_retry, operation_cancellation]
        lock_timeout >> Edge(label="admin action", color=COLORS['warning']) >> force_unlock
        
        # Notification Flow
        lock_conflict >> conflict_alerts >> team_notifications
        lock_timeout >> admin_escalation
        
        # Monitoring Flow
        lock_table >> lock_metrics >> [lock_duration, lock_failures]
        [lock_acquisition, lock_release] >> lock_audit >> operation_logs
        
        # State Operations Flow
        lock_acquisition >> Edge(label="enables", color=COLORS['success']) >> [state_read, state_write]
        state_write >> s3_state_bucket >> state_versioning
        state_backup >> state_encryption

def create_workspace_management_patterns():
    """
    Figure 6.3: Terraform Workspace Management and Environment Isolation

    This diagram demonstrates advanced workspace strategies for environment
    isolation, state organization, and deployment workflows.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 6.3: Terraform Workspace Management and Environment Isolation",
        filename=str(output_dir / "figure_6_3_workspace_management"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Workspace Management Layer
        with Cluster("Workspace Management Layer"):
            # Workspace Operations
            with Cluster("Workspace Operations"):
                workspace_new = Terraform("terraform workspace new")
                workspace_select = Terraform("terraform workspace select")
                workspace_list = Terraform("terraform workspace list")
                workspace_delete = Terraform("terraform workspace delete")

            # Workspace Strategy
            with Cluster("Workspace Strategy"):
                environment_isolation = Storage("Environment Isolation")
                feature_branching = Storage("Feature Branching")
                tenant_isolation = Storage("Tenant Isolation")

        # Environment Workspaces
        with Cluster("Environment Workspaces"):
            # Development Environment
            with Cluster("Development Workspace"):
                dev_workspace = Storage("development")
                dev_state_key = Storage("env:/development/terraform.tfstate")
                dev_variables = Storage("dev.tfvars")
                dev_infrastructure = EC2("Dev Infrastructure")

            # Staging Environment
            with Cluster("Staging Workspace"):
                staging_workspace = Storage("staging")
                staging_state_key = Storage("env:/staging/terraform.tfstate")
                staging_variables = Storage("staging.tfvars")
                staging_infrastructure = AutoScaling("Staging Infrastructure")

            # Production Environment
            with Cluster("Production Workspace"):
                prod_workspace = Storage("production")
                prod_state_key = Storage("env:/production/terraform.tfstate")
                prod_variables = Storage("prod.tfvars")
                prod_infrastructure = Storage("Prod Infrastructure")

        # State Storage Organization
        with Cluster("State Storage Organization"):
            # S3 Bucket Structure
            with Cluster("S3 Bucket Structure"):
                state_bucket = S3("terraform-state-bucket")
                env_prefix = Storage("env:/ prefix")
                workspace_folders = Storage("Workspace Folders")

            # State File Organization
            with Cluster("State File Organization"):
                dev_state_file = Storage("development/terraform.tfstate")
                staging_state_file = Storage("staging/terraform.tfstate")
                prod_state_file = Storage("production/terraform.tfstate")

            # Backup and Versioning
            with Cluster("Backup and Versioning"):
                state_versioning = Storage("S3 Versioning")
                state_backup = Storage("Cross-Region Backup")
                state_lifecycle = Storage("Lifecycle Policies")

        # Access Control and Security
        with Cluster("Access Control and Security"):
            # IAM Roles per Environment
            with Cluster("IAM Roles per Environment"):
                dev_role = IAM("DevRole")
                staging_role = IAM("StagingRole")
                prod_role = IAM("ProdRole")

            # Access Policies
            with Cluster("Access Policies"):
                dev_policy = Storage("Dev Access Policy")
                staging_policy = Storage("Staging Access Policy")
                prod_policy = Storage("Prod Access Policy")

            # Security Controls
            with Cluster("Security Controls"):
                mfa_requirement = Storage("MFA Requirement")
                ip_restrictions = Storage("IP Restrictions")
                time_based_access = Storage("Time-based Access")

        # Deployment Workflows
        with Cluster("Deployment Workflows"):
            # Development Workflow
            with Cluster("Development Workflow"):
                dev_branch = Git("feature/branch")
                dev_pr = Storage("Pull Request")
                dev_deploy = Jenkins("Dev Deploy")

            # Promotion Workflow
            with Cluster("Promotion Workflow"):
                staging_promotion = Storage("Staging Promotion")
                integration_tests = Storage("Integration Tests")
                prod_promotion = Storage("Production Promotion")

            # Rollback Strategy
            with Cluster("Rollback Strategy"):
                state_rollback = Storage("State Rollback")
                infrastructure_rollback = Storage("Infrastructure Rollback")
                emergency_procedures = Storage("Emergency Procedures")

        # Monitoring and Compliance
        with Cluster("Monitoring and Compliance"):
            # Workspace Monitoring
            with Cluster("Workspace Monitoring"):
                workspace_metrics = CloudWatch("Workspace Metrics")
                deployment_tracking = Storage("Deployment Tracking")
                resource_utilization = Storage("Resource Utilization")

            # Compliance and Audit
            with Cluster("Compliance and Audit"):
                workspace_audit = CloudTrail("Workspace Audit")
                compliance_reporting = Storage("Compliance Reporting")
                change_tracking = Storage("Change Tracking")

        # Workspace Flow
        # Workspace Operations
        workspace_new >> [dev_workspace, staging_workspace, prod_workspace]
        workspace_select >> environment_isolation

        # Environment Configuration
        dev_workspace >> Edge(label="configures", color=COLORS['success']) >> dev_state_key
        staging_workspace >> Edge(label="configures", color=COLORS['accent']) >> staging_state_key
        prod_workspace >> Edge(label="configures", color=COLORS['primary']) >> prod_state_key

        # State Storage
        [dev_state_key, staging_state_key, prod_state_key] >> state_bucket
        state_bucket >> workspace_folders >> [dev_state_file, staging_state_file, prod_state_file]

        # Infrastructure Deployment
        dev_state_file >> dev_infrastructure
        staging_state_file >> staging_infrastructure
        prod_state_file >> prod_infrastructure

        # Security Integration
        dev_workspace >> dev_role >> dev_policy
        staging_workspace >> staging_role >> staging_policy
        prod_workspace >> prod_role >> prod_policy

        # Deployment Workflow
        dev_branch >> dev_pr >> dev_deploy >> dev_workspace
        dev_workspace >> staging_promotion >> staging_workspace
        staging_workspace >> integration_tests >> prod_promotion >> prod_workspace

        # Monitoring Integration
        [dev_workspace, staging_workspace, prod_workspace] >> workspace_metrics
        workspace_audit >> compliance_reporting

def create_state_migration_strategies():
    """
    Figure 6.4: State Migration and Backend Transition Strategies

    This diagram shows comprehensive state migration patterns including
    backend transitions, state consolidation, and disaster recovery.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 6.4: State Migration and Backend Transition Strategies",
        filename=str(output_dir / "figure_6_4_state_migration"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Migration Scenarios
        with Cluster("Migration Scenarios"):
            # Source Backends
            with Cluster("Source Backends"):
                local_backend = Storage("Local Backend")
                old_s3_backend = S3("Old S3 Backend")
                terraform_cloud = Storage("Terraform Cloud")

            # Target Backends
            with Cluster("Target Backends"):
                new_s3_backend = S3("New S3 Backend")
                enterprise_backend = Storage("Enterprise Backend")
                multi_region_backend = Storage("Multi-Region Backend")

        # Migration Process
        with Cluster("Migration Process"):
            # Pre-Migration
            with Cluster("Pre-Migration Phase"):
                state_backup = Storage("State Backup")
                migration_planning = Storage("Migration Planning")
                validation_testing = Storage("Validation Testing")

            # Migration Execution
            with Cluster("Migration Execution"):
                backend_reconfiguration = Terraform("Backend Reconfiguration")
                terraform_init_migrate = Terraform("terraform init -migrate-state")
                state_verification = Storage("State Verification")

            # Post-Migration
            with Cluster("Post-Migration Phase"):
                functionality_testing = Storage("Functionality Testing")
                team_notification = Storage("Team Notification")
                documentation_update = Storage("Documentation Update")

        # Migration Tools and Automation
        with Cluster("Migration Tools and Automation"):
            # Migration Scripts
            with Cluster("Migration Scripts"):
                backup_script = Python("Backup Script")
                migration_script = Python("Migration Script")
                validation_script = Python("Validation Script")

            # Automation Framework
            with Cluster("Automation Framework"):
                migration_pipeline = Jenkins("Migration Pipeline")
                rollback_automation = Storage("Rollback Automation")
                notification_system = SNS("Notification System")

        # State Consolidation
        with Cluster("State Consolidation"):
            # Multiple State Files
            with Cluster("Multiple State Files"):
                app_state = Storage("Application State")
                network_state = Storage("Network State")
                security_state = Storage("Security State")

            # Consolidation Process
            with Cluster("Consolidation Process"):
                state_analysis = Storage("State Analysis")
                dependency_mapping = Storage("Dependency Mapping")
                merge_strategy = Storage("Merge Strategy")

            # Consolidated State
            with Cluster("Consolidated State"):
                unified_state = Storage("Unified State")
                modular_organization = Storage("Modular Organization")
                improved_performance = Storage("Improved Performance")

        # Disaster Recovery
        with Cluster("Disaster Recovery"):
            # Backup Strategies
            with Cluster("Backup Strategies"):
                automated_backups = Storage("Automated Backups")
                cross_region_replication = S3("Cross-Region Replication")
                point_in_time_recovery = Storage("Point-in-Time Recovery")

            # Recovery Procedures
            with Cluster("Recovery Procedures"):
                state_restoration = Storage("State Restoration")
                infrastructure_rebuild = Storage("Infrastructure Rebuild")
                data_validation = Storage("Data Validation")

            # Business Continuity
            with Cluster("Business Continuity"):
                rto_objectives = Storage("RTO: 4 hours")
                rpo_objectives = Storage("RPO: 1 hour")
                communication_plan = Storage("Communication Plan")

        # Monitoring and Validation
        with Cluster("Monitoring and Validation"):
            # Migration Monitoring
            with Cluster("Migration Monitoring"):
                migration_metrics = CloudWatch("Migration Metrics")
                progress_tracking = Storage("Progress Tracking")
                error_detection = Storage("Error Detection")

            # Validation Framework
            with Cluster("Validation Framework"):
                state_integrity = Storage("State Integrity")
                resource_consistency = Storage("Resource Consistency")
                performance_validation = Storage("Performance Validation")

        # Migration Flow
        # Source to Target
        local_backend >> Edge(label="migrates to", color=COLORS['primary']) >> new_s3_backend
        old_s3_backend >> Edge(label="upgrades to", color=COLORS['accent']) >> enterprise_backend
        terraform_cloud >> Edge(label="transitions to", color=COLORS['success']) >> multi_region_backend

        # Migration Process Flow
        [local_backend, old_s3_backend, terraform_cloud] >> state_backup
        state_backup >> migration_planning >> validation_testing
        validation_testing >> backend_reconfiguration >> terraform_init_migrate
        terraform_init_migrate >> state_verification >> functionality_testing

        # Automation Integration
        migration_planning >> migration_script >> migration_pipeline
        state_verification >> validation_script >> notification_system

        # Consolidation Flow
        [app_state, network_state, security_state] >> state_analysis
        state_analysis >> dependency_mapping >> merge_strategy
        merge_strategy >> unified_state >> modular_organization

        # Disaster Recovery Flow
        new_s3_backend >> automated_backups >> cross_region_replication
        point_in_time_recovery >> state_restoration >> infrastructure_rebuild

        # Monitoring Integration
        terraform_init_migrate >> migration_metrics >> progress_tracking
        state_verification >> [state_integrity, resource_consistency]

def create_enterprise_state_governance():
    """
    Figure 6.5: Enterprise State Governance and Compliance Framework

    This diagram demonstrates comprehensive governance patterns for enterprise
    state management including compliance, audit, and operational excellence.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 6.5: Enterprise State Governance and Compliance",
        filename=str(output_dir / "figure_6_5_enterprise_governance"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Governance Framework
        with Cluster("Governance Framework"):
            # Policy Management
            with Cluster("Policy Management"):
                state_policies = Storage("State Management Policies")
                access_policies = IAM("Access Control Policies")
                compliance_policies = Storage("Compliance Policies")

            # Organizational Structure
            with Cluster("Organizational Structure"):
                platform_team = LocalUsers("Platform Team")
                development_teams = LocalUsers("Development Teams")
                security_team = LocalUsers("Security Team")
                compliance_team = LocalUsers("Compliance Team")

        # Multi-Account Strategy
        with Cluster("Multi-Account Strategy"):
            # Account Structure
            with Cluster("Account Structure"):
                shared_services_account = Organizations("Shared Services")
                development_account = Organizations("Development")
                staging_account = Organizations("Staging")
                production_account = Organizations("Production")

            # Cross-Account Access
            with Cluster("Cross-Account Access"):
                cross_account_roles = IAM("Cross-Account Roles")
                assume_role_policies = Storage("Assume Role Policies")
                external_id_validation = Storage("External ID Validation")

        # State Security Framework
        with Cluster("State Security Framework"):
            # Encryption Strategy
            with Cluster("Encryption Strategy"):
                encryption_at_rest = KMS("Encryption at Rest")
                encryption_in_transit = Storage("Encryption in Transit")
                key_rotation = Storage("Automatic Key Rotation")

            # Access Control
            with Cluster("Access Control"):
                rbac_implementation = IAM("RBAC Implementation")
                least_privilege = Storage("Least Privilege")
                temporary_access = Storage("Temporary Access")

            # Security Monitoring
            with Cluster("Security Monitoring"):
                security_alerts = SNS("Security Alerts")
                anomaly_detection = Storage("Anomaly Detection")
                threat_intelligence = Storage("Threat Intelligence")

        # Compliance and Audit
        with Cluster("Compliance and Audit"):
            # Compliance Frameworks
            with Cluster("Compliance Frameworks"):
                soc2_compliance = Storage("SOC 2 Compliance")
                hipaa_compliance = Storage("HIPAA Compliance")
                gdpr_compliance = Storage("GDPR Compliance")

            # Audit Trail
            with Cluster("Audit Trail"):
                comprehensive_logging = CloudTrail("Comprehensive Logging")
                audit_reports = Storage("Audit Reports")
                compliance_dashboard = Grafana("Compliance Dashboard")

            # Data Governance
            with Cluster("Data Governance"):
                data_classification = Storage("Data Classification")
                retention_policies = Storage("Retention Policies")
                data_sovereignty = Storage("Data Sovereignty")

        # Operational Excellence
        with Cluster("Operational Excellence"):
            # Automation and Orchestration
            with Cluster("Automation and Orchestration"):
                automated_governance = Jenkins("Automated Governance")
                policy_enforcement = Storage("Policy Enforcement")
                compliance_automation = Storage("Compliance Automation")

            # Monitoring and Alerting
            with Cluster("Monitoring and Alerting"):
                governance_metrics = CloudWatch("Governance Metrics")
                compliance_monitoring = Storage("Compliance Monitoring")
                operational_dashboards = Grafana("Operational Dashboards")

            # Continuous Improvement
            with Cluster("Continuous Improvement"):
                governance_reviews = Storage("Governance Reviews")
                policy_updates = Storage("Policy Updates")
                training_programs = Storage("Training Programs")

        # Risk Management
        with Cluster("Risk Management"):
            # Risk Assessment
            with Cluster("Risk Assessment"):
                risk_identification = Storage("Risk Identification")
                impact_analysis = Storage("Impact Analysis")
                mitigation_strategies = Storage("Mitigation Strategies")

            # Business Continuity
            with Cluster("Business Continuity"):
                disaster_recovery_plan = Storage("Disaster Recovery Plan")
                backup_strategies = Storage("Backup Strategies")
                incident_response = Storage("Incident Response")

        # Governance Flow
        # Policy to Implementation
        state_policies >> Edge(label="enforces", color=COLORS['primary']) >> rbac_implementation
        access_policies >> Edge(label="controls", color=COLORS['warning']) >> cross_account_roles
        compliance_policies >> Edge(label="mandates", color=COLORS['secondary']) >> encryption_at_rest

        # Organizational Flow
        platform_team >> Edge(label="manages", color=COLORS['success']) >> shared_services_account
        development_teams >> Edge(label="uses", color=COLORS['accent']) >> [development_account, staging_account]
        security_team >> Edge(label="monitors", color=COLORS['warning']) >> security_alerts
        compliance_team >> Edge(label="audits", color=COLORS['secondary']) >> comprehensive_logging

        # Security Integration
        encryption_at_rest >> key_rotation
        rbac_implementation >> least_privilege >> temporary_access
        security_alerts >> anomaly_detection >> threat_intelligence

        # Compliance Integration
        [soc2_compliance, hipaa_compliance, gdpr_compliance] >> comprehensive_logging
        comprehensive_logging >> audit_reports >> compliance_dashboard

        # Operational Integration
        policy_enforcement >> automated_governance >> compliance_automation
        governance_metrics >> compliance_monitoring >> operational_dashboards

        # Risk Management Integration
        risk_identification >> impact_analysis >> mitigation_strategies
        disaster_recovery_plan >> backup_strategies >> incident_response

        # Continuous Improvement
        compliance_dashboard >> governance_reviews >> policy_updates >> training_programs

def main():
    """
    Main function to generate all diagrams for Topic 6: State Management with AWS
    """
    print("🎨 Generating Professional State Management Diagrams...")
    print("=" * 80)

    try:
        # Ensure output directory exists
        output_dir = ensure_output_directory()
        print(f"📁 Output directory: {output_dir.absolute()}")

        # Generate all diagrams
        diagrams = [
            ("Figure 6.1: State Backend Architecture", create_state_backend_architecture),
            ("Figure 6.2: State Locking Workflow", create_state_locking_workflow),
            ("Figure 6.3: Workspace Management", create_workspace_management_patterns),
            ("Figure 6.4: State Migration Strategies", create_state_migration_strategies),
            ("Figure 6.5: Enterprise Governance", create_enterprise_state_governance)
        ]

        for diagram_name, diagram_function in diagrams:
            print(f"🔄 Generating {diagram_name}...")
            diagram_function()
            print(f"✅ {diagram_name} completed successfully!")

        print("\n" + "=" * 80)
        print("🎉 All diagrams generated successfully!")
        print(f"📂 Diagrams saved to: {output_dir.absolute()}")
        print("\n📋 Generated Files:")

        # List generated files
        for file in sorted(output_dir.glob("*.png")):
            print(f"   • {file.name}")

        print("\n💡 Integration Notes:")
        print("   • All diagrams are 300 DPI for professional presentations")
        print("   • AWS brand colors and styling applied consistently")
        print("   • Diagrams are referenced in Concept.md and Lab-6.md")
        print("   • Use these diagrams to enhance learning and understanding")

    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        print("Please check your environment and dependencies.")
        sys.exit(1)

if __name__ == "__main__":
    main()
