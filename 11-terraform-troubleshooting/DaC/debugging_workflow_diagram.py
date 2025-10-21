#!/usr/bin/env python3
"""
Topic 11: Terraform Debugging Workflow Diagram
Generates a professional diagram showing the debugging workflow
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.logging import Loki

def create_debugging_workflow_diagram():
    """Create Terraform debugging workflow diagram"""
    
    with Diagram(
        "Terraform Debugging Workflow",
        filename="debugging_workflow",
        direction="TB",
        show=False,
        outformat="png"
    ):
        # Problem Detection
        with Cluster("Problem Detection"):
            error = Terraform("Error Occurs")
            identify = Terraform("Identify Error")
            error >> identify
        
        # Enable Debugging
        with Cluster("Enable Debugging"):
            enable_log = Terraform("Enable TF_LOG")
            set_path = Terraform("Set TF_LOG_PATH")
            enable_log >> set_path
        
        # Collect Information
        with Cluster("Collect Information"):
            logs = Loki("Review Logs")
            validate = Terraform("terraform validate")
            plan = Terraform("terraform plan")
            logs >> validate >> plan
        
        # Analyze
        with Cluster("Analysis"):
            analyze = Terraform("Analyze Error")
            research = Terraform("Research Solution")
            analyze >> research
        
        # Resolution
        with Cluster("Resolution"):
            fix = Terraform("Apply Fix")
            verify = Terraform("Verify Fix")
            fix >> verify
        
        # Verification
        with Cluster("Verification"):
            success = Redis("SUCCESS")
            retry = Redis("RETRY")
        
        # Workflow connections
        identify >> Edge(label="enable") >> enable_log
        set_path >> Edge(label="collect") >> logs
        plan >> Edge(label="analyze") >> analyze
        research >> Edge(label="fix") >> fix
        verify >> Edge(label="success") >> success
        verify >> Edge(label="failed", color="red") >> retry
        retry >> Edge(label="retry", color="red") >> identify

if __name__ == "__main__":
    print("Generating Terraform Debugging Workflow diagram...")
    create_debugging_workflow_diagram()
    print("✓ Diagram saved as: debugging_workflow.png")

