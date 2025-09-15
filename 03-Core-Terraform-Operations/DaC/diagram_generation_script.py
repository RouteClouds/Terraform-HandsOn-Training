#!/usr/bin/env python3
"""
AWS Terraform Training - Core Terraform Operations
Diagram as Code (DaC) Generation Script

This script generates 5 professional diagrams for the Core Terraform Operations module:
1. Terraform Core Workflow
2. Resource Lifecycle States
3. Dependency Graph Example
4. Performance Optimization
5. Error Recovery Patterns

Requirements:
- Python 3.9+
- diagrams library
- Graphviz
"""

import os
import sys
from pathlib import Path

# Add current directory to path for imports
sys.path.append(str(Path(__file__).parent))

try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.aws.compute import EC2
    from diagrams.aws.database import DynamodbTable
    from diagrams.aws.network import VPC, ELB, InternetGateway
    from diagrams.aws.security import IAM
    from diagrams.aws.storage import S3
    from diagrams.aws.management import Cloudwatch
    from diagrams.aws.general import General, Users
    from diagrams.onprem.vcs import Git
    from diagrams.onprem.ci import Jenkins
    from diagrams.onprem.client import Users as LocalUsers
    from diagrams.programming.language import Python
    from diagrams.generic.blank import Blank
    from diagrams.generic.compute import Rack
    from diagrams.generic.network import Switch
    from diagrams.generic.storage import Storage
    from diagrams.generic.os import Ubuntu, Windows, IOS
except ImportError as e:
    print(f"Error importing required libraries: {e}")
    print("Please install required packages: pip install diagrams")
    sys.exit(1)

# Configuration
OUTPUT_DIR = Path(__file__).parent / "generated_diagrams"
DPI = 300  # High resolution for professional quality

