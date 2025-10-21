#!/usr/bin/env python3
"""
Topic 9: Terraform Migration Patterns Diagram
Generates a diagram showing different resource migration patterns
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import SecurityGroup, VPC
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.iac import Terraform

def create_migration_patterns_diagram():
    """Create Terraform migration patterns diagram"""
    
    with Diagram(
        "Terraform Migration Patterns",
        filename="migration_patterns",
        direction="LR",
        show=False,
        outformat="png"
    ):
        # Pattern 1: Single Resource Migration
        with Cluster("Pattern 1: Single Resource"):
            aws_single = EC2("EC2 Instance")
            tf_single = Terraform("terraform import\naws_instance.web")
            state_single = PostgreSQL("State")
            
            aws_single >> Edge(label="import") >> tf_single >> state_single
        
        # Pattern 2: Dependent Resources
        with Cluster("Pattern 2: Dependent Resources"):
            with Cluster("AWS"):
                vpc = VPC("VPC")
                sg = SecurityGroup("Security Group")
                ec2 = EC2("EC2 Instance")
                vpc >> sg >> ec2
            
            with Cluster("Terraform"):
                import_vpc = Terraform("import VPC")
                import_sg = Terraform("import SG")
                import_ec2 = Terraform("import EC2")
                import_vpc >> import_sg >> import_ec2
            
            ec2 >> Edge(label="import in order") >> import_vpc
        
        # Pattern 3: Workspace Migration
        with Cluster("Pattern 3: Workspace Migration"):
            state_old = PostgreSQL("State: Old")
            state_new = PostgreSQL("State: New")
            
            state_old >> Edge(label="terraform state mv") >> state_new
        
        # Pattern 4: Disaster Recovery
        with Cluster("Pattern 4: Disaster Recovery"):
            corrupted = PostgreSQL("Corrupted State")
            backup = PostgreSQL("Backup State")
            recovered = PostgreSQL("Recovered State")
            
            corrupted >> Edge(label="restore from") >> backup >> Edge(label="refresh") >> recovered

if __name__ == "__main__":
    print("Generating Terraform Migration Patterns diagram...")
    create_migration_patterns_diagram()
    print("✓ Diagram saved as: migration_patterns.png")

