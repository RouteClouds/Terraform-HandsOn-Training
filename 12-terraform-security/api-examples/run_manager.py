#!/usr/bin/env python3
"""
HCP Terraform Run Manager
Demonstrates run management via HCP Terraform API
"""

import requests
import json
import os
import sys
import time
from typing import Optional, Dict

# Configuration
API_TOKEN = os.environ.get('TFC_TOKEN')
ORG_NAME = os.environ.get('TFC_ORG', 'my-organization')
BASE_URL = 'https://app.terraform.io/api/v2'

if not API_TOKEN:
    print("❌ Error: TFC_TOKEN environment variable not set")
    sys.exit(1)

headers = {
    'Authorization': f'Bearer {API_TOKEN}',
    'Content-Type': 'application/vnd.api+json'
}


def get_workspace_id(workspace_name: str) -> Optional[str]:
    """Get workspace ID by name"""
    response = requests.get(
        f'{BASE_URL}/organizations/{ORG_NAME}/workspaces/{workspace_name}',
        headers=headers
    )
    
    if response.status_code == 200:
        return response.json()['data']['id']
    else:
        print(f"❌ Workspace not found: {workspace_name}")
        return None


def create_run(workspace_id: str, message: str = 'Triggered via API', 
               is_destroy: bool = False) -> Optional[str]:
    """Create a new run (queue plan)"""
    print(f"\n🚀 Creating run...")
    print(f"   Message: {message}")
    print(f"   Destroy: {is_destroy}")
    
    payload = {
        'data': {
            'type': 'runs',
            'attributes': {
                'message': message,
                'is-destroy': is_destroy
            },
            'relationships': {
                'workspace': {
                    'data': {
                        'type': 'workspaces',
                        'id': workspace_id
                    }
                }
            }
        }
    }
    
    response = requests.post(
        f'{BASE_URL}/runs',
        headers=headers,
        json=payload
    )
    
    if response.status_code == 201:
        run = response.json()['data']
        run_id = run['id']
        print(f"✅ Run created successfully")
        print(f"   Run ID: {run_id}")
        print(f"   Status: {run['attributes']['status']}")
        return run_id
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return None


def get_run_status(run_id: str) -> Optional[Dict]:
    """Get run status and details"""
    response = requests.get(
        f'{BASE_URL}/runs/{run_id}',
        headers=headers
    )
    
    if response.status_code == 200:
        return response.json()['data']
    else:
        return None


def apply_run(run_id: str, comment: str = 'Approved via API') -> bool:
    """Apply a run"""
    print(f"\n✅ Applying run: {run_id}")
    print(f"   Comment: {comment}")
    
    payload = {'comment': comment}
    
    response = requests.post(
        f'{BASE_URL}/runs/{run_id}/actions/apply',
        headers=headers,
        json=payload
    )
    
    if response.status_code == 202:
        print(f"✅ Run apply initiated")
        return True
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return False


def cancel_run(run_id: str, comment: str = 'Canceled via API') -> bool:
    """Cancel a run"""
    print(f"\n🛑 Canceling run: {run_id}")
    print(f"   Comment: {comment}")
    
    payload = {'comment': comment}
    
    response = requests.post(
        f'{BASE_URL}/runs/{run_id}/actions/cancel',
        headers=headers,
        json=payload
    )
    
    if response.status_code == 202:
        print(f"✅ Run canceled")
        return True
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return False


def wait_for_run(run_id: str, timeout: int = 600) -> str:
    """Wait for run to complete"""
    print(f"\n⏳ Waiting for run to complete (timeout: {timeout}s)...")
    
    start_time = time.time()
    terminal_statuses = ['applied', 'errored', 'canceled', 'discarded', 'planned_and_finished']
    
    while time.time() - start_time < timeout:
        run = get_run_status(run_id)
        if not run:
            return 'error'
        
        status = run['attributes']['status']
        print(f"   Status: {status}")
        
        if status in terminal_statuses:
            return status
        
        time.sleep(10)
    
    print(f"⚠️  Timeout reached")
    return 'timeout'


def list_runs(workspace_id: str, limit: int = 10) -> list:
    """List recent runs for a workspace"""
    print(f"\n📋 Listing recent runs (limit: {limit})...")
    
    response = requests.get(
        f'{BASE_URL}/workspaces/{workspace_id}/runs',
        headers=headers,
        params={'page[size]': limit}
    )
    
    if response.status_code == 200:
        runs = response.json()['data']
        print(f"✅ Found {len(runs)} runs")
        
        for run in runs:
            attrs = run['attributes']
            print(f"   - {run['id']}: {attrs['status']} - {attrs.get('message', 'No message')}")
        
        return runs
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return []


def main():
    """Main execution"""
    print("=" * 70)
    print("HCP Terraform Run Manager")
    print("=" * 70)
    
    # Get workspace
    workspace_name = input("\nEnter workspace name: ").strip()
    if not workspace_name:
        workspace_name = 'api-demo-workspace'
        print(f"Using default: {workspace_name}")
    
    workspace_id = get_workspace_id(workspace_name)
    if not workspace_id:
        sys.exit(1)
    
    print(f"✅ Workspace ID: {workspace_id}")
    
    # List recent runs
    list_runs(workspace_id, limit=5)
    
    # Create a new run
    run_id = create_run(
        workspace_id,
        message='Demo run via API',
        is_destroy=False
    )
    
    if run_id:
        # Wait for plan to complete
        final_status = wait_for_run(run_id, timeout=300)
        print(f"\n📊 Final Status: {final_status}")
        
        # Get final run details
        run = get_run_status(run_id)
        if run:
            attrs = run['attributes']
            print(f"\n📊 Run Details:")
            print(f"   ID: {run['id']}")
            print(f"   Status: {attrs['status']}")
            print(f"   Message: {attrs.get('message', 'N/A')}")
            print(f"   Created: {attrs.get('created-at', 'N/A')}")
            
            # Optionally apply the run
            if final_status == 'planned':
                apply_choice = input("\nApply this run? (yes/no): ").strip().lower()
                if apply_choice == 'yes':
                    apply_run(run_id, 'Applied via API demo')
                    wait_for_run(run_id, timeout=300)
    
    print("\n" + "=" * 70)
    print("✅ Demo completed")
    print("=" * 70)


if __name__ == '__main__':
    main()

