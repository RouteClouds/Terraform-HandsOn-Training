#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 2: Terraform CLI & AWS Provider Configuration
Professional Diagram Generation Script (DaC - Diagram as Code)

This script generates 5 professional-quality diagrams for Topic 2 of the AWS Terraform
training curriculum. Each diagram is designed to support specific learning objectives
and enhance understanding of Terraform CLI installation, configuration, and AWS Provider setup.

Generated Diagrams:
1. Figure 2.1: Terraform CLI Installation and Setup Methods
2. Figure 2.2: AWS Provider Configuration and Authentication Flow
3. Figure 2.3: Terraform CLI Workflow and Command Structure
4. Figure 2.4: AWS Authentication Methods and Security Best Practices
5. Figure 2.5: Enterprise Terraform CLI Configuration and Management

Requirements:
- Python 3.9+
- All dependencies from requirements.txt
- Graphviz system installation
- 300 DPI output for professional quality

Author: AWS Terraform Training Team
Version: 2.0.0
Last Updated: January 2025
License: Educational Use
"""

import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple
import logging

# Configure logging for diagram generation tracking
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('diagram_generation.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Import required libraries with error handling
try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.aws.compute import EC2, Lambda
    from diagrams.aws.database import RDS
    from diagrams.aws.network import VPC
    from diagrams.aws.storage import S3
    from diagrams.aws.security import IAM, KMS
    from diagrams.aws.management import Cloudformation, Cloudwatch, Config
    from diagrams.aws.devtools import Codepipeline, Codebuild, Codecommit
    from diagrams.onprem.client import Users, Client
    from diagrams.onprem.vcs import Git
    from diagrams.programming.language import Python, Bash
    from diagrams.generic.blank import Blank
    from diagrams.generic.compute import Rack
    from diagrams.generic.os import Windows, LinuxGeneral, IOS
    from diagrams.generic.network import Firewall
    logger.info("Successfully imported all required diagram libraries")
except ImportError as e:
    logger.error(f"Failed to import required libraries: {e}")
    logger.error("Please install dependencies: pip install -r requirements.txt")
    sys.exit(1)

# AWS Brand Colors (Official AWS Design System)
AWS_COLORS = {
    'primary': '#FF9900',      # AWS Orange
    'secondary': '#232F3E',    # AWS Dark Blue  
    'accent': '#146EB4',       # AWS Blue
    'success': '#7AA116',      # AWS Green
    'warning': '#FF9900',      # AWS Orange
    'background': '#F2F3F3',   # Light Gray
    'text': '#232F3E',         # Dark Blue
    'white': '#FFFFFF',        # Pure White
    'light_blue': '#4B9CD3',   # Light Blue
    'dark_gray': '#5A6C7D'     # Dark Gray
}

# Professional Typography Settings
TYPOGRAPHY = {
    'title_size': 16,
    'subtitle_size': 14, 
    'heading_size': 12,
    'body_size': 10,
    'caption_size': 8
}

# Diagram Configuration
DIAGRAM_CONFIG = {
    'dpi': 300,                # High resolution for professional output
    'format': 'png',           # PNG format for web and print compatibility
    'background': 'white',     # Clean white background
    'fontsize': '12',          # Base font size
    'fontname': 'Arial',       # Professional font family
    'rankdir': 'TB',           # Top to bottom layout
    'splines': 'ortho',        # Orthogonal edge routing
    'nodesep': '0.8',          # Node separation
    'ranksep': '1.0'           # Rank separation
}

class TerraformCLIDiagramGenerator:
    """
    Professional diagram generator for Terraform CLI and AWS Provider configuration.
    
    This class provides methods to generate high-quality architectural diagrams
    that support the learning objectives of Topic 2: Terraform CLI & AWS Provider Configuration.
    """
    
    def __init__(self, output_dir: str = "generated_diagrams"):
        """
        Initialize the diagram generator.
        
        Args:
            output_dir (str): Directory to save generated diagrams
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        logger.info(f"Initialized diagram generator with output directory: {self.output_dir}")
        
        # Ensure output directory exists and is writable
        if not os.access(self.output_dir, os.W_OK):
            logger.error(f"Output directory {self.output_dir} is not writable")
            raise PermissionError(f"Cannot write to {self.output_dir}")
    
    def generate_all_diagrams(self) -> Dict[str, str]:
        """
        Generate all 5 professional diagrams for Topic 2.
        
        Returns:
            Dict[str, str]: Mapping of diagram names to file paths
        """
        logger.info("Starting generation of all Topic 2 diagrams")
        
        diagrams = {
            'figure_2_1': self.generate_terraform_installation_diagram(),
            'figure_2_2': self.generate_aws_provider_configuration_diagram(), 
            'figure_2_3': self.generate_terraform_cli_workflow_diagram(),
            'figure_2_4': self.generate_aws_authentication_methods_diagram(),
            'figure_2_5': self.generate_enterprise_terraform_configuration_diagram()
        }
        
        logger.info(f"Successfully generated {len(diagrams)} diagrams")
        return diagrams
    
    def generate_terraform_installation_diagram(self) -> str:
        """
        Generate Figure 2.1: Terraform CLI Installation and Setup Methods
        
        This diagram illustrates the various methods for installing and setting up
        Terraform CLI across different operating systems and environments.
        
        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 2.1: Terraform CLI Installation Methods")
        
        diagram_path = self.output_dir / "figure_2_1_terraform_installation_methods.png"
        
        with Diagram(
            "Figure 2.1: Terraform CLI Installation and Setup Methods",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="TB",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Operating Systems
            with Cluster("Operating System Support", graph_attr={"bgcolor": "#F0F8FF"}):
                windows = Windows("Windows\n10/11")
                linux = LinuxGeneral("Linux\nUbuntu/CentOS")
                macos = IOS("macOS\n10.15+")
            
            # Installation Methods
            with Cluster("Installation Methods", graph_attr={"bgcolor": "#FFF8DC"}):
                # Package Managers
                with Cluster("Package Managers", graph_attr={"bgcolor": "#F0FFF0"}):
                    chocolatey = Blank("Chocolatey\n(Windows)")
                    homebrew = Blank("Homebrew\n(macOS)")
                    apt = Blank("APT\n(Ubuntu)")
                    yum = Blank("YUM/DNF\n(CentOS)")
                
                # Direct Download
                with Cluster("Direct Download", graph_attr={"bgcolor": "#FFE6F3"}):
                    binary_download = Blank("Binary\nDownload")
                    zip_extract = Blank("ZIP\nExtraction")
                    path_setup = Blank("PATH\nConfiguration")
                
                # Container/Cloud
                with Cluster("Container & Cloud", graph_attr={"bgcolor": "#E6F3FF"}):
                    docker = Blank("Docker\nContainer")
                    cloud_shell = Blank("AWS Cloud\nShell")
                    terraform_cloud = Blank("Terraform\nCloud")
            
            # Version Management
            with Cluster("Version Management", graph_attr={"bgcolor": "#FFFACD"}):
                tfenv = Blank("tfenv\nVersion Manager")
                tfswitch = Blank("tfswitch\nSwitcher")
                version_check = Blank("terraform\nversion")
            
            # Connections
            windows >> chocolatey
            windows >> binary_download
            windows >> docker
            
            linux >> apt
            linux >> yum
            linux >> binary_download
            linux >> docker
            
            macos >> homebrew
            macos >> binary_download
            macos >> docker
            
            binary_download >> zip_extract >> path_setup
            
            chocolatey >> tfenv
            homebrew >> tfenv
            apt >> tfswitch
            
            tfenv >> version_check
            tfswitch >> version_check
        
        logger.info(f"Generated Figure 2.1 at: {diagram_path}")
        return str(diagram_path)

    def generate_aws_provider_configuration_diagram(self) -> str:
        """
        Generate Figure 2.2: AWS Provider Configuration and Authentication Flow

        This diagram shows the AWS Provider configuration process and various
        authentication methods available for Terraform AWS integration.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 2.2: AWS Provider Configuration")

        diagram_path = self.output_dir / "figure_2_2_aws_provider_configuration.png"

        with Diagram(
            "Figure 2.2: AWS Provider Configuration and Authentication Flow",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="TB",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Terraform Configuration
            with Cluster("Terraform Configuration", graph_attr={"bgcolor": "#F0F8FF"}):
                terraform_config = Python("terraform {\n  required_providers {\n    aws = {\n      source = \"hashicorp/aws\"\n      version = \"~> 6.12.0\"\n    }\n  }\n}")
                provider_config = Python("provider \"aws\" {\n  region = \"us-east-1\"\n  profile = \"default\"\n}")

            # Authentication Methods
            with Cluster("AWS Authentication Methods", graph_attr={"bgcolor": "#FFF8DC"}):
                # Environment Variables
                with Cluster("Environment Variables", graph_attr={"bgcolor": "#F0FFF0"}):
                    aws_access_key = Blank("AWS_ACCESS_KEY_ID")
                    aws_secret_key = Blank("AWS_SECRET_ACCESS_KEY")
                    aws_region = Blank("AWS_DEFAULT_REGION")

                # AWS CLI Profiles
                with Cluster("AWS CLI Profiles", graph_attr={"bgcolor": "#FFE6F3"}):
                    aws_credentials = Blank("~/.aws/credentials")
                    aws_config = Blank("~/.aws/config")
                    profile_selection = Blank("profile = \"prod\"")

                # IAM Roles
                with Cluster("IAM Roles", graph_attr={"bgcolor": "#E6F3FF"}):
                    assume_role = IAM("AssumeRole")
                    instance_profile = EC2("Instance\nProfile")
                    oidc_provider = IAM("OIDC\nProvider")

            # AWS Services Integration
            with Cluster("AWS Services", graph_attr={"bgcolor": "#FFFACD"}):
                iam_service = IAM("AWS IAM")
                sts_service = Blank("AWS STS")
                organizations = Blank("AWS\nOrganizations")

            # Security Best Practices
            with Cluster("Security Best Practices", graph_attr={"bgcolor": "#F5F5DC"}):
                mfa_enabled = Blank("MFA\nEnabled")
                least_privilege = Blank("Least\nPrivilege")
                rotation_policy = Blank("Key\nRotation")
                audit_logging = Cloudwatch("CloudTrail\nLogging")

            # Connections
            terraform_config >> provider_config

            provider_config >> aws_access_key
            provider_config >> aws_credentials
            provider_config >> assume_role

            aws_credentials >> profile_selection
            aws_config >> profile_selection

            assume_role >> sts_service
            instance_profile >> sts_service
            oidc_provider >> sts_service

            sts_service >> iam_service
            iam_service >> organizations

            iam_service >> mfa_enabled
            iam_service >> least_privilege
            iam_service >> rotation_policy
            iam_service >> audit_logging

        logger.info(f"Generated Figure 2.2 at: {diagram_path}")
        return str(diagram_path)

    def generate_terraform_cli_workflow_diagram(self) -> str:
        """
        Generate Figure 2.3: Terraform CLI Workflow and Command Structure

        This diagram illustrates the complete Terraform CLI workflow from
        initialization through deployment and management.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 2.3: Terraform CLI Workflow")

        diagram_path = self.output_dir / "figure_2_3_terraform_cli_workflow.png"

        with Diagram(
            "Figure 2.3: Terraform CLI Workflow and Command Structure",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="LR",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Initialization Phase
            with Cluster("1. Initialization", graph_attr={"bgcolor": "#E6F3FF"}):
                terraform_init = Bash("terraform init")
                provider_download = Blank("Provider\nDownload")
                backend_config = Blank("Backend\nConfiguration")
                module_download = Blank("Module\nDownload")

                terraform_init >> provider_download
                terraform_init >> backend_config
                terraform_init >> module_download

            # Validation Phase
            with Cluster("2. Validation", graph_attr={"bgcolor": "#F0FFF0"}):
                terraform_validate = Bash("terraform validate")
                terraform_fmt = Bash("terraform fmt")
                syntax_check = Blank("Syntax\nValidation")
                format_check = Blank("Format\nValidation")

                terraform_validate >> syntax_check
                terraform_fmt >> format_check

            # Planning Phase
            with Cluster("3. Planning", graph_attr={"bgcolor": "#FFF8DC"}):
                terraform_plan = Bash("terraform plan")
                plan_output = Blank("Execution\nPlan")
                resource_diff = Blank("Resource\nDifferences")
                cost_estimation = Blank("Cost\nEstimation")

                terraform_plan >> plan_output
                terraform_plan >> resource_diff
                terraform_plan >> cost_estimation

            # Application Phase
            with Cluster("4. Application", graph_attr={"bgcolor": "#FFE6F3"}):
                terraform_apply = Bash("terraform apply")
                resource_creation = Blank("Resource\nCreation")
                state_update = Blank("State\nUpdate")
                output_display = Blank("Output\nDisplay")

                terraform_apply >> resource_creation
                terraform_apply >> state_update
                terraform_apply >> output_display

            # Management Phase
            with Cluster("5. Management", graph_attr={"bgcolor": "#F5F5DC"}):
                terraform_show = Bash("terraform show")
                terraform_state = Bash("terraform state")
                terraform_destroy = Bash("terraform destroy")

            # Flow connections
            provider_download >> Edge(label="next") >> terraform_validate
            syntax_check >> Edge(label="next") >> terraform_plan
            plan_output >> Edge(label="approve") >> terraform_apply
            state_update >> Edge(label="manage") >> terraform_show

        logger.info(f"Generated Figure 2.3 at: {diagram_path}")
        return str(diagram_path)

    def generate_aws_authentication_methods_diagram(self) -> str:
        """
        Generate Figure 2.4: AWS Authentication Methods and Security Best Practices

        This diagram provides a comprehensive view of AWS authentication methods
        and security best practices for Terraform deployments.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 2.4: AWS Authentication Methods")

        diagram_path = self.output_dir / "figure_2_4_aws_authentication_methods.png"

        with Diagram(
            "Figure 2.4: AWS Authentication Methods and Security Best Practices",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="TB",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Development Environment
            with Cluster("Development Environment", graph_attr={"bgcolor": "#E6F3FF"}):
                dev_user = Users("Developer")
                aws_cli = Bash("AWS CLI")
                local_credentials = Blank("Local\nCredentials")

                dev_user >> aws_cli >> local_credentials

            # Authentication Methods
            with Cluster("Authentication Methods", graph_attr={"bgcolor": "#FFF8DC"}):
                # Static Credentials (Not Recommended)
                with Cluster("Static Credentials (Dev Only)", graph_attr={"bgcolor": "#FFE6E6"}):
                    access_keys = Blank("Access Keys")
                    env_vars = Blank("Environment\nVariables")
                    credential_files = Blank("Credential\nFiles")

                # Dynamic Credentials (Recommended)
                with Cluster("Dynamic Credentials (Recommended)", graph_attr={"bgcolor": "#E6FFE6"}):
                    iam_roles = IAM("IAM Roles")
                    assume_role = IAM("AssumeRole")
                    oidc_federation = IAM("OIDC\nFederation")
                    saml_federation = IAM("SAML\nFederation")

            # CI/CD Integration
            with Cluster("CI/CD Integration", graph_attr={"bgcolor": "#F0FFF0"}):
                github_actions = Blank("GitHub\nActions")
                gitlab_ci = Blank("GitLab CI")
                jenkins = Blank("Jenkins")
                terraform_cloud = Blank("Terraform\nCloud")

                github_actions >> oidc_federation
                gitlab_ci >> oidc_federation
                jenkins >> assume_role
                terraform_cloud >> assume_role

            # Security Best Practices
            with Cluster("Security Best Practices", graph_attr={"bgcolor": "#FFFACD"}):
                mfa_enforcement = Blank("MFA\nEnforcement")
                principle_least_privilege = Blank("Least\nPrivilege")
                credential_rotation = Blank("Credential\nRotation")
                audit_trails = Cloudwatch("Audit\nTrails")

            # AWS Services
            with Cluster("AWS Security Services", graph_attr={"bgcolor": "#F5F5DC"}):
                aws_iam = IAM("AWS IAM")
                aws_sts = Blank("AWS STS")
                aws_cloudtrail = Cloudwatch("AWS CloudTrail")
                aws_config = Config("AWS Config")

            # Connections
            local_credentials >> access_keys
            local_credentials >> env_vars
            local_credentials >> credential_files

            iam_roles >> assume_role
            assume_role >> aws_sts
            oidc_federation >> aws_sts
            saml_federation >> aws_sts

            aws_sts >> aws_iam
            aws_iam >> mfa_enforcement
            aws_iam >> principle_least_privilege
            aws_iam >> credential_rotation
            aws_iam >> audit_trails

            audit_trails >> aws_cloudtrail
            aws_cloudtrail >> aws_config

        logger.info(f"Generated Figure 2.4 at: {diagram_path}")
        return str(diagram_path)

    def generate_enterprise_terraform_configuration_diagram(self) -> str:
        """
        Generate Figure 2.5: Enterprise Terraform CLI Configuration and Management

        This diagram illustrates enterprise-scale Terraform CLI configuration,
        including team collaboration, state management, and governance.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 2.5: Enterprise Terraform Configuration")

        diagram_path = self.output_dir / "figure_2_5_enterprise_terraform_configuration.png"

        with Diagram(
            "Figure 2.5: Enterprise Terraform CLI Configuration and Management",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="TB",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Team Structure
            with Cluster("Development Teams", graph_attr={"bgcolor": "#E6F3FF"}):
                platform_team = Users("Platform\nTeam")
                app_team_1 = Users("App Team\nAlpha")
                app_team_2 = Users("App Team\nBeta")
                security_team = Users("Security\nTeam")

            # Terraform Configuration Management
            with Cluster("Terraform Configuration Management", graph_attr={"bgcolor": "#FFF8DC"}):
                # Version Management
                with Cluster("Version Management", graph_attr={"bgcolor": "#F0FFF0"}):
                    terraform_version = Blank("Terraform\n~> 1.13.0")
                    provider_versions = Blank("Provider\nVersions")
                    version_constraints = Blank("Version\nConstraints")

                # Configuration Standards
                with Cluster("Configuration Standards", graph_attr={"bgcolor": "#FFE6F3"}):
                    coding_standards = Blank("Coding\nStandards")
                    naming_conventions = Blank("Naming\nConventions")
                    tagging_strategy = Blank("Tagging\nStrategy")
                    security_policies = Blank("Security\nPolicies")

            # State Management
            with Cluster("State Management", graph_attr={"bgcolor": "#F0FFF0"}):
                remote_backend = S3("S3 Remote\nBackend")
                state_locking = Blank("DynamoDB\nLocking")
                state_encryption = KMS("State\nEncryption")
                backup_strategy = Blank("Backup\nStrategy")

                remote_backend >> state_locking
                remote_backend >> state_encryption
                remote_backend >> backup_strategy

            # Governance and Compliance
            with Cluster("Governance & Compliance", graph_attr={"bgcolor": "#FFFACD"}):
                policy_enforcement = Blank("Policy\nEnforcement")
                compliance_scanning = Blank("Compliance\nScanning")
                cost_controls = Blank("Cost\nControls")
                access_controls = IAM("Access\nControls")

            # CI/CD Integration
            with Cluster("CI/CD Pipeline", graph_attr={"bgcolor": "#F5F5DC"}):
                source_control = Git("Git\nRepository")
                ci_pipeline = Codepipeline("CI/CD\nPipeline")
                automated_testing = Blank("Automated\nTesting")
                deployment_gates = Blank("Deployment\nGates")

                source_control >> ci_pipeline
                ci_pipeline >> automated_testing
                ci_pipeline >> deployment_gates

            # Monitoring and Observability
            with Cluster("Monitoring & Observability", graph_attr={"bgcolor": "#E6FFE6"}):
                infrastructure_monitoring = Cloudwatch("Infrastructure\nMonitoring")
                cost_monitoring = Blank("Cost\nMonitoring")
                security_monitoring = Blank("Security\nMonitoring")
                compliance_reporting = Blank("Compliance\nReporting")

            # Team connections to configuration
            platform_team >> terraform_version
            platform_team >> coding_standards
            platform_team >> remote_backend

            app_team_1 >> provider_versions
            app_team_2 >> provider_versions

            security_team >> security_policies
            security_team >> access_controls
            security_team >> compliance_scanning

            # Configuration flow
            terraform_version >> ci_pipeline
            coding_standards >> automated_testing
            remote_backend >> deployment_gates

            # Monitoring connections
            deployment_gates >> infrastructure_monitoring
            cost_controls >> cost_monitoring
            security_policies >> security_monitoring
            compliance_scanning >> compliance_reporting

        logger.info(f"Generated Figure 2.5 at: {diagram_path}")
        return str(diagram_path)


def main():
    """
    Main execution function for generating all Topic 2 diagrams.

    This function initializes the diagram generator and creates all 5 professional
    diagrams for the Terraform CLI & AWS Provider Configuration topic.
    """
    logger.info("Starting AWS Terraform Training Topic 2 diagram generation")

    try:
        # Initialize diagram generator
        generator = TerraformCLIDiagramGenerator()

        # Generate all diagrams
        diagrams = generator.generate_all_diagrams()

        # Report generation results
        logger.info("=" * 80)
        logger.info("DIAGRAM GENERATION COMPLETE")
        logger.info("=" * 80)

        for diagram_name, file_path in diagrams.items():
            logger.info(f"✅ {diagram_name}: {file_path}")

        logger.info("=" * 80)
        logger.info("All diagrams generated successfully!")
        logger.info("Integration instructions:")
        logger.info("1. Review generated diagrams in the generated_diagrams/ directory")
        logger.info("2. Integrate diagrams into training materials using figure references")
        logger.info("3. Update README.md with diagram descriptions and usage")
        logger.info("4. Ensure diagrams support learning objectives in Concept.md")
        logger.info("=" * 80)

        return True

    except Exception as e:
        logger.error(f"Failed to generate diagrams: {e}")
        logger.error("Please check system requirements and dependencies")
        return False


if __name__ == "__main__":
    """
    Script entry point for command-line execution.

    Usage:
        python diagram_generation_script.py

    Requirements:
        - Python 3.9+
        - All dependencies from requirements.txt installed
        - Graphviz system installation
        - Write permissions in current directory
    """
    success = main()
    sys.exit(0 if success else 1)
