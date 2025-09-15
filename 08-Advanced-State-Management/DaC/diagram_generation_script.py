#!/usr/bin/env python3
"""
Advanced State Management Diagram Generation Script
Topic 8: Advanced State Management with AWS

This script generates 5 professional diagrams for advanced Terraform state management:
1. Enterprise State Architecture Overview
2. Multi-Environment State Strategy
3. State Security and Encryption Patterns
4. State Lifecycle and Operations Flow
5. Disaster Recovery and Backup Strategy

Requirements: diagrams, matplotlib, seaborn
"""

import os
import sys
from pathlib import Path

# Add the parent directory to the path to import common modules
sys.path.append(str(Path(__file__).parent.parent.parent))

try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.aws.storage import S3
    from diagrams.aws.database import Dynamodb
    from diagrams.aws.security import KMS, IAM
    from diagrams.aws.management import Cloudwatch, CloudwatchLogs, Cloudtrail
    from diagrams.aws.compute import EC2
    from diagrams.aws.network import VPC
    from diagrams.aws.general import Users, General
    from diagrams.programming.framework import Terraform
    from diagrams.programming.language import Python
    from diagrams.onprem.vcs import Git
    from diagrams.onprem.ci import Jenkins
    import matplotlib.pyplot as plt
    import seaborn as sns
    import numpy as np
except ImportError as e:
    print(f"Error importing required modules: {e}")
    print("Please install required packages: pip install diagrams matplotlib seaborn")
    sys.exit(1)

# AWS Brand Colors
COLORS = {
    'primary': '#FF9900',      # AWS Orange
    'secondary': '#232F3E',    # AWS Dark Blue
    'accent': '#146EB4',       # AWS Blue
    'success': '#7AA116',      # AWS Green
    'warning': '#FF9900',      # AWS Orange
    'danger': '#D13212',       # AWS Red
    'background': '#F2F3F3',   # Light Gray
    'text': '#232F3E'          # Dark Blue
}

def setup_output_directory():
    """Create output directory for generated diagrams."""
    output_dir = Path(__file__).parent / "generated_diagrams"
    output_dir.mkdir(exist_ok=True)
    return output_dir

