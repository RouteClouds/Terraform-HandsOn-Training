#!/usr/bin/env python3
from diagrams import Diagram, Cluster
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, InternetGateway, PublicSubnet
from diagrams.aws.database import RDS
from diagrams.aws.security import SecretsManager
from diagrams.onprem.client import User
from diagrams.aws.security import IAM
from diagrams.onprem.iac import Terraform

# Common settings
graph_attr = {
    "pad": "1.5",
    "splines": "ortho",
    "nodesep": "1.0",
    "ranksep": "1.0"
}

# Lab 1: Basic Variable Usage
def create_lab1_diagram():
    with Diagram(
        "Lab 1 - Basic Variable Usage",
        show=False,
        direction="LR",
        graph_attr=graph_attr,
        filename="lab1_diagram"
    ):
        with Cluster("Terraform Configuration"):
            tf = Terraform("Terraform")
            vars = Terraform("Variables")
            outputs = Terraform("Outputs")

        with Cluster("AWS Resources"):
            ec2 = EC2("EC2 Instance")

        vars >> tf >> ec2
        ec2 >> outputs

# Lab 2: Variable Types and Validation
def create_lab2_diagram():
    with Diagram(
        "Lab 2 - Variable Types and Validation",
        show=False,
        direction="TB",
        graph_attr=graph_attr,
        filename="lab2_diagram"
    ):
        with Cluster("Variable Types"):
            with Cluster("Complex Types"):
                obj_var = Terraform("Object")
                list_var = Terraform("List")
                map_var = Terraform("Map")

            with Cluster("Validation"):
                validation = Terraform("Validation Rules")

        with Cluster("AWS Resources"):
            sg = IAM("Security Group")
            instances = [EC2("Instance 1"),
                       EC2("Instance 2")]

        obj_var >> validation
        list_var >> sg
        map_var >> instances

# Lab 3: Variable Files and Precedence
def create_lab3_diagram():
    with Diagram(
        "Lab 3 - Variable Files and Precedence",
        show=False,
        direction="TB",
        graph_attr=graph_attr,
        filename="lab3_diagram"
    ):
        with Cluster("Variable Files"):
            tfvars = Terraform("terraform.tfvars")
            prod_vars = Terraform("prod.tfvars")
            env_vars = Terraform("ENV Variables")

        with Cluster("AWS Network"):
            vpc = VPC("VPC")
            igw = InternetGateway("Internet Gateway")
            subnets = [PublicSubnet("Subnet 1"),
                      PublicSubnet("Subnet 2")]

        tfvars >> vpc
        prod_vars >> vpc
        vpc >> igw
        vpc >> subnets

# Lab 4: Sensitive Variables
def create_lab4_diagram():
    with Diagram(
        "Lab 4 - Sensitive Variables",
        show=False,
        direction="LR",
        graph_attr=graph_attr,
        filename="lab4_diagram"
    ):
        with Cluster("Sensitive Configuration"):
            secrets = Terraform("Sensitive Variables")
            tf_config = Terraform("Terraform Config")

        with Cluster("AWS Resources"):
            db = RDS("RDS Instance")
            sm = SecretsManager("Secrets Manager")

        secrets >> tf_config >> db
        secrets >> sm
        db >> sm

def main():
    create_lab1_diagram()
    create_lab2_diagram()
    create_lab3_diagram()
    create_lab4_diagram()

if __name__ == "__main__":
    main() 