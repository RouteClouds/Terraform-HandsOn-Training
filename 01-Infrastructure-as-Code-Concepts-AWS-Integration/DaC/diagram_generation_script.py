#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 1: Infrastructure as Code Concepts & AWS Integration
Professional Diagram Generation Script (DaC - Diagram as Code)

This script generates 5 professional-quality diagrams for Topic 1 of the AWS Terraform
training curriculum. Each diagram is designed to support specific learning objectives
and enhance understanding of Infrastructure as Code concepts with AWS integration.

Generated Diagrams:
1. Figure 1.1: Infrastructure as Code Evolution and Benefits
2. Figure 1.2: AWS IaC Ecosystem and Service Integration
3. Figure 1.3: Terraform vs AWS CloudFormation Comparison
4. Figure 1.4: Enterprise IaC Workflow and Best Practices
5. Figure 1.5: AWS Cost Optimization through IaC Automation

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
    from diagrams.aws.compute import EC2, Lambda, ECS
    from diagrams.aws.database import RDS, Dynamodb
    from diagrams.aws.network import VPC, ELB, CloudFront
    from diagrams.aws.storage import S3
    from diagrams.aws.security import IAM, KMS
    from diagrams.aws.management import Cloudformation, Cloudwatch, Config
    from diagrams.aws.devtools import Codepipeline, Codebuild, Codecommit
    from diagrams.aws.analytics import Athena, Glue
    from diagrams.onprem.client import Users
    from diagrams.onprem.vcs import Git
    from diagrams.programming.language import Python, Bash
    from diagrams.generic.blank import Blank
    from diagrams.generic.compute import Rack
    from diagrams.generic.database import SQL
    from diagrams.generic.network import Firewall
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    from matplotlib.patches import FancyBboxPatch
    import numpy as np
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

