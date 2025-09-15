#!/usr/bin/env python3
"""
Terraform Module Architecture Diagram
Generates a comprehensive diagram showing module structure and relationships
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, AutoScaling
from diagrams.aws.database import RDS
from diagrams.aws.network import VPC, PrivateSubnet, PublicSubnet, NATGateway, InternetGateway, ELB
from diagrams.aws.security import IAM
from diagrams.aws.storage import S3
from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import SQS
from diagrams.generic.blank import Blank
from diagrams.generic.compute import Rack

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
    "Terraform Module Architecture",
    filename="01-module-architecture",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr
):
    
    # Root Module
    with Cluster("Root Module (main.tf)"):
        root_config = Rack("Root Configuration")

        # Module Calls
        with Cluster("Module Composition"):
            vpc_module = Rack("VPC Module")
            compute_module = Rack("Compute Module")
            database_module = Rack("Database Module")
            security_module = Rack("Security Module")
    
    # VPC Module Details
    with Cluster("VPC Module Structure"):
        with Cluster("Network Components"):
            vpc = VPC("VPC")
            igw = InternetGateway("Internet Gateway")
            
            with Cluster("Public Tier"):
                public_subnet_1 = PublicSubnet("Public Subnet 1a")
                public_subnet_2 = PublicSubnet("Public Subnet 1b")
                nat_gw = NATGateway("NAT Gateway")
            
            with Cluster("Private Tier"):
                private_subnet_1 = PrivateSubnet("Private Subnet 1a")
                private_subnet_2 = PrivateSubnet("Private Subnet 1b")
            
            with Cluster("Database Tier"):
                db_subnet_1 = PrivateSubnet("DB Subnet 1a")
                db_subnet_2 = PrivateSubnet("DB Subnet 1b")
    
    # Compute Module Details
    with Cluster("Compute Module Structure"):
        with Cluster("Auto Scaling"):
            asg = AutoScaling("Auto Scaling Group")
            ec2_instances = [
                EC2("Web Server 1"),
                EC2("Web Server 2"),
                EC2("Web Server 3")
            ]
        
        with Cluster("Load Balancing"):
            alb = ELB("Application Load Balancer")
    
    # Database Module Details
    with Cluster("Database Module Structure"):
        with Cluster("RDS Configuration"):
            rds_primary = RDS("RDS Primary")
            rds_standby = RDS("RDS Standby")
    
    # Security Module Details
    with Cluster("Security Module Structure"):
        with Cluster("Access Control"):
            iam_role = IAM("IAM Roles")
            web_sg = Blank("Web Security Group")
            app_sg = Blank("App Security Group")
            db_sg = Blank("DB Security Group")
    
    # Storage and Monitoring
    with Cluster("Supporting Services"):
        s3_bucket = S3("Application Storage")
        cloudwatch = Cloudwatch("Monitoring")
        sqs_queue = SQS("Message Queue")
    
    # Module Relationships
    root_config >> Edge(label="calls", style="dashed") >> [
        vpc_module,
        compute_module,
        database_module,
        security_module
    ]
    
    # VPC Module Internal Connections
    vpc >> igw
    vpc >> [public_subnet_1, public_subnet_2]
    vpc >> [private_subnet_1, private_subnet_2]
    vpc >> [db_subnet_1, db_subnet_2]
    
    public_subnet_1 >> nat_gw
    nat_gw >> [private_subnet_1, private_subnet_2]
    
    # Compute Module Connections
    alb >> asg
    asg >> ec2_instances
    
    # Cross-Module Dependencies
    vpc_module >> Edge(label="vpc_id", style="dotted") >> compute_module
    vpc_module >> Edge(label="subnet_ids", style="dotted") >> database_module
    security_module >> Edge(label="security_groups", style="dotted") >> compute_module
    security_module >> Edge(label="db_security_group", style="dotted") >> database_module
    
    # Infrastructure Placement
    alb - Edge(style="invis") - public_subnet_1
    ec2_instances[0] - Edge(style="invis") - private_subnet_1
    rds_primary - Edge(style="invis") - db_subnet_1
    rds_standby - Edge(style="invis") - db_subnet_2
    
    # Monitoring and Storage Connections
    ec2_instances >> Edge(label="logs", style="dotted") >> cloudwatch
    ec2_instances >> Edge(label="data", style="dotted") >> s3_bucket
    ec2_instances >> Edge(label="messages", style="dotted") >> sqs_queue
    
    # Database Replication
    rds_primary >> Edge(label="replication", style="bold") >> rds_standby

print("✅ Module Architecture diagram generated successfully!")
print("📁 Output: 01-module-architecture.png")
print("🎯 Shows: Module composition, structure, and relationships")
