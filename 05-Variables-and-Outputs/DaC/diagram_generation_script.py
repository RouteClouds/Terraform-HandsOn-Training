#!/usr/bin/env python3
"""
AWS Terraform Training - Variables and Outputs
Diagram as Code (DaC) Generation Script

This script generates professional architectural diagrams for Topic 5: Variables and Outputs,
illustrating advanced variable management patterns, output structures, and AWS integration.
"""

import os
import sys
from pathlib import Path

# Import diagram libraries
try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.aws.compute import EC2, AutoScaling
    from diagrams.aws.database import RDS
    from diagrams.aws.network import VPC, PrivateSubnet, PublicSubnet, NATGateway, InternetGateway
    from diagrams.aws.security import IAM, SecretsManager, KMS
    from diagrams.aws.storage import S3
    from diagrams.aws.management import SystemsManager, CloudWatch, CloudTrail
    from diagrams.aws.integration import SNS
    from diagrams.programming.framework import Terraform
    from diagrams.programming.language import Python
    from diagrams.generic.blank import Blank
    from diagrams.generic.database import SQL
    from diagrams.generic.network import Firewall
    print("✅ Successfully imported diagram libraries")
except ImportError as e:
    print(f"❌ Error importing diagram libraries: {e}")
    print("Please install required dependencies: pip install -r requirements.txt")
    sys.exit(1)

# Configuration
OUTPUT_DIR = Path("generated_diagrams")
DPI = 300  # High resolution for professional quality

def setup_output_directory():
    """Create output directory if it doesn't exist."""
    OUTPUT_DIR.mkdir(exist_ok=True)
    print(f"📁 Output directory: {OUTPUT_DIR.absolute()}")

def generate_variable_architecture():
    """Generate variable architecture diagram showing type hierarchies and validation."""
    print("🎨 Generating Variable Architecture Diagram...")
    
    with Diagram(
        "Variable Architecture - Enterprise Patterns",
        filename=str(OUTPUT_DIR / "variable_architecture"),
        show=False,
        direction="TB",
        graph_attr={"dpi": str(DPI), "bgcolor": "white"}
    ):
        # Variable Input Layer
        with Cluster("Variable Input Layer"):
            simple_vars = Terraform("Simple Variables\n(string, number, bool)")
            complex_vars = Terraform("Complex Variables\n(object, map, list)")
            sensitive_vars = Terraform("Sensitive Variables\n(passwords, keys)")
        
        # Validation Layer
        with Cluster("Validation Layer"):
            type_validation = Python("Type Validation")
            business_validation = Python("Business Rules")
            security_validation = Python("Security Checks")
        
        # Processing Layer
        with Cluster("Variable Processing"):
            locals_processing = Terraform("Local Values\nComputation")
            env_processing = Terraform("Environment\nConfiguration")
            inheritance = Terraform("Variable\nInheritance")
        
        # AWS Integration
        with Cluster("AWS Parameter Management"):
            parameter_store = SystemsManager("Parameter Store\n(Non-sensitive)")
            secrets_manager = SecretsManager("Secrets Manager\n(Sensitive)")
            kms = KMS("KMS Encryption")
        
        # Output Layer
        with Cluster("Configuration Output"):
            resource_config = Terraform("Resource\nConfiguration")
            module_config = Terraform("Module\nInputs")
            automation_config = Terraform("Automation\nInterfaces")
        
        # Connections
        simple_vars >> type_validation >> locals_processing
        complex_vars >> business_validation >> env_processing
        sensitive_vars >> security_validation >> inheritance
        
        locals_processing >> resource_config
        env_processing >> module_config
        inheritance >> automation_config
        
        parameter_store >> env_processing
        secrets_manager >> inheritance
        kms >> secrets_manager

