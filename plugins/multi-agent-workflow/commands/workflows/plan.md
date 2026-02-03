---
name: workflows:plan
description: "Convert ideas into implementable strategies with detailed planning. The foundation of compound engineering (80% planning, 20% execution)."
argument_hint: <feature-name> [--workflow=default|task-breakdown]
---

# Multi-Agent Workflow: Plan

The planning phase is the foundation of compound engineering. Invest 80% of effort here.

## Usage

```
/workflows:plan user-authentication
/workflows:plan payment-system --workflow=task-breakdown
```

## Philosophy

> "Each unit of engineering work should make subsequent units easier—not harder"

> "El código de alta calidad cumple SOLID de forma rigurosa"

Good planning means:
- Engineers can start WITHOUT asking questions
- **Solutions are designed with SOLID compliance from the start**
- API contracts are complete enough to mock
- Every task has clear "definition of done"

---

## The 3-Phase Planning Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 1: UNDERSTAND                          │
│  Analyze request → Ask clarifying questions → Document problem  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 2: SPECS                               │
│  Define acceptance criteria:                                    │
│  ├── Task-specific specs (functional requirements)              │
│  └── **MANDATORY SPEC: SOLID Compliance** (always required)     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 3: PLAN WITH SOLUTIONS                 │
│  For each spec, propose solution:                               │
│  ├── Functional solutions (how to implement each requirement)   │
│  └── SOLID solutions (patterns + practices to ensure quality)   │
└─────────────────────────────────────────────────────────────────┘
```

---

## PHASE 1: UNDERSTAND (Entender el Problema)

### Step 1.1: Analyze the Request

```markdown
## Request Analysis

