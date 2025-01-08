#!/usr/bin/env python3

from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform  # Correct import path
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb
from diagrams.aws.general import General

def create_state_concept_diagram():
    graph_attr = {
        "pad": "1.5",
        "splines": "ortho",
        "nodesep": "1.0",
        "rankdir": "LR"
    }
    
    with Diagram(
        "Terraform State Management Concepts",
        show=True,
        filename="terraform_state_concepts",
        graph_attr=graph_attr,
        outformat="png"
    ):
        with Cluster("Terraform Configuration"):
            tf = Terraform("Terraform")
            
            with Cluster("State Backend"):
                s3 = S3("Remote State")
                dynamo = Dynamodb("State Locking")
            
            with Cluster("State Operations"):
                state_ops = General("State Management")
                
            # Define relationships
            tf >> s3
            tf >> dynamo
            tf >> state_ops

if __name__ == "__main__":
    try:
        create_state_concept_diagram()
        print("Diagram created successfully!")
    except Exception as e:
        print(f"Error creating diagram: {str(e)}") 