def generate_output_architecture():
    """Generate output architecture diagram showing data flow and module integration."""
    print("🎨 Generating Output Architecture Diagram...")
    
    with Diagram(
        "Output Architecture - Module Integration & Data Flow",
        filename=str(OUTPUT_DIR / "output_architecture"),
        show=False,
        direction="LR",
        graph_attr={"dpi": str(DPI), "bgcolor": "white"}
    ):
        # Infrastructure Resources
        with Cluster("Infrastructure Resources"):
            vpc = VPC("VPC")
            subnets = PrivateSubnet("Subnets")
            ec2 = EC2("EC2 Instances")
            rds = RDS("RDS Database")
            s3 = S3("S3 Buckets")
        
        # Output Processing
        with Cluster("Output Processing"):
            structured_outputs = Terraform("Structured\nOutputs")
            sensitive_outputs = Terraform("Sensitive\nOutputs")
            module_outputs = Terraform("Module\nOutputs")
        
        # Integration Interfaces
        with Cluster("Integration Interfaces"):
            module_chaining = Terraform("Module\nChaining")
            automation_api = Python("Automation\nAPIs")
            monitoring_integration = CloudWatch("Monitoring\nIntegration")
        
        # Downstream Consumers
        with Cluster("Downstream Consumers"):
            compute_module = Terraform("Compute\nModule")
            monitoring_module = Terraform("Monitoring\nModule")
            cicd_pipeline = Python("CI/CD\nPipeline")
        
        # Connections
        [vpc, subnets, ec2, rds, s3] >> structured_outputs
        structured_outputs >> module_chaining >> compute_module
        sensitive_outputs >> automation_api >> cicd_pipeline
        module_outputs >> monitoring_integration >> monitoring_module

def generate_environment_configuration():
    """Generate environment configuration diagram showing inheritance patterns."""
    print("🎨 Generating Environment Configuration Diagram...")
    
    with Diagram(
        "Environment Configuration - Inheritance & Overrides",
        filename=str(OUTPUT_DIR / "environment_configuration"),
        show=False,
        direction="TB",
        graph_attr={"dpi": str(DPI), "bgcolor": "white"}
    ):
        # Base Configuration
        with Cluster("Base Configuration"):
            base_config = Terraform("Base Config\n(Common Settings)")
            default_tags = Terraform("Default Tags")
            security_defaults = Terraform("Security Defaults")
        
        # Environment Configurations
        with Cluster("Environment-Specific Configurations"):
            dev_config = Terraform("Development\n(Cost Optimized)")
            staging_config = Terraform("Staging\n(Production-like)")
            prod_config = Terraform("Production\n(High Availability)")
        
        # Override Mechanisms
        with Cluster("Override Processing"):
            inheritance_engine = Python("Inheritance\nEngine")
            merge_logic = Python("Configuration\nMerging")
            validation_engine = Python("Override\nValidation")
        
        # Final Configuration
        with Cluster("Final Configuration"):
            dev_final = Terraform("Dev Final\nConfig")
            staging_final = Terraform("Staging Final\nConfig")
            prod_final = Terraform("Prod Final\nConfig")
        
        # Connections
        base_config >> inheritance_engine
        [default_tags, security_defaults] >> inheritance_engine
        
        dev_config >> merge_logic
        staging_config >> merge_logic
        prod_config >> merge_logic
        
        inheritance_engine >> validation_engine
        merge_logic >> validation_engine
        
        validation_engine >> dev_final
        validation_engine >> staging_final
        validation_engine >> prod_final

def generate_aws_integration():
    """Generate AWS integration diagram showing service interconnections."""
    print("🎨 Generating AWS Integration Diagram...")
    
    with Diagram(
        "AWS Integration - Parameter Management & Security",
        filename=str(OUTPUT_DIR / "aws_integration"),
        show=False,
        direction="TB",
        graph_attr={"dpi": str(DPI), "bgcolor": "white"}
    ):
        # Terraform Configuration
        with Cluster("Terraform Configuration"):
            variables = Terraform("Variables")
            data_sources = Terraform("Data Sources")
            resources = Terraform("Resources")
        
        # AWS Parameter Services
        with Cluster("AWS Parameter Management"):
            parameter_store = SystemsManager("Systems Manager\nParameter Store")
            secrets_manager = SecretsManager("Secrets Manager")
            kms = KMS("KMS Keys")
        
        # AWS Infrastructure
        with Cluster("AWS Infrastructure"):
            vpc = VPC("VPC")
            ec2 = EC2("EC2")
            rds = RDS("RDS")
            s3 = S3("S3")
        
        # Monitoring & Compliance
        with Cluster("Monitoring & Compliance"):
            cloudwatch = CloudWatch("CloudWatch")
            cloudtrail = CloudTrail("CloudTrail")
            sns = SNS("SNS Alerts")
        
        # Connections
        variables >> parameter_store
        variables >> secrets_manager
        data_sources >> parameter_store
        
        secrets_manager >> kms
        parameter_store >> resources
        secrets_manager >> resources
        
        resources >> [vpc, ec2, rds, s3]
        [vpc, ec2, rds, s3] >> cloudwatch
        cloudwatch >> sns
        cloudtrail >> s3

