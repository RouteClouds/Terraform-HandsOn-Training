#!/usr/bin/env python3
"""
Professional Diagram Generation Script for Topic 4: Resource Management & Dependencies

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
    from diagrams.aws.database import RDS, RDSInstance, DynamodbTable
    from diagrams.aws.network import VPC, ELB, InternetGateway, NATGateway, RouteTable, PublicSubnet, PrivateSubnet
    from diagrams.aws.security import IAM
    from diagrams.generic.network import Firewall as SecurityGroup
    from diagrams.aws.storage import S3
    from diagrams.aws.management import Cloudwatch as CloudWatch, Cloudtrail as CloudTrail
    from diagrams.aws.general import General, Users
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
def create_resource_dependency_graph():
    """
    Figure 4.1: Terraform Resource Dependency Graph and Ordering

    This diagram demonstrates complex resource dependencies in a multi-tier
    AWS infrastructure with implicit and explicit dependency patterns.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 4.1: Terraform Resource Dependency Graph and Ordering",
        filename=str(output_dir / "figure_4_1_resource_dependency_graph"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Dependency Types Legend
        with Cluster("Dependency Types"):
            implicit_dep = Storage("Implicit Dependencies")
            explicit_dep = Storage("Explicit Dependencies")
            data_source_dep = Storage("Data Source Dependencies")

        # Foundation Layer (Order 1)
        with Cluster("Foundation Layer (Order 1)"):
            vpc = VPC("VPC")
            availability_zones = Storage("Availability Zones (data)")

        # Network Infrastructure Layer (Order 2)
        with Cluster("Network Infrastructure (Order 2)"):
            internet_gateway = InternetGateway("Internet Gateway")
            public_subnets = PublicSubnet("Public Subnets (count=2)")
            private_subnets = PrivateSubnet("Private Subnets (count=2)")
            database_subnets = PrivateSubnet("Database Subnets (count=2)")

        # Routing Layer (Order 3)
        with Cluster("Routing Layer (Order 3)"):
            public_route_table = RouteTable("Public Route Table")
            private_route_tables = RouteTable("Private Route Tables (count=2)")
            nat_gateways = NATGateway("NAT Gateways (count=2)")

        # Security Layer (Order 4)
        with Cluster("Security Layer (Order 4)"):
            alb_security_group = SecurityGroup("ALB Security Group")
            web_security_group = SecurityGroup("Web Security Group")
            app_security_group = SecurityGroup("App Security Group")
            database_security_group = SecurityGroup("Database Security Group")

        # Database Layer (Order 5)
        with Cluster("Database Layer (Order 5)"):
            db_subnet_group = Storage("DB Subnet Group")
            rds_instance = RDS("RDS Database")

        # Application Layer (Order 6)
        with Cluster("Application Layer (Order 6)"):
            launch_templates = Storage("Launch Templates (for_each)")
            auto_scaling_groups = AutoScaling("Auto Scaling Groups (for_each)")
            application_load_balancer = ELB("Application Load Balancer")

        # Monitoring Layer (Order 7)
        with Cluster("Monitoring Layer (Order 7)"):
            cloudwatch_alarms = CloudWatch("CloudWatch Alarms")
            log_groups = Storage("CloudWatch Log Groups")

        # Implicit Dependencies (Resource Attribute References)
        vpc >> Edge(label="implicit", color=COLORS['success']) >> internet_gateway
        vpc >> Edge(label="implicit", color=COLORS['success']) >> public_subnets
        vpc >> Edge(label="implicit", color=COLORS['success']) >> private_subnets
        vpc >> Edge(label="implicit", color=COLORS['success']) >> database_subnets
        vpc >> Edge(label="implicit", color=COLORS['success']) >> alb_security_group
        vpc >> Edge(label="implicit", color=COLORS['success']) >> web_security_group
        vpc >> Edge(label="implicit", color=COLORS['success']) >> app_security_group
        vpc >> Edge(label="implicit", color=COLORS['success']) >> database_security_group

        # Network Dependencies
        internet_gateway >> Edge(label="implicit", color=COLORS['success']) >> public_route_table
        public_subnets >> Edge(label="implicit", color=COLORS['success']) >> nat_gateways
        private_subnets >> Edge(label="implicit", color=COLORS['success']) >> private_route_tables

        # Database Dependencies
        database_subnets >> Edge(label="implicit", color=COLORS['success']) >> db_subnet_group
        db_subnet_group >> Edge(label="implicit", color=COLORS['success']) >> rds_instance
        database_security_group >> Edge(label="implicit", color=COLORS['success']) >> rds_instance

        # Application Dependencies
        private_subnets >> Edge(label="implicit", color=COLORS['success']) >> launch_templates
        web_security_group >> Edge(label="implicit", color=COLORS['success']) >> launch_templates
        app_security_group >> Edge(label="implicit", color=COLORS['success']) >> launch_templates
        launch_templates >> Edge(label="implicit", color=COLORS['success']) >> auto_scaling_groups
        public_subnets >> Edge(label="implicit", color=COLORS['success']) >> application_load_balancer
        alb_security_group >> Edge(label="implicit", color=COLORS['success']) >> application_load_balancer

        # Explicit Dependencies (depends_on)
        application_load_balancer >> Edge(label="depends_on", style="dashed", color=COLORS['warning']) >> internet_gateway
        auto_scaling_groups >> Edge(label="depends_on", style="dashed", color=COLORS['warning']) >> rds_instance

        # Data Source Dependencies
        availability_zones >> Edge(label="data source", style="dotted", color=COLORS['accent']) >> public_subnets
        availability_zones >> Edge(label="data source", style="dotted", color=COLORS['accent']) >> private_subnets
        availability_zones >> Edge(label="data source", style="dotted", color=COLORS['accent']) >> database_subnets

        # Monitoring Dependencies
        rds_instance >> Edge(label="implicit", color=COLORS['success']) >> cloudwatch_alarms
        auto_scaling_groups >> Edge(label="implicit", color=COLORS['success']) >> cloudwatch_alarms
        application_load_balancer >> Edge(label="implicit", color=COLORS['success']) >> cloudwatch_alarms
        auto_scaling_groups >> Edge(label="implicit", color=COLORS['success']) >> log_groups
def create_meta_arguments_comparison():
    """
    Figure 4.2: Terraform Meta-Arguments Comparison and Usage Patterns

    This diagram compares the four main Terraform meta-arguments:
    count, for_each, lifecycle, and depends_on with practical examples.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 4.2: Terraform Meta-Arguments Comparison and Usage",
        filename=str(output_dir / "figure_4_2_meta_arguments_comparison"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Meta-Arguments Overview
        with Cluster("Terraform Meta-Arguments"):
            meta_args_intro = Storage("Meta-Arguments Control Resource Behavior")

        # Count Meta-Argument
        with Cluster("count Meta-Argument"):
            # Configuration
            with Cluster("Configuration"):
                count_syntax = Storage("count = var.instance_count")
                count_conditional = Storage("count = var.enable_feature ? 1 : 0")

            # Resource Instances
            with Cluster("Resource Instances"):
                count_instance_0 = EC2("aws_instance.web[0]")
                count_instance_1 = EC2("aws_instance.web[1]")
                count_instance_2 = EC2("aws_instance.web[2]")

            # References
            with Cluster("References"):
                count_reference_all = Storage("aws_instance.web[*].id")
                count_reference_specific = Storage("aws_instance.web[0].id")

            # Use Cases
            with Cluster("Best Use Cases"):
                count_use_case_1 = Storage("Simple Scaling")
                count_use_case_2 = Storage("Conditional Resources")
                count_use_case_3 = Storage("Numeric Iteration")

        # For_Each Meta-Argument
        with Cluster("for_each Meta-Argument"):
            # Configuration
            with Cluster("Configuration"):
                foreach_map = Storage("for_each = var.environments")
                foreach_set = Storage("for_each = toset([\"web\", \"app\"])")

            # Resource Instances
            with Cluster("Resource Instances"):
                foreach_instance_web = EC2("aws_instance.app[\"web\"]")
                foreach_instance_app = EC2("aws_instance.app[\"app\"]")

            # References
            with Cluster("References"):
                foreach_reference_key = Storage("each.key")
                foreach_reference_value = Storage("each.value")
                foreach_reference_specific = Storage("aws_instance.app[\"web\"].id")

            # Use Cases
            with Cluster("Best Use Cases"):
                foreach_use_case_1 = Storage("Stable Resource Addresses")
                foreach_use_case_2 = Storage("Map-based Configuration")
                foreach_use_case_3 = Storage("Complex Resource Variations")

        # Lifecycle Meta-Argument
        with Cluster("lifecycle Meta-Argument"):
            # Configuration Options
            with Cluster("Configuration Options"):
                lifecycle_create_before_destroy = Storage("create_before_destroy = true")
                lifecycle_prevent_destroy = Storage("prevent_destroy = true")
                lifecycle_ignore_changes = Storage("ignore_changes = [\"tags\"]")
                lifecycle_replace_triggered_by = Storage("replace_triggered_by = [aws_instance.web]")

            # Behaviors
            with Cluster("Behaviors"):
                behavior_zero_downtime = Storage("Zero Downtime Updates")
                behavior_protection = Storage("Accidental Deletion Protection")
                behavior_drift_ignore = Storage("Configuration Drift Tolerance")
                behavior_coordinated_updates = Storage("Coordinated Resource Updates")

            # Use Cases
            with Cluster("Best Use Cases"):
                lifecycle_use_case_1 = Storage("Production Databases")
                lifecycle_use_case_2 = Storage("Load Balancers")
                lifecycle_use_case_3 = Storage("Auto Scaling Groups")

        # Depends_On Meta-Argument
        with Cluster("depends_on Meta-Argument"):
            # Configuration
            with Cluster("Configuration"):
                depends_on_syntax = Storage("depends_on = [aws_instance.database]")
                depends_on_multiple = Storage("depends_on = [resource1, resource2]")

            # Dependency Types
            with Cluster("Dependency Scenarios"):
                hidden_dependency = Storage("Hidden Dependencies")
                timing_dependency = Storage("Timing Dependencies")
                cross_module_dependency = Storage("Cross-Module Dependencies")

            # Use Cases
            with Cluster("Best Use Cases"):
                depends_use_case_1 = Storage("Service Initialization Order")
                depends_use_case_2 = Storage("External System Dependencies")
                depends_use_case_3 = Storage("Complex Orchestration")

        # Comparison Matrix
        with Cluster("Selection Guidelines"):
            selection_guide = Storage("Meta-Argument Selection Guide")
            count_vs_foreach = Storage("count: Simple scaling | for_each: Stable addresses")
            lifecycle_when = Storage("lifecycle: Production resources")
            depends_when = Storage("depends_on: Hidden dependencies")

        # Meta-Arguments Flow
        meta_args_intro >> [count_syntax, foreach_map, lifecycle_create_before_destroy, depends_on_syntax]

        # Count Flow
        count_syntax >> [count_instance_0, count_instance_1, count_instance_2]
        [count_instance_0, count_instance_1, count_instance_2] >> count_reference_all

        # For_Each Flow
        foreach_map >> [foreach_instance_web, foreach_instance_app]
        [foreach_instance_web, foreach_instance_app] >> foreach_reference_specific

        # Lifecycle Flow
        lifecycle_create_before_destroy >> behavior_zero_downtime
        lifecycle_prevent_destroy >> behavior_protection
        lifecycle_ignore_changes >> behavior_drift_ignore

        # Depends_On Flow
        depends_on_syntax >> hidden_dependency >> timing_dependency

        # Selection Guidelines
        selection_guide >> [count_vs_foreach, lifecycle_when, depends_when]
def create_lifecycle_management_patterns():
    """
    Figure 4.3: Terraform Lifecycle Management Patterns and Strategies

    This diagram shows the four lifecycle meta-arguments and their
    practical applications in enterprise infrastructure management.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 4.3: Terraform Lifecycle Management Patterns",
        filename=str(output_dir / "figure_4_3_lifecycle_management"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Lifecycle Management Overview
        with Cluster("Lifecycle Management Overview"):
            lifecycle_intro = Storage("Lifecycle Meta-Arguments Control Resource Behavior")

        # Create Before Destroy Pattern
        with Cluster("create_before_destroy Pattern"):
            # Scenario
            with Cluster("Zero Downtime Deployment Scenario"):
                old_load_balancer = ELB("Current Load Balancer")
                new_load_balancer = ELB("New Load Balancer")
                traffic_switch = Storage("Traffic Switch")
                old_destroyed = Storage("Old Resource Destroyed")

            # Configuration
            with Cluster("Configuration"):
                create_before_destroy_config = Storage("""
lifecycle {
  create_before_destroy = true
}""")

            # Use Cases
            with Cluster("Best Use Cases"):
                use_case_alb = Storage("Application Load Balancers")
                use_case_asg = Storage("Auto Scaling Groups")
                use_case_launch_template = Storage("Launch Templates")

            # Flow
            old_load_balancer >> Edge(label="1. Create new", color=COLORS['success']) >> new_load_balancer
            new_load_balancer >> Edge(label="2. Switch traffic", color=COLORS['accent']) >> traffic_switch
            traffic_switch >> Edge(label="3. Destroy old", color=COLORS['warning']) >> old_destroyed

        # Prevent Destroy Pattern
        with Cluster("prevent_destroy Pattern"):
            # Scenario
            with Cluster("Production Database Protection"):
                production_database = RDS("Production Database")
                destroy_command = Storage("terraform destroy")
                protection_error = Storage("Error: Resource Protected")

            # Configuration
            with Cluster("Configuration"):
                prevent_destroy_config = Storage("""
lifecycle {
  prevent_destroy = true
}""")

            # Use Cases
            with Cluster("Best Use Cases"):
                use_case_database = Storage("Production Databases")
                use_case_s3 = Storage("Critical S3 Buckets")
                use_case_state = Storage("State Storage Resources")

            # Flow
            destroy_command >> Edge(label="blocked", color="red") >> production_database
            destroy_command >> Edge(label="returns error", color="red") >> protection_error

        # Ignore Changes Pattern
        with Cluster("ignore_changes Pattern"):
            # Scenario
            with Cluster("External Management Scenario"):
                managed_instance = EC2("EC2 Instance")
                external_system = Storage("External Management System")
                terraform_plan = Terraform("terraform plan")
                no_drift_detected = Storage("No Drift Detected")

            # Configuration
            with Cluster("Configuration"):
                ignore_changes_config = Storage("""
lifecycle {
  ignore_changes = [
    "tags",
    "user_data"
  ]
}""")

            # Use Cases
            with Cluster("Best Use Cases"):
                use_case_tags = Storage("AWS-Managed Tags")
                use_case_scaling = Storage("Auto Scaling Policies")
                use_case_monitoring = Storage("Monitoring Configurations")

            # Flow
            external_system >> Edge(label="modifies", color=COLORS['warning']) >> managed_instance
            terraform_plan >> Edge(label="ignores changes", color=COLORS['success']) >> managed_instance
            terraform_plan >> Edge(label="reports", color=COLORS['accent']) >> no_drift_detected

        # Replace Triggered By Pattern
        with Cluster("replace_triggered_by Pattern"):
            # Scenario
            with Cluster("Coordinated Update Scenario"):
                trigger_resource = Storage("Launch Template")
                dependent_asg = AutoScaling("Auto Scaling Group")
                replacement_triggered = Storage("Replacement Triggered")
                new_instances = EC2("New Instances")

            # Configuration
            with Cluster("Configuration"):
                replace_triggered_config = Storage("""
lifecycle {
  replace_triggered_by = [
    aws_launch_template.web
  ]
}""")

            # Use Cases
            with Cluster("Best Use Cases"):
                use_case_coordinated = Storage("Coordinated Updates")
                use_case_cascading = Storage("Cascading Replacements")
                use_case_version_sync = Storage("Version Synchronization")

            # Flow
            trigger_resource >> Edge(label="change detected", color=COLORS['warning']) >> dependent_asg
            dependent_asg >> Edge(label="triggers replacement", color=COLORS['primary']) >> replacement_triggered
            replacement_triggered >> Edge(label="creates", color=COLORS['success']) >> new_instances

        # Best Practices
        with Cluster("Lifecycle Management Best Practices"):
            best_practice_1 = Storage("Use create_before_destroy for zero downtime")
            best_practice_2 = Storage("Apply prevent_destroy to critical resources")
            best_practice_3 = Storage("Use ignore_changes for external management")
            best_practice_4 = Storage("Coordinate updates with replace_triggered_by")

        # Integration
        lifecycle_intro >> [create_before_destroy_config, prevent_destroy_config, ignore_changes_config, replace_triggered_config]
        use_case_alb >> best_practice_1
        use_case_database >> best_practice_2
        use_case_tags >> best_practice_3
        use_case_coordinated >> best_practice_4

def create_complex_dependency_resolution():
    """
    Figure 4.4: Complex Dependency Resolution and Circular Dependency Patterns

    This diagram demonstrates advanced dependency resolution techniques
    including circular dependency resolution and complex multi-tier scenarios.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 4.4: Complex Dependency Resolution Patterns",
        filename=str(output_dir / "figure_4_4_complex_dependencies"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Complex Multi-Tier Dependencies
        with Cluster("Complex Multi-Tier Infrastructure"):
            # Foundation Layer
            with Cluster("Foundation Layer (Order 1)"):
                vpc = VPC("VPC")
                availability_zones = Storage("Availability Zones (data)")

            # Network Layer
            with Cluster("Network Layer (Order 2)"):
                public_subnets = PublicSubnet("Public Subnets (count=3)")
                private_subnets = PrivateSubnet("Private Subnets (count=3)")
                database_subnets = PrivateSubnet("Database Subnets (count=3)")
                internet_gateway = InternetGateway("Internet Gateway")

            # Security Layer
            with Cluster("Security Layer (Order 3)"):
                web_sg = SecurityGroup("Web Security Group")
                app_sg = SecurityGroup("App Security Group")
                db_sg = SecurityGroup("Database Security Group")
                alb_sg = SecurityGroup("ALB Security Group")

            # Database Layer
            with Cluster("Database Layer (Order 4)"):
                db_subnet_group = Storage("DB Subnet Group")
                rds_instance = RDS("RDS Instance")

            # Application Layer
            with Cluster("Application Layer (Order 5)"):
                launch_template = Storage("Launch Template")
                auto_scaling_group = AutoScaling("Auto Scaling Group")
                target_group = Storage("Target Group")

            # Load Balancer Layer
            with Cluster("Load Balancer Layer (Order 6)"):
                application_load_balancer = ELB("Application Load Balancer")
                alb_listener = Storage("ALB Listener")

        # Circular Dependency Scenarios
        with Cluster("Circular Dependency Resolution"):
            # Problem Scenario
            with Cluster("Problem: Circular Dependencies"):
                security_group_a = SecurityGroup("Security Group A")
                security_group_b = SecurityGroup("Security Group B")
                circular_error = Storage("Circular Dependency Error")

            # Resolution Techniques
            with Cluster("Resolution Techniques"):
                # Data Source Resolution
                with Cluster("Data Source Resolution"):
                    existing_sg_data = Storage("data.aws_security_group")
                    new_sg_resource = SecurityGroup("New Security Group")

                # Separate Resource Resolution
                with Cluster("Separate Resource Resolution"):
                    base_sg = SecurityGroup("Base Security Group")
                    sg_rule_1 = Storage("Security Group Rule 1")
                    sg_rule_2 = Storage("Security Group Rule 2")

                # Module-Based Resolution
                with Cluster("Module-Based Resolution"):
                    network_module = Storage("Network Module")
                    security_module = Storage("Security Module")
                    app_module = Storage("Application Module")

        # Advanced Dependency Patterns
        with Cluster("Advanced Dependency Patterns"):
            # Cross-Region Dependencies
            with Cluster("Cross-Region Dependencies"):
                primary_region = Storage("Primary Region (us-east-1)")
                secondary_region = Storage("Secondary Region (us-west-2)")
                cross_region_data = Storage("Cross-Region Data Sources")

            # Cross-Account Dependencies
            with Cluster("Cross-Account Dependencies"):
                account_a = Storage("Account A (Shared Services)")
                account_b = Storage("Account B (Application)")
                cross_account_role = IAM("Cross-Account Role")

            # Module Dependencies
            with Cluster("Module Dependencies"):
                vpc_module = Storage("VPC Module")
                security_module_dep = Storage("Security Module")
                application_module_dep = Storage("Application Module")

        # Dependency Resolution Strategies
        with Cluster("Resolution Strategies"):
            strategy_1 = Storage("Use Data Sources for Existing Resources")
            strategy_2 = Storage("Split Resources into Separate Configurations")
            strategy_3 = Storage("Use Module Composition")
            strategy_4 = Storage("Implement Staged Deployments")

        # Complex Dependencies Flow
        vpc >> Edge(label="implicit", color=COLORS['success']) >> public_subnets
        vpc >> Edge(label="implicit", color=COLORS['success']) >> private_subnets
        vpc >> Edge(label="implicit", color=COLORS['success']) >> database_subnets
        vpc >> Edge(label="implicit", color=COLORS['success']) >> web_sg
        vpc >> Edge(label="implicit", color=COLORS['success']) >> app_sg
        vpc >> Edge(label="implicit", color=COLORS['success']) >> db_sg
        vpc >> Edge(label="implicit", color=COLORS['success']) >> alb_sg

        # Database Dependencies
        database_subnets >> Edge(label="implicit", color=COLORS['success']) >> db_subnet_group
        db_subnet_group >> Edge(label="implicit", color=COLORS['success']) >> rds_instance
        db_sg >> Edge(label="implicit", color=COLORS['success']) >> rds_instance

        # Application Dependencies
        private_subnets >> Edge(label="implicit", color=COLORS['success']) >> launch_template
        app_sg >> Edge(label="implicit", color=COLORS['success']) >> launch_template
        launch_template >> Edge(label="implicit", color=COLORS['success']) >> auto_scaling_group
        auto_scaling_group >> Edge(label="implicit", color=COLORS['success']) >> target_group

        # Load Balancer Dependencies
        public_subnets >> Edge(label="implicit", color=COLORS['success']) >> application_load_balancer
        alb_sg >> Edge(label="implicit", color=COLORS['success']) >> application_load_balancer
        application_load_balancer >> Edge(label="implicit", color=COLORS['success']) >> alb_listener
        target_group >> Edge(label="implicit", color=COLORS['success']) >> alb_listener

        # Explicit Dependencies
        application_load_balancer >> Edge(label="depends_on", style="dashed", color=COLORS['warning']) >> internet_gateway
        auto_scaling_group >> Edge(label="depends_on", style="dashed", color=COLORS['warning']) >> rds_instance

        # Circular Dependency Resolution
        security_group_a >> Edge(label="circular", color="red") >> security_group_b
        security_group_b >> Edge(label="circular", color="red") >> security_group_a
        [security_group_a, security_group_b] >> circular_error

        # Resolution Flows
        existing_sg_data >> Edge(label="resolves", color=COLORS['success']) >> new_sg_resource
        base_sg >> [sg_rule_1, sg_rule_2]
        network_module >> security_module >> app_module

        # Cross-Dependencies
        primary_region >> Edge(label="data source", style="dotted", color=COLORS['accent']) >> cross_region_data
        account_a >> Edge(label="assume role", style="dashed", color=COLORS['primary']) >> cross_account_role

        # Strategy Application
        circular_error >> [strategy_1, strategy_2, strategy_3, strategy_4]
def create_resource_management_workflow():
    """
    Figure 4.5: Enterprise Resource Management Workflow and Best Practices

    This diagram shows the complete workflow for managing complex resource
    dependencies in enterprise Terraform deployments.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 4.5: Enterprise Resource Management Workflow",
        filename=str(output_dir / "figure_4_5_resource_management_workflow"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Planning and Design Phase
        with Cluster("Planning and Design Phase"):
            # Requirements Analysis
            with Cluster("Requirements Analysis"):
                business_requirements = Storage("Business Requirements")
                technical_requirements = Storage("Technical Requirements")
                compliance_requirements = Storage("Compliance Requirements")

            # Architecture Design
            with Cluster("Architecture Design"):
                dependency_mapping = Storage("Dependency Mapping")
                resource_organization = Storage("Resource Organization")
                lifecycle_planning = Storage("Lifecycle Planning")

            # Meta-Arguments Selection
            with Cluster("Meta-Arguments Selection"):
                count_vs_foreach = Storage("count vs for_each Analysis")
                lifecycle_rules = Storage("Lifecycle Rules Design")
                dependency_strategy = Storage("Dependency Strategy")

        # Implementation Phase
        with Cluster("Implementation Phase"):
            # Configuration Development
            with Cluster("Configuration Development"):
                resource_configuration = Terraform("Resource Configuration")
                meta_arguments_implementation = Storage("Meta-Arguments Implementation")
                dependency_implementation = Storage("Dependency Implementation")

            # Code Organization
            with Cluster("Code Organization"):
                module_structure = Storage("Module Structure")
                variable_design = Storage("Variable Design")
                output_planning = Storage("Output Planning")

        # Validation and Testing Phase
        with Cluster("Validation and Testing Phase"):
            # Static Analysis
            with Cluster("Static Analysis"):
                terraform_validate = Terraform("terraform validate")
                terraform_fmt = Terraform("terraform fmt")
                dependency_graph_analysis = Storage("Dependency Graph Analysis")

            # Dynamic Testing
            with Cluster("Dynamic Testing"):
                plan_validation = Terraform("terraform plan")
                lifecycle_testing = Storage("Lifecycle Testing")
                dependency_testing = Storage("Dependency Testing")

            # Integration Testing
            with Cluster("Integration Testing"):
                multi_environment_testing = Storage("Multi-Environment Testing")
                cross_module_testing = Storage("Cross-Module Testing")
                performance_testing = Storage("Performance Testing")

        # Deployment Phase
        with Cluster("Deployment Phase"):
            # Staged Deployment
            with Cluster("Staged Deployment"):
                development_deployment = Storage("Development Deployment")
                staging_deployment = Storage("Staging Deployment")
                production_deployment = Storage("Production Deployment")

            # Monitoring and Validation
            with Cluster("Monitoring and Validation"):
                deployment_monitoring = CloudWatch("Deployment Monitoring")
                resource_validation = Storage("Resource Validation")
                dependency_verification = Storage("Dependency Verification")

        # Maintenance and Optimization Phase
        with Cluster("Maintenance and Optimization Phase"):
            # Ongoing Management
            with Cluster("Ongoing Management"):
                drift_detection = Storage("Configuration Drift Detection")
                dependency_updates = Storage("Dependency Updates")
                lifecycle_maintenance = Storage("Lifecycle Maintenance")

            # Optimization
            with Cluster("Optimization"):
                performance_optimization = Storage("Performance Optimization")
                cost_optimization = Storage("Cost Optimization")
                security_optimization = Storage("Security Optimization")

            # Documentation and Knowledge
            with Cluster("Documentation and Knowledge"):
                pattern_documentation = Storage("Pattern Documentation")
                best_practices = Storage("Best Practices")
                lessons_learned = Storage("Lessons Learned")

        # Workflow Flow
        business_requirements >> Edge(label="informs", color=COLORS['primary']) >> dependency_mapping
        technical_requirements >> Edge(label="guides", color=COLORS['accent']) >> resource_organization
        compliance_requirements >> Edge(label="constrains", color=COLORS['warning']) >> lifecycle_planning

        # Design to Implementation
        dependency_mapping >> Edge(label="guides", color=COLORS['success']) >> dependency_implementation
        resource_organization >> Edge(label="structures", color=COLORS['accent']) >> module_structure
        lifecycle_planning >> Edge(label="defines", color=COLORS['primary']) >> meta_arguments_implementation

        # Implementation to Validation
        resource_configuration >> Edge(label="validates", color=COLORS['success']) >> terraform_validate
        meta_arguments_implementation >> Edge(label="tests", color=COLORS['accent']) >> lifecycle_testing
        dependency_implementation >> Edge(label="analyzes", color=COLORS['primary']) >> dependency_graph_analysis

        # Validation to Deployment
        plan_validation >> Edge(label="approves", color=COLORS['success']) >> development_deployment
        lifecycle_testing >> Edge(label="validates", color=COLORS['accent']) >> staging_deployment
        dependency_testing >> Edge(label="confirms", color=COLORS['primary']) >> production_deployment

        # Deployment to Maintenance
        production_deployment >> Edge(label="monitors", color=COLORS['success']) >> deployment_monitoring
        resource_validation >> Edge(label="detects", color=COLORS['warning']) >> drift_detection
        dependency_verification >> Edge(label="maintains", color=COLORS['accent']) >> dependency_updates

        # Feedback Loops
        lessons_learned >> Edge(label="improves", style="dashed", color=COLORS['secondary']) >> business_requirements
        performance_optimization >> Edge(label="refines", style="dashed", color=COLORS['accent']) >> dependency_strategy
        drift_detection >> Edge(label="triggers", style="dashed", color=COLORS['warning']) >> lifecycle_maintenance

def main():
    """
    Main function to generate all diagrams for Topic 4: Resource Management & Dependencies
    """
    print("🎨 Generating Professional Resource Management & Dependencies Diagrams...")
    print("=" * 80)

    try:
        # Ensure output directory exists
        output_dir = ensure_output_directory()
        print(f"📁 Output directory: {output_dir.absolute()}")

        # Generate all diagrams
        diagrams = [
            ("Figure 4.1: Resource Dependency Graph", create_resource_dependency_graph),
            ("Figure 4.2: Meta-Arguments Comparison", create_meta_arguments_comparison),
            ("Figure 4.3: Lifecycle Management Patterns", create_lifecycle_management_patterns),
            ("Figure 4.4: Complex Dependency Resolution", create_complex_dependency_resolution),
            ("Figure 4.5: Resource Management Workflow", create_resource_management_workflow)
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
        print("   • Diagrams are referenced in Concept.md and Lab-4.md")
        print("   • Use these diagrams to enhance learning and understanding")

    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        print("Please check your environment and dependencies.")
        sys.exit(1)

if __name__ == "__main__":
    main()
