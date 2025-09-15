#!/usr/bin/env python3
"""
AWS Terraform Training - Topic 6: State Management with AWS
State Analysis and Validation Script

This script analyzes Terraform state files and backend configurations
to provide insights into state health, security, and optimization opportunities.

Author: AWS Terraform Training Team
Version: 2.0
Date: January 2025
"""

import json
import sys
import boto3
import argparse
from datetime import datetime, timezone
from typing import Dict, List, Any, Optional
import subprocess
import os

class TerraformStateAnalyzer:
    """Analyzes Terraform state and backend configuration."""
    
    def __init__(self, region: str = 'us-east-1'):
        """Initialize the analyzer with AWS clients."""
        self.region = region
        self.s3_client = boto3.client('s3', region_name=region)
        self.dynamodb_client = boto3.client('dynamodb', region_name=region)
        self.kms_client = boto3.client('kms', region_name=region)
        
    def analyze_state_file(self, state_content: str) -> Dict[str, Any]:
        """Analyze Terraform state file content."""
        try:
            state_data = json.loads(state_content)
        except json.JSONDecodeError as e:
            return {"error": f"Invalid JSON in state file: {e}"}
        
        analysis = {
            "terraform_version": state_data.get("terraform_version", "unknown"),
            "format_version": state_data.get("version", "unknown"),
            "serial": state_data.get("serial", 0),
            "lineage": state_data.get("lineage", "unknown"),
            "resources": [],
            "resource_count": 0,
            "resource_types": {},
            "providers": set(),
            "modules": set(),
            "outputs": list(state_data.get("outputs", {}).keys()),
            "last_modified": datetime.now(timezone.utc).isoformat()
        }
        
        # Analyze resources
        resources = state_data.get("resources", [])
        analysis["resource_count"] = len(resources)
        
        for resource in resources:
            resource_type = resource.get("type", "unknown")
            provider = resource.get("provider", "unknown")
            module = resource.get("module", "root")
            
            # Count resource types
            analysis["resource_types"][resource_type] = analysis["resource_types"].get(resource_type, 0) + 1
            
            # Track providers and modules
            analysis["providers"].add(provider)
            analysis["modules"].add(module)
            
            # Resource details
            analysis["resources"].append({
                "name": resource.get("name", "unknown"),
                "type": resource_type,
                "provider": provider,
                "module": module,
                "instances": len(resource.get("instances", []))
            })
        
        # Convert sets to lists for JSON serialization
        analysis["providers"] = list(analysis["providers"])
        analysis["modules"] = list(analysis["modules"])
        
        return analysis
    
    def analyze_s3_backend(self, bucket_name: str) -> Dict[str, Any]:
        """Analyze S3 backend configuration and health."""
        try:
            # Get bucket information
            bucket_info = self.s3_client.head_bucket(Bucket=bucket_name)
            
            # Check versioning
            versioning = self.s3_client.get_bucket_versioning(Bucket=bucket_name)
            
            # Check encryption
            try:
                encryption = self.s3_client.get_bucket_encryption(Bucket=bucket_name)
                encryption_config = encryption.get('ServerSideEncryptionConfiguration', {})
            except self.s3_client.exceptions.ClientError:
                encryption_config = {}
            
            # Check public access block
            try:
                public_access = self.s3_client.get_public_access_block(Bucket=bucket_name)
                public_access_config = public_access.get('PublicAccessBlockConfiguration', {})
            except self.s3_client.exceptions.ClientError:
                public_access_config = {}
            
            # List state files
            objects = self.s3_client.list_objects_v2(Bucket=bucket_name)
            state_files = []
            total_size = 0
            
            for obj in objects.get('Contents', []):
                if obj['Key'].endswith('.tfstate'):
                    state_files.append({
                        "key": obj['Key'],
                        "size": obj['Size'],
                        "last_modified": obj['LastModified'].isoformat(),
                        "etag": obj['ETag']
                    })
                    total_size += obj['Size']
            
            return {
                "bucket_name": bucket_name,
                "region": bucket_info.get('ResponseMetadata', {}).get('HTTPHeaders', {}).get('x-amz-bucket-region', 'unknown'),
                "versioning_enabled": versioning.get('Status') == 'Enabled',
                "encryption_enabled": bool(encryption_config),
                "encryption_algorithm": encryption_config.get('Rules', [{}])[0].get('ApplyServerSideEncryptionByDefault', {}).get('SSEAlgorithm'),
                "kms_key_id": encryption_config.get('Rules', [{}])[0].get('ApplyServerSideEncryptionByDefault', {}).get('KMSMasterKeyID'),
                "public_access_blocked": all([
                    public_access_config.get('BlockPublicAcls', False),
                    public_access_config.get('IgnorePublicAcls', False),
                    public_access_config.get('BlockPublicPolicy', False),
                    public_access_config.get('RestrictPublicBuckets', False)
                ]),
                "state_files": state_files,
                "state_file_count": len(state_files),
                "total_state_size_bytes": total_size,
                "total_state_size_mb": round(total_size / 1024 / 1024, 2)
            }
            
        except Exception as e:
            return {"error": f"Failed to analyze S3 backend: {e}"}
    
    def analyze_dynamodb_locks(self, table_name: str) -> Dict[str, Any]:
        """Analyze DynamoDB state locking table."""
        try:
            # Get table description
            table_info = self.dynamodb_client.describe_table(TableName=table_name)
            table = table_info['Table']
            
            # Scan for current locks
            locks = self.dynamodb_client.scan(TableName=table_name)
            
            active_locks = []
            for item in locks.get('Items', []):
                lock_id = item.get('LockID', {}).get('S', 'unknown')
                info = json.loads(item.get('Info', {}).get('S', '{}'))
                
                active_locks.append({
                    "lock_id": lock_id,
                    "operation": info.get('Operation', 'unknown'),
                    "who": info.get('Who', 'unknown'),
                    "version": info.get('Version', 'unknown'),
                    "created": info.get('Created', 'unknown'),
                    "path": info.get('Path', 'unknown')
                })
            
            return {
                "table_name": table_name,
                "table_status": table['TableStatus'],
                "billing_mode": table.get('BillingModeSummary', {}).get('BillingMode', 'PROVISIONED'),
                "item_count": table['ItemCount'],
                "table_size_bytes": table['TableSizeBytes'],
                "point_in_time_recovery": table.get('RestorePointInTimeDescription', {}).get('PointInTimeRecoveryStatus') == 'ENABLED',
                "encryption_enabled": 'SSEDescription' in table,
                "encryption_type": table.get('SSEDescription', {}).get('SSEType'),
                "kms_key_id": table.get('SSEDescription', {}).get('KMSMasterKeyArn'),
                "active_locks": active_locks,
                "active_lock_count": len(active_locks)
            }
            
        except Exception as e:
            return {"error": f"Failed to analyze DynamoDB table: {e}"}
    
    def get_terraform_state(self) -> Optional[str]:
        """Get current Terraform state."""
        try:
            result = subprocess.run(['terraform', 'state', 'pull'], 
                                  capture_output=True, text=True, check=True)
            return result.stdout
        except subprocess.CalledProcessError as e:
            print(f"Error pulling Terraform state: {e}")
            return None
    
    def generate_recommendations(self, analysis: Dict[str, Any]) -> List[str]:
        """Generate recommendations based on analysis."""
        recommendations = []
        
        # S3 Backend recommendations
        s3_analysis = analysis.get('s3_backend', {})
        if not s3_analysis.get('versioning_enabled', False):
            recommendations.append("Enable S3 bucket versioning for state file history")
        
        if not s3_analysis.get('encryption_enabled', False):
            recommendations.append("Enable S3 bucket encryption for state file security")
        
        if not s3_analysis.get('public_access_blocked', False):
            recommendations.append("Enable S3 public access block for security")
        
        # DynamoDB recommendations
        dynamodb_analysis = analysis.get('dynamodb_locks', {})
        if not dynamodb_analysis.get('point_in_time_recovery', False):
            recommendations.append("Enable DynamoDB point-in-time recovery")
        
        if not dynamodb_analysis.get('encryption_enabled', False):
            recommendations.append("Enable DynamoDB encryption at rest")
        
        # State file recommendations
        state_analysis = analysis.get('state_analysis', {})
        if state_analysis.get('resource_count', 0) > 100:
            recommendations.append("Consider splitting large state files into smaller modules")
        
        # Active locks warning
        if dynamodb_analysis.get('active_lock_count', 0) > 0:
            recommendations.append("WARNING: Active state locks detected - investigate potential issues")
        
        return recommendations