def generate_enterprise_state_architecture():
    """Generate Figure 8.1: Enterprise State Architecture Overview."""
    output_dir = setup_output_directory()
    
    with Diagram(
        "Figure 8.1: Enterprise State Architecture Overview",
        filename=str(output_dir / "figure_8_1_enterprise_state_architecture"),
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "16",
            "bgcolor": COLORS['background'],
            "pad": "0.5",
            "splines": "ortho"
        }
    ):
        # Development Teams
        with Cluster("Development Teams"):
            dev_team = Users("Dev Team")
            ops_team = Users("Ops Team")
            security_team = Users("Security Team")
        
        # Terraform Workspaces
        with Cluster("Terraform Workspaces"):
            workspace_dev = Terraform("Development")
            workspace_staging = Terraform("Staging")
            workspace_prod = Terraform("Production")
        
        # State Management Layer
        with Cluster("Enterprise State Management"):
            # Primary Region (us-east-1)
            with Cluster("Primary Region (us-east-1)"):
                state_bucket_primary = S3("State Bucket\n(Primary)")
                lock_table_primary = Dynamodb("Lock Table\n(Primary)")
                kms_key_primary = KMS("KMS Key\n(Primary)")
                
                state_bucket_primary - Edge(label="encrypted", color=COLORS['success']) - kms_key_primary
                state_bucket_primary - Edge(label="locking", color=COLORS['accent']) - lock_table_primary
            
            # Disaster Recovery Region (us-west-2)
            with Cluster("DR Region (us-west-2)"):
                state_bucket_dr = S3("State Bucket\n(DR)")
                lock_table_dr = Dynamodb("Lock Table\n(DR)")
                kms_key_dr = KMS("KMS Key\n(DR)")
                
                state_bucket_dr - Edge(label="encrypted", color=COLORS['success']) - kms_key_dr
                state_bucket_dr - Edge(label="locking", color=COLORS['accent']) - lock_table_dr
        
        # Monitoring and Security
        with Cluster("Monitoring & Security"):
            cloudwatch = Cloudwatch("CloudWatch\nMetrics")
            cloudtrail = Cloudtrail("CloudTrail\nAudit")
            iam_policies = IAM("IAM Policies\nAccess Control")
        
        # AWS Infrastructure
        with Cluster("AWS Infrastructure"):
            vpc_dev = VPC("Dev VPC")
            vpc_staging = VPC("Staging VPC")
            vpc_prod = VPC("Prod VPC")
            
            ec2_dev = EC2("Dev Resources")
            ec2_staging = EC2("Staging Resources")
            ec2_prod = EC2("Prod Resources")
        
        # Connections
        dev_team >> Edge(label="terraform apply", color=COLORS['primary']) >> workspace_dev
        ops_team >> Edge(label="terraform apply", color=COLORS['primary']) >> workspace_staging
        security_team >> Edge(label="terraform apply", color=COLORS['primary']) >> workspace_prod
        
        workspace_dev >> Edge(label="state ops", color=COLORS['accent']) >> state_bucket_primary
        workspace_staging >> Edge(label="state ops", color=COLORS['accent']) >> state_bucket_primary
        workspace_prod >> Edge(label="state ops", color=COLORS['accent']) >> state_bucket_primary
        
        state_bucket_primary >> Edge(label="replication", color=COLORS['warning']) >> state_bucket_dr
        
        workspace_dev >> Edge(label="provisions", color=COLORS['success']) >> vpc_dev >> ec2_dev
        workspace_staging >> Edge(label="provisions", color=COLORS['success']) >> vpc_staging >> ec2_staging
        workspace_prod >> Edge(label="provisions", color=COLORS['success']) >> vpc_prod >> ec2_prod
        
        state_bucket_primary >> Edge(label="monitors", color=COLORS['text']) >> cloudwatch
        state_bucket_primary >> Edge(label="audits", color=COLORS['text']) >> cloudtrail
        iam_policies >> Edge(label="controls", color=COLORS['danger']) >> state_bucket_primary

def generate_multi_environment_strategy():
    """Generate Figure 8.2: Multi-Environment State Strategy."""
    output_dir = setup_output_directory()
    
    with Diagram(
        "Figure 8.2: Multi-Environment State Strategy",
        filename=str(output_dir / "figure_8_2_multi_environment_strategy"),
        show=False,
        direction="LR",
        graph_attr={
            "fontsize": "16",
            "bgcolor": COLORS['background'],
            "pad": "0.5",
            "splines": "ortho"
        }
    ):
        # Environment Isolation Strategy
        with Cluster("Development Environment"):
            dev_workspace = Terraform("Dev Workspace")
            dev_state = S3("dev/terraform.tfstate")
            dev_lock = Dynamodb("dev-locks")
            dev_kms = KMS("dev-kms-key")
            
            dev_workspace >> dev_state
            dev_state - dev_lock
            dev_state - dev_kms
        
        with Cluster("Staging Environment"):
            staging_workspace = Terraform("Staging Workspace")
            staging_state = S3("staging/terraform.tfstate")
            staging_lock = Dynamodb("staging-locks")
            staging_kms = KMS("staging-kms-key")
            
            staging_workspace >> staging_state
            staging_state - staging_lock
            staging_state - staging_kms
        
        with Cluster("Production Environment"):
            prod_workspace = Terraform("Prod Workspace")
            prod_state = S3("prod/terraform.tfstate")
            prod_lock = Dynamodb("prod-locks")
            prod_kms = KMS("prod-kms-key")
            
            prod_workspace >> prod_state
            prod_state - prod_lock
            prod_state - prod_kms
        
        # Access Control
        with Cluster("Access Control Matrix"):
            dev_team = Users("Dev Team")
            qa_team = Users("QA Team")
            ops_team = Users("Ops Team")
            
            dev_team >> Edge(label="full access", color=COLORS['success']) >> dev_workspace
            dev_team >> Edge(label="read only", color=COLORS['warning']) >> staging_workspace
            
            qa_team >> Edge(label="read only", color=COLORS['warning']) >> dev_workspace
            qa_team >> Edge(label="full access", color=COLORS['success']) >> staging_workspace
            qa_team >> Edge(label="read only", color=COLORS['warning']) >> prod_workspace
            
            ops_team >> Edge(label="emergency", color=COLORS['danger']) >> dev_workspace
            ops_team >> Edge(label="full access", color=COLORS['success']) >> staging_workspace
            ops_team >> Edge(label="full access", color=COLORS['success']) >> prod_workspace
        
        # State Promotion Flow
        with Cluster("State Promotion Flow"):
            git_dev = Git("Dev Branch")
            git_staging = Git("Staging Branch")
            git_prod = Git("Main Branch")
            
            git_dev >> Edge(label="merge", color=COLORS['primary']) >> git_staging
            git_staging >> Edge(label="merge", color=COLORS['primary']) >> git_prod
            
            git_dev >> dev_workspace
            git_staging >> staging_workspace
            git_prod >> prod_workspace

