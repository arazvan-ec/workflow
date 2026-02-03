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
│                    PHASE 2: SPECS (Functional Requirements)     │
│  Define WHAT the system must do:                                │
│  └── Task-specific specs (user requirements, acceptance criteria│
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 3: PLAN WITH SOLUTIONS                 │
│  Design HOW to implement each spec:                             │
│  ├── Functional solutions (implementation approach)             │
│  └── **CONSTRAINT: SOLID** (patterns + quality = mandatory)     │
└─────────────────────────────────────────────────────────────────┘
```

### Key Distinction

| Phase 2: SPECS | Phase 3: SOLUTIONS |
|----------------|-------------------|
| **QUÉ** debe hacer | **CÓMO** hacerlo |
| Requisitos funcionales | Diseño técnico |
| "User can register" | "Use Strategy pattern for validators" |
| Del usuario/negocio | Del desarrollador/arquitecto |

**SOLID es un CONSTRAINT de diseño en Fase 3, no una spec funcional en Fase 2.**

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

## PHASE 2: SPECS (Requisitos Funcionales)

Phase 2 defines **WHAT** the system must do - the functional requirements from the user's perspective.

### Functional Specs Only

```markdown
## Functional Specs: ${FEATURE_ID}

### SPEC-F01: [Functional Requirement 1]
**Description**: [What it must do - from user perspective]
**Acceptance Criteria**:
- [ ] [Testable criterion]
- [ ] [Testable criterion]
**Verification**: [How to test]

### SPEC-F02: [Functional Requirement 2]
**Description**: [What it must do]
**Acceptance Criteria**:
- [ ] [Testable criterion]
**Verification**: [How to test]

### SPEC-F03: [Functional Requirement 3]
...
```

### Examples of Good Specs (Functional)

| Good Spec (QUÉ) | Bad Spec (CÓMO) |
|-----------------|-----------------|
| "User can register with email and password" | "Use Strategy pattern" |
| "System validates email format" | "Create EmailValidator class" |
| "Login returns authentication token" | "Implement Repository pattern" |
| "Password must be ≥8 characters" | "Use DIP for dependencies" |

**Note**: SOLID, patterns, and technical decisions belong in Phase 3, not here.

### How to Generate Specs

```bash
# Generate functional specs interactively
/workflow-skill:criteria-generator --feature=${FEATURE_ID} --interview

# Output: .ai/project/features/${FEATURE_ID}/12_specs.md
```

---

## PHASE 3: PLAN WITH SOLUTIONS

Phase 3 defines **HOW** to implement each spec. This is where **SOLID becomes mandatory**.

### The SOLID Constraint

> ⚠️ **MANDATORY CONSTRAINT**: All solutions MUST comply with SOLID principles.
>
> This is NOT optional. Every solution designed in Phase 3 must:
> 1. Be analyzed for SOLID compliance
> 2. Use appropriate design patterns
> 3. Achieve score ≥18/25 to proceed, ≥22/25 to approve

### Step 3.1: Analyze Existing Code (SOLID Baseline)

Before designing solutions, understand the current state:

```bash
# Get SOLID score of affected areas
/workflow-skill:solid-analyzer --path=src/relevant-module

# Output:
# - Current SOLID score: X/25
# - Violations found: [list]
# - Recommended patterns: [list]
```

### Step 3.2: Design Solutions with SOLID

For EACH functional spec, propose a solution that complies with SOLID:

```markdown
## Solutions: ${FEATURE_ID}

---

### Solution for SPEC-F01: User Registration

**Approach**: Create User entity with email validation

**SOLID Compliance**:
| Principle | How It's Addressed | Pattern Used |
|-----------|-------------------|--------------|
| **S** - SRP | User entity only holds data, validation in ValueObject | Value Object |
| **O** - OCP | New validators can be added without modifying User | Strategy |
| **L** - LSP | N/A for this solution | - |
| **I** - ISP | Small, focused interfaces | - |
| **D** - DIP | Repository interface in Domain | Repository |

**Files to Create**:
- `Domain/Entity/User.php` (SRP: only user data)
- `Domain/ValueObject/Email.php` (SRP: email rules)
- `Domain/Repository/UserRepositoryInterface.php` (DIP: abstraction)
- `Infrastructure/Repository/DoctrineUserRepository.php` (DIP: implementation)

**Expected SOLID Score**: 24/25

---

### Solution for SPEC-F02: User Login

**Approach**: Authentication service with token generation

**SOLID Compliance**:
| Principle | How It's Addressed | Pattern Used |
|-----------|-------------------|--------------|
| **S** - SRP | Auth logic separate from token generation | Extract Class |
| **O** - OCP | Token strategies can be added | Strategy |
| **D** - DIP | Inject token generator interface | DI |

**Files to Create**:
- `Application/Service/AuthenticationService.php`
- `Domain/Service/TokenGeneratorInterface.php`
- `Infrastructure/Service/JwtTokenGenerator.php`

**Expected SOLID Score**: 23/25
```

### Step 3.3: Pattern Selection Guide

When designing solutions, select patterns based on the need:

| If You Need... | Use Pattern | SOLID Addressed |
|----------------|-------------|-----------------|
| Multiple behaviors/algorithms | **Strategy** | OCP, SRP |
| Add functionality without modification | **Decorator** | OCP, SRP |
| Abstract object creation | **Factory Method** | DIP, OCP |
| Integrate external systems | **Adapter / Ports & Adapters** | DIP, OCP |
| Abstract data persistence | **Repository** | SRP, DIP |
| Chain of processing steps | **Chain of Responsibility** | SRP, OCP |
| Encapsulate validation rules | **Value Object** | SRP |
| Decouple layers | **Dependency Injection** | DIP |

See `core/solid-pattern-matrix.md` for complete mapping.

### Step 3.4: Verify SOLID Score

Before finalizing the plan:

```bash
# Validate proposed design achieves SOLID score
/workflow-skill:solid-analyzer --validate --design=15_solutions.md

# Must achieve:
# - ≥18/25 to proceed to implementation
# - ≥22/25 to approve for merge
```

### SOLID Score Thresholds

| Score | Grade | Action |
|-------|-------|--------|
| 22-25/25 | A - SOLID Compliant | ✅ Approve |
| 18-21/25 | B - Acceptable | ✅ Proceed with notes |
| 14-17/25 | C - Needs Work | ❌ Redesign before implementation |
| <14/25 | F - Rejected | ❌ Complete redesign required |

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
# Output: 00_problem_statement.md

# 3. PHASE 2: Specs (functional only)
/workflow-skill:criteria-generator --feature=${FEATURE_ID} --interview
# Output: 12_specs.md (WHAT the system must do)

# 4. PHASE 3: Solutions with SOLID
/workflow-skill:solid-analyzer --path=src/relevant-path  # Get baseline
# Design solutions using patterns
# Verify SOLID score ≥22/25
# Output: 15_solutions.md (HOW with SOLID)

# 5. Create task breakdown
# Each task includes SOLID requirements
# Output: 30_tasks.md
```

---

## Task Template (includes SOLID)

Each task must include SOLID requirements:

```markdown
### Task BE-001: Create User Entity

**Role**: Backend Engineer
**Methodology**: TDD (Red-Green-Refactor)

**Functional Requirement** (from SPEC-F01):
- User entity with id, email, name, password

**SOLID Requirements** (from solution design):
- **SRP**: Entity only holds data, no business logic
- **DIP**: No infrastructure imports in Entity
- **Pattern**: Value Object for Email

**Tests to Write FIRST**:
- [ ] test_user_can_be_created_with_valid_data()
- [ ] test_email_value_object_validates_format()

**Acceptance Criteria**:
- [ ] Entity in src/Domain/Entity/
- [ ] Value Object in src/Domain/ValueObject/
- [ ] **SOLID score ≥4/5 for SRP**
- [ ] No Doctrine imports in Domain

**Reference**: src/Domain/Entity/Order.php (existing pattern)
```

---

## Planning Checklist

Before marking planning as COMPLETED:

### Phase 1: Understanding
- [ ] Problem is clearly understood and documented
- [ ] Clarifying questions asked if needed
- [ ] Constraints identified

### Phase 2: Specs (Functional)
- [ ] All functional specs defined (testable)
- [ ] Specs describe WHAT, not HOW
- [ ] API endpoints fully specified
- [ ] Success criteria clear

### Phase 3: Solutions (with SOLID)
- [ ] **SOLID baseline analyzed** (current score)
- [ ] Each spec has a solution
- [ ] **Patterns selected** for SOLID compliance
- [ ] **Expected SOLID score ≥22/25**
- [ ] Tasks include SOLID requirements

### Final Check
- [ ] Can engineer start WITHOUT asking questions? YES
- [ ] Is "why this pattern?" explained? YES

**If SOLID is not addressed in Phase 3, the plan is INCOMPLETE.**

---

## Output Files

### For `default` workflow:
```
.ai/project/features/${FEATURE_ID}/
├── 00_problem_statement.md    # Phase 1: Understanding
├── 12_specs.md                # Phase 2: Functional specs (WHAT)
├── 15_solutions.md            # Phase 3: Solutions with SOLID (HOW)
├── 30_tasks.md                # Task breakdown
├── 50_state.md                # State tracking
└── FEATURE_${FEATURE_ID}.md   # Summary
```

### For `task-breakdown` workflow:
```
.ai/project/features/${FEATURE_ID}/
├── 00_problem_statement.md
├── 10_architecture.md
├── 12_specs.md                # Functional specs only
├── 15_solutions.md            # Solutions with SOLID patterns
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

## Example: Complete Plan

```markdown
# Feature Plan: user-authentication

## PHASE 1: Problem Statement

We need user authentication with email/password.
Users should register, login, and logout.

## PHASE 2: Specs (WHAT - Functional)

### SPEC-F01: User Registration
- User can register with email and password
- Email must be unique
- Password must be ≥8 characters

### SPEC-F02: User Login
- User can login with email and password
- Returns authentication token on success

### SPEC-F03: User Logout
- User can invalidate their token

## PHASE 3: Solutions (HOW - with SOLID)

### SOLID Baseline
Current code: N/A (greenfield)
Target score: ≥22/25

### Solution for SPEC-F01 & F02

**Patterns Selected**:
| Need | Pattern | SOLID |
|------|---------|-------|
| Email validation rules | Value Object | SRP |
| Password hashing strategies | Strategy | OCP |
| User persistence | Repository | DIP |
| Token generation | Factory Method | DIP |

**Class Design**:
```
Domain/
├── Entity/User.php           (SRP: data only)
├── ValueObject/Email.php     (SRP: validation)
├── Repository/UserRepositoryInterface.php (DIP)
└── Service/PasswordHasherInterface.php (DIP)

Application/
└── Service/AuthenticationService.php (SRP)

Infrastructure/
├── Repository/DoctrineUserRepository.php
└── Service/BcryptPasswordHasher.php
```

**Expected SOLID Score**: 24/25
```

---

## Summary: Where is SOLID?

| Phase | Content | SOLID? |
|-------|---------|--------|
| Phase 1: Understand | Problem statement | ❌ No |
| Phase 2: Specs | Functional requirements (WHAT) | ❌ No |
| **Phase 3: Solutions** | Technical design (HOW) | ✅ **YES - MANDATORY** |

**SOLID is a design CONSTRAINT in Phase 3, not a functional SPEC in Phase 2.**

---

## Related Commands

- `/workflow-skill:criteria-generator` - Generate functional specs
- `/workflow-skill:solid-analyzer` - Analyze SOLID compliance
- `/workflows:work` - Execute the plan
- `/workflows:review` - Review implementation

## Related Documentation

- `core/solid-pattern-matrix.md` - Violation → Pattern mapping
- `core/architecture-quality-criteria.md` - Quality metrics
- `skills/workflow-skill-solid-analyzer.md` - SOLID analysis tool
