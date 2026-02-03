# Specification Template

This template defines the structure for all feature specifications.
**SOLID compliance is ALWAYS included as a mandatory spec.**

---

## Template: 12_specs.md

```markdown
# Specifications: ${FEATURE_ID}

**Created**: ${DATE}
**Status**: DRAFT | VALIDATED | APPROVED

---

## Section A: Functional Specifications

These specs are unique to this feature.

### SPEC-F01: [Requirement Name]

**Description**: [What the system must do]

**Acceptance Criteria**:
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
- [ ] [Testable criterion 3]

**Verification Method**: [How to verify - test command, manual check, etc.]

**Priority**: Critical | High | Medium | Low

---

### SPEC-F02: [Requirement Name]

**Description**: [What the system must do]

**Acceptance Criteria**:
- [ ] [Testable criterion]

**Verification Method**: [How to verify]

**Priority**: Critical | High | Medium | Low

---

## Section B: MANDATORY SPEC - SOLID Compliance

> ⚠️ **THIS SECTION IS REQUIRED FOR ALL FEATURES**
>
> All code created/modified MUST comply with SOLID principles.
> This is NON-NEGOTIABLE regardless of feature type.

### SPEC-SOLID: Code Quality via SOLID Principles

**Description**: All proposed and created code MUST comply with SOLID principles
using appropriate design patterns and best practices.

**Acceptance Criteria**:

#### S - Single Responsibility Principle
- [ ] Each class has ONE and only ONE reason to change
- [ ] Class can be described in one phrase without "and"
- [ ] Class has ≤200 lines of code
- [ ] Class has ≤7 public methods
- [ ] No "God classes" or "Manager" classes

#### O - Open/Closed Principle
- [ ] Classes are open for extension, closed for modification
- [ ] No switch/if-else chains based on type
- [ ] New behaviors can be added without modifying existing code
- [ ] Uses Strategy, Decorator, or similar patterns where needed

#### L - Liskov Substitution Principle
- [ ] Subtypes can replace parent types without breaking behavior
- [ ] No exceptions thrown that parent doesn't declare
- [ ] Preconditions not strengthened in subtypes
- [ ] Postconditions not weakened in subtypes

#### I - Interface Segregation Principle
- [ ] Interfaces have ≤5 methods
- [ ] No "fat" interfaces forcing unused implementations
- [ ] Interfaces are role-specific
- [ ] Clients only depend on methods they use

#### D - Dependency Inversion Principle
- [ ] High-level modules depend on abstractions
- [ ] Domain layer has ZERO infrastructure imports
- [ ] All dependencies are injected, not instantiated
- [ ] Concrete classes depend on interfaces

**Minimum Score**:
- 18/25 to proceed to implementation
- 22/25 to approve for merge

**Verification Method**:
```bash
/workflow-skill:solid-analyzer --path=src/affected-path --validate
```

**Required Patterns** (select applicable):

| Need | Pattern | Addresses |
|------|---------|-----------|
| Multiple behaviors/strategies | Strategy | OCP, SRP |
| Adding functionality dynamically | Decorator | OCP, SRP |
| Creating objects without specifying class | Factory Method | DIP, OCP |
| Integrating with external systems | Adapter / Ports & Adapters | DIP, OCP |
| Abstracting data persistence | Repository | SRP, DIP |
| Processing in sequence | Chain of Responsibility | SRP, OCP |
| Complex object construction | Builder | SRP |
| Single instance guarantee | Singleton (use sparingly) | - |

**Priority**: Critical (MANDATORY)

---

## Section C: Quality Specifications (Optional but Recommended)

### SPEC-Q01: Testability

**Description**: Code must be testable with high coverage

**Acceptance Criteria**:
- [ ] Unit test coverage ≥80%
- [ ] All public methods have tests
- [ ] Edge cases are tested
- [ ] Dependencies are mockable

**Verification Method**: `./vendor/bin/phpunit --coverage`

---

### SPEC-Q02: Performance (if applicable)

**Description**: Code must meet performance requirements

**Acceptance Criteria**:
- [ ] Response time < [X]ms for [operation]
- [ ] Memory usage < [X]MB
- [ ] No N+1 queries

**Verification Method**: Performance tests / profiling

---

## Specification Summary

| ID | Name | Type | Priority | Status |
|----|------|------|----------|--------|
| SPEC-F01 | [Name] | Functional | [Priority] | [ ] |
| SPEC-F02 | [Name] | Functional | [Priority] | [ ] |
| **SPEC-SOLID** | **SOLID Compliance** | **Mandatory** | **Critical** | [ ] |
| SPEC-Q01 | Testability | Quality | High | [ ] |

---

## Approval

- [ ] Product Owner approved functional specs
- [ ] Tech Lead approved SOLID compliance approach
- [ ] Patterns for SOLID selected and documented
- [ ] Ready for solution design (Phase 3)

**Approved By**: _______________
**Date**: _______________
```

---

## Usage

When running `/workflow-skill:criteria-generator --feature=${FEATURE_ID}`, this template
is used to generate the `12_specs.md` file.

The SOLID section is **automatically included** and cannot be removed.

## Integration with Plan

The Plan (Phase 3) must provide solutions for EVERY spec in this document:

```
12_specs.md (this file)     →    15_solutions.md
├── SPEC-F01                →    Solution for F01
├── SPEC-F02                →    Solution for F02
└── SPEC-SOLID (mandatory)  →    Solution with patterns
```

## Related

- `/workflows:plan` - Uses this template in Phase 2
- `/workflow-skill:criteria-generator` - Generates specs from this template
- `core/solid-pattern-matrix.md` - Pattern recommendations for SOLID