def main():
    """Main function."""
    parser = argparse.ArgumentParser(description='Analyze Terraform state and backend configuration')
    parser.add_argument('--bucket', help='S3 bucket name for state storage')
    parser.add_argument('--table', help='DynamoDB table name for state locking')
    parser.add_argument('--region', default='us-east-1', help='AWS region')
    parser.add_argument('--output', choices=['json', 'text'], default='text', help='Output format')
    
    args = parser.parse_args()
    
    analyzer = TerraformStateAnalyzer(region=args.region)
    analysis = {}
    
    # Analyze current state
    print("Analyzing Terraform state...")
    state_content = analyzer.get_terraform_state()
    if state_content:
        analysis['state_analysis'] = analyzer.analyze_state_file(state_content)
    
    # Analyze S3 backend
    if args.bucket:
        print(f"Analyzing S3 backend: {args.bucket}")
        analysis['s3_backend'] = analyzer.analyze_s3_backend(args.bucket)
    
    # Analyze DynamoDB locks
    if args.table:
        print(f"Analyzing DynamoDB locks: {args.table}")
        analysis['dynamodb_locks'] = analyzer.analyze_dynamodb_locks(args.table)
    
    # Generate recommendations
    recommendations = analyzer.generate_recommendations(analysis)
    analysis['recommendations'] = recommendations
    
    # Output results
    if args.output == 'json':
        print(json.dumps(analysis, indent=2, default=str))
    else:
        # Text output
        print("\n" + "="*80)
        print("TERRAFORM STATE ANALYSIS REPORT")
        print("="*80)
        
        if 'state_analysis' in analysis:
            state = analysis['state_analysis']
            print(f"\nState File Analysis:")
            print(f"  Terraform Version: {state.get('terraform_version')}")
            print(f"  Resource Count: {state.get('resource_count')}")
            print(f"  Provider Count: {len(state.get('providers', []))}")
            print(f"  Module Count: {len(state.get('modules', []))}")
        
        if 's3_backend' in analysis:
            s3 = analysis['s3_backend']
            print(f"\nS3 Backend Analysis:")
            print(f"  Bucket: {s3.get('bucket_name')}")
            print(f"  Versioning: {'✓' if s3.get('versioning_enabled') else '✗'}")
            print(f"  Encryption: {'✓' if s3.get('encryption_enabled') else '✗'}")
            print(f"  Public Access Blocked: {'✓' if s3.get('public_access_blocked') else '✗'}")
            print(f"  State Files: {s3.get('state_file_count')}")
            print(f"  Total Size: {s3.get('total_state_size_mb')} MB")
        
        if 'dynamodb_locks' in analysis:
            dynamo = analysis['dynamodb_locks']
            print(f"\nDynamoDB Locks Analysis:")
            print(f"  Table: {dynamo.get('table_name')}")
            print(f"  Status: {dynamo.get('table_status')}")
            print(f"  Billing Mode: {dynamo.get('billing_mode')}")
            print(f"  Point-in-Time Recovery: {'✓' if dynamo.get('point_in_time_recovery') else '✗'}")
            print(f"  Encryption: {'✓' if dynamo.get('encryption_enabled') else '✗'}")
            print(f"  Active Locks: {dynamo.get('active_lock_count')}")
        
        if recommendations:
            print(f"\nRecommendations:")
            for i, rec in enumerate(recommendations, 1):
                print(f"  {i}. {rec}")
        
        print("\n" + "="*80)

if __name__ == "__main__":
    main()
