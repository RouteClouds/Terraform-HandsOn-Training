#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 6: State Management with AWS
Backend Migration and Validation Script

This script helps with Terraform backend migrations, validations,
and provides automation for common state management tasks.

Author: AWS Terraform Training Team
Version: 2.0
Date: January 2025
"""

import json
import sys
import os
import shutil
import subprocess
import argparse
from datetime import datetime
from typing import Dict, List, Any, Optional
import boto3

class TerraformBackendMigrator:
    """Handles Terraform backend migrations and validations."""
    
    def __init__(self, working_dir: str = '.'):
        """Initialize the migrator."""
        self.working_dir = working_dir
        self.backup_dir = os.path.join(working_dir, 'state-backups')
        os.makedirs(self.backup_dir, exist_ok=True)
    
    def backup_state(self, backup_name: Optional[str] = None) -> str:
        """Create a backup of the current state."""
        if not backup_name:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            backup_name = f"terraform_state_backup_{timestamp}.tfstate"
        
        backup_path = os.path.join(self.backup_dir, backup_name)
        
        try:
            # Pull current state
            result = subprocess.run(['terraform', 'state', 'pull'], 
                                  capture_output=True, text=True, check=True,
                                  cwd=self.working_dir)
            
            # Save to backup file
            with open(backup_path, 'w') as f:
                f.write(result.stdout)
            
            print(f"✓ State backed up to: {backup_path}")
            return backup_path
            
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to backup state: {e}")
            return ""
    
    def validate_backend_config(self, config_file: str) -> bool:
        """Validate backend configuration file."""
        if not os.path.exists(config_file):
            print(f"✗ Backend config file not found: {config_file}")
            return False
        
        try:
            with open(config_file, 'r') as f:
                content = f.read()
            
            # Basic validation - check for required fields
            required_fields = ['bucket', 'key', 'region', 'dynamodb_table']
            missing_fields = []
            
            for field in required_fields:
                if field not in content:
                    missing_fields.append(field)
            
            if missing_fields:
                print(f"✗ Missing required fields in backend config: {missing_fields}")
                return False
            
            print("✓ Backend configuration validation passed")
            return True
            
        except Exception as e:
            print(f"✗ Failed to validate backend config: {e}")
            return False
    
    def test_backend_connectivity(self, bucket_name: str, table_name: str, region: str) -> bool:
        """Test connectivity to S3 bucket and DynamoDB table."""
        try:
            # Test S3 connectivity
            s3_client = boto3.client('s3', region_name=region)
            s3_client.head_bucket(Bucket=bucket_name)
            print(f"✓ S3 bucket '{bucket_name}' is accessible")
            
            # Test DynamoDB connectivity
            dynamodb_client = boto3.client('dynamodb', region_name=region)
            dynamodb_client.describe_table(TableName=table_name)
            print(f"✓ DynamoDB table '{table_name}' is accessible")
            
            return True
            
        except Exception as e:
            print(f"✗ Backend connectivity test failed: {e}")
            return False
    
    def migrate_to_remote_backend(self, backend_config: str) -> bool:
        """Migrate from local to remote backend."""
        print("Starting migration to remote backend...")
        
        # Step 1: Backup current state
        backup_path = self.backup_state()
        if not backup_path:
            return False
        
        # Step 2: Validate backend configuration
        if not self.validate_backend_config(backend_config):
            return False
        
        # Step 3: Initialize with migration
        try:
            print("Initializing Terraform with backend migration...")
            result = subprocess.run([
                'terraform', 'init', 
                '-migrate-state',
                f'-backend-config={backend_config}'
            ], capture_output=True, text=True, cwd=self.working_dir)
            
            if result.returncode != 0:
                print(f"✗ Migration failed: {result.stderr}")
                return False
            
            print("✓ Backend migration completed successfully")
            
            # Step 4: Verify migration
            return self.verify_state_integrity()
            
        except Exception as e:
            print(f"✗ Migration failed: {e}")
            return False
    
    def verify_state_integrity(self) -> bool:
        """Verify state file integrity after migration."""
        try:
            # Test state operations
            print("Verifying state integrity...")
            
            # List resources
            result = subprocess.run(['terraform', 'state', 'list'], 
                                  capture_output=True, text=True, check=True,
                                  cwd=self.working_dir)
            
            resource_count = len(result.stdout.strip().split('\n')) if result.stdout.strip() else 0
            print(f"✓ State contains {resource_count} resources")
            
            # Test plan operation
            result = subprocess.run(['terraform', 'plan', '-detailed-exitcode'], 
                                  capture_output=True, text=True,
                                  cwd=self.working_dir)
            
            if result.returncode == 0:
                print("✓ No changes detected - state is consistent")
            elif result.returncode == 2:
                print("⚠ Changes detected - this may be expected")
            else:
                print(f"✗ Plan operation failed: {result.stderr}")
                return False
            
            return True
            
        except Exception as e:
            print(f"✗ State integrity verification failed: {e}")
            return False
    
    def create_backend_config_file(self, bucket: str, table: str, region: str, 
                                 key: str = "terraform.tfstate", 
                                 output_file: str = "backend.hcl") -> str:
        """Create a backend configuration file."""
        config_content = f"""bucket         = "{bucket}"
