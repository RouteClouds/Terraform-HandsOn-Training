#!/usr/bin/env python3
"""
Topic 10: Terraform Validation Pipeline Diagram
Generates a diagram showing the validation pipeline stages
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.onprem.ci import GitlabCI
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.security import Vault

def create_validation_pipeline_diagram():
    """Create Terraform validation pipeline diagram"""
    
    with Diagram(
        "Terraform Validation Pipeline",
        filename="validation_pipeline",
        direction="TB",
        show=False,
        outformat="png"
    ):
        # Stage 1: Syntax Validation
        with Cluster("Stage 1: Syntax Validation"):
            validate = Terraform("terraform validate")
            fmt_check = Terraform("terraform fmt -check")
            syntax = Terraform("Check Syntax")
            validate >> fmt_check >> syntax
        
        # Stage 2: Linting
        with Cluster("Stage 2: Linting"):
            tflint = Terraform("tflint")
            style = Terraform("Check Style")
            tflint >> style
        
        # Stage 3: Security Scanning
        with Cluster("Stage 3: Security Scanning"):
            tfsec = Terraform("tfsec")
            checkov = Terraform("Checkov")
            security = Terraform("Scan Security")
            tfsec >> checkov >> security
        
        # Stage 4: Policy Enforcement
        with Cluster("Stage 4: Policy Enforcement"):
            sentinel = Terraform("Sentinel Policies")
            opa = Terraform("OPA Policies")
            policy = Terraform("Enforce Policies")
            sentinel >> opa >> policy
        
        # Stage 5: Testing
        with Cluster("Stage 5: Testing"):
            unit = Terraform("Unit Tests")
            integration = Terraform("Integration Tests")
            testing = Terraform("Run Tests")
            unit >> integration >> testing
        
        # Results
        with Cluster("Results"):
            pass_result = Redis("PASS")
            fail_result = Redis("FAIL")
        
        # Pipeline flow
        syntax >> Edge(label="pass") >> tflint
        style >> Edge(label="pass") >> tfsec
        security >> Edge(label="pass") >> sentinel
        policy >> Edge(label="pass") >> unit
        testing >> Edge(label="pass") >> pass_result
        
        # Failure paths
        syntax >> Edge(label="fail", color="red") >> fail_result
        style >> Edge(label="fail", color="red") >> fail_result
        security >> Edge(label="fail", color="red") >> fail_result
        policy >> Edge(label="fail", color="red") >> fail_result
        testing >> Edge(label="fail", color="red") >> fail_result

if __name__ == "__main__":
    print("Generating Terraform Validation Pipeline diagram...")
    create_validation_pipeline_diagram()
    print("✓ Diagram saved as: validation_pipeline.png")

