#!/usr/bin/env python3
"""
Topic 11: Terraform State Troubleshooting Diagram
Generates a diagram showing state troubleshooting process
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Terraform
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.inmemory import Redis

def create_state_troubleshooting_diagram():
    """Create Terraform state troubleshooting diagram"""
    
    with Diagram(
        "Terraform State Troubleshooting",
        filename="state_troubleshooting",
        direction="LR",
        show=False,
        outformat="png"
    ):
        # State Issues
        with Cluster("State Issues"):
            lock_issue = Terraform("State Lock Issue")
            corruption = Terraform("State Corruption")
            drift = Terraform("Resource Drift")
            mismatch = Terraform("State Mismatch")
        
        # Lock Resolution
        with Cluster("Lock Resolution"):
            check_lock = Terraform("Check Lock")
            force_unlock = Terraform("Force Unlock")
            check_lock >> force_unlock
        
        # Corruption Recovery
        with Cluster("Corruption Recovery"):
            backup = PostgreSQL("Restore Backup")
            refresh = Terraform("terraform refresh")
            backup >> refresh
        
        # Drift Detection
        with Cluster("Drift Detection"):
            plan = Terraform("terraform plan")
            taint = Terraform("terraform taint")
            plan >> taint
        
        # Mismatch Resolution
        with Cluster("Mismatch Resolution"):
            sync = Terraform("terraform refresh")
            import_res = Terraform("terraform import")
            sync >> import_res
        
        # Verification
        with Cluster("Verification"):
            verify = Terraform("Verify State")
            success = Redis("RESOLVED")
            verify >> success
        
        # Connections
        lock_issue >> Edge(label="resolve") >> check_lock
        corruption >> Edge(label="recover") >> backup
        drift >> Edge(label="detect") >> plan
        mismatch >> Edge(label="sync") >> sync
        
        force_unlock >> Edge(label="verify") >> verify
        refresh >> Edge(label="verify") >> verify
        taint >> Edge(label="verify") >> verify
        import_res >> Edge(label="verify") >> verify

if __name__ == "__main__":
    print("Generating Terraform State Troubleshooting diagram...")
    create_state_troubleshooting_diagram()
    print("✓ Diagram saved as: state_troubleshooting.png")

