#!/usr/bin/env python3
"""
Topic 10: Terraform Testing Workflow Diagram
Generates a professional diagram showing the Terraform testing workflow
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GitlabCI
from diagrams.onprem.inmemory import Redis
from diagrams.aws.compute import EC2

def create_testing_workflow_diagram():
    """Create Terraform testing workflow diagram"""
    
    with Diagram(
        "Terraform Testing Workflow",
        filename="testing_workflow",
        direction="LR",
        show=False,
        outformat="png"
    ):
        # Development Phase
        with Cluster("Development"):
            code = Terraform("Write Terraform Code")
            validate = Terraform("terraform validate")
            fmt = Terraform("terraform fmt")
            code >> validate >> fmt
        
        # Pre-commit Phase
        with Cluster("Pre-commit Hooks"):
            precommit = Terraform("Pre-commit Hooks")
            fmt_hook = Terraform("terraform_fmt")
            validate_hook = Terraform("terraform_validate")
            tflint = Terraform("tflint")
            precommit >> fmt_hook >> validate_hook >> tflint
        
        # Version Control
        with Cluster("Version Control"):
            github = Github("Git Repository")
        
        # CI/CD Pipeline
        with Cluster("CI/CD Pipeline"):
            ci = GitlabCI("CI/CD Pipeline")
            security = Terraform("Security Scan")
            test = Terraform("Run Tests")
            ci >> security >> test
        
        # Testing Phase
        with Cluster("Testing"):
            unit = Terraform("Unit Tests")
            integration = Terraform("Integration Tests")
            compliance = Terraform("Compliance Tests")
            unit >> integration >> compliance
        
        # Deployment
        with Cluster("Deployment"):
            deploy = Terraform("terraform apply")
            verify = Terraform("Verify Resources")
            deploy >> verify
        
        # Connections
        fmt >> Edge(label="commit") >> github
        github >> Edge(label="trigger") >> ci
        ci >> Edge(label="run") >> unit
        compliance >> Edge(label="success") >> deploy
        
        # AWS Resources
        with Cluster("AWS"):
            ec2 = EC2("EC2 Instances")
        
        verify >> Edge(label="create") >> ec2

if __name__ == "__main__":
    print("Generating Terraform Testing Workflow diagram...")
    create_testing_workflow_diagram()
    print("✓ Diagram saved as: testing_workflow.png")