def generate_lab_architecture():
    """Generate complete lab architecture diagram."""
    print("🎨 Generating Lab 5 Architecture Diagram...")
    
    with Diagram(
        "Lab 5 Architecture - Complete Variable & Output Flow",
        filename=str(OUTPUT_DIR / "lab_5_architecture"),
        show=False,
        direction="TB",
        graph_attr={"dpi": str(DPI), "bgcolor": "white"}
    ):
        # Input Layer
        with Cluster("Variable Input Layer"):
            tfvars = Terraform("terraform.tfvars")
            env_vars = Terraform("Environment\nVariables")
            cli_vars = Terraform("CLI Variables")
        
        # Processing Layer
        with Cluster("Variable Processing"):
            validation = Python("Validation\nEngine")
            locals_calc = Python("Local Values\nCalculation")
            env_config = Python("Environment\nConfiguration")
        
        # AWS Services Integration
        with Cluster("AWS Services"):
            with Cluster("Parameter Management"):
                param_store = SystemsManager("Parameter\nStore")
                secrets = SecretsManager("Secrets\nManager")
            
            with Cluster("Infrastructure"):
                vpc = VPC("VPC")
                subnets = PrivateSubnet("Subnets")
                ec2 = EC2("EC2")
                rds = RDS("RDS")
                s3 = S3("S3")
            
            with Cluster("Security"):
                kms = KMS("KMS")
                iam = IAM("IAM")
        
        # Output Layer
        with Cluster("Output Generation"):
            infra_outputs = Terraform("Infrastructure\nOutputs")
            security_outputs = Terraform("Security\nOutputs")
            cost_outputs = Terraform("Cost\nOutputs")
        
        # Integration Layer
        with Cluster("Integration & Automation"):
            module_chain = Terraform("Module\nChaining")
            cicd = Python("CI/CD\nIntegration")
            monitoring = CloudWatch("Monitoring\nSetup")
        
        # Connections
        [tfvars, env_vars, cli_vars] >> validation
        validation >> locals_calc >> env_config
        
        env_config >> param_store
        env_config >> secrets
        
        [param_store, secrets] >> [vpc, subnets, ec2, rds, s3]
        kms >> secrets
        iam >> [ec2, rds]
        
        [vpc, subnets, ec2, rds, s3] >> infra_outputs
        [kms, iam] >> security_outputs
        env_config >> cost_outputs
        
        [infra_outputs, security_outputs, cost_outputs] >> module_chain
        module_chain >> cicd
        infra_outputs >> monitoring

def generate_diagrams_readme():
    """Generate README for the generated diagrams directory."""
    readme_content = """# Generated Diagrams - Variables and Outputs

## 📊 Professional Architectural Diagrams

This directory contains high-quality architectural diagrams for **Topic 5: Variables and Outputs**.

### 🎯 Diagram Collection

1. **variable_architecture.png** - Enterprise variable architecture with type hierarchies and validation
2. **output_architecture.png** - Output patterns for module integration and automation
3. **environment_configuration.png** - Multi-environment configuration management
4. **aws_integration.png** - AWS service integration for parameter management
5. **lab_5_architecture.png** - Complete lab architecture with variable flow

### 📋 Usage Guidelines

- **Resolution**: 300 DPI (print quality)
- **Format**: PNG with transparency
- **License**: Educational use within AWS Terraform Training
- **Attribution**: AWS Terraform Training - Topic 5

### 🔄 Regeneration

To regenerate these diagrams:
```bash
cd ../
python diagram_generation_script.py
```

---
**Generated**: January 2025  
**Version**: 5.0  
**Topic**: Variables and Outputs
"""
    
    diagrams_readme_path = OUTPUT_DIR / "README.md"
    with open(diagrams_readme_path, 'w') as f:
        f.write(readme_content)
    print(f"📝 Generated diagrams README: {diagrams_readme_path}")

def main():
    """Main function to generate all diagrams."""
    print("🚀 Starting Variables and Outputs Diagram Generation")
    print("=" * 60)
    
    # Setup
    setup_output_directory()
    
    # Generate all diagrams
    try:
        generate_variable_architecture()
        generate_output_architecture()
        generate_environment_configuration()
        generate_aws_integration()
        generate_lab_architecture()
        generate_diagrams_readme()
        
        print("=" * 60)
        print("✅ All diagrams generated successfully!")
        print(f"📁 Output location: {OUTPUT_DIR.absolute()}")
        print("🎨 Diagrams ready for use in documentation and presentations")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
