---
name: workflows:work
description: "Execute implementation with configurable parallelization modes and execution mode (agent-executes, human-guided, or hybrid)."
argument_hint: <feature-name> --mode=<roles|layers|stacks> [--role=<role>] [--layer=<layer>] [--exec=auto|agent|human|hybrid]
---

# Multi-Agent Workflow: Work

Execute implementation with the compound engineering principle: make each unit of work easier.

## Flow Guard (prerequisite check)

Before executing, verify the flow has been followed:

```
PREREQUISITE CHECK:
  1. Does 50_state.md exist for this feature?
     - NO: STOP. Run /workflows:plan first.

  2. Is planner status = COMPLETED in 50_state.md?
     - NO (PENDING or IN_PROGRESS): STOP. Planning not finished. Run /workflows:plan.
     - NO (BLOCKED): STOP. Planning is blocked. Resolve blocker first.
     - YES: Continue to work.

  3. Does the role's status allow starting work?
     - PENDING: OK, start work (set to IN_PROGRESS)
     - IN_PROGRESS: OK, resume work from last checkpoint
     - COMPLETED: Work already done. Confirm re-work with user.
     - BLOCKED: Show blocker details, ask user how to proceed.

  If checks 1 or 2 fail, do NOT proceed. Plan first.
```

## Automatic Operations (built into this command)

The following are executed automatically as part of `/workflows:work`:
- **Git sync** (Step 2) -- pulls latest changes before starting
- **Solution Validation** (Step 4.5) -- validates approach before TDD cycle
- **TDD enforcement** (Step 5) -- Red-Green-Refactor cycle
- **SOLID verification** (Step 7) -- checks score at each checkpoint
- **Bounded Correction Protocol** (Step 6) -- auto-corrects with scale-adaptive limits
- **Checkpoint** (Step 7) -- saves progress + commits after each logical unit
- **Snapshot** -- triggered when context exceeds 70% capacity

You do NOT need to invoke these separately.

## Usage

```bash
# By Role (standard)
/workflows:work user-auth --mode=roles --role=backend
/workflows:work user-auth --mode=roles --role=frontend

# By Layer (DDD)
/workflows:work user-auth --mode=layers --layer=domain
/workflows:work user-auth --mode=layers --layer=application
/workflows:work user-auth --mode=layers --layer=infrastructure

# By Stack
/workflows:work user-auth --mode=stacks --stack=backend
/workflows:work user-auth --mode=stacks --stack=frontend
```

## Execution Mode Resolution

Before executing tasks, resolve the execution mode:

` ` `
1. READ core/providers.yaml → providers.execution_mode

2. IF "auto":
   ├── Is the task in a LOW trust area (auth/, security/, payment/)?
   │   YES → hybrid (agent generates, human reviews)
   │
   ├── Does the task have a "Reference" file in 30_tasks.md?
   │   YES → agent-executes (pattern exists to follow)
   │
   └── OTHERWISE → agent-executes (default)

3. IF --exec flag passed → override (session only)
` ` `

### Agent Executes (default)

The agent generates code following the plan. For each task in `30_tasks.md`:

` ` `
TASK EXECUTION LOOP:
  1. READ task (acceptance criteria, SOLID requirements, reference file)
  2. READ reference file to learn existing pattern
  3. WRITE test FIRST (TDD Red) — Write tool creates test file
  4. RUN tests → confirm failure (test-runner)
  5. WRITE implementation following pattern — Write/Edit tools
  6. RUN tests (test-runner)
  7. IF fail → analyze + fix (BCP, max 10 iterations)
  8. CHECK SOLID (solid-analyzer) — must meet task thresholds
  9. FIX lint (lint-fixer)
  10. CHECKPOINT → update 50_state.md
  11. → Next task
` ` `

### Human Guided

The agent presents each task with detailed instructions. The human implements. The agent verifies with test-runner and solid-analyzer.

### Hybrid

Same as agent-executes, but pauses before each checkpoint:
` ` `
After step 9 (lint fixed, tests passing):
  → Present generated code to human
  → Wait for: [Accept] [Modify] [Reject]
  → Accept: proceed to checkpoint
  → Modify: incorporate changes, re-run tests
  → Reject: regenerate with human feedback
` ` `

## Parallelization Modes

### Mode: Roles (Standard)
```
Planner → Backend + Frontend (parallel) → QA
```

**Roles available**: `backend`, `frontend`

**Best for**:
- Full-stack features with separate concerns
- Teams with distinct frontend/backend developers
- Standard feature development

### Mode: Layers (DDD)
```
Domain + Application + Infrastructure (can run parallel)
```

**Layers available**: `domain`, `application`, `infrastructure`

**Best for**:
- Complex business logic
- Backend-heavy features
- DDD architecture compliance

