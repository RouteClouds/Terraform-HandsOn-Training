#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 4: Resource Management & Dependencies
Professional Diagram Generation Script (DaC - Diagram as Code)

This script generates 5 professional-quality diagrams for Topic 4 of the AWS Terraform
training curriculum. Each diagram is designed to support specific learning objectives
and enhance understanding of resource management, dependencies, lifecycle patterns,
and troubleshooting strategies.

Generated Diagrams:
1. Figure 4.1: Terraform Dependency Graph and Resource Relationships
2. Figure 4.2: Resource Lifecycle Management and State Transitions
3. Figure 4.3: Meta-Arguments and Advanced Resource Control
4. Figure 4.4: Resource Targeting and Selective Operations
5. Figure 4.5: Dependency Troubleshooting and Resolution Patterns

Requirements:
- Python 3.9+
- All dependencies from requirements.txt
- Graphviz system installation
- 300 DPI output for professional quality

Author: AWS Terraform Training Team
Version: 4.0.0
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
    from diagrams.aws.compute import EC2, Lambda, ECS, AutoScaling
    from diagrams.aws.database import RDS, Dynamodb, ElastiCache
    from diagrams.aws.network import VPC, ELB, CloudFront, Route53
    from diagrams.aws.storage import S3, EBS
    from diagrams.aws.security import IAM, KMS, WAF
    from diagrams.aws.management import Cloudformation, Cloudwatch, Config, SystemsManager
    from diagrams.aws.devtools import Codepipeline, Codebuild, Codecommit
    from diagrams.aws.analytics import Athena, Glue, Kinesis
    from diagrams.onprem.client import Users, Client
    from diagrams.onprem.vcs import Git
    from diagrams.programming.language import Python, Bash
    from diagrams.generic.blank import Blank
    from diagrams.generic.compute import Rack
    from diagrams.generic.database import SQL
    from diagrams.generic.network import Firewall, Router
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
    'error': '#D13212',        # AWS Red
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

