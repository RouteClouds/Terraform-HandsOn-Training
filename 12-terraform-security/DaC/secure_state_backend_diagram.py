#!/usr/bin/env python3
"""
Topic 12: Secure State Backend Diagram
Generates a diagram showing secure state backend configuration
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb
from diagrams.aws.security import KMS
from diagrams.aws.management import CloudTrail

def create_secure_state_backend_diagram():
    """Create secure state backend diagram"""
    
    with Diagram(
        "Secure State Backend",
        filename="secure_state_backend",
        direction="LR",
        show=False,
        outformat="png"
    ):
        # Terraform
        with Cluster("Terraform"):
            tf = Terraform("terraform apply")
        
        # State Storage
        with Cluster("State Storage"):
            s3 = S3("S3 Bucket\n(State File)")
            encryption = KMS("KMS Encryption")
            versioning = S3("Versioning\nEnabled")
            s3 >> encryption
            s3 >> versioning
        
        # State Locking
        with Cluster("State Locking"):
            dynamodb = Dynamodb("DynamoDB\nLock Table")
        
        # Audit & Monitoring
        with Cluster("Audit & Monitoring"):
            cloudtrail = CloudTrail("CloudTrail\nLogging")
        
        # Connections
        tf >> Edge(label="write state") >> s3
        tf >> Edge(label="acquire lock") >> dynamodb
        s3 >> Edge(label="audit") >> cloudtrail
        dynamodb >> Edge(label="audit") >> cloudtrail

if __name__ == "__main__":
    print("Generating Secure State Backend diagram...")
    create_secure_state_backend_diagram()
    print("✓ Diagram saved as: secure_state_backend.png")

