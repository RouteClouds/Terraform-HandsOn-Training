#!/bin/bash
# manage_variables.sh - Manage HCP Terraform variables via API
# Usage: ./manage_variables.sh <workspace-name>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TFC_TOKEN="${TFC_TOKEN}"
TFC_ORG="${TFC_ORG:-my-organization}"
BASE_URL="https://app.terraform.io/api/v2"

# Check if token is set
if [ -z "$TFC_TOKEN" ]; then
    echo -e "${RED}❌ Error: TFC_TOKEN environment variable not set${NC}"
    echo "   Export your HCP Terraform token: export TFC_TOKEN='your-token'"
    exit 1
fi

# Check if workspace name provided
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Workspace name required${NC}"
    echo "   Usage: $0 <workspace-name>"
    exit 1
fi

WORKSPACE_NAME="$1"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HCP Terraform Variable Manager${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get workspace ID
echo -e "${YELLOW}📋 Getting workspace ID...${NC}"
WORKSPACE_ID=$(curl -s \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "$BASE_URL/organizations/$TFC_ORG/workspaces/$WORKSPACE_NAME" \
    | jq -r '.data.id')

if [ "$WORKSPACE_ID" == "null" ] || [ -z "$WORKSPACE_ID" ]; then
    echo -e "${RED}❌ Workspace not found: $WORKSPACE_NAME${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Workspace ID: $WORKSPACE_ID${NC}"
echo ""

# List existing variables
list_variables() {
    echo -e "${YELLOW}📋 Listing existing variables...${NC}"
    
    VARS=$(curl -s \
        --header "Authorization: Bearer $TFC_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        "$BASE_URL/workspaces/$WORKSPACE_ID/vars")
    
    echo "$VARS" | jq -r '.data[] | "   - \(.attributes.key) = \(if .attributes.sensitive then \"***\" else .attributes.value end) (\(.attributes.category))"'
    echo ""
}

# Create or update variable
set_variable() {
    local key="$1"
    local value="$2"
    local sensitive="${3:-false}"
    local category="${4:-terraform}"
    local description="${5:-}"
    
    # Check if variable exists
    existing_var=$(curl -s \
        --header "Authorization: Bearer $TFC_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        "$BASE_URL/workspaces/$WORKSPACE_ID/vars" \
        | jq -r ".data[] | select(.attributes.key == \"$key\") | .id")
    
    if [ -n "$existing_var" ] && [ "$existing_var" != "null" ]; then
        # Update existing variable
        echo -e "${YELLOW}🔄 Updating variable: $key${NC}"
        
        response=$(curl -s -w "\n%{http_code}" \
            --header "Authorization: Bearer $TFC_TOKEN" \
            --header "Content-Type: application/vnd.api+json" \
            --request PATCH \
            --data @- \
            "$BASE_URL/workspaces/$WORKSPACE_ID/vars/$existing_var" <<EOF
{
  "data": {
    "type": "vars",
    "attributes": {
      "value": "$value",
      "sensitive": $sensitive,
      "description": "$description"
    }
  }
}
EOF
)
        
        http_code=$(echo "$response" | tail -n1)
        if [ "$http_code" == "200" ]; then
            echo -e "${GREEN}✅ Variable updated: $key${NC}"
        else
            echo -e "${RED}❌ Error updating variable: $key (HTTP $http_code)${NC}"
        fi
    else
        # Create new variable
        echo -e "${YELLOW}🔨 Creating variable: $key${NC}"
        
        response=$(curl -s -w "\n%{http_code}" \
            --header "Authorization: Bearer $TFC_TOKEN" \
            --header "Content-Type: application/vnd.api+json" \
            --request POST \
            --data @- \
            "$BASE_URL/workspaces/$WORKSPACE_ID/vars" <<EOF
{
  "data": {
    "type": "vars",
    "attributes": {
      "key": "$key",
      "value": "$value",
      "category": "$category",
      "sensitive": $sensitive,
      "description": "$description"
    }
  }
}
EOF
)
        
        http_code=$(echo "$response" | tail -n1)
        if [ "$http_code" == "201" ]; then
            echo -e "${GREEN}✅ Variable created: $key${NC}"
        else
            echo -e "${RED}❌ Error creating variable: $key (HTTP $http_code)${NC}"
        fi
    fi
}

# Delete variable
delete_variable() {
    local key="$1"
    
    # Get variable ID
    var_id=$(curl -s \
        --header "Authorization: Bearer $TFC_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        "$BASE_URL/workspaces/$WORKSPACE_ID/vars" \
        | jq -r ".data[] | select(.attributes.key == \"$key\") | .id")
    
    if [ -z "$var_id" ] || [ "$var_id" == "null" ]; then
        echo -e "${RED}❌ Variable not found: $key${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}🗑️  Deleting variable: $key${NC}"
    
    http_code=$(curl -s -w "%{http_code}" -o /dev/null \
        --header "Authorization: Bearer $TFC_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        --request DELETE \
        "$BASE_URL/workspaces/$WORKSPACE_ID/vars/$var_id")
    
    if [ "$http_code" == "204" ]; then
        echo -e "${GREEN}✅ Variable deleted: $key${NC}"
    else
        echo -e "${RED}❌ Error deleting variable: $key (HTTP $http_code)${NC}"
    fi
}

# Main execution
list_variables

# Set some example variables
echo -e "${BLUE}Setting example variables...${NC}"
echo ""

set_variable "region" "us-east-1" "false" "terraform" "AWS region"
set_variable "instance_type" "t3.medium" "false" "terraform" "EC2 instance type"
set_variable "environment" "development" "false" "terraform" "Environment name"
set_variable "db_password" "super-secret-password" "true" "terraform" "Database password"

# Set environment variables
set_variable "AWS_DEFAULT_REGION" "us-east-1" "false" "env" "AWS region for provider"

echo ""
echo -e "${BLUE}Updated variables:${NC}"
list_variables

# Uncomment to delete a variable
# delete_variable "example_var"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Variable management completed${NC}"
echo -e "${BLUE}========================================${NC}"

