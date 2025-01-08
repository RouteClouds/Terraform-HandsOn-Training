from diagrams import Diagram, Cluster, Edge
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb
from diagrams.aws.network import VPC
from diagrams.onprem.iac import Terraform
from diagrams.aws.general import General
import os

# Create output directory
output_dir = "generated"
os.makedirs(output_dir, exist_ok=True)

def create_lab1_diagram():
    graph_attr = {
        "fontsize": "20",
        "bgcolor": "white",
        "pad": "0.75"
    }

    with Diagram(
        "Lab 1: Basic State Management and Backend Configuration",
        show=False,
        filename=f"{output_dir}/lab1_backend_setup",
        graph_attr=graph_attr,
        direction="LR"
    ):
        with Cluster("Terraform Configuration"):
            terraform = Terraform("Terraform")
            state_file = General("Local State")

        with Cluster("Backend Infrastructure"):
            with Cluster("State Storage"):
                s3_bucket = S3("S3 Bucket\nterraform-state-xxxxx")
                encryption = General("Server-Side\nEncryption")
                versioning = General("Versioning\nEnabled")

            with Cluster("State Locking"):
                dynamo_table = Dynamodb("DynamoDB Table\nterraform-state-locks")

        with Cluster("Test Infrastructure"):
            vpc = VPC("Main VPC\n10.0.0.0/16")
            test_subnet = General("Example Subnet\n10.0.1.0/24")

        # Draw relationships
        terraform >> Edge(label="init") >> state_file
        terraform >> Edge(label="remote state", color="blue") >> s3_bucket
        s3_bucket - encryption
        s3_bucket - versioning
        terraform >> Edge(label="lock", color="red") >> dynamo_table
        terraform >> Edge(label="manage") >> vpc >> test_subnet

if __name__ == "__main__":
    create_lab1_diagram()