### Mode: Stacks
```
Backend complete + Frontend complete (parallel)
```

**Stacks available**: `backend`, `frontend`

**Best for**:
- Independent features
- Separate deployment pipelines
- Large features with clear boundaries

## Execution Flow

### Step 1: Load Context

```bash
# Based on mode, load appropriate agent
--mode=roles --role=backend → Read: agents/roles/backend.md
--mode=roles --role=frontend → Read: agents/roles/frontend.md
--mode=layers --layer=domain → Read: agents/roles/backend.md + rules/ddd_rules.md
```

### Step 2: Git Sync

```bash
git pull origin feature/${FEATURE_ID} || git pull origin main
```

### Step 3: Load Feature Context

```bash
Read: .ai/project/features/${FEATURE_ID}/50_state.md
Read: .ai/project/features/${FEATURE_ID}/FEATURE_*.md
Read: .ai/project/features/${FEATURE_ID}/30_tasks.md
```

### Step 4: Verify Prerequisites

**For Roles mode**:
- Check Planner status is COMPLETED
- If `frontend`: Check if backend API ready or mock needed

**For Layers mode**:
- Domain: Can start immediately
- Application: Domain should be COMPLETED (or mock)
- Infrastructure: Application should be COMPLETED

### Step 4.5: Solution Validation (Pre-Implementation Check)

Before starting the TDD cycle for each task, validate the approach is sound:

```
SOLUTION VALIDATION (for each task in 30_tasks.md):

1. REFERENCE CHECK: Does a reference file exist for this task?
   - YES: Read reference file. Confirm approach follows the same pattern.
   - NO: Check 15_solutions.md for architectural guidance. Confirm alignment.

2. INTEGRATION CHECK: Will this conflict with completed checkpoints?
   - Read completed checkpoints in 50_state.md
   - Verify interfaces match (DTO shapes, method signatures, API contracts)
   - If conflict detected → STOP. Consult planner before proceeding.

3. DECISION CHECK: Is approach consistent with DECISIONS.md?
   - Read DECISIONS.md for relevant architectural decisions
   - If approach contradicts a decision → STOP. Consult planner.

4. COMPLEXITY ASSESSMENT: Resolve max_iterations for this task
   - Read task complexity from 30_tasks.md (or infer from scope)
   - Set max_iterations from providers.yaml correction_limits
   - simple: 5, moderate: 10, complex: 15

If ALL checks pass → proceed to TDD (Step 5)
If ANY check fails → escalate to planner with specific conflict details
```

This step prevents wasting TDD iterations on an architecturally flawed approach.

### Step 5: Execute with TDD + SOLID

Execution behavior depends on the resolved execution mode (see Execution Mode Resolution above).

**In `agent-executes` mode** (default), the agent performs all steps autonomously following the Task Execution Loop. The TDD cycle is executed directly by the agent using Write, Edit, and tool invocations.

**In `human-guided` mode**, the agent presents each task with detailed instructions, acceptance criteria, and reference patterns. The human engineer performs the TDD cycle manually. The agent verifies results with test-runner and solid-analyzer after each task.

**In `hybrid` mode**, the agent executes autonomously but pauses before each checkpoint for human review (Accept / Modify / Reject).

Regardless of mode, follow the TDD cycle for each task, ensuring SOLID compliance:

```
1. 🔴 RED: Write test FIRST (must fail)
2. 🟢 GREEN: Write minimum code to pass
3. 🔵 REFACTOR: Improve while keeping tests green
4. ✅ SOLID: Verify code follows SOLID patterns from 15_solutions.md
```

**SOLID Verification During Implementation**:

```bash
# After each logical unit, verify SOLID compliance
/workflow-skill:solid-analyzer --path=src/modified-path

# Must match expected score from 15_solutions.md
# If score < expected, refactor before proceeding
```

### Step 6: Bounded Auto-Correction Protocol

Detects and corrects three types of deviations (not just test failures):

```python
iterations = 0
MAX_ITERATIONS = 10  # Resolved from providers.yaml correction_limits

while (tests_failing or deviation_detected) and iterations < MAX_ITERATIONS:
    classify_deviation()

    if TYPE_1_TEST_FAILURE:
        analyze_error()
        fix_code()          # NEVER fix the test
    elif TYPE_2_MISSING_FUNCTIONALITY:
        compare_vs_acceptance_criteria()  # from 30_tasks.md
        add_missing_implementation()
    elif TYPE_3_INCOMPLETE_PATTERN:
        compare_vs_reference_file()       # from task definition
        complete_pattern()

    run_verification()    # tests + acceptance criteria check
    iterations += 1

if all_verified:
    checkpoint_complete()
else:
    document_blocker(deviation_type, attempts_per_type)
    mark_blocked()
```

