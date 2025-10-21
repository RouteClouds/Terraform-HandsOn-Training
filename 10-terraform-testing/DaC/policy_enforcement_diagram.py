#!/usr/bin/env python3
"""
Topic 10: Terraform Policy Enforcement Diagram
Generates a diagram showing policy as code enforcement
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.onprem.security import Vault
from diagrams.onprem.inmemory import Redis
from diagrams.aws.compute import EC2

def create_policy_enforcement_diagram():
    """Create Terraform policy enforcement diagram"""
    
    with Diagram(
        "Terraform Policy Enforcement",
        filename="policy_enforcement",
        direction="LR",
        show=False,
        outformat="png"
    ):
        # Terraform Configuration
        with Cluster("Terraform Configuration"):
            tf_code = Terraform("Terraform Code")
            plan = Terraform("terraform plan")
            tf_code >> plan
        
        # Policy Definitions
        with Cluster("Policy Definitions"):
            sentinel = Terraform("Sentinel Policies")
            opa = Terraform("OPA Policies")
            rules = Terraform("Compliance Rules")
            sentinel >> opa >> rules
        
        # Policy Evaluation
        with Cluster("Policy Evaluation"):
            evaluate = Terraform("Evaluate Policies")
            check = Terraform("Check Compliance")
            evaluate >> check
        
        # Decision
        with Cluster("Decision"):
            pass_policy = Redis("PASS")
            fail_policy = Redis("FAIL")
        
        # Deployment
        with Cluster("Deployment"):
            apply = Terraform("terraform apply")
            resources = EC2("AWS Resources")
            apply >> resources
        
        # Connections
        plan >> Edge(label="send to") >> evaluate
        rules >> Edge(label="apply") >> evaluate
        check >> Edge(label="compliant") >> pass_policy
        check >> Edge(label="non-compliant", color="red") >> fail_policy
        pass_policy >> Edge(label="approve") >> apply
        fail_policy >> Edge(label="reject", color="red") >> Terraform("Reject Plan")

if __name__ == "__main__":
    print("Generating Terraform Policy Enforcement diagram...")
    create_policy_enforcement_diagram()
    print("✓ Diagram saved as: policy_enforcement.png")

