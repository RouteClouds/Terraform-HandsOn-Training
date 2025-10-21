# Topic 9: Test Your Understanding - Terraform Import & State Manipulation

**Total Questions**: 15  
**Time Limit**: 30 minutes  
**Passing Score**: 70% (11/15 correct)

---

## Multiple Choice Questions (10 questions)

### Question 1
What is the primary purpose of the `terraform import` command?

A) To export Terraform configuration to JSON  
B) To bring existing infrastructure resources into Terraform state  
C) To import modules from the Terraform Registry  
D) To import variables from external files  

**Answer**: B  
**Explanation**: `terraform import` allows you to bring existing AWS resources into Terraform management without recreating them.

---

### Question 2
What is the correct syntax for importing an EC2 instance?

A) `terraform import i-1234567890abcdef0 aws_instance.web`  
B) `terraform import aws_instance.web i-1234567890abcdef0`  
C) `terraform import aws_instance i-1234567890abcdef0`  
D) `terraform import -resource aws_instance.web i-1234567890abcdef0`  

**Answer**: B  
**Explanation**: The correct syntax is `terraform import ADDRESS ID` where ADDRESS is the resource address in configuration.

---

### Question 3
After importing a resource, what should you do to verify the import was successful?

A) Run `terraform destroy`  
B) Run `terraform apply`  
C) Run `terraform plan` to verify no changes  
D) Run `terraform validate`  

**Answer**: C  
**Explanation**: After import, `terraform plan` should show no changes, indicating the configuration matches the imported resource.

---

### Question 4
Which command removes a resource from Terraform state WITHOUT destroying it in AWS?

A) `terraform destroy -target=aws_instance.web`  
B) `terraform state rm aws_instance.web`  
C) `terraform state remove aws_instance.web`  
D) `terraform remove aws_instance.web`  

**Answer**: B  
**Explanation**: `terraform state rm` removes a resource from state while leaving it in AWS.

---

### Question 5
What does `terraform state mv` command do?

A) Moves resources between AWS regions  
B) Moves resources in Terraform state (rename or reorganize)  
C) Moves resources to a different AWS account  
D) Moves resources to a different provider  

**Answer**: B  
**Explanation**: `terraform state mv` allows renaming resources or moving them between modules in state.

---

### Question 6
Which flag allows you to target a specific resource during terraform operations?

A) `-resource`  
B) `-target`  
C) `-select`  
D) `-filter`  

**Answer**: B  
**Explanation**: The `-target` flag allows operations on specific resources: `terraform plan -target=aws_instance.web`

---

### Question 7
What is the primary benefit of using `terraform state replace-provider`?

A) To change AWS regions  
B) To change the provider version  
C) To change the provider source (e.g., from one registry to another)  
D) To replace provider credentials  

**Answer**: C  
**Explanation**: This command changes the provider source for resources in state.

---

### Question 8
Before importing resources, what should you do?

A) Delete existing Terraform configuration  
B) Write Terraform configuration matching the resources  
C) Destroy all existing resources  
D) Export AWS resources to JSON  

**Answer**: B  
**Explanation**: You must write Terraform configuration with matching resource addresses before importing.

---

### Question 9
What happens if you run `terraform import` for a resource that already exists in state?

A) It updates the existing state entry  
B) It creates a duplicate entry  
C) It returns an error  
D) It deletes the old entry  

**Answer**: C  
**Explanation**: Terraform will return an error if the resource already exists in state.

---

### Question 10
Which file contains the backup of your Terraform state?

A) `terraform.tfstate.old`  
B) `terraform.tfstate.backup`  
C) `terraform.backup`  
D) `.terraform/backup`  

**Answer**: B  
**Explanation**: Terraform automatically creates `terraform.tfstate.backup` as a backup of the previous state.

---

## Scenario-Based Questions (3 questions)

### Scenario 1
You have an existing EC2 instance running in AWS (ID: i-0123456789abcdef0) that was created manually. You want to manage it with Terraform. What are the steps?

**Answer**:
1. Write Terraform configuration with `resource "aws_instance" "web" { ... }`
2. Run `terraform init`
3. Run `terraform import aws_instance.web i-0123456789abcdef0`
4. Run `terraform state show aws_instance.web` to verify
5. Update configuration with actual resource attributes
6. Run `terraform plan` to verify no changes

---

### Scenario 2
You need to move a resource from one Terraform workspace to another. How would you do this?

**Answer**:
1. In source workspace: `terraform state list` to identify resource
2. Use `terraform state mv` to move the resource
3. Switch to destination workspace: `terraform workspace select destination`
4. Verify resource exists: `terraform state list`
5. Run `terraform plan` to verify no changes

---

### Scenario 3
Your state file became corrupted and you can't run Terraform commands. How would you recover?

**Answer**:
1. Check for backup: `terraform.tfstate.backup`
2. Restore backup: `cp terraform.tfstate.backup terraform.tfstate`
3. Verify recovery: `terraform state list`
4. Run `terraform refresh` to sync with AWS
5. Run `terraform plan` to verify state is current

---

## Hands-On Exercises (2 exercises)

### Exercise 1: Import and Verify
Create an EC2 instance manually in AWS, then:
1. Write Terraform configuration
2. Import the instance using `terraform import`
3. Verify with `terraform plan` showing no changes
4. Document the process

### Exercise 2: State Manipulation
Using the imported instance from Exercise 1:
1. Rename the resource using `terraform state mv`
2. Verify the rename with `terraform state list`
3. Update configuration to match new name
4. Run `terraform plan` to verify no changes

---

## Answer Key Summary

**Multiple Choice**: Questions 1-10  
- Q1: B, Q2: B, Q3: C, Q4: B, Q5: B  
- Q6: B, Q7: C, Q8: B, Q9: C, Q10: B  

**Scenario Questions**: 1-3  
- See detailed answers above  

**Hands-On Exercises**: 1-2  
- Complete exercises and document results  

---

## Scoring Guide

- **14-15 correct**: Excellent - Ready for certification exam
- **12-13 correct**: Good - Review weak areas
- **11 correct**: Passing - Study additional resources
- **Below 11**: Review Topic 9 content and retake

---

## Additional Resources

- [Terraform Import Documentation](https://www.terraform.io/docs/commands/import.html)
- [Terraform State Management](https://www.terraform.io/docs/state/)
- [AWS Resource IDs](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html)

---

**Assessment Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Testing

