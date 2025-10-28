#!/usr/bin/env python3
"""
Diagram Generation Script for Project 1: Multi-Tier Web Application Infrastructure
Generates comprehensive architecture diagrams using the diagrams library
"""

import os
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, EC2AutoScaling
from diagrams.aws.network import VPC, PublicSubnet, PrivateSubnet, InternetGateway, NATGateway, Route53, ELB, CloudFront
from diagrams.aws.database import RDS, RDSPostgresqlInstance
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM, KMS, SecretsManager
from diagrams.aws.management import Cloudwatch, CloudwatchAlarm
from diagrams.aws.integration import SNS
from diagrams.onprem.client import Users, Client
from diagrams.onprem.monitoring import Grafana

# Configuration
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
GRAPH_ATTR = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "0.5",
}

def generate_high_level_design():
    """Generate high-level design diagram"""
    print("Generating high-level design diagram...")
    
    with Diagram(
        "High-Level Design - Multi-Tier Web Application",
        filename=os.path.join(OUTPUT_DIR, "hld"),
        show=False,
        direction="TB",
        graph_attr=GRAPH_ATTR
    ):
        users = Users("End Users")
        
        with Cluster("AWS Cloud"):
            route53 = Route53("Route53\nDNS")
            cloudfront = CloudFront("CloudFront\nCDN")
            
            with Cluster("VPC (10.0.0.0/16)"):
                with Cluster("Public Subnets"):
                    alb = ELB("Application\nLoad Balancer")
                    nat = NATGateway("NAT\nGateways")
                
                with Cluster("Private Subnets"):
                    with Cluster("Compute Tier"):
                        asg = EC2AutoScaling("Auto Scaling\nGroup")
                        ec2_instances = [
                            EC2("Web Server 1"),
                            EC2("Web Server 2"),
                            EC2("Web Server N")
                        ]
                    
                    with Cluster("Database Tier"):
                        rds_primary = RDSPostgresqlInstance("RDS Primary\n(Multi-AZ)")
                        rds_replica = RDSPostgresqlInstance("RDS Replica\n(Read)")
                
                with Cluster("Storage"):
                    s3_static = S3("Static Assets\nBucket")
                    s3_logs = S3("Logs\nBucket")
                
                with Cluster("Monitoring"):
                    cloudwatch = Cloudwatch("CloudWatch\nLogs & Metrics")
                    alarms = CloudwatchAlarm("CloudWatch\nAlarms")
                    sns = SNS("SNS\nNotifications")
        
        # Connections
        users >> Edge(label="HTTPS") >> route53
        route53 >> Edge(label="DNS") >> cloudfront
        cloudfront >> Edge(label="Cache Miss") >> alb
        cloudfront >> Edge(label="Cache Hit") >> s3_static
        
        alb >> Edge(label="HTTP") >> ec2_instances
        asg >> Edge(label="Manages") >> ec2_instances
        
        ec2_instances >> Edge(label="Query") >> rds_primary
        ec2_instances >> Edge(label="Read") >> rds_replica
        rds_primary >> Edge(label="Replicate") >> rds_replica
        
        ec2_instances >> Edge(label="Upload") >> s3_static
        ec2_instances >> Edge(label="Logs") >> cloudwatch
        
        alb >> Edge(label="Metrics") >> cloudwatch
        rds_primary >> Edge(label="Metrics") >> cloudwatch
        cloudwatch >> Edge(label="Trigger") >> alarms
        alarms >> Edge(label="Notify") >> sns
    
    print("✓ High-level design diagram generated")

