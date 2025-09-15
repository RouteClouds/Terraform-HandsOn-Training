#!/usr/bin/env python3
"""
Professional Diagram Generation Script for Topic 7: Modules and Module Development

This script generates 5 high-quality architectural diagrams using Python and the diagrams library.
All diagrams follow AWS brand guidelines and are optimized for 300 DPI resolution.

Author: AWS Terraform Training Team
Version: 2.0
Date: January 2025
"""

import os
import sys
from pathlib import Path

# Import required libraries
try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.aws.compute import EC2, AutoScaling, ECS
    from diagrams.aws.database import RDS, DynamodbTable
    from diagrams.aws.network import VPC, PrivateSubnet, PublicSubnet, ELB, ALB
    from diagrams.aws.security import IAM, KMS
    from diagrams.generic.network import Firewall as SecurityGroup
    from diagrams.aws.storage import S3
    from diagrams.aws.management import Cloudwatch as CloudWatch, Organizations
    from diagrams.aws.integration import SNS
    from diagrams.onprem.iac import Terraform
    from diagrams.programming.language import Python
    from diagrams.generic.blank import Blank
    from diagrams.generic.database import SQL
    from diagrams.generic.network import Firewall
    from diagrams.generic.storage import Storage
    from diagrams.onprem.vcs import Git
    from diagrams.onprem.ci import Jenkins
    from diagrams.onprem.client import Users as LocalUsers
    from diagrams.onprem.monitoring import Grafana
    from diagrams.programming.framework import React
except ImportError as e:
    print(f"❌ Error importing diagram libraries: {e}")
    print("Please install required dependencies: pip install -r requirements.txt")
    sys.exit(1)

# AWS Brand Colors (Official AWS Color Palette)
COLORS = {
    'primary': '#FF9900',      # AWS Orange
    'secondary': '#232F3E',    # AWS Dark Blue
    'accent': '#146EB4',       # AWS Blue
    'success': '#7AA116',      # AWS Green
    'warning': '#FF9900',      # AWS Orange
    'background': '#F2F3F3',   # Light Gray
    'text': '#232F3E',         # Dark Blue
    'module': '#4B9CD3',       # Module Blue
    'composition': '#8B5A3C'   # Composition Brown
}

# Configuration for high-quality output
DIAGRAM_CONFIG = {
    'direction': 'TB',  # Top to Bottom
    'graph_attr': {
        'fontsize': '16',
        'fontname': 'Arial',
        'bgcolor': COLORS['background'],
        'pad': '1.0',
        'nodesep': '1.0',
        'ranksep': '1.5',
        'dpi': '300'  # High resolution for professional quality
    },
    'node_attr': {
        'fontsize': '12',
        'fontname': 'Arial',
        'style': 'rounded,filled',
        'fillcolor': 'white',
        'color': COLORS['secondary']
    },
    'edge_attr': {
        'fontsize': '10',
        'fontname': 'Arial',
        'color': COLORS['accent']
    }
}

def ensure_output_directory():
    """Create output directory if it doesn't exist"""
    output_dir = Path("generated_diagrams")
    output_dir.mkdir(exist_ok=True)
    return output_dir