def generate_state_security_patterns():
    """Generate Figure 8.3: State Security and Encryption Patterns."""
    output_dir = setup_output_directory()
    
    with Diagram(
        "Figure 8.3: State Security and Encryption Patterns",
        filename=str(output_dir / "figure_8_3_state_security_patterns"),
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "16",
            "bgcolor": COLORS['background'],
            "pad": "0.5",
            "splines": "ortho"
        }
    ):
        # Security Layers
        with Cluster("Multi-Layer Security Architecture"):
            # Network Security
            with Cluster("Network Security"):
                vpc_endpoints = VPC("VPC Endpoints")
                private_subnets = General("Private Subnets")
                
                vpc_endpoints - private_subnets
            
            # Identity and Access Management
            with Cluster("Identity & Access Management"):
                iam_roles = IAM("IAM Roles")
                iam_policies = IAM("IAM Policies")
                assume_roles = IAM("Cross-Account\nAssume Roles")
                
                iam_roles - iam_policies
                iam_roles - assume_roles
            
            # Encryption at Rest and Transit
            with Cluster("Encryption Strategy"):
                kms_cmk = KMS("Customer Managed\nKMS Key")
                s3_encryption = S3("S3 Server-Side\nEncryption")
                ssl_tls = General("SSL/TLS\nIn Transit")
                
                kms_cmk >> s3_encryption
                s3_encryption - ssl_tls
            
            # State Storage Security
            with Cluster("Secure State Storage"):
                state_bucket = S3("Terraform State\nBucket")
                bucket_policy = General("Bucket Policy")
                versioning = General("Versioning\nEnabled")
                mfa_delete = General("MFA Delete\nProtection")
                
                state_bucket - bucket_policy
                state_bucket - versioning
                state_bucket - mfa_delete
            
            # Audit and Monitoring
            with Cluster("Audit & Monitoring"):
                cloudtrail_audit = Cloudtrail("CloudTrail\nAPI Auditing")
                access_logs = CloudwatchLogs("S3 Access\nLogs")
                cloudwatch_metrics = Cloudwatch("CloudWatch\nMetrics & Alarms")
                
                cloudtrail_audit - access_logs
                access_logs - cloudwatch_metrics
        
        # Security Flow
        terraform_client = Terraform("Terraform Client")
        
        terraform_client >> Edge(label="1. Authenticate", color=COLORS['primary']) >> iam_roles
        iam_roles >> Edge(label="2. Authorize", color=COLORS['accent']) >> iam_policies
        iam_policies >> Edge(label="3. Access via VPC", color=COLORS['success']) >> vpc_endpoints
        vpc_endpoints >> Edge(label="4. Encrypted Transit", color=COLORS['warning']) >> ssl_tls
        ssl_tls >> Edge(label="5. KMS Encryption", color=COLORS['danger']) >> kms_cmk
        kms_cmk >> Edge(label="6. Store State", color=COLORS['text']) >> state_bucket
        state_bucket >> Edge(label="7. Audit Trail", color=COLORS['primary']) >> cloudtrail_audit

