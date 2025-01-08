from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform
from diagrams.aws.management import Config
from diagrams.aws.security import IAM
from diagrams.onprem.client import Users
from diagrams.programming.language import Python
from diagrams.aws.general import General

def create_setup_concept_diagram():
    # Set graph attributes for better layout
    graph_attr = {
        "pad": "1.5",
        "splines": "ortho",
        "nodesep": "1.0",
        "rankdir": "LR"
    }
    
    with Diagram("Terraform Setup Concepts", show=True, filename="terraform_setup_concepts", graph_attr=graph_attr, outformat="png"):
        with Cluster("Development Environment"):
            developer = Users("Developer")
            
            with Cluster("Core Tools"):
                terraform = Terraform("Terraform CLI")
                awscli = Config("AWS CLI")
            
            with Cluster("AWS Account"):
                credentials = IAM("AWS Credentials")
            
            # Create logical flow
            developer >> [terraform, awscli]
            terraform >> credentials
            awscli >> credentials

if __name__ == "__main__":
    create_setup_concept_diagram()
