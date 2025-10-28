# HCP Terraform API Examples

This directory contains working examples demonstrating how to interact with the HCP Terraform API programmatically.

## 📋 Prerequisites

### 1. HCP Terraform Account

Sign up at https://app.terraform.io if you don't have an account.

### 2. API Token

Create an API token:
1. Navigate to User Settings → Tokens
2. Click "Create an API token"
3. Enter description (e.g., "API Examples")
4. Copy the token (shown only once)

### 3. Environment Variables

```bash
# Required
export TFC_TOKEN="your-api-token-here"

# Optional (defaults to 'my-organization')
export TFC_ORG="your-organization-name"
```

### 4. Dependencies

**Python Examples**:
```bash
pip install requests
```

**Bash Examples**:
```bash
# Requires jq for JSON parsing
sudo apt-get install jq  # Ubuntu/Debian
brew install jq          # macOS
```

---

## 🐍 Python Examples

### 1. Workspace Manager (`workspace_manager.py`)

**Purpose**: Demonstrates workspace management operations

**Features**:
- List all workspaces in organization
- Create new workspace
- Update workspace attributes
- Delete workspace
- Get workspace details

**Usage**:
```bash
# Make executable
chmod +x workspace_manager.py

# Run
./workspace_manager.py
```

**Example Output**:
```
======================================================================
HCP Terraform Workspace Manager
======================================================================

📋 Listing workspaces in organization: my-org
✅ Found 5 workspaces
   - prod-infrastructure (Terraform 1.6.0)
   - staging-infrastructure (Terraform 1.6.0)
   - dev-infrastructure (Terraform 1.5.7)

🔨 Creating workspace: api-demo-workspace
✅ Workspace created successfully
   ID: ws-abc123def456
   Name: api-demo-workspace
   Terraform Version: 1.6.0

🔄 Updating workspace: ws-abc123def456
✅ Workspace updated successfully
   auto-apply: True
   terraform-version: 1.6.0
   description: Updated via API
```

---

### 2. Run Manager (`run_manager.py`)

**Purpose**: Demonstrates run management operations

**Features**:
- Create new run (queue plan)
- Get run status
- Wait for run completion
- Apply run
- Cancel run
- List recent runs

**Usage**:
```bash
# Make executable
chmod +x run_manager.py

# Run
./run_manager.py
```

**Interactive Prompts**:
```
Enter workspace name: prod-infrastructure
✅ Workspace ID: ws-abc123

📋 Listing recent runs (limit: 5)...
✅ Found 3 runs
   - run-xyz789: applied - Deployed new feature
   - run-abc456: planned_and_finished - Testing changes
   - run-def123: errored - Configuration error

🚀 Creating run...
   Message: Demo run via API
   Destroy: False
✅ Run created successfully
   Run ID: run-new123
   Status: pending

⏳ Waiting for run to complete (timeout: 300s)...
   Status: planning
   Status: planned

📊 Final Status: planned

Apply this run? (yes/no): yes
✅ Applying run: run-new123
```

---

## 🔧 Bash Examples

### 3. Variable Manager (`manage_variables.sh`)

**Purpose**: Demonstrates variable management operations

**Features**:
- List all variables in workspace
- Create new variables
- Update existing variables
- Delete variables
- Handle sensitive variables
- Support both Terraform and environment variables

**Usage**:
```bash
# Make executable
chmod +x manage_variables.sh

# Run
./manage_variables.sh <workspace-name>

# Example
./manage_variables.sh prod-infrastructure
```

**Example Output**:
```
========================================
HCP Terraform Variable Manager
========================================

📋 Getting workspace ID...
✅ Workspace ID: ws-abc123

📋 Listing existing variables...
   - region = us-west-2 (terraform)
   - instance_type = t3.small (terraform)

Setting example variables...

🔄 Updating variable: region
✅ Variable updated: region

🔨 Creating variable: db_password
✅ Variable created: db_password

Updated variables:
   - region = us-east-1 (terraform)
   - instance_type = t3.medium (terraform)
   - environment = development (terraform)
   - db_password = *** (terraform)
   - AWS_DEFAULT_REGION = us-east-1 (env)

========================================
✅ Variable management completed
========================================
```

