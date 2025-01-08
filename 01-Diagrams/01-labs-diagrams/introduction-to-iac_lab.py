from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC

# Lab architecture diagrams for introduction-to-iac
def create_lab_diagram():
    with Diagram("Introduction to IaC Lab Architecture", show=False):
        terraform = Terraform("Terraform")
        
        with Cluster("AWS Cloud"):
            vpc = VPC("VPC")
            ec2 = EC2("Web Server")
            
            terraform >> vpc >> ec2

if __name__ == "__main__":
    create_lab_diagram()
