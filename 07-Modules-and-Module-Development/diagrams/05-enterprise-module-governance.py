#!/usr/bin/env python3
"""
Enterprise Module Governance and Distribution Diagram
Shows enterprise-scale module governance, distribution, and compliance patterns
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.generic.compute import Rack
from diagrams.onprem.vcs import Github
from diagrams.onprem.security import Vault
from diagrams.aws.management import Organizations, Cloudwatch
from diagrams.aws.security import IAM, SecurityHub
from diagrams.aws.storage import S3
from diagrams.aws.compute import Lambda
from diagrams.aws.integration import SQS, SNS
from diagrams.onprem.monitoring import Grafana
from diagrams.generic.blank import Blank
from diagrams.generic.device import Mobile
from diagrams.onprem.ci import GithubActions

# Configure diagram settings
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "dpi": "300",
    "margin": "0.5",
    "rankdir": "TB",
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
    "Enterprise Module Governance & Distribution",
    filename="05-enterprise-module-governance",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr
):
    
    # Governance Layer
    with Cluster("Enterprise Governance Layer"):
        with Cluster("Policy Management"):
            governance_board = Mobile("Architecture Review Board")
            policy_engine = Blank("Policy Engine")
            compliance_framework = Blank("Compliance Framework")
        
        with Cluster("Standards & Guidelines"):
            module_standards = Blank("Module Standards")
            security_policies = Blank("Security Policies")
            naming_conventions = Blank("Naming Conventions")
            tagging_strategy = Blank("Tagging Strategy")
    
    # Module Registry & Distribution
    with Cluster("Module Registry & Distribution"):
        with Cluster("Private Module Registry"):
            terraform_registry = Rack("Private Terraform Registry")
            module_catalog = Blank("Module Catalog")
            version_management = Blank("Version Management")
        
        with Cluster("Artifact Storage"):
            s3_registry = S3("Module Artifacts")
            vault_secrets = Vault("Secrets & Credentials")
        
        with Cluster("Distribution Control"):
            access_control = IAM("Access Control")
            approval_workflow = Blank("Approval Workflow")
            release_gates = Blank("Release Gates")
    
    # Module Development Centers
    with Cluster("Module Development Centers"):
        with Cluster("Platform Team"):
            platform_devs = Mobile("Platform Engineers")
            core_modules = Rack("Core Infrastructure Modules")

            with Cluster("Core Module Types"):
                networking_module = Blank("Networking")
                security_module = Blank("Security")
                compute_module = Blank("Compute")
                data_module = Blank("Data")

        with Cluster("Application Teams"):
            app_teams = Mobile("Application Teams")
            app_modules = Rack("Application-Specific Modules")
            
            with Cluster("App Module Types"):
                web_app_module = Blank("Web Applications")
                api_module = Blank("API Services")
                batch_module = Blank("Batch Processing")
    
    # Quality Assurance
    with Cluster("Quality Assurance & Compliance"):
        with Cluster("Automated Testing"):
            ci_pipeline = GithubActions("CI/CD Pipeline")
            security_scanning = Blank("Security Scanning")
            compliance_testing = Blank("Compliance Testing")
            performance_testing = Blank("Performance Testing")
        
        with Cluster("Manual Review"):
            code_review = Blank("Code Review")
            architecture_review = Blank("Architecture Review")
            security_review = Blank("Security Review")
        
        with Cluster("Compliance Monitoring"):
            security_hub = SecurityHub("AWS Security Hub")
            compliance_dashboard = Grafana("Compliance Dashboard")
            audit_trail = Blank("Audit Trail")
    
    # Multi-Account Distribution
    with Cluster("Multi-Account Distribution"):
        with Cluster("AWS Organization"):
            aws_org = Organizations("AWS Organizations")
            
            with Cluster("Account Types"):
                shared_services = Cloudwatch("Shared Services")
                dev_accounts = Cloudwatch("Development Accounts")
                staging_accounts = Cloudwatch("Staging Accounts")
                prod_accounts = Cloudwatch("Production Accounts")
        
        with Cluster("Cross-Account Access"):
            cross_account_roles = IAM("Cross-Account Roles")
            assume_role_policy = Blank("Assume Role Policies")
    
    # Consumption & Usage
    with Cluster("Module Consumption & Usage"):
        with Cluster("Consumer Teams"):
            dev_teams = Mobile("Development Teams")
            ops_teams = Mobile("Operations Teams")
            security_teams = Mobile("Security Teams")
        
        with Cluster("Usage Patterns"):
            direct_usage = Rack("Direct Module Usage")
            wrapper_modules = Rack("Wrapper Modules")
            template_usage = Rack("Template Usage")
        
        with Cluster("Self-Service Portal"):
            module_portal = Blank("Module Portal")
            documentation = Blank("Documentation")
            examples = Blank("Usage Examples")
    
    # Monitoring & Feedback
    with Cluster("Monitoring & Feedback Loop"):
        with Cluster("Usage Analytics"):
            usage_metrics = Grafana("Usage Metrics")
            adoption_tracking = Blank("Adoption Tracking")
            performance_metrics = Blank("Performance Metrics")
        
        with Cluster("Feedback Mechanisms"):
            feedback_queue = SQS("Feedback Queue")
            issue_tracking = Blank("Issue Tracking")
            feature_requests = Blank("Feature Requests")
        
        with Cluster("Notifications"):
            sns_notifications = SNS("Notifications")
            alert_system = Blank("Alert System")
    
    # Governance Flow
    governance_board >> [policy_engine, compliance_framework]
    policy_engine >> [module_standards, security_policies, naming_conventions, tagging_strategy]
    
    # Development Flow
    platform_devs >> core_modules
    core_modules >> [networking_module, security_module, compute_module, data_module]
    app_teams >> app_modules
    app_modules >> [web_app_module, api_module, batch_module]
    
    # Quality Assurance Flow
    [core_modules, app_modules] >> ci_pipeline
    ci_pipeline >> [security_scanning, compliance_testing, performance_testing]
    ci_pipeline >> [code_review, architecture_review, security_review]
    
    # Registry Flow
    [core_modules, app_modules] >> Edge(label="publish", style="bold") >> terraform_registry
    terraform_registry >> [module_catalog, version_management]
    terraform_registry >> s3_registry
    access_control >> [approval_workflow, release_gates]
    
    # Distribution Flow
    terraform_registry >> Edge(label="distribute", style="bold") >> aws_org
    aws_org >> [shared_services, dev_accounts, staging_accounts, prod_accounts]
    cross_account_roles >> assume_role_policy
    
    # Consumption Flow
    [dev_teams, ops_teams, security_teams] >> module_portal
    module_portal >> [documentation, examples]
    terraform_registry >> [direct_usage, wrapper_modules, template_usage]
    
    # Monitoring Flow
    [direct_usage, wrapper_modules, template_usage] >> usage_metrics
    usage_metrics >> [adoption_tracking, performance_metrics]
    
    # Feedback Flow
    [dev_teams, ops_teams, security_teams] >> feedback_queue
    feedback_queue >> [issue_tracking, feature_requests]
    [issue_tracking, feature_requests] >> platform_devs
    
    # Compliance Flow
    [shared_services, dev_accounts, staging_accounts, prod_accounts] >> security_hub
    security_hub >> compliance_dashboard
    compliance_dashboard >> audit_trail
    
    # Notification Flow
    [usage_metrics, compliance_dashboard, feedback_queue] >> sns_notifications
    sns_notifications >> alert_system

print("✅ Enterprise Module Governance diagram generated successfully!")
print("📁 Output: 05-enterprise-module-governance.png")
print("🎯 Shows: Enterprise-scale module governance, distribution, and compliance")
