from diagrams import Diagram, Cluster, Edge
from diagrams.aws.storage import S3
from diagrams.aws.network import VPC, InternetGateway, RouteTable, Subnet
from diagrams.aws.compute import EC2
from diagrams.aws.security import IAM
from diagrams.aws.general import General
from diagrams.onprem.iac import Terraform
from diagrams.aws.database import Dynamodb

# Lab 1: Basic Commands and S3
def create_lab1_diagram():
    with Diagram("Lab 1: Basic Terraform Commands", show=False):
        with Cluster("Terraform Configuration"):
            tf = Terraform("Terraform CLI")
            
            with Cluster("Commands Flow"):
                init = Terraform("terraform init")
                plan = Terraform("terraform plan")
                apply = Terraform("terraform apply")
                destroy = Terraform("terraform destroy")
                
                init >> plan >> apply >> destroy
            
            with Cluster("AWS Resources"):
                bucket = S3("Demo Bucket")
                versioning = General("Versioning")
                
                tf >> apply >> bucket >> versioning

# Lab 2: Variables and VPC
def create_lab2_diagram():
    with Diagram("Lab 2: Variables and VPC", show=False):
        with Cluster("Network Infrastructure"):
            with Cluster("Variables"):
                vars = [
                    General("Region"),
                    General("Environment"),
                    General("CIDR Blocks")
                ]
            
            with Cluster("VPC Resources"):
                vpc = VPC("Main VPC")
                subnet = Subnet("Public Subnet")
                
                vars >> vpc >> subnet

# Lab 3: Resource Dependencies
def create_lab3_diagram():
    with Diagram("Lab 3: Resource Dependencies", show=False):
        with Cluster("VPC Infrastructure"):
            # Core Network
            vpc = VPC("VPC")
            igw = InternetGateway("Internet Gateway")
            
            # Networking Components
            with Cluster("Network Components"):
                subnet = Subnet("Public Subnet")
                rt = RouteTable("Route Table")
                
                vpc >> igw
                vpc >> subnet
                igw >> rt >> subnet
            
            # Security and Compute
            with Cluster("Compute Resources"):
                sg = IAM("Security Group")
                ec2 = EC2("Web Server")
                
                vpc >> sg >> ec2
                subnet >> ec2

# Lab 4: State Management
def create_lab4_diagram():
    with Diagram("Lab 4: State Management", show=False):
        with Cluster("State Infrastructure"):
            with Cluster("Backend Configuration"):
                state_bucket = S3("State Bucket")
                lock_table = Dynamodb("State Lock Table")
                
                state_bucket - Edge(label="Encrypted") >> General("AES-256")
                lock_table - Edge(label="Locking") >> General("DynamoDB")
            
            with Cluster("Example Resources"):
                vpc = VPC("Example VPC")
                subnet = Subnet("Example Subnet")
                
                state_bucket >> Edge(label="Tracks") >> [vpc, subnet]
                lock_table >> Edge(label="Locks") >> state_bucket

def create_lab_overview_diagram():
    with Diagram("Terraform Basics Labs Overview", show=False):
        with Cluster("Lab Progression"):
            # Lab 1
            with Cluster("Lab 1: Basics"):
                l1 = [
                    Terraform("Commands"),
                    S3("Storage")
                ]
            
            # Lab 2
            with Cluster("Lab 2: Variables"):
                l2 = [
                    General("Variables"),
                    VPC("Networking")
                ]
            
            # Lab 3
            with Cluster("Lab 3: Dependencies"):
                l3 = [
                    VPC("Infrastructure"),
                    EC2("Compute")
                ]
            
            # Lab 4
            with Cluster("Lab 4: State"):
                l4 = [
                    S3("Backend"),
                    Dynamodb("Locking")
                ]
            
            # Show progression
            l1 >> l2 >> l3 >> l4

if __name__ == "__main__":
    create_lab1_diagram()
    create_lab2_diagram()
    create_lab3_diagram()
    create_lab4_diagram()
    create_lab_overview_diagram() 