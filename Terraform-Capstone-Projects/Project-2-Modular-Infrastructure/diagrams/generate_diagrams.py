#!/usr/bin/env python3
"""
Diagram Generation Script for Project 2: Modular Infrastructure
Generates architecture diagrams showing module composition and dependencies
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, EC2AutoScaling
from diagrams.aws.network import VPC, ELB, Route53, NATGateway, InternetGateway
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM, KMS, Shield
from diagrams.aws.management import Cloudwatch
from diagrams.aws.general import Users

# Diagram attributes
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5"
}

def generate_hld():
    """Generate High-Level Design diagram"""
    with Diagram("Project 2 - High-Level Design", filename="hld", show=False, graph_attr=graph_attr):
        users = Users("Users")
        
        with Cluster("AWS Cloud"):
            route53 = Route53("Route53")
            
            with Cluster("VPC Module"):
                vpc = VPC("VPC\n10.0.0.0/16")
                
                with Cluster("Public Subnets"):
                    igw = InternetGateway("IGW")
                    alb = ELB("ALB")
                    nat = NATGateway("NAT")
                
                with Cluster("Private Subnets"):
                    asg = EC2AutoScaling("Auto Scaling")
                    rds = RDS("RDS")
            
            s3 = S3("S3 Bucket")
            cloudwatch = Cloudwatch("CloudWatch")
        
        users >> route53 >> alb
        alb >> asg
        asg >> rds
        asg >> s3
        asg >> cloudwatch

def generate_lld():
    """Generate Low-Level Design diagram"""
    with Diagram("Project 2 - Low-Level Design", filename="lld", show=False, graph_attr=graph_attr):
        users = Users("Users")
        
        with Cluster("AWS Cloud"):
            with Cluster("DNS Module"):
                route53 = Route53("Route53\nHosted Zone")
            
            with Cluster("VPC Module"):
                vpc = VPC("VPC")
                
                with Cluster("Public Subnets (3 AZs)"):
                    igw = InternetGateway("IGW")
                    alb_module = ELB("Load Balancer\nModule")
                    nat1 = NATGateway("NAT-1")
                    nat2 = NATGateway("NAT-2")
                    nat3 = NATGateway("NAT-3")
                
                with Cluster("Private Subnets (3 AZs)"):
                    with Cluster("Compute Module"):
                        asg = EC2AutoScaling("ASG")
                        ec2_1 = EC2("EC2-1")
                        ec2_2 = EC2("EC2-2")
                    
                    with Cluster("Database Module"):
                        rds_primary = RDS("RDS Primary")
                        rds_standby = RDS("RDS Standby")
            
            with Cluster("Security Module"):
                sg = Shield("Security\nGroups")
                iam = IAM("IAM Roles")
                kms = KMS("KMS Keys")
            
            with Cluster("Storage Module"):
                s3 = S3("S3 Bucket")
            
            with Cluster("Monitoring Module"):
                cw = Cloudwatch("CloudWatch")
        
        users >> route53 >> alb_module
        alb_module >> asg
        asg >> [ec2_1, ec2_2]
        ec2_1 >> rds_primary
        ec2_2 >> rds_primary
        rds_primary >> rds_standby
        [ec2_1, ec2_2] >> s3
        [ec2_1, ec2_2] >> cw

def generate_module_architecture():
    """Generate Module Architecture diagram"""
    with Diagram("Module Architecture", filename="module_architecture", show=False, graph_attr=graph_attr):
        with Cluster("Root Module"):
            root = EC2("main.tf")
            
            with Cluster("Child Modules"):
                vpc_mod = VPC("VPC Module")
                sec_mod = Shield("Security Module")
                compute_mod = EC2AutoScaling("Compute Module")
                lb_mod = ELB("Load Balancer Module")
                db_mod = RDS("Database Module")
                storage_mod = S3("Storage Module")
                monitor_mod = Cloudwatch("Monitoring Module")
                dns_mod = Route53("DNS Module")
            
            root >> vpc_mod
            root >> sec_mod
            root >> compute_mod
            root >> lb_mod
            root >> db_mod
            root >> storage_mod
            root >> monitor_mod
            root >> dns_mod

def generate_module_dependencies():
    """Generate Module Dependencies diagram"""
    with Diagram("Module Dependencies", filename="module_dependencies", show=False, graph_attr=graph_attr):
        vpc = VPC("VPC Module")
        security = Shield("Security Module")
        compute = EC2AutoScaling("Compute Module")
        lb = ELB("Load Balancer Module")
        db = RDS("Database Module")
        storage = S3("Storage Module")
        monitoring = Cloudwatch("Monitoring Module")
        dns = Route53("DNS Module")
        
        vpc >> security
        security >> compute
        security >> lb
        security >> db
        security >> storage
        compute >> monitoring
        lb >> monitoring
        db >> monitoring
        lb >> dns

def generate_vpc_module_design():
    """Generate VPC Module Design diagram"""
    with Diagram("VPC Module Design", filename="vpc_module_design", show=False, graph_attr=graph_attr):
        with Cluster("VPC Module"):
            with Cluster("Inputs"):
                inputs = EC2("vpc_cidr\navailability_zones\nsubnet_cidrs")
            
            with Cluster("Resources"):
                vpc = VPC("VPC")
                igw = InternetGateway("IGW")
                nat = NATGateway("NAT Gateways")
                subnets = EC2("Subnets")
            
            with Cluster("Outputs"):
                outputs = EC2("vpc_id\nsubnet_ids\nnat_gateway_ids")
            
            inputs >> vpc
            vpc >> [igw, nat, subnets]
            [vpc, igw, nat, subnets] >> outputs

def generate_compute_module_design():
    """Generate Compute Module Design diagram"""
    with Diagram("Compute Module Design", filename="compute_module_design", show=False, graph_attr=graph_attr):
        with Cluster("Compute Module"):
            with Cluster("Inputs"):
                inputs = EC2("instance_type\nmin_size\nmax_size")
            
            with Cluster("Resources"):
                lt = EC2("Launch Template")
                asg = EC2AutoScaling("Auto Scaling Group")
                policy = Cloudwatch("Scaling Policies")
            
            with Cluster("Outputs"):
                outputs = EC2("asg_name\nasg_arn\nlaunch_template_id")
            
            inputs >> lt
            lt >> asg
            asg >> policy
            [lt, asg, policy] >> outputs

def generate_database_module_design():
    """Generate Database Module Design diagram"""
    with Diagram("Database Module Design", filename="database_module_design", show=False, graph_attr=graph_attr):
        with Cluster("Database Module"):
            with Cluster("Inputs"):
                inputs = RDS("engine\ninstance_class\nmulti_az")
            
            with Cluster("Resources"):
                subnet_group = RDS("DB Subnet Group")
                rds = RDS("RDS Instance")
                monitoring = Cloudwatch("Enhanced Monitoring")
            
            with Cluster("Outputs"):
                outputs = RDS("endpoint\naddress\nport")
            
            inputs >> subnet_group
            subnet_group >> rds
            rds >> monitoring
            [subnet_group, rds, monitoring] >> outputs

def generate_module_composition():
    """Generate Module Composition diagram"""
    with Diagram("Module Composition", filename="module_composition", show=False, graph_attr=graph_attr):
        with Cluster("Infrastructure as Code"):
            with Cluster("Root Module"):
                main = EC2("main.tf")
                variables = EC2("variables.tf")
                outputs = EC2("outputs.tf")
            
            with Cluster("Reusable Modules"):
                with Cluster("Network Layer"):
                    vpc = VPC("VPC")
                    security = Shield("Security")
                
                with Cluster("Compute Layer"):
                    compute = EC2AutoScaling("Compute")
                    lb = ELB("Load Balancer")
                
                with Cluster("Data Layer"):
                    db = RDS("Database")
                    storage = S3("Storage")
                
                with Cluster("Observability Layer"):
                    monitoring = Cloudwatch("Monitoring")
                    dns = Route53("DNS")
            
            variables >> main
            main >> [vpc, security, compute, lb, db, storage, monitoring, dns]
            [vpc, security, compute, lb, db, storage, monitoring, dns] >> outputs

def generate_testing_strategy():
    """Generate Testing Strategy diagram"""
    with Diagram("Module Testing Strategy", filename="testing_strategy", show=False, graph_attr=graph_attr):
        with Cluster("Testing Workflow"):
            with Cluster("Unit Testing"):
                validate = EC2("terraform validate")
                fmt = EC2("terraform fmt")
                lint = EC2("tflint")
            
            with Cluster("Integration Testing"):
                plan = EC2("terraform plan")
                apply = EC2("terraform apply")
                test = EC2("terraform test")
            
            with Cluster("End-to-End Testing"):
                deploy = EC2("Full Deployment")
                verify = EC2("Verification")
                cleanup = EC2("Cleanup")
            
            validate >> plan
            fmt >> plan
            lint >> plan
            plan >> apply
            apply >> test
            test >> deploy
            deploy >> verify
            verify >> cleanup

def main():
    """Generate all diagrams"""
    print("Generating Project 2 architecture diagrams...")
    
    try:
        generate_hld()
        print("✓ Generated: hld.png")
        
        generate_lld()
        print("✓ Generated: lld.png")
        
        generate_module_architecture()
        print("✓ Generated: module_architecture.png")
        
        generate_module_dependencies()
        print("✓ Generated: module_dependencies.png")
        
        generate_vpc_module_design()
        print("✓ Generated: vpc_module_design.png")
        
        generate_compute_module_design()
        print("✓ Generated: compute_module_design.png")
        
        generate_database_module_design()
        print("✓ Generated: database_module_design.png")
        
        generate_module_composition()
        print("✓ Generated: module_composition.png")
        
        generate_testing_strategy()
        print("✓ Generated: testing_strategy.png")
        
        print("\n✅ All diagrams generated successfully!")
        print("📁 Diagrams saved in the current directory")
        
    except Exception as e:
        print(f"\n❌ Error generating diagrams: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())

