#!/usr/bin/env python3

from diagrams import Diagram, Cluster
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC
from diagrams.aws.security import IAM
from diagrams.onprem.iac import Terraform

def create_basics_lab_diagram():
    # Set output directory explicitly
    outdir = "/home/geek/All-Projects/k8s-training-project/CKA-Course-Content/Terraform-training/03-terraform-basics/terraform-diagrams/labs/diagrams"
    
    # Create output directory if it doesn't exist
    import os
    os.makedirs(outdir, exist_ok=True)
    
    graph_attr = {
        "pad": "1.5",
        "splines": "ortho",
        "nodesep": "1.0",
        "rankdir": "LR"
    }
    
    # Specify the output directory in the Diagram constructor
    with Diagram(
        "Terraform Basics Lab Architecture",
        show=True,
        filename=f"{outdir}/terraform_basics_lab",
        graph_attr=graph_attr,
        outformat="png"
    ):
        with Cluster("AWS Infrastructure"):
            vpc = VPC("VPC")
            ec2 = EC2("EC2 Instance")
            iam = IAM("IAM Role")

            with Cluster("Terraform Configuration"):
                tf = Terraform("Terraform")
                
            # Define relationships
            tf >> vpc >> ec2
            tf >> iam >> ec2

if __name__ == "__main__":
    try:
        create_basics_lab_diagram()
        print("Diagram created successfully!")
    except Exception as e:
        print(f"Error creating diagram: {str(e)}") 