**Original Request**: [user's exact words]
**Request Type**: [feature | refactor | bugfix | architecture | investigation]
**Affected Areas**: [modules/services involved]
**Confidence Level**: [0-100%]
```

### Step 1.2: Ask Clarifying Questions (if confidence < 60%)

Before proceeding, ensure you understand:

| Question Category | Example Questions |
|-------------------|-------------------|
| **Functional Scope** | ¿Qué debe hacer exactamente? ¿Qué NO debe hacer? |
| **Users/Actors** | ¿Quién usará esta funcionalidad? |
| **Integration** | ¿Se conecta con APIs externas? ¿Qué sistemas afecta? |
| **Constraints** | ¿Hay restricciones de tiempo/tecnología/rendimiento? |
| **Success Criteria** | ¿Cómo sabremos que está completo y funciona? |

### Step 1.3: Document the Understood Problem

```markdown
## Problem Statement

### What We're Building
[Clear description of the feature/task]

### Why It's Needed
[Business justification]

### Who Benefits
[Users/stakeholders]

### Constraints
- Technical: [stack, performance, integrations]
- Business: [timeline, budget, compliance]
- Team: [skills, availability]

### Success Criteria
1. [Measurable criterion 1]
2. [Measurable criterion 2]
```

---

## PHASE 2: SPECS (Definir Criterios de Aceptación)

Every task has TWO types of specs:

### A. Task-Specific Specs (Functional Requirements)

These are unique to each task:

```markdown
## Functional Specs: ${FEATURE_ID}

### SPEC-F01: [Functional Requirement 1]
**Description**: [What it must do]
**Acceptance Criteria**:
- [ ] [Testable criterion]
- [ ] [Testable criterion]
**Verification**: [How to test]

### SPEC-F02: [Functional Requirement 2]
...
```

### B. MANDATORY SPEC: SOLID Compliance (Always Required)

**THIS SPEC APPLIES TO ALL TASKS, ALWAYS.**

```markdown
## MANDATORY SPEC: SOLID-COMPLIANCE

**This spec is NON-NEGOTIABLE. All code must comply.**

### SPEC-SOLID: Code Quality via SOLID Principles

**Description**: All proposed/created code MUST comply with SOLID principles
using appropriate design patterns and best practices.

**Acceptance Criteria**:
- [ ] **S** - Single Responsibility: Each class has ONE reason to change
- [ ] **O** - Open/Closed: Extensible via composition, not modification
- [ ] **L** - Liskov Substitution: Subtypes honor parent contracts
- [ ] **I** - Interface Segregation: Interfaces are role-specific (≤5 methods)
- [ ] **D** - Dependency Inversion: High-level modules depend on abstractions

**Minimum Score**: 18/25 to proceed, 22/25 to approve
**Verification**: `/workflow-skill:solid-analyzer --validate`

### Required Design Patterns

Based on the task, these patterns MUST be considered:

| If You Need... | Use Pattern | SOLID Principles Addressed |
|----------------|-------------|---------------------------|
| Multiple behaviors | Strategy | OCP, SRP |
| Add functionality | Decorator | OCP, SRP |
| Object creation | Factory Method | DIP, OCP |
| External integrations | Adapter / Ports & Adapters | DIP, OCP |
| Data access | Repository | SRP, DIP |
| Processing chains | Chain of Responsibility | SRP, OCP |

See `core/solid-pattern-matrix.md` for complete mapping.
```

### How to Generate Specs

```bash
# Generate functional specs interactively
/workflow-skill:criteria-generator --feature=${FEATURE_ID} --interview

# This ALWAYS includes SOLID as mandatory spec
# Output: .ai/project/features/${FEATURE_ID}/12_specs.md
```

---

## PHASE 3: PLAN WITH SOLUTIONS

The plan MUST detail HOW to achieve each spec.

### Step 3.1: Load Context

```
Read: core/roles/planner.md
Read: core/solid-pattern-matrix.md
Read: .ai/extensions/rules/project_rules.md
```

### Step 3.2: Analyze Existing Code (for SOLID baseline)

```bash
# Get current SOLID score of affected areas
/workflow-skill:solid-analyzer --path=src/relevant-module

# Output shows:
# - Current SOLID score
# - Violations found
# - Recommended patterns to fix
```

### Step 3.3: Design Solutions

For EACH spec, propose a solution:

```markdown
## Solutions: ${FEATURE_ID}

### Solution for SPEC-F01: [Functional Requirement]
**Approach**: [How to implement]
**Files to Create/Modify**: [List]
**Reference Pattern**: [Existing code to follow]

### Solution for SPEC-F02: [Functional Requirement]
...

### Solution for SPEC-SOLID: SOLID Compliance

**Current SOLID Score**: [X/25] (from analyzer)
**Target SOLID Score**: ≥22/25

#### Patterns Selected:

| Violation/Need | Pattern | Implementation |
|----------------|---------|----------------|
| [God class detected] | Strategy + Extract Class | Split `BigService` into `XStrategy`, `YStrategy` |
| [Switch by type] | Strategy | Create `ProcessorInterface` with implementations |
| [Concrete dependencies] | Dependency Injection | Inject interfaces, not classes |
| [Layer violation] | Ports & Adapters | Create Port interface in Domain |

#### Class Design (SOLID-Compliant):

```
┌─────────────────────────────────────────┐
│ Domain Layer (no external dependencies) │
├─────────────────────────────────────────┤
│ ├── Entity/                             │
│ │   └── User.php (SRP: only user data)  │
│ ├── ValueObject/                        │
│ │   └── Email.php (SRP: email rules)    │
│ ├── Repository/                         │
│ │   └── UserRepositoryInterface (DIP)   │
│ └── Service/                            │
│     └── UserDomainService (SRP)         │
└─────────────────────────────────────────┘
          ↑ depends on abstractions (DIP)
┌─────────────────────────────────────────┐
│ Infrastructure Layer                    │
├─────────────────────────────────────────┤
│ └── Persistence/                        │
│     └── DoctrineUserRepository (DIP)    │
│         implements UserRepositoryInterface
└─────────────────────────────────────────┘
```

#### Why These Patterns?

| Pattern | Why Selected | SOLID Score Impact |
|---------|--------------|-------------------|
| Strategy | Avoid switch statements, enable new behaviors without modification | OCP +5, SRP +3 |
| Repository Interface | Decouple domain from persistence | DIP +5, SRP +2 |
| Value Objects | Encapsulate validation rules | SRP +3 |

**Expected SOLID Score After Implementation**: 24/25
```

### Step 3.4: Create Task Breakdown

Each task references the solution and SOLID requirements:

```markdown
### Task BE-001: Create User Entity

**Role**: Backend Engineer
**Methodology**: TDD (Red-Green-Refactor)

**Functional Requirements**:
- User entity with id, email, name, password
- Email as Value Object

**SOLID Requirements**:
- SRP: Entity only holds data, no business logic
- DIP: No infrastructure imports in Entity
- Pattern: Value Object for Email

**Tests to Write FIRST**:
- [ ] test_user_can_be_created_with_valid_data()
- [ ] test_email_value_object_validates_format()

**Acceptance Criteria**:
- [ ] Entity in src/Domain/Entity/
- [ ] Value Object in src/Domain/ValueObject/
- [ ] SOLID score ≥4/5 for SRP
- [ ] No Doctrine imports in Domain

**Reference**: src/Domain/Entity/Order.php (existing pattern)
```

---

## Complete Planning Workflow

```bash
# 1. Create workspace
FEATURE_ID="user-authentication"
mkdir -p .ai/project/features/${FEATURE_ID}

# 2. PHASE 1: Understand
# - Analyze request
# - Ask clarifying questions if needed
# - Document problem statement

# 3. PHASE 2: Specs
/workflow-skill:criteria-generator --feature=${FEATURE_ID} --interview
# Output: 12_specs.md (includes SOLID as mandatory spec)

# 4. PHASE 3: Plan with Solutions
/workflow-skill:solid-analyzer --path=src/relevant-path  # Get baseline
# Design solutions with patterns
# Create task breakdown

# 5. Validate plan completeness
# - All specs have solutions
# - All solutions include SOLID patterns
# - Expected SOLID score ≥22/25
```

---

## Planning Checklist

Before marking planning as COMPLETED:

### Functional Completeness
- [ ] Problem is clearly understood and documented
- [ ] All functional specs defined (testable)
- [ ] All API endpoints fully specified
- [ ] Tasks broken down by role

### SOLID Completeness (MANDATORY)
- [ ] **SOLID baseline analyzed** (current score documented)
- [ ] **Patterns selected** for each SOLID requirement
- [ ] **Class design** shows SOLID compliance
- [ ] **Expected SOLID score** ≥22/25 documented
- [ ] **Each task** includes SOLID requirements

### Quality Checks
- [ ] Can engineer start WITHOUT asking questions? YES
- [ ] Are patterns and references provided? YES
- [ ] Is "why this pattern?" explained? YES

**If SOLID is not addressed in the plan, the plan is INCOMPLETE.**

---

## Output Files

### For `default` workflow:
```
.ai/project/features/${FEATURE_ID}/
├── 00_problem_statement.md    # Phase 1 output
├── 12_specs.md                # Phase 2 output (includes SOLID)
├── 15_solutions.md            # Phase 3 solutions with patterns
├── 30_tasks.md                # Task breakdown
├── 50_state.md                # State tracking
└── FEATURE_${FEATURE_ID}.md   # Summary document
```

### For `task-breakdown` workflow (complete):
```
.ai/project/features/${FEATURE_ID}/
├── 00_problem_statement.md
├── 10_architecture.md
├── 12_specs.md                # Includes SOLID spec
├── 15_solutions.md            # Includes SOLID patterns
├── 15_data_model.md
├── 20_api_contracts.md
├── 30_tasks_backend.md
├── 31_tasks_frontend.md
├── 32_tasks_qa.md
├── 35_dependencies.md
├── 50_state.md
└── FEATURE_${FEATURE_ID}.md
```

---

## Example: Complete Plan with SOLID

```markdown
# Feature Plan: user-authentication

## PHASE 1: Problem Statement

We need to implement user authentication with email/password.
Users should be able to register, login, and logout.

## PHASE 2: Specs

### SPEC-F01: User Registration
- User can register with email and password
- Email must be unique
- Password must be ≥8 characters

### SPEC-F02: User Login
- User can login with email and password
- Returns JWT token on success

### SPEC-SOLID: SOLID Compliance (MANDATORY)
- All code must score ≥22/25
- Must use appropriate design patterns

## PHASE 3: Solutions

### Solution SPEC-F01 & F02: Authentication Flow
- Create User entity with Email value object
- Create AuthenticationService

### Solution SPEC-SOLID: Design Patterns

| Need | Pattern | Why |
|------|---------|-----|
| Password hashing strategies | Strategy | OCP - add new hashers without modifying |
| Token generation | Factory Method | DIP - abstract token creation |
| User persistence | Repository | DIP - decouple from Doctrine |

**Class Design**:
- `Domain/Entity/User` - only user data (SRP)
- `Domain/ValueObject/Email` - email validation (SRP)
- `Domain/Service/AuthenticationService` - auth logic only (SRP)
- `Domain/Repository/UserRepositoryInterface` - abstraction (DIP)
- `Infrastructure/Repository/DoctrineUserRepository` - implementation

**Expected SOLID Score**: 24/25
```

---

## Related Commands

- `/workflow-skill:criteria-generator` - Generate specs interactively
- `/workflow-skill:solid-analyzer` - Analyze SOLID compliance
- `/workflows:work` - Execute the plan
- `/workflows:review` - Review implementation

## Related Documentation

- `core/solid-pattern-matrix.md` - Violation → Pattern mapping
- `core/architecture-quality-criteria.md` - Quality metrics
- `skills/workflow-skill-solid-analyzer.md` - SOLID analysis tool