def generate_low_level_design():
    """Generate low-level design diagram with detailed components"""
    print("Generating low-level design diagram...")
    
    with Diagram(
        "Low-Level Design - Detailed Architecture",
        filename=os.path.join(OUTPUT_DIR, "lld"),
        show=False,
        direction="TB",
        graph_attr=GRAPH_ATTR
    ):
        users = Users("Internet Users")
        
        with Cluster("AWS Cloud - us-east-1"):
            route53 = Route53("Route53\nHosted Zone")
            cloudfront = CloudFront("CloudFront\nDistribution")
            
            with Cluster("VPC - 10.0.0.0/16"):
                igw = InternetGateway("Internet\nGateway")
                
                with Cluster("Availability Zone A"):
                    with Cluster("Public Subnet A\n10.0.1.0/24"):
                        nat_a = NATGateway("NAT-A")
                    
                    with Cluster("Private Subnet A\n10.0.11.0/24"):
                        ec2_a = EC2("Web-A\nt3.micro")
                
                with Cluster("Availability Zone B"):
                    with Cluster("Public Subnet B\n10.0.2.0/24"):
                        nat_b = NATGateway("NAT-B")
                        alb = ELB("ALB\napp/webapp")
                    
                    with Cluster("Private Subnet B\n10.0.12.0/24"):
                        ec2_b = EC2("Web-B\nt3.micro")
                
                with Cluster("Availability Zone C"):
                    with Cluster("Public Subnet C\n10.0.3.0/24"):
                        nat_c = NATGateway("NAT-C")
                    
                    with Cluster("Private Subnet C\n10.0.13.0/24"):
                        ec2_c = EC2("Web-C\nt3.micro")
                
                with Cluster("Database Subnets"):
                    rds = RDS("RDS PostgreSQL\ndb.t3.micro\nMulti-AZ")
                
                with Cluster("Security & Monitoring"):
                    kms = KMS("KMS\nEncryption")
                    iam = IAM("IAM\nRoles")
                    cw = Cloudwatch("CloudWatch")
                
                with Cluster("Storage"):
                    s3 = S3("S3 Buckets")
        
        # Connections
        users >> Edge(label="HTTPS") >> route53
        route53 >> cloudfront
        cloudfront >> igw
        igw >> alb
        
        alb >> ec2_a
        alb >> ec2_b
        alb >> ec2_c
        
        ec2_a >> nat_a >> igw
        ec2_b >> nat_b >> igw
        ec2_c >> nat_c >> igw
        
        [ec2_a, ec2_b, ec2_c] >> rds
        [ec2_a, ec2_b, ec2_c] >> s3
        
        [ec2_a, ec2_b, ec2_c, alb, rds] >> cw
        [rds, s3] >> kms
        [ec2_a, ec2_b, ec2_c] >> iam
    
    print("✓ Low-level design diagram generated")

def generate_vpc_architecture():
    """Generate VPC architecture diagram"""
    print("Generating VPC architecture diagram...")
    
    with Diagram(
        "VPC Architecture - Network Design",
        filename=os.path.join(OUTPUT_DIR, "vpc_architecture"),
        show=False,
        direction="LR",
        graph_attr=GRAPH_ATTR
    ):
        internet = Users("Internet")
        
        with Cluster("VPC - 10.0.0.0/16"):
            igw = InternetGateway("Internet Gateway")
            
            with Cluster("Public Subnets (3 AZs)"):
                pub_a = PublicSubnet("10.0.1.0/24\nus-east-1a")
                pub_b = PublicSubnet("10.0.2.0/24\nus-east-1b")
                pub_c = PublicSubnet("10.0.3.0/24\nus-east-1c")
                
                nat_a = NATGateway("NAT-A")
                nat_b = NATGateway("NAT-B")
                nat_c = NATGateway("NAT-C")
            
            with Cluster("Private Subnets (3 AZs)"):
                priv_a = PrivateSubnet("10.0.11.0/24\nus-east-1a")
                priv_b = PrivateSubnet("10.0.12.0/24\nus-east-1b")
                priv_c = PrivateSubnet("10.0.13.0/24\nus-east-1c")
        
        # Connections
        internet >> igw
        igw >> [pub_a, pub_b, pub_c]
        
        pub_a >> nat_a >> priv_a
        pub_b >> nat_b >> priv_b
        pub_c >> nat_c >> priv_c
    
    print("✓ VPC architecture diagram generated")

def generate_compute_architecture():
    """Generate compute architecture diagram"""
    print("Generating compute architecture diagram...")
    
    with Diagram(
        "Compute Architecture - Auto Scaling",
        filename=os.path.join(OUTPUT_DIR, "compute_architecture"),
        show=False,
        direction="TB",
        graph_attr=GRAPH_ATTR
    ):
        with Cluster("Auto Scaling Configuration"):
            asg = EC2AutoScaling("Auto Scaling Group\nMin: 2, Max: 6, Desired: 2")
            
            with Cluster("Launch Template"):
                lt_config = EC2("Launch Template\nAMI: Amazon Linux 2023\nType: t3.micro\nIMDSv2: Required")
            
            with Cluster("Scaling Policies"):
                scale_up = CloudwatchAlarm("Scale Up\nCPU > 70%")
                scale_down = CloudwatchAlarm("Scale Down\nCPU < 20%")
            
            with Cluster("Running Instances"):
                instances = [
                    EC2("Instance 1\nAZ-A"),
                    EC2("Instance 2\nAZ-B"),
                    EC2("Instance N\nAZ-C")
                ]
            
            with Cluster("Monitoring"):
                cw = Cloudwatch("CloudWatch\nMetrics")
        
        # Connections
        asg >> Edge(label="Uses") >> lt_config
        asg >> Edge(label="Manages") >> instances
        
        instances >> Edge(label="Metrics") >> cw
        cw >> Edge(label="Trigger") >> scale_up
        cw >> Edge(label="Trigger") >> scale_down
        
        scale_up >> Edge(label="Add Instances") >> asg
        scale_down >> Edge(label="Remove Instances") >> asg
    
    print("✓ Compute architecture diagram generated")

