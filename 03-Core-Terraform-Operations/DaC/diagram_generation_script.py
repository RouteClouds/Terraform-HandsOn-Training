#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 3: Core Terraform Operations
Professional Diagram Generation Script (DaC - Diagram as Code)

This script generates 5 professional-quality diagrams for Topic 3 of the AWS Terraform
training curriculum. Each diagram is designed to support specific learning objectives
and enhance understanding of core Terraform operations including resource management,
data sources, provisioners, and lifecycle management.

Generated Diagrams:
1. Figure 3.1: Terraform Resource Lifecycle and Management
2. Figure 3.2: Data Sources and Resource Dependencies
3. Figure 3.3: Provisioners and Configuration Management
4. Figure 3.4: Resource Meta-Arguments and Lifecycle Rules
5. Figure 3.5: Enterprise Resource Organization and Patterns

Requirements:
- Python 3.9+
- All dependencies from requirements.txt
- Graphviz system installation
- 300 DPI output for professional quality

Author: AWS Terraform Training Team
Version: 3.0.0
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
    from diagrams.aws.compute import EC2, Lambda, ECS
    from diagrams.aws.database import RDS, Dynamodb
    from diagrams.aws.network import VPC, ELB, CloudFront
    from diagrams.aws.storage import S3
    from diagrams.aws.security import IAM, KMS
    from diagrams.aws.management import Cloudformation, Cloudwatch, Config
    from diagrams.aws.devtools import Codepipeline, Codebuild, Codecommit
    from diagrams.aws.analytics import Athena, Glue
    from diagrams.onprem.client import Users, Client
    from diagrams.onprem.vcs import Git
    from diagrams.programming.language import Python, Bash
    from diagrams.generic.blank import Blank
    from diagrams.generic.compute import Rack
    from diagrams.generic.database import SQL
    from diagrams.generic.network import Firewall
    from diagrams.generic.os import LinuxGeneral, Windows, IOS
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

