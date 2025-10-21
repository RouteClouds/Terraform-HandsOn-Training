#!/usr/bin/env python3
"""
Topic 12: Secrets Management Diagram
Generates a diagram showing secrets management architecture
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.aws.security import SecretsManager, KMS
from diagrams.aws.database import RDS
from diagrams.aws.compute import EC2

def create_secrets_management_diagram():
    """Create secrets management diagram"""
    
    with Diagram(
        "Secrets Management Architecture",
        filename="secrets_management",
        direction="LR",
        show=False,
        outformat="png"
    ):
        # Terraform
        with Cluster("Terraform"):
            tf_code = Terraform("Terraform Code")
            sensitive_var = Terraform("Sensitive Variables")
            tf_code >> sensitive_var
        
        # Secrets Management
        with Cluster("Secrets Management"):
            secrets_mgr = SecretsManager("AWS Secrets Manager")
            kms = KMS("KMS Encryption")
            secrets_mgr >> Edge(label="encrypt") >> kms
        
        # Application
        with Cluster("Application"):
            app = EC2("Application")
            db = RDS("Database")
            app >> Edge(label="connect") >> db
        
        # Connections
        sensitive_var >> Edge(label="reference") >> secrets_mgr
        secrets_mgr >> Edge(label="provide") >> app
        kms >> Edge(label="decrypt") >> app

if __name__ == "__main__":
    print("Generating Secrets Management diagram...")
    create_secrets_management_diagram()
    print("✓ Diagram saved as: secrets_management.png")

