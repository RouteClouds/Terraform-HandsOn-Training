#!/usr/bin/env python3
"""
AWS Terraform Training - Resource Management & Dependencies
Diagram as Code (DaC) Generation Script

This script generates 5 professional diagrams for the Resource Management & Dependencies module:
1. Resource Dependency Graph
2. Meta-Arguments Comparison
3. Lifecycle Management Patterns
4. Complex Dependency Resolution
5. Resource Management Workflow

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
    from diagrams.aws.compute import EC2, AutoScaling
    from diagrams.aws.database import RDS, RDSInstance
    from diagrams.aws.network import VPC, ELB, InternetGateway, NATGateway, RouteTable
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

def generate_dependency_graph():
    """Generate Figure 4.1: Resource Dependency Graph."""
    print("Generating Figure 4.1: Resource Dependency Graph...")
    
    with Diagram(
        "Figure 4.1: Resource Dependency Graph",
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
        # Foundation Layer
        with Cluster("Foundation Layer"):
            vpc = VPC("VPC")
            igw = InternetGateway("Internet Gateway")
            
        # Network Layer
        with Cluster("Network Layer"):
            public_subnet = General("Public Subnets\n(count = 2)")
            private_subnet = General("Private Subnets\n(count = 2)")
            db_subnet = General("Database Subnets\n(count = 2)")
            
        # Routing Layer
        with Cluster("Routing Layer"):
            public_rt = RouteTable("Public Route Table")
            private_rt = RouteTable("Private Route Tables\n(count = 2)")
            nat_gw = NATGateway("NAT Gateways\n(optional)")
            
        # Security Layer
        with Cluster("Security Layer"):
            web_sg = General("Web Security Group")
            app_sg = General("App Security Group")
            db_sg = General("Database Security Group")
            alb_sg = General("ALB Security Group")
            
        # Application Layer
        with Cluster("Application Layer"):
            database = RDSInstance("RDS Database")
            web_asg = AutoScaling("Web ASG\n(for_each)")
            app_asg = AutoScaling("App ASG\n(for_each)")
            alb = ELB("Application\nLoad Balancer")
            
        # Implicit Dependencies (solid lines)
        vpc >> Edge(label="implicit", style="solid", color="blue") >> [public_subnet, private_subnet, db_subnet]
        vpc >> Edge(label="implicit", style="solid", color="blue") >> igw
        vpc >> Edge(label="implicit", style="solid", color="blue") >> [web_sg, app_sg, db_sg, alb_sg]
        
        igw >> Edge(label="implicit", style="solid", color="blue") >> public_rt
        public_subnet >> Edge(label="implicit", style="solid", color="blue") >> public_rt
        private_subnet >> Edge(label="implicit", style="solid", color="blue") >> private_rt
        
        [public_subnet, private_subnet] >> Edge(label="implicit", style="solid", color="blue") >> nat_gw
        
        db_subnet >> Edge(label="implicit", style="solid", color="blue") >> database
        db_sg >> Edge(label="implicit", style="solid", color="blue") >> database
        
        [private_subnet, web_sg] >> Edge(label="implicit", style="solid", color="blue") >> web_asg
        [private_subnet, app_sg] >> Edge(label="implicit", style="solid", color="blue") >> app_asg
        
        [public_subnet, alb_sg] >> Edge(label="implicit", style="solid", color="blue") >> alb
        
        # Explicit Dependencies (dashed lines)
        igw >> Edge(label="depends_on", style="dashed", color="red") >> alb
        database >> Edge(label="depends_on", style="dashed", color="red") >> [web_asg, app_asg]
        [web_asg, app_asg] >> Edge(label="depends_on", style="dashed", color="red") >> alb

def generate_meta_arguments():
    """Generate Figure 4.2: Meta-Arguments Comparison."""
    print("Generating Figure 4.2: Meta-Arguments Comparison...")
    
    with Diagram(
        "Figure 4.2: Meta-Arguments Comparison",
        filename=str(OUTPUT_DIR / "meta_arguments"),
        show=False,
        direction="LR",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Count Meta-Argument
        with Cluster("count Meta-Argument"):
            count_config = General("count = 3")
            count_resources = [
                General("resource[0]"),
                General("resource[1]"),
                General("resource[2]")
            ]
            count_reference = General("resource[*].id")
            
        # For_Each Meta-Argument
        with Cluster("for_each Meta-Argument"):
            foreach_config = General("for_each = {\n  web = {...}\n  app = {...}\n}")
            foreach_resources = [
                General("resource[\"web\"]"),
                General("resource[\"app\"]")
            ]
            foreach_reference = General("resource[\"web\"].id")
            
        # Lifecycle Meta-Argument
        with Cluster("lifecycle Meta-Argument"):
            lifecycle_config = General("lifecycle {\n  create_before_destroy\n  prevent_destroy\n  ignore_changes\n}")
            lifecycle_behaviors = [
                General("Create Before Destroy"),
                General("Prevent Destroy"),
                General("Ignore Changes"),
                General("Replace Triggered By")
            ]
            
        # Depends_On Meta-Argument
        with Cluster("depends_on Meta-Argument"):
            depends_config = General("depends_on = [\n  resource1,\n  resource2\n]")
            depends_flow = [
                General("Resource 1"),
                General("Resource 2"),
                General("Target Resource")
            ]
            
        # Connections
        count_config >> count_resources
        count_resources >> count_reference
        
        foreach_config >> foreach_resources
        foreach_resources >> foreach_reference
        
        lifecycle_config >> lifecycle_behaviors
        
        depends_config >> depends_flow[0] >> depends_flow[1] >> depends_flow[2]

def generate_lifecycle_patterns():
    """Generate Figure 4.3: Lifecycle Management Patterns."""
    print("Generating Figure 4.3: Lifecycle Management Patterns...")
    
    with Diagram(
        "Figure 4.3: Lifecycle Management Patterns",
        filename=str(OUTPUT_DIR / "lifecycle_patterns"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Create Before Destroy Pattern
        with Cluster("Create Before Destroy Pattern"):
            old_resource = General("Old Resource\n(running)")
            new_resource = General("New Resource\n(creating)")
            updated_resource = General("Updated Resource\n(active)")
            
            old_resource >> Edge(label="1. Create new") >> new_resource
            new_resource >> Edge(label="2. Update references") >> updated_resource
            updated_resource >> Edge(label="3. Destroy old") >> General("Destroyed")
            
        # Prevent Destroy Pattern
        with Cluster("Prevent Destroy Pattern"):
            critical_resource = General("Critical Resource\n(protected)")
            destroy_attempt = General("Destroy Attempt")
            error_message = General("Error: Resource\nProtected")
            
            destroy_attempt >> Edge(label="blocked", color="red") >> critical_resource
            destroy_attempt >> Edge(label="returns", color="red") >> error_message
            
        # Ignore Changes Pattern
        with Cluster("Ignore Changes Pattern"):
            managed_resource = General("Managed Resource")
            external_change = General("External Change")
            terraform_plan = General("Terraform Plan")
            no_changes = General("No Changes\nDetected")
            
            external_change >> Edge(label="modifies") >> managed_resource
            terraform_plan >> Edge(label="ignores") >> managed_resource
            terraform_plan >> Edge(label="reports") >> no_changes
            
        # Replace Triggered By Pattern
        with Cluster("Replace Triggered By Pattern"):
            trigger_resource = General("Trigger Resource\n(changed)")
            dependent_resource = General("Dependent Resource")
            replacement = General("Replacement\nTriggered")
            
            trigger_resource >> Edge(label="change detected") >> dependent_resource
            dependent_resource >> Edge(label="triggers") >> replacement

def generate_complex_dependencies():
    """Generate Figure 4.4: Complex Dependency Resolution."""
    print("Generating Figure 4.4: Complex Dependency Resolution...")
    
    with Diagram(
        "Figure 4.4: Complex Dependency Resolution",
        filename=str(OUTPUT_DIR / "complex_dependencies"),
        show=False,
        direction="TB",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Multi-Tier Architecture
        with Cluster("Data Tier"):
            db_subnet_group = General("DB Subnet Group")
            database = RDSInstance("RDS Database")
            db_security_group = General("DB Security Group")
            
        with Cluster("Application Tier"):
            app_launch_template = General("Launch Template")
            app_asg = AutoScaling("Auto Scaling Group")
            app_security_group = General("App Security Group")
            
        with Cluster("Presentation Tier"):
            alb = ELB("Load Balancer")
            alb_target_group = General("Target Group")
            alb_listener = General("Listener")
            alb_security_group = General("ALB Security Group")
            
        with Cluster("Network Foundation"):
            vpc = VPC("VPC")
            subnets = General("Subnets")
            igw = InternetGateway("Internet Gateway")
            route_tables = RouteTable("Route Tables")
            
        # Complex Dependency Chains
        vpc >> Edge(label="1") >> subnets
        vpc >> Edge(label="2") >> [db_security_group, app_security_group, alb_security_group]
        subnets >> Edge(label="3") >> db_subnet_group
        [db_subnet_group, db_security_group] >> Edge(label="4") >> database
        
        database >> Edge(label="5", style="dashed") >> app_launch_template
        [subnets, app_security_group] >> Edge(label="6") >> app_asg
        app_launch_template >> Edge(label="7") >> app_asg
        
        [subnets, alb_security_group] >> Edge(label="8") >> alb
        igw >> Edge(label="9", style="dashed") >> alb
        alb >> Edge(label="10") >> alb_target_group
        alb_target_group >> Edge(label="11") >> alb_listener
        
        # Circular Dependency Resolution
        with Cluster("Circular Dependency Resolution"):
            resource_a = General("Resource A")
            resource_b = General("Resource B")
            data_source = General("Data Source\n(breaks cycle)")
            
            resource_a >> Edge(label="references", color="blue") >> data_source
            data_source >> Edge(label="queries", color="green") >> resource_b
            resource_b >> Edge(label="would reference", style="dashed", color="red") >> resource_a

def generate_resource_workflow():
    """Generate Figure 4.5: Resource Management Workflow."""
    print("Generating Figure 4.5: Resource Management Workflow...")
    
    with Diagram(
        "Figure 4.5: Resource Management Workflow",
        filename=str(OUTPUT_DIR / "resource_workflow"),
        show=False,
        direction="LR",
        graph_attr={
            "dpi": str(DPI),
            "bgcolor": "white",
            "fontname": "Arial",
            "fontsize": "16"
        }
    ):
        # Planning Phase
        with Cluster("Planning Phase"):
            analyze_deps = General("Analyze\nDependencies")
            choose_meta_args = General("Choose\nMeta-Arguments")
            design_lifecycle = General("Design\nLifecycle Rules")
            
        # Implementation Phase
        with Cluster("Implementation Phase"):
            configure_resources = General("Configure\nResources")
            set_dependencies = General("Set\nDependencies")
            apply_lifecycle = General("Apply\nLifecycle Rules")
            
        # Validation Phase
        with Cluster("Validation Phase"):
            validate_graph = General("Validate\nDependency Graph")
            test_lifecycle = General("Test\nLifecycle Behavior")
            verify_ordering = General("Verify\nResource Ordering")
            
        # Optimization Phase
        with Cluster("Optimization Phase"):
            optimize_deps = General("Optimize\nDependencies")
            tune_performance = General("Tune\nPerformance")
            document_patterns = General("Document\nPatterns")
            
        # Workflow connections
        analyze_deps >> choose_meta_args >> design_lifecycle
        design_lifecycle >> configure_resources
        configure_resources >> set_dependencies >> apply_lifecycle
        apply_lifecycle >> validate_graph
        validate_graph >> test_lifecycle >> verify_ordering
        verify_ordering >> optimize_deps
        optimize_deps >> tune_performance >> document_patterns
        
        # Feedback loops
        verify_ordering >> Edge(label="issues found", style="dashed") >> analyze_deps
        test_lifecycle >> Edge(label="lifecycle issues", style="dashed") >> design_lifecycle

def main():
    """Main function to generate all diagrams."""
    print("🎨 Starting Resource Management & Dependencies Diagram Generation")
    print("=" * 80)
    
    # Setup
    setup_output_directory()
    
    try:
        # Generate all diagrams
        generate_dependency_graph()
        generate_meta_arguments()
        generate_lifecycle_patterns()
        generate_complex_dependencies()
        generate_resource_workflow()
        
        print("\n✅ All diagrams generated successfully!")
        print(f"📁 Output location: {OUTPUT_DIR}")
        print("\nGenerated diagrams:")
        print("- Figure 4.1: dependency_graph.png")
        print("- Figure 4.2: meta_arguments.png")
        print("- Figure 4.3: lifecycle_patterns.png")
        print("- Figure 4.4: complex_dependencies.png")
        print("- Figure 4.5: resource_workflow.png")
        print(f"\n🎯 All diagrams are {DPI} DPI for professional quality")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