class ResourceManagementDiagramGenerator:
    """
    Professional diagram generator for Resource Management & Dependencies.
    
    This class provides methods to generate high-quality architectural diagrams
    that support the learning objectives of Topic 4: Resource Management & Dependencies.
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
        Generate all 5 professional diagrams for Topic 4.
        
        Returns:
            Dict[str, str]: Mapping of diagram names to file paths
        """
        logger.info("Starting generation of all Topic 4 diagrams")
        
        diagrams = {
            'figure_4_1': self.generate_dependency_graph_diagram(),
            'figure_4_2': self.generate_lifecycle_management_diagram(), 
            'figure_4_3': self.generate_meta_arguments_control_diagram(),
            'figure_4_4': self.generate_resource_targeting_diagram(),
            'figure_4_5': self.generate_troubleshooting_patterns_diagram()
        }
        
        logger.info(f"Successfully generated {len(diagrams)} diagrams")
        return diagrams
    
    def generate_dependency_graph_diagram(self) -> str:
        """
        Generate Figure 4.1: Terraform Dependency Graph and Resource Relationships
        
        This diagram illustrates how Terraform builds and manages dependency graphs
        between resources, showing implicit and explicit dependencies.
        
        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 4.1: Dependency Graph and Resource Relationships")
        
        diagram_path = self.output_dir / "figure_4_1_dependency_graph_relationships.png"
        
        with Diagram(
            "Figure 4.1: Terraform Dependency Graph and Resource Relationships",
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
            # Dependency Analysis Phase
            with Cluster("1. Dependency Analysis", graph_attr={"bgcolor": "#E6F3FF"}):
                config_parsing = Python("Configuration\nParsing")
                resource_discovery = Blank("Resource\nDiscovery")
                dependency_detection = Blank("Dependency\nDetection")
                
                config_parsing >> resource_discovery >> dependency_detection
            
            # Implicit Dependencies
            with Cluster("2. Implicit Dependencies", graph_attr={"bgcolor": "#F0FFF0"}):
                # Network Dependencies
                with Cluster("Network Layer", graph_attr={"bgcolor": "#E6FFE6"}):
                    vpc = VPC("VPC")
                    subnet = Blank("Subnet")
                    igw = Router("Internet\nGateway")
                    
                    vpc >> subnet
                    vpc >> igw
                
                # Security Dependencies
                with Cluster("Security Layer", graph_attr={"bgcolor": "#F0FFF0"}):
                    security_group = Firewall("Security\nGroup")
                    iam_role = IAM("IAM Role")
                    
                    vpc >> security_group
                
                # Compute Dependencies
                with Cluster("Compute Layer", graph_attr={"bgcolor": "#FFF8F0"}):
                    ec2_instance = EC2("EC2\nInstance")
                    load_balancer = ELB("Load\nBalancer")
                    
                    subnet >> ec2_instance
                    security_group >> ec2_instance
                    ec2_instance >> load_balancer
            
            # Explicit Dependencies
            with Cluster("3. Explicit Dependencies", graph_attr={"bgcolor": "#FFF8DC"}):
                depends_on = Blank("depends_on\nMeta-Argument")
                custom_order = Blank("Custom\nOrdering")
                complex_deps = Blank("Complex\nDependencies")
                
                depends_on >> custom_order
                depends_on >> complex_deps
            
            # Dependency Graph
            with Cluster("4. Dependency Graph", graph_attr={"bgcolor": "#F5F5DC"}):
                graph_builder = Blank("Graph\nBuilder")
                topological_sort = Blank("Topological\nSort")
                execution_plan = Blank("Execution\nPlan")
                
                graph_builder >> topological_sort >> execution_plan
            
            # Resource Execution Order
            with Cluster("5. Execution Order", graph_attr={"bgcolor": "#FFFACD"}):
                parallel_execution = Blank("Parallel\nExecution")
                sequential_execution = Blank("Sequential\nExecution")
                dependency_wait = Blank("Dependency\nWait")
                
                execution_plan >> parallel_execution
                execution_plan >> sequential_execution
                sequential_execution >> dependency_wait
            
            # Connections showing dependency flow
            dependency_detection >> Edge(label="analyzes") >> vpc
            vpc >> Edge(label="implicit") >> subnet
            subnet >> Edge(label="implicit") >> ec2_instance
            ec2_instance >> Edge(label="explicit") >> depends_on
            depends_on >> Edge(label="creates") >> graph_builder
            topological_sort >> Edge(label="determines") >> parallel_execution
        
        logger.info(f"Generated Figure 4.1 at: {diagram_path}")
        return str(diagram_path)

    def generate_lifecycle_management_diagram(self) -> str:
        """
        Generate Figure 4.2: Resource Lifecycle Management and State Transitions

        This diagram shows advanced lifecycle management patterns and state transitions
        for complex resource scenarios.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 4.2: Lifecycle Management and State Transitions")

        diagram_path = self.output_dir / "figure_4_2_lifecycle_management_transitions.png"

        with Diagram(
            "Figure 4.2: Resource Lifecycle Management and State Transitions",
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
            # Lifecycle States
            with Cluster("Resource Lifecycle States", graph_attr={"bgcolor": "#E6F3FF"}):
                # Initial State
                with Cluster("Initial", graph_attr={"bgcolor": "#F0F8FF"}):
                    planned = Blank("Planned")
                    validated = Blank("Validated")

                # Active States
                with Cluster("Active", graph_attr={"bgcolor": "#F0FFF0"}):
                    creating = Blank("Creating")
                    created = EC2("Created")
                    updating = Blank("Updating")
                    updated = EC2("Updated")

                # Terminal States
                with Cluster("Terminal", graph_attr={"bgcolor": "#FFF0F0"}):
                    destroying = Blank("Destroying")
                    destroyed = Blank("Destroyed")
                    failed = Blank("Failed")

            # Lifecycle Rules
            with Cluster("Lifecycle Rules", graph_attr={"bgcolor": "#FFF8DC"}):
                create_before_destroy = Blank("create_before_destroy")
                prevent_destroy = Blank("prevent_destroy")
                ignore_changes = Blank("ignore_changes")
                replace_triggered_by = Blank("replace_triggered_by")

            # State Transitions
            with Cluster("State Management", graph_attr={"bgcolor": "#F5F5DC"}):
                state_lock = Dynamodb("State\nLock")
                state_backup = S3("State\nBackup")
                state_refresh = Blank("State\nRefresh")

            # Advanced Patterns
            with Cluster("Advanced Patterns", graph_attr={"bgcolor": "#FFFACD"}):
                blue_green = Blank("Blue-Green\nDeployment")
                rolling_update = Blank("Rolling\nUpdate")
                canary_deployment = Blank("Canary\nDeployment")

            # State transitions
            planned >> validated >> creating >> created
            created >> updating >> updated
            updated >> Edge(label="lifecycle rule") >> create_before_destroy
            created >> Edge(label="protected") >> prevent_destroy
            updating >> Edge(label="selective") >> ignore_changes

            # Advanced patterns
            create_before_destroy >> blue_green
            updating >> rolling_update
            replace_triggered_by >> canary_deployment

            # State management
            creating >> state_lock
            updating >> state_lock
            destroying >> state_lock
            created >> state_backup
            updated >> state_refresh

        logger.info(f"Generated Figure 4.2 at: {diagram_path}")
        return str(diagram_path)

    def generate_meta_arguments_control_diagram(self) -> str:
        """
        Generate Figure 4.3: Meta-Arguments and Advanced Resource Control

        This diagram demonstrates advanced meta-argument patterns and their
        interactions in complex resource management scenarios.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 4.3: Meta-Arguments and Advanced Control")

        diagram_path = self.output_dir / "figure_4_3_meta_arguments_control.png"

        with Diagram(
            "Figure 4.3: Meta-Arguments and Advanced Resource Control",
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
            # Meta-Argument Categories
            with Cluster("Meta-Argument Categories", graph_attr={"bgcolor": "#E6F3FF"}):
                # Iteration Control
                with Cluster("Iteration Control", graph_attr={"bgcolor": "#F0F8FF"}):
                    count_meta = Blank("count")
                    for_each_meta = Blank("for_each")
                    dynamic_blocks = Blank("dynamic\nblocks")

                # Dependency Control
                with Cluster("Dependency Control", graph_attr={"bgcolor": "#F5F5FF"}):
                    depends_on_meta = Blank("depends_on")
                    provider_meta = Blank("provider")

                # Lifecycle Control
                with Cluster("Lifecycle Control", graph_attr={"bgcolor": "#F8F8FF"}):
                    lifecycle_meta = Blank("lifecycle")
                    provisioner_meta = Blank("provisioner")

            # Complex Scenarios
            with Cluster("Complex Resource Scenarios", graph_attr={"bgcolor": "#FFF8DC"}):
                # Multi-Instance Patterns
                with Cluster("Multi-Instance", graph_attr={"bgcolor": "#FFFACD"}):
                    auto_scaling_group = AutoScaling("Auto Scaling\nGroup")
                    instance_fleet = EC2("Instance\nFleet")
                    load_balanced = ELB("Load\nBalanced")

                # Cross-Region Patterns
                with Cluster("Cross-Region", graph_attr={"bgcolor": "#FFF8E1"}):
                    primary_region = Blank("Primary\nRegion")
                    secondary_region = Blank("Secondary\nRegion")
                    replication = Blank("Data\nReplication")

                # Conditional Resources
                with Cluster("Conditional", graph_attr={"bgcolor": "#F8F8DC"}):
                    environment_check = Blank("Environment\nCheck")
                    feature_flags = Blank("Feature\nFlags")
                    conditional_creation = Blank("Conditional\nCreation")

            # Advanced Patterns
            with Cluster("Advanced Control Patterns", graph_attr={"bgcolor": "#F0FFF0"}):
                # Resource Chaining
                with Cluster("Resource Chaining", graph_attr={"bgcolor": "#E6FFE6"}):
                    sequential_deps = Blank("Sequential\nDependencies")
                    parallel_creation = Blank("Parallel\nCreation")
                    dependency_chains = Blank("Dependency\nChains")

                # Error Handling
                with Cluster("Error Handling", graph_attr={"bgcolor": "#F0FFF0"}):
                    retry_logic = Blank("Retry\nLogic")
                    fallback_resources = Blank("Fallback\nResources")
                    graceful_degradation = Blank("Graceful\nDegradation")

            # Meta-argument interactions
            count_meta >> instance_fleet
            for_each_meta >> auto_scaling_group
            depends_on_meta >> sequential_deps
            lifecycle_meta >> retry_logic

            # Complex scenario flows
            environment_check >> conditional_creation
            feature_flags >> conditional_creation
            primary_region >> replication >> secondary_region

            # Advanced pattern connections
            sequential_deps >> dependency_chains
            parallel_creation >> load_balanced
            retry_logic >> graceful_degradation

        logger.info(f"Generated Figure 4.3 at: {diagram_path}")
        return str(diagram_path)

    def generate_resource_targeting_diagram(self) -> str:
        """
        Generate Figure 4.4: Resource Targeting and Selective Operations

        This diagram illustrates resource targeting strategies and selective
        operations for precise infrastructure management.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 4.4: Resource Targeting and Selective Operations")

        diagram_path = self.output_dir / "figure_4_4_resource_targeting_operations.png"

        with Diagram(
            "Figure 4.4: Resource Targeting and Selective Operations",
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
            # Targeting Strategies
            with Cluster("Targeting Strategies", graph_attr={"bgcolor": "#E6F3FF"}):
                # Resource Targeting
                with Cluster("Resource Targeting", graph_attr={"bgcolor": "#F0F8FF"}):
                    single_resource = Blank("-target=\nresource.name")
                    multiple_resources = Blank("-target=\nresource1,resource2")
                    module_targeting = Blank("-target=\nmodule.name")

                # Pattern Targeting
                with Cluster("Pattern Targeting", graph_attr={"bgcolor": "#F5F5FF"}):
                    wildcard_targeting = Blank("Wildcard\nPatterns")
                    regex_targeting = Blank("Regex\nPatterns")
                    conditional_targeting = Blank("Conditional\nTargeting")

            # Selective Operations
            with Cluster("Selective Operations", graph_attr={"bgcolor": "#FFF8DC"}):
                # Apply Operations
                with Cluster("Apply Operations", graph_attr={"bgcolor": "#FFFACD"}):
                    targeted_apply = Bash("terraform apply\n-target=...")
                    partial_deployment = Blank("Partial\nDeployment")
                    incremental_updates = Blank("Incremental\nUpdates")

                # Destroy Operations
                with Cluster("Destroy Operations", graph_attr={"bgcolor": "#FFF8E1"}):
                    targeted_destroy = Bash("terraform destroy\n-target=...")
                    selective_cleanup = Blank("Selective\nCleanup")
                    resource_removal = Blank("Resource\nRemoval")

                # Plan Operations
                with Cluster("Plan Operations", graph_attr={"bgcolor": "#F8F8DC"}):
                    targeted_plan = Bash("terraform plan\n-target=...")
                    impact_analysis = Blank("Impact\nAnalysis")
                    change_preview = Blank("Change\nPreview")

            # Use Cases
            with Cluster("Common Use Cases", graph_attr={"bgcolor": "#F0FFF0"}):
                # Development Scenarios
                with Cluster("Development", graph_attr={"bgcolor": "#E6FFE6"}):
                    rapid_iteration = Blank("Rapid\nIteration")
                    component_testing = Blank("Component\nTesting")
                    debug_deployment = Blank("Debug\nDeployment")

                # Production Scenarios
                with Cluster("Production", graph_attr={"bgcolor": "#F0FFF0"}):
                    hotfix_deployment = Blank("Hotfix\nDeployment")
                    emergency_updates = Blank("Emergency\nUpdates")
                    maintenance_windows = Blank("Maintenance\nWindows")

                # Troubleshooting
                with Cluster("Troubleshooting", graph_attr={"bgcolor": "#FFF8F0"}):
                    isolated_testing = Blank("Isolated\nTesting")
                    dependency_analysis = Blank("Dependency\nAnalysis")
                    rollback_scenarios = Blank("Rollback\nScenarios")

            # Best Practices
            with Cluster("Best Practices", graph_attr={"bgcolor": "#F5F5DC"}):
                careful_targeting = Blank("Careful\nTargeting")
                dependency_awareness = Blank("Dependency\nAwareness")
                state_backup = S3("State\nBackup")
                testing_first = Blank("Test\nFirst")

            # Targeting flow
            single_resource >> targeted_apply >> partial_deployment
            multiple_resources >> targeted_destroy >> selective_cleanup
            module_targeting >> targeted_plan >> impact_analysis

            # Use case connections
            rapid_iteration >> component_testing
            hotfix_deployment >> emergency_updates
            isolated_testing >> dependency_analysis

            # Best practices
            targeted_apply >> careful_targeting
            selective_cleanup >> dependency_awareness
            partial_deployment >> state_backup
            impact_analysis >> testing_first

        logger.info(f"Generated Figure 4.4 at: {diagram_path}")
        return str(diagram_path)

    def generate_troubleshooting_patterns_diagram(self) -> str:
        """
        Generate Figure 4.5: Dependency Troubleshooting and Resolution Patterns

        This diagram shows common dependency issues and their resolution patterns
        for effective troubleshooting and problem resolution.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 4.5: Troubleshooting and Resolution Patterns")

        diagram_path = self.output_dir / "figure_4_5_troubleshooting_resolution_patterns.png"

        with Diagram(
            "Figure 4.5: Dependency Troubleshooting and Resolution Patterns",
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
            # Common Issues
            with Cluster("Common Dependency Issues", graph_attr={"bgcolor": "#FFE6E6"}):
                # Circular Dependencies
                with Cluster("Circular Dependencies", graph_attr={"bgcolor": "#FFF0F0"}):
                    circular_refs = Blank("Circular\nReferences")
                    mutual_deps = Blank("Mutual\nDependencies")
                    cycle_detection = Blank("Cycle\nDetection")

                # Missing Dependencies
                with Cluster("Missing Dependencies", graph_attr={"bgcolor": "#FFF5F5"}):
                    implicit_missing = Blank("Implicit\nMissing")
                    resource_not_found = Blank("Resource\nNot Found")
                    provider_issues = Blank("Provider\nIssues")

                # Timing Issues
                with Cluster("Timing Issues", graph_attr={"bgcolor": "#FFEFEF"}):
                    race_conditions = Blank("Race\nConditions")
                    async_operations = Blank("Async\nOperations")
                    timeout_errors = Blank("Timeout\nErrors")

            # Diagnostic Tools
            with Cluster("Diagnostic Tools", graph_attr={"bgcolor": "#E6F3FF"}):
                # Terraform Commands
                with Cluster("Terraform Commands", graph_attr={"bgcolor": "#F0F8FF"}):
                    terraform_graph = Bash("terraform\ngraph")
                    terraform_show = Bash("terraform\nshow")
                    terraform_state = Bash("terraform\nstate list")

                # Analysis Tools
                with Cluster("Analysis Tools", graph_attr={"bgcolor": "#F5F5FF"}):
                    dependency_viewer = Blank("Dependency\nViewer")
                    state_inspector = Blank("State\nInspector")
                    log_analysis = Blank("Log\nAnalysis")

            # Resolution Strategies
            with Cluster("Resolution Strategies", graph_attr={"bgcolor": "#F0FFF0"}):
                # Dependency Fixes
                with Cluster("Dependency Fixes", graph_attr={"bgcolor": "#E6FFE6"}):
                    explicit_depends = Blank("Explicit\ndepends_on")
                    resource_ordering = Blank("Resource\nOrdering")
                    module_separation = Blank("Module\nSeparation")

                # State Management
                with Cluster("State Management", graph_attr={"bgcolor": "#F0FFF0"}):
                    state_refresh = Blank("State\nRefresh")
                    state_import = Blank("State\nImport")
                    state_move = Blank("State\nMove")

                # Advanced Techniques
                with Cluster("Advanced Techniques", graph_attr={"bgcolor": "#FFF8F0"}):
                    resource_replacement = Blank("Resource\nReplacement")
                    dependency_injection = Blank("Dependency\nInjection")
                    conditional_logic = Blank("Conditional\nLogic")

            # Prevention Strategies
            with Cluster("Prevention Strategies", graph_attr={"bgcolor": "#FFFACD"}):
                design_patterns = Blank("Design\nPatterns")
                testing_strategies = Blank("Testing\nStrategies")
                documentation = Blank("Documentation")
                code_review = Blank("Code\nReview")

            # Issue detection flow
            circular_refs >> cycle_detection >> terraform_graph
            resource_not_found >> terraform_state >> state_inspector
            race_conditions >> log_analysis >> dependency_viewer

            # Resolution flow
            cycle_detection >> explicit_depends
            state_inspector >> state_refresh
            dependency_viewer >> resource_ordering

            # Prevention flow
            explicit_depends >> design_patterns
            resource_ordering >> testing_strategies
            state_refresh >> documentation
            testing_strategies >> code_review

        logger.info(f"Generated Figure 4.5 at: {diagram_path}")
        return str(diagram_path)


def main():
    """
    Main execution function for generating all Topic 4 diagrams.

    This function initializes the diagram generator and creates all 5 professional
    diagrams for the Resource Management & Dependencies topic.
    """
    logger.info("Starting AWS Terraform Training Topic 4 diagram generation")

    try:
        # Initialize diagram generator
        generator = ResourceManagementDiagramGenerator()

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
