#!/usr/bin/env python3
"""
Generate All Terraform Module Diagrams
Executes all diagram generation scripts for Topic 7: Modules and Module Development
"""

import subprocess
import sys
import os
from pathlib import Path

def run_diagram_script(script_name):
    """Run a diagram generation script and handle errors."""
    try:
        print(f"🔄 Generating {script_name}...")
        result = subprocess.run([sys.executable, script_name], 
                              capture_output=True, text=True, check=True)
        print(f"✅ {script_name} completed successfully")
        if result.stdout:
            print(f"   Output: {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating {script_name}:")
        print(f"   {e.stderr}")
        return False
    except FileNotFoundError:
        print(f"❌ Script not found: {script_name}")
        return False

def main():
    """Generate all diagrams for Topic 7."""
    print("🎯 Generating Terraform Module Diagrams")
    print("=" * 50)
    
    # Get the directory containing this script
    script_dir = Path(__file__).parent
    os.chdir(script_dir)
    
    # List of diagram scripts to execute
    diagram_scripts = [
        "01-module-architecture.py",
        "02-module-lifecycle.py", 
        "03-module-composition.py",
        "04-module-testing.py",
        "05-enterprise-module-governance.py"
    ]
    
    successful = 0
    failed = 0
    
    # Generate each diagram
    for script in diagram_scripts:
        if run_diagram_script(script):
            successful += 1
        else:
            failed += 1
        print()  # Add spacing between scripts
    
    # Summary
    print("📊 Generation Summary")
    print("=" * 50)
    print(f"✅ Successful: {successful}")
    print(f"❌ Failed: {failed}")
    print(f"📁 Total diagrams: {len(diagram_scripts)}")
    
    if failed == 0:
        print("\n🎉 All diagrams generated successfully!")
        print("\n📋 Generated Files:")
        for script in diagram_scripts:
            png_file = script.replace('.py', '.png')
            if os.path.exists(png_file):
                print(f"   ✓ {png_file}")
            else:
                print(f"   ✗ {png_file} (not found)")
    else:
        print(f"\n⚠️  {failed} diagram(s) failed to generate")
        return 1
    
    print("\n🔍 Diagram Descriptions:")
    print("   01-module-architecture.png     - Module structure and relationships")
    print("   02-module-lifecycle.png        - Module development and deployment lifecycle")
    print("   03-module-composition.png      - Different module composition patterns")
    print("   04-module-testing.png          - Comprehensive module testing strategies")
    print("   05-enterprise-module-governance.png - Enterprise governance and distribution")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
