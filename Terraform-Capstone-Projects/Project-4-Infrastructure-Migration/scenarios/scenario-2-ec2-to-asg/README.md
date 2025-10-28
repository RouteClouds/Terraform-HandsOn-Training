# Scenario 2: EC2 to Auto Scaling Group Conversion

## 📋 Overview

**Complexity**: Intermediate  
**Duration**: 2-3 hours  
**Resources**: EC2 Instances, Launch Template, Auto Scaling Group, Target Group

This scenario demonstrates how to convert standalone EC2 instances into an Auto Scaling Group with zero downtime.

---

## 🎯 Learning Objectives

- Import EC2 instances
- Create Launch Template from existing instance
- Convert to Auto Scaling Group
- Implement zero-downtime migration
- Use state manipulation commands

---

## 🏗️ Migration Strategy

### Phase 1: Import Existing EC2 Instances
1. Import EC2 instances into Terraform
2. Import security group
3. Validate configuration

### Phase 2: Create Launch Template
1. Create Launch Template based on existing instance
2. Test Launch Template
3. Validate new instances match existing

### Phase 3: Create Auto Scaling Group
1. Create ASG with Launch Template
2. Set desired capacity to match existing instances
3. Wait for new instances to be healthy

### Phase 4: Cutover
1. Remove old instances from load balancer (if applicable)
2. Terminate old instances
3. Remove old instances from Terraform state

---

## 📝 Step-by-Step Process

### Step 1: Import Existing EC2 Instances

```bash
cd imported
terraform init

# Import security group
terraform import aws_security_group.web <sg_id>

# Import EC2 instances
terraform import 'aws_instance.web[0]' <instance_1_id>
terraform import 'aws_instance.web[1]' <instance_2_id>
```

### Step 2: Validate Import

```bash
terraform plan
# Should show no changes
```

### Step 3: Create Launch Template

Add Launch Template configuration to `main.tf`:

```hcl
resource "aws_launch_template" "web" {
  name_prefix   = "web-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  
  # ... other configuration
}
```

### Step 4: Create Auto Scaling Group

```hcl
resource "aws_autoscaling_group" "web" {
  name                = "web-asg"
  vpc_zone_identifier = data.aws_subnets.public.ids
  desired_capacity    = 2
  min_size            = 2
  max_size            = 6
  
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}
```

### Step 5: Apply Changes

```bash
terraform apply
```

This creates the ASG alongside existing instances.

### Step 6: Verify New Instances

```bash
# Check ASG instances are healthy
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names web-asg
```

### Step 7: Remove Old Instances

```bash
# Remove from state (doesn't terminate)
terraform state rm 'aws_instance.web[0]'
terraform state rm 'aws_instance.web[1]'

# Manually terminate old instances
aws ec2 terminate-instances --instance-ids <instance_1_id> <instance_2_id>
```

### Step 8: Clean Up Configuration

Remove the `aws_instance` resources from `main.tf`.

### Step 9: Final Validation

```bash
terraform plan
# Should show no changes
```

---

## 🔄 Zero-Downtime Strategy

### Option 1: Parallel Running (Recommended)

1. Keep old instances running
2. Create ASG with new instances
3. Add new instances to load balancer
4. Verify new instances are healthy
5. Remove old instances from load balancer
6. Terminate old instances

### Option 2: Blue-Green Deployment

1. Create new ASG (green)
2. Test green environment
3. Switch traffic to green
4. Terminate blue environment

---

## 🛠️ State Manipulation Commands

### List Current Resources

```bash
terraform state list
```

### Show Instance Details

```bash
terraform state show 'aws_instance.web[0]'
```

### Remove Instance from State

```bash
terraform state rm 'aws_instance.web[0]'
```

### Move Resource

```bash
# If refactoring to module
terraform state mv aws_autoscaling_group.web module.asg.aws_autoscaling_group.web
```

---

## 🔍 Verification Steps

### 1. Check ASG Status

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names web-asg \
  --query 'AutoScalingGroups[0].Instances[*].[InstanceId,HealthStatus,LifecycleState]' \
  --output table
```

### 2. Check Instance Health

```bash
aws ec2 describe-instance-status \
  --instance-ids <instance_id> \
  --query 'InstanceStatuses[*].[InstanceId,InstanceState.Name,SystemStatus.Status,InstanceStatus.Status]' \
  --output table
```

### 3. Test Application

```bash
# Get instance public IPs
aws ec2 describe-instances \
  --filters "Name=tag:aws:autoscaling:groupName,Values=web-asg" \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text

# Test each instance
curl http://<instance_ip>
```

---

## 🎓 Key Concepts

### Launch Template vs Launch Configuration

- **Launch Template**: Newer, more features, versioning support
- **Launch Configuration**: Legacy, being phased out

Always use Launch Templates for new deployments.

### Instance Refresh

ASG supports instance refresh for rolling updates:

```hcl
resource "aws_autoscaling_group" "web" {
  # ... other configuration
  
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}
```

### Lifecycle Hooks

For graceful shutdown:

```hcl
resource "aws_autoscaling_lifecycle_hook" "terminating" {
  name                   = "terminating-hook"
  autoscaling_group_name = aws_autoscaling_group.web.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
}
```

---

## 🚨 Troubleshooting

### Issue: ASG instances fail health checks

**Solution**: Check security group rules, user data script, and application logs.

### Issue: Old instances still receiving traffic

**Solution**: Verify load balancer target group deregistration.

### Issue: State manipulation fails

**Solution**: Backup state first:
```bash
terraform state pull > backup.tfstate
```

---

## ✅ Success Criteria

- [ ] EC2 instances imported successfully
- [ ] Launch Template created
- [ ] ASG created and healthy
- [ ] New instances pass health checks
- [ ] Old instances removed cleanly
- [ ] Zero downtime achieved
- [ ] `terraform plan` shows no changes

---

## 📝 Rollback Procedure

If migration fails:

1. **Stop ASG scaling**:
   ```bash
   aws autoscaling suspend-processes --auto-scaling-group-name web-asg
   ```

2. **Restore old instances** (if still running):
   ```bash
   # Re-import to state
   terraform import 'aws_instance.web[0]' <instance_id>
   ```

3. **Delete ASG**:
   ```bash
   terraform destroy -target=aws_autoscaling_group.web
   ```

4. **Restore state from backup**:
   ```bash
   terraform state push backup.tfstate
   ```

---

**Scenario Status**: Ready for Implementation  
**Last Updated**: October 27, 2025