key            = "{key}"
region         = "{region}"
dynamodb_table = "{table}"
encrypt        = true
"""
        
        config_path = os.path.join(self.working_dir, output_file)
        
        with open(config_path, 'w') as f:
            f.write(config_content)
        
        print(f"✓ Backend configuration created: {config_path}")
        return config_path
    
    def workspace_migration(self, source_workspace: str, target_workspace: str) -> bool:
        """Migrate state between workspaces."""
        try:
            print(f"Migrating from workspace '{source_workspace}' to '{target_workspace}'...")
            
            # Create target workspace if it doesn't exist
            subprocess.run(['terraform', 'workspace', 'new', target_workspace], 
                          capture_output=True, cwd=self.working_dir)
            
            # Switch to source workspace
            result = subprocess.run(['terraform', 'workspace', 'select', source_workspace], 
                                  capture_output=True, text=True, cwd=self.working_dir)
            
            if result.returncode != 0:
                print(f"✗ Failed to select source workspace: {result.stderr}")
                return False
            
            # Pull state from source
            source_state = subprocess.run(['terraform', 'state', 'pull'], 
                                        capture_output=True, text=True, check=True,
                                        cwd=self.working_dir)
            
            # Switch to target workspace
            subprocess.run(['terraform', 'workspace', 'select', target_workspace], 
                          check=True, cwd=self.working_dir)
            
            # Push state to target
            process = subprocess.Popen(['terraform', 'state', 'push', '-'], 
                                     stdin=subprocess.PIPE, 
                                     stdout=subprocess.PIPE, 
                                     stderr=subprocess.PIPE,
                                     text=True, cwd=self.working_dir)
            
            stdout, stderr = process.communicate(input=source_state.stdout)
            
            if process.returncode != 0:
                print(f"✗ Failed to push state to target workspace: {stderr}")
                return False
            
            print(f"✓ Workspace migration completed successfully")
            return True
            
        except Exception as e:
            print(f"✗ Workspace migration failed: {e}")
            return False
    
    def force_unlock_state(self, lock_id: str) -> bool:
        """Force unlock a stuck state lock."""
        try:
            print(f"Force unlocking state with lock ID: {lock_id}")
            
            result = subprocess.run(['terraform', 'force-unlock', '-force', lock_id], 
                                  capture_output=True, text=True, cwd=self.working_dir)
            
            if result.returncode != 0:
                print(f"✗ Failed to force unlock: {result.stderr}")
                return False
            
            print("✓ State unlocked successfully")
            return True
            
        except Exception as e:
            print(f"✗ Force unlock failed: {e}")
            return False
    
    def restore_from_backup(self, backup_file: str) -> bool:
        """Restore state from backup file."""
        try:
            if not os.path.exists(backup_file):
                print(f"✗ Backup file not found: {backup_file}")
                return False
            
            print(f"Restoring state from backup: {backup_file}")
            
            with open(backup_file, 'r') as f:
                backup_content = f.read()
            
            # Push backup state
            process = subprocess.Popen(['terraform', 'state', 'push', '-'], 
                                     stdin=subprocess.PIPE, 
                                     stdout=subprocess.PIPE, 
                                     stderr=subprocess.PIPE,
                                     text=True, cwd=self.working_dir)
            
            stdout, stderr = process.communicate(input=backup_content)
            
            if process.returncode != 0:
                print(f"✗ Failed to restore from backup: {stderr}")
                return False
            
            print("✓ State restored from backup successfully")
            return True
            
        except Exception as e:
            print(f"✗ Restore from backup failed: {e}")
            return False

def main():
    """Main function."""
    parser = argparse.ArgumentParser(description='Terraform backend migration and validation tool')
    parser.add_argument('--action', required=True, 
                       choices=['backup', 'migrate', 'validate', 'test-connectivity', 
                               'create-config', 'workspace-migrate', 'force-unlock', 'restore'],
                       help='Action to perform')
    parser.add_argument('--bucket', help='S3 bucket name')
    parser.add_argument('--table', help='DynamoDB table name')
    parser.add_argument('--region', default='us-east-1', help='AWS region')
    parser.add_argument('--key', default='terraform.tfstate', help='State file key')
    parser.add_argument('--config', help='Backend configuration file')
    parser.add_argument('--source-workspace', help='Source workspace for migration')
    parser.add_argument('--target-workspace', help='Target workspace for migration')
    parser.add_argument('--lock-id', help='Lock ID for force unlock')
    parser.add_argument('--backup-file', help='Backup file for restore')
    parser.add_argument('--working-dir', default='.', help='Terraform working directory')
    
    args = parser.parse_args()
    
    migrator = TerraformBackendMigrator(working_dir=args.working_dir)
    
    if args.action == 'backup':
        migrator.backup_state()
    
    elif args.action == 'validate':
        if not args.config:
            print("✗ --config required for validation")
            sys.exit(1)
        migrator.validate_backend_config(args.config)
    
    elif args.action == 'test-connectivity':
        if not all([args.bucket, args.table]):
            print("✗ --bucket and --table required for connectivity test")
            sys.exit(1)
        migrator.test_backend_connectivity(args.bucket, args.table, args.region)
    
    elif args.action == 'create-config':
        if not all([args.bucket, args.table]):
            print("✗ --bucket and --table required for config creation")
            sys.exit(1)
        migrator.create_backend_config_file(args.bucket, args.table, args.region, args.key)
    
    elif args.action == 'migrate':
        if not args.config:
            print("✗ --config required for migration")
            sys.exit(1)
        success = migrator.migrate_to_remote_backend(args.config)
        sys.exit(0 if success else 1)
    
    elif args.action == 'workspace-migrate':
        if not all([args.source_workspace, args.target_workspace]):
            print("✗ --source-workspace and --target-workspace required")
            sys.exit(1)
        success = migrator.workspace_migration(args.source_workspace, args.target_workspace)
        sys.exit(0 if success else 1)
    
    elif args.action == 'force-unlock':
        if not args.lock_id:
            print("✗ --lock-id required for force unlock")
            sys.exit(1)
        success = migrator.force_unlock_state(args.lock_id)
        sys.exit(0 if success else 1)
    
    elif args.action == 'restore':
        if not args.backup_file:
            print("✗ --backup-file required for restore")
            sys.exit(1)
        success = migrator.restore_from_backup(args.backup_file)
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
