from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, InternetGateway, RouteTable
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM
from diagrams.aws.general import General
from diagrams.programming.language import Python
from diagrams.onprem.vcs import Git

def create_terraform_basics_diagram():
    with Diagram("Terraform Basics Concepts", show=False, direction="TB"):
        # Core Concepts
        with Cluster("Terraform Core Concepts"):
            tf_core = Terraform("Terraform Core")
            
            with Cluster("Basic Commands"):
                init = Terraform("Init")
                plan = Terraform("Plan")
                apply = Terraform("Apply")
                destroy = Terraform("Destroy")
                
                init >> plan >> apply >> destroy

            with Cluster("Configuration"):
                config = [
                    Python("main.tf"),
                    Python("variables.tf"),
                    Python("outputs.tf"),
                    Python("providers.tf")
                ]
                
                for c in config:
                    c >> tf_core

        # Infrastructure Components
        with Cluster("AWS Infrastructure"):
            vpc = VPC("VPC")
            igw = InternetGateway("Internet Gateway")
            rt = RouteTable("Route Table")
            ec2 = EC2("EC2 Instance")
            s3 = S3("Storage")
            
            vpc >> igw >> rt >> ec2 >> s3

        # State Management
        with Cluster("State Management"):
            state = [
                S3("Remote State"),
                Terraform("State Lock"),
                Terraform("State Operations")
            ]
            
            tf_core >> Edge(color="red") >> state

        # Variables and Outputs
        with Cluster("Variables & Outputs"):
            vars = [
                General("Input Variables"),
                General("Local Variables"),
                General("Output Values")
            ]
            
            vars >> tf_core

def create_terraform_workflow_diagram():
    with Diagram("Terraform Workflow", show=False):
        with Cluster("Development Process"):
            # Version Control
            git = Git("Version Control")
            
            # Terraform Workflow
            with Cluster("Terraform Workflow"):
                init = Terraform("terraform init")
                validate = Terraform("terraform validate")
                plan = Terraform("terraform plan")
                apply = Terraform("terraform apply")
                
                init >> validate >> plan >> apply
            
            # Infrastructure
            with Cluster("AWS Resources"):
                vpc = VPC("Network")
                compute = EC2("Compute")
                storage = S3("Storage")
                
                vpc >> compute >> storage
            
            git >> init
            apply >> [vpc, compute, storage]

def create_state_management_diagram():
    with Diagram("State Management", show=False):
        with Cluster("State Operations"):
            tf = Terraform("Terraform")
            
            with Cluster("State Storage"):
                local = Terraform("Local State")
                remote = S3("Remote State")
                lock = IAM("State Lock")
                
                tf >> [local, remote]
                remote >> lock

            with Cluster("State Commands"):
                commands = [
                    Terraform("terraform refresh"),
                    Terraform("terraform state list"),
                    Terraform("terraform state show"),
                    Terraform("terraform state mv")
                ]
                
                for cmd in commands:
                    tf >> cmd

if __name__ == "__main__":
    create_terraform_basics_diagram()
    create_terraform_workflow_diagram()
    create_state_management_diagram()