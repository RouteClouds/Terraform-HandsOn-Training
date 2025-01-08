from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import VPC, InternetGateway, RouteTable
from diagrams.onprem.iac import Terraform
from diagrams.aws.general import General
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb
import os

# Create output directory
output_dir = "generated"
os.makedirs(output_dir, exist_ok=True)

def create_lab3_diagram():
    graph_attr = {
        "fontsize": "20",
        "bgcolor": "white",
        "pad": "0.75"
    }

    with Diagram(
        "Lab 3: Advanced State Management with Workspaces",
        show=False,
        filename=f"{output_dir}/lab3_workspaces",
        graph_attr=graph_attr,
        direction="TB"
    ):
        with Cluster("Terraform Configuration"):
            terraform = Terraform("Terraform CLI")
            vpc_module = General("VPC Module")

        with Cluster("Backend"):
            s3 = S3("State Storage")
            dynamo = Dynamodb("State Locking")
            
            with Cluster("Workspace States"):
                dev_state = General("development.tfstate")
                prod_state = General("production.tfstate")

        with Cluster("Development Workspace"):
            dev_vpc = VPC("Dev VPC\n10.0.0.0/16")
            
            with Cluster("Dev Network"):
                dev_public = [
                    General("Dev Public 1\n10.0.1.0/24"),
                    General("Dev Public 2\n10.0.2.0/24")
                ]
                dev_private = [
                    General("Dev Private 1\n10.0.11.0/24"),
                    General("Dev Private 2\n10.0.12.0/24")
                ]
                dev_igw = InternetGateway("Dev IGW")
                dev_rt = RouteTable("Dev Route Tables")

        with Cluster("Production Workspace"):
            prod_vpc = VPC("Prod VPC\n10.1.0.0/16")
            
            with Cluster("Prod Network"):
                prod_public = [
                    General("Prod Public 1\n10.1.1.0/24"),
                    General("Prod Public 2\n10.1.2.0/24")
                ]
                prod_private = [
                    General("Prod Private 1\n10.1.11.0/24"),
                    General("Prod Private 2\n10.1.12.0/24")
                ]
                prod_igw = InternetGateway("Prod IGW")
                prod_rt = RouteTable("Prod Route Tables")

        # Draw relationships
        terraform >> vpc_module
        terraform >> s3
        terraform >> dynamo
        
        s3 >> Edge(color="blue") >> dev_state
        s3 >> Edge(color="red") >> prod_state
        
        dev_state >> Edge(color="blue") >> dev_vpc
        prod_state >> Edge(color="red") >> prod_vpc
        
        dev_vpc >> dev_public
        dev_vpc >> dev_private
        dev_vpc >> dev_igw >> dev_rt
        
        prod_vpc >> prod_public
        prod_vpc >> prod_private
        prod_vpc >> prod_igw >> prod_rt

if __name__ == "__main__":
    create_lab3_diagram()
