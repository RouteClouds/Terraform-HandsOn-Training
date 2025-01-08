from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import VPC, InternetGateway, RouteTable
from diagrams.onprem.iac import Terraform
from diagrams.programming.flowchart import Document
from diagrams.aws.general import General
import os

# Create output directory
output_dir = "generated"
os.makedirs(output_dir, exist_ok=True)

def create_lab2_diagram():
    graph_attr = {
        "fontsize": "20",
        "bgcolor": "white",
        "pad": "0.75"
    }

    with Diagram(
        "Lab 2: State Operations and Manipulation",
        show=False,
        filename=f"{output_dir}/lab2_state_operations",
        graph_attr=graph_attr,
        direction="TB"
    ):
        with Cluster("State Management"):
            terraform = Terraform("Terraform CLI")
            
            with Cluster("State Operations"):
                state_ops = [
                    Document("state list"),
                    Document("state show"),
                    Document("state mv"),
                    Document("state rm"),
                    Document("state import")
                ]
            
            state_file = General("terraform.tfstate")

        with Cluster("Infrastructure Resources"):
            with Cluster("Network Resources"):
                vpc = VPC("Main VPC")
                
                with Cluster("Subnet Configuration"):
                    subnets = [
                        General("Subnet 1\n10.0.1.0/24"),
                        General("Subnet 2\n10.0.2.0/24"),
                        General("Subnet 3\n10.0.3.0/24")
                    ]
                
                igw = InternetGateway("Internet Gateway")
                rt = RouteTable("Route Table")

            with Cluster("Security"):
                sg = General("Imported Security Group")

        # Draw relationships
        terraform >> Edge(label="manages") >> state_file
        for op in state_ops:
            terraform >> Edge(style="dotted") >> op
            op >> Edge(style="dotted") >> state_file

        state_file >> Edge(label="tracks") >> vpc
        vpc >> subnets
        vpc >> igw >> rt
        vpc >> sg

if __name__ == "__main__":
    create_lab2_diagram()
