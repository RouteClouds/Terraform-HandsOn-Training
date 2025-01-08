from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC

def create_lab_diagram():
    with Diagram("Import and Migration Lab Architecture", show=False):
        # Add lab diagram components here
        pass

if __name__ == "__main__":
    create_lab_diagram()
