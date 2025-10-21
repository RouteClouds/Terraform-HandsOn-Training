#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 7: Terraform Modules
Professional Diagram Generation Script (DaC - Diagram as Code)

This script generates 5 professional-quality diagrams for Topic 7 of the AWS Terraform
training curriculum. Each diagram is designed to support specific learning objectives
and enhance understanding of module architecture, composition patterns, versioning
workflows, testing frameworks, and enterprise governance.

Generated Diagrams:
1. Figure 7.1: Module Architecture and Design Patterns
2. Figure 7.2: Module Composition and Dependency Management
3. Figure 7.3: Module Versioning and Lifecycle Management
4. Figure 7.4: Module Testing and Validation Frameworks
5. Figure 7.5: Enterprise Module Governance and Registry

Requirements:
- Python 3.9+
- All dependencies from requirements.txt
- Graphviz system installation
- 300 DPI output for professional quality

Author: AWS Terraform Training Team
Version: 7.0.0
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
    from diagrams.aws.storage import S3, EBS, EFS
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

class TerraformModulesDiagramGenerator:
    """
    Professional diagram generator for Terraform Modules.
    
    This class provides methods to generate high-quality architectural diagrams
    that support the learning objectives of Topic 7: Terraform Modules.
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
        Generate all 5 professional diagrams for Topic 7.
        
        Returns:
            Dict[str, str]: Mapping of diagram names to file paths
        """
        logger.info("Starting generation of all Topic 7 diagrams")
        
        diagrams = {
            'figure_7_1': self.generate_module_architecture_patterns_diagram(),
            'figure_7_2': self.generate_module_composition_dependency_diagram(), 
            'figure_7_3': self.generate_module_versioning_lifecycle_diagram(),
            'figure_7_4': self.generate_module_testing_validation_diagram(),
            'figure_7_5': self.generate_enterprise_module_governance_diagram()
        }
        
        logger.info(f"Successfully generated {len(diagrams)} diagrams")
        return diagrams
    
    def generate_module_architecture_patterns_diagram(self) -> str:
        """
        Generate Figure 7.1: Module Architecture and Design Patterns
        
        This diagram illustrates comprehensive module architecture patterns, design
        principles, and structural organization for enterprise Terraform modules.
        
        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 7.1: Module Architecture and Design Patterns")
        
        diagram_path = self.output_dir / "figure_7_1_module_architecture_patterns.png"
        
        with Diagram(
            "Figure 7.1: Module Architecture and Design Patterns",
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
            # Module Design Principles
            with Cluster("Module Design Principles", graph_attr={"bgcolor": "#E6F3FF"}):
                # Single Responsibility
                with Cluster("Single Responsibility", graph_attr={"bgcolor": "#F0F8FF"}):
                    single_purpose = Blank("Single\nPurpose")
                    clear_scope = Blank("Clear\nScope")
                    focused_functionality = Blank("Focused\nFunctionality")
                
                # Reusability
                with Cluster("Reusability", graph_attr={"bgcolor": "#F5F5FF"}):
                    parameterization = Blank("Parameterization")
                    configuration_flexibility = Blank("Configuration\nFlexibility")
                    environment_agnostic = Blank("Environment\nAgnostic")
                
                # Composability
                with Cluster("Composability", graph_attr={"bgcolor": "#F8F8FF"}):
                    modular_design = Blank("Modular\nDesign")
                    interface_contracts = Blank("Interface\nContracts")
                    dependency_injection = Blank("Dependency\nInjection")
            
            # Module Architecture Patterns
            with Cluster("Module Architecture Patterns", graph_attr={"bgcolor": "#FFF8DC"}):
                # Foundation Modules
                with Cluster("Foundation Modules", graph_attr={"bgcolor": "#FFFACD"}):
                    network_module = VPC("Network\nModule")
                    security_module = IAM("Security\nModule")
                    compute_module = EC2("Compute\nModule")
                
                # Composite Modules
                with Cluster("Composite Modules", graph_attr={"bgcolor": "#FFF8E1"}):
                    application_module = ELB("Application\nModule")
                    database_module = RDS("Database\nModule")
                    monitoring_module = Cloudwatch("Monitoring\nModule")
                
                # Wrapper Modules
                with Cluster("Wrapper Modules", graph_attr={"bgcolor": "#F8F8DC"}):
                    aws_wrapper = Blank("AWS Service\nWrapper")
                    third_party_wrapper = Blank("Third-Party\nWrapper")
                    legacy_wrapper = Blank("Legacy System\nWrapper")
            
            # Module Structure Standards
            with Cluster("Module Structure Standards", graph_attr={"bgcolor": "#F0FFF0"}):
                # File Organization
                with Cluster("File Organization", graph_attr={"bgcolor": "#E6FFE6"}):
                    main_tf = Blank("main.tf")
                    variables_tf = Blank("variables.tf")
                    outputs_tf = Blank("outputs.tf")
                    versions_tf = Blank("versions.tf")
                
                # Documentation Structure
                with Cluster("Documentation", graph_attr={"bgcolor": "#F0FFF0"}):
                    readme_md = Blank("README.md")
                    examples_dir = Blank("examples/")
                    docs_dir = Blank("docs/")
                
                # Testing Structure
                with Cluster("Testing", graph_attr={"bgcolor": "#FFF8F0"}):
                    test_dir = Blank("test/")
                    fixtures_dir = Blank("fixtures/")
                    integration_tests = Blank("integration/")
            
            # Interface Design Patterns
            with Cluster("Interface Design Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Input Patterns
                with Cluster("Input Patterns", graph_attr={"bgcolor": "#FFF8DC"}):
                    required_variables = Blank("Required\nVariables")
                    optional_variables = Blank("Optional\nVariables")
                    validation_rules = Blank("Validation\nRules")
                
                # Output Patterns
                with Cluster("Output Patterns", graph_attr={"bgcolor": "#FFFACD"}):
                    resource_ids = Blank("Resource\nIDs")
                    configuration_data = Blank("Configuration\nData")
                    computed_values = Blank("Computed\nValues")
                
                # Data Source Patterns
                with Cluster("Data Source Patterns", graph_attr={"bgcolor": "#FDF5E6"}):
                    external_data = Blank("External\nData")
                    remote_state = Blank("Remote\nState")
                    dynamic_lookup = Blank("Dynamic\nLookup")
            
            # Enterprise Patterns
            with Cluster("Enterprise Patterns", graph_attr={"bgcolor": "#FFF0F5"}):
                # Multi-Environment
                with Cluster("Multi-Environment", graph_attr={"bgcolor": "#FFE4E1"}):
                    environment_config = Blank("Environment\nConfiguration")
                    resource_naming = Blank("Resource\nNaming")
                    tagging_strategy = Blank("Tagging\nStrategy")
                
                # Security Patterns
                with Cluster("Security Patterns", graph_attr={"bgcolor": "#FFF5EE"}):
                    least_privilege = Blank("Least\nPrivilege")
                    encryption_defaults = Blank("Encryption\nDefaults")
                    compliance_controls = Blank("Compliance\nControls")
                
                # Operational Patterns
                with Cluster("Operational Patterns", graph_attr={"bgcolor": "#FFFAF0"}):
                    monitoring_integration = Blank("Monitoring\nIntegration")
                    logging_standards = Blank("Logging\nStandards")
                    backup_strategies = Blank("Backup\nStrategies")
            
            # Design principle flow
            single_purpose >> parameterization >> modular_design
            clear_scope >> configuration_flexibility >> interface_contracts
            focused_functionality >> environment_agnostic >> dependency_injection
            
            # Architecture pattern relationships
            network_module >> application_module
            security_module >> database_module
            compute_module >> monitoring_module
            
            # Structure standards flow
            main_tf >> variables_tf >> outputs_tf >> versions_tf
            readme_md >> examples_dir >> docs_dir
            test_dir >> fixtures_dir >> integration_tests
            
            # Interface patterns
            required_variables >> resource_ids
            optional_variables >> configuration_data
            validation_rules >> computed_values
            
            # Enterprise integration
            environment_config >> least_privilege >> monitoring_integration
            resource_naming >> encryption_defaults >> logging_standards
            tagging_strategy >> compliance_controls >> backup_strategies
        
        logger.info(f"Generated Figure 7.1 at: {diagram_path}")
        return str(diagram_path)

    def generate_module_composition_dependency_diagram(self) -> str:
        """
        Generate Figure 7.2: Module Composition and Dependency Management

        This diagram demonstrates module composition patterns, dependency
        management strategies, and complex module integration workflows.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 7.2: Module Composition and Dependency Management")

        diagram_path = self.output_dir / "figure_7_2_module_composition_dependency.png"

        with Diagram(
            "Figure 7.2: Module Composition and Dependency Management",
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
            # Foundation Layer Modules
            with Cluster("Foundation Layer", graph_attr={"bgcolor": "#E6F3FF"}):
                # Core Infrastructure
                with Cluster("Core Infrastructure", graph_attr={"bgcolor": "#F0F8FF"}):
                    vpc_module = VPC("VPC\nModule")
                    security_module = IAM("Security\nModule")
                    dns_module = Route53("DNS\nModule")

                # Foundation Outputs
                with Cluster("Foundation Outputs", graph_attr={"bgcolor": "#F5F5FF"}):
                    network_config = Blank("Network\nConfiguration")
                    security_config = Blank("Security\nConfiguration")
                    dns_config = Blank("DNS\nConfiguration")

            # Platform Layer Modules
            with Cluster("Platform Layer", graph_attr={"bgcolor": "#FFF8DC"}):
                # Platform Services
                with Cluster("Platform Services", graph_attr={"bgcolor": "#FFFACD"}):
                    compute_module = EC2("Compute\nModule")
                    storage_module = S3("Storage\nModule")
                    database_module = RDS("Database\nModule")

                # Platform Dependencies
                with Cluster("Platform Dependencies", graph_attr={"bgcolor": "#FFF8E1"}):
                    platform_inputs = Blank("Foundation\nInputs")
                    platform_config = Blank("Platform\nConfiguration")
                    platform_outputs = Blank("Platform\nOutputs")

            # Application Layer Modules
            with Cluster("Application Layer", graph_attr={"bgcolor": "#F0FFF0"}):
                # Application Components
                with Cluster("Application Components", graph_attr={"bgcolor": "#E6FFE6"}):
                    web_app_module = ELB("Web App\nModule")
                    api_module = Lambda("API\nModule")
                    worker_module = ECS("Worker\nModule")

                # Application Integration
                with Cluster("Application Integration", graph_attr={"bgcolor": "#F0FFF0"}):
                    app_dependencies = Blank("Platform\nDependencies")
                    app_composition = Blank("Application\nComposition")
                    app_outputs = Blank("Application\nOutputs")

            # Composition Patterns
            with Cluster("Composition Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Hierarchical Composition
                with Cluster("Hierarchical Composition", graph_attr={"bgcolor": "#FFF8DC"}):
                    parent_module = Blank("Parent\nModule")
                    child_modules = Blank("Child\nModules")
                    nested_composition = Blank("Nested\nComposition")

                # Horizontal Composition
                with Cluster("Horizontal Composition", graph_attr={"bgcolor": "#FFFACD"}):
                    peer_modules = Blank("Peer\nModules")
                    shared_resources = Blank("Shared\nResources")
                    cross_references = Blank("Cross\nReferences")

                # Dynamic Composition
                with Cluster("Dynamic Composition", graph_attr={"bgcolor": "#FDF5E6"}):
                    conditional_modules = Blank("Conditional\nModules")
                    for_each_modules = Blank("For-Each\nModules")
                    count_modules = Blank("Count\nModules")

            # Dependency Management
            with Cluster("Dependency Management", graph_attr={"bgcolor": "#FFF0F5"}):
                # Explicit Dependencies
                with Cluster("Explicit Dependencies", graph_attr={"bgcolor": "#FFE4E1"}):
                    depends_on = Blank("depends_on")
                    module_outputs = Blank("Module\nOutputs")
                    data_sources = Blank("Data\nSources")

                # Implicit Dependencies
                with Cluster("Implicit Dependencies", graph_attr={"bgcolor": "#FFF5EE"}):
                    resource_references = Blank("Resource\nReferences")
                    variable_interpolation = Blank("Variable\nInterpolation")
                    computed_dependencies = Blank("Computed\nDependencies")

                # Dependency Resolution
                with Cluster("Dependency Resolution", graph_attr={"bgcolor": "#FFFAF0"}):
                    dependency_graph = Blank("Dependency\nGraph")
                    execution_order = Blank("Execution\nOrder")
                    circular_detection = Blank("Circular\nDetection")

            # Advanced Patterns
            with Cluster("Advanced Patterns", graph_attr={"bgcolor": "#F0F8FF"}):
                # Module Factories
                with Cluster("Module Factories", graph_attr={"bgcolor": "#E6F7FF"}):
                    factory_pattern = Blank("Factory\nPattern")
                    template_modules = Blank("Template\nModules")
                    generated_modules = Blank("Generated\nModules")

                # Module Proxies
                with Cluster("Module Proxies", graph_attr={"bgcolor": "#F0F8FF"}):
                    proxy_modules = Blank("Proxy\nModules")
                    adapter_pattern = Blank("Adapter\nPattern")
                    facade_pattern = Blank("Facade\nPattern")

                # Module Composition Tools
                with Cluster("Composition Tools", graph_attr={"bgcolor": "#F8FCFF"}):
                    terragrunt = Blank("Terragrunt")
                    atlantis = Blank("Atlantis")
                    custom_tools = Blank("Custom\nTools")

            # Foundation to Platform flow
            vpc_module >> network_config >> platform_inputs
            security_module >> security_config >> platform_config
            dns_module >> dns_config >> platform_outputs

            # Platform to Application flow
            compute_module >> app_dependencies
            storage_module >> app_composition
            database_module >> app_outputs

            # Composition pattern relationships
            parent_module >> child_modules >> nested_composition
            peer_modules >> shared_resources >> cross_references
            conditional_modules >> for_each_modules >> count_modules

            # Dependency management flow
            depends_on >> resource_references >> dependency_graph
            module_outputs >> variable_interpolation >> execution_order
            data_sources >> computed_dependencies >> circular_detection

            # Advanced pattern integration
            factory_pattern >> proxy_modules >> terragrunt
            template_modules >> adapter_pattern >> atlantis
            generated_modules >> facade_pattern >> custom_tools

        logger.info(f"Generated Figure 7.2 at: {diagram_path}")
        return str(diagram_path)

    def generate_module_versioning_lifecycle_diagram(self) -> str:
        """
        Generate Figure 7.3: Module Versioning and Lifecycle Management

        This diagram shows module versioning strategies, lifecycle management,
        and release workflows for enterprise module development.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 7.3: Module Versioning and Lifecycle Management")

        diagram_path = self.output_dir / "figure_7_3_module_versioning_lifecycle.png"

        with Diagram(
            "Figure 7.3: Module Versioning and Lifecycle Management",
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
            # Semantic Versioning
            with Cluster("Semantic Versioning", graph_attr={"bgcolor": "#E6F3FF"}):
                # Version Components
                with Cluster("Version Components", graph_attr={"bgcolor": "#F0F8FF"}):
                    major_version = Blank("Major\n(Breaking)")
                    minor_version = Blank("Minor\n(Features)")
                    patch_version = Blank("Patch\n(Fixes)")

                # Version Constraints
                with Cluster("Version Constraints", graph_attr={"bgcolor": "#F5F5FF"}):
                    exact_version = Blank("Exact\n= 1.2.3")
                    pessimistic_constraint = Blank("Pessimistic\n~> 1.2")
                    range_constraint = Blank("Range\n>= 1.0, < 2.0")

                # Pre-release Versions
                with Cluster("Pre-release Versions", graph_attr={"bgcolor": "#F8F8FF"}):
                    alpha_version = Blank("Alpha\n1.0.0-alpha")
                    beta_version = Blank("Beta\n1.0.0-beta")
                    rc_version = Blank("RC\n1.0.0-rc")

            # Development Lifecycle
            with Cluster("Development Lifecycle", graph_attr={"bgcolor": "#FFF8DC"}):
                # Development Phases
                with Cluster("Development Phases", graph_attr={"bgcolor": "#FFFACD"}):
                    feature_development = Git("Feature\nDevelopment")
                    code_review = Blank("Code\nReview")
                    testing_validation = Blank("Testing &\nValidation")

                # Release Preparation
                with Cluster("Release Preparation", graph_attr={"bgcolor": "#FFF8E1"}):
                    documentation_update = Blank("Documentation\nUpdate")
                    changelog_generation = Blank("Changelog\nGeneration")
                    version_tagging = Blank("Version\nTagging")

                # Release Process
                with Cluster("Release Process", graph_attr={"bgcolor": "#F8F8DC"}):
                    automated_testing = Blank("Automated\nTesting")
                    security_scanning = Blank("Security\nScanning")
                    release_publishing = Blank("Release\nPublishing")

            # Module Registry Management
            with Cluster("Module Registry Management", graph_attr={"bgcolor": "#F0FFF0"}):
                # Registry Types
                with Cluster("Registry Types", graph_attr={"bgcolor": "#E6FFE6"}):
                    public_registry = Blank("Public\nRegistry")
                    private_registry = Blank("Private\nRegistry")
                    enterprise_registry = Blank("Enterprise\nRegistry")

                # Registry Operations
                with Cluster("Registry Operations", graph_attr={"bgcolor": "#F0FFF0"}):
                    module_publishing = Blank("Module\nPublishing")
                    version_management = Blank("Version\nManagement")
                    access_control = Blank("Access\nControl")

                # Registry Integration
                with Cluster("Registry Integration", graph_attr={"bgcolor": "#FFF8F0"}):
                    ci_cd_integration = Codepipeline("CI/CD\nIntegration")
                    automated_publishing = Blank("Automated\nPublishing")
                    dependency_tracking = Blank("Dependency\nTracking")

            # Lifecycle Automation
            with Cluster("Lifecycle Automation", graph_attr={"bgcolor": "#F5F5DC"}):
                # Automated Workflows
                with Cluster("Automated Workflows", graph_attr={"bgcolor": "#FFF8DC"}):
                    github_actions = Blank("GitHub\nActions")
                    gitlab_ci = Blank("GitLab\nCI")
                    jenkins_pipeline = Blank("Jenkins\nPipeline")

                # Quality Gates
                with Cluster("Quality Gates", graph_attr={"bgcolor": "#FFFACD"}):
                    lint_checks = Blank("Lint\nChecks")
                    security_checks = Blank("Security\nChecks")
                    compliance_checks = Blank("Compliance\nChecks")

                # Deployment Automation
                with Cluster("Deployment Automation", graph_attr={"bgcolor": "#FDF5E6"}):
                    staging_deployment = Blank("Staging\nDeployment")
                    production_deployment = Blank("Production\nDeployment")
                    rollback_procedures = Blank("Rollback\nProcedures")

            # Version lifecycle flow
            major_version >> minor_version >> patch_version
            exact_version >> pessimistic_constraint >> range_constraint
            alpha_version >> beta_version >> rc_version

            # Development flow
            feature_development >> code_review >> testing_validation
            documentation_update >> changelog_generation >> version_tagging
            automated_testing >> security_scanning >> release_publishing

            # Registry management flow
            public_registry >> module_publishing >> ci_cd_integration
            private_registry >> version_management >> automated_publishing
            enterprise_registry >> access_control >> dependency_tracking

            # Automation flow
            github_actions >> lint_checks >> staging_deployment
            gitlab_ci >> security_checks >> production_deployment
            jenkins_pipeline >> compliance_checks >> rollback_procedures

        logger.info(f"Generated Figure 7.3 at: {diagram_path}")
        return str(diagram_path)

    def generate_module_testing_validation_diagram(self) -> str:
        """
        Generate Figure 7.4: Module Testing and Validation Frameworks

        This diagram illustrates comprehensive testing strategies, validation
        frameworks, and quality assurance processes for Terraform modules.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 7.4: Module Testing and Validation Frameworks")

        diagram_path = self.output_dir / "figure_7_4_module_testing_validation.png"

        with Diagram(
            "Figure 7.4: Module Testing and Validation Frameworks",
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
            # Testing Pyramid
            with Cluster("Testing Pyramid", graph_attr={"bgcolor": "#E6F3FF"}):
                # Unit Tests
                with Cluster("Unit Tests", graph_attr={"bgcolor": "#F0F8FF"}):
                    syntax_validation = Blank("Syntax\nValidation")
                    variable_validation = Blank("Variable\nValidation")
                    output_validation = Blank("Output\nValidation")

                # Integration Tests
                with Cluster("Integration Tests", graph_attr={"bgcolor": "#F5F5FF"}):
                    resource_creation = Blank("Resource\nCreation")
                    dependency_testing = Blank("Dependency\nTesting")
                    configuration_testing = Blank("Configuration\nTesting")

                # End-to-End Tests
                with Cluster("End-to-End Tests", graph_attr={"bgcolor": "#F8F8FF"}):
                    full_deployment = Blank("Full\nDeployment")
                    workflow_testing = Blank("Workflow\nTesting")
                    user_acceptance = Blank("User\nAcceptance")

            # Testing Frameworks
            with Cluster("Testing Frameworks", graph_attr={"bgcolor": "#FFF8DC"}):
                # Terratest Framework
                with Cluster("Terratest", graph_attr={"bgcolor": "#FFFACD"}):
                    go_testing = Blank("Go\nTesting")
                    aws_helpers = Blank("AWS\nHelpers")
                    terraform_helpers = Blank("Terraform\nHelpers")

                # Kitchen-Terraform
                with Cluster("Kitchen-Terraform", graph_attr={"bgcolor": "#FFF8E1"}):
                    test_kitchen = Blank("Test\nKitchen")
                    inspec_tests = Blank("InSpec\nTests")
                    ruby_testing = Blank("Ruby\nTesting")

                # Custom Frameworks
                with Cluster("Custom Frameworks", graph_attr={"bgcolor": "#F8F8DC"}):
                    python_testing = Python("Python\nTesting")
                    bash_testing = Bash("Bash\nTesting")
                    custom_scripts = Blank("Custom\nScripts")

            # Validation Tools
            with Cluster("Validation Tools", graph_attr={"bgcolor": "#F0FFF0"}):
                # Static Analysis
                with Cluster("Static Analysis", graph_attr={"bgcolor": "#E6FFE6"}):
                    terraform_validate = Blank("terraform\nvalidate")
                    terraform_fmt = Blank("terraform\nfmt")
                    tflint = Blank("TFLint")

                # Security Scanning
                with Cluster("Security Scanning", graph_attr={"bgcolor": "#F0FFF0"}):
                    checkov = Blank("Checkov")
                    terrascan = Blank("Terrascan")
                    tfsec = Blank("TFSec")

                # Compliance Testing
                with Cluster("Compliance Testing", graph_attr={"bgcolor": "#FFF8F0"}):
                    terraform_compliance = Blank("terraform-\ncompliance")
                    policy_validation = Blank("Policy\nValidation")
                    regulatory_checks = Blank("Regulatory\nChecks")

            # Test Automation
            with Cluster("Test Automation", graph_attr={"bgcolor": "#F5F5DC"}):
                # CI/CD Integration
                with Cluster("CI/CD Integration", graph_attr={"bgcolor": "#FFF8DC"}):
                    github_actions = Blank("GitHub\nActions")
                    gitlab_ci = Blank("GitLab\nCI")
                    jenkins = Blank("Jenkins")

                # Test Orchestration
                with Cluster("Test Orchestration", graph_attr={"bgcolor": "#FFFACD"}):
                    parallel_execution = Blank("Parallel\nExecution")
                    test_scheduling = Blank("Test\nScheduling")
                    resource_management = Blank("Resource\nManagement")

                # Reporting and Analytics
                with Cluster("Reporting & Analytics", graph_attr={"bgcolor": "#FDF5E6"}):
                    test_reports = Blank("Test\nReports")
                    coverage_analysis = Blank("Coverage\nAnalysis")
                    trend_analysis = Blank("Trend\nAnalysis")

            # Quality Assurance
            with Cluster("Quality Assurance", graph_attr={"bgcolor": "#FFF0F5"}):
                # Code Quality
                with Cluster("Code Quality", graph_attr={"bgcolor": "#FFE4E1"}):
                    code_standards = Blank("Code\nStandards")
                    documentation_quality = Blank("Documentation\nQuality")
                    maintainability = Blank("Maintainability")

                # Performance Testing
                with Cluster("Performance Testing", graph_attr={"bgcolor": "#FFF5EE"}):
                    deployment_time = Blank("Deployment\nTime")
                    resource_efficiency = Blank("Resource\nEfficiency")
                    scalability_testing = Blank("Scalability\nTesting")

                # Reliability Testing
                with Cluster("Reliability Testing", graph_attr={"bgcolor": "#FFFAF0"}):
                    failure_scenarios = Blank("Failure\nScenarios")
                    recovery_testing = Blank("Recovery\nTesting")
                    chaos_engineering = Blank("Chaos\nEngineering")

            # Testing pyramid flow
            syntax_validation >> resource_creation >> full_deployment
            variable_validation >> dependency_testing >> workflow_testing
            output_validation >> configuration_testing >> user_acceptance

            # Framework integration
            go_testing >> test_kitchen >> python_testing
            aws_helpers >> inspec_tests >> bash_testing
            terraform_helpers >> ruby_testing >> custom_scripts

            # Validation tool flow
            terraform_validate >> checkov >> terraform_compliance
            terraform_fmt >> terrascan >> policy_validation
            tflint >> tfsec >> regulatory_checks

            # Automation flow
            github_actions >> parallel_execution >> test_reports
            gitlab_ci >> test_scheduling >> coverage_analysis
            jenkins >> resource_management >> trend_analysis

            # Quality assurance flow
            code_standards >> deployment_time >> failure_scenarios
            documentation_quality >> resource_efficiency >> recovery_testing
            maintainability >> scalability_testing >> chaos_engineering

        logger.info(f"Generated Figure 7.4 at: {diagram_path}")
        return str(diagram_path)

    def generate_enterprise_module_governance_diagram(self) -> str:
        """
        Generate Figure 7.5: Enterprise Module Governance and Registry

        This diagram shows enterprise governance frameworks, module registries,
        and organizational policies for large-scale module management.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 7.5: Enterprise Module Governance and Registry")

        diagram_path = self.output_dir / "figure_7_5_enterprise_module_governance.png"

        with Diagram(
            "Figure 7.5: Enterprise Module Governance and Registry",
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
            # Governance Framework
            with Cluster("Governance Framework", graph_attr={"bgcolor": "#E6F3FF"}):
                # Organizational Structure
                with Cluster("Organizational Structure", graph_attr={"bgcolor": "#F0F8FF"}):
                    module_committee = Users("Module\nCommittee")
                    architecture_board = Users("Architecture\nBoard")
                    security_team = Users("Security\nTeam")

                # Governance Policies
                with Cluster("Governance Policies", graph_attr={"bgcolor": "#F5F5FF"}):
                    module_standards = Blank("Module\nStandards")
                    approval_process = Blank("Approval\nProcess")
                    lifecycle_policies = Blank("Lifecycle\nPolicies")

                # Compliance Framework
                with Cluster("Compliance Framework", graph_attr={"bgcolor": "#F8F8FF"}):
                    regulatory_compliance = Blank("Regulatory\nCompliance")
                    security_policies = Blank("Security\nPolicies")
                    audit_requirements = Blank("Audit\nRequirements")

            # Module Registry Architecture
            with Cluster("Module Registry Architecture", graph_attr={"bgcolor": "#FFF8DC"}):
                # Registry Types
                with Cluster("Registry Types", graph_attr={"bgcolor": "#FFFACD"}):
                    public_registry = Blank("Public\nRegistry")
                    private_registry = Blank("Private\nRegistry")
                    hybrid_registry = Blank("Hybrid\nRegistry")

                # Registry Services
                with Cluster("Registry Services", graph_attr={"bgcolor": "#FFF8E1"}):
                    module_storage = S3("Module\nStorage")
                    version_management = Blank("Version\nManagement")
                    dependency_resolution = Blank("Dependency\nResolution")

                # Registry Security
                with Cluster("Registry Security", graph_attr={"bgcolor": "#F8F8DC"}):
                    access_control = IAM("Access\nControl")
                    authentication = Blank("Authentication")
                    authorization = Blank("Authorization")

            # Module Lifecycle Management
            with Cluster("Module Lifecycle Management", graph_attr={"bgcolor": "#F0FFF0"}):
                # Development Governance
                with Cluster("Development Governance", graph_attr={"bgcolor": "#E6FFE6"}):
                    design_review = Blank("Design\nReview")
                    code_review = Blank("Code\nReview")
                    testing_requirements = Blank("Testing\nRequirements")

                # Release Management
                with Cluster("Release Management", graph_attr={"bgcolor": "#F0FFF0"}):
                    release_approval = Blank("Release\nApproval")
                    change_management = Blank("Change\nManagement")
                    deployment_coordination = Blank("Deployment\nCoordination")

                # Maintenance Governance
                with Cluster("Maintenance Governance", graph_attr={"bgcolor": "#FFF8F0"}):
                    update_policies = Blank("Update\nPolicies")
                    deprecation_process = Blank("Deprecation\nProcess")
                    support_lifecycle = Blank("Support\nLifecycle")

            # Enterprise Integration
            with Cluster("Enterprise Integration", graph_attr={"bgcolor": "#F5F5DC"}):
                # ITSM Integration
                with Cluster("ITSM Integration", graph_attr={"bgcolor": "#FFF8DC"}):
                    service_catalog = Blank("Service\nCatalog")
                    change_requests = Blank("Change\nRequests")
                    incident_management = Blank("Incident\nManagement")

                # DevOps Integration
                with Cluster("DevOps Integration", graph_attr={"bgcolor": "#FFFACD"}):
                    ci_cd_pipelines = Codepipeline("CI/CD\nPipelines")
                    infrastructure_automation = Blank("Infrastructure\nAutomation")
                    monitoring_integration = Cloudwatch("Monitoring\nIntegration")

                # Business Integration
                with Cluster("Business Integration", graph_attr={"bgcolor": "#FDF5E6"}):
                    cost_management = Blank("Cost\nManagement")
                    resource_optimization = Blank("Resource\nOptimization")
                    business_alignment = Blank("Business\nAlignment")

            # Quality and Compliance
            with Cluster("Quality & Compliance", graph_attr={"bgcolor": "#FFF0F5"}):
                # Quality Assurance
                with Cluster("Quality Assurance", graph_attr={"bgcolor": "#FFE4E1"}):
                    quality_gates = Blank("Quality\nGates")
                    automated_testing = Blank("Automated\nTesting")
                    performance_monitoring = Blank("Performance\nMonitoring")

                # Security Compliance
                with Cluster("Security Compliance", graph_attr={"bgcolor": "#FFF5EE"}):
                    security_scanning = Blank("Security\nScanning")
                    vulnerability_management = Blank("Vulnerability\nManagement")
                    compliance_reporting = Blank("Compliance\nReporting")

                # Operational Excellence
                with Cluster("Operational Excellence", graph_attr={"bgcolor": "#FFFAF0"}):
                    operational_metrics = Blank("Operational\nMetrics")
                    continuous_improvement = Blank("Continuous\nImprovement")
                    knowledge_management = Blank("Knowledge\nManagement")

            # Governance flow
            module_committee >> module_standards >> regulatory_compliance
            architecture_board >> approval_process >> security_policies
            security_team >> lifecycle_policies >> audit_requirements

            # Registry architecture flow
            public_registry >> module_storage >> access_control
            private_registry >> version_management >> authentication
            hybrid_registry >> dependency_resolution >> authorization

            # Lifecycle management flow
            design_review >> release_approval >> update_policies
            code_review >> change_management >> deprecation_process
            testing_requirements >> deployment_coordination >> support_lifecycle

            # Enterprise integration flow
            service_catalog >> ci_cd_pipelines >> cost_management
            change_requests >> infrastructure_automation >> resource_optimization
            incident_management >> monitoring_integration >> business_alignment

            # Quality and compliance flow
            quality_gates >> security_scanning >> operational_metrics
            automated_testing >> vulnerability_management >> continuous_improvement
            performance_monitoring >> compliance_reporting >> knowledge_management

        logger.info(f"Generated Figure 7.5 at: {diagram_path}")
        return str(diagram_path)


def validate_system_requirements() -> bool:
    """
    Validate system requirements for diagram generation.

    Returns:
        bool: True if all requirements are met, False otherwise
    """
    logger.info("Validating system requirements...")

    # Check Python version
    if sys.version_info < (3, 9):
        logger.error(f"Python 3.9+ required, found {sys.version}")
        return False

    # Check Graphviz installation
    try:
        import subprocess
        result = subprocess.run(['dot', '-V'], capture_output=True, text=True)
        if result.returncode != 0:
            logger.error("Graphviz not found. Please install Graphviz system package.")
            return False
        logger.info(f"Graphviz found: {result.stderr.strip()}")
    except FileNotFoundError:
        logger.error("Graphviz not found. Please install Graphviz system package.")
        return False

    # Check required libraries
    required_modules = ['diagrams', 'PIL', 'pathlib']
    for module in required_modules:
        try:
            __import__(module)
            logger.info(f"✓ {module} available")
        except ImportError:
            logger.error(f"✗ {module} not available")
            return False

    # Check write permissions
    output_dir = Path("generated_diagrams")
    try:
        output_dir.mkdir(exist_ok=True)
        test_file = output_dir / "test_write.tmp"
        test_file.write_text("test")
        test_file.unlink()
        logger.info("✓ Write permissions verified")
    except Exception as e:
        logger.error(f"✗ Write permission error: {e}")
        return False

    logger.info("✅ All system requirements validated successfully")
    return True


def generate_summary_report(diagrams: Dict[str, str]) -> str:
    """
    Generate a summary report of diagram generation.

    Args:
        diagrams (Dict[str, str]): Mapping of diagram names to file paths

    Returns:
        str: Summary report
    """
    report = []
    report.append("=" * 80)
    report.append("TOPIC 7: TERRAFORM MODULES - DIAGRAM GENERATION REPORT")
    report.append("=" * 80)
    report.append("")

    # Generation summary
    report.append(f"📊 GENERATION SUMMARY")
    report.append(f"   Total Diagrams Generated: {len(diagrams)}")
    report.append(f"   Output Directory: generated_diagrams/")
    report.append(f"   Resolution: {DIAGRAM_CONFIG['dpi']} DPI")
    report.append(f"   Format: {DIAGRAM_CONFIG['format'].upper()}")
    report.append("")

    # Individual diagram details
    report.append("📋 DIAGRAM DETAILS")
    for i, (name, path) in enumerate(diagrams.items(), 1):
        file_path = Path(path)
        if file_path.exists():
            file_size = file_path.stat().st_size / (1024 * 1024)  # MB
            status = "✅ Generated"
        else:
            file_size = 0
            status = "❌ Failed"

        report.append(f"   {i}. {name}")
        report.append(f"      File: {file_path.name}")
        report.append(f"      Size: {file_size:.2f} MB")
        report.append(f"      Status: {status}")
        report.append("")

    # Learning objectives alignment
    report.append("🎯 LEARNING OBJECTIVES ALIGNMENT")
    report.append("   Figure 7.1: Module Architecture and Design Patterns")
    report.append("   - Supports understanding of module design principles")
    report.append("   - Illustrates enterprise module architecture patterns")
    report.append("")
    report.append("   Figure 7.2: Module Composition and Dependency Management")
    report.append("   - Demonstrates complex module composition strategies")
    report.append("   - Shows dependency management and resolution patterns")
    report.append("")
    report.append("   Figure 7.3: Module Versioning and Lifecycle Management")
    report.append("   - Explains semantic versioning and release workflows")
    report.append("   - Illustrates enterprise lifecycle management")
    report.append("")
    report.append("   Figure 7.4: Module Testing and Validation Frameworks")
    report.append("   - Shows comprehensive testing strategies")
    report.append("   - Demonstrates quality assurance processes")
    report.append("")
    report.append("   Figure 7.5: Enterprise Module Governance and Registry")
    report.append("   - Illustrates governance frameworks and policies")
    report.append("   - Shows enterprise registry architecture")
    report.append("")

    # Usage instructions
    report.append("📖 USAGE INSTRUCTIONS")
    report.append("   1. Integration with Training Materials:")
    report.append("      - Reference diagrams in Concept.md")
    report.append("      - Include in Lab-7.md exercises")
    report.append("      - Use in presentations and documentation")
    report.append("")
    report.append("   2. Quality Standards:")
    report.append("      - 300 DPI resolution for professional printing")
    report.append("      - AWS brand compliant colors and styling")
    report.append("      - Consistent typography and layout")
    report.append("")
    report.append("   3. Customization:")
    report.append("      - Modify diagram_generation_script.py for changes")
    report.append("      - Update AWS_COLORS for custom branding")
    report.append("      - Adjust DIAGRAM_CONFIG for different output")
    report.append("")

    # Technical specifications
    report.append("🔧 TECHNICAL SPECIFICATIONS")
    report.append(f"   Python Version: {sys.version}")
    try:
        import diagrams as diagrams_lib
        diagrams_version = diagrams_lib.__version__
    except:
        diagrams_version = 'Unknown'
    report.append(f"   Diagrams Library: {diagrams_version}")
    report.append(f"   Output Format: PNG")
    report.append(f"   Color Depth: 24-bit")
    report.append(f"   Compression: Optimized")
    report.append("")

    report.append("=" * 80)
    report.append("🎉 DIAGRAM GENERATION COMPLETED SUCCESSFULLY!")
    report.append("=" * 80)

    return "\n".join(report)


def main():
    """
    Main function to generate all Topic 7 diagrams.
    """
    logger.info("Starting Topic 7: Terraform Modules diagram generation")

    # Validate system requirements
    if not validate_system_requirements():
        logger.error("System requirements validation failed")
        sys.exit(1)

    try:
        # Initialize diagram generator
        generator = TerraformModulesDiagramGenerator()

        # Generate all diagrams
        diagrams = generator.generate_all_diagrams()

        # Generate and display summary report
        report = generate_summary_report(diagrams)
        print(report)

        # Save report to file
        report_path = Path("generated_diagrams") / "generation_report.txt"
        report_path.write_text(report)
        logger.info(f"Generation report saved to: {report_path}")

        logger.info("🎉 All diagrams generated successfully!")

    except Exception as e:
        logger.error(f"Diagram generation failed: {e}")
        import traceback
        logger.error(traceback.format_exc())
        sys.exit(1)


if __name__ == "__main__":
    main()
