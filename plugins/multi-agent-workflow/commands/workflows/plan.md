---
name: workflows:plan
description: "Convert ideas into implementable strategies with detailed planning. The foundation of compound engineering (80% planning, 20% execution)."
argument_hint: <feature-name> [--workflow=default|task-breakdown] [--show-impact=true|false] [--speed=fast|standard]
---

# Multi-Agent Workflow: Plan

The planning phase is the foundation of compound engineering. Invest 80% of effort here.

## Flow Guard (prerequisite check)

```
PREREQUISITE CHECK:
  1. Was this request routed via /workflows:route?
     - YES: Continue to planning
     - NO: STOP. Run /workflows:route first, then return here.

  2. If tasks.md exists in openspec/changes/{slug}/ for this feature, is this a continuation?
     - YES (planner = IN_PROGRESS): Resume planning from last checkpoint
     - YES (planner = COMPLETED): Plan already exists. Confirm re-planning with user.
     - NO: Fresh start, proceed normally.
```

## Usage

```
/workflows:plan user-authentication
/workflows:plan payment-system --workflow=task-breakdown
/workflows:plan order-management --show-impact=true
/workflows:plan quick-feature --speed=fast
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--workflow` | `default` | Workflow type: `default` or `task-breakdown` |
| `--show-impact` | depth-dependent | Show integration impact analysis (default: true for full, false for standard/minimal) |
| `--speed` | from providers.yaml | Planning speed: `fast` or `standard` (overrides `providers.planning_speed`) |

## Philosophy

> "Each unit of engineering work should make subsequent units easier -- not harder"

Good planning means:
- Engineers can start WITHOUT asking questions
- Solutions are designed with SOLID compliance from the start
- API contracts are complete enough to mock
- Every task has clear "definition of done"

---

## Planning Resolution (EXECUTE FIRST)

Before any planning work, resolve TWO settings from `core/providers.yaml`:

### 1. Planning Depth

```
READ core/providers.yaml -> providers.planning_depth

IF "auto":
  Complexity from /workflows:route == "complex" -> full
  Complexity from /workflows:route == "medium"  -> standard
  Complexity from /workflows:route == "simple"  -> minimal

IF explicit: Use the specified value (full | standard | minimal)
```

### 2. Planning Speed

```
READ core/providers.yaml -> providers.planning_speed
Override with --speed flag if provided.

IF "fast":  Inline analysis, skip forked skills, auto-advance HITL checkpoints
IF "standard": Full Quality Gates, HITL checkpoints, forked skills per fork_strategy
```

### Resolution Matrix (depth x speed)

| Depth | Speed | Phases | QG Iterations | Step 0 Files | Show Impact | HITL | Forked Skills |
|-------|-------|--------|---------------|-------------|-------------|------|---------------|
| **minimal** | standard | 1 + 4 | 1 | 1 file | no | no | none |
| **minimal** | fast | 1 + 4 | 1 | 1 file | no | no | none |
| **standard** | standard | 1-4 | 2 | 2 files | no | yes | per fork_strategy |
| **standard** | fast | 1-4 | 1 | 2 files | no | no | none (inline) |
| **full** | standard | 1-4 + impact | 3 | 5 files | yes | yes | per fork_strategy |
| **full** | fast | 1-4 + impact | 2 | 2 files | yes | no | none (inline) |

---

## Quality Gate Protocol (depth-adaptive)

Each planning phase ends with a Quality Gate. The max iterations depend on depth:

```
READ core/providers.yaml -> thresholds.quality_gate_max_iterations[planning_depth]

QUALITY GATE (max N iterations, where N = depth-dependent):
  iteration = 0
  while iteration < N:
    Step 0 (Reflection): State 3 things that could be wrong
    Run phase-specific checks (see each phase file)
    IF all checks pass -> WRITE file, advance to next phase
    IF any check fails -> log which failed, revise, iteration += 1

  IF N iterations exhausted:
    WRITE best version with "## Quality Warnings" section
    ADVANCE to next phase
```

---

## MANDATORY: Incremental Persistence Protocol

> **CRITICAL RULE**: Every planning phase MUST write its output to disk IMMEDIATELY upon completion, BEFORE starting the next phase.

| Phase | Output File | Extra Steps |
|-------|------------|-------------|
| Step 0 | (none -- context only) | UPDATE tasks.md: Step 0 -> COMPLETED |
| Phase 1 | `proposal.md` | -- |
| Phase 2 | `specs.md` | RUN Integration Analysis pre-hook before generating |
| Phase 3 | `design.md` | -- |
| Phase 4 | Update `tasks.md` | APPEND summary to `proposal.md`, proceed to Completeness Verification |

---

## Shaping Integration (Optional Pre-Phase)

If `/workflows:shape` was run before planning, these artifacts accelerate planning:

| File | How Planner Uses It |
|------|---------------------|
| `01_shaped_brief.md` | Accelerates Phase 1 (use Frame as problem statement) and Phase 2 (use Requirements as spec foundation) |
| `02_breadboard.md` | Informs Phase 3 design with concrete mechanisms |
| `03_slices.md` | Becomes task group structure in Phase 4 |
| `spike-*.md` | Context for design decisions |

---

## Phase Execution (Progressive Loading)

Execute phases based on resolved `planning_depth`. Each phase's full instructions are in separate files for progressive context loading.

