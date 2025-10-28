# Terraform Curriculum Enhancement Roadmap

**Document Purpose**: Detailed implementation guide for curriculum improvements  
**Priority Level**: Medium (Nice-to-have enhancements)  
**Estimated Total Effort**: 15-20 hours  
**Target Completion**: Q4 2025

---

## PHASE 1: SENTINEL POLICY ENHANCEMENT (Priority 1)

### Objective
Expand HCP Terraform Sentinel policy coverage to address Domain 9b gaps.

### Current State
- Topic 12 mentions Sentinel
- No hands-on examples
- Limited practice questions

### Enhancement Details

#### 1.1 Topic 12 Expansion
**Add Section**: "Sentinel Policy Language and Enforcement"

**Content to Add** (300-400 lines):
- Sentinel language basics
- Policy structure and syntax
- Common policy patterns
- Policy evaluation process
- Enforcement levels (advisory, soft-mandatory, hard-mandatory)

**Code Examples**:
```hcl
# Example: Enforce AWS region
import "tfplan/v2" as tfplan

allowed_regions = ["us-east-1", "us-west-2"]

main = rule {
  all tfplan.resource_changes.aws_instance as _, instances {
    all instances as _, instance {
      instance.change.after.availability_zone matches "^(us-east-1|us-west-2)"
    }
  }
}
```

#### 1.2 Lab Exercise
**Create**: Lab-12-Sentinel.md (400+ lines)

**Exercises**:
1. Write policy to enforce tagging
2. Create cost estimation policy
3. Implement compliance policy
4. Test policy evaluation

#### 1.3 Assessment Questions
**Add**: 10-15 Sentinel-specific questions to Topic 12 assessment

**Question Types**:
- Policy syntax validation
- Enforcement level selection
- Policy evaluation scenarios
- Troubleshooting policy failures

**Estimated Effort**: 4-6 hours

---

## PHASE 2: HCP TERRAFORM TEAM MANAGEMENT LAB (Priority 1)

### Objective
Add hands-on lab for HCP Terraform team and permission management.

### Enhancement Details

#### 2.1 New Lab: Lab-12-Team-Management.md
**Content** (500+ lines):

**Exercise 1**: Team Creation and Management
- Create organization
- Create teams
- Add team members
- Assign roles

**Exercise 2**: Permission Management
- Configure workspace permissions
- Set team permissions
- Implement RBAC
- Test permission enforcement

**Exercise 3**: Workspace Access Control
- Create workspaces
- Assign team access
- Configure run permissions
- Test access restrictions

**Exercise 4**: Audit and Compliance
- Review audit logs
- Track permission changes
- Implement governance policies
- Document access controls

#### 2.2 Practical Scenarios
**Scenario 1**: Multi-team Organization
- 3 teams (Platform, Application, Security)
- Different permission levels
- Workspace isolation
- Cross-team collaboration

**Scenario 2**: Compliance Requirements
- Enforce approval workflows
- Require policy checks
- Audit trail requirements
- Access logging

**Estimated Effort**: 3-4 hours

---

## PHASE 3: VCS INTEGRATION ENHANCEMENT (Priority 2)

### Objective
Expand VCS integration coverage for Domain 9a.

### Enhancement Details

#### 3.1 Topic 12 VCS Section
**Add Section**: "VCS Integration and Workflows"

**Content** (200-300 lines):
- GitHub/GitLab integration setup
- Webhook configuration
- Branch protection rules
- VCS-triggered runs
- Pull request workflows
- Merge strategies

#### 3.2 Lab Exercise
**Create**: Lab-12-VCS-Integration.md (400+ lines)

**Exercises**:
1. GitHub repository setup
2. HCP Terraform VCS connection
3. Webhook configuration
4. Branch protection rules
5. PR workflow testing

**Practical Scenarios**:
- Feature branch workflow
- Release branch workflow
- Hotfix workflow
- Approval requirements

**Estimated Effort**: 2-3 hours

---

## PHASE 4: PROJECT 3 ENHANCEMENT (Priority 2)

### Objective
Enhance Project 3 with VCS-triggered workflows.

### Current State
- Project 3 has CI/CD pipeline
- Uses GitHub Actions
- No VCS-specific workflows

### Enhancement Details

#### 4.1 Add VCS Workflow
**New File**: `Project-3-VCS-Workflow.md`

**Content**:
- VCS connection setup
- Branch strategy
- PR workflow
- Approval process
- Merge and deploy

