#!/usr/bin/env python3
"""
Terraform Module Lifecycle Management Diagram
Shows the complete lifecycle of module development, testing, and deployment
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.vcs import Git, Github
from diagrams.onprem.ci import Jenkins, GithubActions
from diagrams.onprem.container import Docker
from diagrams.aws.storage import S3
from diagrams.aws.management import Cloudwatch
from diagrams.generic.compute import Rack
from diagrams.generic.device import Mobile
from diagrams.generic.blank import Blank
from diagrams.onprem.monitoring import Grafana
from diagrams.onprem.security import Vault

# Configure diagram settings
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "dpi": "300",
    "margin": "0.5",
    "rankdir": "LR",
    "splines": "ortho"
}

node_attr = {
    "fontsize": "12",
    "fontname": "Arial",
    "margin": "0.1"
}

edge_attr = {
    "fontsize": "10",
    "fontname": "Arial"
}

with Diagram(
    "Terraform Module Lifecycle Management",
    filename="02-module-lifecycle",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr
):
    
    # Development Phase
    with Cluster("Development Phase"):
        developer = Mobile("Developer")
        
        with Cluster("Local Development"):
            local_git = Git("Local Git")
            terraform_dev = Rack("Terraform CLI")
            docker_dev = Docker("Local Testing")
    
    # Version Control
    with Cluster("Version Control"):
        github_repo = Github("GitHub Repository")
        
        with Cluster("Branch Strategy"):
            main_branch = Git("main")
            feature_branch = Git("feature/*")
            release_branch = Git("release/*")
    
    # CI/CD Pipeline
    with Cluster("CI/CD Pipeline"):
        github_actions = GithubActions("GitHub Actions")
        
        with Cluster("Pipeline Stages"):
            lint_stage = Blank("Lint & Format")
            validate_stage = Blank("Validate")
            test_stage = Blank("Test")
            security_stage = Blank("Security Scan")
            build_stage = Blank("Build")
            deploy_stage = Blank("Deploy")
    
    # Testing Environment
    with Cluster("Testing Infrastructure"):
        with Cluster("Automated Testing"):
            unit_tests = Rack("Unit Tests")
            integration_tests = Rack("Integration Tests")
            compliance_tests = Rack("Compliance Tests")

        test_aws = Cloudwatch("Test AWS Account")
    
    # Module Registry
    with Cluster("Module Registry"):
        with Cluster("Terraform Registry"):
            public_registry = Rack("Public Registry")
            private_registry = Rack("Private Registry")
        
        with Cluster("Artifact Storage"):
            s3_artifacts = S3("Module Artifacts")
            vault_secrets = Vault("Secrets Management")
    
    # Deployment Environments
    with Cluster("Deployment Environments"):
        with Cluster("Development"):
            dev_terraform = Rack("Dev Deployment")
            dev_aws = Cloudwatch("Dev AWS")

        with Cluster("Staging"):
            staging_terraform = Rack("Staging Deployment")
            staging_aws = Cloudwatch("Staging AWS")

        with Cluster("Production"):
            prod_terraform = Rack("Prod Deployment")
            prod_aws = Cloudwatch("Prod AWS")
    
    # Monitoring and Feedback
    with Cluster("Monitoring & Feedback"):
        monitoring = Grafana("Module Monitoring")
        feedback_loop = Blank("Feedback Loop")
    
    # Development Flow
    developer >> local_git
    local_git >> terraform_dev
    terraform_dev >> docker_dev
    
    # Version Control Flow
    local_git >> Edge(label="push", style="bold") >> github_repo
    github_repo >> [main_branch, feature_branch, release_branch]
    
    # CI/CD Flow
    github_repo >> Edge(label="trigger", style="bold") >> github_actions
    github_actions >> lint_stage >> validate_stage >> test_stage >> security_stage >> build_stage >> deploy_stage
    
    # Testing Flow
    test_stage >> [unit_tests, integration_tests, compliance_tests]
    [unit_tests, integration_tests, compliance_tests] >> test_aws
    
    # Registry Flow
    build_stage >> Edge(label="publish", style="bold") >> [public_registry, private_registry]
    build_stage >> s3_artifacts
    security_stage >> vault_secrets
    
    # Deployment Flow
    private_registry >> Edge(label="v1.0.0", style="dashed") >> dev_terraform
    private_registry >> Edge(label="v1.0.0", style="dashed") >> staging_terraform
    private_registry >> Edge(label="v1.0.0", style="dashed") >> prod_terraform
    
    dev_terraform >> dev_aws
    staging_terraform >> staging_aws
    prod_terraform >> prod_aws
    
    # Monitoring Flow
    [dev_aws, staging_aws, prod_aws] >> monitoring
    monitoring >> feedback_loop >> developer
    
    # Version Progression
    feature_branch >> Edge(label="PR", style="dotted") >> main_branch
    main_branch >> Edge(label="tag", style="dotted") >> release_branch

print("✅ Module Lifecycle diagram generated successfully!")
print("📁 Output: 02-module-lifecycle.png")
print("🎯 Shows: Complete module development and deployment lifecycle")
