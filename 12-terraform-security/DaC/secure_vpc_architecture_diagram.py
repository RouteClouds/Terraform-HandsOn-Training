#!/usr/bin/env python3
"""
Topic 12: Secure VPC Architecture Diagram
Generates a professional diagram showing secure VPC design
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import VPC, Subnet, SecurityGroup, NatGateway
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

def create_secure_vpc_architecture_diagram():
    """Create secure VPC architecture diagram"""
    
    with Diagram(
        "Secure VPC Architecture",
        filename="secure_vpc_architecture",
        direction="TB",
        show=False,
        outformat="png"
    ):
        # Internet
        internet = ELB("Internet")
        
        # VPC
        with Cluster("VPC (10.0.0.0/16)"):
            # Public Subnet
            with Cluster("Public Subnet (10.0.2.0/24)"):
                alb_sg = SecurityGroup("ALB SG\n(443, 80)")
                alb = ELB("Application Load Balancer")
                alb_sg >> alb
            
            # Private Subnet - Application
            with Cluster("Private Subnet - App (10.0.1.0/24)"):
                app_sg = SecurityGroup("App SG\n(80 from ALB)")
                app = EC2("Application Servers")
                app_sg >> app
            
            # Private Subnet - Database
            with Cluster("Private Subnet - DB (10.0.3.0/24)"):
                db_sg = SecurityGroup("DB SG\n(3306 from App)")
                db = RDS("Database")
                db_sg >> db
            
            # NAT Gateway
            nat = NatGateway("NAT Gateway")
        
        # Connections
        internet >> Edge(label="HTTPS/HTTP") >> alb
        alb >> Edge(label="HTTP") >> app
        app >> Edge(label="MySQL") >> db
        app >> Edge(label="Outbound") >> nat
        nat >> Edge(label="Internet") >> internet

if __name__ == "__main__":
    print("Generating Secure VPC Architecture diagram...")
    create_secure_vpc_architecture_diagram()
    print("✓ Diagram saved as: secure_vpc_architecture.png")

