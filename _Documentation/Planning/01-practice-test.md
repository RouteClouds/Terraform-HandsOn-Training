# Introduction to Infrastructure Automation - Practice Questions

## Section 1: Multiple Choice Questions

1. What is Infrastructure as Code (IaC)?
   - [ ] A programming language for system administrators
   - [ ] A method of manually configuring servers
   - [x] A practice of managing infrastructure through machine-readable definition files
   - [ ] A cloud service provider feature

   **Explanation:** Infrastructure as Code is the practice of managing and provisioning infrastructure through code and automation rather than manual processes.

2. Which of the following is a key benefit of Infrastructure as Code?
   - [ ] Increased manual intervention required
   - [x] Consistent environment creation
   - [ ] Higher deployment costs
   - [ ] Reduced version control capabilities

   **Explanation:** IaC ensures consistency by using the same code to create environments, eliminating manual configuration variations.

3. In the context of IaC, what is a "declarative" approach?
   - [ ] Writing step-by-step instructions
   - [x] Specifying the desired end state
   - [ ] Using only command-line tools
   - [ ] Manual configuration of resources

   **Explanation:** Declarative approach focuses on describing the desired end state, letting the tool determine how to achieve it.

4. Which statement about Terraform is FALSE?
   - [ ] It uses HCL (HashiCorp Configuration Language)
   - [ ] It supports multiple cloud providers
   - [x] It requires manual state management
   - [ ] It follows a declarative approach

   **Explanation:** Terraform includes built-in state management capabilities; it's not purely manual.

5. What is the primary purpose of version control in IaC?
   - [ ] To make deployments slower
   - [ ] To increase infrastructure costs
   - [x] To track changes and maintain history
   - [ ] To manually configure servers

   **Explanation:** Version control helps track changes, maintain history, and collaborate effectively on infrastructure code.

## Section 2: Hands-on Exercises

### Exercise 1: Basic IaC Setup
**Task:** Create a basic infrastructure project structure with the following requirements:
- Proper directory organization
- Version control setup
- Basic documentation
- .gitignore configuration

**Solution Outline:**
```bash
# Directory structure
mkdir iac-project
cd iac-project
git init
touch README.md
mkdir terraform docs tests
```

### Exercise 2: Documentation Practice
**Task:** Create comprehensive documentation for a simple infrastructure setup including:
- Project overview
- Prerequisites
- Setup instructions
- Maintenance guidelines

**Validation Criteria:**
- Clear structure
- Complete prerequisites
- Step-by-step instructions
- Troubleshooting section

## Section 3: Scenario-Based Questions

1. **Enterprise Migration Scenario**
   You are tasked with migrating a traditional infrastructure to IaC. Describe your approach considering:
   - Initial assessment
   - Risk mitigation
   - Implementation strategy
   - Validation process

   **Expected Answer Points:**
   - Conduct infrastructure audit
   - Create phased migration plan
   - Implement version control
   - Set up automated testing
   - Establish validation procedures

2. **Collaboration Challenge**
   Your team is experiencing conflicts in infrastructure changes. How would you:
   - Set up workflow
   - Establish best practices
   - Implement review process
   - Ensure code quality

   **Expected Answer Points:**
   - Implement branching strategy
   - Create pull request process
   - Set up automated testing
   - Establish code review guidelines

## Section 4: True/False Questions

1. Infrastructure as Code eliminates the need for documentation.
   - [ ] True
   - [x] False
   
   **Explanation:** IaC requires proper documentation for maintenance, onboarding, and best practices.

2. Version control is optional in Infrastructure as Code.
   - [ ] True
   - [x] False
   
   **Explanation:** Version control is essential for tracking changes, collaboration, and maintaining infrastructure history.

## Section 5: Fill in the Blanks

1. ________ is a key principle of IaC that ensures environments are created consistently.
   **Answer:** Idempotency

2. The ________ approach to IaC specifies what the final state should be rather than how to achieve it.
   **Answer:** Declarative

## Additional Practice Resources
- Review the lab exercises
- Examine the example diagrams in `iac-diagrams/`
- Practice with the provided manifest files in `iac-manifests/`