#### 4.2 Update Terraform Code
**Modifications**:
- Add HCP Terraform cloud block
- Configure VCS settings
- Add branch protection
- Implement approval workflow

#### 4.3 Documentation
**Add**: VCS workflow diagrams and examples

**Estimated Effort**: 2-3 hours

---

## PHASE 5: ADVANCED SENTINEL PATTERNS (Priority 3)

### Objective
Add advanced Sentinel policy examples for real-world scenarios.

### Enhancement Details

#### 5.1 Cost Estimation Policies
**Example Policies**:
- Enforce instance size limits
- Restrict expensive resources
- Implement cost budgets
- Alert on cost overruns

#### 5.2 Compliance Policies
**Example Policies**:
- Enforce encryption
- Require tagging
- Enforce network isolation
- Implement security groups

#### 5.3 Resource Tagging Policies
**Example Policies**:
- Enforce required tags
- Validate tag values
- Implement tag naming conventions
- Audit tag compliance

**Estimated Effort**: 3-4 hours

---

## PHASE 6: HCP TERRAFORM API EXAMPLES (Priority 3)

### Objective
Add API-based management examples.

### Enhancement Details

#### 6.1 API Authentication
**Content**:
- API token generation
- Token management
- Security best practices
- Token rotation

#### 6.2 Workspace Management via API
**Examples**:
- Create workspaces
- Update workspace settings
- Delete workspaces
- List workspaces

#### 6.3 Run Management via API
**Examples**:
- Trigger runs
- Monitor run status
- Cancel runs
- Retrieve run logs

**Estimated Effort**: 2-3 hours

---

## IMPLEMENTATION TIMELINE

### Week 1-2: Phase 1 (Sentinel Enhancement)
- Add Sentinel section to Topic 12
- Create Sentinel lab
- Add assessment questions
- **Effort**: 4-6 hours

### Week 2-3: Phase 2 (Team Management Lab)
- Create team management lab
- Develop practical scenarios
- Add assessment questions
- **Effort**: 3-4 hours

### Week 3-4: Phase 3 & 4 (VCS Integration)
- Add VCS section to Topic 12
- Create VCS lab
- Enhance Project 3
- **Effort**: 4-6 hours

### Week 4-5: Phase 5 & 6 (Advanced Topics)
- Add advanced Sentinel patterns
- Add API examples
- Create additional labs
- **Effort**: 5-7 hours

---

## RESOURCE REQUIREMENTS

### Knowledge Requirements
- Advanced Sentinel policy experience
- HCP Terraform API expertise
- VCS integration experience
- AWS best practices

### Tools Required
- HCP Terraform account
- GitHub/GitLab account
- Terraform CLI
- Python (for diagram generation)

### Time Estimate
- **Total Effort**: 15-20 hours
- **Phases 1-2**: 7-10 hours (High Priority)
- **Phases 3-4**: 4-6 hours (Medium Priority)
- **Phases 5-6**: 5-7 hours (Nice-to-have)

---

## SUCCESS CRITERIA

### Phase 1 Success
- ✅ Sentinel section added to Topic 12
- ✅ Lab exercise created and tested
- ✅ 10+ practice questions added
- ✅ Example policies documented

### Phase 2 Success
- ✅ Team management lab created
- ✅ Practical scenarios documented
- ✅ Permission examples working
- ✅ Assessment questions added

### Phase 3-4 Success
- ✅ VCS section added
- ✅ Lab exercise created
- ✅ Project 3 enhanced
- ✅ Workflow diagrams created

### Phase 5-6 Success
- ✅ Advanced patterns documented
- ✅ API examples working
- ✅ Code samples provided
- ✅ Best practices documented

---

## RISK MITIGATION

### Risk 1: Sentinel Complexity
**Mitigation**: Start with simple policies, progress to complex

### Risk 2: API Changes
**Mitigation**: Use official HCP Terraform API documentation

### Risk 3: VCS Integration Variations
**Mitigation**: Focus on GitHub (most common), mention GitLab

### Risk 4: Time Constraints
**Mitigation**: Prioritize Phases 1-2, defer Phases 5-6 if needed

---

## NEXT STEPS

1. **Review** this roadmap with team
2. **Prioritize** phases based on student feedback
3. **Assign** resources to each phase
4. **Schedule** implementation timeline
5. **Track** progress and adjust as needed
6. **Test** all new content before deployment
7. **Gather** student feedback post-implementation

---

**Document Status**: Ready for Implementation  
**Last Updated**: October 28, 2025  
**Next Review**: After Phase 2 completion

