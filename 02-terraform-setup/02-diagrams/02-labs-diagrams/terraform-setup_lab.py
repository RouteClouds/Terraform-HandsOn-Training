from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.onprem.client import Client
from diagrams.programming.language import Python
from diagrams.onprem.vcs import Git
from diagrams.aws.general import Client as AWSClient
from diagrams.aws.security import IAM
from diagrams.aws.storage import S3
from diagrams.aws.network import VPC, InternetGateway, RouteTable
from diagrams.aws.compute import EC2

# Lab 1: Basic Environment Setup
def create_lab1_diagram():
    with Diagram("Lab 1: Basic Environment Setup", show=False):
        with Cluster("Local Environment"):
            tools = [
                Client("VS Code"),
                Git("Git"),
                Python("AWS CLI"),
                Terraform("Terraform CLI")
            ]

        with Cluster("AWS Environment"):
            s3 = S3("Test Bucket")
            iam = IAM("AWS Credentials")

        tools >> Edge(label="create") >> s3
        tools >> Edge(label="authenticate") >> iam

# Lab 2: Development Environment
def create_lab2_diagram():
    with Diagram("Lab 2: Development Environment", show=False):
        with Cluster("Network Infrastructure"):
            vpc = VPC("Development VPC")
            igw = InternetGateway("Internet Gateway")
            rt = RouteTable("Route Table")
            
            with Cluster("Public Subnet"):
                subnet = [EC2("Instance 1"),
                         EC2("Instance 2")]

            vpc >> igw >> rt >> subnet

# Lab 3: Backend Configuration
def create_lab3_diagram():
    with Diagram("Lab 3: Backend Configuration", show=False):
        with Cluster("State Management"):
            tf = Terraform("Terraform")
            
            with Cluster("Backend Infrastructure"):
                state = S3("State Bucket")
                lock = IAM("State Lock")
                
                tf >> state
                tf >> lock

# Lab 4: Workspace Management
def create_lab4_diagram():
    with Diagram("Lab 4: Workspace Setup", show=False):
        with Cluster("Module Structure"):
            module = Terraform("VPC Module")
            
            with Cluster("Environments"):
                envs = [
                    VPC("Dev VPC"),
                    VPC("Staging VPC"),
                    VPC("Prod VPC")
                ]
                
                module >> envs

if __name__ == "__main__":
    create_lab1_diagram()
    create_lab2_diagram()
    create_lab3_diagram()
    create_lab4_diagram()
