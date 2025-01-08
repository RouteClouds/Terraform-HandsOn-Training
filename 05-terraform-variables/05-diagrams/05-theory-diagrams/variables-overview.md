# Terraform Variables and Outputs - Diagrams

## 1. Variable Types and Flow
```mermaid
graph TB
    subgraph "Variable Types"
        A[Input Variables] --> B[String]
        A --> C[Number]
        A --> D[List]
        A --> E[Map]
        A --> F[Bool]
        G[Local Variables] --> H[Computed Values]
        G --> I[Combined Values]
    end

    subgraph "Variable Sources"
        J[terraform.tfvars]
        K[*.auto.tfvars]
        L[Environment Variables]
        M[Command Line]
    end

    subgraph "Terraform Configuration"
        N[Resource Configuration]
        O[Output Values]
    end

    J --> N
    K --> N
    L --> N
    M --> N
    A --> N
    G --> N
    N --> O
```

## 2. Variable Precedence
```mermaid
graph TD
    A[Variable Definition] --> B[Environment Variables]
    B --> C[terraform.tfvars]
    C --> D[*.auto.tfvars]
    D --> E[Command Line -var or -var-file]
    
    style A fill:#f9f,stroke:#333
    style E fill:#9f9,stroke:#333
```

## 3. Variable Validation Flow
```mermaid
flowchart LR
    A[Variable Input] --> B{Validation Rules}
    B -->|Pass| C[Use Variable]
    B -->|Fail| D[Error Message]
    
    style B fill:#ff9,stroke:#333
    style D fill:#f99,stroke:#333
```

## 4. Output Structure
```mermaid
graph LR
    subgraph "Resource"
        A[AWS Instance]
    end
    
    subgraph "Output Values"
        B[Basic Output]
        C[Complex Output]
    end
    
    A -->|instance_id| B
    A -->|all attributes| C
```

## 5. Variable Organization
```mermaid
mindmap
    root((Variables))
        Network
            VPC CIDR
            Subnets
            Routes
        Compute
            Instance Type
            AMI ID
            Count
        Tags
            Environment
            Project
            Owner
        Security
            Passwords
            Keys
            Certificates
```

## 6. Dynamic Blocks Pattern
```mermaid
graph TB
    A[Variable: ingress_rules] --> B{Dynamic Block}
    B --> C[Rule 1]
    B --> D[Rule 2]
    B --> E[Rule n]
    
    C --> F[Security Group]
    D --> F
    E --> F
```

## 7. Variable Usage Flow
```mermaid
sequenceDiagram
    participant U as User
    participant T as Terraform
    participant P as Provider
    participant R as Resources

    U->>T: Define Variables
    T->>T: Validate Variables
    T->>P: Configure Provider
    T->>R: Apply Configuration
    R->>T: Return Outputs
    T->>U: Display Outputs
``` 