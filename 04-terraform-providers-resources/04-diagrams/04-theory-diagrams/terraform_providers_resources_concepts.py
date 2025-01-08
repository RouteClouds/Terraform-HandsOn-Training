from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.aws.general import General
from diagrams.programming.framework import React
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC
from diagrams.aws.security import IAM
from diagrams.aws.storage import S3
from diagrams.aws.integration import EventbridgeCustomEventBusResource
from diagrams.onprem.client import Client

def create_provider_types_diagram():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }

    with Diagram("Terraform Provider Types", show=False, direction="TB", graph_attr=graph_attr):
        tf = Terraform("Terraform Core")
        
        with Cluster("Provider Types"):
            with Cluster("Official"):
                official = [
                    General("AWS"),
                    General("Azure"),
                    General("GCP")
                ]
            
            with Cluster("Partner"):
                partner = [
                    General("Heroku"),
                    General("DigitalOcean")
                ]
            
            with Cluster("Community"):
                community = [
                    General("Custom Provider 1"),
                    General("Custom Provider 2")
                ]
            
            tf >> Edge(color="blue", style="bold") >> official
            tf >> Edge(color="green") >> partner
            tf >> Edge(color="orange") >> community

def create_resource_management_diagram():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }

    with Diagram("Resource Management", show=False, direction="LR", graph_attr=graph_attr):
        with Cluster("Resource Configuration"):
            config = Terraform("Resource Block")
            
            with Cluster("Meta-Arguments"):
                meta = [
                    General("count"),
                    General("for_each"),
                    General("depends_on"),
                    General("lifecycle")
                ]
            
            with Cluster("Resource Attributes"):
                attrs = [
                    General("id"),
                    General("arn"),
                    General("tags")
                ]
            
            config >> meta
            config >> attrs

def create_provider_features_diagram():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }

    with Diagram("Provider Features", show=False, direction="TB", graph_attr=graph_attr):
        with Cluster("Provider Configuration"):
            provider = Terraform("Provider")
            
            with Cluster("Authentication"):
                auth = [
                    IAM("Static Credentials"),
                    IAM("Environment Variables"),
                    IAM("Shared Credentials"),
                    IAM("IAM Roles")
                ]
            
            with Cluster("Settings"):
                settings = [
                    General("Region"),
                    General("Version"),
                    General("Alias"),
                    General("Endpoints")
                ]
            
            auth >> provider >> settings

def create_resource_lifecycle_diagram():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }

    with Diagram("Resource Lifecycle", show=False, direction="LR", graph_attr=graph_attr):
        with Cluster("Lifecycle Events"):
            events = [
                Terraform("Plan"),
                EventbridgeCustomEventBusResource("Create"),
                EventbridgeCustomEventBusResource("Update"),
                EventbridgeCustomEventBusResource("Destroy")
            ]
            
            with Cluster("Lifecycle Rules"):
                rules = [
                    General("create_before_destroy"),
                    General("prevent_destroy"),
                    General("ignore_changes")
                ]
            
            for i in range(len(events)-1):
                events[i] >> events[i+1]
            
            for rule in rules:
                rule >> Edge(style="dotted") >> events[1:4]

def create_dependencies_diagram():
    graph_attr = {
        "fontsize": "45",
        "bgcolor": "white"
    }

    with Diagram("Resource Dependencies", show=False, direction="TB", graph_attr=graph_attr):
        with Cluster("Infrastructure"):
            vpc = VPC("VPC")
            subnet = General("Subnet")
            instance = EC2("EC2")
            storage = S3("Storage")
            
            vpc >> Edge(label="implicit", color="blue") >> subnet
            subnet >> Edge(label="implicit", color="blue") >> instance
            instance >> Edge(label="explicit", style="dashed", color="red") >> storage

if __name__ == "__main__":
    create_provider_types_diagram()
    create_resource_management_diagram()
    create_provider_features_diagram()
    create_resource_lifecycle_diagram()
    create_dependencies_diagram() 