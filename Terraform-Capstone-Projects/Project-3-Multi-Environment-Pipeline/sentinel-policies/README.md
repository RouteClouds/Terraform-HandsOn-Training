# Sentinel Policies for Project 3

This directory contains Sentinel policies specifically designed for the Multi-Environment Pipeline project.

## 📋 Policies

### 1. environment-specific-instance-types.sentinel

Enforces environment-specific instance type restrictions:
- **Dev**: t3.micro, t3.small only
- **Staging**: t3.small, t3.medium
- **Production**: t3.medium, t3.large, m5.large

**Enforcement Level**: Soft-mandatory

### 2. require-multi-az-prod.sentinel

Ensures production RDS instances are configured with Multi-AZ:
- **Dev/Staging**: Single-AZ allowed
- **Production**: Multi-AZ required

**Enforcement Level**: Hard-mandatory

### 3. cost-limit-by-environment.sentinel

Enforces cost limits per environment:
- **Dev**: $200/month
- **Staging**: $500/month
- **Production**: $2000/month

**Enforcement Level**: Soft-mandatory

## 🚀 Usage

### For HCP Terraform

1. Create a policy set in HCP Terraform
2. Upload these policies
3. Attach to workspaces: `dev-pipeline`, `staging-pipeline`, `prod-pipeline`
4. Configure enforcement levels as specified

### For Local Testing

```bash
# Install Sentinel CLI
wget https://releases.hashicorp.com/sentinel/0.24.0/sentinel_0.24.0_linux_amd64.zip
unzip sentinel_0.24.0_linux_amd64.zip
sudo mv sentinel /usr/local/bin/

# Test policies
sentinel test
```

## 📚 Related Resources

For comprehensive Sentinel policy examples and documentation, see:
- **Topic 12**: `12-terraform-security/sentinel-policies/`
- **Lab 12.4**: Sentinel Policy Implementation

---

**Version**: 1.0  
**Last Updated**: October 28, 2025  
**Part of**: Phase 1 - Sentinel Policy Enhancement

