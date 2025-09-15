#!/usr/bin/env python3
"""
Terraform Module Composition Patterns Diagram
Demonstrates different module composition strategies and patterns
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.generic.compute import Rack
from diagrams.aws.compute import EC2, Lambda
from diagrams.aws.database import RDS, Dynamodb
from diagrams.aws.network import VPC, ELB
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM
from diagrams.aws.management import Cloudwatch
from diagrams.generic.blank import Blank

# Configure diagram settings
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "dpi": "300",
    "margin": "0.5",
    "rankdir": "TB",
    "splines": "ortho"
}

node_attr = {
    "fontsize": "12",
    "fontname": "Arial",
    "margin": "0.1"
}

edge_attr = {
    "fontsize": "10",
    "fontname": "Arial"
}

with Diagram(
    "Terraform Module Composition Patterns",
    filename="03-module-composition",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr
):
    
    # Pattern 1: Monolithic Module
    with Cluster("Pattern 1: Monolithic Module"):
        with Cluster("Single Large Module"):
            monolithic = Rack("Web Application Module")
            
            with Cluster("All Resources in One Module"):
                mono_vpc = VPC("VPC")
                mono_ec2 = EC2("EC2")
                mono_rds = RDS("RDS")
                mono_s3 = S3("S3")
                mono_iam = IAM("IAM")
                mono_elb = ELB("ELB")
        
        monolithic >> [mono_vpc, mono_ec2, mono_rds, mono_s3, mono_iam, mono_elb]
    
    # Pattern 2: Layered Modules
    with Cluster("Pattern 2: Layered Architecture"):
        with Cluster("Foundation Layer"):
            foundation = Rack("Foundation Module")
            foundation_vpc = VPC("VPC")
            foundation_iam = IAM("Base IAM")

        with Cluster("Platform Layer"):
            platform = Rack("Platform Module")
            platform_ec2 = EC2("Compute")
            platform_rds = RDS("Database")
            platform_s3 = S3("Storage")

        with Cluster("Application Layer"):
            application = Rack("Application Module")
            app_lambda = Lambda("Functions")
            app_elb = ELB("Load Balancer")
            app_cloudwatch = Cloudwatch("Monitoring")
        
        foundation >> [foundation_vpc, foundation_iam]
        platform >> [platform_ec2, platform_rds, platform_s3]
        application >> [app_lambda, app_elb, app_cloudwatch]
        
        foundation >> Edge(label="outputs", style="dashed") >> platform
        platform >> Edge(label="outputs", style="dashed") >> application
    
    # Pattern 3: Microservice Modules
    with Cluster("Pattern 3: Microservice Architecture"):
        with Cluster("Shared Infrastructure"):
            shared_infra = Rack("Shared Infrastructure")
            shared_vpc = VPC("Shared VPC")
            shared_monitoring = Cloudwatch("Shared Monitoring")

        with Cluster("Service Modules"):
            with Cluster("User Service"):
                user_service = Rack("User Service Module")
                user_ec2 = EC2("User API")
                user_db = Dynamodb("User DB")

            with Cluster("Order Service"):
                order_service = Rack("Order Service Module")
                order_ec2 = EC2("Order API")
                order_db = RDS("Order DB")

            with Cluster("Payment Service"):
                payment_service = Rack("Payment Service Module")
                payment_lambda = Lambda("Payment Function")
                payment_db = Dynamodb("Payment DB")
        
        shared_infra >> [shared_vpc, shared_monitoring]
        user_service >> [user_ec2, user_db]
        order_service >> [order_ec2, order_db]
        payment_service >> [payment_lambda, payment_db]
        
        shared_infra >> Edge(label="shared resources", style="dotted") >> [user_service, order_service, payment_service]
    
    # Pattern 4: Composite Module
    with Cluster("Pattern 4: Composite Module Pattern"):
        with Cluster("High-Level Composite"):
            composite = Rack("E-commerce Platform")

            with Cluster("Composed Sub-modules"):
                network_module = Rack("Network Module")
                security_module = Rack("Security Module")
                compute_module = Rack("Compute Module")
                data_module = Rack("Data Module")
                monitoring_module = Rack("Monitoring Module")
        
        composite >> [network_module, security_module, compute_module, data_module, monitoring_module]
        
        # Sub-module dependencies
        network_module >> Edge(label="vpc_id", style="dashed") >> [security_module, compute_module, data_module]
        security_module >> Edge(label="security_groups", style="dashed") >> [compute_module, data_module]
        compute_module >> Edge(label="instance_ids", style="dashed") >> monitoring_module
        data_module >> Edge(label="db_endpoints", style="dashed") >> monitoring_module
    
    # Pattern 5: Environment-Specific Modules
    with Cluster("Pattern 5: Environment-Specific Composition"):
        with Cluster("Base Module"):
            base_module = Rack("Base Application Module")

        with Cluster("Environment Overlays"):
            dev_overlay = Rack("Development Overlay")
            staging_overlay = Rack("Staging Overlay")
            prod_overlay = Rack("Production Overlay")
        
        with Cluster("Environment Configurations"):
            dev_config = Blank("Dev: t3.micro, 1 AZ")
            staging_config = Blank("Staging: t3.small, 2 AZ")
            prod_config = Blank("Prod: t3.large, 3 AZ, Multi-region")
        
        base_module >> [dev_overlay, staging_overlay, prod_overlay]
        dev_overlay >> dev_config
        staging_overlay >> staging_config
        prod_overlay >> prod_config

print("✅ Module Composition Patterns diagram generated successfully!")
print("📁 Output: 03-module-composition.png")
print("🎯 Shows: Different strategies for composing and organizing modules")
