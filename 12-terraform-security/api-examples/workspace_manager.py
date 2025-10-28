#!/usr/bin/env python3
"""
HCP Terraform Workspace Manager
Demonstrates workspace management via HCP Terraform API
"""

import requests
import json
import os
import sys
from typing import Optional, Dict, List

# Configuration
API_TOKEN = os.environ.get('TFC_TOKEN')
ORG_NAME = os.environ.get('TFC_ORG', 'my-organization')
BASE_URL = 'https://app.terraform.io/api/v2'

if not API_TOKEN:
    print("❌ Error: TFC_TOKEN environment variable not set")
    print("   Export your HCP Terraform token: export TFC_TOKEN='your-token'")
    sys.exit(1)

headers = {
    'Authorization': f'Bearer {API_TOKEN}',
    'Content-Type': 'application/vnd.api+json'
}


def list_workspaces() -> List[Dict]:
    """List all workspaces in the organization"""
    print(f"\n📋 Listing workspaces in organization: {ORG_NAME}")
    
    workspaces = []
    page = 1
    
    while True:
        response = requests.get(
            f'{BASE_URL}/organizations/{ORG_NAME}/workspaces',
            headers=headers,
            params={'page[size]': 100, 'page[number]': page}
        )
        
        if response.status_code != 200:
            print(f"❌ Error: {response.status_code} - {response.text}")
            return []
        
        data = response.json()
        workspaces.extend(data['data'])
        
        # Check if there are more pages
        if 'next' not in data.get('links', {}):
            break
        
        page += 1
    
    print(f"✅ Found {len(workspaces)} workspaces")
    for ws in workspaces:
        attrs = ws['attributes']
        print(f"   - {attrs['name']} (Terraform {attrs.get('terraform-version', 'N/A')})")
    
    return workspaces


def create_workspace(name: str, terraform_version: str = '1.6.0', 
                    auto_apply: bool = False, description: str = '') -> Optional[str]:
    """Create a new workspace"""
    print(f"\n🔨 Creating workspace: {name}")
    
    payload = {
        'data': {
            'type': 'workspaces',
            'attributes': {
                'name': name,
                'terraform-version': terraform_version,
                'auto-apply': auto_apply,
                'execution-mode': 'remote',
                'description': description or f'Created via API'
            }
        }
    }
    
    response = requests.post(
        f'{BASE_URL}/organizations/{ORG_NAME}/workspaces',
        headers=headers,
        json=payload
    )
    
    if response.status_code == 201:
        workspace = response.json()['data']
        workspace_id = workspace['id']
        print(f"✅ Workspace created successfully")
        print(f"   ID: {workspace_id}")
        print(f"   Name: {workspace['attributes']['name']}")
        print(f"   Terraform Version: {workspace['attributes']['terraform-version']}")
        return workspace_id
    elif response.status_code == 422:
        error = response.json()
        print(f"❌ Validation error: {error}")
        return None
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return None


def get_workspace(name: str) -> Optional[Dict]:
    """Get workspace by name"""
    response = requests.get(
        f'{BASE_URL}/organizations/{ORG_NAME}/workspaces/{name}',
        headers=headers
    )
    
    if response.status_code == 200:
        return response.json()['data']
    else:
        return None


def update_workspace(workspace_id: str, **kwargs) -> bool:
    """Update workspace attributes"""
    print(f"\n🔄 Updating workspace: {workspace_id}")
    
    payload = {
        'data': {
            'type': 'workspaces',
            'attributes': kwargs
        }
    }
    
    response = requests.patch(
        f'{BASE_URL}/workspaces/{workspace_id}',
        headers=headers,
        json=payload
    )
    
    if response.status_code == 200:
        workspace = response.json()['data']
        print(f"✅ Workspace updated successfully")
        for key, value in kwargs.items():
            print(f"   {key}: {value}")
        return True
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return False


def delete_workspace(workspace_id: str) -> bool:
    """Delete a workspace"""
    print(f"\n🗑️  Deleting workspace: {workspace_id}")
    
    response = requests.delete(
        f'{BASE_URL}/workspaces/{workspace_id}',
        headers=headers
    )
    
    if response.status_code == 204:
        print(f"✅ Workspace deleted successfully")
        return True
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return False


def main():
    """Main execution"""
    print("=" * 70)
    print("HCP Terraform Workspace Manager")
    print("=" * 70)
    
    # List existing workspaces
    workspaces = list_workspaces()
    
    # Create a new workspace
    workspace_name = 'api-demo-workspace'
    workspace_id = create_workspace(
        name=workspace_name,
        terraform_version='1.6.0',
        auto_apply=False,
        description='Demo workspace created via API'
    )
    
    if workspace_id:
        # Update the workspace
        update_workspace(
            workspace_id,
            **{
                'auto-apply': True,
                'terraform-version': '1.6.0',
                'description': 'Updated via API'
            }
        )
        
        # Get workspace details
        workspace = get_workspace(workspace_name)
        if workspace:
            print(f"\n📊 Workspace Details:")
            print(f"   ID: {workspace['id']}")
            print(f"   Name: {workspace['attributes']['name']}")
            print(f"   Auto-apply: {workspace['attributes']['auto-apply']}")
            print(f"   Terraform Version: {workspace['attributes']['terraform-version']}")
        
        # Uncomment to delete the workspace
        # delete_workspace(workspace_id)
    
    print("\n" + "=" * 70)
    print("✅ Demo completed successfully")
    print("=" * 70)


if __name__ == '__main__':
    main()

