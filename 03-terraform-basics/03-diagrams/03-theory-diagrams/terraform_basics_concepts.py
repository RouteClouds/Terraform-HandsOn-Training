from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM
from diagrams.aws.general import General
from diagrams.programming.language import Python
from diagrams.onprem.vcs import Git

# Terraform Basic Workflow
def create_terraform_workflow():
    with Diagram("Terraform Basic Workflow", show=False):
        with Cluster("Terraform Lifecycle"):
            init = Terraform("terraform init")
            plan = Terraform("terraform plan")
            apply = Terraform("terraform apply")
            destroy = Terraform("terraform destroy")

            init >> plan >> apply >> destroy

# HCL Configuration Structure
def create_hcl_structure():
    with Diagram("HCL Configuration Structure", show=False):
        with Cluster("Configuration Files"):
            with Cluster("Core Files"):
                main = Python("main.tf")
                vars = Python("variables.tf")
                outputs = Python("outputs.tf")
                provider = Python("provider.tf")

            with Cluster("Additional Files"):
                tfvars = Python("terraform.tfvars")
                backend = Python("backend.tf")

            main >> outputs
            vars >> main
            provider >> main
            tfvars >> vars
            backend >> main

# Resource Dependencies
def create_resource_dependencies():
    with Diagram("Resource Dependencies", show=False):
        with Cluster("AWS Infrastructure"):
            vpc = VPC("VPC")
            subnet = VPC("Subnet")
            sg = IAM("Security Group")
            ec2 = EC2("EC2 Instance")
            s3 = S3("S3 Bucket")

            vpc >> subnet >> sg >> ec2
            ec2 >> s3

# Variable Types and Usage
def create_variable_types():
    with Diagram("Variable Types and Usage", show=False):
        with Cluster("Variable Types"):
            simple = General("Simple Types")
            complex = General("Complex Types")
            
            with Cluster("Simple"):
                string = General("String")
                number = General("Number")
                bool = General("Boolean")
                
            with Cluster("Complex"):
                list = General("List")
                map = General("Map")
                object = General("Object")

            simple >> Edge() >> [string, number, bool]
            complex >> Edge() >> [list, map, object]

# State Management
def create_state_management():
    with Diagram("State Management", show=False):
        with Cluster("State Storage"):
            local = Terraform("Local State")
            remote = S3("Remote State")
            
            with Cluster("State Operations"):
                refresh = Terraform("Refresh")
                import_op = Terraform("Import")
                move = Terraform("Move")

            local >> refresh
            remote >> refresh
            refresh >> [import_op, move]

# Best Practices
def create_best_practices():
    with Diagram("Terraform Best Practices", show=False):
        with Cluster("Development Workflow"):
            git = Git("Version Control")
            tf = Terraform("Terraform")
            aws = General("AWS")

            with Cluster("Best Practices"):
                code = General("Code Organization")
                state = General("State Management")
                security = General("Security")

            git >> tf >> aws
            [code, state, security] >> tf

if __name__ == "__main__":
    create_terraform_workflow()
    create_hcl_structure()
    create_resource_dependencies()
    create_variable_types()
    create_state_management()
    create_best_practices() 