def generate_state_lifecycle_operations():
    """Generate Figure 8.4: State Lifecycle and Operations Flow."""
    output_dir = setup_output_directory()
    
    with Diagram(
        "Figure 8.4: State Lifecycle and Operations Flow",
        filename=str(output_dir / "figure_8_4_state_lifecycle_operations"),
        show=False,
        direction="LR",
        graph_attr={
            "fontsize": "16",
            "bgcolor": COLORS['background'],
            "pad": "0.5",
            "splines": "curved"
        }
    ):
        # State Operations Workflow
        with Cluster("State Lifecycle Management"):
            # Initialization Phase
            with Cluster("1. Initialization"):
                terraform_init = Terraform("terraform init")
                backend_config = General("Backend\nConfiguration")
                state_creation = S3("State File\nCreation")
                
                terraform_init >> backend_config >> state_creation
            
            # Planning Phase
            with Cluster("2. Planning"):
                terraform_plan = Terraform("terraform plan")
                state_read = S3("State File\nRead")
                lock_acquire = Dynamodb("Lock\nAcquisition")
                
                terraform_plan >> state_read
                terraform_plan >> lock_acquire
            
            # Apply Phase
            with Cluster("3. Apply"):
                terraform_apply = Terraform("terraform apply")
                state_update = S3("State File\nUpdate")
                lock_release = Dynamodb("Lock\nRelease")
                
                terraform_apply >> state_update >> lock_release
            
            # Maintenance Operations
            with Cluster("4. Maintenance"):
                state_backup = S3("State\nBackup")
                state_migration = General("State\nMigration")
                state_import = General("Resource\nImport")
                
                state_backup - state_migration - state_import
        
        # Advanced Operations
        with Cluster("Advanced State Operations"):
            # State Manipulation
            with Cluster("State Manipulation"):
                state_mv = General("terraform\nstate mv")
                state_rm = General("terraform\nstate rm")
                state_import_cmd = General("terraform\nimport")
                
                state_mv - state_rm - state_import_cmd
            
            # Disaster Recovery
            with Cluster("Disaster Recovery"):
                state_pull = General("terraform\nstate pull")
                state_push = General("terraform\nstate push")
                force_unlock = General("terraform\nforce-unlock")
                
                state_pull - state_push - force_unlock
            
            # Monitoring and Alerts
            with Cluster("Monitoring"):
                state_metrics = Cloudwatch("State\nMetrics")
                lock_monitoring = Cloudwatch("Lock\nMonitoring")
                alert_system = General("Alert\nSystem")
                
                state_metrics - lock_monitoring - alert_system
        
        # Operation Flow
        terraform_init >> Edge(label="initializes", color=COLORS['primary']) >> terraform_plan
        terraform_plan >> Edge(label="validates", color=COLORS['accent']) >> terraform_apply
        terraform_apply >> Edge(label="maintains", color=COLORS['success']) >> state_backup
        
        # Error Handling Flow
        lock_acquire >> Edge(label="timeout", color=COLORS['danger']) >> force_unlock
        state_update >> Edge(label="corruption", color=COLORS['warning']) >> state_pull

