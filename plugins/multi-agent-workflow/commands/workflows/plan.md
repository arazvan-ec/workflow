---
name: workflows:plan
description: "Convert ideas into implementable strategies with detailed planning. The foundation of compound engineering (80% planning, 20% execution)."
argument_hint: <feature-name> [--workflow=default|task-breakdown] [--show-impact=true|false]
---

# Multi-Agent Workflow: Plan

The planning phase is the foundation of compound engineering. Invest 80% of effort here.

## Flow Guard (prerequisite check)

Before executing, verify the flow has been followed:

```
PREREQUISITE CHECK:
  1. Was this request routed via /workflows:route?
     - YES: Continue to planning
     - NO: STOP. Run /workflows:route first, then return here.

  2. If tasks.md exists in openspec/changes/{slug}/ for this feature, is this a continuation?
     - YES (planner = IN_PROGRESS): Resume planning from last checkpoint
     - YES (planner = COMPLETED): Plan already exists. Confirm re-planning with user.
     - NO: Fresh start, proceed normally.

  If either check fails, do NOT proceed. Route first.
```

## Usage

```
/workflows:plan user-authentication
/workflows:plan payment-system --workflow=task-breakdown
/workflows:plan order-management --show-impact=true
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--workflow` | `default` | Workflow type: `default` or `task-breakdown` |
| `--show-impact` | `true` | Show detailed integration impact analysis |

## Philosophy

> "Each unit of engineering work should make subsequent units easier—not harder"

> "El código de alta calidad cumple SOLID de forma rigurosa"

Good planning means:
- Engineers can start WITHOUT asking questions
- **Solutions are designed with SOLID compliance from the start**
- API contracts are complete enough to mock
- Every task has clear "definition of done"

---

## MANDATORY: Incremental Persistence Protocol

> **CRITICAL RULE**: Every planning phase MUST write its output file to disk IMMEDIATELY upon completion, BEFORE starting the next phase. Planning is NOT an in-memory exercise. If Claude is interrupted at any point, all completed phases must be recoverable from disk.

### The Write-Then-Advance Rule

```
PHASE COMPLETION PROTOCOL (applies to every phase):

1. GENERATE the phase output in full
2. WRITE the output file to disk immediately (use Write tool)
3. UPDATE tasks.md Workflow State with phase completion status + timestamp
4. VERIFY the file exists on disk (use Read tool to confirm)
5. ONLY THEN advance to the next phase

If step 2 fails, RETRY the write. Do NOT proceed to next phase
with unwritten output.
```

### Planning Progress Tracker (in tasks.md Workflow State)

At the START of planning, create `openspec/changes/${FEATURE_ID}/tasks.md` with this initial structure:

```markdown
# Implementation Tasks

## Progress
| Task | Status | Verify | Completed At |
|------|--------|--------|--------------|
(populated in Phase 4)

## Task Details
(populated in Phase 4)

## Workflow State
**Planner**: IN_PROGRESS | **Implementer**: PENDING | **Reviewer**: PENDING
**Feature**: ${FEATURE_ID}
**Started**: ${ISO_TIMESTAMP}
**Last Updated**: ${ISO_TIMESTAMP}
**Last Phase**: (none) | **Resume Point**: Step 0

### Planning Progress
| Phase | Status | Output File | Written At |
|-------|--------|-------------|------------|
| Step 0 (Load Specs) | PENDING | (context only) | - |
| Phase 1 (Understand) | PENDING | proposal.md | - |
| Phase 2 (Specs) | PENDING | specs.md | - |
| Phase 3 (Design) | PENDING | design.md | - |
| Phase 4 (Tasks) | PENDING | tasks.md | - |
| Completeness Check | PENDING | (summary in proposal.md) | - |
```

### Per-Phase Write Directives

After completing each phase, you MUST execute these exact steps:

**After Step 0 (Load Specs)**:
```
1. UPDATE tasks.md Workflow State: Step 0 → COMPLETED, timestamp
2. No output file for this step (context only)
```

**After Phase 1 (Understand)**:
```
1. WRITE openspec/changes/${FEATURE_ID}/proposal.md
2. VERIFY file exists and has substantive content (not just headers)
3. UPDATE tasks.md Workflow State: Phase 1 → COMPLETED, timestamp, file path
4. UPDATE Resume Point: Last Phase = Phase 1, Resume Point = Phase 2
```

**After Phase 2 (Specs)**:
```
1. RUN Integration Analysis pre-hook (reads openspec/specs/, generates impact context)
2. GENERATE specs.md with impact context injected
3. RUN Quality Gate post-hook (4 checks, max 3 iterations)
4. WRITE openspec/changes/${FEATURE_ID}/specs.md
5. VERIFY file exists and has substantive content
6. UPDATE tasks.md Workflow State: Phase 2 → COMPLETED, timestamp
7. UPDATE Resume Point: Last Phase = Phase 2, Resume Point = Phase 3
```

**After Phase 3 (Design)**:
```
1. WRITE openspec/changes/${FEATURE_ID}/design.md
2. VERIFY file exists and has substantive content
3. UPDATE tasks.md Workflow State: Phase 3 → COMPLETED, timestamp
4. UPDATE Resume Point: Last Phase = Phase 3, Resume Point = Phase 4
```