---

## 🔐 Security Best Practices

### 1. Token Management

**✅ DO**:
- Store tokens in environment variables
- Use secret managers (AWS Secrets Manager, HashiCorp Vault)
- Rotate tokens regularly (every 90 days)
- Use team tokens for shared automation
- Revoke tokens when no longer needed

**❌ DON'T**:
- Hardcode tokens in scripts
- Commit tokens to version control
- Share tokens via email or chat
- Use organization tokens unless necessary

### 2. Error Handling

All examples include proper error handling:
- HTTP status code checking
- Timeout handling
- Retry logic for rate limiting
- Clear error messages

### 3. Rate Limiting

HCP Terraform API limits:
- 30 requests per second per organization
- Shared across all users and tokens

Examples implement:
- Exponential backoff for 429 responses
- Reasonable timeouts
- Efficient pagination

---

## 📚 API Reference

### Base URL
```
https://app.terraform.io/api/v2
```

### Authentication Header
```bash
Authorization: Bearer <YOUR_TOKEN>
Content-Type: application/vnd.api+json
```

### Common Endpoints

**Workspaces**:
- `GET /organizations/{org}/workspaces` - List workspaces
- `POST /organizations/{org}/workspaces` - Create workspace
- `GET /workspaces/{id}` - Get workspace
- `PATCH /workspaces/{id}` - Update workspace
- `DELETE /workspaces/{id}` - Delete workspace

**Runs**:
- `POST /runs` - Create run
- `GET /runs/{id}` - Get run status
- `POST /runs/{id}/actions/apply` - Apply run
- `POST /runs/{id}/actions/cancel` - Cancel run
- `GET /workspaces/{id}/runs` - List runs

**Variables**:
- `GET /workspaces/{id}/vars` - List variables
- `POST /workspaces/{id}/vars` - Create variable
- `PATCH /workspaces/{id}/vars/{var_id}` - Update variable
- `DELETE /workspaces/{id}/vars/{var_id}` - Delete variable

---

## 🧪 Testing

### Test with a Demo Workspace

1. Create a test workspace in HCP Terraform UI
2. Add some basic Terraform configuration
3. Run the examples against the test workspace
4. Verify operations in HCP Terraform UI

### Example Test Workflow

```bash
# 1. Set environment variables
export TFC_TOKEN="your-token"
export TFC_ORG="your-org"

# 2. Create a workspace
./workspace_manager.py

# 3. Set variables
./manage_variables.sh api-demo-workspace

# 4. Trigger a run
./run_manager.py
```

---

## 🔧 Customization

### Modify for Your Use Case

**1. Workspace Manager**:
- Add VCS connection configuration
- Implement workspace tagging
- Add notification configuration

**2. Run Manager**:
- Add plan output parsing
- Implement cost estimation checks
- Add Sentinel policy override logic

**3. Variable Manager**:
- Bulk import from CSV/JSON
- Variable validation
- Environment-specific variable sets

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: `401 Unauthorized`
- **Solution**: Check TFC_TOKEN is set correctly
- Verify token hasn't expired
- Ensure token has required permissions

**Issue**: `404 Not Found`
- **Solution**: Verify organization name is correct
- Check workspace name spelling
- Ensure resource exists

**Issue**: `422 Unprocessable Entity`
- **Solution**: Check request payload format
- Verify required fields are present
- Review validation error message

**Issue**: `429 Too Many Requests`
- **Solution**: Implement rate limiting
- Add delays between requests
- Use exponential backoff

### Debug Mode

**Python**:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

**Bash**:
```bash
set -x  # Enable debug mode
```

---

## 📖 Additional Resources

- [HCP Terraform API Documentation](https://developer.hashicorp.com/terraform/cloud-docs/api-docs)
- [JSON:API Specification](https://jsonapi.org/)
- [Terraform Associate Certification](https://www.hashicorp.com/certification/terraform-associate)

---

## 🤝 Contributing

To add new examples:
1. Follow existing code structure
2. Include comprehensive error handling
3. Add usage documentation
4. Test with real HCP Terraform account

---

**Version**: 1.0  
**Last Updated**: October 28, 2025  
**Author**: RouteCloud Training Team