**Deviation Types:**
- **TYPE 1 — Test Failure**: Tests fail → fix implementation
- **TYPE 2 — Missing Functionality**: Tests pass but acceptance criteria unmet → add implementation
- **TYPE 3 — Incomplete Pattern**: Implementation doesn't follow reference file → complete pattern

### Step 7: Checkpoint (includes SOLID verification)

After each logical unit:

```bash
# 1. Verify SOLID score
/workflow-skill:solid-analyzer --path=src/modified-path

# 2. Only checkpoint if SOLID score meets expected
/workflows:checkpoint ${ROLE} ${FEATURE_ID} "Completed ${UNIT}"
```

**Checkpoint SOLID Requirements**:

| Checkpoint Type | SOLID Requirement |
|-----------------|-------------------|
| Domain layer | SRP, DIP must score ≥4/5 |
| Application layer | SRP, OCP must score ≥4/5 |
| Infrastructure | DIP must score ≥4/5 |
| Full feature | Total score must be ≥18/25 |

## Role-Specific Workflows

### Backend Workflow (Layers: domain → application → infrastructure)

```markdown
Checkpoint 1: Domain Layer
- Entities, Value Objects
- Verification: php bin/phpunit tests/Unit/Domain/
- Coverage: >80%
- **SOLID**: SRP ≥4/5, DIP ≥4/5 (no infrastructure imports)
- Run: /workflow-skill:solid-analyzer --path=src/Domain

Checkpoint 2: Application Layer
- Use Cases, DTOs
- Verification: php bin/phpunit tests/Unit/Application/
- Coverage: >80%
- **SOLID**: SRP ≥4/5, OCP ≥4/5
- Run: /workflow-skill:solid-analyzer --path=src/Application

Checkpoint 3: Infrastructure Layer
- Repositories, Controllers
- Verification: php bin/phpunit tests/Integration/
- Schema validation
- **SOLID**: DIP ≥4/5 (implements interfaces from Domain)
- Run: /workflow-skill:solid-analyzer --path=src/Infrastructure

Checkpoint 4: API Endpoints
- REST endpoints
- Verification: curl tests, API contract validation
- **SOLID Total**: Must achieve ≥18/25 overall
- Run: /workflow-skill:solid-analyzer --path=src --validate
```

### Frontend Workflow

```markdown
Checkpoint 1: Component Structure
- TypeScript types, component skeleton
- Verification: npm run type-check

Checkpoint 2: Form Logic
- Validation, event handlers
- Verification: npm test -- ComponentName

Checkpoint 3: API Integration
- Real API or mocks
- Verification: Integration tests

Checkpoint 4: Responsive Design
- Mobile (375px), Tablet (768px), Desktop (1024px)
- Verification: Visual inspection

Checkpoint 5: Accessibility
- Lighthouse score >90
- Verification: npm run lighthouse
```

## State Updates

Update `50_state.md` at each checkpoint:

```markdown
## Backend Engineer
**Status**: IN_PROGRESS
**Checkpoint**: Domain layer complete
**Timestamp**: 2026-01-16T14:30:00Z
**Tests**: 15/15 passing, 92% coverage
**SOLID Score**: 21/25 (SRP: 5, OCP: 4, LSP: 4, ISP: 4, DIP: 4)
**Iterations**: 3

### Resume Information
- **Completed**: User entity, Email VO
- **Next Task**: CreateUserUseCase (BE-005)
- **Files to Read on Resume**:
  - 30_tasks.md (Task BE-005)
  - src/Domain/Entity/User.php
- **SOLID Notes**: DIP verified - no infrastructure imports in Domain
```

## Escape Hatch

If blocked after max iterations:

```markdown
## Blocker: [Task Name]

**Deviation type**: TYPE 1 | TYPE 2 | TYPE 3
**Iterations attempted**: [N] (Type 1: X, Type 2: Y, Type 3: Z)
**Last error/gap**: [exact error or unmet criterion]

**What was tried per deviation type**:
- TYPE 1 (test failures): [approaches tried]
- TYPE 2 (missing functionality): [gaps identified and attempted]
- TYPE 3 (incomplete patterns): [reference comparisons made]

**Root cause hypothesis**: [Why failing]

**Suggested alternatives**:
1. [Alternative 1]
2. [Alternative 2]

**Status**: BLOCKED - Needs Planner decision
```

## Verification Commands

### Backend
```bash
php bin/phpunit                          # All tests
php bin/phpunit --coverage-text          # Coverage check
./vendor/bin/php-cs-fixer fix --dry-run  # Style check
```

### Frontend
```bash
npm test                    # All tests
npm test -- --coverage      # Coverage check
npm run lint               # Linting
npm run type-check         # TypeScript
```

## Compound Effect

Good work execution compounds:
- TDD prevents regressions
- Checkpoints enable session resumption
- Documentation helps onboarding
- Tests become living specifications
