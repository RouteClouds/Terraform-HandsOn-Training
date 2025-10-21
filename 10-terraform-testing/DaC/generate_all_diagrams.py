#!/usr/bin/env python3
"""
Topic 10: Master Diagram Generation Script
Generates all Topic 10 diagrams in sequence
"""

import os
import sys
import subprocess
from pathlib import Path

def run_diagram_script(script_name):
    """Run a diagram generation script"""
    script_path = Path(__file__).parent / script_name
    
    if not script_path.exists():
        print(f"✗ Script not found: {script_name}")
        return False
    
    try:
        print(f"\n{'='*60}")
        print(f"Generating: {script_name}")
        print(f"{'='*60}")
        
        result = subprocess.run(
            [sys.executable, str(script_path)],
            cwd=Path(__file__).parent,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print(result.stdout)
            return True
        else:
            print(f"✗ Error: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"✗ Exception: {str(e)}")
        return False

def main():
    """Generate all diagrams"""
    print("\n" + "="*60)
    print("Topic 10: Terraform Testing & Validation")
    print("Diagram Generation Script")
    print("="*60)
    
    scripts = [
        "testing_workflow_diagram.py",
        "validation_pipeline_diagram.py",
        "policy_enforcement_diagram.py",
    ]
    
    results = {}
    
    for script in scripts:
        results[script] = run_diagram_script(script)
    
    # Summary
    print("\n" + "="*60)
    print("Generation Summary")
    print("="*60)
    
    successful = sum(1 for v in results.values() if v)
    total = len(results)
    
    for script, success in results.items():
        status = "✓ SUCCESS" if success else "✗ FAILED"
        print(f"{status}: {script}")
    
    print(f"\nTotal: {successful}/{total} diagrams generated successfully")
    
    if successful == total:
        print("\n✓ All diagrams generated successfully!")
        return 0
    else:
        print(f"\n✗ {total - successful} diagram(s) failed to generate")
        return 1

if __name__ == "__main__":
    sys.exit(main())

