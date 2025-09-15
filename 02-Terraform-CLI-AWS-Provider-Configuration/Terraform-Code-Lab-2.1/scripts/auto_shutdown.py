#!/usr/bin/env python3
"""
AWS Terraform Training - Terraform CLI & AWS Provider Configuration
Lab 2.1: Auto-Shutdown Lambda Function for Cost Optimization

This Lambda function automatically stops or terminates resources
based on tags to optimize costs for training environments.
"""

import json
import boto3
import logging
import os
from datetime import datetime, timezone
from typing import List, Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
ec2_client = boto3.client('ec2')
s3_client = boto3.client('s3')

# Environment variables
STUDENT_NAME = os.environ.get('STUDENT_NAME', 'unknown')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'development')
REGION = os.environ.get('REGION', 'us-east-1')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler function for auto-shutdown functionality.
    
    Args:
        event: Lambda event data
        context: Lambda context object
        
    Returns:
        Dict containing execution results
    """
    logger.info(f"Auto-shutdown Lambda started for student: {STUDENT_NAME}")
    logger.info(f"Environment: {ENVIRONMENT}, Region: {REGION}")
    
    try:
        # Get resources to shutdown
        resources_to_shutdown = get_resources_to_shutdown()
        
        if not resources_to_shutdown:
            logger.info("No resources found for auto-shutdown")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'No resources found for auto-shutdown',
                    'student_name': STUDENT_NAME,
                    'environment': ENVIRONMENT,
                    'timestamp': datetime.now(timezone.utc).isoformat()
                })
            }
        
        # Process shutdown for each resource
        shutdown_results = []
        for resource in resources_to_shutdown:
            result = process_resource_shutdown(resource)
            shutdown_results.append(result)
        
        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Auto-shutdown completed for {len(shutdown_results)} resources',
                'student_name': STUDENT_NAME,
                'environment': ENVIRONMENT,
                'resources_processed': len(shutdown_results),
                'results': shutdown_results,
                'timestamp': datetime.now(timezone.utc).isoformat()
            })
        }
        
    except Exception as e:
        logger.error(f"Error in auto-shutdown Lambda: {str(e)}")
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Auto-shutdown failed',
                'message': str(e),
                'student_name': STUDENT_NAME,
                'environment': ENVIRONMENT,
                'timestamp': datetime.now(timezone.utc).isoformat()
            })
        }

def get_resources_to_shutdown() -> List[Dict[str, Any]]:
    """
    Get resources that should be shut down based on tags.
    
    Returns:
        List of resource dictionaries
    """
    resources = []
    
    try:
        # Get EC2 instances
        ec2_instances = get_ec2_instances_to_shutdown()
        resources.extend(ec2_instances)
        
        # Get other resources (S3 buckets, etc.) if needed
        # For this lab, we'll focus on EC2 instances
        
        logger.info(f"Found {len(resources)} resources for potential shutdown")
        return resources
        
    except Exception as e:
        logger.error(f"Error getting resources: {str(e)}")
        raise

def get_ec2_instances_to_shutdown() -> List[Dict[str, Any]]:
    """
    Get EC2 instances that should be shut down.
    
    Returns:
        List of EC2 instance dictionaries
    """
    try:
        # Define filters for instances to shutdown
        filters = [
            {
                'Name': 'tag:Student',
                'Values': [STUDENT_NAME]
            },
            {
                'Name': 'tag:Environment',
                'Values': [ENVIRONMENT]
            },
            {
                'Name': 'tag:AutoShutdown',
                'Values': ['true', 'enabled']
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
        
        # Get instances
        response = ec2_client.describe_instances(Filters=filters)
        
        instances = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instance_info = {
                    'type': 'ec2-instance',
                    'id': instance['InstanceId'],
                    'instance_type': instance['InstanceType'],
                    'launch_time': instance['LaunchTime'],
                    'state': instance['State']['Name'],
                    'tags': {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
                }
                instances.append(instance_info)
        
        return instances
        
    except Exception as e:
        logger.error(f"Error getting EC2 instances: {str(e)}")
        return []

def process_resource_shutdown(resource: Dict[str, Any]) -> Dict[str, Any]:
    """
    Process shutdown for a single resource.
    
    Args:
        resource: Resource information dictionary
        
    Returns:
        Dict containing shutdown result
    """
    resource_type = resource['type']
    resource_id = resource['id']
    
    try:
        logger.info(f"Processing shutdown for {resource_type}: {resource_id}")
        
        if resource_type == 'ec2-instance':
            return shutdown_ec2_instance(resource)
        else:
            logger.warning(f"Unknown resource type: {resource_type}")
            return {
                'resource_type': resource_type,
                'resource_id': resource_id,
                'action': 'skipped',
                'status': 'unknown_type',
                'timestamp': datetime.now(timezone.utc).isoformat()
            }
        
    except Exception as e:
        logger.error(f"Error processing resource {resource_id}: {str(e)}")
        return {
            'resource_type': resource_type,
            'resource_id': resource_id,
            'action': 'failed',
            'status': 'error',
            'error': str(e),
            'timestamp': datetime.now(timezone.utc).isoformat()
        }

def shutdown_ec2_instance(instance: Dict[str, Any]) -> Dict[str, Any]:
    """
    Shutdown an EC2 instance.
    
    Args:
        instance: Instance information dictionary
        
    Returns:
        Dict containing shutdown result
    """
    instance_id = instance['id']
    instance_type = instance['instance_type']
    tags = instance['tags']
    
    try:
        # Determine shutdown action based on environment
        if ENVIRONMENT in ['development', 'lab', 'test']:
            # Terminate instances in development/lab environments
            action = 'terminate'
            ec2_client.terminate_instances(InstanceIds=[instance_id])
            logger.info(f"Terminated instance: {instance_id}")
        else:
            # Stop instances in other environments
            action = 'stop'
            ec2_client.stop_instances(InstanceIds=[instance_id])
            logger.info(f"Stopped instance: {instance_id}")
        
        return {
            'resource_type': 'ec2-instance',
            'resource_id': instance_id,
            'instance_type': instance_type,
            'action': action,
            'status': 'success',
            'student': tags.get('Student', 'unknown'),
            'environment': tags.get('Environment', 'unknown'),
            'timestamp': datetime.now(timezone.utc).isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error shutting down instance {instance_id}: {str(e)}")
        return {
            'resource_type': 'ec2-instance',
            'resource_id': instance_id,
            'instance_type': instance_type,
            'action': 'failed',
            'status': 'error',
            'error': str(e),
            'student': tags.get('Student', 'unknown'),
            'environment': tags.get('Environment', 'unknown'),
            'timestamp': datetime.now(timezone.utc).isoformat()
        }

def get_resource_uptime_hours(launch_time: datetime) -> float:
    """
    Calculate resource uptime in hours.
    
    Args:
        launch_time: Resource launch timestamp
        
    Returns:
        Uptime in hours
    """
    now = datetime.now(timezone.utc)
    if launch_time.tzinfo is None:
        launch_time = launch_time.replace(tzinfo=timezone.utc)
    
    uptime_delta = now - launch_time
    return uptime_delta.total_seconds() / 3600

def should_shutdown_resource(resource: Dict[str, Any], max_uptime_hours: int = 4) -> bool:
    """
    Determine if a resource should be shut down based on uptime.
    
    Args:
        resource: Resource information
        max_uptime_hours: Maximum allowed uptime in hours
        
    Returns:
        True if resource should be shut down
    """
    try:
        if 'launch_time' in resource:
            launch_time = resource['launch_time']
            uptime_hours = get_resource_uptime_hours(launch_time)
            
            logger.info(f"Resource {resource['id']} uptime: {uptime_hours:.2f} hours")
            
            return uptime_hours >= max_uptime_hours
        
        return False
        
    except Exception as e:
        logger.error(f"Error checking resource uptime: {str(e)}")
        return False

def get_cost_savings_estimate(resources_count: int) -> Dict[str, float]:
    """
    Calculate estimated cost savings from shutdown.
    
    Args:
        resources_count: Number of resources being shut down
        
    Returns:
        Dict with cost savings estimates
    """
    # Estimated costs (approximate)
    hourly_rate = 0.0116  # t3.micro pricing
    
    return {
        'hourly_savings': resources_count * hourly_rate,
        'daily_savings': resources_count * hourly_rate * 24,
        'monthly_savings': resources_count * hourly_rate * 24 * 30
    }

def log_shutdown_metrics(results: List[Dict[str, Any]]) -> None:
    """
    Log metrics for monitoring and analysis.
    
    Args:
        results: Shutdown results
    """
    try:
        successful_count = len([r for r in results if r['status'] == 'success'])
        failed_count = len([r for r in results if r['status'] == 'error'])
        
        logger.info(f"METRICS: successful_shutdowns={successful_count}")
        logger.info(f"METRICS: failed_shutdowns={failed_count}")
        logger.info(f"METRICS: total_processed={len(results)}")
        logger.info(f"METRICS: student={STUDENT_NAME}")
        logger.info(f"METRICS: environment={ENVIRONMENT}")
        
    except Exception as e:
        logger.error(f"Error logging metrics: {str(e)}")

# Test function for local development
if __name__ == "__main__":
    # Test event
    test_event = {}
    test_context = type('Context', (), {
        'function_name': 'test-auto-shutdown',
        'aws_request_id': 'test-request-id'
    })()
    
    # Run handler
    result = lambda_handler(test_event, test_context)
    print(json.dumps(result, indent=2))
