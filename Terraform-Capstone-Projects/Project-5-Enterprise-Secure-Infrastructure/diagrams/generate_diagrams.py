#!/usr/bin/env python3
"""
Diagram Generation Script for Project 5: Enterprise-Grade Secure Infrastructure
Generates comprehensive security architecture diagrams
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, NATGateway, Endpoint, ELB
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3
from diagrams.aws.security import KMS, SecretsManager, IAM, Shield, WAF, Guardduty, SecurityHub
from diagrams.aws.management import Cloudwatch, Cloudtrail, Config
from diagrams.aws.integration import SNS
from diagrams.onprem.client import Users

# Diagram attributes
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5"
}

def generate_hld():
    """Generate High-Level Design diagram"""
    with Diagram("Project 5 - High-Level Design", filename="hld", show=False, graph_attr=graph_attr):
        users = Users("Users")
        
        with Cluster("AWS Cloud"):
            with Cluster("Security Layer"):
                waf = WAF("WAF")
                shield = Shield("Shield")
            
            with Cluster("VPC (10.0.0.0/16)"):
                with Cluster("Private Subnets"):
                    alb = ELB("ALB")
                    ec2 = EC2("Application")
                    rds = RDS("Database")
                
                nat = NATGateway("NAT Gateway")
                endpoints = Endpoint("VPC Endpoints")
            
            with Cluster("Security Services"):
                secrets = SecretsManager("Secrets Manager")
                kms = KMS("KMS")
                guardduty = Guardduty("GuardDuty")
                securityhub = SecurityHub("Security Hub")
            
            with Cluster("Monitoring"):
                cloudtrail = Cloudtrail("CloudTrail")
                cloudwatch = Cloudwatch("CloudWatch")
                config = Config("Config")
        
        users >> waf >> shield >> alb >> ec2 >> rds
        ec2 >> endpoints >> secrets
        ec2 >> endpoints >> kms
        cloudtrail >> guardduty
        cloudwatch >> guardduty
        config >> guardduty
        guardduty >> securityhub

def generate_lld():
    """Generate Low-Level Design diagram"""
    with Diagram("Project 5 - Low-Level Design", filename="lld", show=False, graph_attr=graph_attr):
        with Cluster("VPC (10.0.0.0/16)"):
            with Cluster("AZ1 - Private Subnet"):
                app1 = EC2("App-1")
                db1 = RDS("DB-1")
            
            with Cluster("AZ2 - Private Subnet"):
                app2 = EC2("App-2")
                db2 = RDS("DB-2")
            
            with Cluster("AZ3 - Private Subnet"):
                app3 = EC2("App-3")
            
            nat = NATGateway("NAT")
            
            with Cluster("VPC Endpoints"):
                s3_ep = Endpoint("S3")
                secrets_ep = Endpoint("Secrets Manager")
                kms_ep = Endpoint("KMS")
                ssm_ep = Endpoint("SSM")
        
        app1 >> nat
        app2 >> nat
        app3 >> nat
        app1 >> s3_ep
        app2 >> secrets_ep
        app3 >> kms_ep
        app1 >> db1
        app2 >> db2

def generate_security_architecture():
    """Generate Security Architecture diagram"""
    with Diagram("Security Architecture", filename="security_architecture", show=False, graph_attr=graph_attr):
        with Cluster("Defense in Depth"):
            with Cluster("Layer 1: Network Security"):
                vpc = VPC("VPC")
                nacl = VPC("NACLs")
                sg = VPC("Security Groups")
            
            with Cluster("Layer 2: Identity Security"):
                iam = IAM("IAM Roles")
                mfa = IAM("MFA")
            
            with Cluster("Layer 3: Data Security"):
                kms = KMS("KMS")
                secrets = SecretsManager("Secrets Manager")
                encryption = KMS("Encryption")
            
            with Cluster("Layer 4: Application Security"):
                waf = WAF("WAF")
                shield = Shield("Shield")
            
            with Cluster("Layer 5: Monitoring"):
                cloudtrail = Cloudtrail("CloudTrail")
                guardduty = Guardduty("GuardDuty")
                securityhub = SecurityHub("Security Hub")
            
            with Cluster("Layer 6: Compliance"):
                config = Config("Config")
                backup = S3("Backup")
        
        vpc >> nacl >> sg >> iam >> mfa
        iam >> kms >> secrets >> encryption
        encryption >> waf >> shield
        [cloudtrail, guardduty] >> securityhub
        config >> backup

def generate_network_security():
    """Generate Network Security diagram"""
    with Diagram("Network Security", filename="network_security", show=False, graph_attr=graph_attr):
        internet = Users("Internet")
        
        with Cluster("VPC"):
            with Cluster("Network ACLs"):
                nacl = VPC("Stateless Firewall")
            
            with Cluster("Private Subnets Only"):
                with Cluster("Security Groups"):
                    alb_sg = VPC("ALB SG\n(HTTPS:443)")
                    app_sg = VPC("App SG\n(8080)")
                    db_sg = VPC("DB SG\n(5432)")
                
                alb = ELB("ALB")
                app = EC2("Application")
                db = RDS("Database")
            
            nat = NATGateway("NAT Gateway")
            
            with Cluster("VPC Endpoints"):
                endpoints = Endpoint("Private\nConnectivity")
        
        internet >> nacl >> alb_sg >> alb >> app_sg >> app >> db_sg >> db
        app >> nat >> internet
        app >> endpoints

def generate_iam_architecture():
    """Generate IAM Architecture diagram"""
    with Diagram("IAM Architecture", filename="iam_architecture", show=False, graph_attr=graph_attr):
        with Cluster("IAM Least Privilege"):
            with Cluster("EC2 Instance Role"):
                ec2_role = IAM("EC2 Role")
                ssm_policy = IAM("SSM Policy")
                secrets_policy = IAM("Secrets Policy")
                cloudwatch_policy = IAM("CloudWatch Policy")
            
            with Cluster("Lambda Role"):
                lambda_role = IAM("Lambda Role")
                lambda_policy = IAM("Lambda Policy")
            
            with Cluster("Service Roles"):
                cloudtrail_role = IAM("CloudTrail Role")
                config_role = IAM("Config Role")
                flowlogs_role = IAM("Flow Logs Role")
        
        ec2 = EC2("EC2 Instance")
        secrets = SecretsManager("Secrets")
        cloudwatch = Cloudwatch("CloudWatch")
        
        ec2 >> ec2_role
        ec2_role >> [ssm_policy, secrets_policy, cloudwatch_policy]
        secrets_policy >> secrets
        cloudwatch_policy >> cloudwatch

def generate_encryption_strategy():
    """Generate Encryption Strategy diagram"""
    with Diagram("Encryption Strategy", filename="encryption_strategy", show=False, graph_attr=graph_attr):
        with Cluster("KMS Encryption"):
            kms = KMS("Customer\nManaged Key")
            
            with Cluster("Encrypted at Rest"):
                ebs = EC2("EBS Volumes")
                s3 = S3("S3 Buckets")
                rds = RDS("RDS Database")
                secrets = SecretsManager("Secrets Manager")
                logs = Cloudwatch("CloudWatch Logs")
                sns = SNS("SNS Topics")
            
            with Cluster("Encrypted in Transit"):
                tls = Shield("TLS/SSL")
                https = Shield("HTTPS")
        
        kms >> [ebs, s3, rds, secrets, logs, sns]
        [tls, https] >> kms

def generate_secrets_management():
    """Generate Secrets Management diagram"""
    with Diagram("Secrets Management", filename="secrets_management", show=False, graph_attr=graph_attr):
        with Cluster("Secrets Manager"):
            with Cluster("Secrets"):
                db_secret = SecretsManager("DB Password")
                api_secret = SecretsManager("API Key")
                app_secret = SecretsManager("App Config")
            
            kms = KMS("KMS Key")
            rotation = SecretsManager("Auto Rotation")
        
        with Cluster("Applications"):
            app = EC2("Application")
            lambda_func = EC2("Lambda")
        
        with Cluster("Monitoring"):
            cloudwatch = Cloudwatch("CloudWatch")
            sns = SNS("Alerts")
        
        [db_secret, api_secret, app_secret] >> kms
        app >> db_secret
        app >> api_secret
        lambda_func >> app_secret
        rotation >> [db_secret, api_secret]
        [db_secret, api_secret, app_secret] >> cloudwatch >> sns

def generate_compliance_framework():
    """Generate Compliance Framework diagram"""
    with Diagram("Compliance Framework", filename="compliance_framework", show=False, graph_attr=graph_attr):
        with Cluster("AWS Config"):
            config = Config("Config Recorder")
            
            with Cluster("CIS Benchmarks"):
                cis1 = Config("IAM Rules")
                cis2 = Config("Logging Rules")
                cis3 = Config("Monitoring Rules")
                cis4 = Config("Networking Rules")
            
            conformance = Config("Conformance Pack")
        
        with Cluster("Security Hub"):
            securityhub = SecurityHub("Security Hub")
            findings = SecurityHub("Findings")
        
        with Cluster("Remediation"):
            sns = SNS("Alerts")
            lambda_func = EC2("Auto Remediation")
        
        config >> [cis1, cis2, cis3, cis4] >> conformance >> securityhub >> findings
        findings >> sns >> lambda_func

def generate_monitoring_architecture():
    """Generate Monitoring Architecture diagram"""
    with Diagram("Monitoring Architecture", filename="monitoring_architecture", show=False, graph_attr=graph_attr):
        with Cluster("Data Sources"):
            cloudtrail = Cloudtrail("CloudTrail")
            flowlogs = VPC("VPC Flow Logs")
            app_logs = Cloudwatch("App Logs")
        
        with Cluster("Analysis"):
            cloudwatch = Cloudwatch("CloudWatch")
            guardduty = Guardduty("GuardDuty")
            securityhub = SecurityHub("Security Hub")
        
        with Cluster("Alerting"):
            alarms = Cloudwatch("Alarms")
            sns = SNS("SNS")
            email = Users("Email")
        
        [cloudtrail, flowlogs, app_logs] >> cloudwatch
        [cloudtrail, flowlogs] >> guardduty
        [cloudwatch, guardduty] >> securityhub
        securityhub >> alarms >> sns >> email

def generate_troubleshooting_workflow():
    """Generate Troubleshooting Workflow diagram"""
    with Diagram("Troubleshooting Workflow", filename="troubleshooting_workflow", show=False, graph_attr=graph_attr):
        with Cluster("Issue Detection"):
            alarm = Cloudwatch("CloudWatch Alarm")
            guardduty = Guardduty("GuardDuty Finding")
            user_report = Users("User Report")
        
        with Cluster("Investigation"):
            cloudtrail = Cloudtrail("CloudTrail Logs")
            flowlogs = VPC("Flow Logs")
            app_logs = Cloudwatch("Application Logs")
        
        with Cluster("Analysis"):
            analyze = Cloudwatch("Log Analysis")
            correlate = Cloudwatch("Correlation")
        
        with Cluster("Resolution"):
            fix = EC2("Apply Fix")
            verify = Cloudwatch("Verify")
            document = S3("Document")
        
        alarm >> cloudtrail
        guardduty >> flowlogs
        user_report >> app_logs
        [cloudtrail, flowlogs, app_logs] >> analyze >> correlate
        correlate >> fix >> verify >> document

def main():
    """Generate all diagrams"""
    print("Generating Project 5 architecture diagrams...")
    
    try:
        generate_hld()
        print("✓ Generated: hld.png")
        
        generate_lld()
        print("✓ Generated: lld.png")
        
        generate_security_architecture()
        print("✓ Generated: security_architecture.png")
        
        generate_network_security()
        print("✓ Generated: network_security.png")
        
        generate_iam_architecture()
        print("✓ Generated: iam_architecture.png")
        
        generate_encryption_strategy()
        print("✓ Generated: encryption_strategy.png")
        
        generate_secrets_management()
        print("✓ Generated: secrets_management.png")
        
        generate_compliance_framework()
        print("✓ Generated: compliance_framework.png")
        
        generate_monitoring_architecture()
        print("✓ Generated: monitoring_architecture.png")
        
        generate_troubleshooting_workflow()
        print("✓ Generated: troubleshooting_workflow.png")
        
        print("\n✅ All diagrams generated successfully!")
        print("📁 Diagrams saved in the current directory")
        
    except Exception as e:
        print(f"\n❌ Error generating diagrams: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())

