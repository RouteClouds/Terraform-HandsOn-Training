#!/usr/bin/env python3

from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform  # Correct import path for Terraform
from diagrams.aws.general import General
from diagrams.programming.language import Python
from diagrams.aws.management import Config

def create_modules_concept_diagram():
    graph_attr = {
        "pad": "1.5",
        "splines": "ortho",
        "nodesep": "1.0",
        "rankdir": "LR"
    }
    
    with Diagram(
        "Terraform Modules Concept",
        show=True,
        filename="terraform_modules_concept",
        graph_attr=graph_attr,
        outformat="png"
    ):
        with Cluster("Root Module"):
            tf = Terraform("Terraform")
            
            with Cluster("Child Modules"):
                vpc_module = General("VPC Module")
                ec2_module = General("EC2 Module")
                rds_module = General("RDS Module")
            
            with Cluster("Resources"):
                resources = Config("AWS Resources")
            
            # Define relationships
            tf >> [vpc_module, ec2_module, rds_module]
            vpc_module >> resources
            ec2_module >> resources
            rds_module >> resources

if __name__ == "__main__":
    try:
        create_modules_concept_diagram()
        print("Diagram created successfully!")
    except Exception as e:
        print(f"Error creating diagram: {str(e)}") 