### Phase Dispatcher

```
RESOLVED: planning_depth, planning_speed

IF planning_depth == "minimal":
  1. LOAD plan-phases/step0-context.md   -> Execute Step 0 (minimal scope)
  2. LOAD plan-phases/phase1-understand.md -> Execute Phase 1
  3. LOAD plan-phases/phase4-tasks.md     -> Execute Phase 4
  DONE.

IF planning_depth == "standard":
  1. LOAD plan-phases/step0-context.md   -> Execute Step 0 (standard scope)
  2. LOAD plan-phases/phase1-understand.md -> Execute Phase 1
  3. LOAD plan-phases/phase2-specs.md     -> Execute Phase 2 (--show-impact=false unless overridden)
  4. LOAD plan-phases/phase3-design.md    -> Execute Phase 3 (skip Step 3.5 impact analysis)
  5. LOAD plan-phases/phase4-tasks.md     -> Execute Phase 4
  DONE.

IF planning_depth == "full":
  1. LOAD plan-phases/step0-context.md   -> Execute Step 0 (full scope)
  2. LOAD plan-phases/phase1-understand.md -> Execute Phase 1
  3. LOAD plan-phases/phase2-specs.md     -> Execute Phase 2 (--show-impact=true by default)
  4. LOAD plan-phases/phase3-design.md    -> Execute Phase 3 (full: impact + security analysis)
  5. LOAD plan-phases/phase4-tasks.md     -> Execute Phase 4
  DONE.
```

### Fast Mode Shortcuts (when planning_speed=fast)

When `planning_speed=fast`, apply these optimizations across ALL phases:

1. **Skip forked skills**: Perform solid-analyzer and spec-analyzer checks inline (no `context: fork`)
2. **Auto-advance HITL**: Skip Phase 2->3 user checkpoint (auto-advance)
3. **Combine Phase 1+2**: When depth is standard, generate proposal.md and specs.md in a single pass
4. **Reduce QG iterations**: Use `quality_gate_max_iterations` from providers.yaml (1 for standard+fast)
5. **Default --show-impact=false**: Unless explicitly set to true via flag

---

## Key Distinction (Phase 2 vs Phase 3)

| Phase 2: SPECS | Phase 3: SOLUTIONS |
|----------------|-------------------|
| **WHAT** it must do | **HOW** to do it |
| Functional requirements | Technical design |
| "User can register" | "Use Strategy pattern for validators" |
| From user/business | From developer/architect |

**SOLID is a design CONSTRAINT in Phase 3, not a functional SPEC in Phase 2.**

---

## Output Files

```
openspec/changes/${FEATURE_ID}/
  proposal.md     # Phase 1: Problem statement, motivation, scope, success criteria
  specs.md        # Phase 2: Functional specs (WHAT) + Integration Analysis + Test Contract Sketch
  design.md       # Phase 3: Solutions + SOLID + Architectural Impact (HOW)
  tasks.md        # Phase 4: Task breakdown + verify conditions + Workflow State + Decision Log
  scratchpad.md   # Runtime: Working notes, hypotheses, context breadcrumbs (ephemeral)
```

Files produced by depth:

| Depth | proposal.md | specs.md | design.md | tasks.md |
|-------|-------------|----------|-----------|----------|
| minimal | YES | NO | NO | YES |
| standard | YES | YES | YES | YES |
| full | YES | YES | YES | YES |

---

## Chunking Directive

| Phase | Max output | Action if exceeded |
|-------|-----------|-------------------|
| Phase 1 (proposal.md) | ~200 lines | Split into problem + appendix |
| Phase 2 (specs.md) | ~300 lines | Group by domain boundary |
| Phase 3 (design.md) | ~400 lines | Split into core + appendix |
| Phase 4 (tasks.md) | ~200 lines | Use task IDs, concise descriptions |

---

## Error Recovery

- **Phase output fails to write**: Retry. If persists, write to `/tmp/openspec-${FEATURE_ID}/`.
- **Quality Gate fails after max iterations**: Document blocker in `tasks.md`, mark BLOCKED, present to user.
- **Spec conflicts in Phase 2**: Log with `[CONFLICT]` tag. Do not proceed to Phase 3 until resolved.
- **HITL rejected**: Return to previous phase, incorporate feedback, re-run phase.
- **Session interrupted**: Read `tasks.md` Planning Progress, verify last file, continue from next phase.

---

## Planning Checklist

| Phase | Must Have |
|-------|----------|
| Step 0 | Specs loaded, architecture context understood |
| Phase 1 | Problem documented, constraints identified |
| Phase 2 | Testable specs (WHAT not HOW), integration analysis (if applicable) |
| Phase 3 | SOLID baseline, patterns selected, all principles COMPLIANT |
| Final | Engineer can start WITHOUT asking questions |

---

## Related Commands

- `/workflow-skill:criteria-generator` - Generate functional specs
- `/workflow-skill:solid-analyzer` - Analyze SOLID compliance
- `/workflow-skill:spec-analyzer` - Validate specs and detect conflicts
- `/workflows:work` - Execute the plan
- `/workflows:review` - Review implementation

## Related Documentation

- `core/architecture-reference.md` - Violation -> Pattern mapping
- `skills/workflow-skill-solid-analyzer.md` - SOLID analysis tool
- `core/providers.yaml` - Planning depth, speed, and threshold configuration
