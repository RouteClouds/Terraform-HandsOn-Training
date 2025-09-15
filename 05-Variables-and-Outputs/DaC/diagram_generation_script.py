#!/usr/bin/env python3
"""
Professional Diagram Generation Script for Topic 5: Variables and Outputs

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
    from diagrams.aws.compute import EC2, AutoScaling
    from diagrams.aws.database import RDS, DynamodbTable
    from diagrams.aws.network import VPC, PrivateSubnet, PublicSubnet, NATGateway, InternetGateway
    from diagrams.aws.security import IAM, SecretsManager, KMS
    from diagrams.generic.storage import Storage
    from diagrams.aws.storage import S3
    from diagrams.aws.management import SystemsManager, Cloudwatch, Cloudtrail
    from diagrams.aws.integration import SNS
    from diagrams.onprem.iac import Terraform
    from diagrams.programming.language import Python
    from diagrams.generic.blank import Blank
    from diagrams.generic.database import SQL
    from diagrams.generic.network import Firewall
    from diagrams.generic.storage import Storage
    from diagrams.onprem.vcs import Git
    from diagrams.onprem.ci import Jenkins
    from diagrams.onprem.client import Users as LocalUsers
    from diagrams.onprem.monitoring import Grafana
except ImportError as e:
    print(f"❌ Error importing diagram libraries: {e}")
    print("Please install required dependencies: pip install -r requirements.txt")
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

def create_variable_architecture_patterns():
    """
    Figure 5.1: Terraform Variable Architecture and Type Management

    This diagram demonstrates enterprise variable architecture with type hierarchies,
    validation layers, and AWS integration for dynamic configuration management.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 5.1: Terraform Variable Architecture and Type Management",
        filename=str(output_dir / "figure_5_1_variable_architecture"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Variable Input Sources
        with Cluster("Variable Input Sources"):
            # Configuration Files
            with Cluster("Configuration Files"):
                variables_tf = Storage("variables.tf")
                terraform_tfvars = Storage("terraform.tfvars")
                env_tfvars = Storage("environment.tfvars")

            # External Sources
            with Cluster("External Sources"):
                environment_vars = Storage("Environment Variables")
                cli_arguments = Storage("CLI Arguments")
                workspace_vars = Storage("Workspace Variables")

            # AWS Integration
            with Cluster("AWS Parameter Sources"):
                parameter_store = SystemsManager("Parameter Store")
                secrets_manager = SecretsManager("Secrets Manager")
                kms_encryption = KMS("KMS Encryption")

        # Variable Type System
        with Cluster("Variable Type System"):
            # Primitive Types
            with Cluster("Primitive Types"):
                string_type = Storage("string")
                number_type = Storage("number")
                bool_type = Storage("bool")

            # Collection Types
            with Cluster("Collection Types"):
                list_type = Storage("list(type)")
                map_type = Storage("map(type)")
                set_type = Storage("set(type)")

            # Structural Types
            with Cluster("Structural Types"):
                object_type = Storage("object({...})")
                tuple_type = Storage("tuple([...])")

            # Advanced Types
            with Cluster("Advanced Types"):
                optional_type = Storage("optional(type)")
                nullable_type = Storage("nullable(type)")
                sensitive_type = Storage("sensitive(type)")

        # Validation Framework
        with Cluster("Validation Framework"):
            # Type Validation
            with Cluster("Type Validation"):
                type_checking = Storage("Type Checking")
                constraint_validation = Storage("Constraint Validation")

            # Business Rules
            with Cluster("Business Rules Validation"):
                range_validation = Storage("Range Validation")
                pattern_validation = Storage("Pattern Validation")
                conditional_validation = Storage("Conditional Validation")

            # Security Validation
            with Cluster("Security Validation"):
                sensitive_detection = Storage("Sensitive Data Detection")
                encryption_validation = Storage("Encryption Validation")
                compliance_checks = Storage("Compliance Checks")

        # Variable Processing Engine
        with Cluster("Variable Processing Engine"):
            # Local Values
            with Cluster("Local Values Processing"):
                computation_engine = Storage("Computation Engine")
                expression_evaluation = Storage("Expression Evaluation")
                function_processing = Storage("Function Processing")

            # Environment Management
            with Cluster("Environment Management"):
                environment_selection = Storage("Environment Selection")
                variable_inheritance = Storage("Variable Inheritance")
                override_resolution = Storage("Override Resolution")

            # Dynamic Configuration
            with Cluster("Dynamic Configuration"):
                conditional_logic = Storage("Conditional Logic")
                loop_processing = Storage("Loop Processing")
                template_rendering = Storage("Template Rendering")

        # Output Configuration
        with Cluster("Configuration Output"):
            # Resource Configuration
            with Cluster("Resource Configuration"):
                resource_attributes = Storage("Resource Attributes")
                meta_arguments = Storage("Meta-Arguments")
                lifecycle_rules = Storage("Lifecycle Rules")

            # Module Integration
            with Cluster("Module Integration"):
                module_inputs = Storage("Module Inputs")
                variable_passing = Storage("Variable Passing")
                composition_patterns = Storage("Composition Patterns")

            # Automation Interfaces
            with Cluster("Automation Interfaces"):
                ci_cd_integration = Jenkins("CI/CD Integration")
                api_interfaces = Storage("API Interfaces")
                monitoring_config = Cloudwatch("Monitoring Config")

        # Variable Flow
        variables_tf >> Edge(label="defines", color=COLORS['primary']) >> [string_type, object_type, sensitive_type]
        terraform_tfvars >> Edge(label="provides values", color=COLORS['success']) >> type_checking
        env_tfvars >> Edge(label="environment specific", color=COLORS['accent']) >> environment_selection

        # AWS Integration Flow
        parameter_store >> Edge(label="non-sensitive", color=COLORS['success']) >> computation_engine
        secrets_manager >> Edge(label="sensitive", color=COLORS['warning']) >> sensitive_detection
        kms_encryption >> Edge(label="encrypts", color=COLORS['secondary']) >> secrets_manager

        # Validation Flow
        type_checking >> Edge(label="validates", color=COLORS['success']) >> computation_engine
        pattern_validation >> Edge(label="business rules", color=COLORS['accent']) >> expression_evaluation
        sensitive_detection >> Edge(label="security", color=COLORS['warning']) >> encryption_validation

        # Processing Flow
        computation_engine >> Edge(label="computes", color=COLORS['primary']) >> resource_attributes
        environment_selection >> Edge(label="configures", color=COLORS['accent']) >> module_inputs
        conditional_logic >> Edge(label="automates", color=COLORS['success']) >> ci_cd_integration

        # Output Flow
        resource_attributes >> Edge(label="configures", color=COLORS['primary']) >> EC2("Infrastructure")
        module_inputs >> Edge(label="integrates", color=COLORS['accent']) >> Storage("Modules")
        monitoring_config >> Edge(label="observes", color=COLORS['success']) >> Cloudtrail("Audit Trail")

def create_output_architecture_patterns():
    """
    Figure 5.2: Terraform Output Architecture and Data Flow Patterns

    This diagram shows sophisticated output patterns for module integration,
    automation interfaces, and enterprise data flow management.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 5.2: Terraform Output Architecture and Data Flow",
        filename=str(output_dir / "figure_5_2_output_architecture"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Infrastructure Resource Layer
        with Cluster("Infrastructure Resource Layer"):
            # Network Resources
            with Cluster("Network Resources"):
                vpc_resource = VPC("VPC")
                subnets_resource = PrivateSubnet("Subnets")
                security_groups = Storage("Security Groups")

            # Compute Resources
            with Cluster("Compute Resources"):
                ec2_instances = EC2("EC2 Instances")
                auto_scaling_groups = AutoScaling("Auto Scaling Groups")
                load_balancers = Storage("Load Balancers")

            # Data Resources
            with Cluster("Data Resources"):
                rds_databases = RDS("RDS Databases")
                s3_buckets = S3("S3 Buckets")
                dynamodb_tables = DynamodbTable("DynamoDB Tables")

        # Output Processing Layer
        with Cluster("Output Processing Layer"):
            # Output Categories
            with Cluster("Output Categories"):
                infrastructure_outputs = Storage("Infrastructure Outputs")
                security_outputs = Storage("Security Outputs")
                connectivity_outputs = Storage("Connectivity Outputs")
                monitoring_outputs = Storage("Monitoring Outputs")

            # Output Types
            with Cluster("Output Types"):
                simple_outputs = Storage("Simple Values")
                complex_outputs = Storage("Complex Objects")
                sensitive_outputs = Storage("Sensitive Outputs")
                computed_outputs = Storage("Computed Values")

            # Output Processing
            with Cluster("Output Processing"):
                value_transformation = Storage("Value Transformation")
                data_aggregation = Storage("Data Aggregation")
                conditional_outputs = Storage("Conditional Outputs")

        # Integration Interface Layer
        with Cluster("Integration Interface Layer"):
            # Module Integration
            with Cluster("Module Integration"):
                parent_module = Storage("Parent Module")
                child_modules = Storage("Child Modules")
                module_composition = Storage("Module Composition")

            # Automation Interfaces
            with Cluster("Automation Interfaces"):
                ci_cd_integration = Jenkins("CI/CD Integration")
                api_endpoints = Storage("API Endpoints")
                webhook_integration = Storage("Webhook Integration")

            # Monitoring Integration
            with Cluster("Monitoring Integration"):
                cloudwatch_integration = Cloudwatch("CloudWatch")
                grafana_dashboards = Grafana("Grafana Dashboards")
                alerting_systems = SNS("Alerting Systems")

        # Consumer Layer
        with Cluster("Consumer Layer"):
            # Infrastructure Consumers
            with Cluster("Infrastructure Consumers"):
                networking_module = Storage("Networking Module")
                compute_module = Storage("Compute Module")
                database_module = Storage("Database Module")

            # Operational Consumers
            with Cluster("Operational Consumers"):
                monitoring_stack = Storage("Monitoring Stack")
                backup_systems = Storage("Backup Systems")
                disaster_recovery = Storage("Disaster Recovery")

            # Business Consumers
            with Cluster("Business Consumers"):
                cost_tracking = Storage("Cost Tracking")
                compliance_reporting = Storage("Compliance Reporting")
                capacity_planning = Storage("Capacity Planning")

        # Output Patterns
        with Cluster("Enterprise Output Patterns"):
            # Structured Patterns
            with Cluster("Structured Output Patterns"):
                hierarchical_outputs = Storage("Hierarchical Structure")
                tagged_outputs = Storage("Tagged Outputs")
                versioned_outputs = Storage("Versioned Outputs")

            # Security Patterns
            with Cluster("Security Output Patterns"):
                encrypted_outputs = Storage("Encrypted Outputs")
                role_based_access = Storage("Role-based Access")
                audit_trail = Storage("Audit Trail")

            # Integration Patterns
            with Cluster("Integration Patterns"):
                chaining_patterns = Storage("Output Chaining")
                dependency_patterns = Storage("Dependency Patterns")
                composition_patterns = Storage("Composition Patterns")

        # Data Flow
        # Infrastructure to Outputs
        [vpc_resource, subnets_resource, security_groups] >> Edge(label="network data", color=COLORS['success']) >> connectivity_outputs
        [ec2_instances, auto_scaling_groups, load_balancers] >> Edge(label="compute data", color=COLORS['accent']) >> infrastructure_outputs
        [rds_databases, s3_buckets, dynamodb_tables] >> Edge(label="data layer", color=COLORS['primary']) >> security_outputs

        # Output Processing
        infrastructure_outputs >> Edge(label="transforms", color=COLORS['success']) >> value_transformation
        security_outputs >> Edge(label="aggregates", color=COLORS['warning']) >> data_aggregation
        connectivity_outputs >> Edge(label="conditions", color=COLORS['accent']) >> conditional_outputs

        # Output Types
        value_transformation >> [simple_outputs, complex_outputs]
        data_aggregation >> [sensitive_outputs, computed_outputs]

        # Integration Flow
        complex_outputs >> Edge(label="module inputs", color=COLORS['primary']) >> module_composition
        computed_outputs >> Edge(label="automation", color=COLORS['accent']) >> ci_cd_integration
        sensitive_outputs >> Edge(label="monitoring", color=COLORS['success']) >> cloudwatch_integration

        # Consumer Flow
        module_composition >> [networking_module, compute_module, database_module]
        ci_cd_integration >> [monitoring_stack, backup_systems]
        cloudwatch_integration >> [cost_tracking, compliance_reporting]

        # Pattern Application
        hierarchical_outputs >> Edge(label="structures", color=COLORS['primary']) >> module_composition
        encrypted_outputs >> Edge(label="secures", color=COLORS['warning']) >> role_based_access
        chaining_patterns >> Edge(label="integrates", color=COLORS['success']) >> dependency_patterns

def create_environment_configuration_management():
    """
    Figure 5.3: Environment Configuration Management and Variable Inheritance

    This diagram demonstrates sophisticated environment-specific configuration
    patterns with inheritance, overrides, and dynamic parameter management.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 5.3: Environment Configuration Management",
        filename=str(output_dir / "figure_5_3_environment_configuration"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Base Configuration Layer
        with Cluster("Base Configuration Layer"):
            # Global Defaults
            with Cluster("Global Defaults"):
                global_variables = Storage("global.tfvars")
                default_tags = Storage("Default Tags")
                security_baseline = Storage("Security Baseline")
                compliance_rules = Storage("Compliance Rules")

            # Organizational Standards
            with Cluster("Organizational Standards"):
                naming_conventions = Storage("Naming Conventions")
                resource_standards = Storage("Resource Standards")
                cost_policies = Storage("Cost Policies")
                monitoring_standards = Storage("Monitoring Standards")

        # Environment-Specific Configuration
        with Cluster("Environment-Specific Configuration"):
            # Development Environment
            with Cluster("Development Environment"):
                dev_variables = Storage("dev.tfvars")
                dev_instance_types = Storage("t3.micro, t3.small")
                dev_scaling = Storage("Min: 1, Max: 2")
                dev_cost_optimization = Storage("Spot Instances: Enabled")

            # Staging Environment
            with Cluster("Staging Environment"):
                staging_variables = Storage("staging.tfvars")
                staging_instance_types = Storage("t3.medium, m5.large")
                staging_scaling = Storage("Min: 2, Max: 5")
                staging_monitoring = Storage("Enhanced Monitoring")

            # Production Environment
            with Cluster("Production Environment"):
                prod_variables = Storage("prod.tfvars")
                prod_instance_types = Storage("m5.large, m5.xlarge")
                prod_scaling = Storage("Min: 3, Max: 20")
                prod_ha_config = Storage("Multi-AZ, Auto-failover")

        # Variable Processing Engine
        with Cluster("Variable Processing Engine"):
            # Inheritance Processing
            with Cluster("Inheritance Processing"):
                inheritance_resolver = Storage("Inheritance Resolver")
                precedence_engine = Storage("Precedence Engine")
                merge_strategy = Storage("Merge Strategy")

            # Validation Engine
            with Cluster("Validation Engine"):
                type_validator = Storage("Type Validator")
                business_rules = Storage("Business Rules")
                security_validator = Storage("Security Validator")

            # Dynamic Configuration
            with Cluster("Dynamic Configuration"):
                conditional_logic = Storage("Conditional Logic")
                expression_evaluator = Storage("Expression Evaluator")
                template_processor = Storage("Template Processor")

        # AWS Parameter Integration
        with Cluster("AWS Parameter Integration"):
            # Parameter Store Integration
            with Cluster("Parameter Store Integration"):
                environment_params = SystemsManager("Environment Parameters")
                feature_flags = SystemsManager("Feature Flags")
                configuration_data = SystemsManager("Configuration Data")

            # Secrets Management
            with Cluster("Secrets Management"):
                database_credentials = SecretsManager("Database Credentials")
                api_keys = SecretsManager("API Keys")
                certificates = SecretsManager("SSL Certificates")

            # Security Layer
            with Cluster("Security Layer"):
                kms_encryption = KMS("KMS Encryption")
                iam_roles = IAM("IAM Roles")
                access_policies = Storage("Access Policies")

        # Final Configuration Output
        with Cluster("Final Configuration Output"):
            # Environment Configurations
            with Cluster("Environment Configurations"):
                dev_final_config = Storage("Development Config")
                staging_final_config = Storage("Staging Config")
                prod_final_config = Storage("Production Config")

            # Infrastructure Deployment
            with Cluster("Infrastructure Deployment"):
                dev_infrastructure = EC2("Dev Infrastructure")
                staging_infrastructure = AutoScaling("Staging Infrastructure")
                prod_infrastructure = Storage("Prod Infrastructure")

            # Monitoring and Compliance
            with Cluster("Monitoring and Compliance"):
                environment_monitoring = Cloudwatch("Environment Monitoring")
                compliance_reporting = Storage("Compliance Reporting")
                cost_tracking = Storage("Cost Tracking")

        # Configuration Flow
        # Base to Processing
        global_variables >> Edge(label="base config", color=COLORS['primary']) >> inheritance_resolver
        default_tags >> Edge(label="defaults", color=COLORS['success']) >> precedence_engine
        security_baseline >> Edge(label="security", color=COLORS['warning']) >> security_validator

        # Environment-specific to Processing
        dev_variables >> Edge(label="dev overrides", color=COLORS['accent']) >> merge_strategy
        staging_variables >> Edge(label="staging overrides", color=COLORS['accent']) >> merge_strategy
        prod_variables >> Edge(label="prod overrides", color=COLORS['accent']) >> merge_strategy

        # Processing Flow
        inheritance_resolver >> Edge(label="resolves", color=COLORS['primary']) >> type_validator
        precedence_engine >> Edge(label="prioritizes", color=COLORS['success']) >> business_rules
        merge_strategy >> Edge(label="merges", color=COLORS['accent']) >> conditional_logic

        # AWS Integration
        environment_params >> Edge(label="dynamic params", color=COLORS['success']) >> expression_evaluator
        database_credentials >> Edge(label="secure data", color=COLORS['warning']) >> security_validator
        kms_encryption >> Edge(label="encrypts", color=COLORS['secondary']) >> database_credentials

        # Final Configuration
        conditional_logic >> Edge(label="dev config", color=COLORS['success']) >> dev_final_config
        expression_evaluator >> Edge(label="staging config", color=COLORS['accent']) >> staging_final_config
        template_processor >> Edge(label="prod config", color=COLORS['primary']) >> prod_final_config

        # Infrastructure Deployment
        dev_final_config >> Edge(label="deploys", color=COLORS['success']) >> dev_infrastructure
        staging_final_config >> Edge(label="deploys", color=COLORS['accent']) >> staging_infrastructure
        prod_final_config >> Edge(label="deploys", color=COLORS['primary']) >> prod_infrastructure

        # Monitoring Integration
        [dev_infrastructure, staging_infrastructure, prod_infrastructure] >> environment_monitoring
        environment_monitoring >> [compliance_reporting, cost_tracking]

def create_aws_parameter_integration():
    """
    Figure 5.4: AWS Parameter Store and Secrets Manager Integration

    This diagram shows comprehensive AWS service integration for dynamic
    parameter management, secure credential handling, and compliance monitoring.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 5.4: AWS Parameter Store and Secrets Manager Integration",
        filename=str(output_dir / "figure_5_4_aws_integration"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Terraform Configuration Layer
        with Cluster("Terraform Configuration Layer"):
            # Variable Sources
            with Cluster("Variable Sources"):
                terraform_variables = Terraform("Terraform Variables")
                data_sources = Storage("Data Sources")
                local_values = Storage("Local Values")

            # Configuration Processing
            with Cluster("Configuration Processing"):
                variable_validation = Storage("Variable Validation")
                expression_evaluation = Storage("Expression Evaluation")
                conditional_processing = Storage("Conditional Processing")

        # AWS Parameter Management Layer
        with Cluster("AWS Parameter Management Layer"):
            # Parameter Store
            with Cluster("Parameter Store"):
                standard_parameters = SystemsManager("Standard Parameters")
                secure_string_parameters = SystemsManager("SecureString Parameters")
                parameter_hierarchies = SystemsManager("Parameter Hierarchies")

            # Secrets Manager
            with Cluster("Secrets Manager"):
                database_secrets = SecretsManager("Database Secrets")
                api_credentials = SecretsManager("API Credentials")
                ssl_certificates = SecretsManager("SSL Certificates")

            # Security Services
            with Cluster("Security Services"):
                kms_keys = KMS("KMS Keys")
                iam_roles = IAM("IAM Roles")
                access_policies = Storage("Access Policies")

        # Infrastructure Layer
        with Cluster("Infrastructure Layer"):
            # Network Infrastructure
            with Cluster("Network Infrastructure"):
                vpc_infrastructure = VPC("VPC")
                subnets = PrivateSubnet("Subnets")
                security_groups = Storage("Security Groups")

            # Compute Infrastructure
            with Cluster("Compute Infrastructure"):
                ec2_instances = EC2("EC2 Instances")
                auto_scaling_groups = AutoScaling("Auto Scaling Groups")
                lambda_functions = Storage("Lambda Functions")

            # Data Infrastructure
            with Cluster("Data Infrastructure"):
                rds_databases = RDS("RDS Databases")
                s3_buckets = S3("S3 Buckets")
                dynamodb_tables = DynamodbTable("DynamoDB Tables")

        # Monitoring and Compliance Layer
        with Cluster("Monitoring and Compliance Layer"):
            # Monitoring Services
            with Cluster("Monitoring Services"):
                cloudwatch_metrics = Cloudwatch("CloudWatch Metrics")
                cloudwatch_logs = Storage("CloudWatch Logs")
                cloudwatch_alarms = Storage("CloudWatch Alarms")

            # Audit and Compliance
            with Cluster("Audit and Compliance"):
                cloudtrail_logs = Cloudtrail("CloudTrail")
                config_compliance = Storage("AWS Config")
                security_hub = Storage("Security Hub")

            # Alerting and Notification
            with Cluster("Alerting and Notification"):
                sns_topics = SNS("SNS Topics")
                email_notifications = Storage("Email Notifications")
                slack_integration = Storage("Slack Integration")

        # Integration Patterns
        with Cluster("Integration Patterns"):
            # Dynamic Configuration
            with Cluster("Dynamic Configuration"):
                environment_switching = Storage("Environment Switching")
                feature_flags = Storage("Feature Flags")
                configuration_updates = Storage("Configuration Updates")

            # Security Patterns
            with Cluster("Security Patterns"):
                credential_rotation = Storage("Credential Rotation")
                encryption_at_rest = Storage("Encryption at Rest")
                encryption_in_transit = Storage("Encryption in Transit")

            # Operational Patterns
            with Cluster("Operational Patterns"):
                automated_deployment = Jenkins("Automated Deployment")
                configuration_drift = Storage("Configuration Drift Detection")
                disaster_recovery = Storage("Disaster Recovery")

        # Data Flow
        # Terraform to AWS Services
        terraform_variables >> Edge(label="queries", color=COLORS['primary']) >> standard_parameters
        data_sources >> Edge(label="retrieves", color=COLORS['success']) >> parameter_hierarchies
        local_values >> Edge(label="processes", color=COLORS['accent']) >> secure_string_parameters

        # Security Integration
        database_secrets >> Edge(label="encrypts", color=COLORS['warning']) >> kms_keys
        api_credentials >> Edge(label="secures", color=COLORS['warning']) >> iam_roles
        kms_keys >> Edge(label="protects", color=COLORS['secondary']) >> secure_string_parameters

        # Infrastructure Deployment
        variable_validation >> Edge(label="configures", color=COLORS['success']) >> vpc_infrastructure
        expression_evaluation >> Edge(label="provisions", color=COLORS['accent']) >> ec2_instances
        conditional_processing >> Edge(label="manages", color=COLORS['primary']) >> rds_databases

        # Parameter Integration
        standard_parameters >> Edge(label="configures", color=COLORS['success']) >> [vpc_infrastructure, subnets]
        secure_string_parameters >> Edge(label="secures", color=COLORS['warning']) >> [ec2_instances, rds_databases]
        database_secrets >> Edge(label="authenticates", color=COLORS['warning']) >> rds_databases

        # Monitoring Integration
        [vpc_infrastructure, ec2_instances, rds_databases, s3_buckets] >> cloudwatch_metrics
        cloudwatch_metrics >> cloudwatch_alarms >> sns_topics
        cloudtrail_logs >> Edge(label="audits", color=COLORS['secondary']) >> config_compliance

        # Operational Integration
        environment_switching >> Edge(label="enables", color=COLORS['accent']) >> automated_deployment
        credential_rotation >> Edge(label="automates", color=COLORS['warning']) >> database_secrets
        configuration_drift >> Edge(label="detects", color=COLORS['primary']) >> cloudwatch_alarms

def create_variable_validation_workflow():
    """
    Figure 5.5: Variable Validation and Processing Workflow

    This diagram shows the complete workflow for variable validation,
    processing, and transformation in enterprise Terraform deployments.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 5.5: Variable Validation and Processing Workflow",
        filename=str(output_dir / "figure_5_5_validation_workflow"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Input Validation Layer
        with Cluster("Input Validation Layer"):
            # Variable Sources
            with Cluster("Variable Sources"):
                terraform_tfvars = Storage("terraform.tfvars")
                environment_tfvars = Storage("environment.tfvars")
                cli_variables = Storage("CLI Variables")
                environment_variables = Storage("Environment Variables")

            # Input Validation
            with Cluster("Input Validation"):
                syntax_validation = Storage("Syntax Validation")
                type_validation = Storage("Type Validation")
                format_validation = Storage("Format Validation")

        # Business Rules Validation
        with Cluster("Business Rules Validation"):
            # Constraint Validation
            with Cluster("Constraint Validation"):
                range_constraints = Storage("Range Constraints")
                pattern_constraints = Storage("Pattern Constraints")
                enum_constraints = Storage("Enum Constraints")

            # Cross-Variable Validation
            with Cluster("Cross-Variable Validation"):
                dependency_validation = Storage("Dependency Validation")
                consistency_checks = Storage("Consistency Checks")
                compatibility_validation = Storage("Compatibility Validation")

            # Environment-Specific Rules
            with Cluster("Environment-Specific Rules"):
                development_rules = Storage("Development Rules")
                staging_rules = Storage("Staging Rules")
                production_rules = Storage("Production Rules")

        # Security Validation Layer
        with Cluster("Security Validation Layer"):
            # Sensitive Data Detection
            with Cluster("Sensitive Data Detection"):
                credential_detection = Storage("Credential Detection")
                secret_scanning = Storage("Secret Scanning")
                pii_detection = Storage("PII Detection")

            # Security Policy Validation
            with Cluster("Security Policy Validation"):
                encryption_requirements = Storage("Encryption Requirements")
                access_control_validation = Storage("Access Control Validation")
                compliance_checks = Storage("Compliance Checks")

            # AWS Security Integration
            with Cluster("AWS Security Integration"):
                secrets_manager_validation = SecretsManager("Secrets Manager")
                kms_validation = KMS("KMS Validation")
                iam_policy_validation = IAM("IAM Policy Validation")

        # Processing and Transformation
        with Cluster("Processing and Transformation"):
            # Local Values Processing
            with Cluster("Local Values Processing"):
                expression_evaluation = Storage("Expression Evaluation")
                function_processing = Storage("Function Processing")
                conditional_logic = Storage("Conditional Logic")

            # Dynamic Configuration
            with Cluster("Dynamic Configuration"):
                environment_resolution = Storage("Environment Resolution")
                template_processing = Storage("Template Processing")
                variable_interpolation = Storage("Variable Interpolation")

            # Output Generation
            with Cluster("Output Generation"):
                resource_configuration = Storage("Resource Configuration")
                module_inputs = Storage("Module Inputs")
                automation_interfaces = Storage("Automation Interfaces")

        # Error Handling and Reporting
        with Cluster("Error Handling and Reporting"):
            # Error Detection
            with Cluster("Error Detection"):
                validation_errors = Storage("Validation Errors")
                type_mismatches = Storage("Type Mismatches")
                constraint_violations = Storage("Constraint Violations")

            # Error Reporting
            with Cluster("Error Reporting"):
                error_messages = Storage("Error Messages")
                validation_reports = Storage("Validation Reports")
                remediation_suggestions = Storage("Remediation Suggestions")

            # Monitoring Integration
            with Cluster("Monitoring Integration"):
                cloudwatch_metrics = Cloudwatch("CloudWatch Metrics")
                alerting_system = SNS("Alerting System")
                audit_logging = Cloudtrail("Audit Logging")

        # Quality Assurance
        with Cluster("Quality Assurance"):
            # Testing Framework
            with Cluster("Testing Framework"):
                unit_tests = Storage("Unit Tests")
                integration_tests = Storage("Integration Tests")
                validation_tests = Storage("Validation Tests")

            # Continuous Validation
            with Cluster("Continuous Validation"):
                ci_cd_integration = Jenkins("CI/CD Integration")
                automated_testing = Storage("Automated Testing")
                quality_gates = Storage("Quality Gates")

        # Validation Flow
        # Input to Validation
        terraform_tfvars >> Edge(label="validates", color=COLORS['primary']) >> syntax_validation
        environment_tfvars >> Edge(label="checks", color=COLORS['success']) >> type_validation
        cli_variables >> Edge(label="formats", color=COLORS['accent']) >> format_validation

        # Business Rules
        syntax_validation >> Edge(label="constraints", color=COLORS['primary']) >> range_constraints
        type_validation >> Edge(label="patterns", color=COLORS['success']) >> pattern_constraints
        format_validation >> Edge(label="dependencies", color=COLORS['accent']) >> dependency_validation

        # Security Validation
        dependency_validation >> Edge(label="scans", color=COLORS['warning']) >> credential_detection
        consistency_checks >> Edge(label="validates", color=COLORS['warning']) >> encryption_requirements
        production_rules >> Edge(label="enforces", color=COLORS['secondary']) >> compliance_checks

        # Processing
        credential_detection >> Edge(label="processes", color=COLORS['success']) >> expression_evaluation
        encryption_requirements >> Edge(label="resolves", color=COLORS['accent']) >> environment_resolution
        compliance_checks >> Edge(label="generates", color=COLORS['primary']) >> resource_configuration

        # Error Handling
        range_constraints >> Edge(label="errors", color="red") >> validation_errors
        pattern_constraints >> Edge(label="mismatches", color="red") >> type_mismatches
        validation_errors >> Edge(label="reports", color=COLORS['warning']) >> error_messages

        # Quality Assurance
        resource_configuration >> Edge(label="tests", color=COLORS['success']) >> unit_tests
        module_inputs >> Edge(label="integrates", color=COLORS['accent']) >> ci_cd_integration
        automation_interfaces >> Edge(label="monitors", color=COLORS['primary']) >> cloudwatch_metrics

        # Monitoring
        error_messages >> cloudwatch_metrics >> alerting_system
        validation_reports >> audit_logging

def generate_diagrams_readme():
    """Generate README for the generated diagrams directory."""
    readme_content = """# Generated Diagrams - Variables and Outputs

## 📊 Professional Architectural Diagrams

This directory contains high-quality architectural diagrams for **Topic 5: Variables and Outputs**.

### 🎯 Diagram Collection

1. **variable_architecture.png** - Enterprise variable architecture with type hierarchies and validation
2. **output_architecture.png** - Output patterns for module integration and automation
3. **environment_configuration.png** - Multi-environment configuration management
4. **aws_integration.png** - AWS service integration for parameter management
5. **lab_5_architecture.png** - Complete lab architecture with variable flow

### 📋 Usage Guidelines

- **Resolution**: 300 DPI (print quality)
- **Format**: PNG with transparency
- **License**: Educational use within AWS Terraform Training
- **Attribution**: AWS Terraform Training - Topic 5

### 🔄 Regeneration

To regenerate these diagrams:
```bash
cd ../
python diagram_generation_script.py
```

---
**Generated**: January 2025  
**Version**: 5.0  
**Topic**: Variables and Outputs
"""
    
    diagrams_readme_path = OUTPUT_DIR / "README.md"
    with open(diagrams_readme_path, 'w') as f:
        f.write(readme_content)
    print(f"📝 Generated diagrams README: {diagrams_readme_path}")

def main():
    """
    Main function to generate all diagrams for Topic 5: Variables and Outputs
    """
    print("🎨 Generating Professional Variables and Outputs Diagrams...")
    print("=" * 80)

    try:
        # Ensure output directory exists
        output_dir = ensure_output_directory()
        print(f"📁 Output directory: {output_dir.absolute()}")

        # Generate all diagrams
        diagrams = [
            ("Figure 5.1: Variable Architecture Patterns", create_variable_architecture_patterns),
            ("Figure 5.2: Output Architecture Patterns", create_output_architecture_patterns),
            ("Figure 5.3: Environment Configuration Management", create_environment_configuration_management),
            ("Figure 5.4: AWS Parameter Integration", create_aws_parameter_integration),
            ("Figure 5.5: Variable Validation Workflow", create_variable_validation_workflow)
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
        print("   • Diagrams are referenced in Concept.md and Lab-5.md")
        print("   • Use these diagrams to enhance learning and understanding")

    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        print("Please check your environment and dependencies.")
        sys.exit(1)

if __name__ == "__main__":
    main()
