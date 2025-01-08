from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform
from diagrams.onprem.compute import Server
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC
from diagrams.aws.storage import S3
from diagrams.onprem.ci import Jenkins
from diagrams.onprem.monitoring import Grafana
from diagrams.onprem.network import Internet
from diagrams.aws.security import IAM

# Theory concept diagrams for introduction-to-iac
def create_concept_diagram():
    with Diagram("introduction-to-iac Concepts", show=False):
        # Add diagram components here
        pass

# Traditional vs IaC Diagram
def create_comparison_diagram():
    with Diagram("Traditional vs IaC Approach", show=False):
        with Cluster("Traditional Approach"):
            manual = [Server("Manual Config"),
                     Server("SSH/Console"),
                     Server("Human Errors")]
        
        with Cluster("Infrastructure as Code"):
            iac = [Terraform("Terraform Code"),
                  Terraform("Version Control"),
                  Terraform("Automation")]

# IaC Workflow Diagram
def create_workflow_diagram():
    with Diagram("IaC Workflow", show=False):
        with Cluster("Development"):
            code = Terraform("Infrastructure Code")
            vcs = Terraform("Version Control")
        
        with Cluster("Deployment"):
            tf = Terraform("Terraform Apply")
        
        with Cluster("Infrastructure"):
            infra = [EC2("Compute"),
                    VPC("Network"),
                    S3("Storage")]
        
        code >> vcs >> tf >> infra

# Enterprise Migration Pattern
def create_enterprise_migration_diagram():
    with Diagram("Enterprise Migration Pattern", show=False):
        with Cluster("Legacy Infrastructure"):
            legacy = [Server("Legacy App"),
                     Server("Database"),
                     Server("File Storage")]

        with Cluster("Modern Infrastructure"):
            modern = [EC2("Cloud App"),
                     S3("Object Storage"),
                     VPC("Network")]

        with Cluster("Migration Tools"):
            tools = [Terraform("IaC"),
                    Jenkins("CI/CD"),
                    Grafana("Monitoring")]

        legacy >> tools >> modern

# Startup Implementation Flow
def create_startup_implementation_diagram():
    with Diagram("Startup Implementation", show=False):
        with Cluster("Infrastructure Definition"):
            code = [Terraform("Main"),
                   Terraform("Variables"),
                   Terraform("Outputs")]

        with Cluster("Security Layer"):
            security = [IAM("Access Control"),
                       VPC("Network Security")]

        with Cluster("Resources"):
            resources = [EC2("Application"),
                        S3("Storage"),
                        Internet("CDN")]

        code >> security >> resources

if __name__ == "__main__":
    create_concept_diagram()
    create_comparison_diagram()
    create_workflow_diagram()
    create_enterprise_migration_diagram()
    create_startup_implementation_diagram()