class AWSInfrastructureDiagramGenerator:
    """
    Professional diagram generator for AWS Infrastructure as Code concepts.

    This class provides methods to generate high-quality architectural diagrams
    that support the learning objectives of Topic 1: Infrastructure as Code
    Concepts & AWS Integration.
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
        Generate all 5 professional diagrams for Topic 1.

        Returns:
            Dict[str, str]: Mapping of diagram names to file paths
        """
        logger.info("Starting generation of all Topic 1 diagrams")

        diagrams = {
            'figure_1_1': self.generate_iac_evolution_diagram(),
            'figure_1_2': self.generate_aws_iac_ecosystem_diagram(),
            'figure_1_3': self.generate_terraform_vs_cloudformation_diagram(),
            'figure_1_4': self.generate_enterprise_iac_workflow_diagram(),
            'figure_1_5': self.generate_cost_optimization_diagram()
        }

        logger.info(f"Successfully generated {len(diagrams)} diagrams")
        return diagrams

    def generate_iac_evolution_diagram(self) -> str:
        """
        Generate Figure 1.1: Infrastructure as Code Evolution and Benefits

        This diagram illustrates the evolution from traditional infrastructure
        management to modern Infrastructure as Code practices, highlighting
        the key benefits and transformation journey.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 1.1: IaC Evolution and Benefits")

        diagram_path = self.output_dir / "figure_1_1_iac_evolution_benefits.png"

        with Diagram(
            "Figure 1.1: Infrastructure as Code Evolution and Benefits",
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
            # Traditional Infrastructure Management (Left Side)
            with Cluster("Traditional Infrastructure\n(Manual & Error-Prone)", graph_attr={"bgcolor": "#FFE6E6"}):
                manual_config = Rack("Manual\nConfiguration")
                documentation = Blank("Paper\nDocumentation")
                human_errors = Firewall("Human\nErrors")
                inconsistency = SQL("Environment\nInconsistency")

                manual_config >> Edge(label="leads to", style="dashed", color="red") >> human_errors
                human_errors >> Edge(label="causes", style="dashed", color="red") >> inconsistency

            # Infrastructure as Code (Right Side)
            with Cluster("Infrastructure as Code\n(Automated & Reliable)", graph_attr={"bgcolor": "#E6F7E6"}):
                terraform = Python("Terraform\nCode")
                version_control = Git("Version\nControl")
                automation = Lambda("Automated\nDeployment")
                consistency = Cloudformation("Environment\nConsistency")

                terraform >> Edge(label="stored in", color="green") >> version_control
                version_control >> Edge(label="enables", color="green") >> automation
                automation >> Edge(label="ensures", color="green") >> consistency

            # Transformation Arrow
            manual_config >> Edge(
                label="TRANSFORMATION\nto IaC",
                style="bold",
                color=AWS_COLORS['primary'],
                fontsize="14"
            ) >> terraform

        logger.info(f"Generated Figure 1.1 at: {diagram_path}")
        return str(diagram_path)

    def generate_aws_iac_ecosystem_diagram(self) -> str:
        """
        Generate Figure 1.2: AWS IaC Ecosystem and Service Integration

        This diagram shows the comprehensive AWS ecosystem for Infrastructure
        as Code, including native AWS services and third-party tools like Terraform.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 1.2: AWS IaC Ecosystem")

        diagram_path = self.output_dir / "figure_1_2_aws_iac_ecosystem.png"

        with Diagram(
            "Figure 1.2: AWS IaC Ecosystem and Service Integration",
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
            # Developer Tools Layer
            with Cluster("Developer Tools & Version Control", graph_attr={"bgcolor": "#F0F8FF"}):
                git_repo = Git("Git Repository")
                code_commit = Codecommit("AWS CodeCommit")
                code_pipeline = Codepipeline("AWS CodePipeline")

                git_repo >> Edge(label="push") >> code_commit
                code_commit >> Edge(label="triggers") >> code_pipeline

            # IaC Tools Layer
            with Cluster("Infrastructure as Code Tools", graph_attr={"bgcolor": "#FFF8DC"}):
                terraform = Python("Terraform")
                cloudformation = Cloudformation("AWS CloudFormation")
                cdk = Python("AWS CDK")

            # AWS Services Layer
            with Cluster("AWS Infrastructure Services", graph_attr={"bgcolor": "#F0FFF0"}):
                # Compute Services
                with Cluster("Compute", graph_attr={"bgcolor": "#E6F3FF"}):
                    ec2 = EC2("Amazon EC2")
                    lambda_func = Lambda("AWS Lambda")
                    ecs = ECS("Amazon ECS")

                # Storage Services
                with Cluster("Storage", graph_attr={"bgcolor": "#FFE6F3"}):
                    s3 = S3("Amazon S3")

                # Database Services
                with Cluster("Database", graph_attr={"bgcolor": "#F3E6FF"}):
                    rds = RDS("Amazon RDS")
                    dynamodb = Dynamodb("Amazon DynamoDB")

                # Network Services
                with Cluster("Networking", graph_attr={"bgcolor": "#E6FFE6"}):
                    vpc = VPC("Amazon VPC")
                    elb = ELB("Elastic Load Balancer")
                    cloudfront = CloudFront("Amazon CloudFront")

            # Management & Governance
            with Cluster("Management & Governance", graph_attr={"bgcolor": "#FFFACD"}):
                cloudwatch = Cloudwatch("Amazon CloudWatch")
                config = Config("AWS Config")
                iam = IAM("AWS IAM")

            # Connections
            code_pipeline >> Edge(label="deploys") >> terraform
            code_pipeline >> Edge(label="deploys") >> cloudformation
            code_pipeline >> Edge(label="deploys") >> cdk

            terraform >> Edge(label="provisions") >> ec2
            terraform >> Edge(label="provisions") >> s3
            terraform >> Edge(label="provisions") >> rds
            terraform >> Edge(label="provisions") >> vpc

            cloudformation >> Edge(label="provisions") >> lambda_func
            cloudformation >> Edge(label="provisions") >> dynamodb
            cloudformation >> Edge(label="provisions") >> elb

            cdk >> Edge(label="provisions") >> ecs
            cdk >> Edge(label="provisions") >> cloudfront

            ec2 >> Edge(label="monitored by") >> cloudwatch
            lambda_func >> Edge(label="monitored by") >> cloudwatch
            ecs >> Edge(label="monitored by") >> cloudwatch

            s3 >> Edge(label="governed by") >> config
            rds >> Edge(label="governed by") >> config
            dynamodb >> Edge(label="governed by") >> config

            vpc >> Edge(label="secured by") >> iam
            elb >> Edge(label="secured by") >> iam
            cloudfront >> Edge(label="secured by") >> iam

        logger.info(f"Generated Figure 1.2 at: {diagram_path}")
        return str(diagram_path)

    def generate_terraform_vs_cloudformation_diagram(self) -> str:
        """
        Generate Figure 1.3: Terraform vs AWS CloudFormation Comparison

        This diagram provides a detailed comparison between Terraform and
        AWS CloudFormation, highlighting their strengths, use cases, and
        integration patterns for enterprise environments.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 1.3: Terraform vs CloudFormation Comparison")

        diagram_path = self.output_dir / "figure_1_3_terraform_vs_cloudformation.png"

        with Diagram(
            "Figure 1.3: Terraform vs AWS CloudFormation Comparison",
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
            # Terraform Side (Left)
            with Cluster("Terraform\n(Multi-Cloud IaC)", graph_attr={"bgcolor": "#E6F3FF"}):
                terraform_logo = Python("Terraform\nby HashiCorp")

                with Cluster("Terraform Strengths", graph_attr={"bgcolor": "#F0F8FF"}):
                    multi_cloud = Blank("Multi-Cloud\nSupport")
                    hcl_syntax = Blank("HCL Syntax\n(Human Readable)")
                    state_mgmt = Blank("Advanced State\nManagement")
                    modules = Blank("Reusable\nModules")
                    planning = Blank("Plan & Preview\nChanges")

                with Cluster("Terraform Use Cases", graph_attr={"bgcolor": "#F5F5FF"}):
                    hybrid_cloud = Blank("Hybrid Cloud\nDeployments")
                    complex_infra = Blank("Complex\nInfrastructure")
                    team_collab = Blank("Team\nCollaboration")

                terraform_logo >> multi_cloud
                terraform_logo >> hcl_syntax
                terraform_logo >> state_mgmt
                terraform_logo >> modules
                terraform_logo >> planning

                multi_cloud >> hybrid_cloud
                hcl_syntax >> complex_infra
                state_mgmt >> team_collab

            # AWS CloudFormation Side (Right)
            with Cluster("AWS CloudFormation\n(AWS Native IaC)", graph_attr={"bgcolor": "#E6FFE6"}):
                cf_logo = Cloudformation("AWS\nCloudFormation")

                with Cluster("CloudFormation Strengths", graph_attr={"bgcolor": "#F0FFF0"}):
                    aws_native = Blank("AWS Native\nIntegration")
                    json_yaml = Blank("JSON/YAML\nTemplates")
                    rollback = Blank("Automatic\nRollback")
                    drift_detect = Blank("Drift\nDetection")
                    stacksets = Blank("StackSets\n(Multi-Account)")

                with Cluster("CloudFormation Use Cases", graph_attr={"bgcolor": "#F5FFF5"}):
                    aws_only = Blank("AWS-Only\nEnvironments")
                    compliance = Blank("Compliance &\nGovernance")
                    quick_deploy = Blank("Quick AWS\nDeployments")

                cf_logo >> aws_native
                cf_logo >> json_yaml
                cf_logo >> rollback
                cf_logo >> drift_detect
                cf_logo >> stacksets

                aws_native >> aws_only
                json_yaml >> compliance
                rollback >> quick_deploy

            # Comparison Metrics (Center)
            with Cluster("Comparison Metrics", graph_attr={"bgcolor": "#FFFACD"}):
                learning_curve = Blank("Learning Curve:\nTerraform (Moderate)\nCloudFormation (Easy)")
                ecosystem = Blank("Ecosystem:\nTerraform (Broad)\nCloudFormation (AWS)")
                community = Blank("Community:\nTerraform (Large)\nCloudFormation (AWS)")
                cost = Blank("Cost:\nTerraform (Tool Cost)\nCloudFormation (Free)")

            # Integration Arrow
            terraform_logo >> Edge(
                label="CHOOSE BASED ON\nREQUIREMENTS",
                style="bold",
                color=AWS_COLORS['primary']
            ) >> cf_logo

        logger.info(f"Generated Figure 1.3 at: {diagram_path}")
        return str(diagram_path)

    def generate_enterprise_iac_workflow_diagram(self) -> str:
        """
        Generate Figure 1.4: Enterprise IaC Workflow and Best Practices

        This diagram illustrates the complete enterprise workflow for
        Infrastructure as Code, including development, testing, deployment,
        and governance phases with AWS integration.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 1.4: Enterprise IaC Workflow")

        diagram_path = self.output_dir / "figure_1_4_enterprise_iac_workflow.png"

        with Diagram(
            "Figure 1.4: Enterprise IaC Workflow and Best Practices",
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
            # Development Phase
            with Cluster("1. Development Phase", graph_attr={"bgcolor": "#E6F3FF"}):
                developer = Users("Infrastructure\nDevelopers")
                ide = Blank("IDE/Editor\n(VS Code)")
                terraform_code = Python("Terraform\nConfiguration")
                local_test = Blank("Local\nValidation")

                developer >> ide >> terraform_code >> local_test

            # Version Control & Collaboration
            with Cluster("2. Version Control & Collaboration", graph_attr={"bgcolor": "#F0F8FF"}):
                git_repo = Git("Git Repository\n(GitHub/GitLab)")
                pull_request = Blank("Pull Request\nReview")
                code_review = Users("Code Review\nTeam")

                local_test >> Edge(label="commit") >> git_repo
                git_repo >> pull_request >> code_review

            # Automated Testing & Validation
            with Cluster("3. Automated Testing & Validation", graph_attr={"bgcolor": "#FFF8DC"}):
                ci_pipeline = Codepipeline("CI/CD Pipeline")
                terraform_validate = Blank("terraform validate")
                terraform_plan = Blank("terraform plan")
                security_scan = Blank("Security\nScanning")
                cost_analysis = Blank("Cost\nAnalysis")

                code_review >> Edge(label="merge") >> ci_pipeline
                ci_pipeline >> terraform_validate
                ci_pipeline >> terraform_plan
                ci_pipeline >> security_scan
                ci_pipeline >> cost_analysis

            # Environment Deployment
            with Cluster("4. Environment Deployment", graph_attr={"bgcolor": "#E6FFE6"}):
                dev_env = EC2("Development\nEnvironment")
                staging_env = EC2("Staging\nEnvironment")
                prod_env = EC2("Production\nEnvironment")

                terraform_plan >> Edge(label="deploy to") >> dev_env
                dev_env >> Edge(label="promote to") >> staging_env
                staging_env >> Edge(label="promote to") >> prod_env

            # Monitoring & Governance
            with Cluster("5. Monitoring & Governance", graph_attr={"bgcolor": "#FFFACD"}):
                cloudwatch = Cloudwatch("Infrastructure\nMonitoring")
                config = Config("Compliance\nTracking")
                cost_mgmt = Blank("Cost\nManagement")
                drift_detection = Blank("Drift\nDetection")

                dev_env >> cloudwatch
                staging_env >> cloudwatch
                prod_env >> cloudwatch

                dev_env >> config
                staging_env >> config
                prod_env >> config

                dev_env >> cost_mgmt
                staging_env >> cost_mgmt
                prod_env >> cost_mgmt

                dev_env >> drift_detection
                staging_env >> drift_detection
                prod_env >> drift_detection

        logger.info(f"Generated Figure 1.4 at: {diagram_path}")
        return str(diagram_path)

    def generate_cost_optimization_diagram(self) -> str:
        """
        Generate Figure 1.5: AWS Cost Optimization through IaC Automation

        This diagram demonstrates how Infrastructure as Code enables
        cost optimization through automation, right-sizing, scheduling,
        and intelligent resource management in AWS environments.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 1.5: Cost Optimization through IaC")

        diagram_path = self.output_dir / "figure_1_5_cost_optimization_iac.png"

        with Diagram(
            "Figure 1.5: AWS Cost Optimization through IaC Automation",
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
            # Cost Optimization Strategies
            with Cluster("IaC-Enabled Cost Optimization Strategies", graph_attr={"bgcolor": "#E6F7E6"}):

                # Automated Resource Management
                with Cluster("Automated Resource Management", graph_attr={"bgcolor": "#F0FFF0"}):
                    auto_scaling = Lambda("Auto Scaling\nPolicies")
                    scheduled_actions = Lambda("Scheduled\nStart/Stop")
                    right_sizing = EC2("Right-Sizing\nRecommendations")

                # Storage Optimization
                with Cluster("Storage Lifecycle Management", graph_attr={"bgcolor": "#F5FFFA"}):
                    s3_lifecycle = S3("S3 Lifecycle\nPolicies")
                    storage_classes = S3("Intelligent\nTiering")
                    data_archival = S3("Automated\nArchival")

                # Reserved Capacity Management
                with Cluster("Reserved Capacity Optimization", graph_attr={"bgcolor": "#F0F8F0"}):
                    reserved_instances = EC2("Reserved\nInstances")
                    savings_plans = Blank("Savings\nPlans")
                    spot_instances = EC2("Spot\nInstances")

            # Cost Monitoring & Governance
            with Cluster("Cost Monitoring & Governance", graph_attr={"bgcolor": "#FFF8DC"}):
                cost_explorer = Blank("AWS Cost\nExplorer")
                budgets = Blank("AWS\nBudgets")
                cost_alerts = Cloudwatch("Cost\nAlerts")
                tagging_strategy = Blank("Resource\nTagging")

            # Business Impact Metrics
            with Cluster("Business Impact & ROI", graph_attr={"bgcolor": "#FFFACD"}):
                cost_savings = Blank("30-50%\nCost Reduction")
                efficiency_gains = Blank("80%\nOperational\nEfficiency")
                time_savings = Blank("90%\nDeployment\nTime Reduction")
                risk_reduction = Blank("95%\nHuman Error\nReduction")

            # Terraform Automation Engine
            terraform_engine = Python("Terraform\nAutomation Engine")

            # Connections showing automation flow
            terraform_engine >> Edge(label="automates") >> auto_scaling
            terraform_engine >> Edge(label="automates") >> scheduled_actions
            terraform_engine >> Edge(label="automates") >> right_sizing

            terraform_engine >> Edge(label="configures") >> s3_lifecycle
            terraform_engine >> Edge(label="configures") >> storage_classes
            terraform_engine >> Edge(label="configures") >> data_archival

            terraform_engine >> Edge(label="manages") >> reserved_instances
            terraform_engine >> Edge(label="manages") >> savings_plans
            terraform_engine >> Edge(label="manages") >> spot_instances

            # Monitoring connections
            auto_scaling >> Edge(label="monitored by") >> cost_explorer
            s3_lifecycle >> Edge(label="monitored by") >> cost_explorer
            reserved_instances >> Edge(label="monitored by") >> cost_explorer

            cost_explorer >> budgets
            cost_explorer >> cost_alerts
            cost_explorer >> tagging_strategy

            # Business impact connections
            auto_scaling >> Edge(label="delivers") >> cost_savings
            s3_lifecycle >> Edge(label="delivers") >> cost_savings
            reserved_instances >> Edge(label="delivers") >> cost_savings

            scheduled_actions >> Edge(label="enables") >> efficiency_gains
            storage_classes >> Edge(label="enables") >> efficiency_gains
            savings_plans >> Edge(label="enables") >> efficiency_gains

            right_sizing >> Edge(label="achieves") >> time_savings
            data_archival >> Edge(label="achieves") >> time_savings
            spot_instances >> Edge(label="achieves") >> time_savings

            terraform_engine >> Edge(label="ensures") >> risk_reduction

        logger.info(f"Generated Figure 1.5 at: {diagram_path}")
        return str(diagram_path)


def main():
    """
    Main execution function for generating all Topic 1 diagrams.

    This function initializes the diagram generator and creates all 5 professional
    diagrams for the Infrastructure as Code Concepts & AWS Integration topic.
    """
    logger.info("Starting AWS Terraform Training Topic 1 diagram generation")

    try:
        # Initialize diagram generator
        generator = AWSInfrastructureDiagramGenerator()

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
"""
AWS Terraform Training - Topic 1: Infrastructure as Code Concepts & AWS Integration
Professional Diagram Generation Script

This script generates 5 professional diagrams for Topic 1 using Python libraries
with AWS brand-compliant styling and 300 DPI resolution for enterprise presentations.

Generated Diagrams:
1. Figure 1.1: Infrastructure as Code Evolution and Benefits
2. Figure 1.2: AWS IaC Service Ecosystem and Integration
3. Figure 1.3: Terraform vs AWS CloudFormation Comparison
4. Figure 1.4: Enterprise IaC Workflow and Best Practices
5. Figure 1.5: Cost Optimization and ROI Analysis

Requirements:
- matplotlib >= 3.7.0
- numpy >= 1.24.0
- seaborn >= 0.12.0
- plotly >= 5.15.0
- Pillow >= 10.0.0

Author: AWS Terraform Training Team
Version: 3.0.0 (Updated for Terraform 1.13.0 & AWS Provider 6.12.0)
Date: January 2025
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, Rectangle, Arrow
import numpy as np
import seaborn as sns
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import os
import sys
from pathlib import Path
import warnings
warnings.filterwarnings('ignore')

# AWS Brand Color Palette (Official AWS Colors)
COLORS = {
    'primary': '#FF9900',      # AWS Orange
    'secondary': '#232F3E',    # AWS Dark Blue
    'accent': '#146EB4',       # AWS Blue
    'success': '#7AA116',      # AWS Green
    'warning': '#FF9900',      # AWS Orange
    'background': '#F2F3F3',   # Light Gray
    'text': '#232F3E',         # Dark Blue
    'white': '#FFFFFF',        # White
    'light_blue': '#E8F4FD',   # Light Blue
    'light_orange': '#FFF3E0', # Light Orange
    'dark_gray': '#5A6C7D',    # Dark Gray
    'medium_gray': '#8C9196'   # Medium Gray
}

# Professional styling configuration
plt.style.use('default')
sns.set_palette([COLORS['primary'], COLORS['accent'], COLORS['success'],
                COLORS['secondary'], COLORS['warning']])

def setup_figure(figsize=(16, 12), dpi=300):
    """Setup figure with professional styling and AWS branding."""
    fig, ax = plt.subplots(figsize=figsize, dpi=dpi)
    fig.patch.set_facecolor(COLORS['white'])
    ax.set_facecolor(COLORS['background'])

    # Remove axes for clean diagram appearance
    ax.set_xticks([])
    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    ax.spines['left'].set_visible(False)

    return fig, ax

def add_aws_branding(ax, title, subtitle=""):
    """Add AWS branding and professional title to diagram."""
    # Main title
    ax.text(0.5, 0.95, title, transform=ax.transAxes,
            fontsize=20, fontweight='bold', ha='center', va='top',
            color=COLORS['secondary'])

    # Subtitle
    if subtitle:
        ax.text(0.5, 0.91, subtitle, transform=ax.transAxes,
                fontsize=14, ha='center', va='top',
                color=COLORS['dark_gray'])

    # AWS branding
    ax.text(0.02, 0.02, "AWS Terraform Training", transform=ax.transAxes,
            fontsize=10, ha='left', va='bottom',
            color=COLORS['medium_gray'], style='italic')

def create_rounded_box(ax, x, y, width, height, text, color, text_color='white'):
    """Create a rounded rectangle with text."""
    box = FancyBboxPatch((x, y), width, height,
                        boxstyle="round,pad=0.02",
                        facecolor=color, edgecolor=COLORS['secondary'],
                        linewidth=2)
    ax.add_patch(box)

    # Add text
    ax.text(x + width/2, y + height/2, text,
            ha='center', va='center', fontsize=12, fontweight='bold',
            color=text_color, wrap=True)

def ensure_output_directory():
    """Create output directory if it doesn't exist"""
    output_dir = Path("generated_diagrams")
    output_dir.mkdir(exist_ok=True)
    return output_dir

def create_traditional_vs_iac_diagram():
    """
    Figure 1.1: Traditional vs Infrastructure as Code Approach Comparison
    
    This diagram illustrates the key differences between traditional manual
    infrastructure management and modern Infrastructure as Code practices.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 1.1: Traditional vs Infrastructure as Code Approach",
        filename=str(output_dir / "figure_1_1_traditional_vs_iac"),
        show=False,
        direction="LR",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        with Cluster("Traditional Approach"):
            traditional_user = Users("System Admin")
            traditional_process = [
                Rack("Manual Setup"),
                Firewall("Manual Config"),
                Storage("Manual Storage"),
                Rack("Inconsistent Results")
            ]
            
            traditional_user >> Edge(label="Manual Steps", style="dashed", color="red") >> traditional_process[0]
            traditional_process[0] >> traditional_process[1] >> traditional_process[2] >> traditional_process[3]
        
        with Cluster("Infrastructure as Code Approach"):
            iac_user = Users("DevOps Engineer")
            iac_tools = [
                Terraform("Terraform Code"),
                Git("Version Control"),
                Jenkins("CI/CD Pipeline")
            ]
            
            iac_infrastructure = [
                VPC("Consistent VPC"),
                EC2("Standardized EC2"),
                S3("Automated S3"),
                RDS("Managed Database")
            ]
            
            iac_user >> Edge(label="Code Commit", color=COLORS['success']) >> iac_tools[0]
            iac_tools[0] >> iac_tools[1] >> iac_tools[2]
            iac_tools[2] >> Edge(label="Automated Deployment", color=COLORS['success']) >> iac_infrastructure[0]
            iac_infrastructure[0] >> iac_infrastructure[1] >> iac_infrastructure[2] >> iac_infrastructure[3]

def create_aws_iac_integration_architecture():
    """
    Figure 1.2: AWS Infrastructure as Code Integration Architecture
    
    This diagram shows how Terraform integrates with AWS services to create
    a comprehensive infrastructure automation solution.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 1.2: AWS Infrastructure as Code Integration Architecture",
        filename=str(output_dir / "figure_1_2_aws_iac_integration"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        # Development Layer
        with Cluster("Development Environment"):
            developer = Users("Developer")
            terraform_code = Terraform("Terraform Configuration")
            git_repo = Git("Git Repository")
            
            developer >> terraform_code >> git_repo
        
        # CI/CD Layer
        with Cluster("Automation Pipeline"):
            ci_cd = Jenkins("CI/CD Pipeline")
            terraform_plan = Terraform("Terraform Plan")
            terraform_apply = Terraform("Terraform Apply")
            
            git_repo >> ci_cd >> terraform_plan >> terraform_apply
        
        # AWS Infrastructure Layer
        with Cluster("AWS Cloud Infrastructure"):
            # Networking
            with Cluster("Networking"):
                vpc = VPC("VPC")
                public_subnet = PublicSubnet("Public Subnets")
                private_subnet = PrivateSubnet("Private Subnets")
                igw = InternetGateway("Internet Gateway")
                nat = NATGateway("NAT Gateway")
                
                vpc >> [public_subnet, private_subnet]
                igw >> public_subnet >> nat >> private_subnet
            
            # Compute
            with Cluster("Compute"):
                alb = ELB("Application Load Balancer")
                asg = AutoScaling("Auto Scaling Group")
                ec2 = EC2("EC2 Instances")
                
                alb >> asg >> ec2
            
            # Storage & Database
            with Cluster("Storage & Database"):
                s3 = S3("S3 Bucket")
                rds = RDS("RDS Database")
            
            # Security & Monitoring
            with Cluster("Security & Monitoring"):
                iam = IAM("IAM Roles")
                sg = Firewall("Security Groups")
                cloudwatch = Cloudwatch("CloudWatch")
                cloudtrail = Cloudtrail("CloudTrail")
        
        # Connections
        terraform_apply >> Edge(label="Provisions", color=COLORS['success']) >> vpc
        terraform_apply >> Edge(label="Configures", color=COLORS['success']) >> [alb, s3, iam]
        
        # Infrastructure connections
        public_subnet >> alb >> private_subnet
        private_subnet >> ec2
        ec2 >> [s3, rds]
        iam >> ec2
        sg >> [alb, ec2, rds]
        [ec2, alb, rds] >> cloudwatch
        cloudtrail >> CloudwatchLogs("Audit Logs")

def create_enterprise_migration_workflow():
    """
    Figure 1.3: Enterprise Infrastructure Migration Workflow
    
    This diagram illustrates the step-by-step process for migrating from
    traditional infrastructure to Infrastructure as Code in an enterprise environment.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 1.3: Enterprise Infrastructure Migration Workflow",
        filename=str(output_dir / "figure_1_3_enterprise_migration"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        # Phase 1: Assessment
        with Cluster("Phase 1: Assessment & Planning"):
            current_infra = Rack("Current Infrastructure")
            assessment = Python("Infrastructure Audit")
            planning = Terraform("Migration Planning")
            
            current_infra >> assessment >> planning
        
        # Phase 2: Foundation
        with Cluster("Phase 2: Foundation Setup"):
            team_training = Users("Team Training")
            tool_setup = Terraform("Tool Configuration")
            version_control = Git("Version Control Setup")
            
            planning >> team_training >> tool_setup >> version_control
        
        # Phase 3: Pilot Implementation
        with Cluster("Phase 3: Pilot Implementation"):
            pilot_env = VPC("Pilot Environment")
            basic_resources = [
                EC2("Basic Compute"),
                S3("Basic Storage"),
                Firewall("Basic Security")
            ]
            
            version_control >> pilot_env >> basic_resources[0]
            basic_resources[0] >> basic_resources[1] >> basic_resources[2]
        
        # Phase 4: Production Migration
        with Cluster("Phase 4: Production Migration"):
            prod_vpc = VPC("Production VPC")
            prod_resources = [
                ELB("Load Balancers"),
                AutoScaling("Auto Scaling"),
                RDS("Databases"),
                Cloudwatch("Monitoring")
            ]
            
            basic_resources[2] >> prod_vpc >> prod_resources[0]
            prod_resources[0] >> prod_resources[1] >> prod_resources[2] >> prod_resources[3]
        
        # Phase 5: Optimization
        with Cluster("Phase 5: Optimization & Governance"):
            cost_optimization = Cloudwatch("Cost Optimization")
            security_compliance = IAM("Security Compliance")
            automation = Jenkins("Full Automation")
            
            prod_resources[3] >> [cost_optimization, security_compliance, automation]

def create_cost_optimization_framework():
    """
    Figure 1.4: Infrastructure as Code Cost Optimization Framework
    
    This diagram shows how IaC enables systematic cost optimization through
    automation, monitoring, and intelligent resource management.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 1.4: Infrastructure as Code Cost Optimization Framework",
        filename=str(output_dir / "figure_1_4_cost_optimization"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        # Cost Monitoring Layer
        with Cluster("Cost Monitoring & Analysis"):
            cost_explorer = Cloudwatch("AWS Cost Explorer")
            billing_alerts = Cloudwatch("Billing Alerts")
            cost_reports = CloudwatchLogs("Cost Reports")
            
            cost_explorer >> billing_alerts >> cost_reports
        
        # IaC Optimization Layer
        with Cluster("IaC-Driven Optimization"):
            terraform_config = Terraform("Terraform Configuration")
            
            # Resource Optimization
            with Cluster("Resource Optimization"):
                right_sizing = EC2("Right-sizing")
                auto_scaling = AutoScaling("Auto Scaling")
                scheduled_scaling = Cloudwatch("Scheduled Scaling")
                
                terraform_config >> right_sizing >> auto_scaling >> scheduled_scaling
            
            # Storage Optimization
            with Cluster("Storage Optimization"):
                s3_lifecycle = S3("S3 Lifecycle Policies")
                storage_classes = S3("Storage Classes")
                data_archival = S3("Data Archival")
                
                terraform_config >> s3_lifecycle >> storage_classes >> data_archival
        
        # Automation Layer
        with Cluster("Cost Automation"):
            automated_shutdown = Jenkins("Automated Shutdown")
            resource_tagging = IAM("Resource Tagging")
            budget_controls = Cloudwatch("Budget Controls")
            
            scheduled_scaling >> automated_shutdown
            data_archival >> resource_tagging >> budget_controls
        
        # Business Impact
        with Cluster("Business Impact"):
            cost_savings = Grafana("25-40% Cost Reduction")
            operational_efficiency = Grafana("70% Ops Efficiency")
            roi_metrics = Grafana("300%+ ROI")
            
            budget_controls >> cost_savings >> operational_efficiency >> roi_metrics
        
        # Feedback Loop
        cost_reports >> Edge(label="Insights", style="dashed", color=COLORS['accent']) >> terraform_config

def create_security_compliance_architecture():
    """
    Figure 1.5: Infrastructure as Code Security & Compliance Architecture
    
    This diagram demonstrates how IaC enables built-in security controls,
    compliance automation, and continuous security monitoring.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 1.5: Infrastructure as Code Security & Compliance Architecture",
        filename=str(output_dir / "figure_1_5_security_compliance"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        # Security Policy Layer
        with Cluster("Security Policy as Code"):
            security_policies = Terraform("Security Policies")
            compliance_rules = Terraform("Compliance Rules")
            security_templates = Git("Security Templates")
            
            security_policies >> compliance_rules >> security_templates
        
        # Infrastructure Security Layer
        with Cluster("Infrastructure Security"):
            # Network Security
            with Cluster("Network Security"):
                vpc_security = VPC("VPC Isolation")
                security_groups = Firewall("Security Groups")
                nacls = Firewall("Network ACLs")
                
                vpc_security >> security_groups >> nacls
            
            # Access Control
            with Cluster("Access Control"):
                iam_roles = IAM("IAM Roles")
                least_privilege = IAM("Least Privilege")
                mfa = IAM("Multi-Factor Auth")
                
                iam_roles >> least_privilege >> mfa
            
            # Data Protection
            with Cluster("Data Protection"):
                encryption_rest = S3("Encryption at Rest")
                encryption_transit = Firewall("Encryption in Transit")
                key_management = IAM("KMS Key Management")
                
                encryption_rest >> encryption_transit >> key_management
        
        # Monitoring & Compliance Layer
        with Cluster("Security Monitoring & Compliance"):
            cloudtrail_audit = Cloudtrail("CloudTrail Auditing")
            config_compliance = Cloudwatch("AWS Config")
            security_monitoring = Cloudwatch("Security Monitoring")
            
            cloudtrail_audit >> config_compliance >> security_monitoring
        
        # Automated Response Layer
        with Cluster("Automated Security Response"):
            incident_response = Jenkins("Incident Response")
            compliance_reporting = CloudwatchLogs("Compliance Reports")
            security_remediation = Terraform("Auto Remediation")
            
            security_monitoring >> incident_response >> compliance_reporting >> security_remediation
        
        # Connections from IaC to Security Implementation
        security_templates >> Edge(label="Implements", color=COLORS['success']) >> vpc_security
        security_templates >> Edge(label="Enforces", color=COLORS['success']) >> iam_roles
        security_templates >> Edge(label="Configures", color=COLORS['success']) >> encryption_rest
        
        # Feedback loop for continuous improvement
        compliance_reporting >> Edge(label="Feedback", style="dashed", color=COLORS['accent']) >> security_policies

def main():
    """
    Main function to generate all diagrams for Topic 1: Infrastructure as Code Concepts & AWS Integration
    """
    print("🎨 Generating Professional AWS Infrastructure as Code Diagrams...")
    print("=" * 70)
    
    try:
        # Ensure output directory exists
        output_dir = ensure_output_directory()
        print(f"📁 Output directory: {output_dir.absolute()}")
        
        # Generate all diagrams
        diagrams = [
            ("Figure 1.1: Traditional vs IaC Approach", create_traditional_vs_iac_diagram),
            ("Figure 1.2: AWS IaC Integration Architecture", create_aws_iac_integration_architecture),
            ("Figure 1.3: Enterprise Migration Workflow", create_enterprise_migration_workflow),
            ("Figure 1.4: Cost Optimization Framework", create_cost_optimization_framework),
            ("Figure 1.5: Security & Compliance Architecture", create_security_compliance_architecture)
        ]
        
        for diagram_name, diagram_function in diagrams:
            print(f"🔄 Generating {diagram_name}...")
            diagram_function()
            print(f"✅ {diagram_name} completed successfully!")
        
        print("\n" + "=" * 70)
        print("🎉 All diagrams generated successfully!")
        print(f"📂 Diagrams saved to: {output_dir.absolute()}")
        print("\n📋 Generated Files:")
        
        # List generated files
        for file in sorted(output_dir.glob("*.png")):
            print(f"   • {file.name}")
        
        print("\n💡 Integration Notes:")
        print("   • All diagrams are 300 DPI for professional presentations")
        print("   • AWS brand colors and styling applied consistently")
        print("   • Diagrams are referenced in Concept.md and Lab-1.md")
        print("   • Use these diagrams to enhance learning and understanding")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        print("Please check your environment and dependencies.")
        sys.exit(1)

if __name__ == "__main__":
    main()
