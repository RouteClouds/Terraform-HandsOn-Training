# Terraform Provider Labs - Diagrams

This directory contains Diagrams as Code (DaC) for visualizing the lab exercises in the Terraform Providers and Resources module.

## Lab Diagrams

### Lab 1: Provider Configuration and Authentication
- **Authentication Flow**
  - Static credentials (development only)
  - Environment variables (recommended)
  - Shared credentials file (AWS standard)
  - IAM roles (production recommended)
- **Provider Setup**
  - Version constraints
  - Regional configuration
  - Alias definitions
- **Configuration Management**
  - Credential handling
  - Provider initialization
  - Version control

### Lab 2: Resource Creation and Attributes
- **Storage Resources**
  - S3 bucket configuration
  - Versioning setup
  - Access management
- **Security Components**
  - IAM role creation
  - Policy attachments
  - Permission management
- **Network Elements**
  - Security group rules
  - Inbound/outbound traffic
  - VPC association

### Lab 3: Resource Dependencies
- **VPC Architecture**
  - Public and private subnets
  - Internet and NAT gateways
  - Route table associations
- **Dependency Types**
  - Implicit dependencies (blue arrows)
  - Explicit dependencies (red arrows)
  - Cross-component relationships (green/orange arrows)
- **Network Flow**
  - Internet access path
  - Internal routing
  - NAT routing

### Lab 4: Meta-Arguments and Lifecycle
- **Count Implementation**
  - Multiple instance creation
  - Index-based references
  - Resource scaling
- **For_Each Patterns**
  - Environment-based deployment
  - Map-based creation
  - Dynamic resource generation
- **Lifecycle Rules**
  - Creation/destruction order
  - Update behavior
  - Change management

### Lab 5: Multiple Provider Configurations
- **Regional Setup**
  - Primary region configuration
  - Secondary region setup
  - Cross-region connectivity
- **Resource Distribution**
  - Regional VPC deployment
  - Compute resource placement
  - Storage configuration
- **Inter-Region Communication**
  - VPC peering
  - Cross-region references
  - Resource synchronization

## Generated Files
The script generates the following diagrams:
```plaintext
generated/
├── lab1_provider_config.png      # Authentication and provider setup
├── lab2_resource_creation.png    # AWS resource creation flow
├── lab3_dependencies.png         # Infrastructure dependencies
├── lab4_meta_arguments.png       # Resource patterns and lifecycle
├── lab5_multi_provider.png       # Multi-region architecture
└── labs_overview.png            # Complete lab progression
```

## Usage
```bash
# Generate all diagrams
python terraform_providers_resources_labs.py

# Generate specific diagram
python terraform_providers_resources_labs.py --lab=1

# View generated diagrams
open generated/lab1_provider_config.png
```

## Diagram Features
1. Clear clustering of related components
   - Logical grouping of resources
   - Hierarchical structure
   - Component relationships

2. Consistent color coding
   - Blue: Implicit dependencies
   - Red: Explicit dependencies
   - Green: Network flow
   - Orange: NAT routing

3. Explicit relationship arrows
   - Solid lines: Direct dependencies
   - Dashed lines: Optional connections
   - Labeled arrows: Relationship type

4. Proper resource grouping
   - Functional clusters
   - Service categories
   - Regional separation

5. Informative labels
   - Resource names
   - Relationship types
   - Configuration details

## Best Practices
1. Diagram Organization
   - Maintain consistent layout
   - Use appropriate spacing
   - Follow logical flow

2. Visual Elements
   - Apply consistent styling
   - Use meaningful colors
   - Keep diagrams readable

3. Relationship Representation
   - Show critical connections
   - Avoid cluttered arrows
   - Label important relationships

4. Component Grouping
   - Group related resources
   - Use meaningful clusters
   - Maintain hierarchy

5. Documentation
   - Include diagram legends
   - Document color coding
   - Explain relationships

## Troubleshooting
1. Diagram Generation Issues
   - Check Python environment
   - Verify Graphviz installation
   - Confirm file permissions

2. Visualization Problems
   - Adjust graph attributes
   - Modify node spacing
   - Update cluster layout

## Additional Resources
- [Diagrams Documentation](https://diagrams.mingrammer.com/)
- [Graphviz Documentation](https://graphviz.org/documentation/)
- [AWS Architecture Icons](https://aws.amazon.com/architecture/icons/)