def setup_output_directory():
    """Create output directory if it doesn't exist."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Output directory: {OUTPUT_DIR}")

def generate_core_workflow():
    """Generate Figure 3.1: Terraform Core Workflow."""
    print("Generating Figure 3.1: Terraform Core Workflow...")
    
    with Diagram(
        "Figure 3.1: Terraform Core Workflow",
        filename=str(OUTPUT_DIR / "core_workflow"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Developer
        developer = LocalUsers("Developer")
        
        # Terraform Operations
        with Cluster("Terraform Core Operations"):
            # Init Phase
            with Cluster("1. Initialize"):
                init_cmd = General("terraform init")
                provider_download = General("Download\nProviders")
                backend_setup = General("Setup\nBackend")
                
            # Plan Phase
            with Cluster("2. Plan"):
                plan_cmd = General("terraform plan")
                state_refresh = General("Refresh\nState")
                generate_plan = General("Generate\nPlan")
                
            # Apply Phase
            with Cluster("3. Apply"):
                apply_cmd = General("terraform apply")
                create_resources = General("Create\nResources")
                update_state = General("Update\nState")
                
            # Destroy Phase
            with Cluster("4. Destroy"):
                destroy_cmd = General("terraform destroy")
                delete_resources = General("Delete\nResources")
                clean_state = General("Clean\nState")
        
        # Infrastructure
        with Cluster("AWS Infrastructure"):
            vpc = VPC("VPC")
            ec2 = EC2("EC2")
            s3 = S3("S3")
            
        # State Storage
        state_backend = S3("State Backend")
        
        # Workflow connections
        developer >> init_cmd >> [provider_download, backend_setup]
        developer >> plan_cmd >> [state_refresh, generate_plan]
        developer >> apply_cmd >> [create_resources, update_state]
        developer >> destroy_cmd >> [delete_resources, clean_state]
        
        # Infrastructure connections
        [create_resources, delete_resources] >> [vpc, ec2, s3]
        [update_state, clean_state] >> state_backend

def generate_resource_lifecycle():
    """Generate Figure 3.2: Resource Lifecycle States."""
    print("Generating Figure 3.2: Resource Lifecycle States...")
    
    with Diagram(
        "Figure 3.2: Resource Lifecycle States",
        filename=str(OUTPUT_DIR / "resource_lifecycle"),
        show=False,
        direction="LR",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Lifecycle States
        with Cluster("Resource Lifecycle"):
            # Creation
            with Cluster("Creation Phase"):
                planned = General("Planned")
                creating = General("Creating")
                created = General("Created")
                
            # Update
            with Cluster("Update Phase"):
                updating = General("Updating")
                updated = General("Updated")
                
            # Destruction
            with Cluster("Destruction Phase"):
                destroying = General("Destroying")
                destroyed = General("Destroyed")
        
        # Terraform Operations
        with Cluster("Terraform Operations"):
            plan_op = General("terraform plan")
            apply_op = General("terraform apply")
            destroy_op = General("terraform destroy")
            
        # Meta-Arguments
        with Cluster("Meta-Arguments"):
            count_arg = General("count")
            for_each_arg = General("for_each")
            lifecycle_arg = General("lifecycle")
            depends_on_arg = General("depends_on")
        
        # AWS Resources
        with Cluster("AWS Resources"):
            ec2_instance = EC2("EC2 Instance")
            s3_bucket = S3("S3 Bucket")
            vpc_resource = VPC("VPC")
        
        # Lifecycle flow
        plan_op >> planned >> apply_op >> creating >> created
        created >> updating >> updated
        created >> destroy_op >> destroying >> destroyed
        
        # Meta-arguments influence
        [count_arg, for_each_arg, lifecycle_arg, depends_on_arg] >> [creating, updating, destroying]
        
        # Resource examples
        [created, updated] >> [ec2_instance, s3_bucket, vpc_resource]

def generate_dependency_graph():
    """Generate Figure 3.3: Dependency Graph Example."""
    print("Generating Figure 3.3: Dependency Graph Example...")
    
    with Diagram(
        "Figure 3.3: Dependency Graph Example",
        filename=str(OUTPUT_DIR / "dependency_graph"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Infrastructure Components
        with Cluster("VPC Infrastructure"):
            vpc = VPC("VPC")
            igw = InternetGateway("Internet Gateway")
            
        with Cluster("Networking"):
            public_subnet = General("Public Subnet")
            private_subnet = General("Private Subnet")
            route_table = General("Route Table")
            
        with Cluster("Security"):
            security_group = General("Security Group")
            
        with Cluster("Compute"):
            ec2_web = EC2("Web Server")
            ec2_app = EC2("App Server")
            
        with Cluster("Load Balancing"):
            alb = ELB("Application\nLoad Balancer")
            
        with Cluster("Storage"):
            s3_bucket = S3("S3 Bucket")
            
        # Dependency relationships
        vpc >> Edge(label="implicit") >> [public_subnet, private_subnet, security_group]
        vpc >> Edge(label="implicit") >> igw
        igw >> Edge(label="implicit") >> route_table
        public_subnet >> Edge(label="implicit") >> route_table
        
        [public_subnet, security_group] >> Edge(label="implicit") >> ec2_web
        [private_subnet, security_group] >> Edge(label="implicit") >> ec2_app
        
        [public_subnet, private_subnet, security_group] >> Edge(label="implicit") >> alb
        igw >> Edge(label="depends_on") >> alb
        
        # Independent resource
        s3_bucket

def generate_performance_optimization():
    """Generate Figure 3.4: Performance Optimization."""
    print("Generating Figure 3.4: Performance Optimization...")
    
    with Diagram(
        "Figure 3.4: Performance Optimization",
        filename=str(OUTPUT_DIR / "performance_optimization"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Performance Strategies
        with Cluster("Performance Optimization Strategies"):
            # Parallelism
            with Cluster("Parallelism Control"):
                parallel_config = General("terraform apply\n-parallelism=20")
                parallel_env = General("TF_CLI_ARGS_apply=\n'-parallelism=15'")
                
            # Provider Caching
            with Cluster("Provider Caching"):
                cache_dir = General("TF_PLUGIN_CACHE_DIR")
                cache_config = General("plugin_cache_dir\nin .terraformrc")
                
            # Resource Targeting
            with Cluster("Resource Targeting"):
                target_resource = General("terraform apply\n-target=aws_instance.web")
                target_module = General("terraform apply\n-target=module.networking")
                
            # State Optimization
            with Cluster("State Optimization"):
                refresh_disable = General("terraform plan\n-refresh=false")
                state_backend = General("Remote State\nBackend")
        
        # Performance Metrics
        with Cluster("Performance Metrics"):
            time_before = General("Before: 5 minutes")
            time_after = General("After: 2 minutes")
            
        # Infrastructure Scale
        with Cluster("Infrastructure Scale"):
            small_infra = General("10 Resources")
            medium_infra = General("50 Resources")
            large_infra = General("200+ Resources")
        
        # Optimization impact
        [parallel_config, cache_dir, target_resource] >> time_after
        time_before >> Edge(label="optimization") >> time_after
        
        # Scale considerations
        small_infra >> parallel_config
        medium_infra >> [parallel_config, cache_dir]
        large_infra >> [parallel_config, cache_dir, target_resource, state_backend]

def generate_error_recovery():
    """Generate Figure 3.5: Error Recovery Patterns."""
    print("Generating Figure 3.5: Error Recovery Patterns...")
    
    with Diagram(
        "Figure 3.5: Error Recovery Patterns",
        filename=str(OUTPUT_DIR / "error_recovery"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Error Scenarios
        with Cluster("Common Error Scenarios"):
            state_lock = General("State Lock\nError")
            resource_exists = General("Resource Already\nExists")
            provider_version = General("Provider Version\nConflict")
            partial_apply = General("Partial Apply\nFailure")
            
        # Recovery Actions
        with Cluster("Recovery Actions"):
            # State Lock Recovery
            force_unlock = General("terraform\nforce-unlock")
            
            # Resource Import
            import_resource = General("terraform import\naws_instance.web\ni-1234567890abcdef0")
            
            # Provider Upgrade
            init_upgrade = General("terraform init\n-upgrade")
            
            # State Management
            state_backup = General("cp terraform.tfstate\nterraform.tfstate.backup")
            state_restore = General("cp terraform.tfstate.backup\nterraform.tfstate")
            
        # Validation Steps
        with Cluster("Validation and Prevention"):
            validate_config = General("terraform validate")
            format_code = General("terraform fmt")
            plan_check = General("terraform plan\n-detailed-exitcode")
            
        # Monitoring
        with Cluster("Monitoring and Logging"):
            debug_logging = General("TF_LOG=DEBUG")
            apply_logging = General("terraform apply\n| tee apply.log")
            
        # Recovery flows
        state_lock >> force_unlock
        resource_exists >> import_resource
        provider_version >> init_upgrade
        partial_apply >> [state_backup, state_restore]
        
        # Prevention flows
        [validate_config, format_code, plan_check] >> Edge(label="prevents") >> [resource_exists, provider_version]
        [debug_logging, apply_logging] >> Edge(label="helps diagnose") >> [state_lock, partial_apply]

def main():
    """Main function to generate all diagrams."""
    print("🎨 Starting Core Terraform Operations Diagram Generation")
    print("=" * 80)
    
    # Setup
    setup_output_directory()
    
    try:
        # Generate all diagrams
        generate_core_workflow()
        generate_resource_lifecycle()
        generate_dependency_graph()
        generate_performance_optimization()
        generate_error_recovery()
        
        print("\n✅ All diagrams generated successfully!")
        print(f"📁 Output location: {OUTPUT_DIR}")
        print("\nGenerated diagrams:")
        print("- Figure 3.1: core_workflow.png")
        print("- Figure 3.2: resource_lifecycle.png")
        print("- Figure 3.3: dependency_graph.png")
        print("- Figure 3.4: performance_optimization.png")
        print("- Figure 3.5: error_recovery.png")
        print(f"\n🎯 All diagrams are {DPI} DPI for professional quality")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
