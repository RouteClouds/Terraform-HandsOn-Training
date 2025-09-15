#!/usr/bin/env python3
"""
AWS Terraform Training - Terraform CLI & AWS Provider Configuration
Diagram as Code (DaC) Generation Script

This script generates 5 professional diagrams for the Terraform CLI & AWS Provider module:
1. Terraform CLI Installation Methods
2. AWS Authentication Flow
3. Multi-Environment Setup
4. Provider Configuration Patterns
5. Development Workflow

Requirements:
- Python 3.9+
- diagrams library
- Graphviz
"""

import os
import sys
from pathlib import Path

# Add current directory to path for imports
sys.path.append(str(Path(__file__).parent))

try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.aws.compute import EC2
    from diagrams.aws.database import DynamodbTable
    from diagrams.aws.network import VPC
    from diagrams.aws.security import IAM, KMS
    from diagrams.aws.storage import S3
    from diagrams.aws.management import Cloudwatch, Organizations
    from diagrams.aws.general import General, Users, Client
    from diagrams.onprem.vcs import Git
    from diagrams.onprem.ci import Jenkins
    from diagrams.onprem.client import Users as LocalUsers
    from diagrams.programming.language import Python
    from diagrams.generic.blank import Blank
    from diagrams.generic.compute import Rack
    from diagrams.generic.network import Switch
    from diagrams.generic.storage import Storage
    from diagrams.generic.os import Ubuntu, Windows, IOS
except ImportError as e:
    print(f"Error importing required libraries: {e}")
    print("Please install required packages: pip install diagrams")
    sys.exit(1)

# Configuration
OUTPUT_DIR = Path(__file__).parent / "generated_diagrams"
DPI = 300  # High resolution for professional quality

