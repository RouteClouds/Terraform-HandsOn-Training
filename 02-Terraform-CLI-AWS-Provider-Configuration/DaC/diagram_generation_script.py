#!/usr/bin/env python3
"""
Professional Diagram Generation Script for Topic 2: Terraform CLI & AWS Provider Configuration

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
    from diagrams.aws.compute import EC2
    from diagrams.aws.database import DynamodbTable
    from diagrams.aws.network import VPC
    from diagrams.aws.security import IAM, KMS
    from diagrams.aws.storage import S3
    from diagrams.aws.management import Cloudwatch, Cloudtrail, Organizations
    from diagrams.aws.general import General, Users, Client
    from diagrams.onprem.vcs import Git
    from diagrams.onprem.ci import Jenkins
    from diagrams.onprem.client import Users as LocalUsers
    from diagrams.onprem.iac import Terraform
    from diagrams.programming.language import Python
    from diagrams.generic.blank import Blank
    from diagrams.generic.compute import Rack
    from diagrams.generic.network import Switch
    from diagrams.generic.storage import Storage
    from diagrams.generic.os import Ubuntu, Windows, IOS
    from diagrams.onprem.monitoring import Grafana
except ImportError as e:
    print(f"Error importing required libraries: {e}")
    print("Please install required packages: pip install diagrams")
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

def create_terraform_cli_installation_methods():
    """
    Figure 2.1: Terraform CLI Installation and Version Management Methods

    This diagram illustrates different methods for installing and managing
    Terraform CLI across various operating systems and environments.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 2.1: Terraform CLI Installation and Version Management",
        filename=str(output_dir / "figure_2_1_terraform_cli_installation"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Operating Systems
        with Cluster("Operating Systems"):
            linux = Ubuntu("Linux")
            macos = IOS("macOS")
            windows = Windows("Windows")

        # Installation Methods
        with Cluster("Installation Methods"):
            # Package Managers
            with Cluster("Package Managers"):
                apt = Rack("apt (Ubuntu/Debian)")
                brew = Rack("Homebrew (macOS)")
                choco = Rack("Chocolatey (Windows)")
                yum = Rack("yum/dnf (RHEL/CentOS)")

            # Direct Download
            with Cluster("Direct Download"):
                hashicorp_releases = Storage("HashiCorp Releases")
                binary_install = Rack("Binary Installation")

            # Version Managers
            with Cluster("Version Management"):
                tfenv = Python("tfenv")
                tfswitch = Python("tfswitch")
                asdf = Python("asdf-terraform")

        # Enterprise Solutions
        with Cluster("Enterprise Solutions"):
            docker = Rack("Docker Containers")
            ci_cd = Jenkins("CI/CD Integration")
            terraform_cloud = Storage("Terraform Cloud")

        # Configuration and Optimization
        with Cluster("Configuration & Optimization"):
            cli_config = Storage(".terraformrc")
            plugin_cache = Storage("Plugin Cache")
            network_mirror = Storage("Network Mirror")

        # Connections
        linux >> Edge(label="Package Manager", color=COLORS['success']) >> apt
        macos >> Edge(label="Package Manager", color=COLORS['success']) >> brew
        windows >> Edge(label="Package Manager", color=COLORS['success']) >> choco

        linux >> Edge(label="Direct Download", color=COLORS['accent']) >> hashicorp_releases
        macos >> Edge(label="Direct Download", color=COLORS['accent']) >> hashicorp_releases
        windows >> Edge(label="Direct Download", color=COLORS['accent']) >> hashicorp_releases
        hashicorp_releases >> binary_install

        linux >> Edge(label="Version Management", color=COLORS['primary']) >> tfenv
        macos >> Edge(label="Version Management", color=COLORS['primary']) >> tfenv
        linux >> Edge(label="Version Management", color=COLORS['primary']) >> tfswitch
        macos >> Edge(label="Version Management", color=COLORS['primary']) >> tfswitch
        windows >> Edge(label="Version Management", color=COLORS['primary']) >> tfswitch

        binary_install >> Edge(label="Configuration", color=COLORS['secondary']) >> cli_config
        cli_config >> plugin_cache
        cli_config >> network_mirror

        # Enterprise connections
        docker >> Edge(label="Enterprise", color=COLORS['warning']) >> cli_config
        ci_cd >> Edge(label="Enterprise", color=COLORS['warning']) >> cli_config
        terraform_cloud >> Edge(label="Enterprise", color=COLORS['warning']) >> cli_config

def create_aws_authentication_flow():
    """
    Figure 2.2: AWS Provider Authentication Methods and Flow

    This diagram shows the various authentication methods available for
    the AWS provider and their security implications.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 2.2: AWS Provider Authentication Methods and Security Flow",
        filename=str(output_dir / "figure_2_2_aws_authentication_flow"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Developer/User Layer
        with Cluster("Developer Environment"):
            developer = LocalUsers("Developer")
            terraform_cli = Terraform("Terraform CLI")

            developer >> terraform_cli

        # Authentication Methods
        with Cluster("Authentication Methods"):
            # AWS CLI Profiles
            with Cluster("AWS CLI Profiles"):
                aws_config = Storage("~/.aws/config")
                aws_credentials = Storage("~/.aws/credentials")
                named_profiles = Storage("Named Profiles")

                aws_config >> named_profiles
                aws_credentials >> named_profiles

            # Environment Variables
            with Cluster("Environment Variables"):
                env_access_key = Storage("AWS_ACCESS_KEY_ID")
                env_secret_key = Storage("AWS_SECRET_ACCESS_KEY")
                env_session_token = Storage("AWS_SESSION_TOKEN")
                env_region = Storage("AWS_DEFAULT_REGION")

            # IAM Roles
            with Cluster("IAM Roles and Assume Role"):
                ec2_instance_profile = IAM("EC2 Instance Profile")
                assume_role = IAM("Assume Role")
                cross_account_role = IAM("Cross-Account Role")
                mfa_device = IAM("MFA Device")

            # AWS SSO
            with Cluster("AWS SSO Integration"):
                sso_config = Organizations("AWS SSO")
                sso_profiles = Storage("SSO Profiles")
                sso_cache = Storage("SSO Cache")

        # AWS Services Layer
        with Cluster("AWS Services"):
            iam_service = IAM("AWS IAM")
            sts_service = IAM("AWS STS")
            organizations = Organizations("AWS Organizations")

            # Target AWS Services
            with Cluster("Target AWS Resources"):
                ec2 = EC2("EC2")
                s3 = S3("S3")
                vpc = VPC("VPC")
                dynamodb = DynamodbTable("DynamoDB")

        # Security and Monitoring
        with Cluster("Security & Monitoring"):
            cloudtrail = Cloudtrail("CloudTrail")
            cloudwatch = Cloudwatch("CloudWatch")
            kms = KMS("KMS")

        # Authentication Flow Connections
        terraform_cli >> Edge(label="Profile Auth", color=COLORS['success']) >> named_profiles
        terraform_cli >> Edge(label="Env Vars", color=COLORS['accent']) >> env_access_key
        terraform_cli >> Edge(label="Instance Profile", color=COLORS['primary']) >> ec2_instance_profile
        terraform_cli >> Edge(label="Assume Role", color=COLORS['warning']) >> assume_role
        terraform_cli >> Edge(label="SSO", color=COLORS['secondary']) >> sso_config

        # AWS Service Connections
        [named_profiles, env_access_key, ec2_instance_profile, assume_role] >> iam_service
        assume_role >> sts_service
        sso_config >> organizations

        # MFA Integration
        assume_role >> Edge(label="MFA Required", style="dashed", color="red") >> mfa_device

        # Target Resource Access
        iam_service >> Edge(label="Authorized Access", color=COLORS['success']) >> [ec2, s3, vpc, dynamodb]

        # Security Monitoring
        [ec2, s3, vpc, dynamodb] >> cloudtrail
        cloudtrail >> cloudwatch
        iam_service >> kms

def create_multi_environment_setup():
    """
    Figure 2.3: Multi-Environment AWS Provider Configuration

    This diagram demonstrates how to configure multiple AWS providers
    for different environments and regions in a single Terraform configuration.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 2.3: Multi-Environment AWS Provider Configuration",
        filename=str(output_dir / "figure_2_3_multi_environment_setup"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Terraform Configuration Layer
        with Cluster("Terraform Configuration"):
            terraform_config = Terraform("terraform.tf")
            providers_config = Storage("providers.tf")
            variables_config = Storage("variables.tf")

            terraform_config >> [providers_config, variables_config]

        # Provider Configurations
        with Cluster("AWS Provider Configurations"):
            # Default Provider
            with Cluster("Default Provider"):
                default_provider = Storage("aws (default)")
                default_region = Storage("us-east-1")
                default_profile = Storage("default profile")

                default_provider >> [default_region, default_profile]

            # Aliased Providers
            with Cluster("Aliased Providers"):
                west_provider = Storage("aws.west")
                west_region = Storage("us-west-2")
                west_profile = Storage("west profile")

                eu_provider = Storage("aws.eu")
                eu_region = Storage("eu-west-1")
                eu_profile = Storage("eu profile")

                prod_provider = Storage("aws.prod")
                prod_account = Storage("prod account")
                prod_role = IAM("assume role")

                west_provider >> [west_region, west_profile]
                eu_provider >> [eu_region, eu_profile]
                prod_provider >> [prod_account, prod_role]

        # Environment-Specific Resources
        with Cluster("Environment-Specific Resources"):
            # Development Environment
            with Cluster("Development (us-east-1)"):
                dev_vpc = VPC("Dev VPC")
                dev_ec2 = EC2("Dev EC2")
                dev_s3 = S3("Dev S3")

                dev_vpc >> [dev_ec2, dev_s3]

            # Staging Environment
            with Cluster("Staging (us-west-2)"):
                staging_vpc = VPC("Staging VPC")
                staging_ec2 = EC2("Staging EC2")
                staging_rds = Storage("Staging RDS")

                staging_vpc >> [staging_ec2, staging_rds]

            # Production Environment
            with Cluster("Production (eu-west-1)"):
                prod_vpc = VPC("Prod VPC")
                prod_ec2 = EC2("Prod EC2")
                prod_rds = Storage("Prod RDS")
                prod_backup = S3("Prod Backup")

                prod_vpc >> [prod_ec2, prod_rds, prod_backup]

        # Cross-Region Replication
        with Cluster("Cross-Region Features"):
            replication = Storage("S3 Replication")
            backup_strategy = Storage("Cross-Region Backup")
            disaster_recovery = Storage("DR Strategy")

        # Provider to Resource Mapping
        providers_config >> default_provider >> Edge(label="deploys", color=COLORS['success']) >> dev_vpc
        providers_config >> west_provider >> Edge(label="deploys", color=COLORS['accent']) >> staging_vpc
        providers_config >> eu_provider >> Edge(label="deploys", color=COLORS['primary']) >> prod_vpc

        # Cross-region connections
        dev_s3 >> Edge(label="replicates", style="dashed", color=COLORS['warning']) >> replication
        staging_ec2 >> Edge(label="backup", style="dashed", color=COLORS['secondary']) >> backup_strategy
        prod_backup >> Edge(label="DR", style="dashed", color="red") >> disaster_recovery

def create_provider_configuration_patterns():
    """
    Figure 2.4: AWS Provider Configuration Patterns and Best Practices

    This diagram shows different configuration patterns for the AWS provider
    including security, performance, and operational considerations.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 2.4: AWS Provider Configuration Patterns and Best Practices",
        filename=str(output_dir / "figure_2_4_provider_configuration_patterns"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Configuration Categories
        with Cluster("Provider Configuration Categories"):
            # Basic Configuration
            with Cluster("Basic Configuration"):
                region_config = Storage("Region")
                profile_config = Storage("Profile")
                version_constraint = Storage("Version Constraint")

            # Security Configuration
            with Cluster("Security Configuration"):
                assume_role_config = IAM("Assume Role")
                mfa_config = IAM("MFA Configuration")
                external_id = Storage("External ID")
                session_name = Storage("Session Name")

            # Performance Configuration
            with Cluster("Performance Configuration"):
                retry_mode = Storage("Retry Mode")
                max_retries = Storage("Max Retries")
                http_timeout = Storage("HTTP Timeout")

            # Advanced Configuration
            with Cluster("Advanced Configuration"):
                custom_endpoints = Storage("Custom Endpoints")
                skip_validation = Storage("Skip Validation")
                default_tags = Storage("Default Tags")

        # Configuration Patterns
        with Cluster("Configuration Patterns"):
            # Development Pattern
            with Cluster("Development Pattern"):
                dev_simple = Storage("Simple Config")
                dev_local = Storage("Local Profile")
                dev_fast = Storage("Fast Iteration")

                dev_simple >> [dev_local, dev_fast]

            # Production Pattern
            with Cluster("Production Pattern"):
                prod_secure = IAM("Secure Config")
                prod_role = IAM("Role-based Auth")
                prod_monitoring = Cloudwatch("Enhanced Monitoring")
                prod_tags = Storage("Comprehensive Tags")

                prod_secure >> [prod_role, prod_monitoring, prod_tags]

            # Enterprise Pattern
            with Cluster("Enterprise Pattern"):
                enterprise_governance = Organizations("Governance")
                enterprise_compliance = Storage("Compliance")
                enterprise_audit = Cloudtrail("Audit Trail")
                enterprise_cost = Storage("Cost Controls")

                enterprise_governance >> [enterprise_compliance, enterprise_audit, enterprise_cost]

        # Best Practices
        with Cluster("Best Practices"):
            version_pinning = Storage("Version Pinning")
            least_privilege = IAM("Least Privilege")
            network_security = Storage("Network Security")
            cost_optimization = Storage("Cost Optimization")
            monitoring_logging = Cloudwatch("Monitoring & Logging")

        # Pattern Connections
        [region_config, profile_config, version_constraint] >> dev_simple
        [assume_role_config, mfa_config, external_id] >> prod_secure
        [custom_endpoints, default_tags, retry_mode] >> enterprise_governance

        # Best Practice Connections
        version_constraint >> version_pinning
        assume_role_config >> least_privilege
        custom_endpoints >> network_security
        default_tags >> cost_optimization
        [prod_monitoring, enterprise_audit] >> monitoring_logging

def create_development_workflow():
    """
    Figure 2.5: Terraform CLI Development Workflow and Best Practices

    This diagram illustrates the complete development workflow using Terraform CLI
    with AWS provider, including initialization, planning, applying, and maintenance.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 2.5: Terraform CLI Development Workflow and Best Practices",
        filename=str(output_dir / "figure_2_5_development_workflow"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Development Environment Setup
        with Cluster("Development Environment Setup"):
            developer = LocalUsers("Developer")
            ide = Storage("IDE/Editor")
            git_repo = Git("Git Repository")

            developer >> ide >> git_repo

        # Terraform CLI Workflow
        with Cluster("Terraform CLI Workflow"):
            # Initialization Phase
            with Cluster("1. Initialization"):
                terraform_init = Terraform("terraform init")
                provider_download = Storage("Provider Download")
                plugin_cache = Storage("Plugin Cache")
                backend_init = Storage("Backend Init")

                terraform_init >> [provider_download, plugin_cache, backend_init]

            # Planning Phase
            with Cluster("2. Planning"):
                terraform_plan = Terraform("terraform plan")
                plan_file = Storage("Plan File")
                change_preview = Storage("Change Preview")
                cost_estimation = Storage("Cost Estimation")

                terraform_plan >> [plan_file, change_preview, cost_estimation]

            # Validation Phase
            with Cluster("3. Validation"):
                terraform_validate = Terraform("terraform validate")
                terraform_fmt = Terraform("terraform fmt")
                security_scan = Storage("Security Scan")
                policy_check = Storage("Policy Check")

                terraform_validate >> [terraform_fmt, security_scan, policy_check]

            # Application Phase
            with Cluster("4. Application"):
                terraform_apply = Terraform("terraform apply")
                resource_creation = Storage("Resource Creation")
                state_update = Storage("State Update")
                output_values = Storage("Output Values")

                terraform_apply >> [resource_creation, state_update, output_values]

        # AWS Provider Integration
        with Cluster("AWS Provider Integration"):
            aws_authentication = IAM("AWS Authentication")
            aws_api_calls = Storage("AWS API Calls")
            aws_resources = Storage("AWS Resources")
            aws_monitoring = Cloudwatch("AWS Monitoring")

            aws_authentication >> aws_api_calls >> aws_resources >> aws_monitoring

        # State Management
        with Cluster("State Management"):
            local_state = Storage("Local State")
            remote_state = S3("Remote State (S3)")
            state_locking = DynamodbTable("State Locking")
            state_backup = Storage("State Backup")

            local_state >> remote_state >> state_locking
            remote_state >> state_backup

        # CI/CD Integration
        with Cluster("CI/CD Integration"):
            ci_pipeline = Jenkins("CI Pipeline")
            automated_testing = Storage("Automated Testing")
            deployment_approval = Storage("Deployment Approval")
            production_deploy = Storage("Production Deploy")

            ci_pipeline >> automated_testing >> deployment_approval >> production_deploy

        # Monitoring and Maintenance
        with Cluster("Monitoring and Maintenance"):
            drift_detection = Storage("Drift Detection")
            cost_monitoring = Storage("Cost Monitoring")
            security_monitoring = Cloudtrail("Security Monitoring")
            performance_monitoring = Cloudwatch("Performance Monitoring")

        # Workflow Connections
        git_repo >> Edge(label="clone/pull", color=COLORS['success']) >> terraform_init
        terraform_init >> Edge(label="next", color=COLORS['accent']) >> terraform_plan
        terraform_plan >> Edge(label="validate", color=COLORS['primary']) >> terraform_validate
        terraform_validate >> Edge(label="apply", color=COLORS['warning']) >> terraform_apply

        # AWS Integration
        terraform_apply >> Edge(label="authenticate", color=COLORS['secondary']) >> aws_authentication
        aws_resources >> Edge(label="monitor", color=COLORS['success']) >> aws_monitoring

        # State Management Integration
        terraform_apply >> Edge(label="update", color=COLORS['accent']) >> remote_state

        # CI/CD Integration
        git_repo >> Edge(label="trigger", style="dashed", color=COLORS['primary']) >> ci_pipeline
        production_deploy >> Edge(label="deploy", color=COLORS['warning']) >> aws_resources

        # Monitoring Integration
        aws_resources >> [drift_detection, cost_monitoring, security_monitoring, performance_monitoring]

def main():
    """
    Main function to generate all diagrams for Topic 2: Terraform CLI & AWS Provider Configuration
    """
    print("🎨 Generating Professional Terraform CLI & AWS Provider Configuration Diagrams...")
    print("=" * 80)

    try:
        # Ensure output directory exists
        output_dir = ensure_output_directory()
        print(f"📁 Output directory: {output_dir.absolute()}")

        # Generate all diagrams
        diagrams = [
            ("Figure 2.1: Terraform CLI Installation Methods", create_terraform_cli_installation_methods),
            ("Figure 2.2: AWS Authentication Flow", create_aws_authentication_flow),
            ("Figure 2.3: Multi-Environment Setup", create_multi_environment_setup),
            ("Figure 2.4: Provider Configuration Patterns", create_provider_configuration_patterns),
            ("Figure 2.5: Development Workflow", create_development_workflow)
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
        print("   • Diagrams are referenced in Concept.md and Lab-2.md")
        print("   • Use these diagrams to enhance learning and understanding")

    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        print("Please check your environment and dependencies.")
        sys.exit(1)

if __name__ == "__main__":
    main()

# Additional configuration for the second implementation
DPI = 300  # High resolution for professional quality
OUTPUT_DIR = Path("generated_diagrams")

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
        providers_tf >> Edge(label="config") >> dev_workspace
        variables_tf >> Edge(label="config") >> staging_workspace
        main_tf >> Edge(label="config") >> prod_workspace

        dev_vars >> dev_workspace >> Edge(label="deploy") >> dev_vpc
        dev_workspace >> dev_ec2
        staging_vars >> staging_workspace >> Edge(label="deploy") >> staging_vpc
        staging_workspace >> staging_ec2
        prod_vars >> prod_workspace >> Edge(label="deploy") >> prod_vpc
        prod_workspace >> prod_ec2

        dev_workspace >> Edge(label="state") >> s3_state
        staging_workspace >> Edge(label="state") >> s3_state
        prod_workspace >> Edge(label="state") >> s3_state
        dev_workspace >> Edge(label="locking") >> dynamodb_lock
        staging_workspace >> Edge(label="locking") >> dynamodb_lock
        prod_workspace >> Edge(label="locking") >> dynamodb_lock

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
        single_provider >> version_constraints >> east_vpc
        single_provider >> default_tags >> east_ec2
        
        primary_provider >> east_vpc
        primary_provider >> east_ec2
        secondary_provider >> west_vpc
        secondary_provider >> west_ec2
        
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
        
        validate >> git_repo >> ci_pipeline
        plan >> git_repo
        apply >> git_repo
        init >> s3_backend
        plan >> s3_backend
        apply >> s3_backend
        init >> state_locking
        plan >> state_locking
        apply >> state_locking
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
