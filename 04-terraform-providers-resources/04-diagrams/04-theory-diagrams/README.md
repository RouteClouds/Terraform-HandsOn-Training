# Terraform Providers and Resources - Theory Diagrams

This directory contains Diagrams as Code (DaC) for visualizing the theoretical concepts of Terraform Providers and Resources.

## Diagram Types

### 1. Provider Types Diagram
- Illustrates different types of providers
- Shows relationship between Terraform core and providers
- Demonstrates provider hierarchy

### 2. Provider Features Diagram
- Shows authentication methods
- Illustrates provider configuration options
- Demonstrates feature relationships

### 3. Resource Dependencies Diagram
- Visualizes implicit and explicit dependencies
- Shows resource relationships
- Demonstrates dependency flow

### 4. Resource Lifecycle Diagram
- Shows lifecycle events
- Illustrates lifecycle rules
- Demonstrates event flow

### 5. Meta-Arguments Diagram
- Shows count usage
- Illustrates for_each implementation
- Demonstrates lifecycle configurations

## Generated Files
The script generates the following diagrams:
- provider_types.png
- provider_features.png
- resource_dependencies.png
- resource_lifecycle.png
- meta_arguments.png

## Usage
```bash
# Generate all diagrams
python terraform_providers_resources_concepts.py
```

## Diagram Relationships
1. Provider Types → Provider Features
2. Provider Features → Resource Dependencies
3. Resource Dependencies → Resource Lifecycle
4. Resource Lifecycle → Meta-Arguments

## Best Practices
- Keep diagrams focused and clear
- Use consistent color coding
- Maintain logical grouping
- Show clear relationships
- Include relevant labels 