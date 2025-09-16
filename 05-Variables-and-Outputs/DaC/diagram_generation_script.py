#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 5: Variables and Outputs
Professional Diagram Generation Script (DaC - Diagram as Code)

This script generates 5 professional-quality diagrams for Topic 5 of the AWS Terraform
training curriculum. Each diagram is designed to support specific learning objectives
and enhance understanding of variable management, output patterns, validation workflows,
and data flow in enterprise Terraform configurations.

Generated Diagrams:
1. Figure 5.1: Variable Types and Validation Patterns
2. Figure 5.2: Output Values and Data Flow Management
3. Figure 5.3: Local Values and Computed Expressions
4. Figure 5.4: Variable Precedence and Configuration Hierarchy
5. Figure 5.5: Enterprise Variable Organization and Best Practices

Requirements:
- Python 3.9+
- All dependencies from requirements.txt
- Graphviz system installation
- 300 DPI output for professional quality

Author: AWS Terraform Training Team
Version: 5.0.0
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

class VariablesOutputsDiagramGenerator:
    """
    Professional diagram generator for Variables and Outputs.
    
    This class provides methods to generate high-quality architectural diagrams
    that support the learning objectives of Topic 5: Variables and Outputs.
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
        Generate all 5 professional diagrams for Topic 5.
        
        Returns:
            Dict[str, str]: Mapping of diagram names to file paths
        """
        logger.info("Starting generation of all Topic 5 diagrams")
        
        diagrams = {
            'figure_5_1': self.generate_variable_types_validation_diagram(),
            'figure_5_2': self.generate_output_data_flow_diagram(), 
            'figure_5_3': self.generate_local_values_expressions_diagram(),
            'figure_5_4': self.generate_variable_precedence_hierarchy_diagram(),
            'figure_5_5': self.generate_enterprise_organization_diagram()
        }
        
        logger.info(f"Successfully generated {len(diagrams)} diagrams")
        return diagrams
    
    def generate_variable_types_validation_diagram(self) -> str:
        """
        Generate Figure 5.1: Variable Types and Validation Patterns
        
        This diagram illustrates comprehensive variable types, validation rules,
        and advanced validation patterns for enterprise Terraform configurations.
        
        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 5.1: Variable Types and Validation Patterns")
        
        diagram_path = self.output_dir / "figure_5_1_variable_types_validation.png"
        
        with Diagram(
            "Figure 5.1: Variable Types and Validation Patterns",
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
            # Variable Types
            with Cluster("1. Variable Types", graph_attr={"bgcolor": "#E6F3FF"}):
                # Primitive Types
                with Cluster("Primitive Types", graph_attr={"bgcolor": "#F0F8FF"}):
                    string_type = Blank("string")
                    number_type = Blank("number")
                    bool_type = Blank("bool")
                
                # Collection Types
                with Cluster("Collection Types", graph_attr={"bgcolor": "#F5F5FF"}):
                    list_type = Blank("list(type)")
                    set_type = Blank("set(type)")
                    map_type = Blank("map(type)")
                
                # Structural Types
                with Cluster("Structural Types", graph_attr={"bgcolor": "#F8F8FF"}):
                    object_type = Blank("object({...})")
                    tuple_type = Blank("tuple([...])")
                    any_type = Blank("any")
            
            # Validation Rules
            with Cluster("2. Validation Rules", graph_attr={"bgcolor": "#FFF8DC"}):
                # Basic Validation
                with Cluster("Basic Validation", graph_attr={"bgcolor": "#FFFACD"}):
                    condition_check = Blank("condition")
                    error_message = Blank("error_message")
                    validation_func = Blank("validation\nfunction")
                
                # Advanced Validation
                with Cluster("Advanced Validation", graph_attr={"bgcolor": "#FFF8E1"}):
                    regex_validation = Blank("regex\nvalidation")
                    range_validation = Blank("range\nvalidation")
                    custom_validation = Blank("custom\nvalidation")
                
                # Complex Validation
                with Cluster("Complex Validation", graph_attr={"bgcolor": "#F8F8DC"}):
                    multi_condition = Blank("multi-condition\nvalidation")
                    cross_variable = Blank("cross-variable\nvalidation")
                    conditional_validation = Blank("conditional\nvalidation")
            
            # Validation Patterns
            with Cluster("3. Validation Patterns", graph_attr={"bgcolor": "#F0FFF0"}):
                # String Patterns
                with Cluster("String Patterns", graph_attr={"bgcolor": "#E6FFE6"}):
                    email_pattern = Blank("email\npattern")
                    cidr_pattern = Blank("CIDR\npattern")
                    arn_pattern = Blank("ARN\npattern")
                
                # Numeric Patterns
                with Cluster("Numeric Patterns", graph_attr={"bgcolor": "#F0FFF0"}):
                    port_range = Blank("port\nrange")
                    cpu_limits = Blank("CPU\nlimits")
                    memory_size = Blank("memory\nsize")
                
                # Collection Patterns
                with Cluster("Collection Patterns", graph_attr={"bgcolor": "#FFF8F0"}):
                    length_validation = Blank("length\nvalidation")
                    unique_values = Blank("unique\nvalues")
                    allowed_values = Blank("allowed\nvalues")
            
            # Enterprise Patterns
            with Cluster("4. Enterprise Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Security Validation
                with Cluster("Security Validation", graph_attr={"bgcolor": "#FFF8DC"}):
                    sensitive_data = Blank("sensitive\ndata")
                    encryption_keys = Blank("encryption\nkeys")
                    access_patterns = Blank("access\npatterns")
                
                # Compliance Validation
                with Cluster("Compliance Validation", graph_attr={"bgcolor": "#FFFACD"}):
                    naming_standards = Blank("naming\nstandards")
                    tagging_rules = Blank("tagging\nrules")
                    policy_compliance = Blank("policy\ncompliace")
            
            # Validation flow
            string_type >> condition_check >> regex_validation
            number_type >> range_validation >> port_range
            object_type >> multi_condition >> cross_variable
            
            # Pattern connections
            email_pattern >> sensitive_data
            cidr_pattern >> access_patterns
            naming_standards >> tagging_rules
        
        logger.info(f"Generated Figure 5.1 at: {diagram_path}")
        return str(diagram_path)

    def generate_output_data_flow_diagram(self) -> str:
        """
        Generate Figure 5.2: Output Values and Data Flow Management

        This diagram shows output value patterns, data flow between configurations,
        and advanced output management strategies.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 5.2: Output Values and Data Flow Management")

        diagram_path = self.output_dir / "figure_5_2_output_data_flow.png"

        with Diagram(
            "Figure 5.2: Output Values and Data Flow Management",
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
            # Output Sources
            with Cluster("Output Sources", graph_attr={"bgcolor": "#E6F3FF"}):
                # Resource Outputs
                with Cluster("Resource Outputs", graph_attr={"bgcolor": "#F0F8FF"}):
                    resource_attrs = Blank("Resource\nAttributes")
                    computed_values = Blank("Computed\nValues")
                    resource_ids = Blank("Resource\nIDs")

                # Data Source Outputs
                with Cluster("Data Source Outputs", graph_attr={"bgcolor": "#F5F5FF"}):
                    external_data = Blank("External\nData")
                    existing_resources = Blank("Existing\nResources")
                    api_responses = Blank("API\nResponses")

                # Local Computations
                with Cluster("Local Computations", graph_attr={"bgcolor": "#F8F8FF"}):
                    local_values = Blank("Local\nValues")
                    expressions = Blank("Expressions")
                    functions = Blank("Functions")

            # Output Processing
            with Cluster("Output Processing", graph_attr={"bgcolor": "#FFF8DC"}):
                # Value Transformation
                with Cluster("Value Transformation", graph_attr={"bgcolor": "#FFFACD"}):
                    formatting = Blank("Formatting")
                    filtering = Blank("Filtering")
                    aggregation = Blank("Aggregation")

                # Sensitive Handling
                with Cluster("Sensitive Handling", graph_attr={"bgcolor": "#FFF8E1"}):
                    sensitive_flag = Blank("sensitive\nflag")
                    masking = Blank("Value\nMasking")
                    secure_storage = Blank("Secure\nStorage")

                # Validation
                with Cluster("Output Validation", graph_attr={"bgcolor": "#F8F8DC"}):
                    type_checking = Blank("Type\nChecking")
                    value_validation = Blank("Value\nValidation")
                    dependency_check = Blank("Dependency\nCheck")

            # Output Consumers
            with Cluster("Output Consumers", graph_attr={"bgcolor": "#F0FFF0"}):
                # Module Integration
                with Cluster("Module Integration", graph_attr={"bgcolor": "#E6FFE6"}):
                    parent_module = Blank("Parent\nModule")
                    child_modules = Blank("Child\nModules")
                    module_chain = Blank("Module\nChain")

                # External Systems
                with Cluster("External Systems", graph_attr={"bgcolor": "#F0FFF0"}):
                    ci_cd_pipeline = Blank("CI/CD\nPipeline")
                    monitoring = Blank("Monitoring\nSystems")
                    documentation = Blank("Documentation\nGeneration")

                # State Management
                with Cluster("State Management", graph_attr={"bgcolor": "#FFF8F0"}):
                    remote_state = S3("Remote\nState")
                    state_sharing = Blank("State\nSharing")
                    backend_config = Blank("Backend\nConfig")

            # Data Flow Patterns
            with Cluster("Data Flow Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Hierarchical Flow
                with Cluster("Hierarchical Flow", graph_attr={"bgcolor": "#FFF8DC"}):
                    top_down = Blank("Top-Down\nFlow")
                    bottom_up = Blank("Bottom-Up\nFlow")
                    bidirectional = Blank("Bidirectional\nFlow")

                # Cross-Configuration
                with Cluster("Cross-Configuration", graph_attr={"bgcolor": "#FFFACD"}):
                    config_chaining = Blank("Configuration\nChaining")
                    data_passing = Blank("Data\nPassing")
                    dependency_graph = Blank("Dependency\nGraph")

            # Data flow connections
            resource_attrs >> formatting >> parent_module
            computed_values >> sensitive_flag >> secure_storage
            external_data >> type_checking >> ci_cd_pipeline

            # Pattern flows
            local_values >> aggregation >> module_chain
            expressions >> value_validation >> state_sharing
            top_down >> config_chaining >> dependency_graph

        logger.info(f"Generated Figure 5.2 at: {diagram_path}")
        return str(diagram_path)

    def generate_local_values_expressions_diagram(self) -> str:
        """
        Generate Figure 5.3: Local Values and Computed Expressions

        This diagram demonstrates local value patterns, computed expressions,
        and advanced expression evaluation in Terraform configurations.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 5.3: Local Values and Computed Expressions")

        diagram_path = self.output_dir / "figure_5_3_local_values_expressions.png"

        with Diagram(
            "Figure 5.3: Local Values and Computed Expressions",
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
            # Local Value Sources
            with Cluster("Local Value Sources", graph_attr={"bgcolor": "#E6F3FF"}):
                # Variable References
                with Cluster("Variable References", graph_attr={"bgcolor": "#F0F8FF"}):
                    input_variables = Blank("Input\nVariables")
                    environment_vars = Blank("Environment\nVariables")
                    default_values = Blank("Default\nValues")

                # Resource References
                with Cluster("Resource References", graph_attr={"bgcolor": "#F5F5FF"}):
                    resource_outputs = Blank("Resource\nOutputs")
                    data_sources = Blank("Data\nSources")
                    module_outputs = Blank("Module\nOutputs")

                # External Data
                with Cluster("External Data", graph_attr={"bgcolor": "#F8F8FF"}):
                    external_apis = Blank("External\nAPIs")
                    file_data = Blank("File\nData")
                    template_data = Blank("Template\nData")

            # Expression Types
            with Cluster("Expression Types", graph_attr={"bgcolor": "#FFF8DC"}):
                # Arithmetic Expressions
                with Cluster("Arithmetic", graph_attr={"bgcolor": "#FFFACD"}):
                    mathematical = Blank("Mathematical\nOperations")
                    string_ops = Blank("String\nOperations")
                    logical_ops = Blank("Logical\nOperations")

                # Collection Expressions
                with Cluster("Collections", graph_attr={"bgcolor": "#FFF8E1"}):
                    for_expressions = Blank("for\nExpressions")
                    conditional_expr = Blank("Conditional\nExpressions")
                    splat_expressions = Blank("Splat\nExpressions")

                # Function Calls
                with Cluster("Functions", graph_attr={"bgcolor": "#F8F8DC"}):
                    built_in_functions = Blank("Built-in\nFunctions")
                    string_functions = Blank("String\nFunctions")
                    collection_functions = Blank("Collection\nFunctions")

            # Computation Patterns
            with Cluster("Computation Patterns", graph_attr={"bgcolor": "#F0FFF0"}):
                # Data Transformation
                with Cluster("Data Transformation", graph_attr={"bgcolor": "#E6FFE6"}):
                    data_mapping = Blank("Data\nMapping")
                    data_filtering = Blank("Data\nFiltering")
                    data_aggregation = Blank("Data\nAggregation")

                # Configuration Generation
                with Cluster("Configuration Generation", graph_attr={"bgcolor": "#F0FFF0"}):
                    dynamic_config = Blank("Dynamic\nConfiguration")
                    template_rendering = Blank("Template\nRendering")
                    conditional_logic = Blank("Conditional\nLogic")

                # Validation and Checks
                with Cluster("Validation", graph_attr={"bgcolor": "#FFF8F0"}):
                    value_validation = Blank("Value\nValidation")
                    type_conversion = Blank("Type\nConversion")
                    error_handling = Blank("Error\nHandling")

            # Advanced Patterns
            with Cluster("Advanced Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Complex Computations
                with Cluster("Complex Computations", graph_attr={"bgcolor": "#FFF8DC"}):
                    nested_loops = Blank("Nested\nLoops")
                    recursive_data = Blank("Recursive\nData")
                    graph_traversal = Blank("Graph\nTraversal")

                # Performance Optimization
                with Cluster("Performance", graph_attr={"bgcolor": "#FFFACD"}):
                    lazy_evaluation = Blank("Lazy\nEvaluation")
                    caching = Blank("Expression\nCaching")
                    optimization = Blank("Performance\nOptimization")

            # Expression flow
            input_variables >> mathematical >> data_mapping
            resource_outputs >> for_expressions >> dynamic_config
            data_sources >> built_in_functions >> value_validation

            # Advanced patterns
            conditional_expr >> nested_loops >> lazy_evaluation
            collection_functions >> data_aggregation >> caching
            template_data >> template_rendering >> optimization

        logger.info(f"Generated Figure 5.3 at: {diagram_path}")
        return str(diagram_path)

    def generate_variable_precedence_hierarchy_diagram(self) -> str:
        """
        Generate Figure 5.4: Variable Precedence and Configuration Hierarchy

        This diagram illustrates variable precedence rules, configuration hierarchy,
        and advanced variable resolution patterns.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 5.4: Variable Precedence and Configuration Hierarchy")

        diagram_path = self.output_dir / "figure_5_4_variable_precedence_hierarchy.png"

        with Diagram(
            "Figure 5.4: Variable Precedence and Configuration Hierarchy",
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
            # Precedence Hierarchy (Highest to Lowest)
            with Cluster("Variable Precedence Hierarchy", graph_attr={"bgcolor": "#E6F3FF"}):
                # Highest Precedence
                with Cluster("1. Highest Precedence", graph_attr={"bgcolor": "#FFE6E6"}):
                    command_line = Bash("-var and\n-var-file")
                    tf_vars_env = Blank("TF_VAR_*\nEnvironment")

                # High Precedence
                with Cluster("2. High Precedence", graph_attr={"bgcolor": "#FFF0F0"}):
                    terraform_tfvars = Blank("terraform.tfvars")
                    terraform_tfvars_json = Blank("terraform.tfvars.json")
                    auto_tfvars = Blank("*.auto.tfvars")

                # Medium Precedence
                with Cluster("3. Medium Precedence", graph_attr={"bgcolor": "#FFF5F5"}):
                    tfvars_files = Blank(".tfvars files\n(alphabetical)")
                    workspace_vars = Blank("Workspace\nVariables")

                # Lowest Precedence
                with Cluster("4. Lowest Precedence", graph_attr={"bgcolor": "#FFFAFA"}):
                    default_values = Blank("Variable\nDefaults")
                    implicit_defaults = Blank("Implicit\nDefaults")

            # Configuration Sources
            with Cluster("Configuration Sources", graph_attr={"bgcolor": "#FFF8DC"}):
                # File-based Configuration
                with Cluster("File-based", graph_attr={"bgcolor": "#FFFACD"}):
                    variable_files = Blank("Variable\nFiles")
                    config_files = Blank("Configuration\nFiles")
                    module_configs = Blank("Module\nConfigurations")

                # Environment-based
                with Cluster("Environment-based", graph_attr={"bgcolor": "#FFF8E1"}):
                    env_variables = Blank("Environment\nVariables")
                    shell_vars = Blank("Shell\nVariables")
                    system_vars = Blank("System\nVariables")

                # Runtime Configuration
                with Cluster("Runtime", graph_attr={"bgcolor": "#F8F8DC"}):
                    cli_args = Bash("CLI\nArguments")
                    interactive_input = Blank("Interactive\nInput")
                    api_config = Blank("API\nConfiguration")

            # Resolution Process
            with Cluster("Variable Resolution Process", graph_attr={"bgcolor": "#F0FFF0"}):
                # Collection Phase
                with Cluster("Collection Phase", graph_attr={"bgcolor": "#E6FFE6"}):
                    source_scanning = Blank("Source\nScanning")
                    value_collection = Blank("Value\nCollection")
                    precedence_sorting = Blank("Precedence\nSorting")

                # Resolution Phase
                with Cluster("Resolution Phase", graph_attr={"bgcolor": "#F0FFF0"}):
                    conflict_resolution = Blank("Conflict\nResolution")
                    value_merging = Blank("Value\nMerging")
                    final_assignment = Blank("Final\nAssignment")

                # Validation Phase
                with Cluster("Validation Phase", graph_attr={"bgcolor": "#FFF8F0"}):
                    type_validation = Blank("Type\nValidation")
                    constraint_check = Blank("Constraint\nCheck")
                    dependency_resolution = Blank("Dependency\nResolution")

            # Enterprise Patterns
            with Cluster("Enterprise Configuration Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Environment Management
                with Cluster("Environment Management", graph_attr={"bgcolor": "#FFF8DC"}):
                    env_separation = Blank("Environment\nSeparation")
                    config_inheritance = Blank("Configuration\nInheritance")
                    override_patterns = Blank("Override\nPatterns")

                # Security Patterns
                with Cluster("Security Patterns", graph_attr={"bgcolor": "#FFFACD"}):
                    sensitive_vars = Blank("Sensitive\nVariables")
                    secret_management = Blank("Secret\nManagement")
                    access_control = Blank("Access\nControl")

            # Precedence flow (highest to lowest)
            command_line >> Edge(label="overrides") >> terraform_tfvars
            terraform_tfvars >> Edge(label="overrides") >> auto_tfvars
            auto_tfvars >> Edge(label="overrides") >> tfvars_files
            tfvars_files >> Edge(label="overrides") >> default_values

            # Resolution process flow
            source_scanning >> value_collection >> precedence_sorting
            precedence_sorting >> conflict_resolution >> value_merging
            value_merging >> type_validation >> final_assignment

            # Enterprise patterns
            env_separation >> config_inheritance >> override_patterns
            sensitive_vars >> secret_management >> access_control

        logger.info(f"Generated Figure 5.4 at: {diagram_path}")
        return str(diagram_path)

    def generate_enterprise_organization_diagram(self) -> str:
        """
        Generate Figure 5.5: Enterprise Variable Organization and Best Practices

        This diagram shows enterprise-scale variable organization patterns,
        best practices, and governance strategies.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 5.5: Enterprise Variable Organization and Best Practices")

        diagram_path = self.output_dir / "figure_5_5_enterprise_organization.png"

        with Diagram(
            "Figure 5.5: Enterprise Variable Organization and Best Practices",
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
            # Organization Structure
            with Cluster("Variable Organization Structure", graph_attr={"bgcolor": "#E6F3FF"}):
                # Hierarchical Organization
                with Cluster("Hierarchical", graph_attr={"bgcolor": "#F0F8FF"}):
                    global_vars = Blank("Global\nVariables")
                    environment_vars = Blank("Environment\nVariables")
                    application_vars = Blank("Application\nVariables")
                    component_vars = Blank("Component\nVariables")

                # Functional Organization
                with Cluster("Functional", graph_attr={"bgcolor": "#F5F5FF"}):
                    network_vars = Blank("Network\nVariables")
                    security_vars = Blank("Security\nVariables")
                    compute_vars = Blank("Compute\nVariables")
                    storage_vars = Blank("Storage\nVariables")

            # Best Practices
            with Cluster("Enterprise Best Practices", graph_attr={"bgcolor": "#FFF8DC"}):
                # Naming Conventions
                with Cluster("Naming Conventions", graph_attr={"bgcolor": "#FFFACD"}):
                    naming_standards = Blank("Naming\nStandards")
                    prefix_patterns = Blank("Prefix\nPatterns")
                    categorization = Blank("Variable\nCategorization")

                # Documentation
                with Cluster("Documentation", graph_attr={"bgcolor": "#FFF8E1"}):
                    variable_docs = Blank("Variable\nDocumentation")
                    usage_examples = Blank("Usage\nExamples")
                    change_logs = Blank("Change\nLogs")

                # Validation Standards
                with Cluster("Validation", graph_attr={"bgcolor": "#F8F8DC"}):
                    validation_rules = Blank("Validation\nRules")
                    testing_patterns = Blank("Testing\nPatterns")
                    quality_gates = Blank("Quality\nGates")

            # Governance Framework
            with Cluster("Governance Framework", graph_attr={"bgcolor": "#F0FFF0"}):
                # Policy Management
                with Cluster("Policy Management", graph_attr={"bgcolor": "#E6FFE6"}):
                    variable_policies = Blank("Variable\nPolicies")
                    compliance_rules = Blank("Compliance\nRules")
                    audit_trails = Blank("Audit\nTrails")

                # Access Control
                with Cluster("Access Control", graph_attr={"bgcolor": "#F0FFF0"}):
                    role_based_access = IAM("Role-based\nAccess")
                    permission_matrix = Blank("Permission\nMatrix")
                    approval_workflows = Blank("Approval\nWorkflows")

                # Change Management
                with Cluster("Change Management", graph_attr={"bgcolor": "#FFF8F0"}):
                    version_control = Git("Version\nControl")
                    change_approval = Blank("Change\nApproval")
                    rollback_procedures = Blank("Rollback\nProcedures")

            # Implementation Patterns
            with Cluster("Implementation Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Modular Patterns
                with Cluster("Modular Patterns", graph_attr={"bgcolor": "#FFF8DC"}):
                    module_variables = Blank("Module\nVariables")
                    variable_passing = Blank("Variable\nPassing")
                    interface_design = Blank("Interface\nDesign")

                # Automation Patterns
                with Cluster("Automation", graph_attr={"bgcolor": "#FFFACD"}):
                    automated_validation = Blank("Automated\nValidation")
                    ci_cd_integration = Codepipeline("CI/CD\nIntegration")
                    deployment_automation = Blank("Deployment\nAutomation")

            # Organization flow
            global_vars >> environment_vars >> application_vars >> component_vars

            # Best practices flow
            naming_standards >> variable_docs >> validation_rules
            prefix_patterns >> usage_examples >> testing_patterns
            categorization >> change_logs >> quality_gates

            # Governance flow
            variable_policies >> role_based_access >> version_control
            compliance_rules >> permission_matrix >> change_approval
            audit_trails >> approval_workflows >> rollback_procedures

            # Implementation flow
            module_variables >> automated_validation >> ci_cd_integration
            variable_passing >> deployment_automation
            interface_design >> automated_validation

        logger.info(f"Generated Figure 5.5 at: {diagram_path}")
        return str(diagram_path)


def main():
    """
    Main execution function for generating all Topic 5 diagrams.

    This function initializes the diagram generator and creates all 5 professional
    diagrams for the Variables and Outputs topic.
    """
    logger.info("Starting AWS Terraform Training Topic 5 diagram generation")

    try:
        # Initialize diagram generator
        generator = VariablesOutputsDiagramGenerator()

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
