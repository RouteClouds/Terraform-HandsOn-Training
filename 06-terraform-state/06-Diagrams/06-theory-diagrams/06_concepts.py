from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb
from diagrams.aws.security import KMS
from diagrams.onprem.vcs import Github
from diagrams.onprem.client import Users
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC
from diagrams.aws.general import General
from diagrams.programming.flowchart import Document
import os

# Create output directory if it doesn't exist
output_dir = "generated"
os.makedirs(output_dir, exist_ok=True)

# Diagram 1: State Management Overview
def create_state_overview():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }
    
    with Diagram(
        "Terraform State Management Overview",
        show=False,
        filename=f"{output_dir}/01_state_overview",
        graph_attr=graph_attr
    ):
        tf = Terraform("Terraform")
        
        with Cluster("State Management"):
            state = Document("State File")
            metadata = Document("Metadata")
            deps = Document("Dependencies")

        with Cluster("Infrastructure"):
            resources = [
                EC2("EC2 Instance"),
                VPC("VPC"),
                S3("S3 Bucket")
            ]

        tf >> state >> resources
        state << metadata
        state << deps

# Diagram 2: State Storage Options
def create_storage_options():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }
    
    with Diagram(
        "Terraform State Storage Options",
        show=False,
        filename=f"{output_dir}/02_storage_options",
        graph_attr=graph_attr
    ):
        tf = Terraform("Terraform")

        with Cluster("Local Storage"):
            local = Document("Local State")

        with Cluster("Remote Storage"):
            with Cluster("AWS"):
                s3 = S3("S3 Backend")
                dynamo = Dynamodb("State Locking")
                kms = KMS("Encryption")

            with Cluster("Other Backends"):
                other = [
                    General("Azure Storage"),
                    General("GCS"),
                    General("Terraform Cloud")
                ]

        tf >> local
        tf >> s3 >> dynamo
        s3 << kms

# Diagram 3: State Operations Flow
def create_state_operations():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }
    
    with Diagram(
        "Terraform State Operations",
        show=False,
        filename=f"{output_dir}/03_state_operations",
        graph_attr=graph_attr
    ):
        with Cluster("State Commands"):
            commands = [
                Document("terraform state list"),
                Document("terraform state show"),
                Document("terraform state mv"),
                Document("terraform state rm")
            ]

        with Cluster("State File"):
            state = Document("terraform.tfstate")

        with Cluster("Infrastructure"):
            infra = [EC2("Resource 1"), EC2("Resource 2")]

        commands >> state >> infra

# Diagram 4: State Locking Mechanism
def create_state_locking():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }
    
    with Diagram(
        "Terraform State Locking",
        show=False,
        filename=f"{output_dir}/04_state_locking",
        graph_attr=graph_attr
    ):
        with Cluster("Team Members"):
            users = [Users("User 1"), Users("User 2")]

        with Cluster("State Backend"):
            s3 = S3("State Storage")
            lock = Dynamodb("Lock Table")

        with Cluster("Lock Status"):
            status = Document("Lock Info")

        users >> Edge(label="acquire lock") >> lock
        lock >> Edge(label="check status") >> status
        users >> Edge(label="read/write state") >> s3

# Diagram 5: Enterprise State Management
def create_enterprise_setup():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }
    
    with Diagram(
        "Enterprise State Management",
        show=False,
        filename=f"{output_dir}/05_enterprise_setup",
        graph_attr=graph_attr
    ):
        with Cluster("Development Process"):
            github = Github("Version Control")
            tf = Terraform("Terraform")

        with Cluster("State Management"):
            with Cluster("Production"):
                prod_state = S3("Prod State")
                prod_lock = Dynamodb("Prod Lock")

            with Cluster("Staging"):
                stage_state = S3("Stage State")
                stage_lock = Dynamodb("Stage Lock")

            with Cluster("Development"):
                dev_state = S3("Dev State")
                dev_lock = Dynamodb("Dev Lock")

        github >> tf
        tf >> prod_state >> prod_lock
        tf >> stage_state >> stage_lock
        tf >> dev_state >> dev_lock

if __name__ == "__main__":
    create_state_overview()
    create_storage_options()
    create_state_operations()
    create_state_locking()
    create_enterprise_setup() 