**After Phase 4 (Tasks)**:
```
1. UPDATE openspec/changes/${FEATURE_ID}/tasks.md (Progress + Task Details sections)
2. VERIFY file has substantive content
3. APPEND summary section to proposal.md
4. UPDATE tasks.md Workflow State: Phase 4 → COMPLETED, Completeness Check → PENDING
5. PROCEED to Completeness Verification
```

---

## Shaping Integration (Optional Pre-Phase)

If `/workflows:shape` was run before planning, the following artifacts are available in `openspec/changes/${FEATURE_ID}/`:

| File | Content | How Planner Uses It |
|------|---------|---------------------|
| `01_shaped_brief.md` | Frame, requirements (R), shape, fit check | Accelerates Phase 1 (Understand) and Phase 2 (Specs) |
| `02_breadboard.md` | Places, affordances, wiring diagram | Informs Phase 3 (Design) with concrete mechanisms |
| `03_slices.md` | Vertical slices with demo statements | Becomes the task group structure in Phase 4 |
| `spike-*.md` | Technical investigation findings | Provides context for design decisions |

When shaped brief exists, the planner should:
1. **Phase 1**: Use the Frame as the problem statement (verify with user, don't re-derive)
2. **Phase 2**: Use Requirements (R) as foundation for functional specs (add formal structure)
3. **Phase 3**: Use Shape parts as starting point for design (add SOLID analysis)
4. **Phase 4**: Use Slices (V1, V2...) to structure task groups vertically

---

## Planning Depth Resolution

Before starting the planning process, resolve the `planning_depth` provider from `core/providers.yaml`:

```
READ core/providers.yaml → providers.planning_depth

IF "auto":
  ├── Complexity from /workflows:route == "complex" → full
  ├── Complexity from /workflows:route == "medium"  → standard
  └── Complexity from /workflows:route == "simple"  → minimal

IF "full":    Execute ALL phases (Step 0 + Phase 1 + Phase 2 + Phase 3 + Phase 4)
IF "standard": Execute Step 0 + Phase 1 + Phase 2 + Phase 3 (skip integration/impact detail) + Phase 4
IF "minimal":  Execute Step 0 + Phase 1 + Phase 4 ONLY (skip Phase 2 specs and Phase 3 solutions)
```

| Depth | Phases | Output Files | Best For |
|-------|--------|-------------|----------|
| **full** | All phases + integration + SOLID + impact | proposal, specs, design, tasks | Complex features, multi-layer, security |
| **standard** | Phase 1-4, no detailed impact | proposal, specs, design, tasks | Medium features, single-layer |
| **minimal** | Phase 1 + Phase 4 only | proposal, tasks | Simple features, bug fixes |

When `planning_depth` is `minimal`, the Quality Gates for Phase 2 and Phase 3 are skipped (those phases don't execute).

---

## The Architecture-First Planning Process

> **"Every new feature is an INTEGRATION into existing architecture, not an isolated solution."**

```
┌─────────────────────────────────────────────────────────────────┐
│                    STEP 0: LOAD PROJECT SPECS                   │
│  Read existing specs → Understand current architecture          │
│  └── entities, api-contracts, business-rules, constraints       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 1: UNDERSTAND                          │
│  Analyze request → Ask clarifying questions → Document problem  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 2: SPECS + INTEGRATION ANALYSIS        │
│  Define WHAT the system must do:                                │
│  ├── Task-specific specs (user requirements, acceptance criteria│
│  └── **Integration Analysis** (existing specs impact)           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 3: SOLUTIONS + ARCHITECTURAL IMPACT    │
│  Design HOW to implement each spec:                             │
│  ├── Functional solutions (implementation approach)             │
│  ├── **CONSTRAINT: SOLID** (patterns + quality = mandatory)     │
│  └── **Architectural Impact** (layers, modules, change scope)   │
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

## STEP 0: LOAD PROJECT SPECS (Architecture Context)

Before planning any new feature, load and understand the existing project architecture.

### Step 0.0: Load Implementation Preferences (if exists)

```bash
# Check if pre-planning phase captured preferences
PREFERENCES="openspec/changes/${FEATURE_ID}/01_preferences.md"
if [ -f "$PREFERENCES" ]; then
  echo "Preferences found from pre-planning. Loading into planning context."
  # Read technology choices, architecture preferences, code style, constraints
  # Do NOT re-ask questions already answered in 01_preferences.md
  # Use preferences to guide Phase 1 constraints and Phase 3 design
fi
```

### Step 0.0b: Check for Shaped Brief (if exists)

```bash
# Check if shaping was done before planning
SHAPED_BRIEF="openspec/changes/${FEATURE_ID}/01_shaped_brief.md"
if [ -f "$SHAPED_BRIEF" ]; then
  echo "Shaped brief found. Using as input for planning."
  # Read shaped brief, breadboard, slices
  # Accelerate Phase 1 and Phase 2 with existing context
fi
```

### Step 0.1: Read Existing Specifications

```bash
# Load all existing project specs (BASELINE — read-only, only compound writes here)
SPECS_BASE="openspec/specs"

# Entities - the domain model
ls -la ${SPECS_BASE}/entities/*.yaml

# API Contracts - existing endpoints
ls -la ${SPECS_BASE}/api-contracts/*.yaml

# Business Rules - domain logic constraints
ls -la ${SPECS_BASE}/business-rules/*.yaml

# Architectural Constraints - system boundaries
ls -la ${SPECS_BASE}/architectural-constraints/*.yaml
```

### Step 0.2: Generate Specs Summary

```markdown
## Existing Project Specs Summary

### Entities (Domain Model)
| Entity | Properties | Relationships | Last Modified |
|--------|------------|---------------|---------------|
| User | id, email, name, role | has_many: Orders | 2026-01-15 |
| Order | id, status, total | belongs_to: User | 2026-01-20 |
| Product | id, name, price, stock | has_many: OrderItems | 2026-01-18 |

### API Contracts
| Endpoint | Method | Entity | Description |
|----------|--------|--------|-------------|
| /api/users | GET, POST | User | User CRUD |
| /api/orders | GET, POST | Order | Order management |
| /api/products | GET | Product | Product catalog |

### Business Rules
| Rule ID | Entity | Description |
|---------|--------|-------------|
| BR-001 | Order | Order total must be > 0 |
| BR-002 | User | Email must be unique |
| BR-003 | Product | Stock cannot be negative |

### Architectural Constraints
| Constraint | Type | Description |
|------------|------|-------------|
| AC-001 | Layer | Domain must not import Infrastructure |
| AC-002 | Security | Auth required for write operations |
| AC-003 | Performance | API response < 200ms |
```

### Step 0.3: Display Summary to User

When `--show-impact=true` (default), display this summary at the start of planning:

```
╔══════════════════════════════════════════════════════════════════╗
║                    PROJECT ARCHITECTURE CONTEXT                   ║
╠══════════════════════════════════════════════════════════════════╣
║  Entities:     12 defined (User, Order, Product, ...)            ║
║  Endpoints:    24 API contracts                                   ║
║  Rules:        18 business rules                                  ║
║  Constraints:   8 architectural constraints                       ║
╠══════════════════════════════════════════════════════════════════╣
║  New feature will be planned as INTEGRATION into this context    ║
╚══════════════════════════════════════════════════════════════════╝
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

### Phase 1 Quality Gate (BCP for Planning)

Before writing `proposal.md`, self-validate with bounded iteration:

```
PHASE 1 QUALITY CHECK (max 3 iterations):

  iteration = 0
  while iteration < 3:
    CHECK 1: Is the problem statement specific to the user's request?
      - Does it reference the user's exact words or intent?
      - FAIL if it is generic/templated (e.g., "The system needs improvement")

    CHECK 2: Does it have substantive content (not just headers)?
      - Count non-empty, non-header lines. Must be >= 10 lines of content.
      - FAIL if only section headers with placeholder text

    CHECK 3: Are success criteria measurable and specific?
      - Each criterion must be testable (pass/fail)
      - FAIL if criteria are vague (e.g., "good performance")

    CHECK 4: Does it address ALL aspects of the user's request?
      - Compare against the original request text
      - FAIL if significant aspects are missing

    IF all checks pass → WRITE file, advance to Phase 2
    IF any check fails → log which check failed, revise, iteration += 1

  IF 3 iterations exhausted and still failing:
    WRITE the best version with a "## Quality Warnings" section noting deficiencies
    NOTIFY user: "Phase 1 output has quality concerns: [list]. Review recommended."
    ADVANCE to Phase 2 (do not block indefinitely)
```

**After passing Quality Gate**: Follow the Per-Phase Write Directives (see Incremental Persistence Protocol above).

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

# Output: openspec/changes/${FEATURE_ID}/specs.md
```

### Integration Analysis (when --show-impact=true)

After defining functional specs, analyze how they integrate with existing specs.

#### Step 2.A: Identify Integration Points

```markdown
## Integration Analysis: ${FEATURE_ID}

### Entities Impact

#### EXTENDED (existing entities with new properties/methods)
| Entity | New Property/Method | Reason |
|--------|---------------------|--------|
| User | `subscription_tier` | Support premium features |
| Order | `discount_applied` | Apply subscription discounts |

#### MODIFIED (existing entities with changed behavior)
| Entity | Change | Impact |
|--------|--------|--------|
| User | Validation rules | Add tier validation |

#### NEW (entities created by this feature)
| Entity | Purpose | Relationships |
|--------|---------|---------------|
| Subscription | Track user subscription | belongs_to: User |
| SubscriptionPlan | Define available plans | has_many: Subscriptions |

### API Contracts Impact

#### EXTENDED (existing endpoints with new parameters/responses)
| Endpoint | Change | Backward Compatible |
|----------|--------|---------------------|
| GET /api/users/{id} | Add `subscription` to response | YES |
| POST /api/orders | Accept `discount_code` param | YES |

#### MODIFIED (existing endpoints with changed behavior)
| Endpoint | Change | Migration Required |
|----------|--------|-------------------|
| None | - | - |

#### NEW (endpoints created by this feature)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| /api/subscriptions | GET, POST | Subscription CRUD |
| /api/subscription-plans | GET | List available plans |

### Business Rules Impact

#### CONFLICTS (potential conflicts with existing rules)
| New Rule | Existing Rule | Resolution |
|----------|---------------|------------|
| "Premium users get 20% discount" | BR-001 "Order total > 0" | Check after discount |

#### NEW (business rules added by this feature)
| Rule ID | Entity | Description |
|---------|--------|-------------|
| BR-010 | Subscription | Active subscription required for premium features |
| BR-011 | Order | Discount cannot exceed 50% of order total |
```

#### Step 2.B: API Contract Design (for new/modified endpoints)

When the feature introduces new API endpoints or modifies existing ones, apply these conventions:

```
API CONTRACT DESIGN PROTOCOL:

1. NAMING: RESTful resource-based URLs
   - Resources are nouns, plural: /api/users, /api/orders
   - Nested resources for relationships: /api/users/{id}/orders
   - Actions as sub-resources when CRUD doesn't fit: /api/orders/{id}/cancel

2. CONTRACT DEFINITION: For each new/modified endpoint, specify:
   - Method + Path
   - Request: headers, path params, query params, body schema
   - Response: status codes (success + error), body schema
   - Authentication: required/optional, token type
   - Rate limiting: if applicable

3. CONSISTENCY: Match existing project conventions
   - Read existing API contracts in openspec/specs/api-contracts/
   - Follow the same response envelope format
   - Use consistent error response structure
   - Match pagination style (cursor vs offset)

4. VERSIONING: Follow project's versioning strategy
   - If existing endpoints use /api/v1/, new endpoints must too
   - If no versioning exists, don't introduce it unnecessarily

5. OUTPUT: Include contracts in specs.md Integration Analysis section
```

#### Step 2.C: Conflict Detection

Before proceeding to Phase 3, verify no unresolved conflicts:

```bash
# Check for spec conflicts
/workflow-skill:spec-analyzer --feature=${FEATURE_ID} --check-conflicts

# Output:
# ✅ No entity name conflicts
# ✅ No endpoint path conflicts
# ⚠️ 1 business rule conflict (BR-001 vs new discount rule)
# Action: Resolve conflict before proceeding
```

### Phase 2 Quality Gate (BCP for Planning)

Before writing `specs.md`, self-validate with bounded iteration:

```
PHASE 2 QUALITY CHECK (max 3 iterations):

  iteration = 0
  while iteration < 3:
    CHECK 1: Does each spec describe WHAT (not HOW)?
      - Specs must be functional requirements, not technical design
      - FAIL if specs contain implementation details (class names, patterns)

    CHECK 2: Does each spec have testable acceptance criteria?
      - At least 2 acceptance criteria per spec
      - Each must be verifiable (pass/fail)
      - FAIL if criteria are missing or vague

    CHECK 3: Do specs cover the FULL scope of the user's request?
      - Map each user requirement to at least one spec
      - FAIL if user requirements are not fully covered

    CHECK 4: Is the integration analysis substantive (not just "None")?
      - Must identify at least extended/modified/new for entities AND endpoints
      - FAIL if all sections say "None" for a non-trivial feature

    IF all checks pass → WRITE specs.md, advance to Phase 3
    IF any check fails → revise, iteration += 1

  IF 3 iterations exhausted:
    WRITE best version with "## Quality Warnings" section
    NOTIFY user of concerns
    ADVANCE to Phase 3
```

**After passing Quality Gate**: Follow the Per-Phase Write Directives (see Incremental Persistence Protocol above).

---

## PHASE 3: DESIGN

Phase 3 defines **HOW** to implement each spec. This is where **SOLID becomes mandatory**.

### The SOLID Constraint

> ⚠️ **MANDATORY CONSTRAINT**: All solutions MUST comply with SOLID principles.
>
> This is NOT optional. Every solution designed in Phase 3 must:
> 1. Be analyzed for SOLID compliance per principle
> 2. Use appropriate design patterns
> 3. Achieve COMPLIANT to proceed, NEEDS_WORK requires revision, NON_COMPLIANT blocks

### Step 3.1: Analyze Existing Code (SOLID Baseline)

Before designing solutions, understand the current state:

```bash
# Get SOLID baseline of affected areas
/workflow-skill:solid-analyzer --mode=baseline --path=src/relevant-module

# Output:
# - Patterns detected in module: [list]
# - Violations found: [list]
# - Principles most relevant to this module: [list]
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
- **SRP**: COMPLIANT — User entity only holds data, validation logic isolated in Email ValueObject
- **OCP**: COMPLIANT — New validators can be added without modifying User (Strategy pattern)
- **LSP**: N/A — No inheritance hierarchy in this solution
- **ISP**: COMPLIANT — Small, focused interfaces for repository and validation
- **DIP**: COMPLIANT — Repository interface defined in Domain, implemented in Infrastructure

**Files to Create**:
- `Domain/Entity/User.php` (SRP: only user data)
- `Domain/ValueObject/Email.php` (SRP: email rules)
- `Domain/Repository/UserRepositoryInterface.php` (DIP: abstraction)
- `Infrastructure/Repository/DoctrineUserRepository.php` (DIP: implementation)

---

### Solution for SPEC-F02: User Login

**Approach**: Authentication service with token generation

**SOLID Compliance**:
- **SRP**: COMPLIANT — Auth logic separate from token generation (Extract Class)
- **OCP**: COMPLIANT — Token strategies can be added without modification (Strategy pattern)
- **LSP**: N/A — No inheritance hierarchy in this solution
- **ISP**: COMPLIANT — Token generator interface is minimal and focused
- **DIP**: COMPLIANT — Token generator injected via interface (DI)

**Files to Create**:
- `Application/Service/AuthenticationService.php`
- `Domain/Service/TokenGeneratorInterface.php`
- `Infrastructure/Service/JwtTokenGenerator.php`
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

See `core/architecture-reference.md` for complete mapping. Consult openspec/specs/architecture-profile.yaml for project patterns.

### Step 3.4: Verify SOLID Compliance

Before finalizing the plan:

```bash
# Validate proposed design against SOLID principles
/workflow-skill:solid-analyzer --mode=design --design=design.md

# Gate logic:
# - COMPLIANT → proceed to implementation
# - NEEDS_WORK → revise design before proceeding
# - NON_COMPLIANT → blocked, requires redesign
```

### SOLID Verdict Gate

| Verdict | Action |
|---------|--------|
| All relevant principles COMPLIANT | ✅ Approve — proceed to implementation |
| Any principle NEEDS_WORK | ⚠️ Revise — address noted concerns before proceeding |
| Any principle NON_COMPLIANT | ❌ Blocked — redesign required for non-compliant principles |
| Principles marked N/A | ✅ Acceptable — with justification for why principle does not apply |

### Step 3.5: Architectural Impact Analysis (when --show-impact=true)

After designing solutions, analyze the architectural impact across the codebase.

#### Layers Affected

```markdown
## Architectural Impact: ${FEATURE_ID}

### Layer Analysis

| Layer | Impact Level | Changes Required |
|-------|--------------|------------------|
| **Domain** | HIGH | 2 new entities, 1 extended |
| **Application** | MEDIUM | 3 new use cases |
| **Infrastructure** | MEDIUM | 2 new repositories |
| **Presentation/API** | LOW | 2 new endpoints |

### Affected Layers Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ PRESENTATION                                                     │
│   [MODIFIED] UserController.php                                  │
│   [NEW] SubscriptionController.php                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ APPLICATION                                                      │
│   [NEW] CreateSubscriptionUseCase.php                            │
│   [NEW] ApplyDiscountUseCase.php                                 │
│   [MODIFIED] CreateOrderUseCase.php                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ DOMAIN                                                           │
│   [EXTENDED] User.php (add subscription_tier)                    │
│   [NEW] Subscription.php                                         │
│   [NEW] SubscriptionPlan.php                                     │
│   [NEW] DiscountCalculator.php (Domain Service)                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ INFRASTRUCTURE                                                   │
│   [NEW] DoctrineSubscriptionRepository.php                       │
│   [NEW] StripePaymentGateway.php                                 │
│   [MODIFIED] migrations/Version20260201_subscriptions.php        │
└─────────────────────────────────────────────────────────────────┘
```

### Existing Modules Touched

| Module | Files Touched | Risk Level | Notes |
|--------|---------------|------------|-------|
| `src/User/` | 3 files | MEDIUM | Core entity modified |
| `src/Order/` | 2 files | LOW | Minor additions |
| `src/Subscription/` | 8 files | N/A | New module |
| `tests/` | 12 files | LOW | New tests + updates |

### Change Scope Estimation

```
╔══════════════════════════════════════════════════════════════════╗
║                    CHANGE SCOPE SUMMARY                          ║
╠══════════════════════════════════════════════════════════════════╣
║  Files to CREATE:     14                                         ║
║  Files to MODIFY:      6                                         ║
║  Files to DELETE:      0                                         ║
║  ────────────────────────────────────────────────                ║
║  Total files affected: 20                                        ║
║                                                                  ║
║  Estimated LOC added:   ~800                                     ║
║  Estimated LOC modified: ~120                                    ║
║  ────────────────────────────────────────────────                ║
║  Complexity: MEDIUM                                              ║
║  Estimated effort: 2-3 days                                      ║
╚══════════════════════════════════════════════════════════════════╝
```

### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| User entity changes break existing tests | MEDIUM | HIGH | Run full test suite before merge |
| Payment gateway integration issues | LOW | HIGH | Use sandbox environment |
| Migration conflicts | LOW | MEDIUM | Coordinate with team |
```

### Phase 3 Quality Gate (BCP for Planning)

Before writing `design.md`, self-validate with bounded iteration:

```
PHASE 3 QUALITY CHECK (max 3 iterations):

  iteration = 0
  while iteration < 3:
    CHECK 1: Does every spec from Phase 2 have a corresponding solution?
      - Map SPEC-F01 → Solution, SPEC-F02 → Solution, etc.
      - FAIL if any spec lacks a solution

    CHECK 2: Does each solution specify concrete files to create/modify?
      - Must list actual file paths, not abstract descriptions
      - FAIL if solutions are too abstract ("implement a service")

    CHECK 3: Does each relevant SOLID principle have a reasoned verdict (COMPLIANT/N_A with justification)?
      - Each solution must have per-principle verdicts with reasoning
      - FAIL if verdicts are missing reasoning or all principles are marked N/A

    CHECK 4: Does the architectural impact section list specific layers and files?
      - Must identify files to CREATE and files to MODIFY
      - FAIL if change scope is empty or says "TBD"

    IF all checks pass → WRITE design.md, advance to Phase 4
    IF any check fails → revise, iteration += 1

  IF 3 iterations exhausted:
    WRITE best version with "## Quality Warnings" section
    NOTIFY user of concerns
    ADVANCE to Phase 4
```

**After passing Quality Gate**: Follow the Per-Phase Write Directives (see Incremental Persistence Protocol above).

---

## Complete Planning Workflow

```bash
# 0. STEP 0: Load Project Specs (Architecture Context)
FEATURE_ID="user-authentication"
mkdir -p openspec/changes/${FEATURE_ID}

# CREATE tasks.md with Planning Progress Tracker ← WRITE IMMEDIATELY
# (see Incremental Persistence Protocol for template)
# Read existing entities, api-contracts, business-rules, architectural-constraints from openspec/specs/
# Display summary of existing architecture
# UPDATE tasks.md Workflow State: Step 0 → COMPLETED

# 1. PHASE 1: Understand
# - Analyze request IN CONTEXT of existing specs
# - Ask clarifying questions if needed
# - Document problem statement
# - RUN Phase 1 Quality Gate (max 3 iterations)
# - WRITE openspec/changes/${FEATURE_ID}/proposal.md ← IMMEDIATELY
# - VERIFY file exists on disk
# - UPDATE tasks.md Workflow State: Phase 1 → COMPLETED with timestamp

# 2. PHASE 2: Specs + Integration Analysis
# - RUN Integration Analysis pre-hook (reads openspec/specs/, generates impact context)
/workflow-skill:criteria-generator --feature=${FEATURE_ID} --interview
# - Define functional specs with Gherkin scenarios (WHAT the system must do)
# - Include integration analysis (EXTENDED, MODIFIED, NEW, CONFLICT) with impact context
# - Detect conflicts with existing specs
# - RUN Quality Gate post-hook (4 checks, max 3 iterations)
# - WRITE openspec/changes/${FEATURE_ID}/specs.md ← IMMEDIATELY
# - VERIFY file exists on disk
# - UPDATE tasks.md Workflow State: Phase 2 → COMPLETED with timestamp

# 3. PHASE 3: Design (Solutions + SOLID + Architectural Impact)
/workflow-skill:solid-analyzer --path=src/relevant-path  # Get baseline
# - Design solutions using patterns
# - Verify SOLID compliance (all relevant principles COMPLIANT)
# - Analyze layers affected, modules touched, change scope
# - RUN Phase 3 Quality Gate (max 3 iterations)
# - WRITE openspec/changes/${FEATURE_ID}/design.md ← IMMEDIATELY
# - VERIFY file exists on disk
# - UPDATE tasks.md Workflow State: Phase 3 → COMPLETED with timestamp

# 4. PHASE 4: Tasks
# Each task includes SOLID requirements + integration notes + verify conditions
# - UPDATE openspec/changes/${FEATURE_ID}/tasks.md (Progress + Task Details) ← IMMEDIATELY
# - APPEND summary section to proposal.md
# - VERIFY file has substantive content
# - UPDATE tasks.md Workflow State: Phase 4 → COMPLETED with timestamp

# 5. RUN Plan Completeness Verification (MANDATORY)
# - Verify all files exist on disk
# - Verify substantive content (not just headers)
# - Cross-reference against original request
# - User confirmation
# - UPDATE tasks.md Workflow State: Planner → COMPLETED
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
- [ ] Architecture: Follow project patterns, SOLID compliance required per solid-analyzer
- [ ] No Doctrine imports in Domain

**Reference**: src/Domain/Entity/Order.php (existing pattern)
```

---

## Planning Checklist

Before marking planning as COMPLETED:

### Step 0: Architecture Context
- [ ] Existing specs loaded (entities, api-contracts, business-rules)
- [ ] Architectural constraints reviewed
- [ ] Current architecture understood

### Phase 1: Understanding
- [ ] Problem is clearly understood and documented
- [ ] Clarifying questions asked if needed
- [ ] Constraints identified
- [ ] **Context of existing architecture considered**

### Phase 2: Specs + Integration
- [ ] All functional specs defined (testable)
- [ ] Specs describe WHAT, not HOW
- [ ] API endpoints fully specified
- [ ] Success criteria clear
- [ ] **EXTENDED entities/endpoints identified**
- [ ] **MODIFIED entities/endpoints identified**
- [ ] **NEW entities/endpoints identified**
- [ ] **Conflicts with existing specs resolved**

### Phase 3: Solutions + Architectural Impact
- [ ] **SOLID baseline analyzed** (per-principle contextual analysis)
- [ ] Each spec has a solution
- [ ] **Patterns selected** for SOLID compliance
- [ ] **All relevant SOLID principles verified as COMPLIANT**
- [ ] Tasks include SOLID requirements
- [ ] **Layers affected documented**
- [ ] **Existing modules touched listed**
- [ ] **Change scope estimated (files affected)**
- [ ] **Risk assessment completed**

### Final Check
- [ ] Can engineer start WITHOUT asking questions? YES
- [ ] Is "why this pattern?" explained? YES
- [ ] **Is integration with existing code clear? YES**
- [ ] **Is architectural impact understood? YES**

**If SOLID is not addressed in Phase 3, the plan is INCOMPLETE.**
**If integration analysis is missing, the plan treats feature as ISOLATED (anti-pattern).**

---

## Plan Completeness Verification (MANDATORY before marking COMPLETED)

Before setting planner status to `COMPLETED` in `tasks.md` Workflow State, execute this verification:

```
PLAN COMPLETENESS GATE:

  STEP 1: Verify all required files exist on disk
  ─────────────────────────────────────────────────
  For each required file, use Read tool to verify it exists and is non-empty:

  REQUIRED_FILES = [
    "proposal.md",   # Phase 1 output
    "specs.md",      # Phase 2 output
    "design.md",     # Phase 3 output
    "tasks.md",      # Phase 4 output + state tracking
  ]

  missing = []
  for file in REQUIRED_FILES:
    path = "openspec/changes/${FEATURE_ID}/${file}"
    if NOT exists(path) OR is_empty(path):
      missing.append(file)

  IF missing is not empty:
    STOP. Report: "Plan incomplete. Missing files: ${missing}"
    DO NOT mark planner as COMPLETED.
    Attempt to generate missing files.

  STEP 2: Verify substantive content (not just headers)
  ─────────────────────────────────────────────────────
  For each REQUIRED file:
    Read the file
    Count lines that are not blank and not markdown headers (not starting with #)
    IF content_lines < 5:
      Flag as "insufficient content"

  IF any file flagged:
    WARN user: "${file} has insufficient content (${n} lines). Enriching..."
    Re-generate the flagged sections with more depth
    Re-write the file

  STEP 3: Cross-reference against original request
  ─────────────────────────────────────────────────
  Read the original user request (from proposal.md "Original Request")
  Read specs.md and tasks.md
  Verify:
    - Every distinct requirement from the request maps to at least one spec
    - Every spec maps to at least one task
    - No major aspect of the request is absent from the plan

  IF gaps found:
    LIST the gaps
    ASK user: "The plan may not fully cover: [gaps]. Should I add these?"
    IF yes: generate missing specs/tasks and write them
    IF no: document user's decision in tasks.md Workflow State notes

  STEP 4: User confirmation (recommended)
  ────────────────────────────────────────
  Present plan summary to user:
    "Plan complete for ${FEATURE_ID}:
     - ${N} functional specs defined
     - ${M} tasks created (${B} backend, ${F} frontend, ${Q} QA)
     - ${X} files to create, ${Y} files to modify
     - SOLID compliance: all relevant principles verified
     - All output files written to openspec/changes/${FEATURE_ID}/

     Ready to proceed to /workflows:work? (yes/review/revise)"

  IF "review": Display the summary section of proposal.md for user review
  IF "revise": Ask what to change, update relevant files
  IF "yes" or no response: Mark COMPLETED

  STEP 5: Mark planning COMPLETED
  ────────────────────────────────
  UPDATE tasks.md Workflow State:
    Planner Status → COMPLETED
    Completeness Check → COMPLETED
    All phases → COMPLETED with timestamps
    Last Updated → current timestamp
```

---

## Output Files

### OpenSpec Structure (all workflows):
```
openspec/changes/${FEATURE_ID}/
├── proposal.md   # Phase 1: Problem statement, motivation, scope, success criteria
├── specs.md      # Phase 2: Functional specs (WHAT) + Integration Analysis
├── design.md     # Phase 3: Solutions + SOLID + Architectural Impact (HOW)
└── tasks.md      # Phase 4: Task breakdown + verify conditions + Workflow State
```

### specs.md Structure

```markdown
# Functional Specifications: ${FEATURE_ID}

## Requirements
- SPEC-F01: [Functional Requirement 1]
  - Acceptance Criteria: ...
  - Verification: ...
- SPEC-F02: ...

## Scenarios (Gherkin)
GIVEN [precondition]
WHEN [action]
THEN [expected result]

## Integration Analysis
### Entities Impact
| Entity | Change Type | Details |
(EXTENDED / MODIFIED / NEW / CONFLICT)

### API Contracts Impact
[Extended, Modified, New endpoints]

### Business Rules Impact
[Conflicts with existing rules + new rules]

### Backward Compatibility
[Assessment: YES | NO | PARTIAL, migration needs, breaking changes]
```

### design.md Structure

```markdown
# Technical Design: ${FEATURE_ID}

## Solution Approach
[Per-requirement solution mapping: SPEC-F01 → Solution, etc.]

## SOLID Analysis
- SOLID baseline: contextual per-principle analysis
- Pattern selection (violation → pattern)
- Target: COMPLIANT

## Architectural Impact
- Layers affected (Domain/Application/Infrastructure)
- Modules touched
- Change scope estimation (files to CREATE/MODIFY, LOC, complexity)
- Risk assessment

## Key Decisions
[Architecture decisions with rationale]
```

---

## Example: Complete Plan

The 4 OpenSpec files for `openspec/changes/user-authentication/`:

### proposal.md
```markdown
# User Authentication

## Problem
We need user authentication with email/password.

## Motivation
Users should register, login, and logout. Enables AC-002 for auth on write ops.

## Scope
**In**: Registration, login, logout, token management
**Out**: OAuth, social login, 2FA

## Success Criteria
1. User can register with unique email and password ≥8 chars
2. User can login and receive auth token
3. User can logout and invalidate token
```

### specs.md
```markdown
# Functional Specifications: user-authentication

## Requirements
- SPEC-F01: User can register with email and password
  - Email must be unique
  - Password must be ≥8 characters
- SPEC-F02: User can login with email and password
  - Returns authentication token on success
- SPEC-F03: User can invalidate their token

## Scenarios
GIVEN a new user with valid email and password
WHEN they submit registration
THEN account is created and confirmation returned

GIVEN a registered user with correct credentials
WHEN they submit login
THEN an authentication token is returned

## Integration Analysis
### Entities Impact
| Entity | Change Type | Details |
|--------|-------------|---------|
| User | NEW | Core auth entity |
| RefreshToken | NEW | Token management |
| Order | EXTENDED | Add `user_id` foreign key |

### API Contracts Impact
| Endpoint | Change Type | Details |
|----------|-------------|---------|
| POST /api/auth/register | NEW | User registration |
| POST /api/auth/login | NEW | User login |
| POST /api/auth/logout | NEW | User logout |
| POST /api/orders | MODIFIED | Require auth header |

### Business Rules Impact
| Rule | Type | Details |
|------|------|---------|
| BR-AUTH-01 | NEW | Email must be unique |
| BR-AUTH-02 | NEW | Password ≥8 characters |
| AC-002 | ENABLES | Auth now possible for write ops |

### Backward Compatibility
- Backward Compatible: YES (new endpoints, existing Order gets optional user_id)
- Migration Required: YES (add user_id to orders table)
```

### design.md
```markdown
# Technical Design: user-authentication

## Solution Approach

### Solution for SPEC-F01 & F02
**Patterns Selected**:
| Need | Pattern | SOLID |
|------|---------|-------|
| Email validation rules | Value Object | SRP |
| Password hashing strategies | Strategy | OCP |
| User persistence | Repository | DIP |
| Token generation | Factory Method | DIP |

**Class Design**:
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

## SOLID Analysis
- Baseline score: N/A (greenfield)
- Pattern selection: Value Object (SRP), Strategy (OCP), Repository (DIP), Factory Method (DIP)
- Target: COMPLIANT for all relevant principles

## Architectural Impact
### Layers Affected
| Layer | Impact | Files |
|-------|--------|-------|
| Domain | HIGH | 5 new files |
| Application | MEDIUM | 3 new files |
| Infrastructure | MEDIUM | 4 new files |
| Presentation | LOW | 1 new controller |

### Modules Touched
| Module | Files | Risk |
|--------|-------|------|
| src/Auth/ (NEW) | 12 | N/A |
| src/Order/ | 2 | LOW |
| config/ | 2 | LOW |

### Change Scope
- Files to CREATE: 14, Files to MODIFY: 4, Total: 18
- Complexity: MEDIUM

## Key Decisions
- Greenfield module: no existing auth to extend
- JWT tokens with refresh token rotation
```

---

## Summary: Architecture-First Planning

| Step/Phase | Content | Output File | SOLID? | Integration? |
|------------|---------|-------------|--------|--------------|
| **Step 0: Load Specs** | Existing architecture context | (context only) | ❌ No | ✅ **YES - CONTEXT** |
| Phase 1: Understand | Problem statement | `proposal.md` | ❌ No | ❌ No |
| **Phase 2: Specs** | Functional requirements (WHAT) | `specs.md` | ❌ No | ✅ **YES - ANALYSIS** |
| **Phase 3: Design** | Technical design (HOW) | `design.md` | ✅ **YES - MANDATORY** | ✅ **YES - IMPACT** |
| Phase 4: Tasks | Task breakdown + verify + state | `tasks.md` | ❌ No | ❌ No |

**SOLID is a design CONSTRAINT in Phase 3, not a functional SPEC in Phase 2.**

**Integration analysis ensures every feature is designed as an EXTENSION of existing architecture, not an isolated solution.**

### The Integration Mindset

```
❌ WRONG: "I'll create a new User service for authentication"
✅ RIGHT: "I'll EXTEND the existing architecture with User entity,
          MODIFY Order to require auth, and CREATE 3 new endpoints"
```

Every planning session should answer:
1. What EXISTING specs will this feature EXTEND?
2. What EXISTING specs will this feature MODIFY?
3. What NEW specs will this feature CREATE?
4. Are there any CONFLICTS with existing specs?
5. What is the ARCHITECTURAL IMPACT (layers, modules, files)?

---

## Related Commands

- `/workflow-skill:criteria-generator` - Generate functional specs
- `/workflow-skill:solid-analyzer` - Analyze SOLID compliance
- `/workflow-skill:spec-analyzer` - Validate specs and detect conflicts
- `/workflows:work` - Execute the plan
- `/workflows:review` - Review implementation

## Related Documentation

- `core/architecture-reference.md` - Violation → Pattern mapping and quality metrics
- `skills/workflow-skill-solid-analyzer.md` - SOLID analysis tool

## Project Specs Location (BASELINE — read-only)

```
openspec/specs/
├── entities/                  # Domain entities YAML specs
│   ├── user.yaml
│   ├── order.yaml
│   └── product.yaml
├── api-contracts/             # API endpoint contracts
│   ├── users.yaml
│   ├── orders.yaml
│   └── products.yaml
├── business-rules/            # Domain logic constraints
│   └── rules.yaml
└── architectural-constraints/ # System boundaries
    └── constraints.yaml
```

## Active Changes Location

```
openspec/changes/${FEATURE_ID}/
├── proposal.md   # Phase 1: Problem + motivation + scope + criteria
├── specs.md      # Phase 2: Requirements + Gherkin + Integration Analysis
├── design.md     # Phase 3: Solutions + SOLID + Architectural Impact
└── tasks.md      # Phase 4: Tasks + verify conditions + Workflow State
```
