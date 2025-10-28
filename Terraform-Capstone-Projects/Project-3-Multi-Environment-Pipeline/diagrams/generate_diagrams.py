#!/usr/bin/env python3
"""
Diagram Generation Script for Project 3: Multi-Environment Infrastructure Pipeline
Generates architecture diagrams showing multi-environment setup and CI/CD pipeline
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, EC2AutoScaling
from diagrams.aws.network import VPC, ELB, Route53, NATGateway, InternetGateway
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM, Shield
from diagrams.aws.management import Cloudwatch
from diagrams.aws.general import Users
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions
from diagrams.programming.flowchart import Decision

# Diagram attributes
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5"
}

def generate_hld():
    """Generate High-Level Design diagram"""
    with Diagram("Project 3 - High-Level Design", filename="hld", show=False, graph_attr=graph_attr):
        users = Users("Users")
        
        with Cluster("AWS Cloud"):
            with Cluster("Development"):
                dev_vpc = VPC("Dev VPC\n10.0.0.0/16")
                dev_alb = ELB("Dev ALB")
                dev_asg = EC2AutoScaling("Dev ASG")
                dev_rds = RDS("Dev RDS")
            
            with Cluster("Staging"):
                stg_vpc = VPC("Staging VPC\n10.1.0.0/16")
                stg_alb = ELB("Staging ALB")
                stg_asg = EC2AutoScaling("Staging ASG")
                stg_rds = RDS("Staging RDS")
            
            with Cluster("Production"):
                prod_vpc = VPC("Prod VPC\n10.2.0.0/16")
                prod_alb = ELB("Prod ALB")
                prod_asg = EC2AutoScaling("Prod ASG")
                prod_rds = RDS("Prod RDS")
            
            with Cluster("State Management"):
                s3 = S3("State Bucket")
        
        users >> [dev_alb, stg_alb, prod_alb]
        dev_alb >> dev_asg >> dev_rds
        stg_alb >> stg_asg >> stg_rds
        prod_alb >> prod_asg >> prod_rds

def generate_lld():
    """Generate Low-Level Design diagram"""
    with Diagram("Project 3 - Low-Level Design", filename="lld", show=False, graph_attr=graph_attr):
        users = Users("Users")
        
        with Cluster("Production Environment"):
            with Cluster("VPC 10.2.0.0/16"):
                with Cluster("Public Subnets"):
                    igw = InternetGateway("IGW")
                    alb = ELB("ALB")
                    nat = NATGateway("NAT Gateways")
                
                with Cluster("Private Subnets"):
                    asg = EC2AutoScaling("ASG (2-6)")
                    ec2_1 = EC2("EC2-1")
                    ec2_2 = EC2("EC2-2")
                    ec2_3 = EC2("EC2-3")
                    rds = RDS("RDS Multi-AZ")
        
        with Cluster("State Backend"):
            s3_state = S3("State Bucket")
            s3_backup = S3("Backup Bucket")
        
        users >> alb
        alb >> [ec2_1, ec2_2, ec2_3]
        [ec2_1, ec2_2, ec2_3] >> rds

def generate_multi_environment():
    """Generate Multi-Environment Architecture diagram"""
    with Diagram("Multi-Environment Architecture", filename="multi_environment_architecture", show=False, graph_attr=graph_attr):
        with Cluster("Terraform Configuration"):
            tf_code = Github("Terraform Code")
        
        with Cluster("AWS Environments"):
            with Cluster("Dev (1 AZ)"):
                dev = VPC("Dev\nt3.micro\nSingle NAT")
            
            with Cluster("Staging (2 AZs)"):
                staging = VPC("Staging\nt3.small\nMulti-AZ RDS")
            
            with Cluster("Production (3 AZs)"):
                prod = VPC("Production\nt3.medium\nFull HA")
        
        with Cluster("State Management"):
            s3 = S3("S3 State Bucket")
            
            with Cluster("State Files"):
                dev_state = S3("dev/terraform.tfstate")
                stg_state = S3("staging/terraform.tfstate")
                prod_state = S3("prod/terraform.tfstate")
        
        tf_code >> [dev, staging, prod]
        dev >> dev_state >> s3
        staging >> stg_state >> s3
        prod >> prod_state >> s3

def generate_state_isolation():
    """Generate State Isolation diagram"""
    with Diagram("State Isolation Strategy", filename="state_isolation", show=False, graph_attr=graph_attr):
        with Cluster("State Backend"):
            s3_bucket = S3("terraform-state-bucket")
            
            with Cluster("Environment States"):
                dev_state = S3("dev/\nterraform.tfstate")
                stg_state = S3("staging/\nterraform.tfstate")
                prod_state = S3("prod/\nterraform.tfstate")
            
            with Cluster("State Locking"):
                dev_lock = S3("terraform-locks-dev")
                stg_lock = S3("terraform-locks-staging")
                prod_lock = S3("terraform-locks-prod")
        
        s3_bucket >> [dev_state, stg_state, prod_state]
        dev_state >> dev_lock
        stg_state >> stg_lock
        prod_state >> prod_lock

def generate_cicd_pipeline():
    """Generate CI/CD Pipeline diagram"""
    with Diagram("CI/CD Pipeline", filename="cicd_pipeline", show=False, graph_attr=graph_attr):
        github = Github("GitHub Repo")
        
        with Cluster("GitHub Actions"):
            with Cluster("Dev Pipeline"):
                dev_workflow = GithubActions("Dev Workflow")
                dev_plan = GithubActions("Plan")
                dev_apply = GithubActions("Apply")
            
            with Cluster("Staging Pipeline"):
                stg_workflow = GithubActions("Staging Workflow")
                stg_plan = GithubActions("Plan")
                stg_approval = GithubActions("Approval")
                stg_apply = GithubActions("Apply")
            
            with Cluster("Production Pipeline"):
                prod_workflow = GithubActions("Prod Workflow")
                prod_plan = GithubActions("Plan")
                prod_approval = GithubActions("Approval (2)")
                prod_apply = GithubActions("Apply")
        
        with Cluster("AWS Environments"):
            dev_env = VPC("Dev")
            stg_env = VPC("Staging")
            prod_env = VPC("Production")
        
        github >> dev_workflow >> dev_plan >> dev_apply >> dev_env
        github >> stg_workflow >> stg_plan >> stg_approval >> stg_apply >> stg_env
        github >> prod_workflow >> prod_plan >> prod_approval >> prod_apply >> prod_env

def generate_deployment_workflow():
    """Generate Deployment Workflow diagram"""
    with Diagram("Deployment Workflow", filename="deployment_workflow", show=False, graph_attr=graph_attr):
        with Cluster("Deployment Steps"):
            checkout = GithubActions("1. Checkout")
            fmt = GithubActions("2. Format Check")
            init = GithubActions("3. Init")
            validate = GithubActions("4. Validate")
            plan = GithubActions("5. Plan")
            approval = GithubActions("6. Approval")
            apply = GithubActions("7. Apply")
            test = GithubActions("8. Test")
            notify = GithubActions("9. Notify")
        
        aws = VPC("AWS Environment")
        
        checkout >> fmt >> init >> validate >> plan >> approval >> apply >> test >> notify
        apply >> aws

def generate_state_backend():
    """Generate State Backend diagram"""
    with Diagram("State Backend Infrastructure", filename="state_backend", show=False, graph_attr=graph_attr):
        with Cluster("State Backend"):
            with Cluster("S3 Buckets"):
                state_bucket = S3("State Bucket\nVersioning\nEncryption")
                backup_bucket = S3("Backup Bucket\n30-day retention")
            
            with Cluster("DynamoDB Tables"):
                dev_lock = S3("terraform-locks-dev")
                stg_lock = S3("terraform-locks-staging")
                prod_lock = S3("terraform-locks-prod")
            
            with Cluster("Monitoring"):
                cw = Cloudwatch("CloudWatch Logs")
                sns = Cloudwatch("SNS Notifications")
        
        state_bucket >> backup_bucket
        state_bucket >> [dev_lock, stg_lock, prod_lock]
        state_bucket >> cw >> sns

def generate_approval_gates():
    """Generate Approval Gates diagram"""
    with Diagram("Approval Gates", filename="approval_gates", show=False, graph_attr=graph_attr):
        with Cluster("Deployment Flow"):
            dev = GithubActions("Dev\nAuto-deploy")
            staging = GithubActions("Staging\n1 Approval")
            prod = GithubActions("Production\n2 Approvals")
        
        with Cluster("Environments"):
            dev_env = VPC("Dev")
            stg_env = VPC("Staging")
            prod_env = VPC("Production")
        
        dev >> dev_env
        staging >> stg_env
        prod >> prod_env

def generate_drift_detection():
    """Generate Drift Detection diagram"""
    with Diagram("Drift Detection", filename="drift_detection", show=False, graph_attr=graph_attr):
        with Cluster("Scheduled Check"):
            cron = GithubActions("Daily Cron\n9 AM UTC")
        
        with Cluster("Drift Detection"):
            check_dev = GithubActions("Check Dev")
            check_stg = GithubActions("Check Staging")
            check_prod = GithubActions("Check Prod")
        
        with Cluster("Notifications"):
            issue = Github("Create Issue")
            alert = Cloudwatch("Alert")
        
        cron >> [check_dev, check_stg, check_prod]
        [check_dev, check_stg, check_prod] >> issue
        [check_dev, check_stg, check_prod] >> alert

def generate_vcs_workflow():
    """Generate VCS-Driven Workflow diagram"""
    with Diagram("VCS-Driven Workflow", filename="vcs_workflow", show=False, graph_attr=graph_attr):
        with Cluster("Developer Workflow"):
            developer = Users("Developer")
            git_push = Github("Git Push")

        with Cluster("GitHub"):
            pr = Github("Pull Request")
            main_branch = Github("Main Branch")
            gh_actions = GithubActions("GitHub Actions")

        with Cluster("CI/CD Pipeline"):
            with Cluster("Dev Environment"):
                dev_plan = GithubActions("Terraform Plan")
                dev_apply = GithubActions("Auto Apply")

            with Cluster("Staging Environment"):
                stg_plan = GithubActions("Terraform Plan")
                stg_approval = Decision("Manual Approval\n(1 reviewer)")
                stg_apply = GithubActions("Terraform Apply")

            with Cluster("Production Environment"):
                prod_plan = GithubActions("Terraform Plan")
                prod_approval = Decision("Manual Approval\n(2 reviewers)")
                prod_apply = GithubActions("Terraform Apply")

        with Cluster("AWS Infrastructure"):
            dev_infra = VPC("Dev VPC")
            stg_infra = VPC("Staging VPC")
            prod_infra = VPC("Production VPC")

        # Workflow connections
        developer >> git_push >> pr
        pr >> gh_actions >> dev_plan
        dev_plan >> dev_apply >> dev_infra

        pr >> Edge(label="merge") >> main_branch
        main_branch >> stg_plan >> stg_approval >> stg_apply >> stg_infra
        main_branch >> prod_plan >> prod_approval >> prod_apply >> prod_infra

def main():
    """Generate all diagrams"""
    print("Generating Project 3 architecture diagrams...")
    
    try:
        generate_hld()
        print("✓ Generated: hld.png")
        
        generate_lld()
        print("✓ Generated: lld.png")
        
        generate_multi_environment()
        print("✓ Generated: multi_environment_architecture.png")
        
        generate_state_isolation()
        print("✓ Generated: state_isolation.png")
        
        generate_cicd_pipeline()
        print("✓ Generated: cicd_pipeline.png")
        
        generate_deployment_workflow()
        print("✓ Generated: deployment_workflow.png")
        
        generate_state_backend()
        print("✓ Generated: state_backend.png")
        
        generate_approval_gates()
        print("✓ Generated: approval_gates.png")
        
        generate_drift_detection()
        print("✓ Generated: drift_detection.png")

        generate_vcs_workflow()
        print("✓ Generated: vcs_workflow.png")

        print("\n✅ All diagrams generated successfully!")
        print("📁 Diagrams saved in the current directory")
        
    except Exception as e:
        print(f"\n❌ Error generating diagrams: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())