def create_module_architecture_patterns():
    """
    Figure 7.1: Terraform Module Architecture and Composition Patterns
    
    This diagram demonstrates enterprise module architecture with composition
    patterns, reusability strategies, and organizational structures.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 7.1: Terraform Module Architecture and Composition Patterns",
        filename=str(output_dir / "figure_7_1_module_architecture"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        # Module Registry and Sources
        with Cluster("Module Registry and Sources"):
            # Public Registry
            with Cluster("Public Registry"):
                terraform_registry = Storage("Terraform Registry")
                aws_modules = Storage("AWS Modules")
                community_modules = Storage("Community Modules")
                
            # Private Registry
            with Cluster("Private Registry"):
                enterprise_registry = Storage("Enterprise Registry")
                company_modules = Storage("Company Modules")
                team_modules = Storage("Team Modules")
                
            # Version Control
            with Cluster("Version Control"):
                git_repository = Git("Git Repository")
                module_versioning = Storage("Module Versioning")
                release_management = Storage("Release Management")
        
        # Module Development Layer
        with Cluster("Module Development Layer"):
            # Core Modules
            with Cluster("Core Infrastructure Modules"):
                vpc_module = Storage("VPC Module")
                security_module = Storage("Security Module")
                compute_module = Storage("Compute Module")
                storage_module = Storage("Storage Module")
                
            # Application Modules
            with Cluster("Application Modules"):
                web_app_module = Storage("Web App Module")
                database_module = Storage("Database Module")
                monitoring_module = Storage("Monitoring Module")
                
            # Composite Modules
            with Cluster("Composite Modules"):
                full_stack_module = Storage("Full Stack Module")
                microservice_module = Storage("Microservice Module")
                platform_module = Storage("Platform Module")
        
        # Module Composition Layer
        with Cluster("Module Composition Layer"):
            # Environment Compositions
            with Cluster("Environment Compositions"):
                dev_composition = Terraform("Development")
                staging_composition = Terraform("Staging")
                prod_composition = Terraform("Production")
                
            # Application Compositions
            with Cluster("Application Compositions"):
                frontend_composition = React("Frontend Stack")
                backend_composition = Storage("Backend Stack")
                data_composition = SQL("Data Stack")
                
            # Cross-Cutting Compositions
            with Cluster("Cross-Cutting Compositions"):
                security_composition = SecurityGroup("Security Stack")
                monitoring_composition = CloudWatch("Monitoring Stack")
                networking_composition = VPC("Networking Stack")
        
        # Infrastructure Deployment
        with Cluster("Infrastructure Deployment"):
            # AWS Services
            with Cluster("AWS Services"):
                # Compute Services
                with Cluster("Compute Services"):
                    ec2_instances = EC2("EC2 Instances")
                    auto_scaling = AutoScaling("Auto Scaling")
                    ecs_services = ECS("ECS Services")
                
                # Network Services
                with Cluster("Network Services"):
                    vpc_resources = VPC("VPC Resources")
                    load_balancers = ALB("Load Balancers")
                    security_groups = SecurityGroup("Security Groups")
                
                # Storage Services
                with Cluster("Storage Services"):
                    s3_buckets = S3("S3 Buckets")
                    rds_databases = RDS("RDS Databases")
                    dynamodb_tables = DynamodbTable("DynamoDB Tables")
        
        # Module Flow and Dependencies
        # Registry to Development
        terraform_registry >> Edge(label="public modules", color=COLORS['primary']) >> vpc_module
        enterprise_registry >> Edge(label="private modules", color=COLORS['accent']) >> security_module
        git_repository >> Edge(label="source control", color=COLORS['success']) >> [vpc_module, security_module]
        
        # Module Composition
        vpc_module >> Edge(label="composes", color=COLORS['module']) >> networking_composition
        security_module >> Edge(label="composes", color=COLORS['module']) >> security_composition
        compute_module >> Edge(label="composes", color=COLORS['module']) >> backend_composition
        
        # Environment Deployment
        dev_composition >> Edge(label="deploys", color=COLORS['success']) >> ec2_instances
        staging_composition >> Edge(label="deploys", color=COLORS['warning']) >> auto_scaling
        prod_composition >> Edge(label="deploys", color=COLORS['primary']) >> ecs_services
        
        # Infrastructure Integration
        networking_composition >> vpc_resources
        security_composition >> security_groups
        backend_composition >> [s3_buckets, rds_databases]
        
        # Version Management
        module_versioning >> [vpc_module, security_module, compute_module]
        release_management >> [dev_composition, staging_composition, prod_composition]

def create_module_development_lifecycle():
    """
    Figure 7.2: Module Development Lifecycle and Best Practices
    
    This diagram shows the complete module development lifecycle including
    design, development, testing, publishing, and maintenance phases.
    """
    output_dir = ensure_output_directory()
    
    with Diagram(
        "Figure 7.2: Module Development Lifecycle and Best Practices",
        filename=str(output_dir / "figure_7_2_development_lifecycle"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):
        
        # Planning and Design Phase
        with Cluster("Planning and Design Phase"):
            # Requirements Analysis
            with Cluster("Requirements Analysis"):
                business_requirements = Storage("Business Requirements")
                technical_requirements = Storage("Technical Requirements")
                compliance_requirements = Storage("Compliance Requirements")
                
            # Architecture Design
            with Cluster("Architecture Design"):
                module_design = Storage("Module Design")
                interface_design = Storage("Interface Design")
                dependency_analysis = Storage("Dependency Analysis")
                
            # Documentation Planning
            with Cluster("Documentation Planning"):
                api_documentation = Storage("API Documentation")
                usage_examples = Storage("Usage Examples")
                best_practices = Storage("Best Practices")
        
        # Development Phase
        with Cluster("Development Phase"):
            # Code Development
            with Cluster("Code Development"):
                terraform_code = Terraform("Terraform Code")
                variable_definitions = Storage("Variable Definitions")
                output_definitions = Storage("Output Definitions")
                
            # Validation and Testing
            with Cluster("Validation and Testing"):
                syntax_validation = Storage("Syntax Validation")
                unit_testing = Python("Unit Testing")
                integration_testing = Storage("Integration Testing")
                
            # Security and Compliance
            with Cluster("Security and Compliance"):
                security_scanning = Storage("Security Scanning")
                compliance_checking = Storage("Compliance Checking")
                vulnerability_assessment = Storage("Vulnerability Assessment")
        
        # Quality Assurance Phase
        with Cluster("Quality Assurance Phase"):
            # Code Review
            with Cluster("Code Review"):
                peer_review = LocalUsers("Peer Review")
                architecture_review = Storage("Architecture Review")
                security_review = Storage("Security Review")
                
            # Automated Testing
            with Cluster("Automated Testing"):
                ci_pipeline = Jenkins("CI Pipeline")
                automated_tests = Storage("Automated Tests")
                performance_tests = Storage("Performance Tests")
                
            # Documentation Review
            with Cluster("Documentation Review"):
                doc_validation = Storage("Documentation Validation")
                example_testing = Storage("Example Testing")
                readme_review = Storage("README Review")
        
        # Publishing and Distribution
        with Cluster("Publishing and Distribution"):
            # Version Management
            with Cluster("Version Management"):
                semantic_versioning = Storage("Semantic Versioning")
                changelog_generation = Storage("Changelog Generation")
                release_tagging = Git("Release Tagging")
                
            # Registry Publishing
            with Cluster("Registry Publishing"):
                terraform_registry_publish = Storage("Terraform Registry")
                private_registry_publish = Storage("Private Registry")
                artifact_storage = Storage("Artifact Storage")
                
            # Distribution Channels
            with Cluster("Distribution Channels"):
                public_distribution = Storage("Public Distribution")
                enterprise_distribution = Storage("Enterprise Distribution")
                team_distribution = Storage("Team Distribution")
        
        # Maintenance and Evolution
        with Cluster("Maintenance and Evolution"):
            # Monitoring and Feedback
            with Cluster("Monitoring and Feedback"):
                usage_analytics = Grafana("Usage Analytics")
                user_feedback = Storage("User Feedback")
                issue_tracking = Storage("Issue Tracking")
                
            # Updates and Patches
            with Cluster("Updates and Patches"):
                bug_fixes = Storage("Bug Fixes")
                feature_updates = Storage("Feature Updates")
                security_patches = Storage("Security Patches")
                
            # Lifecycle Management
            with Cluster("Lifecycle Management"):
                deprecation_planning = Storage("Deprecation Planning")
                migration_support = Storage("Migration Support")
                end_of_life = Storage("End of Life")
        
        # Development Flow
        # Planning to Development
        business_requirements >> module_design >> terraform_code
        technical_requirements >> interface_design >> variable_definitions
        compliance_requirements >> dependency_analysis >> output_definitions
        
        # Development to QA
        terraform_code >> syntax_validation >> peer_review
        unit_testing >> integration_testing >> ci_pipeline
        security_scanning >> compliance_checking >> security_review
        
        # QA to Publishing
        peer_review >> semantic_versioning >> terraform_registry_publish
        ci_pipeline >> automated_tests >> release_tagging
        doc_validation >> changelog_generation >> public_distribution
        
        # Publishing to Maintenance
        terraform_registry_publish >> usage_analytics >> user_feedback
        public_distribution >> issue_tracking >> bug_fixes
        enterprise_distribution >> feature_updates >> migration_support
        
        # Feedback Loop
        user_feedback >> Edge(label="feedback", color=COLORS['warning']) >> business_requirements
        issue_tracking >> Edge(label="improvements", color=COLORS['success']) >> technical_requirements

def create_module_registry_ecosystem():
    """
    Figure 7.3: Module Registry Ecosystem and Distribution Patterns

    This diagram illustrates the complete module registry ecosystem including
    public registries, private registries, and distribution strategies.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 7.3: Module Registry Ecosystem and Distribution Patterns",
        filename=str(output_dir / "figure_7_3_registry_ecosystem"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Public Registry Ecosystem
        with Cluster("Public Registry Ecosystem"):
            # Terraform Registry
            with Cluster("Terraform Registry"):
                terraform_public = Storage("registry.terraform.io")
                verified_modules = Storage("Verified Modules")
                community_modules = Storage("Community Modules")

            # Provider Registries
            with Cluster("Provider Registries"):
                aws_provider_modules = Storage("AWS Provider Modules")
                azure_provider_modules = Storage("Azure Provider Modules")
                gcp_provider_modules = Storage("GCP Provider Modules")

            # Third-Party Registries
            with Cluster("Third-Party Registries"):
                github_registry = Git("GitHub Registry")
                gitlab_registry = Storage("GitLab Registry")
                bitbucket_registry = Storage("Bitbucket Registry")

        # Private Registry Solutions
        with Cluster("Private Registry Solutions"):
            # Enterprise Solutions
            with Cluster("Enterprise Solutions"):
                terraform_cloud = Storage("Terraform Cloud")
                terraform_enterprise = Storage("Terraform Enterprise")
                spacelift_registry = Storage("Spacelift Registry")

            # Self-Hosted Solutions
            with Cluster("Self-Hosted Solutions"):
                artifactory_registry = Storage("JFrog Artifactory")
                nexus_registry = Storage("Nexus Repository")
                custom_registry = Storage("Custom Registry")

            # Cloud-Native Solutions
            with Cluster("Cloud-Native Solutions"):
                aws_codecommit = Storage("AWS CodeCommit")
                azure_devops = Storage("Azure DevOps")
                gcp_source_repos = Storage("GCP Source Repos")

        # Module Distribution Patterns
        with Cluster("Module Distribution Patterns"):
            # Versioning Strategies
            with Cluster("Versioning Strategies"):
                semantic_versioning = Storage("Semantic Versioning")
                git_tags = Git("Git Tags")
                branch_based = Storage("Branch-Based")

            # Access Control
            with Cluster("Access Control"):
                public_access = Storage("Public Access")
                private_access = Storage("Private Access")
                rbac_access = IAM("RBAC Access")

            # Distribution Methods
            with Cluster("Distribution Methods"):
                direct_download = Storage("Direct Download")
                api_access = Storage("API Access")
                cli_integration = Terraform("CLI Integration")

        # Module Consumption Layer
        with Cluster("Module Consumption Layer"):
            # Development Teams
            with Cluster("Development Teams"):
                frontend_team = LocalUsers("Frontend Team")
                backend_team = LocalUsers("Backend Team")
                platform_team = LocalUsers("Platform Team")

            # Automation Systems
            with Cluster("Automation Systems"):
                ci_cd_pipelines = Jenkins("CI/CD Pipelines")
                infrastructure_automation = Storage("Infrastructure Automation")
                deployment_tools = Storage("Deployment Tools")

            # Governance and Compliance
            with Cluster("Governance and Compliance"):
                policy_enforcement = Storage("Policy Enforcement")
                compliance_scanning = Storage("Compliance Scanning")
                audit_logging = Storage("Audit Logging")

        # Registry Integration Flow
        # Public to Private
        terraform_public >> Edge(label="mirrors", color=COLORS['primary']) >> terraform_cloud
        verified_modules >> Edge(label="curates", color=COLORS['success']) >> artifactory_registry
        community_modules >> Edge(label="evaluates", color=COLORS['accent']) >> custom_registry

        # Distribution Flow
        semantic_versioning >> [terraform_cloud, artifactory_registry, custom_registry]
        git_tags >> [github_registry, gitlab_registry, bitbucket_registry]

        # Access Control Flow
        rbac_access >> [terraform_enterprise, spacelift_registry]
        private_access >> [aws_codecommit, azure_devops, gcp_source_repos]

        # Consumption Flow
        terraform_cloud >> cli_integration >> [frontend_team, backend_team, platform_team]
        artifactory_registry >> api_access >> ci_cd_pipelines
        custom_registry >> direct_download >> infrastructure_automation

        # Governance Integration
        policy_enforcement >> [terraform_enterprise, spacelift_registry]
        compliance_scanning >> audit_logging >> [terraform_cloud, artifactory_registry]

def create_enterprise_module_governance():
    """
    Figure 7.4: Enterprise Module Governance and Compliance Framework

    This diagram demonstrates comprehensive governance patterns for enterprise
    module management including policies, compliance, and operational excellence.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 7.4: Enterprise Module Governance and Compliance Framework",
        filename=str(output_dir / "figure_7_4_enterprise_governance"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Governance Framework
        with Cluster("Governance Framework"):
            # Policy Management
            with Cluster("Policy Management"):
                module_policies = Storage("Module Policies")
                security_policies = Storage("Security Policies")
                compliance_policies = Storage("Compliance Policies")

            # Standards and Guidelines
            with Cluster("Standards and Guidelines"):
                coding_standards = Storage("Coding Standards")
                naming_conventions = Storage("Naming Conventions")
                documentation_standards = Storage("Documentation Standards")

            # Approval Workflows
            with Cluster("Approval Workflows"):
                design_approval = Storage("Design Approval")
                security_approval = Storage("Security Approval")
                architecture_approval = Storage("Architecture Approval")

        # Quality Assurance Framework
        with Cluster("Quality Assurance Framework"):
            # Automated Testing
            with Cluster("Automated Testing"):
                unit_tests = Python("Unit Tests")
                integration_tests = Storage("Integration Tests")
                security_tests = Storage("Security Tests")

            # Code Quality
            with Cluster("Code Quality"):
                static_analysis = Storage("Static Analysis")
                code_coverage = Storage("Code Coverage")
                complexity_analysis = Storage("Complexity Analysis")

            # Compliance Validation
            with Cluster("Compliance Validation"):
                policy_validation = Storage("Policy Validation")
                security_scanning = Storage("Security Scanning")
                license_compliance = Storage("License Compliance")

        # Operational Excellence
        with Cluster("Operational Excellence"):
            # Monitoring and Metrics
            with Cluster("Monitoring and Metrics"):
                usage_metrics = Grafana("Usage Metrics")
                performance_metrics = CloudWatch("Performance Metrics")
                adoption_metrics = Storage("Adoption Metrics")

            # Lifecycle Management
            with Cluster("Lifecycle Management"):
                version_management = Storage("Version Management")
                deprecation_management = Storage("Deprecation Management")
                migration_support = Storage("Migration Support")

            # Support and Training
            with Cluster("Support and Training"):
                documentation_portal = Storage("Documentation Portal")
                training_programs = Storage("Training Programs")
                community_support = Storage("Community Support")

        # Compliance and Audit
        with Cluster("Compliance and Audit"):
            # Regulatory Compliance
            with Cluster("Regulatory Compliance"):
                soc2_compliance = Storage("SOC 2 Compliance")
                hipaa_compliance = Storage("HIPAA Compliance")
                gdpr_compliance = Storage("GDPR Compliance")

            # Audit Framework
            with Cluster("Audit Framework"):
                audit_trails = Storage("Audit Trails")
                compliance_reporting = Storage("Compliance Reporting")
                risk_assessment = Storage("Risk Assessment")

            # Security Controls
            with Cluster("Security Controls"):
                access_controls = IAM("Access Controls")
                encryption_standards = KMS("Encryption Standards")
                vulnerability_management = Storage("Vulnerability Management")

        # Governance Flow
        # Policy to Implementation
        module_policies >> Edge(label="enforces", color=COLORS['primary']) >> policy_validation
        security_policies >> Edge(label="mandates", color=COLORS['warning']) >> security_scanning
        compliance_policies >> Edge(label="requires", color=COLORS['secondary']) >> license_compliance

        # Standards to Quality
        coding_standards >> static_analysis >> code_coverage
        naming_conventions >> complexity_analysis >> unit_tests
        documentation_standards >> integration_tests >> security_tests

        # Approval to Operations
        design_approval >> version_management >> usage_metrics
        security_approval >> deprecation_management >> performance_metrics
        architecture_approval >> migration_support >> adoption_metrics

        # Compliance Integration
        [soc2_compliance, hipaa_compliance, gdpr_compliance] >> audit_trails
        audit_trails >> compliance_reporting >> risk_assessment

        # Security Integration
        access_controls >> [policy_validation, security_scanning]
        encryption_standards >> vulnerability_management >> security_tests

        # Operational Integration
        usage_metrics >> documentation_portal >> training_programs
        performance_metrics >> community_support >> migration_support

def create_module_testing_automation():
    """
    Figure 7.5: Module Testing and Automation Pipeline

    This diagram shows comprehensive testing strategies and automation
    pipelines for Terraform module development and deployment.
    """
    output_dir = ensure_output_directory()

    with Diagram(
        "Figure 7.5: Module Testing and Automation Pipeline",
        filename=str(output_dir / "figure_7_5_testing_automation"),
        show=False,
        direction="TB",
        graph_attr=DIAGRAM_CONFIG['graph_attr'],
        node_attr=DIAGRAM_CONFIG['node_attr'],
        edge_attr=DIAGRAM_CONFIG['edge_attr']
    ):

        # Development Environment
        with Cluster("Development Environment"):
            # Local Development
            with Cluster("Local Development"):
                developer_workstation = LocalUsers("Developer Workstation")
                local_testing = Python("Local Testing")
                code_editor = Storage("Code Editor")

            # Version Control
            with Cluster("Version Control"):
                git_repository = Git("Git Repository")
                feature_branches = Storage("Feature Branches")
                pull_requests = Storage("Pull Requests")

            # Pre-commit Hooks
            with Cluster("Pre-commit Hooks"):
                syntax_validation = Storage("Syntax Validation")
                formatting_check = Storage("Formatting Check")
                security_scan = Storage("Security Scan")

        # CI/CD Pipeline
        with Cluster("CI/CD Pipeline"):
            # Build Stage
            with Cluster("Build Stage"):
                code_checkout = Storage("Code Checkout")
                dependency_resolution = Storage("Dependency Resolution")
                artifact_creation = Storage("Artifact Creation")

            # Test Stage
            with Cluster("Test Stage"):
                unit_testing = Python("Unit Testing")
                integration_testing = Storage("Integration Testing")
                end_to_end_testing = Storage("End-to-End Testing")

            # Quality Gates
            with Cluster("Quality Gates"):
                code_quality_gate = Storage("Code Quality Gate")
                security_gate = Storage("Security Gate")
                compliance_gate = Storage("Compliance Gate")

        # Testing Infrastructure
        with Cluster("Testing Infrastructure"):
            # Test Environments
            with Cluster("Test Environments"):
                sandbox_environment = Storage("Sandbox Environment")
                integration_environment = Storage("Integration Environment")
                staging_environment = Storage("Staging Environment")

            # Test Automation
            with Cluster("Test Automation"):
                terraform_test = Terraform("Terraform Test")
                terratest_framework = Python("Terratest Framework")
                kitchen_terraform = Storage("Kitchen Terraform")

            # Infrastructure Validation
            with Cluster("Infrastructure Validation"):
                resource_validation = Storage("Resource Validation")
                configuration_drift = Storage("Configuration Drift")
                compliance_validation = Storage("Compliance Validation")

        # Deployment and Release
        with Cluster("Deployment and Release"):
            # Release Management
            with Cluster("Release Management"):
                version_tagging = Git("Version Tagging")
                changelog_generation = Storage("Changelog Generation")
                release_notes = Storage("Release Notes")

            # Registry Publishing
            with Cluster("Registry Publishing"):
                module_registry = Storage("Module Registry")
                artifact_repository = Storage("Artifact Repository")
                distribution_channels = Storage("Distribution Channels")

            # Deployment Automation
            with Cluster("Deployment Automation"):
                automated_deployment = Jenkins("Automated Deployment")
                rollback_automation = Storage("Rollback Automation")
                monitoring_integration = CloudWatch("Monitoring Integration")

        # Feedback and Monitoring
        with Cluster("Feedback and Monitoring"):
            # Performance Monitoring
            with Cluster("Performance Monitoring"):
                deployment_metrics = Grafana("Deployment Metrics")
                usage_analytics = Storage("Usage Analytics")
                error_tracking = Storage("Error Tracking")

            # Quality Metrics
            with Cluster("Quality Metrics"):
                test_coverage = Storage("Test Coverage")
                code_quality_metrics = Storage("Code Quality Metrics")
                security_metrics = Storage("Security Metrics")

            # Continuous Improvement
            with Cluster("Continuous Improvement"):
                feedback_collection = Storage("Feedback Collection")
                process_optimization = Storage("Process Optimization")
                tool_enhancement = Storage("Tool Enhancement")

        # Pipeline Flow
        # Development to CI/CD
        developer_workstation >> code_editor >> git_repository
        local_testing >> feature_branches >> pull_requests
        syntax_validation >> formatting_check >> security_scan

        # CI/CD Flow
        pull_requests >> code_checkout >> dependency_resolution
        dependency_resolution >> artifact_creation >> unit_testing
        unit_testing >> integration_testing >> end_to_end_testing

        # Quality Gates Flow
        end_to_end_testing >> code_quality_gate >> security_gate
        security_gate >> compliance_gate >> version_tagging

        # Testing Infrastructure Flow
        unit_testing >> sandbox_environment >> terraform_test
        integration_testing >> integration_environment >> terratest_framework
        end_to_end_testing >> staging_environment >> kitchen_terraform

        # Deployment Flow
        compliance_gate >> version_tagging >> changelog_generation
        changelog_generation >> release_notes >> module_registry
        module_registry >> automated_deployment >> monitoring_integration

        # Feedback Loop
        deployment_metrics >> feedback_collection >> process_optimization
        usage_analytics >> tool_enhancement >> developer_workstation
        error_tracking >> Edge(label="improvements", color=COLORS['warning']) >> local_testing

def main():
    """
    Main function to generate all diagrams for Topic 7: Modules and Module Development
    """
    print("🎨 Generating Professional Module Development Diagrams...")
    print("=" * 80)

    try:
        # Ensure output directory exists
        output_dir = ensure_output_directory()
        print(f"📁 Output directory: {output_dir.absolute()}")

        # Generate all diagrams
        diagrams = [
            ("Figure 7.1: Module Architecture Patterns", create_module_architecture_patterns),
            ("Figure 7.2: Module Development Lifecycle", create_module_development_lifecycle),
            ("Figure 7.3: Module Registry Ecosystem", create_module_registry_ecosystem),
            ("Figure 7.4: Enterprise Governance", create_enterprise_module_governance),
            ("Figure 7.5: Testing and Automation", create_module_testing_automation)
        ]

        for diagram_name, diagram_function in diagrams:
            print(f"🔄 Generating {diagram_name}...")
            diagram_function()
            print(f"✅ {diagram_name} completed successfully!")

        print("\n" + "=" * 80)
        print("🎉 All diagrams generated successfully!")
        print(f"📂 Diagrams saved to: {output_dir.absolute()}")
        print("\n📋 Generated Files:")

        # List generated files
        for file in sorted(output_dir.glob("*.png")):
            print(f"   • {file.name}")

        print("\n💡 Integration Notes:")
        print("   • All diagrams are 300 DPI for professional presentations")
        print("   • AWS brand colors and styling applied consistently")
        print("   • Diagrams are referenced in Concept.md and Lab-7.md")
        print("   • Use these diagrams to enhance learning and understanding")

    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        print("Please check your environment and dependencies.")
        sys.exit(1)

if __name__ == "__main__":
    main()
