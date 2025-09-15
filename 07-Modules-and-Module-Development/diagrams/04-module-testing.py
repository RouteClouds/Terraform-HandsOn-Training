#!/usr/bin/env python3
"""
Terraform Module Testing Strategy Diagram
Shows comprehensive testing approaches for Terraform modules
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.generic.compute import Rack
from diagrams.onprem.ci import Jenkins, GithubActions
from diagrams.onprem.container import Docker
from diagrams.onprem.monitoring import Grafana
from diagrams.aws.management import Cloudwatch
from diagrams.aws.security import Inspector
from diagrams.generic.blank import Blank
from diagrams.generic.device import Mobile
from diagrams.onprem.vcs import Git

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
    "Terraform Module Testing Strategy",
    filename="04-module-testing",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr
):
    
    # Module Under Test
    with Cluster("Module Under Test"):
        module_source = Rack("AWS VPC Module")
        
        with Cluster("Module Components"):
            main_tf = Blank("main.tf")
            variables_tf = Blank("variables.tf")
            outputs_tf = Blank("outputs.tf")
            versions_tf = Blank("versions.tf")
    
    # Static Analysis Testing
    with Cluster("Static Analysis Testing"):
        with Cluster("Code Quality"):
            terraform_fmt = Blank("terraform fmt")
            terraform_validate = Blank("terraform validate")
            tflint = Blank("TFLint")
            checkov = Blank("Checkov")
        
        with Cluster("Security Scanning"):
            tfsec = Blank("tfsec")
            terrascan = Blank("Terrascan")
            snyk = Blank("Snyk IaC")
    
    # Unit Testing
    with Cluster("Unit Testing"):
        with Cluster("Terratest Framework"):
            go_tests = Blank("Go Test Files")
            unit_test_1 = Blank("TestVPCCreation")
            unit_test_2 = Blank("TestSubnetConfiguration")
            unit_test_3 = Blank("TestSecurityGroups")
        
        with Cluster("Test Utilities"):
            aws_sdk = Blank("AWS SDK")
            terraform_cli = Rack("Terraform CLI")
    
    # Integration Testing
    with Cluster("Integration Testing"):
        with Cluster("End-to-End Tests"):
            e2e_test_1 = Blank("TestCompleteInfrastructure")
            e2e_test_2 = Blank("TestCrossModuleIntegration")
            e2e_test_3 = Blank("TestDataFlow")
        
        with Cluster("Test Environment"):
            test_aws_account = Cloudwatch("Test AWS Account")
            test_vpc = Blank("Test VPC")
            test_resources = Blank("Test Resources")
    
    # Contract Testing
    with Cluster("Contract Testing"):
        with Cluster("Interface Validation"):
            input_validation = Blank("Input Validation Tests")
            output_validation = Blank("Output Validation Tests")
            api_contract = Blank("API Contract Tests")
        
        with Cluster("Compatibility Testing"):
            version_compat = Blank("Version Compatibility")
            provider_compat = Blank("Provider Compatibility")
            terraform_compat = Blank("Terraform Version Tests")
    
    # Performance Testing
    with Cluster("Performance Testing"):
        with Cluster("Resource Efficiency"):
            deployment_time = Blank("Deployment Time Tests")
            resource_usage = Blank("Resource Usage Tests")
            cost_analysis = Blank("Cost Analysis")
        
        with Cluster("Scale Testing"):
            load_testing = Blank("Load Testing")
            stress_testing = Blank("Stress Testing")
            capacity_testing = Blank("Capacity Testing")
    
    # Compliance Testing
    with Cluster("Compliance Testing"):
        with Cluster("Security Compliance"):
            cis_benchmarks = Blank("CIS Benchmarks")
            aws_config = Blank("AWS Config Rules")
            security_inspector = Inspector("AWS Inspector")
        
        with Cluster("Governance Testing"):
            policy_validation = Blank("Policy Validation")
            tagging_compliance = Blank("Tagging Compliance")
            naming_conventions = Blank("Naming Conventions")
    
    # CI/CD Integration
    with Cluster("CI/CD Pipeline Integration"):
        github_actions = GithubActions("GitHub Actions")
        
        with Cluster("Pipeline Stages"):
            pre_commit = Blank("Pre-commit Hooks")
            pr_validation = Blank("PR Validation")
            automated_testing = Blank("Automated Testing")
            deployment_testing = Blank("Deployment Testing")
    
    # Test Reporting
    with Cluster("Test Reporting & Monitoring"):
        with Cluster("Test Results"):
            test_reports = Blank("Test Reports")
            coverage_reports = Blank("Coverage Reports")
            security_reports = Blank("Security Reports")
        
        with Cluster("Monitoring"):
            test_metrics = Grafana("Test Metrics")
            quality_gates = Blank("Quality Gates")
    
    # Module Flow
    module_source >> [main_tf, variables_tf, outputs_tf, versions_tf]
    
    # Static Analysis Flow
    module_source >> Edge(label="analyze", style="dashed") >> [terraform_fmt, terraform_validate, tflint, checkov]
    module_source >> Edge(label="scan", style="dashed") >> [tfsec, terrascan, snyk]
    
    # Unit Testing Flow
    module_source >> Edge(label="test", style="bold") >> go_tests
    go_tests >> [unit_test_1, unit_test_2, unit_test_3]
    unit_test_1 >> aws_sdk
    unit_test_2 >> terraform_cli
    unit_test_3 >> aws_sdk
    
    # Integration Testing Flow
    module_source >> Edge(label="deploy", style="bold") >> test_aws_account
    test_aws_account >> [test_vpc, test_resources]
    [e2e_test_1, e2e_test_2, e2e_test_3] >> test_aws_account
    
    # Contract Testing Flow
    module_source >> Edge(label="validate", style="dotted") >> [input_validation, output_validation, api_contract]
    [version_compat, provider_compat, terraform_compat] >> module_source
    
    # Performance Testing Flow
    test_aws_account >> [deployment_time, resource_usage, cost_analysis]
    [load_testing, stress_testing, capacity_testing] >> test_aws_account
    
    # Compliance Testing Flow
    test_aws_account >> [cis_benchmarks, aws_config, security_inspector]
    [policy_validation, tagging_compliance, naming_conventions] >> module_source
    
    # CI/CD Flow
    github_actions >> [pre_commit, pr_validation, automated_testing, deployment_testing]
    [terraform_fmt, go_tests, e2e_test_1] >> github_actions
    
    # Reporting Flow
    github_actions >> [test_reports, coverage_reports, security_reports]
    [test_reports, coverage_reports, security_reports] >> test_metrics
    test_metrics >> quality_gates

print("✅ Module Testing Strategy diagram generated successfully!")
print("📁 Output: 04-module-testing.png")
print("🎯 Shows: Comprehensive testing approaches for Terraform modules")
