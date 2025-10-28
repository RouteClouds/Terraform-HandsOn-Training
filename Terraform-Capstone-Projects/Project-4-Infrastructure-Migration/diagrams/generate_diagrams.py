#!/usr/bin/env python3
"""
Diagram Generation Script for Project 4: Infrastructure Migration and Import
Generates architecture diagrams showing migration and import workflows
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, EC2AutoScaling
from diagrams.aws.network import VPC, ELB, Route53, InternetGateway
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM
from diagrams.aws.management import Cloudwatch
from diagrams.onprem.vcs import Github
from diagrams.onprem.client import Users

# Diagram attributes
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5"
}

def generate_hld():
    """Generate High-Level Design diagram"""
    with Diagram("Project 4 - High-Level Design", filename="hld", show=False, graph_attr=graph_attr):
        with Cluster("Existing Infrastructure"):
            existing_vpc = VPC("Manual VPC")
            existing_ec2 = EC2("Manual EC2")
            existing_rds = RDS("Manual RDS")
            existing_s3 = S3("Manual S3")
            existing_iam = IAM("Manual IAM")
        
        with Cluster("Terraform Import Process"):
            import_cmd = Github("terraform import")
        
        with Cluster("Terraform Managed"):
            managed_vpc = VPC("Managed VPC")
            managed_asg = EC2AutoScaling("Managed ASG")
            managed_rds = RDS("Managed RDS")
            managed_s3 = S3("Managed S3")
            managed_iam = IAM("Managed IAM")
        
        existing_vpc >> import_cmd >> managed_vpc
        existing_ec2 >> import_cmd >> managed_asg
        existing_rds >> import_cmd >> managed_rds
        existing_s3 >> import_cmd >> managed_s3
        existing_iam >> import_cmd >> managed_iam

def generate_lld():
    """Generate Low-Level Design diagram"""
    with Diagram("Project 4 - Low-Level Design", filename="lld", show=False, graph_attr=graph_attr):
        with Cluster("Import Workflow"):
            with Cluster("Step 1: Discovery"):
                discovery = Github("Resource\nDiscovery")
            
            with Cluster("Step 2: Configuration"):
                config = Github("Write\nConfiguration")
            
            with Cluster("Step 3: Import"):
                import_cmd = Github("terraform\nimport")
            
            with Cluster("Step 4: Validation"):
                validate = Github("terraform\nplan")
        
        with Cluster("AWS Resources"):
            vpc = VPC("VPC")
            ec2 = EC2("EC2")
            rds = RDS("RDS")
        
        discovery >> config >> import_cmd >> validate
        [vpc, ec2, rds] >> import_cmd

def generate_migration_strategy():
    """Generate Migration Strategy diagram"""
    with Diagram("Migration Strategy", filename="migration_strategy", show=False, graph_attr=graph_attr):
        with Cluster("Phase 1: Assessment"):
            inventory = Github("Resource\nInventory")
            dependencies = Github("Dependency\nMapping")
        
        with Cluster("Phase 2: Planning"):
            strategy = Github("Migration\nStrategy")
            timeline = Github("Timeline")
        
        with Cluster("Phase 3: Execution"):
            backup = S3("Backup\nState")
            import_phase = Github("Import\nResources")
            validate = Github("Validate")
        
        with Cluster("Phase 4: Cutover"):
            test = Github("Test")
            cutover = Github("Cutover")
        
        inventory >> dependencies >> strategy >> timeline
        timeline >> backup >> import_phase >> validate >> test >> cutover

def generate_import_workflow():
    """Generate Import Workflow diagram"""
    with Diagram("Import Workflow", filename="import_workflow", show=False, graph_attr=graph_attr):
        with Cluster("Import Process"):
            step1 = Github("1. Get Resource ID")
            step2 = Github("2. Write Config")
            step3 = Github("3. terraform init")
            step4 = Github("4. terraform import")
            step5 = Github("5. terraform plan")
            step6 = Github("6. Adjust Config")
            step7 = Github("7. Validate")
        
        aws = VPC("AWS Resource")
        
        aws >> step1 >> step2 >> step3 >> step4 >> step5
        step5 >> Edge(label="drift?") >> step6 >> step5
        step5 >> Edge(label="no drift") >> step7

def generate_state_manipulation():
    """Generate State Manipulation diagram"""
    with Diagram("State Manipulation", filename="state_manipulation", show=False, graph_attr=graph_attr):
        with Cluster("State Commands"):
            state_list = Github("terraform\nstate list")
            state_show = Github("terraform\nstate show")
            state_mv = Github("terraform\nstate mv")
            state_rm = Github("terraform\nstate rm")
            state_pull = Github("terraform\nstate pull")
            state_push = Github("terraform\nstate push")
        
        with Cluster("State File"):
            state = S3("terraform.tfstate")
        
        state >> state_list
        state >> state_show
        state_mv >> state
        state_rm >> state
        state_pull >> state
        state_push >> state

def generate_zero_downtime():
    """Generate Zero-Downtime Migration diagram"""
    with Diagram("Zero-Downtime Migration", filename="zero_downtime_migration", show=False, graph_attr=graph_attr):
        users = Users("Users")
        
        with Cluster("Old Infrastructure"):
            old_ec2_1 = EC2("EC2-1")
            old_ec2_2 = EC2("EC2-2")
        
        with Cluster("New Infrastructure"):
            asg = EC2AutoScaling("ASG")
            new_ec2_1 = EC2("New-1")
            new_ec2_2 = EC2("New-2")
        
        elb = ELB("Load Balancer")
        
        users >> elb
        elb >> [old_ec2_1, old_ec2_2]
        elb >> [new_ec2_1, new_ec2_2]
        asg >> [new_ec2_1, new_ec2_2]

def generate_disaster_recovery():
    """Generate Disaster Recovery diagram"""
    with Diagram("Disaster Recovery", filename="disaster_recovery", show=False, graph_attr=graph_attr):
        with Cluster("Backup Strategy"):
            state_backup = S3("State Backup")
            config_backup = Github("Config Backup")
        
        with Cluster("Recovery Process"):
            detect = Cloudwatch("Detect Issue")
            restore_state = Github("Restore State")
            restore_config = Github("Restore Config")
            validate = Github("Validate")
            apply = Github("Apply")
        
        state_backup >> restore_state
        config_backup >> restore_config
        detect >> restore_state >> restore_config >> validate >> apply

def generate_backup_strategy():
    """Generate Backup Strategy diagram"""
    with Diagram("Backup Strategy", filename="backup_strategy", show=False, graph_attr=graph_attr):
        with Cluster("Backup Types"):
            state_backup = S3("State Files")
            config_backup = Github("Configuration")
            resource_backup = S3("Resource Data")

        with Cluster("Backup Schedule"):
            before_import = Github("Before Import")
            daily = Github("Daily")
            before_change = Github("Before Changes")

        with Cluster("Storage"):
            s3_versioned = S3("S3 Versioned\nBucket")
            git_repo = Github("Git Repository")

        state_backup >> s3_versioned
        resource_backup >> s3_versioned
        config_backup >> git_repo
        before_import >> s3_versioned
        daily >> s3_versioned
        before_change >> git_repo

def generate_rollback_procedures():
    """Generate Rollback Procedures diagram"""
    with Diagram("Rollback Procedures", filename="rollback_procedures", show=False, graph_attr=graph_attr):
        with Cluster("Rollback Steps"):
            detect = Cloudwatch("Detect Issue")
            stop = Github("Stop Operations")
            backup = S3("Get Backup")
            restore = Github("Restore State")
            verify = Github("Verify")
            resume = Github("Resume")
        
        detect >> stop >> backup >> restore >> verify >> resume

def generate_refactoring_approach():
    """Generate Refactoring Approach diagram"""
    with Diagram("Refactoring Approach", filename="refactoring_approach", show=False, graph_attr=graph_attr):
        with Cluster("Monolithic Config"):
            mono = Github("main.tf\n(1000+ lines)")
        
        with Cluster("State Manipulation"):
            state_mv = Github("terraform\nstate mv")
        
        with Cluster("Modular Config"):
            with Cluster("Modules"):
                vpc_mod = Github("vpc/")
                compute_mod = Github("compute/")
                database_mod = Github("database/")
            
            root = Github("main.tf\n(module calls)")
        
        mono >> state_mv >> [vpc_mod, compute_mod, database_mod]
        [vpc_mod, compute_mod, database_mod] >> root

def main():
    """Generate all diagrams"""
    print("Generating Project 4 architecture diagrams...")
    
    try:
        generate_hld()
        print("✓ Generated: hld.png")
        
        generate_lld()
        print("✓ Generated: lld.png")
        
        generate_migration_strategy()
        print("✓ Generated: migration_strategy.png")
        
        generate_import_workflow()
        print("✓ Generated: import_workflow.png")
        
        generate_state_manipulation()
        print("✓ Generated: state_manipulation.png")
        
        generate_zero_downtime()
        print("✓ Generated: zero_downtime_migration.png")
        
        generate_disaster_recovery()
        print("✓ Generated: disaster_recovery.png")
        
        generate_backup_strategy()
        print("✓ Generated: backup_strategy.png")
        
        generate_rollback_procedures()
        print("✓ Generated: rollback_procedures.png")
        
        generate_refactoring_approach()
        print("✓ Generated: refactoring_approach.png")
        
        print("\n✅ All diagrams generated successfully!")
        print("📁 Diagrams saved in the current directory")
        
    except Exception as e:
        print(f"\n❌ Error generating diagrams: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())

