from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform
from diagrams.aws.management import Config
from diagrams.aws.security import IAM
from diagrams.onprem.client import Users
from diagrams.custom import Custom

def create_setup_concept_diagram():
    with Diagram("Terraform Setup Concepts", show=True, filename="terraform_setup_concepts"):
        with Cluster("Development Environment"):
            user = Users("Developer")
            
            with Cluster("Required Tools"):
                terraform = Terraform("Terraform CLI")
                awscli = Config("AWS CLI")
                vscode = Custom("VS Code", "./icons/vscode.png")
            
            with Cluster("AWS Configuration"):
                iam = IAM("AWS Credentials")
            
            # Connect components individually
            user >> terraform
            user >> awscli
            user >> vscode
            terraform >> iam
            awscli >> iam
            vscode >> iam

if __name__ == "__main__":
    create_setup_concept_diagram() 