def generate_database_architecture():
    """Generate database architecture diagram"""
    print("Generating database architecture diagram...")
    
    with Diagram(
        "Database Architecture - RDS Multi-AZ",
        filename=os.path.join(OUTPUT_DIR, "database_architecture"),
        show=False,
        direction="LR",
        graph_attr=GRAPH_ATTR
    ):
        with Cluster("Application Tier"):
            app_servers = [
                EC2("Web-1"),
                EC2("Web-2"),
                EC2("Web-3")
            ]
        
        with Cluster("Database Tier"):
            with Cluster("Primary AZ"):
                rds_primary = RDSPostgresqlInstance("RDS Primary\nPostgreSQL 15.x\ndb.t3.micro")
            
            with Cluster("Standby AZ"):
                rds_standby = RDSPostgresqlInstance("RDS Standby\n(Synchronous\nReplication)")
            
            with Cluster("Read Replica"):
                rds_replica = RDSPostgresqlInstance("Read Replica\n(Asynchronous\nReplication)")
        
        with Cluster("Backup & Security"):
            s3_backup = S3("Automated\nBackups")
            kms = KMS("KMS\nEncryption")
        
        # Connections
        app_servers >> Edge(label="Write/Read") >> rds_primary
        app_servers >> Edge(label="Read Only") >> rds_replica
        
        rds_primary >> Edge(label="Sync Replication") >> rds_standby
        rds_primary >> Edge(label="Async Replication") >> rds_replica
        
        rds_primary >> Edge(label="Backup") >> s3_backup
        [rds_primary, rds_standby, rds_replica] >> Edge(label="Encrypt") >> kms
    
    print("✓ Database architecture diagram generated")

def generate_cdn_architecture():
    """Generate CDN architecture diagram"""
    print("Generating CDN architecture diagram...")
    
    with Diagram(
        "CDN Architecture - CloudFront Distribution",
        filename=os.path.join(OUTPUT_DIR, "cdn_architecture"),
        show=False,
        direction="TB",
        graph_attr=GRAPH_ATTR
    ):
        users = Users("Global Users")
        
        with Cluster("CloudFront Distribution"):
            cf = CloudFront("CloudFront\nEdge Locations")
            
            with Cluster("Origins"):
                with Cluster("S3 Origin"):
                    s3 = S3("Static Assets\nBucket")
                    oai = IAM("Origin Access\nIdentity")
                
                with Cluster("ALB Origin"):
                    alb = ELB("Application\nLoad Balancer")
                    ec2 = [EC2("Web-1"), EC2("Web-2")]
        
        with Cluster("DNS"):
            route53 = Route53("Route53\nAlias Record")
        
        # Connections
        users >> Edge(label="HTTPS") >> route53
        route53 >> Edge(label="Resolve") >> cf
        
        cf >> Edge(label="Cache Miss\nStatic Content") >> oai
        oai >> s3
        
        cf >> Edge(label="Cache Miss\nDynamic Content") >> alb
        alb >> ec2
    
    print("✓ CDN architecture diagram generated")

def generate_security_architecture():
    """Generate security architecture diagram"""
    print("Generating security architecture diagram...")
    
    with Diagram(
        "Security Architecture - Defense in Depth",
        filename=os.path.join(OUTPUT_DIR, "security_architecture"),
        show=False,
        direction="TB",
        graph_attr=GRAPH_ATTR
    ):
        with Cluster("Security Layers"):
            with Cluster("Network Security"):
                vpc = VPC("VPC\nIsolation")
                sg_alb = IAM("ALB SG\n80, 443 from 0.0.0.0/0")
                sg_ec2 = IAM("EC2 SG\n80 from ALB SG")
                sg_rds = IAM("RDS SG\n5432 from EC2 SG")
            
            with Cluster("Identity & Access"):
                iam_role = IAM("IAM Roles\nEC2 Instance Profile")
                iam_policy = IAM("IAM Policies\nLeast Privilege")
            
            with Cluster("Encryption"):
                kms = KMS("KMS Keys\nData Encryption")
                ssl = KMS("SSL/TLS\nIn-Transit")
            
            with Cluster("Monitoring & Logging"):
                cw_logs = Cloudwatch("CloudWatch\nLogs")
                flow_logs = Cloudwatch("VPC Flow\nLogs")
                alarms = CloudwatchAlarm("Security\nAlarms")
        
        # Connections
        vpc >> [sg_alb, sg_ec2, sg_rds]
        sg_alb >> sg_ec2 >> sg_rds
        
        iam_role >> iam_policy
        
        [sg_alb, sg_ec2, sg_rds] >> cw_logs
        vpc >> flow_logs
        [cw_logs, flow_logs] >> alarms
    
    print("✓ Security architecture diagram generated")

