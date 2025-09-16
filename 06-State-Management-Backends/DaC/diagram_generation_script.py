#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 6: State Management & Backends
Professional Diagram Generation Script (DaC - Diagram as Code)

This script generates 5 professional-quality diagrams for Topic 6 of the AWS Terraform
training curriculum. Each diagram is designed to support specific learning objectives
and enhance understanding of state management, backend architectures, collaboration
patterns, and enterprise governance frameworks.

Generated Diagrams:
1. Figure 6.1: Terraform State Architecture and Backend Types
2. Figure 6.2: State Locking and Collaboration Patterns
3. Figure 6.3: Remote State Sharing and Data Flow
4. Figure 6.4: State Migration and Disaster Recovery
5. Figure 6.5: Enterprise State Governance and Security

Requirements:
- Python 3.9+
- All dependencies from requirements.txt
- Graphviz system installation
- 300 DPI output for professional quality

Author: AWS Terraform Training Team
Version: 6.0.0
Last Updated: January 2025
License: Educational Use
"""

import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple
import logging

# Configure logging for diagram generation tracking
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('diagram_generation.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Import required libraries with error handling
try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.aws.compute import EC2, Lambda, ECS, AutoScaling
    from diagrams.aws.database import RDS, Dynamodb, ElastiCache
    from diagrams.aws.network import VPC, ELB, CloudFront, Route53
    from diagrams.aws.storage import S3, EBS, EFS
    from diagrams.aws.security import IAM, KMS, WAF
    from diagrams.aws.management import Cloudformation, Cloudwatch, Config, SystemsManager
    from diagrams.aws.devtools import Codepipeline, Codebuild, Codecommit
    from diagrams.aws.analytics import Athena, Glue, Kinesis
    from diagrams.onprem.client import Users, Client
    from diagrams.onprem.vcs import Git
    from diagrams.programming.language import Python, Bash
    from diagrams.generic.blank import Blank
    from diagrams.generic.compute import Rack
    from diagrams.generic.database import SQL
    from diagrams.generic.network import Firewall, Router
    from diagrams.generic.os import LinuxGeneral, Windows, IOS
    logger.info("Successfully imported all required diagram libraries")
except ImportError as e:
    logger.error(f"Failed to import required libraries: {e}")
    logger.error("Please install dependencies: pip install -r requirements.txt")
    sys.exit(1)

# AWS Brand Colors (Official AWS Design System)
AWS_COLORS = {
    'primary': '#FF9900',      # AWS Orange
    'secondary': '#232F3E',    # AWS Dark Blue  
    'accent': '#146EB4',       # AWS Blue
    'success': '#7AA116',      # AWS Green
    'warning': '#FF9900',      # AWS Orange
    'error': '#D13212',        # AWS Red
    'background': '#F2F3F3',   # Light Gray
    'text': '#232F3E',         # Dark Blue
    'white': '#FFFFFF',        # Pure White
    'light_blue': '#4B9CD3',   # Light Blue
    'dark_gray': '#5A6C7D'     # Dark Gray
}

# Professional Typography Settings
TYPOGRAPHY = {
    'title_size': 16,
    'subtitle_size': 14, 
    'heading_size': 12,
    'body_size': 10,
    'caption_size': 8
}

# Diagram Configuration
DIAGRAM_CONFIG = {
    'dpi': 300,                # High resolution for professional output
    'format': 'png',           # PNG format for web and print compatibility
    'background': 'white',     # Clean white background
    'fontsize': '12',          # Base font size
    'fontname': 'Arial',       # Professional font family
    'rankdir': 'TB',           # Top to bottom layout
    'splines': 'ortho',        # Orthogonal edge routing
    'nodesep': '0.8',          # Node separation
    'ranksep': '1.0'           # Rank separation
}

class StateManagementDiagramGenerator:
    """
    Professional diagram generator for State Management & Backends.
    
    This class provides methods to generate high-quality architectural diagrams
    that support the learning objectives of Topic 6: State Management & Backends.
    """
    
    def __init__(self, output_dir: str = "generated_diagrams"):
        """
        Initialize the diagram generator.
        
        Args:
            output_dir (str): Directory to save generated diagrams
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        logger.info(f"Initialized diagram generator with output directory: {self.output_dir}")
        
        # Ensure output directory exists and is writable
        if not os.access(self.output_dir, os.W_OK):
            logger.error(f"Output directory {self.output_dir} is not writable")
            raise PermissionError(f"Cannot write to {self.output_dir}")
    
    def generate_all_diagrams(self) -> Dict[str, str]:
        """
        Generate all 5 professional diagrams for Topic 6.
        
        Returns:
            Dict[str, str]: Mapping of diagram names to file paths
        """
        logger.info("Starting generation of all Topic 6 diagrams")
        
        diagrams = {
            'figure_6_1': self.generate_state_architecture_backends_diagram(),
            'figure_6_2': self.generate_state_locking_collaboration_diagram(), 
            'figure_6_3': self.generate_remote_state_sharing_diagram(),
            'figure_6_4': self.generate_state_migration_disaster_recovery_diagram(),
            'figure_6_5': self.generate_enterprise_state_governance_diagram()
        }
        
        logger.info(f"Successfully generated {len(diagrams)} diagrams")
        return diagrams
    
    def generate_state_architecture_backends_diagram(self) -> str:
        """
        Generate Figure 6.1: Terraform State Architecture and Backend Types
        
        This diagram illustrates comprehensive state architecture patterns, backend
        types, and selection criteria for enterprise Terraform deployments.
        
        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 6.1: Terraform State Architecture and Backend Types")
        
        diagram_path = self.output_dir / "figure_6_1_state_architecture_backends.png"
        
        with Diagram(
            "Figure 6.1: Terraform State Architecture and Backend Types",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="TB",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Local State Management
            with Cluster("Local State Management", graph_attr={"bgcolor": "#E6F3FF"}):
                # Local Backend
                with Cluster("Local Backend", graph_attr={"bgcolor": "#F0F8FF"}):
                    local_state = Blank("terraform.tfstate")
                    local_backup = Blank("terraform.tfstate.backup")
                    local_workspace = Blank("terraform.tfstate.d/")
                
                # Local Characteristics
                with Cluster("Characteristics", graph_attr={"bgcolor": "#F5F5FF"}):
                    single_user = Blank("Single User")
                    no_locking = Blank("No Locking")
                    local_storage = Blank("Local Storage")
                    dev_only = Blank("Development Only")
            
            # Remote State Backends
            with Cluster("Remote State Backends", graph_attr={"bgcolor": "#FFF8DC"}):
                # AWS S3 Backend
                with Cluster("AWS S3 Backend", graph_attr={"bgcolor": "#FFFACD"}):
                    s3_bucket = S3("S3 Bucket")
                    dynamodb_lock = Dynamodb("DynamoDB\nLocking")
                    kms_encryption = KMS("KMS\nEncryption")
                
                # Terraform Cloud
                with Cluster("Terraform Cloud", graph_attr={"bgcolor": "#FFF8E1"}):
                    tf_cloud = Blank("Terraform\nCloud")
                    remote_execution = Blank("Remote\nExecution")
                    vcs_integration = Git("VCS\nIntegration")
                
                # Other Backends
                with Cluster("Other Backends", graph_attr={"bgcolor": "#F8F8DC"}):
                    azure_storage = Blank("Azure\nStorage")
                    gcs_backend = Blank("Google\nCloud Storage")
                    consul_backend = Blank("Consul")
                    etcd_backend = Blank("etcd")
            
            # Backend Selection Criteria
            with Cluster("Backend Selection Criteria", graph_attr={"bgcolor": "#F0FFF0"}):
                # Team Size
                with Cluster("Team Considerations", graph_attr={"bgcolor": "#E6FFE6"}):
                    team_size = Blank("Team Size")
                    collaboration = Blank("Collaboration\nNeeds")
                    access_control = Blank("Access\nControl")
                
                # Technical Requirements
                with Cluster("Technical Requirements", graph_attr={"bgcolor": "#F0FFF0"}):
                    state_locking = Blank("State\nLocking")
                    encryption = Blank("Encryption")
                    versioning = Blank("State\nVersioning")
                    backup_recovery = Blank("Backup &\nRecovery")
                
                # Operational Needs
                with Cluster("Operational Needs", graph_attr={"bgcolor": "#FFF8F0"}):
                    ci_cd_integration = Blank("CI/CD\nIntegration")
                    audit_logging = Blank("Audit\nLogging")
                    compliance = Blank("Compliance\nRequirements")
                    cost_optimization = Blank("Cost\nOptimization")
            
            # Enterprise Patterns
            with Cluster("Enterprise State Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Multi-Environment
                with Cluster("Multi-Environment", graph_attr={"bgcolor": "#FFF8DC"}):
                    env_separation = Blank("Environment\nSeparation")
                    state_isolation = Blank("State\nIsolation")
                    workspace_strategy = Blank("Workspace\nStrategy")
                
                # Security Patterns
                with Cluster("Security Patterns", graph_attr={"bgcolor": "#FFFACD"}):
                    encryption_at_rest = Blank("Encryption\nat Rest")
                    encryption_in_transit = Blank("Encryption\nin Transit")
                    access_policies = Blank("Access\nPolicies")
                    key_management = Blank("Key\nManagement")
            
            # State architecture flow
            local_state >> Edge(label="evolves to") >> s3_bucket
            s3_bucket >> dynamodb_lock
            s3_bucket >> kms_encryption
            
            # Selection criteria flow
            team_size >> collaboration >> state_locking
            encryption >> versioning >> backup_recovery
            ci_cd_integration >> audit_logging >> compliance
            
            # Enterprise patterns
            env_separation >> state_isolation >> workspace_strategy
            encryption_at_rest >> encryption_in_transit >> access_policies
        
        logger.info(f"Generated Figure 6.1 at: {diagram_path}")
        return str(diagram_path)

    def generate_state_locking_collaboration_diagram(self) -> str:
        """
        Generate Figure 6.2: State Locking and Collaboration Patterns

        This diagram demonstrates state locking mechanisms, team collaboration
        workflows, and conflict resolution strategies for enterprise teams.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 6.2: State Locking and Collaboration Patterns")

        diagram_path = self.output_dir / "figure_6_2_state_locking_collaboration.png"

        with Diagram(
            "Figure 6.2: State Locking and Collaboration Patterns",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="LR",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Team Members and Clients
            with Cluster("Development Team", graph_attr={"bgcolor": "#E6F3FF"}):
                # Team Members
                with Cluster("Team Members", graph_attr={"bgcolor": "#F0F8FF"}):
                    developer_1 = Users("Developer 1")
                    developer_2 = Users("Developer 2")
                    devops_engineer = Users("DevOps\nEngineer")

                # Client Tools
                with Cluster("Client Tools", graph_attr={"bgcolor": "#F5F5FF"}):
                    terraform_cli = Bash("Terraform\nCLI")
                    ci_cd_pipeline = Codepipeline("CI/CD\nPipeline")
                    automation_tools = Lambda("Automation\nTools")

            # State Locking Mechanism
            with Cluster("State Locking Mechanism", graph_attr={"bgcolor": "#FFF8DC"}):
                # Lock Acquisition
                with Cluster("Lock Acquisition", graph_attr={"bgcolor": "#FFFACD"}):
                    lock_request = Blank("Lock\nRequest")
                    lock_validation = Blank("Lock\nValidation")
                    lock_granted = Blank("Lock\nGranted")

                # Lock Storage
                with Cluster("Lock Storage", graph_attr={"bgcolor": "#FFF8E1"}):
                    dynamodb_table = Dynamodb("DynamoDB\nLock Table")
                    lock_metadata = Blank("Lock\nMetadata")
                    lock_timeout = Blank("Lock\nTimeout")

                # Lock Release
                with Cluster("Lock Release", graph_attr={"bgcolor": "#F8F8DC"}):
                    operation_complete = Blank("Operation\nComplete")
                    lock_release = Blank("Lock\nRelease")
                    cleanup = Blank("Cleanup")

            # Collaboration Workflows
            with Cluster("Collaboration Workflows", graph_attr={"bgcolor": "#F0FFF0"}):
                # Sequential Operations
                with Cluster("Sequential Operations", graph_attr={"bgcolor": "#E6FFE6"}):
                    queue_management = Blank("Queue\nManagement")
                    operation_ordering = Blank("Operation\nOrdering")
                    conflict_prevention = Blank("Conflict\nPrevention")

                # Parallel Development
                with Cluster("Parallel Development", graph_attr={"bgcolor": "#F0FFF0"}):
                    workspace_isolation = Blank("Workspace\nIsolation")
                    feature_branches = Git("Feature\nBranches")
                    merge_strategies = Blank("Merge\nStrategies")

                # Emergency Procedures
                with Cluster("Emergency Procedures", graph_attr={"bgcolor": "#FFF8F0"}):
                    force_unlock = Blank("Force\nUnlock")
                    lock_recovery = Blank("Lock\nRecovery")
                    incident_response = Blank("Incident\nResponse")

            # Advanced Locking Patterns
            with Cluster("Advanced Locking Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Distributed Locking
                with Cluster("Distributed Locking", graph_attr={"bgcolor": "#FFF8DC"}):
                    multi_region = Blank("Multi-Region\nLocking")
                    consensus_algorithm = Blank("Consensus\nAlgorithm")
                    leader_election = Blank("Leader\nElection")

                # Lock Optimization
                with Cluster("Lock Optimization", graph_attr={"bgcolor": "#FFFACD"}):
                    lock_granularity = Blank("Lock\nGranularity")
                    timeout_tuning = Blank("Timeout\nTuning")
                    performance_monitoring = Blank("Performance\nMonitoring")

                # Monitoring and Alerting
                with Cluster("Monitoring & Alerting", graph_attr={"bgcolor": "#FDF5E6"}):
                    lock_metrics = Cloudwatch("Lock\nMetrics")
                    alert_system = Blank("Alert\nSystem")
                    dashboard = Blank("Lock\nDashboard")

            # Collaboration flow
            developer_1 >> terraform_cli >> lock_request
            developer_2 >> ci_cd_pipeline >> lock_request
            devops_engineer >> automation_tools >> lock_request

            # Locking mechanism flow
            lock_request >> lock_validation >> dynamodb_table
            dynamodb_table >> lock_granted >> operation_complete
            operation_complete >> lock_release >> cleanup

            # Workflow patterns
            queue_management >> operation_ordering >> conflict_prevention
            workspace_isolation >> feature_branches >> merge_strategies
            force_unlock >> lock_recovery >> incident_response

            # Advanced patterns
            multi_region >> consensus_algorithm >> leader_election
            lock_granularity >> timeout_tuning >> performance_monitoring
            lock_metrics >> alert_system >> dashboard

        logger.info(f"Generated Figure 6.2 at: {diagram_path}")
        return str(diagram_path)

    def generate_remote_state_sharing_diagram(self) -> str:
        """
        Generate Figure 6.3: Remote State Sharing and Data Flow

        This diagram shows remote state sharing patterns, data flow between
        configurations, and cross-team integration strategies.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 6.3: Remote State Sharing and Data Flow")

        diagram_path = self.output_dir / "figure_6_3_remote_state_sharing.png"

        with Diagram(
            "Figure 6.3: Remote State Sharing and Data Flow",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="TB",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # State Producers
            with Cluster("State Producers", graph_attr={"bgcolor": "#E6F3FF"}):
                # Infrastructure Teams
                with Cluster("Infrastructure Teams", graph_attr={"bgcolor": "#F0F8FF"}):
                    network_team = Users("Network\nTeam")
                    security_team = Users("Security\nTeam")
                    platform_team = Users("Platform\nTeam")

                # Infrastructure Configurations
                with Cluster("Infrastructure Configurations", graph_attr={"bgcolor": "#F5F5FF"}):
                    network_config = Blank("Network\nConfiguration")
                    security_config = Blank("Security\nConfiguration")
                    platform_config = Blank("Platform\nConfiguration")

                # State Outputs
                with Cluster("State Outputs", graph_attr={"bgcolor": "#F8F8FF"}):
                    vpc_outputs = VPC("VPC\nOutputs")
                    security_outputs = IAM("Security\nOutputs")
                    platform_outputs = ECS("Platform\nOutputs")

            # Remote State Storage
            with Cluster("Remote State Storage", graph_attr={"bgcolor": "#FFF8DC"}):
                # S3 Backend
                with Cluster("S3 Backend", graph_attr={"bgcolor": "#FFFACD"}):
                    state_bucket = S3("State\nBucket")
                    versioning = Blank("State\nVersioning")
                    encryption = KMS("State\nEncryption")

                # State Organization
                with Cluster("State Organization", graph_attr={"bgcolor": "#FFF8E1"}):
                    environment_separation = Blank("Environment\nSeparation")
                    team_isolation = Blank("Team\nIsolation")
                    project_structure = Blank("Project\nStructure")

                # Access Control
                with Cluster("Access Control", graph_attr={"bgcolor": "#F8F8DC"}):
                    iam_policies = IAM("IAM\nPolicies")
                    bucket_policies = Blank("Bucket\nPolicies")
                    cross_account = Blank("Cross-Account\nAccess")

            # State Consumers
            with Cluster("State Consumers", graph_attr={"bgcolor": "#F0FFF0"}):
                # Application Teams
                with Cluster("Application Teams", graph_attr={"bgcolor": "#E6FFE6"}):
                    app_team_1 = Users("Application\nTeam 1")
                    app_team_2 = Users("Application\nTeam 2")
                    microservices_team = Users("Microservices\nTeam")

                # Data Sources
                with Cluster("Remote State Data Sources", graph_attr={"bgcolor": "#F0FFF0"}):
                    network_data = Blank("terraform_remote_state\n(network)")
                    security_data = Blank("terraform_remote_state\n(security)")
                    platform_data = Blank("terraform_remote_state\n(platform)")

                # Consumer Applications
                with Cluster("Consumer Applications", graph_attr={"bgcolor": "#FFF8F0"}):
                    web_app = ELB("Web\nApplication")
                    api_service = Lambda("API\nService")
                    database_app = RDS("Database\nApplication")

            # Data Flow Patterns
            with Cluster("Data Flow Patterns", graph_attr={"bgcolor": "#F5F5DC"}):
                # Hierarchical Flow
                with Cluster("Hierarchical Flow", graph_attr={"bgcolor": "#FFF8DC"}):
                    foundation_layer = Blank("Foundation\nLayer")
                    platform_layer = Blank("Platform\nLayer")
                    application_layer = Blank("Application\nLayer")

                # Cross-Team Integration
                with Cluster("Cross-Team Integration", graph_attr={"bgcolor": "#FFFACD"}):
                    shared_services = Blank("Shared\nServices")
                    service_discovery = Blank("Service\nDiscovery")
                    configuration_sharing = Blank("Configuration\nSharing")

                # Advanced Patterns
                with Cluster("Advanced Patterns", graph_attr={"bgcolor": "#FDF5E6"}):
                    state_composition = Blank("State\nComposition")
                    dependency_graph = Blank("Dependency\nGraph")
                    circular_dependency = Blank("Circular\nDependency\nPrevention")

            # Producer flow
            network_team >> network_config >> vpc_outputs
            security_team >> security_config >> security_outputs
            platform_team >> platform_config >> platform_outputs

            # State storage flow
            vpc_outputs >> state_bucket
            security_outputs >> state_bucket
            platform_outputs >> state_bucket
            state_bucket >> versioning >> encryption

            # Consumer flow
            state_bucket >> network_data >> app_team_1
            state_bucket >> security_data >> app_team_2
            state_bucket >> platform_data >> microservices_team

            # Application deployment
            network_data >> web_app
            security_data >> api_service
            platform_data >> database_app

            # Data flow patterns
            foundation_layer >> platform_layer >> application_layer
            shared_services >> service_discovery >> configuration_sharing
            state_composition >> dependency_graph >> circular_dependency

        logger.info(f"Generated Figure 6.3 at: {diagram_path}")
        return str(diagram_path)

    def generate_state_migration_disaster_recovery_diagram(self) -> str:
        """
        Generate Figure 6.4: State Migration and Disaster Recovery

        This diagram illustrates state migration strategies, backup procedures,
        disaster recovery patterns, and business continuity planning.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 6.4: State Migration and Disaster Recovery")

        diagram_path = self.output_dir / "figure_6_4_state_migration_disaster_recovery.png"

        with Diagram(
            "Figure 6.4: State Migration and Disaster Recovery",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="LR",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Current State Environment
            with Cluster("Current State Environment", graph_attr={"bgcolor": "#E6F3FF"}):
                # Source Backend
                with Cluster("Source Backend", graph_attr={"bgcolor": "#F0F8FF"}):
                    source_s3 = S3("Source S3\nBucket")
                    source_dynamodb = Dynamodb("Source\nDynamoDB")
                    source_encryption = KMS("Source\nEncryption")

                # Current State
                with Cluster("Current State", graph_attr={"bgcolor": "#F5F5FF"}):
                    current_state = Blank("terraform.tfstate")
                    state_metadata = Blank("State\nMetadata")
                    resource_mapping = Blank("Resource\nMapping")

                # Backup Systems
                with Cluster("Backup Systems", graph_attr={"bgcolor": "#F8F8FF"}):
                    automated_backup = Blank("Automated\nBackup")
                    versioning_backup = Blank("Versioning\nBackup")
                    cross_region_backup = Blank("Cross-Region\nBackup")

            # Migration Process
            with Cluster("Migration Process", graph_attr={"bgcolor": "#FFF8DC"}):
                # Pre-Migration
                with Cluster("Pre-Migration", graph_attr={"bgcolor": "#FFFACD"}):
                    state_analysis = Blank("State\nAnalysis")
                    dependency_mapping = Blank("Dependency\nMapping")
                    migration_planning = Blank("Migration\nPlanning")

                # Migration Execution
                with Cluster("Migration Execution", graph_attr={"bgcolor": "#FFF8E1"}):
                    state_export = Blank("State\nExport")
                    data_transformation = Blank("Data\nTransformation")
                    state_import = Blank("State\nImport")

                # Validation
                with Cluster("Validation", graph_attr={"bgcolor": "#F8F8DC"}):
                    integrity_check = Blank("Integrity\nCheck")
                    resource_validation = Blank("Resource\nValidation")
                    rollback_preparation = Blank("Rollback\nPreparation")

            # Target State Environment
            with Cluster("Target State Environment", graph_attr={"bgcolor": "#F0FFF0"}):
                # Target Backend
                with Cluster("Target Backend", graph_attr={"bgcolor": "#E6FFE6"}):
                    target_s3 = S3("Target S3\nBucket")
                    target_dynamodb = Dynamodb("Target\nDynamoDB")
                    target_encryption = KMS("Target\nEncryption")

                # Migrated State
                with Cluster("Migrated State", graph_attr={"bgcolor": "#F0FFF0"}):
                    migrated_state = Blank("Migrated\nterraform.tfstate")
                    updated_metadata = Blank("Updated\nMetadata")
                    new_resource_mapping = Blank("New Resource\nMapping")

                # Enhanced Features
                with Cluster("Enhanced Features", graph_attr={"bgcolor": "#FFF8F0"}):
                    improved_security = Blank("Improved\nSecurity")
                    better_performance = Blank("Better\nPerformance")
                    enhanced_monitoring = Blank("Enhanced\nMonitoring")

            # Disaster Recovery
            with Cluster("Disaster Recovery", graph_attr={"bgcolor": "#F5F5DC"}):
                # Recovery Scenarios
                with Cluster("Recovery Scenarios", graph_attr={"bgcolor": "#FFF8DC"}):
                    corruption_recovery = Blank("State\nCorruption")
                    backend_failure = Blank("Backend\nFailure")
                    region_outage = Blank("Region\nOutage")

                # Recovery Procedures
                with Cluster("Recovery Procedures", graph_attr={"bgcolor": "#FFFACD"}):
                    backup_restoration = Blank("Backup\nRestoration")
                    state_reconstruction = Blank("State\nReconstruction")
                    manual_recovery = Blank("Manual\nRecovery")

                # Business Continuity
                with Cluster("Business Continuity", graph_attr={"bgcolor": "#FDF5E6"}):
                    rto_planning = Blank("RTO\nPlanning")
                    rpo_targets = Blank("RPO\nTargets")
                    communication_plan = Blank("Communication\nPlan")

            # Migration Tools and Automation
            with Cluster("Migration Tools & Automation", graph_attr={"bgcolor": "#FFF0F5"}):
                # Migration Tools
                with Cluster("Migration Tools", graph_attr={"bgcolor": "#FFE4E1"}):
                    terraform_cli = Bash("Terraform\nCLI")
                    migration_scripts = Python("Migration\nScripts")
                    validation_tools = Blank("Validation\nTools")

                # Automation Pipeline
                with Cluster("Automation Pipeline", graph_attr={"bgcolor": "#FFF5EE"}):
                    ci_cd_pipeline = Codepipeline("CI/CD\nPipeline")
                    automated_testing = Blank("Automated\nTesting")
                    deployment_automation = Blank("Deployment\nAutomation")

                # Monitoring and Alerting
                with Cluster("Monitoring & Alerting", graph_attr={"bgcolor": "#FFFAF0"}):
                    migration_monitoring = Cloudwatch("Migration\nMonitoring")
                    alert_system = Blank("Alert\nSystem")
                    status_dashboard = Blank("Status\nDashboard")

            # Migration flow
            source_s3 >> state_analysis >> migration_planning
            current_state >> state_export >> data_transformation
            data_transformation >> state_import >> target_s3

            # Validation flow
            state_import >> integrity_check >> resource_validation
            resource_validation >> rollback_preparation >> migrated_state

            # Disaster recovery flow
            corruption_recovery >> backup_restoration >> state_reconstruction
            backend_failure >> manual_recovery >> rto_planning
            region_outage >> rpo_targets >> communication_plan

            # Automation flow
            terraform_cli >> migration_scripts >> validation_tools
            ci_cd_pipeline >> automated_testing >> deployment_automation
            migration_monitoring >> alert_system >> status_dashboard

        logger.info(f"Generated Figure 6.4 at: {diagram_path}")
        return str(diagram_path)

    def generate_enterprise_state_governance_diagram(self) -> str:
        """
        Generate Figure 6.5: Enterprise State Governance and Security

        This diagram shows enterprise governance frameworks, security patterns,
        compliance requirements, and organizational policies for state management.

        Returns:
            str: Path to generated diagram file
        """
        logger.info("Generating Figure 6.5: Enterprise State Governance and Security")

        diagram_path = self.output_dir / "figure_6_5_enterprise_state_governance.png"

        with Diagram(
            "Figure 6.5: Enterprise State Governance and Security",
            filename=str(diagram_path.with_suffix('')),
            show=False,
            direction="TB",
            graph_attr={
                "dpi": str(DIAGRAM_CONFIG['dpi']),
                "bgcolor": DIAGRAM_CONFIG['background'],
                "fontsize": DIAGRAM_CONFIG['fontsize'],
                "fontname": DIAGRAM_CONFIG['fontname']
            }
        ):
            # Governance Framework
            with Cluster("Governance Framework", graph_attr={"bgcolor": "#E6F3FF"}):
                # Organizational Structure
                with Cluster("Organizational Structure", graph_attr={"bgcolor": "#F0F8FF"}):
                    cloud_center = Users("Cloud Center\nof Excellence")
                    security_team = Users("Security\nTeam")
                    compliance_team = Users("Compliance\nTeam")

                # Governance Policies
                with Cluster("Governance Policies", graph_attr={"bgcolor": "#F5F5FF"}):
                    state_policies = Blank("State\nPolicies")
                    access_policies = Blank("Access\nPolicies")
                    retention_policies = Blank("Retention\nPolicies")

                # Policy Enforcement
                with Cluster("Policy Enforcement", graph_attr={"bgcolor": "#F8F8FF"}):
                    automated_enforcement = Blank("Automated\nEnforcement")
                    compliance_scanning = Blank("Compliance\nScanning")
                    violation_detection = Blank("Violation\nDetection")

            # Security Architecture
            with Cluster("Security Architecture", graph_attr={"bgcolor": "#FFF8DC"}):
                # Identity and Access Management
                with Cluster("Identity & Access Management", graph_attr={"bgcolor": "#FFFACD"}):
                    iam_roles = IAM("IAM\nRoles")
                    service_accounts = Blank("Service\nAccounts")
                    federated_access = Blank("Federated\nAccess")

                # Encryption and Key Management
                with Cluster("Encryption & Key Management", graph_attr={"bgcolor": "#FFF8E1"}):
                    kms_keys = KMS("KMS\nKeys")
                    key_rotation = Blank("Key\nRotation")
                    envelope_encryption = Blank("Envelope\nEncryption")

                # Network Security
                with Cluster("Network Security", graph_attr={"bgcolor": "#F8F8DC"}):
                    vpc_endpoints = Blank("VPC\nEndpoints")
                    private_networks = Blank("Private\nNetworks")
                    network_isolation = Blank("Network\nIsolation")

            # Compliance and Audit
            with Cluster("Compliance & Audit", graph_attr={"bgcolor": "#F0FFF0"}):
                # Regulatory Compliance
                with Cluster("Regulatory Compliance", graph_attr={"bgcolor": "#E6FFE6"}):
                    sox_compliance = Blank("SOX\nCompliance")
                    gdpr_compliance = Blank("GDPR\nCompliance")
                    hipaa_compliance = Blank("HIPAA\nCompliance")

                # Audit Trail
                with Cluster("Audit Trail", graph_attr={"bgcolor": "#F0FFF0"}):
                    cloudtrail = Blank("CloudTrail\nLogging")
                    access_logging = Blank("Access\nLogging")
                    change_tracking = Blank("Change\nTracking")

                # Compliance Monitoring
                with Cluster("Compliance Monitoring", graph_attr={"bgcolor": "#FFF8F0"}):
                    config_rules = Config("Config\nRules")
                    compliance_dashboard = Blank("Compliance\nDashboard")
                    violation_alerts = Blank("Violation\nAlerts")

            # State Management Controls
            with Cluster("State Management Controls", graph_attr={"bgcolor": "#F5F5DC"}):
                # Access Controls
                with Cluster("Access Controls", graph_attr={"bgcolor": "#FFF8DC"}):
                    rbac_model = Blank("RBAC\nModel")
                    least_privilege = Blank("Least\nPrivilege")
                    segregation_duties = Blank("Segregation\nof Duties")

                # Data Protection
                with Cluster("Data Protection", graph_attr={"bgcolor": "#FFFACD"}):
                    data_classification = Blank("Data\nClassification")
                    encryption_standards = Blank("Encryption\nStandards")
                    data_retention = Blank("Data\nRetention")

                # Operational Controls
                with Cluster("Operational Controls", graph_attr={"bgcolor": "#FDF5E6"}):
                    change_approval = Blank("Change\nApproval")
                    peer_review = Blank("Peer\nReview")
                    automated_testing = Blank("Automated\nTesting")

            # Enterprise Integration
            with Cluster("Enterprise Integration", graph_attr={"bgcolor": "#FFF0F5"}):
                # ITSM Integration
                with Cluster("ITSM Integration", graph_attr={"bgcolor": "#FFE4E1"}):
                    service_now = Blank("ServiceNow\nIntegration")
                    change_management = Blank("Change\nManagement")
                    incident_management = Blank("Incident\nManagement")

                # Security Tools
                with Cluster("Security Tools", graph_attr={"bgcolor": "#FFF5EE"}):
                    siem_integration = Blank("SIEM\nIntegration")
                    vulnerability_scanning = Blank("Vulnerability\nScanning")
                    threat_detection = Blank("Threat\nDetection")

                # Monitoring and Reporting
                with Cluster("Monitoring & Reporting", graph_attr={"bgcolor": "#FFFAF0"}):
                    centralized_logging = Blank("Centralized\nLogging")
                    metrics_collection = Cloudwatch("Metrics\nCollection")
                    executive_reporting = Blank("Executive\nReporting")

            # Governance flow
            cloud_center >> state_policies >> automated_enforcement
            security_team >> access_policies >> compliance_scanning
            compliance_team >> retention_policies >> violation_detection

            # Security flow
            iam_roles >> service_accounts >> federated_access
            kms_keys >> key_rotation >> envelope_encryption
            vpc_endpoints >> private_networks >> network_isolation

            # Compliance flow
            sox_compliance >> cloudtrail >> config_rules
            gdpr_compliance >> access_logging >> compliance_dashboard
            hipaa_compliance >> change_tracking >> violation_alerts

            # Controls flow
            rbac_model >> least_privilege >> segregation_duties
            data_classification >> encryption_standards >> data_retention
            change_approval >> peer_review >> automated_testing

            # Integration flow
            service_now >> change_management >> incident_management
            siem_integration >> vulnerability_scanning >> threat_detection
            centralized_logging >> metrics_collection >> executive_reporting

        logger.info(f"Generated Figure 6.5 at: {diagram_path}")
        return str(diagram_path)


def validate_system_requirements() -> bool:
    """
    Validate system requirements for diagram generation.

    Returns:
        bool: True if all requirements are met, False otherwise
    """
    logger.info("Validating system requirements...")

    # Check Python version
    if sys.version_info < (3, 9):
        logger.error(f"Python 3.9+ required, found {sys.version}")
        return False

    # Check Graphviz installation
    try:
        import subprocess
        result = subprocess.run(['dot', '-V'], capture_output=True, text=True)
        if result.returncode != 0:
            logger.error("Graphviz not found. Please install Graphviz system package.")
            return False
        logger.info(f"Graphviz found: {result.stderr.strip()}")
    except FileNotFoundError:
        logger.error("Graphviz not found. Please install Graphviz system package.")
        return False

    # Check required libraries
    required_modules = ['diagrams', 'PIL', 'pathlib']
    for module in required_modules:
        try:
            __import__(module)
            logger.info(f"✓ {module} available")
        except ImportError:
            logger.error(f"✗ {module} not available")
            return False

    # Check write permissions
    output_dir = Path("generated_diagrams")
    try:
        output_dir.mkdir(exist_ok=True)
        test_file = output_dir / "test_write.tmp"
        test_file.write_text("test")
        test_file.unlink()
        logger.info("✓ Write permissions verified")
    except Exception as e:
        logger.error(f"✗ Write permission error: {e}")
        return False

    logger.info("✅ All system requirements validated successfully")
    return True


def generate_summary_report(diagrams: Dict[str, str]) -> str:
    """
    Generate a summary report of diagram generation.

    Args:
        diagrams (Dict[str, str]): Mapping of diagram names to file paths

    Returns:
        str: Summary report
    """
    report = []
    report.append("=" * 80)
    report.append("TOPIC 6: STATE MANAGEMENT & BACKENDS - DIAGRAM GENERATION REPORT")
    report.append("=" * 80)
    report.append("")

    # Generation summary
    report.append(f"📊 GENERATION SUMMARY")
    report.append(f"   Total Diagrams Generated: {len(diagrams)}")
    report.append(f"   Output Directory: generated_diagrams/")
    report.append(f"   Resolution: {DIAGRAM_CONFIG['dpi']} DPI")
    report.append(f"   Format: {DIAGRAM_CONFIG['format'].upper()}")
    report.append("")

    # Individual diagram details
    report.append("📋 DIAGRAM DETAILS")
    for i, (name, path) in enumerate(diagrams.items(), 1):
        file_path = Path(path)
        if file_path.exists():
            file_size = file_path.stat().st_size / (1024 * 1024)  # MB
            status = "✅ Generated"
        else:
            file_size = 0
            status = "❌ Failed"

        report.append(f"   {i}. {name}")
        report.append(f"      File: {file_path.name}")
        report.append(f"      Size: {file_size:.2f} MB")
        report.append(f"      Status: {status}")
        report.append("")

    # Learning objectives alignment
    report.append("🎯 LEARNING OBJECTIVES ALIGNMENT")
    report.append("   Figure 6.1: State Architecture and Backend Types")
    report.append("   - Supports understanding of backend selection criteria")
    report.append("   - Illustrates enterprise state architecture patterns")
    report.append("")
    report.append("   Figure 6.2: State Locking and Collaboration Patterns")
    report.append("   - Demonstrates team collaboration workflows")
    report.append("   - Shows conflict resolution strategies")
    report.append("")
    report.append("   Figure 6.3: Remote State Sharing and Data Flow")
    report.append("   - Explains cross-team integration patterns")
    report.append("   - Illustrates data flow management")
    report.append("")
    report.append("   Figure 6.4: State Migration and Disaster Recovery")
    report.append("   - Shows migration strategies and procedures")
    report.append("   - Demonstrates business continuity planning")
    report.append("")
    report.append("   Figure 6.5: Enterprise State Governance and Security")
    report.append("   - Illustrates governance frameworks")
    report.append("   - Shows compliance and security patterns")
    report.append("")

    # Usage instructions
    report.append("📖 USAGE INSTRUCTIONS")
    report.append("   1. Integration with Training Materials:")
    report.append("      - Reference diagrams in Concept.md")
    report.append("      - Include in Lab-6.md exercises")
    report.append("      - Use in presentations and documentation")
    report.append("")
    report.append("   2. Quality Standards:")
    report.append("      - 300 DPI resolution for professional printing")
    report.append("      - AWS brand compliant colors and styling")
    report.append("      - Consistent typography and layout")
    report.append("")
    report.append("   3. Customization:")
    report.append("      - Modify diagram_generation_script.py for changes")
    report.append("      - Update AWS_COLORS for custom branding")
    report.append("      - Adjust DIAGRAM_CONFIG for different output")
    report.append("")

    # Technical specifications
    report.append("🔧 TECHNICAL SPECIFICATIONS")
    report.append(f"   Python Version: {sys.version}")
    try:
        import diagrams as diagrams_lib
        diagrams_version = diagrams_lib.__version__
    except:
        diagrams_version = 'Unknown'
    report.append(f"   Diagrams Library: {diagrams_version}")
    report.append(f"   Output Format: PNG")
    report.append(f"   Color Depth: 24-bit")
    report.append(f"   Compression: Optimized")
    report.append("")

    report.append("=" * 80)
    report.append("🎉 DIAGRAM GENERATION COMPLETED SUCCESSFULLY!")
    report.append("=" * 80)

    return "\n".join(report)


def main():
    """
    Main function to generate all Topic 6 diagrams.
    """
    logger.info("Starting Topic 6: State Management & Backends diagram generation")

    # Validate system requirements
    if not validate_system_requirements():
        logger.error("System requirements validation failed")
        sys.exit(1)

    try:
        # Initialize diagram generator
        generator = StateManagementDiagramGenerator()

        # Generate all diagrams
        diagrams = generator.generate_all_diagrams()

        # Generate and display summary report
        report = generate_summary_report(diagrams)
        print(report)

        # Save report to file
        report_path = Path("generated_diagrams") / "generation_report.txt"
        report_path.write_text(report)
        logger.info(f"Generation report saved to: {report_path}")

        logger.info("🎉 All diagrams generated successfully!")

    except Exception as e:
        logger.error(f"Diagram generation failed: {e}")
        import traceback
        logger.error(traceback.format_exc())
        sys.exit(1)


if __name__ == "__main__":
    main()
