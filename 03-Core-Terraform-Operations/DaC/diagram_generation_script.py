#!/usr/bin/env python3
"""
Professional Diagram Generation Script for Topic 3: Core Terraform Operations

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
    from diagrams.aws.database import DynamodbTable
    from diagrams.aws.network import VPC, ELB, InternetGateway, PublicSubnet, PrivateSubnet
    from diagrams.aws.security import IAM
    from diagrams.generic.network import Firewall
    from diagrams.aws.storage import S3
    from diagrams.aws.management import Cloudwatch, Cloudtrail
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
def create_terraform_core_workflow():
    """
    Figure 3.1: Terraform Core Operations Workflow and Lifecycle

    This diagram illustrates the complete Terraform workflow including
    initialization, planning, applying, and destroying infrastructure.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 3.1: Terraform Core Operations Workflow and Lifecycle",
        filename=str(output_dir / "figure_3_1_terraform_core_workflow"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Developer Environment
        with Cluster("Developer Environment"):
            developer = LocalUsers("Developer")
            terraform_config = Storage("Terraform Configuration")
            git_repo = Git("Git Repository")

            developer >> terraform_config >> git_repo

        # Terraform Core Operations
        with Cluster("Terraform Core Operations"):
            # Initialization Phase
            with Cluster("1. Initialization (terraform init)"):
                terraform_init = Terraform("terraform init")
                provider_download = Storage("Provider Download")
                plugin_cache = Storage("Plugin Cache")
                backend_init = Storage("Backend Initialization")
                module_download = Storage("Module Download")

                terraform_init >> [provider_download, plugin_cache, backend_init, module_download]

            # Planning Phase
            with Cluster("2. Planning (terraform plan)"):
                terraform_plan = Terraform("terraform plan")
                state_refresh = Storage("State Refresh")
                dependency_graph = Storage("Dependency Graph")
                change_calculation = Storage("Change Calculation")
                plan_output = Storage("Plan Output")

                terraform_plan >> [state_refresh, dependency_graph, change_calculation, plan_output]

            # Validation Phase
            with Cluster("3. Validation (terraform validate)"):
                terraform_validate = Terraform("terraform validate")
                syntax_check = Storage("Syntax Check")
                configuration_check = Storage("Configuration Check")
                provider_validation = Storage("Provider Validation")

                terraform_validate >> [syntax_check, configuration_check, provider_validation]

            # Application Phase
            with Cluster("4. Application (terraform apply)"):
                terraform_apply = Terraform("terraform apply")
                resource_creation = Storage("Resource Creation")
                resource_modification = Storage("Resource Modification")
                state_update = Storage("State Update")
                output_generation = Storage("Output Generation")

                terraform_apply >> [resource_creation, resource_modification, state_update, output_generation]

        # AWS Infrastructure Layer
        with Cluster("AWS Infrastructure"):
            # Networking
            with Cluster("Networking"):
                vpc = VPC("VPC")
                subnets = PublicSubnet("Subnets")
                igw = InternetGateway("Internet Gateway")

                vpc >> [subnets, igw]

            # Compute
            with Cluster("Compute"):
                ec2_instances = EC2("EC2 Instances")
                auto_scaling = AutoScaling("Auto Scaling")
                load_balancer = ELB("Load Balancer")

                load_balancer >> auto_scaling >> ec2_instances

            # Storage and Database
            with Cluster("Storage & Database"):
                s3_bucket = S3("S3 Bucket")
                dynamodb = DynamodbTable("DynamoDB")

        # State Management
        with Cluster("State Management"):
            local_state = Storage("Local State")
            remote_state = S3("Remote State (S3)")
            state_locking = DynamodbTable("State Locking")
            state_backup = Storage("State Backup")

            local_state >> remote_state >> state_locking
            remote_state >> state_backup

        # Monitoring and Logging
        with Cluster("Monitoring & Logging"):
            cloudwatch = Cloudwatch("CloudWatch")
            cloudtrail = Cloudtrail("CloudTrail")
            terraform_logs = Storage("Terraform Logs")

        # Workflow Connections
        terraform_config >> Edge(label="init", color=COLORS['success']) >> terraform_init
        terraform_init >> Edge(label="plan", color=COLORS['accent']) >> terraform_plan
        terraform_plan >> Edge(label="validate", color=COLORS['primary']) >> terraform_validate
        terraform_validate >> Edge(label="apply", color=COLORS['warning']) >> terraform_apply

        # Infrastructure Connections
        terraform_apply >> Edge(label="creates", color=COLORS['success']) >> vpc
        terraform_apply >> Edge(label="manages", color=COLORS['accent']) >> [ec2_instances, s3_bucket, dynamodb]

        # State Management Connections
        terraform_apply >> Edge(label="updates", color=COLORS['secondary']) >> remote_state

        # Monitoring Connections
        [vpc, ec2_instances, s3_bucket] >> cloudwatch
        terraform_apply >> cloudtrail
        terraform_apply >> terraform_logs
def create_resource_lifecycle_management():
    """
    Figure 3.2: Terraform Resource Lifecycle Management and States

    This diagram shows the complete lifecycle of Terraform resources
    including creation, updates, and destruction with state transitions.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 3.2: Terraform Resource Lifecycle Management and States",
        filename=str(output_dir / "figure_3_2_resource_lifecycle"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Terraform Operations
        with Cluster("Terraform Operations"):
            terraform_plan = Terraform("terraform plan")
            terraform_apply = Terraform("terraform apply")
            terraform_destroy = Terraform("terraform destroy")
            terraform_refresh = Terraform("terraform refresh")
            terraform_taint = Terraform("terraform taint")

        # Resource Lifecycle States
        with Cluster("Resource Lifecycle States"):
            # Planning States
            with Cluster("Planning States"):
                to_create = Storage("To Create (+)")
                to_update = Storage("To Update (~)")
                to_destroy = Storage("To Destroy (-)")
                no_change = Storage("No Change")

            # Execution States
            with Cluster("Execution States"):
                creating = Storage("Creating")
                updating = Storage("Updating")
                destroying = Storage("Destroying")

            # Final States
            with Cluster("Final States"):
                created = Storage("Created")
                updated = Storage("Updated")
                destroyed = Storage("Destroyed")
                tainted = Storage("Tainted")

        # Resource Meta-Arguments
        with Cluster("Resource Meta-Arguments"):
            count_meta = Storage("count")
            for_each_meta = Storage("for_each")
            lifecycle_meta = Storage("lifecycle")
            depends_on_meta = Storage("depends_on")
            provider_meta = Storage("provider")

        # Lifecycle Rules
        with Cluster("Lifecycle Rules"):
            create_before_destroy = Storage("create_before_destroy")
            prevent_destroy = Storage("prevent_destroy")
            ignore_changes = Storage("ignore_changes")
            replace_triggered_by = Storage("replace_triggered_by")

        # AWS Resource Examples
        with Cluster("AWS Resource Examples"):
            # Simple Resources
            with Cluster("Simple Resources"):
                ec2_instance = EC2("EC2 Instance")
                s3_bucket = S3("S3 Bucket")
                iam_role = IAM("IAM Role")

            # Complex Resources
            with Cluster("Complex Resources"):
                vpc_resource = VPC("VPC")
                auto_scaling_group = AutoScaling("Auto Scaling Group")
                load_balancer = ELB("Load Balancer")

        # State Management
        with Cluster("State Management"):
            terraform_state = Storage("terraform.tfstate")
            state_backup = Storage("State Backup")
            state_lock = DynamodbTable("State Lock")

        # Operation Flow
        terraform_plan >> Edge(label="analyzes", color=COLORS['accent']) >> [to_create, to_update, to_destroy, no_change]

        # Apply Operations
        terraform_apply >> Edge(label="create", color=COLORS['success']) >> creating >> created
        terraform_apply >> Edge(label="update", color=COLORS['warning']) >> updating >> updated
        terraform_apply >> Edge(label="destroy", color="red") >> destroying >> destroyed

        # Taint Operations
        terraform_taint >> Edge(label="marks", style="dashed", color="red") >> tainted
        tainted >> Edge(label="forces recreation", color="red") >> destroying

        # Meta-Arguments Influence
        [count_meta, for_each_meta] >> Edge(label="controls instances", color=COLORS['primary']) >> creating
        lifecycle_meta >> Edge(label="controls behavior", color=COLORS['secondary']) >> [create_before_destroy, prevent_destroy, ignore_changes]
        depends_on_meta >> Edge(label="explicit dependency", style="dashed", color=COLORS['accent']) >> creating

        # Resource Examples
        created >> [ec2_instance, s3_bucket, iam_role]
        updated >> [vpc_resource, auto_scaling_group, load_balancer]

        # State Management
        [created, updated, destroyed] >> Edge(label="updates", color=COLORS['secondary']) >> terraform_state
        terraform_state >> state_backup
        terraform_apply >> state_lock

def create_dependency_graph_and_ordering():
    """
    Figure 3.3: Terraform Dependency Graph and Resource Ordering

    This diagram demonstrates how Terraform builds dependency graphs
    and determines resource creation order for complex infrastructures.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 3.3: Terraform Dependency Graph and Resource Ordering",
        filename=str(output_dir / "figure_3_3_dependency_graph"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Dependency Types
        with Cluster("Dependency Types"):
            implicit_dep = Storage("Implicit Dependencies")
            explicit_dep = Storage("Explicit Dependencies (depends_on)")
            data_dep = Storage("Data Source Dependencies")
            provider_dep = Storage("Provider Dependencies")

        # Infrastructure Foundation Layer (Order 1)
        with Cluster("Foundation Layer (Order 1)"):
            vpc = VPC("VPC")
            kms_key = Storage("KMS Key")
            iam_role = IAM("IAM Role")

        # Network Layer (Order 2)
        with Cluster("Network Layer (Order 2)"):
            internet_gateway = InternetGateway("Internet Gateway")
            public_subnet = PublicSubnet("Public Subnet")
            private_subnet = PrivateSubnet("Private Subnet")
            route_table = Storage("Route Table")
            nat_gateway = Storage("NAT Gateway")

        # Security Layer (Order 3)
        with Cluster("Security Layer (Order 3)"):
            security_group_web = Firewall("Web Security Group")
            security_group_app = Firewall("App Security Group")
            security_group_db = Firewall("DB Security Group")

        # Application Layer (Order 4)
        with Cluster("Application Layer (Order 4)"):
            load_balancer = ELB("Application Load Balancer")
            auto_scaling_group = AutoScaling("Auto Scaling Group")
            ec2_instances = EC2("EC2 Instances")

        # Data Layer (Order 5)
        with Cluster("Data Layer (Order 5)"):
            rds_subnet_group = Storage("RDS Subnet Group")
            rds_instance = Storage("RDS Instance")
            s3_bucket = S3("S3 Bucket")

        # Monitoring Layer (Order 6)
        with Cluster("Monitoring Layer (Order 6)"):
            cloudwatch_alarms = Cloudwatch("CloudWatch Alarms")
            cloudtrail = Cloudtrail("CloudTrail")

        # Dependency Graph Visualization
        with Cluster("Dependency Resolution"):
            dependency_analyzer = Storage("Dependency Analyzer")
            parallel_execution = Storage("Parallel Execution")
            sequential_execution = Storage("Sequential Execution")
            error_handling = Storage("Error Handling")

        # Foundation Dependencies (Implicit)
        vpc >> Edge(label="implicit", color=COLORS['success']) >> [internet_gateway, public_subnet, private_subnet]
        vpc >> Edge(label="implicit", color=COLORS['success']) >> [security_group_web, security_group_app, security_group_db]

        # Network Dependencies (Implicit)
        internet_gateway >> Edge(label="implicit", color=COLORS['success']) >> route_table
        public_subnet >> Edge(label="implicit", color=COLORS['success']) >> nat_gateway
        [public_subnet, private_subnet] >> Edge(label="implicit", color=COLORS['success']) >> rds_subnet_group

        # Security Dependencies (Implicit)
        [public_subnet, security_group_web] >> Edge(label="implicit", color=COLORS['success']) >> load_balancer
        [private_subnet, security_group_app] >> Edge(label="implicit", color=COLORS['success']) >> auto_scaling_group
        auto_scaling_group >> Edge(label="implicit", color=COLORS['success']) >> ec2_instances

        # Data Dependencies (Implicit)
        [rds_subnet_group, security_group_db] >> Edge(label="implicit", color=COLORS['success']) >> rds_instance

        # Explicit Dependencies (depends_on)
        load_balancer >> Edge(label="depends_on", style="dashed", color=COLORS['warning']) >> internet_gateway
        rds_instance >> Edge(label="depends_on", style="dashed", color=COLORS['warning']) >> kms_key

        # Data Source Dependencies
        ec2_instances >> Edge(label="data source", style="dotted", color=COLORS['accent']) >> iam_role

        # Monitoring Dependencies
        [ec2_instances, rds_instance, load_balancer] >> Edge(label="implicit", color=COLORS['success']) >> cloudwatch_alarms
        s3_bucket >> Edge(label="implicit", color=COLORS['success']) >> cloudtrail

        # Dependency Resolution Process
        [implicit_dep, explicit_dep, data_dep] >> dependency_analyzer
        dependency_analyzer >> [parallel_execution, sequential_execution]
        sequential_execution >> error_handling

def create_performance_optimization_strategies():
    """
    Figure 3.4: Terraform Performance Optimization Strategies and Techniques

    This diagram shows various techniques for optimizing Terraform performance
    including parallelism, caching, targeting, and state management.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 3.4: Terraform Performance Optimization Strategies",
        filename=str(output_dir / "figure_3_4_performance_optimization"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Performance Challenges
        with Cluster("Performance Challenges"):
            large_infrastructure = Storage("Large Infrastructure")
            slow_providers = Storage("Slow Provider APIs")
            network_latency = Storage("Network Latency")
            state_size = Storage("Large State Files")

        # Optimization Strategies
        with Cluster("Optimization Strategies"):
            # Parallelism Control
            with Cluster("Parallelism Control"):
                parallelism_flag = Storage("-parallelism=N")
                parallelism_env = Storage("TF_CLI_ARGS_apply")
                parallelism_config = Storage("Default: 10 concurrent")

                parallelism_flag >> parallelism_config
                parallelism_env >> parallelism_config

            # Provider Optimization
            with Cluster("Provider Optimization"):
                plugin_cache = Storage("Plugin Cache Directory")
                provider_mirror = Storage("Provider Network Mirror")
                provider_lock = Storage("Provider Lock File")

                plugin_cache >> provider_mirror >> provider_lock

            # Resource Targeting
            with Cluster("Resource Targeting"):
                target_resource = Storage("-target=resource")
                target_module = Storage("-target=module")
                target_data = Storage("-target=data")

            # State Optimization
            with Cluster("State Optimization"):
                refresh_only = Storage("-refresh-only")
                no_refresh = Storage("-refresh=false")
                partial_refresh = Storage("Partial Refresh")
                state_backend_optimization = S3("Optimized Backend")

        # Performance Monitoring
        with Cluster("Performance Monitoring"):
            execution_time = Cloudwatch("Execution Time")
            resource_count = Storage("Resource Count")
            api_calls = Storage("API Call Count")
            memory_usage = Storage("Memory Usage")

        # Optimization Techniques
        with Cluster("Advanced Techniques"):
            # Configuration Optimization
            with Cluster("Configuration Optimization"):
                resource_splitting = Storage("Resource Splitting")
                module_composition = Storage("Module Composition")
                data_source_optimization = Storage("Data Source Optimization")

            # Infrastructure Patterns
            with Cluster("Infrastructure Patterns"):
                layered_approach = Storage("Layered Infrastructure")
                environment_separation = Storage("Environment Separation")
                workspace_strategy = Storage("Workspace Strategy")

        # Performance Metrics
        with Cluster("Performance Metrics"):
            baseline_performance = Grafana("Baseline: 10 min")
            optimized_performance = Grafana("Optimized: 3 min")
            performance_gain = Grafana("70% Improvement")

        # Optimization Flow
        large_infrastructure >> Edge(label="causes", color="red") >> slow_providers
        slow_providers >> Edge(label="optimization", color=COLORS['success']) >> parallelism_config

        # Provider Optimization Flow
        network_latency >> Edge(label="optimization", color=COLORS['success']) >> plugin_cache
        plugin_cache >> Edge(label="reduces", color=COLORS['accent']) >> network_latency

        # Targeting Optimization
        large_infrastructure >> Edge(label="selective updates", color=COLORS['primary']) >> target_resource
        target_resource >> Edge(label="faster execution", color=COLORS['success']) >> optimized_performance

        # State Optimization Flow
        state_size >> Edge(label="optimization", color=COLORS['success']) >> no_refresh
        no_refresh >> Edge(label="faster planning", color=COLORS['accent']) >> optimized_performance

        # Advanced Techniques
        [resource_splitting, module_composition] >> Edge(label="improves", color=COLORS['primary']) >> execution_time
        layered_approach >> Edge(label="reduces complexity", color=COLORS['secondary']) >> resource_count

        # Performance Monitoring
        [execution_time, resource_count, api_calls, memory_usage] >> performance_gain
        baseline_performance >> Edge(label="optimization", color=COLORS['success']) >> optimized_performance

def create_error_recovery_and_troubleshooting():
    """
    Figure 3.5: Terraform Error Recovery and Troubleshooting Patterns

    This diagram shows common Terraform errors and their recovery patterns,
    including state management issues, resource conflicts, and debugging techniques.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 3.5: Terraform Error Recovery and Troubleshooting",
        filename=str(output_dir / "figure_3_5_error_recovery"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Common Error Scenarios
        with Cluster("Common Error Scenarios"):
            # State Errors
            with Cluster("State Management Errors"):
                state_lock_error = Storage("State Lock Error")
                state_corruption = Storage("State Corruption")
                state_drift = Storage("Configuration Drift")

            # Resource Errors
            with Cluster("Resource Management Errors"):
                resource_exists = Storage("Resource Already Exists")
                resource_not_found = Storage("Resource Not Found")
                dependency_error = Storage("Dependency Error")

            # Provider Errors
            with Cluster("Provider and Configuration Errors"):
                provider_version_conflict = Storage("Provider Version Conflict")
                authentication_error = Storage("Authentication Error")
                api_rate_limit = Storage("API Rate Limit")
                syntax_error = Storage("Configuration Syntax Error")

        # Recovery Actions and Commands
        with Cluster("Recovery Actions and Commands"):
            # State Recovery
            with Cluster("State Recovery"):
                force_unlock = Terraform("terraform force-unlock")
                state_pull = Terraform("terraform state pull")
                state_push = Terraform("terraform state push")
                state_backup = Storage("State Backup")

            # Resource Recovery
            with Cluster("Resource Recovery"):
                terraform_import = Terraform("terraform import")
                terraform_taint = Terraform("terraform taint")
                terraform_untaint = Terraform("terraform untaint")
                state_rm = Terraform("terraform state rm")

            # Configuration Recovery
            with Cluster("Configuration Recovery"):
                terraform_init_upgrade = Terraform("terraform init -upgrade")
                terraform_validate = Terraform("terraform validate")
                terraform_fmt = Terraform("terraform fmt")
                provider_reconfigure = Terraform("terraform init -reconfigure")

        # Debugging and Monitoring Tools
        with Cluster("Debugging and Monitoring"):
            # Logging
            with Cluster("Logging and Debugging"):
                debug_logging = Storage("TF_LOG=DEBUG")
                trace_logging = Storage("TF_LOG=TRACE")
                log_path = Storage("TF_LOG_PATH")

            # Validation Tools
            with Cluster("Validation and Testing"):
                plan_detailed = Terraform("terraform plan -detailed-exitcode")
                refresh_only = Terraform("terraform plan -refresh-only")
                dry_run = Storage("Dry Run Testing")

            # Monitoring
            with Cluster("Monitoring and Alerting"):
                cloudwatch_logs = Cloudwatch("CloudWatch Logs")
                error_alerts = Storage("Error Alerts")
                performance_monitoring = Grafana("Performance Monitoring")

        # Prevention Strategies
        with Cluster("Prevention Strategies"):
            # Best Practices
            with Cluster("Best Practices"):
                version_constraints = Storage("Version Constraints")
                state_locking = DynamodbTable("State Locking")
                backup_strategy = S3("Backup Strategy")

            # Automation
            with Cluster("Automation and CI/CD"):
                automated_testing = Jenkins("Automated Testing")
                pre_commit_hooks = Git("Pre-commit Hooks")
                policy_validation = Storage("Policy Validation")

        # Error Recovery Flows
        state_lock_error >> Edge(label="resolve", color=COLORS['success']) >> force_unlock
        state_corruption >> Edge(label="restore", color=COLORS['warning']) >> state_backup
        state_drift >> Edge(label="refresh", color=COLORS['accent']) >> refresh_only

        # Resource Recovery Flows
        resource_exists >> Edge(label="import", color=COLORS['success']) >> terraform_import
        resource_not_found >> Edge(label="remove from state", color=COLORS['warning']) >> state_rm
        dependency_error >> Edge(label="recreate", color="red") >> terraform_taint

        # Provider Recovery Flows
        provider_version_conflict >> Edge(label="upgrade", color=COLORS['primary']) >> terraform_init_upgrade
        authentication_error >> Edge(label="reconfigure", color=COLORS['secondary']) >> provider_reconfigure
        syntax_error >> Edge(label="validate", color=COLORS['accent']) >> terraform_validate

        # Prevention Flows
        version_constraints >> Edge(label="prevents", color=COLORS['success']) >> state_lock_error
        state_locking >> Edge(label="prevents", color=COLORS['success']) >> state_corruption
        backup_strategy >> Edge(label="prevents", color=COLORS['success']) >> state_corruption
        automated_testing >> Edge(label="catches early", color=COLORS['primary']) >> syntax_error
        pre_commit_hooks >> Edge(label="catches early", color=COLORS['primary']) >> dependency_error

        # Monitoring Integration
        debug_logging >> cloudwatch_logs >> error_alerts
        trace_logging >> cloudwatch_logs
        performance_monitoring >> Edge(label="tracks", color=COLORS['accent']) >> api_rate_limit
        performance_monitoring >> Edge(label="tracks", color=COLORS['accent']) >> state_drift

def main():
    """
    Main function to generate all diagrams for Topic 3: Core Terraform Operations
    """
    print("🎨 Generating Professional Core Terraform Operations Diagrams...")
    print("=" * 80)

    try:
        # Ensure output directory exists
        output_dir = ensure_output_directory()
        print(f"📁 Output directory: {output_dir.absolute()}")

        # Generate all diagrams
        diagrams = [
            ("Figure 3.1: Terraform Core Workflow", create_terraform_core_workflow),
            ("Figure 3.2: Resource Lifecycle Management", create_resource_lifecycle_management),
            ("Figure 3.3: Dependency Graph and Ordering", create_dependency_graph_and_ordering),
            ("Figure 3.4: Performance Optimization", create_performance_optimization_strategies),
            ("Figure 3.5: Error Recovery and Troubleshooting", create_error_recovery_and_troubleshooting)
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
        print("   • Diagrams are referenced in Concept.md and Lab-3.md")
        print("   • Use these diagrams to enhance learning and understanding")

    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        print("Please check your environment and dependencies.")
        sys.exit(1)

if __name__ == "__main__":
    main()