def generate_monitoring_architecture():
    """Generate monitoring architecture diagram"""
    print("Generating monitoring architecture diagram...")

    with Diagram(
        "Monitoring Architecture - CloudWatch",
        filename=os.path.join(OUTPUT_DIR, "monitoring_architecture"),
        show=False,
        direction="LR",
        graph_attr=GRAPH_ATTR
    ):
        with Cluster("Infrastructure"):
            alb = ELB("ALB")
            ec2_1 = EC2("EC2-1")
            ec2_2 = EC2("EC2-2")
            rds = RDS("RDS")
            cloudfront = CloudFront("CloudFront")

        with Cluster("CloudWatch"):
            with Cluster("Logs"):
                log_group = Cloudwatch("Log Groups")
                log_streams = Cloudwatch("Log Streams")

            with Cluster("Metrics"):
                metrics = Cloudwatch("Custom Metrics")
                dashboard = Cloudwatch("Dashboard")

            with Cluster("Alarms"):
                alarm_alb = CloudwatchAlarm("ALB Alarms")
                alarm_ec2 = CloudwatchAlarm("EC2 Alarms")
                alarm_rds = CloudwatchAlarm("RDS Alarms")

        with Cluster("Notifications"):
            sns = SNS("SNS Topic")
            email = Client("Email\nNotifications")

        # Connections
        alb >> log_group
        ec2_1 >> log_group
        ec2_2 >> log_group
        rds >> log_group
        cloudfront >> log_group
        log_group >> log_streams

        alb >> metrics
        ec2_1 >> metrics
        ec2_2 >> metrics
        rds >> metrics
        cloudfront >> metrics
        metrics >> dashboard

        metrics >> alarm_alb
        metrics >> alarm_ec2
        metrics >> alarm_rds
        alarm_alb >> sns
        alarm_ec2 >> sns
        alarm_rds >> sns
        sns >> email

    print("✓ Monitoring architecture diagram generated")

def generate_deployment_flow():
    """Generate deployment flow diagram"""
    print("Generating deployment flow diagram...")
    
    with Diagram(
        "Deployment Flow - CI/CD Pipeline",
        filename=os.path.join(OUTPUT_DIR, "deployment_flow"),
        show=False,
        direction="LR",
        graph_attr=GRAPH_ATTR
    ):
        with Cluster("Development"):
            dev = Client("Developer")
            git = Client("Git Repository")
        
        with Cluster("CI/CD Pipeline"):
            validate = Client("Terraform\nValidate")
            plan = Client("Terraform\nPlan")
            apply = Client("Terraform\nApply")
        
        with Cluster("AWS Infrastructure"):
            vpc = VPC("VPC")
            ec2 = EC2("EC2 Instances")
            rds = RDS("RDS Database")
            alb = ELB("Load Balancer")
        
        with Cluster("Validation"):
            test = Client("Automated\nTests")
            monitor = Cloudwatch("Monitoring")
        
        # Connections
        dev >> Edge(label="1. Commit") >> git
        git >> Edge(label="2. Trigger") >> validate
        validate >> Edge(label="3. Success") >> plan
        plan >> Edge(label="4. Review") >> apply
        apply >> Edge(label="5. Deploy") >> [vpc, ec2, rds, alb]
        [vpc, ec2, rds, alb] >> Edge(label="6. Verify") >> test
        test >> Edge(label="7. Monitor") >> monitor
    
    print("✓ Deployment flow diagram generated")

def main():
    """Main function to generate all diagrams"""
    print("=" * 70)
    print("Diagram Generation Script")
    print("Project 1: Multi-Tier Web Application Infrastructure")
    print("=" * 70)
    print()
    
    try:
        # Generate all diagrams
        generate_high_level_design()
        generate_low_level_design()
        generate_vpc_architecture()
        generate_compute_architecture()
        generate_database_architecture()
        generate_cdn_architecture()
        generate_security_architecture()
        generate_monitoring_architecture()
        generate_deployment_flow()
        
        print()
        print("=" * 70)
        print("✓ All diagrams generated successfully!")
        print(f"✓ Output directory: {OUTPUT_DIR}")
        print("=" * 70)
        
        # List generated files
        print("\nGenerated files:")
        for file in sorted(os.listdir(OUTPUT_DIR)):
            if file.endswith('.png'):
                file_path = os.path.join(OUTPUT_DIR, file)
                file_size = os.path.getsize(file_path) / 1024  # KB
                print(f"  - {file} ({file_size:.1f} KB)")
        
    except Exception as e:
        print(f"\n✗ Error generating diagrams: {e}")
        raise

if __name__ == "__main__":
    main()

