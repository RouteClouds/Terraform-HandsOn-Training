#!/usr/bin/env python3
"""
Topic 9: Terraform State File Structure Diagram
Generates a diagram showing the structure and organization of Terraform state
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.vcs import Github
from diagrams.aws.storage import S3

def create_state_structure_diagram():
    """Create Terraform state file structure diagram"""
    
    with Diagram(
        "Terraform State File Structure",
        filename="state_file_structure",
        direction="TB",
        show=False,
        outformat="png"
    ):
        # Local State
        with Cluster("Local State"):
            current = PostgreSQL("terraform.tfstate\n(Current)")
            backup = PostgreSQL("terraform.tfstate.backup\n(Previous)")
            current >> Edge(label="backup on change") >> backup
        
        # State Contents
        with Cluster("State File Contents"):
            version = Redis("version: 4")
            terraform_version = Redis("terraform_version: 1.0+")
            serial = Redis("serial: 42")
            lineage = Redis("lineage: uuid")
            resources = Redis("resources: [...]")
            
            version >> terraform_version >> serial >> lineage >> resources
        
        # Resource Entry
        with Cluster("Resource Entry"):
            resource_type = Redis("type: aws_instance")
            resource_name = Redis("name: web")
            instances = Redis("instances: [...]")
            attributes = Redis("attributes: {...}")
            
            resource_type >> resource_name >> instances >> attributes
        
        # Remote State
        with Cluster("Remote State (Optional)"):
            s3_state = S3("S3 Bucket\nterraform.tfstate")
            s3_lock = S3("DynamoDB\nState Lock")
            s3_state >> Edge(label="lock") >> s3_lock
        
        # Connections
        current >> Edge(label="contains") >> resources
        resources >> Edge(label="example") >> attributes
        current >> Edge(label="can sync to") >> s3_state
        
        # Version Control
        with Cluster("Version Control"):
            gitignore = Github(".gitignore\n(exclude .tfstate)")
        
        current >> Edge(label="should NOT commit") >> gitignore

if __name__ == "__main__":
    print("Generating Terraform State File Structure diagram...")
    create_state_structure_diagram()
    print("✓ Diagram saved as: state_file_structure.png")