def setup_output_directory():
    """Create output directory if it doesn't exist."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Output directory: {OUTPUT_DIR}")

def generate_cli_installation_diagram():
    """Generate Figure 2.1: Terraform CLI Installation Methods."""
    print("Generating Figure 2.1: Terraform CLI Installation Methods...")
    
    with Diagram(
        "Figure 2.1: Terraform CLI Installation Methods",
        filename=str(OUTPUT_DIR / "cli_installation"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Operating Systems
        with Cluster("Operating Systems"):
            ubuntu = Ubuntu("Ubuntu/Debian")
            centos = General("RHEL/CentOS")
            macos = IOS("macOS")
            windows = Windows("Windows")
            
        # Installation Methods
        with Cluster("Installation Methods"):
            # Official Repository
            with Cluster("Official HashiCorp Repository"):
                apt_repo = General("APT Repository")
                yum_repo = General("YUM Repository")
                brew_repo = General("Homebrew")
                choco_repo = General("Chocolatey")
                
            # Version Management
            with Cluster("Version Management"):
                tfenv = General("tfenv")
                tfswitch = General("tfswitch")
                
            # Container-based
            with Cluster("Container-based"):
                docker = General("Docker")
                podman = General("Podman")
                
        # Terraform CLI
        terraform_cli = General("Terraform CLI\n1.13.2")
        
        # Connections
        ubuntu >> Edge(label="apt install") >> apt_repo >> terraform_cli
        centos >> Edge(label="yum install") >> yum_repo >> terraform_cli
        macos >> Edge(label="brew install") >> brew_repo >> terraform_cli
        windows >> Edge(label="choco install") >> choco_repo >> terraform_cli
        
        [ubuntu, macos] >> Edge(label="version mgmt") >> tfenv >> terraform_cli
        [ubuntu, centos, macos] >> Edge(label="containerized") >> docker >> terraform_cli

def generate_aws_auth_flow():
    """Generate Figure 2.2: AWS Authentication Flow."""
    print("Generating Figure 2.2: AWS Authentication Flow...")
    
    with Diagram(
        "Figure 2.2: AWS Authentication Flow",
        filename=str(OUTPUT_DIR / "aws_auth_flow"),
        show=False,
        direction="LR",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # User/Developer
        developer = LocalUsers("Developer")
        
        # Authentication Methods
        with Cluster("Authentication Methods"):
            # AWS CLI Profiles
            with Cluster("AWS CLI Profiles"):
                default_profile = General("Default Profile")
                named_profiles = General("Named Profiles")
                sso_profile = General("SSO Profile")
                
            # IAM Methods
            with Cluster("IAM Authentication"):
                iam_user = IAM("IAM User")
                iam_role = IAM("IAM Role")
                assume_role = IAM("Assume Role")
                
            # Environment Variables
            env_vars = General("Environment\nVariables")
            
        # AWS Services
        with Cluster("AWS Services"):
            sts = General("AWS STS")
            organizations = Organizations("AWS Organizations")
            sso = General("AWS SSO")
            
        # Terraform Provider
        terraform_provider = General("Terraform\nAWS Provider\n6.12.0")
        
        # AWS Resources
        with Cluster("AWS Resources"):
            ec2 = EC2("EC2")
            s3 = S3("S3")
            vpc = VPC("VPC")
            
        # Authentication flows
        developer >> Edge(label="1. Configure") >> [default_profile, named_profiles, sso_profile]
        developer >> Edge(label="2. Set") >> env_vars
        
        [default_profile, named_profiles] >> Edge(label="3. Authenticate") >> sts
        sso_profile >> Edge(label="3. SSO Login") >> sso >> sts
        env_vars >> Edge(label="3. Direct") >> sts
        
        sts >> Edge(label="4. Credentials") >> terraform_provider
        terraform_provider >> Edge(label="5. Provision") >> [ec2, s3, vpc]

def generate_multi_env_setup():
    """Generate Figure 2.3: Multi-Environment Setup."""
    print("Generating Figure 2.3: Multi-Environment Setup...")
    
    with Diagram(
        "Figure 2.3: Multi-Environment Setup",
        filename=str(OUTPUT_DIR / "multi_env_setup"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Terraform Configuration
        with Cluster("Terraform Configuration"):
            providers_tf = General("providers.tf")
            variables_tf = General("variables.tf")
            main_tf = General("main.tf")
            
        # Environment Configurations
        with Cluster("Environment Configurations"):
            dev_vars = General("development.tfvars")
            staging_vars = General("staging.tfvars")
            prod_vars = General("production.tfvars")
            
        # Terraform Workspaces
        with Cluster("Terraform Workspaces"):
            dev_workspace = General("development")
            staging_workspace = General("staging")
            prod_workspace = General("production")
            
        # AWS Accounts/Environments
        with Cluster("AWS Development Account"):
            dev_vpc = VPC("Dev VPC")
            dev_ec2 = EC2("Dev EC2")
            
        with Cluster("AWS Staging Account"):
            staging_vpc = VPC("Staging VPC")
            staging_ec2 = EC2("Staging EC2")
            
        with Cluster("AWS Production Account"):
            prod_vpc = VPC("Prod VPC")
            prod_ec2 = EC2("Prod EC2")
            
        # State Backend
        with Cluster("Remote State Backend"):
            s3_state = S3("S3 State Bucket")
            dynamodb_lock = DynamodbTable("DynamoDB Locks")
            
        # Connections
        [providers_tf, variables_tf, main_tf] >> Edge(label="config") >> [dev_workspace, staging_workspace, prod_workspace]
        
        dev_vars >> dev_workspace >> Edge(label="deploy") >> [dev_vpc, dev_ec2]
        staging_vars >> staging_workspace >> Edge(label="deploy") >> [staging_vpc, staging_ec2]
        prod_vars >> prod_workspace >> Edge(label="deploy") >> [prod_vpc, prod_ec2]
        
        [dev_workspace, staging_workspace, prod_workspace] >> Edge(label="state") >> s3_state
        [dev_workspace, staging_workspace, prod_workspace] >> Edge(label="locking") >> dynamodb_lock

def generate_provider_patterns():
    """Generate Figure 2.4: Provider Configuration Patterns."""
    print("Generating Figure 2.4: Provider Configuration Patterns...")
    
    with Diagram(
        "Figure 2.4: Provider Configuration Patterns",
        filename=str(OUTPUT_DIR / "provider_patterns"),
        show=False,
        direction="LR",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Provider Configurations
        with Cluster("Provider Configuration Patterns"):
            # Single Region
            with Cluster("Single Region"):
                single_provider = General("AWS Provider\nus-east-1")
                
            # Multi-Region
            with Cluster("Multi-Region"):
                primary_provider = General("Primary Provider\nus-east-1")
                secondary_provider = General("Secondary Provider\nus-west-2")
                
            # Cross-Account
            with Cluster("Cross-Account"):
                dev_provider = General("Dev Account\nProvider")
                prod_provider = General("Prod Account\nProvider")
                
        # Configuration Features
        with Cluster("Configuration Features"):
            version_constraints = General("Version\nConstraints")
            default_tags = General("Default\nTags")
            assume_role = General("Assume\nRole")
            endpoints = General("Custom\nEndpoints")
            
        # AWS Resources
        with Cluster("AWS Resources - us-east-1"):
            east_vpc = VPC("VPC")
            east_ec2 = EC2("EC2")
            
        with Cluster("AWS Resources - us-west-2"):
            west_vpc = VPC("VPC")
            west_ec2 = EC2("EC2")
            
        with Cluster("Cross-Account Resources"):
            dev_resources = General("Dev Resources")
            prod_resources = General("Prod Resources")
            
        # Connections
        single_provider >> [version_constraints, default_tags] >> [east_vpc, east_ec2]
        
        primary_provider >> [east_vpc, east_ec2]
        secondary_provider >> [west_vpc, west_ec2]
        
        dev_provider >> assume_role >> dev_resources
        prod_provider >> assume_role >> prod_resources

def generate_dev_workflow():
    """Generate Figure 2.5: Development Workflow."""
    print("Generating Figure 2.5: Development Workflow...")
    
    with Diagram(
        "Figure 2.5: Development Workflow",
        filename=str(OUTPUT_DIR / "dev_workflow"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Developer Environment
        with Cluster("Developer Environment"):
            developer = LocalUsers("Developer")
            ide = General("IDE/VS Code")
            terraform_cli = General("Terraform CLI")
            
        # Development Tools
        with Cluster("Development Tools"):
            tfenv = General("tfenv")
            pre_commit = General("Pre-commit\nHooks")
            terraform_docs = General("terraform-docs")
            tflint = General("TFLint")
            
        # Terraform Workflow
        with Cluster("Terraform Workflow"):
            init = General("terraform init")
            validate = General("terraform validate")
            plan = General("terraform plan")
            apply = General("terraform apply")
            
        # Version Control
        with Cluster("Version Control"):
            git_repo = Git("Git Repository")
            ci_pipeline = Jenkins("CI Pipeline")
            
        # Remote Backend
        with Cluster("Remote Backend"):
            s3_backend = S3("S3 Backend")
            state_locking = DynamodbTable("State Locking")
            
        # AWS Infrastructure
        with Cluster("AWS Infrastructure"):
            infrastructure = General("Deployed\nInfrastructure")
            monitoring = Cloudwatch("CloudWatch\nMonitoring")
            
        # Workflow connections
        developer >> ide >> terraform_cli
        terraform_cli >> [tfenv, pre_commit, terraform_docs, tflint]
        
        terraform_cli >> init >> validate >> plan >> apply
        
        [validate, plan, apply] >> git_repo >> ci_pipeline
        [init, plan, apply] >> [s3_backend, state_locking]
        apply >> infrastructure >> monitoring

def main():
    """Main function to generate all diagrams."""
    print("🎨 Starting Terraform CLI & AWS Provider Configuration Diagram Generation")
    print("=" * 80)
    
    # Setup
    setup_output_directory()
    
    try:
        # Generate all diagrams
        generate_cli_installation_diagram()
        generate_aws_auth_flow()
        generate_multi_env_setup()
        generate_provider_patterns()
        generate_dev_workflow()
        
        print("\n✅ All diagrams generated successfully!")
        print(f"📁 Output location: {OUTPUT_DIR}")
        print("\nGenerated diagrams:")
        print("- Figure 2.1: cli_installation.png")
        print("- Figure 2.2: aws_auth_flow.png")
        print("- Figure 2.3: multi_env_setup.png")
        print("- Figure 2.4: provider_patterns.png")
        print("- Figure 2.5: dev_workflow.png")
        print(f"\n🎯 All diagrams are {DPI} DPI for professional quality")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
