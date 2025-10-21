#!/usr/bin/env python3
"""
Topic 11: Terraform Error Resolution Flowchart
Generates a diagram showing error resolution decision tree
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.onprem.inmemory import Redis

def create_error_resolution_flowchart():
    """Create Terraform error resolution flowchart"""
    
    with Diagram(
        "Terraform Error Resolution Flowchart",
        filename="error_resolution_flowchart",
        direction="TB",
        show=False,
        outformat="png"
    ):
        # Start
        start = Terraform("Error Occurs")
        
        # Error Type Decision
        with Cluster("Error Type"):
            syntax_error = Terraform("Syntax Error?")
            provider_error = Terraform("Provider Error?")
            state_error = Terraform("State Error?")
            resource_error = Terraform("Resource Error?")
        
        # Syntax Error Resolution
        with Cluster("Syntax Error Resolution"):
            validate = Terraform("terraform validate")
            fmt = Terraform("terraform fmt")
            fix_syntax = Terraform("Fix Syntax")
            validate >> fmt >> fix_syntax
        
        # Provider Error Resolution
        with Cluster("Provider Error Resolution"):
            check_creds = Terraform("Check AWS Credentials")
            check_perms = Terraform("Check IAM Permissions")
            fix_provider = Terraform("Fix Provider Config")
            check_creds >> check_perms >> fix_provider
        
        # State Error Resolution
        with Cluster("State Error Resolution"):
            check_lock = Terraform("Check State Lock")
            force_unlock = Terraform("Force Unlock")
            refresh = Terraform("terraform refresh")
            check_lock >> force_unlock >> refresh
        
        # Resource Error Resolution
        with Cluster("Resource Error Resolution"):
            check_resource = Terraform("Check Resource Config")
            import_resource = Terraform("Import Resource")
            fix_resource = Terraform("Fix Resource")
            check_resource >> import_resource >> fix_resource
        
        # Verification
        with Cluster("Verification"):
            rerun = Terraform("Re-run terraform plan")
            success = Redis("SUCCESS")
            rerun >> success
        
        # Connections
        start >> Edge(label="identify") >> syntax_error
        syntax_error >> Edge(label="yes") >> validate
        syntax_error >> Edge(label="no") >> provider_error
        provider_error >> Edge(label="yes") >> check_creds
        provider_error >> Edge(label="no") >> state_error
        state_error >> Edge(label="yes") >> check_lock
        state_error >> Edge(label="no") >> resource_error
        
        fix_syntax >> Edge(label="verify") >> rerun
        fix_provider >> Edge(label="verify") >> rerun
        refresh >> Edge(label="verify") >> rerun
        fix_resource >> Edge(label="verify") >> rerun

if __name__ == "__main__":
    print("Generating Terraform Error Resolution Flowchart...")
    create_error_resolution_flowchart()
    print("✓ Diagram saved as: error_resolution_flowchart.png")