class CoreTerraformOperationsDiagramGenerator:
    """
    Professional diagram generator for Core Terraform Operations.
    
    This class provides methods to generate high-quality architectural diagrams
    that support the learning objectives of Topic 3: Core Terraform Operations.
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
        Generate all 5 professional diagrams for Topic 3.
        
        Returns:
            Dict[str, str]: Mapping of diagram names to file paths
        """
        logger.info("Starting generation of all Topic 3 diagrams")
        
        diagrams = {
            'figure_3_1': self.generate_resource_lifecycle_diagram(),
            'figure_3_2': self.generate_data_sources_dependencies_diagram(), 
            'figure_3_3': self.generate_provisioners_configuration_diagram(),
            'figure_3_4': self.generate_meta_arguments_lifecycle_diagram(),
            'figure_3_5': self.generate_enterprise_resource_organization_diagram()
        }
        
        logger.info(f"Successfully generated {len(diagrams)} diagrams")
        return diagrams
    
    def generate_resource_lifecycle_diagram(self) -> str:
        """
        Generate Figure 3.1: Terraform Resource Lifecycle and Management
        
        This diagram illustrates the complete lifecycle of Terraform resources
        from creation through updates to destruction, including state management.
        
        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 3.1: Resource Lifecycle and Management")
        
        diagram_path = self.output_dir / "figure_3_1_resource_lifecycle_management.png"
        
        with Diagram(
            "Figure 3.1: Terraform Resource Lifecycle and Management",
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
            # Configuration Phase
            with Cluster("1. Configuration Phase", graph_attr={"bgcolor": "#E6F3FF"}):
                terraform_config = Python("Terraform\nConfiguration")
                resource_blocks = Blank("Resource\nBlocks")
                data_sources = Blank("Data\nSources")
                variables = Blank("Variables &\nLocals")
                
                terraform_config >> resource_blocks
                terraform_config >> data_sources
                terraform_config >> variables
            
            # Planning Phase
            with Cluster("2. Planning Phase", graph_attr={"bgcolor": "#FFF8DC"}):
                terraform_plan = Bash("terraform plan")
                dependency_graph = Blank("Dependency\nGraph")
                resource_diff = Blank("Resource\nDifferences")
                execution_plan = Blank("Execution\nPlan")
                
                terraform_plan >> dependency_graph
                terraform_plan >> resource_diff
                terraform_plan >> execution_plan
            
            # Resource Lifecycle States
            with Cluster("3. Resource Lifecycle States", graph_attr={"bgcolor": "#F0FFF0"}):
                # Creation
                with Cluster("Creation", graph_attr={"bgcolor": "#E6FFE6"}):
                    create_action = Blank("CREATE")
                    new_resource = EC2("New\nResource")
                
                # Update
                with Cluster("Update", graph_attr={"bgcolor": "#FFFACD"}):
                    update_action = Blank("UPDATE")
                    modified_resource = EC2("Modified\nResource")
                
                # Replacement
                with Cluster("Replacement", graph_attr={"bgcolor": "#FFE6E6"}):
                    replace_action = Blank("REPLACE")
                    replaced_resource = EC2("Replaced\nResource")
                
                # Destruction
                with Cluster("Destruction", graph_attr={"bgcolor": "#F5F5F5"}):
                    destroy_action = Blank("DESTROY")
                    removed_resource = Blank("Removed\nResource")
            
            # State Management
            with Cluster("4. State Management", graph_attr={"bgcolor": "#F5F5DC"}):
                terraform_state = S3("Terraform\nState")
                state_lock = Dynamodb("State\nLock")
                backup_state = S3("State\nBackup")
                
                terraform_state >> state_lock
                terraform_state >> backup_state
            
            # Connections showing lifecycle flow
            resource_blocks >> Edge(label="analyzed") >> dependency_graph
            execution_plan >> Edge(label="creates") >> create_action
            execution_plan >> Edge(label="updates") >> update_action
            execution_plan >> Edge(label="replaces") >> replace_action
            execution_plan >> Edge(label="destroys") >> destroy_action
            
            create_action >> new_resource >> terraform_state
            update_action >> modified_resource >> terraform_state
            replace_action >> replaced_resource >> terraform_state
            destroy_action >> removed_resource >> terraform_state
        
        logger.info(f"Generated Figure 3.1 at: {diagram_path}")
        return str(diagram_path)

    def generate_data_sources_dependencies_diagram(self) -> str:
        """
        Generate Figure 3.2: Data Sources and Resource Dependencies

        This diagram shows how data sources work with resources and the
        dependency relationships that Terraform manages automatically.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 3.2: Data Sources and Dependencies")

        diagram_path = self.output_dir / "figure_3_2_data_sources_dependencies.png"

        with Diagram(
            "Figure 3.2: Data Sources and Resource Dependencies",
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
            # Data Sources
            with Cluster("Data Sources (Read-Only)", graph_attr={"bgcolor": "#E6F3FF"}):
                # AWS Data Sources
                with Cluster("AWS Data Sources", graph_attr={"bgcolor": "#F0F8FF"}):
                    data_vpc = VPC("data.aws_vpc")
                    data_subnets = Blank("data.aws_subnets")
                    data_ami = EC2("data.aws_ami")
                    data_availability_zones = Blank("data.aws_availability_zones")

                # External Data Sources
                with Cluster("External Data Sources", graph_attr={"bgcolor": "#F5F5FF"}):
                    data_external = Blank("data.external")
                    data_http = Blank("data.http")
                    data_template = Blank("data.template_file")

            # Resources (Managed)
            with Cluster("Resources (Managed)", graph_attr={"bgcolor": "#F0FFF0"}):
                # Network Resources
                with Cluster("Network Resources", graph_attr={"bgcolor": "#E6FFE6"}):
                    vpc_resource = VPC("aws_vpc.main")
                    subnet_resource = Blank("aws_subnet.private")
                    security_group = Firewall("aws_security_group.web")

                # Compute Resources
                with Cluster("Compute Resources", graph_attr={"bgcolor": "#F0FFF0"}):
                    ec2_instance = EC2("aws_instance.web")
                    launch_template = Blank("aws_launch_template.app")
                    auto_scaling = Blank("aws_autoscaling_group.app")

                # Storage Resources
                with Cluster("Storage Resources", graph_attr={"bgcolor": "#FFF8F0"}):
                    s3_bucket = S3("aws_s3_bucket.data")
                    ebs_volume = Blank("aws_ebs_volume.data")

            # Dependency Relationships
            with Cluster("Dependency Management", graph_attr={"bgcolor": "#FFFACD"}):
                implicit_deps = Blank("Implicit\nDependencies")
                explicit_deps = Blank("Explicit\nDependencies")
                dependency_graph = Blank("Dependency\nGraph")

                implicit_deps >> dependency_graph
                explicit_deps >> dependency_graph

            # Data flow connections
            data_vpc >> Edge(label="provides VPC ID") >> subnet_resource
            data_subnets >> Edge(label="provides subnet IDs") >> ec2_instance
            data_ami >> Edge(label="provides AMI ID") >> launch_template
            data_availability_zones >> Edge(label="provides AZ list") >> auto_scaling

            # Resource dependencies
            vpc_resource >> Edge(label="creates") >> subnet_resource
            subnet_resource >> Edge(label="required by") >> ec2_instance
            security_group >> Edge(label="attached to") >> ec2_instance
            ec2_instance >> Edge(label="depends on") >> ebs_volume

            # Dependency tracking
            subnet_resource >> implicit_deps
            ec2_instance >> implicit_deps
            s3_bucket >> explicit_deps

        logger.info(f"Generated Figure 3.2 at: {diagram_path}")
        return str(diagram_path)

    def generate_provisioners_configuration_diagram(self) -> str:
        """
        Generate Figure 3.3: Provisioners and Configuration Management

        This diagram illustrates different types of provisioners and their
        use cases in Terraform resource configuration.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 3.3: Provisioners and Configuration")

        diagram_path = self.output_dir / "figure_3_3_provisioners_configuration.png"

        with Diagram(
            "Figure 3.3: Provisioners and Configuration Management",
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
            # Resource Creation
            with Cluster("Resource Creation", graph_attr={"bgcolor": "#E6F3FF"}):
                ec2_resource = EC2("aws_instance.web")
                resource_created = Blank("Resource\nCreated")

                ec2_resource >> resource_created

            # Provisioner Types
            with Cluster("Provisioner Types", graph_attr={"bgcolor": "#FFF8DC"}):
                # Local Provisioners
                with Cluster("Local Provisioners", graph_attr={"bgcolor": "#F0FFF0"}):
                    local_exec = Bash("local-exec")
                    local_script = Blank("Local\nScript")

                    local_exec >> local_script

                # Remote Provisioners
                with Cluster("Remote Provisioners", graph_attr={"bgcolor": "#FFE6F3"}):
                    remote_exec = Bash("remote-exec")
                    file_provisioner = Blank("file")
                    remote_script = Bash("Remote\nScript")

                    remote_exec >> remote_script
                    file_provisioner >> remote_script

                # Connection Configuration
                with Cluster("Connection", graph_attr={"bgcolor": "#F5F5DC"}):
                    ssh_connection = Blank("SSH\nConnection")
                    winrm_connection = Blank("WinRM\nConnection")

            # Configuration Management
            with Cluster("Configuration Management", graph_attr={"bgcolor": "#FFFACD"}):
                # Software Installation
                with Cluster("Software Installation", graph_attr={"bgcolor": "#F0F8F0"}):
                    package_install = Blank("Package\nInstallation")
                    service_config = Blank("Service\nConfiguration")
                    app_deployment = Blank("Application\nDeployment")

                # File Management
                with Cluster("File Management", graph_attr={"bgcolor": "#F8F0F8"}):
                    config_files = Blank("Configuration\nFiles")
                    certificates = Blank("SSL\nCertificates")
                    scripts = Bash("Startup\nScripts")

            # Best Practices
            with Cluster("Best Practices", graph_attr={"bgcolor": "#F5F5F5"}):
                idempotency = Blank("Idempotent\nOperations")
                error_handling = Blank("Error\nHandling")
                alternatives = Blank("Consider\nAlternatives")

            # Connections
            resource_created >> Edge(label="triggers") >> local_exec
            resource_created >> Edge(label="triggers") >> remote_exec
            resource_created >> Edge(label="triggers") >> file_provisioner

            remote_exec >> ssh_connection
            remote_exec >> winrm_connection
            file_provisioner >> ssh_connection

            local_script >> package_install
            remote_script >> service_config
            remote_script >> app_deployment

            file_provisioner >> config_files
            file_provisioner >> certificates
            file_provisioner >> scripts

            package_install >> idempotency
            service_config >> error_handling
            app_deployment >> alternatives

        logger.info(f"Generated Figure 3.3 at: {diagram_path}")
        return str(diagram_path)

    def generate_meta_arguments_lifecycle_diagram(self) -> str:
        """
        Generate Figure 3.4: Resource Meta-Arguments and Lifecycle Rules

        This diagram demonstrates Terraform meta-arguments and lifecycle
        management rules for advanced resource control.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 3.4: Meta-Arguments and Lifecycle")

        diagram_path = self.output_dir / "figure_3_4_meta_arguments_lifecycle.png"

        with Diagram(
            "Figure 3.4: Resource Meta-Arguments and Lifecycle Rules",
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
            # Meta-Arguments
            with Cluster("Meta-Arguments", graph_attr={"bgcolor": "#E6F3FF"}):
                # Count and For Each
                with Cluster("Iteration", graph_attr={"bgcolor": "#F0F8FF"}):
                    count_arg = Blank("count")
                    for_each_arg = Blank("for_each")
                    multiple_instances = EC2("Multiple\nInstances")

                    count_arg >> multiple_instances
                    for_each_arg >> multiple_instances

                # Dependencies
                with Cluster("Dependencies", graph_attr={"bgcolor": "#F5F5FF"}):
                    depends_on = Blank("depends_on")
                    explicit_deps = Blank("Explicit\nDependencies")

                    depends_on >> explicit_deps

                # Provider Selection
                with Cluster("Provider", graph_attr={"bgcolor": "#F8F8FF"}):
                    provider_arg = Blank("provider")
                    provider_alias = Blank("Provider\nAlias")

                    provider_arg >> provider_alias

            # Lifecycle Rules
            with Cluster("Lifecycle Rules", graph_attr={"bgcolor": "#FFF8DC"}):
                lifecycle_block = Blank("lifecycle")

                # Lifecycle Options
                with Cluster("Lifecycle Options", graph_attr={"bgcolor": "#FFFACD"}):
                    create_before_destroy = Blank("create_before_destroy")
                    prevent_destroy = Blank("prevent_destroy")
                    ignore_changes = Blank("ignore_changes")
                    replace_triggered_by = Blank("replace_triggered_by")

                    lifecycle_block >> create_before_destroy
                    lifecycle_block >> prevent_destroy
                    lifecycle_block >> ignore_changes
                    lifecycle_block >> replace_triggered_by

            # Resource Examples
            with Cluster("Resource Examples", graph_attr={"bgcolor": "#F0FFF0"}):
                # Database with Protection
                with Cluster("Protected Database", graph_attr={"bgcolor": "#E6FFE6"}):
                    protected_db = RDS("aws_db_instance")
                    protection_rule = Blank("prevent_destroy\n= true")

                    protected_db >> protection_rule

                # Load Balancer with Replacement
                with Cluster("Load Balancer", graph_attr={"bgcolor": "#F0FFF0"}):
                    load_balancer = ELB("aws_lb")
                    replacement_rule = Blank("create_before_destroy\n= true")

                    load_balancer >> replacement_rule

                # Auto Scaling Group
                with Cluster("Auto Scaling", graph_attr={"bgcolor": "#FFF8F0"}):
                    asg = Blank("aws_autoscaling_group")
                    ignore_rule = Blank("ignore_changes\n= [desired_capacity]")

                    asg >> ignore_rule

            # Best Practices
            with Cluster("Best Practices", graph_attr={"bgcolor": "#F5F5DC"}):
                careful_usage = Blank("Use Meta-Arguments\nCarefully")
                test_lifecycle = Blank("Test Lifecycle\nRules")
                document_decisions = Blank("Document\nDecisions")

                create_before_destroy >> careful_usage
                prevent_destroy >> test_lifecycle
                ignore_changes >> document_decisions

        logger.info(f"Generated Figure 3.4 at: {diagram_path}")
        return str(diagram_path)

    def generate_enterprise_resource_organization_diagram(self) -> str:
        """
        Generate Figure 3.5: Enterprise Resource Organization and Patterns

        This diagram shows enterprise patterns for organizing and managing
        Terraform resources at scale.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 3.5: Enterprise Resource Organization")

        diagram_path = self.output_dir / "figure_3_5_enterprise_resource_organization.png"

        with Diagram(
            "Figure 3.5: Enterprise Resource Organization and Patterns",
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
            # Resource Organization Layers
            with Cluster("Resource Organization Layers", graph_attr={"bgcolor": "#E6F3FF"}):
                # Foundation Layer
                with Cluster("Foundation Layer", graph_attr={"bgcolor": "#F0F8FF"}):
                    vpc_foundation = VPC("VPC & Networking")
                    iam_foundation = IAM("IAM & Security")
                    dns_foundation = Blank("DNS & Domains")

                # Platform Layer
                with Cluster("Platform Layer", graph_attr={"bgcolor": "#F5F5FF"}):
                    compute_platform = EC2("Compute Platform")
                    data_platform = RDS("Data Platform")
                    monitoring_platform = Cloudwatch("Monitoring Platform")

                # Application Layer
                with Cluster("Application Layer", graph_attr={"bgcolor": "#F8F8FF"}):
                    web_apps = Lambda("Web Applications")
                    api_services = ECS("API Services")
                    batch_jobs = Blank("Batch Jobs")

            # Resource Patterns
            with Cluster("Enterprise Resource Patterns", graph_attr={"bgcolor": "#FFF8DC"}):
                # Naming Conventions
                with Cluster("Naming Conventions", graph_attr={"bgcolor": "#FFFACD"}):
                    naming_standard = Blank("Environment-Project-\nResource-Instance")
                    tag_strategy = Blank("Comprehensive\nTagging Strategy")
                    resource_hierarchy = Blank("Resource\nHierarchy")

                # Module Organization
                with Cluster("Module Organization", graph_attr={"bgcolor": "#FFF8E1"}):
                    shared_modules = Blank("Shared\nModules")
                    team_modules = Blank("Team-Specific\nModules")
                    application_modules = Blank("Application\nModules")

                # State Management
                with Cluster("State Management", graph_attr={"bgcolor": "#F8F8DC"}):
                    state_separation = S3("Separated\nState Files")
                    workspace_strategy = Blank("Workspace\nStrategy")
                    state_locking = Dynamodb("State\nLocking")

            # Governance and Compliance
            with Cluster("Governance & Compliance", graph_attr={"bgcolor": "#F0FFF0"}):
                # Policy Enforcement
                with Cluster("Policy Enforcement", graph_attr={"bgcolor": "#E6FFE6"}):
                    resource_policies = Blank("Resource\nPolicies")
                    cost_controls = Blank("Cost\nControls")
                    security_policies = Blank("Security\nPolicies")

                # Automation
                with Cluster("Automation", graph_attr={"bgcolor": "#F0FFF0"}):
                    ci_cd_integration = Codepipeline("CI/CD\nIntegration")
                    automated_testing = Blank("Automated\nTesting")
                    deployment_gates = Blank("Deployment\nGates")

            # Team Collaboration
            with Cluster("Team Collaboration", graph_attr={"bgcolor": "#F5F5DC"}):
                platform_team = Users("Platform\nTeam")
                app_teams = Users("Application\nTeams")
                security_team = Users("Security\nTeam")

                platform_team >> shared_modules
                app_teams >> application_modules
                security_team >> security_policies

            # Layer dependencies
            vpc_foundation >> compute_platform
            iam_foundation >> data_platform
            dns_foundation >> monitoring_platform

            compute_platform >> web_apps
            data_platform >> api_services
            monitoring_platform >> batch_jobs

            # Governance connections
            naming_standard >> tag_strategy >> resource_hierarchy
            shared_modules >> team_modules >> application_modules
            state_separation >> workspace_strategy >> state_locking

            resource_policies >> cost_controls >> security_policies
            ci_cd_integration >> automated_testing >> deployment_gates

        logger.info(f"Generated Figure 3.5 at: {diagram_path}")
        return str(diagram_path)


def main():
    """
    Main execution function for generating all Topic 3 diagrams.

    This function initializes the diagram generator and creates all 5 professional
    diagrams for the Core Terraform Operations topic.
    """
    logger.info("Starting AWS Terraform Training Topic 3 diagram generation")

    try:
        # Initialize diagram generator
        generator = CoreTerraformOperationsDiagramGenerator()

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