def generate_disaster_recovery_strategy():
    """Generate Figure 8.5: Disaster Recovery and Backup Strategy."""
    output_dir = setup_output_directory()
    
    with Diagram(
        "Figure 8.5: Disaster Recovery and Backup Strategy",
        filename=str(output_dir / "figure_8_5_disaster_recovery_strategy"),
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "16",
            "bgcolor": COLORS['background'],
            "pad": "0.5",
            "splines": "ortho"
        }
    ):
        # Primary Infrastructure
        with Cluster("Primary Region (us-east-1)"):
            primary_state = S3("Primary State\nBucket")
            primary_locks = Dynamodb("Primary Lock\nTable")
            primary_kms = KMS("Primary KMS\nKey")
            primary_logs = CloudwatchLogs("Primary\nAudit Logs")
            
            primary_state - primary_locks
            primary_state - primary_kms
            primary_state - primary_logs
        
        # Disaster Recovery Infrastructure
        with Cluster("DR Region (us-west-2)"):
            dr_state = S3("DR State\nBucket")
            dr_locks = Dynamodb("DR Lock\nTable")
            dr_kms = KMS("DR KMS\nKey")
            dr_logs = CloudwatchLogs("DR\nAudit Logs")
            
            dr_state - dr_locks
            dr_state - dr_kms
            dr_state - dr_logs
        
        # Backup Strategy
        with Cluster("Backup Strategy"):
            # Automated Backups
            with Cluster("Automated Backups"):
                s3_versioning = General("S3 Versioning\n(30 days)")
                cross_region_replication = General("Cross-Region\nReplication")
                point_in_time = General("DynamoDB\nPoint-in-Time Recovery")
                
                s3_versioning - cross_region_replication - point_in_time
            
            # Manual Backups
            with Cluster("Manual Backups"):
                state_snapshots = General("State\nSnapshots")
                configuration_backup = Git("Configuration\nBackup")
                documentation = General("Runbook\nDocumentation")
                
                state_snapshots - configuration_backup - documentation
        
        # Recovery Procedures
        with Cluster("Recovery Procedures"):
            # RTO/RPO Targets
            with Cluster("Recovery Targets"):
                rto_target = General("RTO: 15 minutes")
                rpo_target = General("RPO: 5 minutes")
                
                rto_target - rpo_target
            
            # Recovery Steps
            with Cluster("Recovery Steps"):
                step1 = General("1. Assess\nDamage")
                step2 = General("2. Switch\nto DR")
                step3 = General("3. Restore\nState")
                step4 = General("4. Validate\nIntegrity")
                step5 = General("5. Resume\nOperations")
                
                step1 >> step2 >> step3 >> step4 >> step5
        
        # Monitoring and Alerting
        with Cluster("Monitoring & Alerting"):
            health_checks = Cloudwatch("Health\nChecks")
            failure_detection = General("Failure\nDetection")
            alert_notification = General("Alert\nNotification")
            escalation = General("Escalation\nProcedures")
            
            health_checks >> failure_detection >> alert_notification >> escalation
        
        # Replication Flow
        primary_state >> Edge(label="real-time replication", color=COLORS['success']) >> dr_state
        primary_locks >> Edge(label="backup replication", color=COLORS['accent']) >> dr_locks
        primary_logs >> Edge(label="log replication", color=COLORS['warning']) >> dr_logs
        
        # Failover Flow
        failure_detection >> Edge(label="triggers", color=COLORS['danger']) >> step1
        step2 >> Edge(label="activates", color=COLORS['primary']) >> dr_state
        
        # Recovery Validation
        step4 >> Edge(label="validates", color=COLORS['text']) >> health_checks

def main():
    """Generate all diagrams for Topic 8: Advanced State Management."""
    print("🎨 Generating Advanced State Management Diagrams...")
    print("=" * 60)
    
    try:
        # Generate all diagrams
        print("📊 Generating Figure 8.1: Enterprise State Architecture Overview...")
        generate_enterprise_state_architecture()
        
        print("📊 Generating Figure 8.2: Multi-Environment State Strategy...")
        generate_multi_environment_strategy()
        
        print("📊 Generating Figure 8.3: State Security and Encryption Patterns...")
        generate_state_security_patterns()
        
        print("📊 Generating Figure 8.4: State Lifecycle and Operations Flow...")
        generate_state_lifecycle_operations()
        
        print("📊 Generating Figure 8.5: Disaster Recovery and Backup Strategy...")
        generate_disaster_recovery_strategy()
        
        print("\n✅ All diagrams generated successfully!")
        print(f"📁 Output directory: {setup_output_directory()}")
        print("\n📋 Generated Diagrams:")
        print("   • Figure 8.1: Enterprise State Architecture Overview")
        print("   • Figure 8.2: Multi-Environment State Strategy")
        print("   • Figure 8.3: State Security and Encryption Patterns")
        print("   • Figure 8.4: State Lifecycle and Operations Flow")
        print("   • Figure 8.5: Disaster Recovery and Backup Strategy")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
