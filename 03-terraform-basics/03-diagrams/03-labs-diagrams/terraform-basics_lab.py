from diagrams import Diagram, Cluster
from diagrams.programming.framework import Terraform
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC

# Lab architecture diagrams for terraform-basics
def create_lab_diagram():
    with Diagram("terraform-basics Lab Architecture", show=False):
        # Add diagram components here
        pass

if __name__ == "__main__":
    create_lab_diagram()
