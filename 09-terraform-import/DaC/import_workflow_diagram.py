#!/usr/bin/env python3
"""
Topic 9: Terraform Import Workflow Diagram
Generates a professional diagram showing the Terraform import workflow
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import SecurityGroup
from diagrams.onprem.iac import Terraform
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.vcs import Github

def create_import_workflow_diagram():
    """Create Terraform import workflow diagram"""
    
    with Diagram(
        "Terraform Import Workflow",
        filename="import_workflow",
        direction="LR",
        show=False,
        outformat="png"
    ):
        # Existing Infrastructure
        with Cluster("Existing AWS Infrastructure"):
            existing_ec2 = EC2("EC2 Instance\n(i-1234567890)")
            existing_sg = SecurityGroup("Security Group\n(sg-12345678)")
            existing_ec2 >> existing_sg
        
        # Terraform Configuration
        with Cluster("Terraform Configuration"):
            tf_config = Terraform("main.tf\nresource definitions")
            tf_init = Terraform("terraform init")
            tf_config >> tf_init
        
        # Import Process
        with Cluster("Import Process"):
            import_cmd = Terraform("terraform import\naws_instance.web\ni-1234567890")
            state_file = PostgreSQL("terraform.tfstate")
            import_cmd >> state_file
        
        # Verification
        with Cluster("Verification"):
            plan = Terraform("terraform plan")
            verify = Terraform("Verify:\nNo Changes")
            plan >> verify
        
        # Workflow connections
        existing_ec2 >> Edge(label="Resource ID") >> import_cmd
        tf_init >> Edge(label="Configuration") >> import_cmd
        state_file >> Edge(label="State") >> plan
        
        # Version Control
        with Cluster("Version Control"):
            github = Github("Git Repository")
        
        verify >> Edge(label="Commit") >> github

if __name__ == "__main__":
    print("Generating Terraform Import Workflow diagram...")
    create_import_workflow_diagram()
    print("✓ Diagram saved as: import_workflow.png")

