# AI Workflow Knowledge Base

> Single source of truth for the Multi-Agent Workflow Plugin methodology. All reference documentation consolidated here.

**Version**: 2.0.0
**Created**: 2026-02-24
**Updated**: 2026-02-25

---

## Table of Contents

- [§1 Ecosystem Map](#1-ecosystem-map)
- [§2 Methodology Contributions](#2-methodology-contributions)
- [§3 The Integrated Workflow — 7 Phases](#3-the-integrated-workflow--7-phases)
- [§4 Complexity Levels L1-L4](#4-complexity-levels-l1-l4)
- [§5 Decision Matrix](#5-decision-matrix)
- [§6 Karpathy Principles](#6-karpathy-principles)
- [§7 Context Engineering](#7-context-engineering)
- [§8 Session Continuity & Ralph Discipline](#8-session-continuity--ralph-discipline)
- [§9 Capability Providers](#9-capability-providers)
- [§10 Validation Learning](#10-validation-learning)
- [§11 MCP Integration](#11-mcp-integration)
- [§12 Cross-Cutting Concepts](#12-cross-cutting-concepts)
- [§13 Compound Memory Architecture](#13-compound-memory-architecture)
- [§14 The 70% Problem (Osmani)](#14-the-70-problem-osmani)
- [§15 When to Use What](#15-when-to-use-what)
- [§16 Plugin Architecture Summary](#16-plugin-architecture-summary)
- [§17 Source References](#17-source-references)

---

## §1 Ecosystem Map

This workflow integrates ideas from 8+ distinct methodologies:

```
┌─────────────────────────────────────────────────────────────────┐
│                    METHODOLOGY ECOSYSTEM                         │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ COMPOUND          │  │ SHAPE UP          │  │ KARPATHY      │ │
│  │ ENGINEERING       │  │ (Singer)          │  │ PRINCIPLES    │ │
│  │                   │  │                   │  │               │ │
│  │ Core loop:        │  │ Shaping phase:    │  │ Guardrails:   │ │
│  │ Plan→Work→Review  │  │ Frame→Spike→Scope │  │ Think first   │ │
│  │ →Compound         │  │ Appetite-based    │  │ Simplicity    │ │
│  │                   │  │ scoping           │  │ Surgical      │ │
│  │ Compounding       │  │                   │  │ Goal-driven   │ │
│  │ returns           │  │ Fat marker /      │  │               │ │
│  │                   │  │ breadboard        │  │               │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ SPEC-DRIVEN       │  │ CONTEXT           │  │ CODE FACTORY  │ │
│  │ DEVELOPMENT       │  │ ENGINEERING       │  │ PATTERNS      │ │
│  │ (OpenSpec/BMAD)   │  │ (Fowler)          │  │               │ │
│  │                   │  │                   │  │               │ │
│  │ Artifact pipeline:│  │ Activation        │  │ Risk tiers    │ │
│  │ proposal→specs→   │  │ taxonomy:         │  │ SHA discipline│ │
│  │ design→tasks      │  │ always, software, │  │ Deterministic │ │
│  │                   │  │ LLM, human        │  │ gates         │ │
│  │ Baseline freeze   │  │                   │  │ Harness loops │ │
│  │ Spec merge cycle  │  │ Fork strategy     │  │               │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ RALPH METHOD      │  │ GSD               │                    │
│  │                   │  │ (Get Shit Done)   │                    │
│  │ Session hygiene:  │  │                   │                    │
│  │ Anti-context-rot  │  │ Quick mode for    │                    │
│  │ State external.   │  │ simple tasks      │                    │
│  │ Deliberate        │  │ Deviation detect. │                    │
│  │ rotation          │  │ Goal-backward     │                    │
│  │                   │  │ verification      │                    │
│  └──────────────────┘  └──────────────────┘                    │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ ADDY OSMANI - 10 Pillars of LLM Development              │   │
│  │                                                            │   │
│  │ 1. Treat AI as junior dev    6. Verify everything          │   │
│  │ 2. Review every line         7. Test-driven development    │   │
│  │ 3. Start small, iterate      8. Document decisions         │   │
│  │ 4. Maintain understanding    9. Own the architecture       │   │
│  │ 5. Keep dependencies tight  10. Never skip code review     │   │
│  │                                                            │   │
│  │ The "70% Problem": AI gets you to 70% fast, but the       │   │
│  │ remaining 30% is where real complexity lives.              │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## §2 Methodology Contributions

| Methodology | Primary Contribution | Where It Lives |
|---|---|---|
| **Compound Engineering** | Core loop (Plan→Work→Review→Compound), compounding returns | `compound.md`, compound-memory |
| **Shape Up (Singer)** | Shaping phase, appetite-based scoping, breadboards | `shape.md`, `shaper/`, `breadboarder/` |
| **Karpathy Principles** | Think before coding, simplicity first, surgical changes, goal-driven | §6 below |
| **Spec-Driven Dev (OpenSpec)** | Artifact pipeline, baseline freeze, spec merge cycle | `plan.md`, `spec-merger/`, `openspec/` |
| **BMAD Method** | Scale-adaptive limits, adversarial self-review, BCP | `testing-rules.md`, BCP in `work.md` |
| **Context Engineering (Fowler)** | Activation taxonomy, fork strategy, context budget | §7 below |
| **Code Factory** | Risk tiers, deterministic gates, policy enforcement | `policy-gate/`, `security-rules.md` |
| **Ralph Method** | Anti-context-rot, state externalization, deliberate rotation | §8 below |
| **GSD** | Quick mode, deviation detection, goal-backward verification | `quick.md`, BCP deviation types |
| **Addy Osmani** | The 70% Problem, 10 pillars, comprehension debt | §14 below |

### Cross-Methodology Synergies

```
Compound x Shape Up = Shape BEFORE Plan (explore unknowns, then compound learnings)
Karpathy x Context Eng. = Think before coding + strategic context calibration
SDD x Compound = Feature specs merge into baseline (spec-merger in compound phase)
BMAD x GSD = Scale-adaptive BCP limits + quick mode escape to full workflow
Ralph x Context Eng. = State externalization + fork strategy prevent context rot
Code Factory x Security Rules = Risk tiers inform trust model and HITL checkpoints
Osmani x Compound = 70% boundary analysis feeds compound memory for next feature
```

---

## §3 The Integrated Workflow — 7 Phases

```
Phase 0: ROUTE    -> Classify, question, select workflow
Phase 0b: QUICK   -> Lightweight path (<=3 files, no arch impact)
Phase 1: SHAPE    -> Separate problem from solution (optional)
Phase 2: PLAN     -> Architecture-first with SOLID constraint
Phase 3: WORK     -> TDD + Bounded Correction Protocol
Phase 4: REVIEW   -> Multi-agent quality review + validation learning
Phase 5: COMPOUND -> Extract patterns, update specs, brief next feature
```

### Time Distribution

```
PLAN ████████████████████████████████████████  80%
WORK ████████                                  15%
REVIEW ██                                       4%
COMPOUND █                                      1%

When planning is thorough, implementation is fast.
```

---

## §4 Complexity Levels L1-L4

Every request is classified into one of 4 complexity levels.

### L1: Trivial (Quick Mode)

| Attribute | Value |
|---|---|
| **Scope** | 1-3 files, no architecture impact |
| **Duration** | < 30 minutes |
| **Phases** | ROUTE -> QUICK |
| **Artifacts** | Quick task log entry only |
| **Guards** | No sensitive paths (auth/, security/, payment/) |
| **BCP limit** | 5 iterations |
| **Examples** | Fix typo, rename variable, update dependency, add field |

### L2: Simple (Default Workflow)

| Attribute | Value |
|---|---|
| **Scope** | 4-10 files, single component/layer |
| **Duration** | 1-4 hours |
| **Phases** | ROUTE -> PLAN (default) -> WORK -> REVIEW |
| **Artifacts** | proposal.md, specs.md, design.md, tasks.md |
| **Guards** | Standard flow guards |
| **BCP limit** | 5 iterations |
| **Examples** | Bug fix, simple feature, single-layer refactor |

### L3: Moderate (Task-Breakdown Workflow)

| Attribute | Value |
|---|---|
| **Scope** | 10-30 files, multiple components/layers |
| **Duration** | 4-16 hours (may span sessions) |
| **Phases** | ROUTE -> PLAN (task-breakdown) -> WORK -> REVIEW -> COMPOUND |
| **Artifacts** | Full SDD pipeline + compound capture |
| **Guards** | Full flow guards + HITL checkpoints |
| **BCP limit** | 10 iterations |
| **Examples** | Multi-layer feature, API + frontend, integration |

### L4: Complex (Shape-First Workflow)

| Attribute | Value |
|---|---|
| **Scope** | 30+ files, architectural change, unknowns |
| **Duration** | 16+ hours (multi-session) |
| **Phases** | ROUTE -> SHAPE -> PLAN (task-breakdown) -> WORK -> REVIEW -> COMPOUND |
| **Artifacts** | Shaped brief + breadboard + full SDD + compound + retrospective |
| **Guards** | All guards + shaping verification + security review |
| **BCP limit** | 15 iterations |
| **Examples** | New domain, migration, auth system, payment integration |

### Level Selection Signal Matrix

| Signal | L1 | L2 | L3 | L4 |
|---|---|---|---|---|
| Files affected | 1-3 | 4-10 | 10-30 | 30+ |
| Components | 1 | 1 | 2-3 | 4+ |
| New entities | 0 | 0-1 | 1-3 | 3+ |
| External APIs | 0 | 0 | 0-1 | 1+ |
| Dimensional change | No | No | Maybe | Yes |
| Unknowns | None | None | Few | Many |
| Sensitive paths | No | Maybe | Maybe | Likely |
| Multi-session | No | No | Maybe | Yes |

### Escalation Rules

- If **any** signal exceeds the level's threshold, escalate to the next level
- Dimensional changes always force at least L3 (task-breakdown)
- Sensitive paths (auth/, security/, payment/) with unknowns always force L4
- Quick Mode (L1) can escalate mid-execution if scope grows beyond 3 files

### Clarifying Question Templates

**For Features:** Can you describe the functionality in 2-3 sentences? Who will use it? Backend, frontend, or both? External APIs? Sensitive data?

**For Bugs:** What happens now vs expected? Reproducible? Intermittent? Error messages?

**For Refactoring:** Which files/modules? Why needed? Existing tests?

### Confidence Scoring

| Signal | Points |
|---|---|
| Contains keyword from need type | +20 |
| Contains file/function reference | +15 |
| Mentions specific technology | +10 |
| Clear action verb (add, fix, remove) | +15 |
| Describes expected behavior | +20 |
| Mentions error/bug explicitly | +20 |
| Is a question | -30 (for work classification) |
| Vague/ambiguous language | -25 |

**Thresholds**: >= 60 HIGH (proceed), 30-59 MEDIUM (confirm), < 30 LOW (ask questions).

### Self-Correction Protocol

1. Pause current work
2. Ask clarifying questions now
3. Confirm workflow selection with user
4. Continue with proper context

### Router Verification Checklist

- [ ] Was the work type clearly identified?
- [ ] Were clarifying questions asked if needed?
- [ ] Is the chosen workflow appropriate for the task?
- [ ] Has trust level been considered for sensitive areas?

---

## §5 Decision Matrix

### Quick Reference Card

```
NEW FEATURE
   Simple (< 2h)     -> /workflows:plan --workflow=default
   Complex (> 2h)    -> /workflows:plan --workflow=task-breakdown

BUG FIX
   Reproducible      -> diagnostic-agent -> implementation-only
   Intermittent      -> codebase-analyzer

REFACTORING
   Localized         -> /workflows:work (direct)
   Systemic          -> /workflows:plan --workflow=task-breakdown

INVESTIGATION       -> codebase-analyzer agent
CODE REVIEW         -> /workflows:review
```

### By User Need Type

| Need Type | Indicators | Workflow | Command |
|---|---|---|---|
| **New Feature** | "add", "implement", "create" | task-breakdown | `/workflows:plan --workflow=task-breakdown` |
| **Quick Feature** | "simple", "small change" | default | `/workflows:plan --workflow=default` |
| **Bug Fix** | "broken", "error", "fails" | implementation-only | `/workflows:plan --workflow=implementation-only` |
| **Refactor** | "refactor", "clean up" | Depends on scope | See §4 Escalation Rules |
| **Investigation** | "how does", "where is" | N/A | Invoke research agents |
| **Code Review** | "review", "validate" | N/A | `/workflows:review` |
| **Setup/Config** | "configure", "install" | N/A | Invoke consultant |

### By Complexity Assessment

| Complexity | Time | Files | Workflow | Planning Depth |
|---|---|---|---|---|
| Trivial | < 30 min | 1-2 | implementation-only | Minimal |
| Simple | 30 min - 2h | 3-5 | default | Basic |
| Medium | 2-8h | 5-15 | task-breakdown | Full |
| Complex | > 8h | 15+ | task-breakdown | Comprehensive |
| Architectural | Days/weeks | System-wide | task-breakdown + design agents | Deep analysis |

### By Dimensional Impact

| Dimensional Change | Complexity Impact | Minimum Workflow |
|---|---|---|
| No change | None | Per complexity assessment |
| Adds consumer diversity | Medium | task-breakdown |
| Adds data aggregation | High | task-breakdown + shape |
| Adds external vendor | Medium | task-breakdown |
| Introduces concurrency | Medium | task-breakdown |
| Multiple changes | Very High | shape + task-breakdown |

**Rule**: If a request increases dimensional complexity, escalate to at least task-breakdown.

### By Technology/Area Touched

| Area | Trust Level | Minimum Workflow | Additional Requirements |
|---|---|---|---|
| Tests only | HIGH | implementation-only | None |
| Documentation | HIGH | implementation-only | None |
| Config files | MEDIUM | default | Review before commit |
| Business logic | MEDIUM | task-breakdown | Tests required |
| API endpoints | MEDIUM | task-breakdown | Contract validation |
| Authentication | LOW | task-breakdown | Security review + pair |
| Payments | LOW | task-breakdown | Security review + pair |
| Infrastructure | LOW | task-breakdown | Full review required |
| Database migrations | LOW | task-breakdown | Rollback plan required |

### Workflow Selection Flowchart

```
                          USER REQUEST
                               |
                               v
                +--------------------------+
                | Question or work request?|
                +--------------------------+
                       |              |
                  QUESTION         WORK
                       |              |
                       v              v
                +----------+  +------------------+
                | Answer   |  | Clear what type? |
                | directly |  +------------------+
                +----------+        |         |
                                   YES        NO
                                    |         |
                                    |         v
                                    |   +----------------+
                                    |   | ASK CLARIFYING |
                                    |   | QUESTIONS      |
                                    |   +----------------+
                                    |         |
                                    v         v
                          +-------------------------+
                          |   CLASSIFY REQUEST       |
                          +-------------------------+
                                    |
                +-------+-----------+-----------+-------+
                v       v           v           v       v
           FEATURE    BUG      REFACTOR    RESEARCH  OTHER
                |       |           |           |       |
                v       v           v           v       v
           Evaluate  Evaluate   Evaluate    Invoke   Invoke
          complexity reproduc.  impact      agents  consultant
```

### Common Patterns

**"Continuing previous work"**: Check tasks.md -> determine next step -> continue existing workflow (don't re-route).

**"I don't know what I need"**: Invoke consultant skill -> exploratory questions -> propose options.

**"Just do it, I trust you"**: NEVER proceed without clarification. Ask minimal necessary questions.

**Golden Rule**: When in doubt, ask. It's faster to clarify than to redo.

---

## §6 Karpathy Principles

**Source**: Adapted from [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)

These principles address common AI failure modes: silent assumptions, overengineering, collateral damage, and vague results.

### Principle 1: Think Before Coding

**Problem**: LLMs make silent assumptions and proceed blindly when confused.
**Rule**: Before writing ANY code, explicitly state assumptions and clarify ambiguities.

**Required Actions:**
1. **State Assumptions Explicitly** -- list ALL assumptions about inputs, outputs, edge cases, dependencies
2. **Present Multiple Interpretations** -- when ambiguous, present 2-3 options and ask
3. **Push Back on Suboptimal Approaches** -- voice concerns, suggest alternatives
4. **Request Clarification When Confused** -- STOP and ask, never proceed with partial understanding

**Assumptions Template:**

```markdown
## Pre-Implementation Assumptions

**Request**: [What user asked for]

**My Assumptions**:
1. [Assumption about scope]
2. [Assumption about inputs]
3. [Assumption about expected behavior]
4. [Assumption about edge cases]
5. [Assumption about integration points]

**Potential Ambiguities**:
- [ ] [Ambiguity 1] - My interpretation: [X]

**Questions Before Proceeding**:
1. [Question about unclear requirement]

**Confidence Level**: [HIGH/MEDIUM/LOW]
```

### Principle 2: Simplicity First

**Problem**: LLMs overengineer solutions with unnecessary abstractions.
**Rule**: Implement ONLY what is explicitly requested. YAGNI is law.

**Required Actions:**
1. **Implement Only Requested Features** -- no "nice to have", no "future-proofing"
2. **Avoid Unnecessary Abstractions** -- no interfaces for single implementations
3. **Refuse Speculative Flexibility** -- no parameters "just in case"
4. **Apply the 50-Line Rule** -- if solvable in 50 lines, don't write 200

**Simplicity Checklist:**

```markdown
- [ ] Did I implement ONLY what was requested?
- [ ] Could this be done with fewer abstractions?
- [ ] Is every class/function/file necessary?
- [ ] Would a junior developer understand this immediately?
- [ ] Can I delete anything and still meet requirements?

Red Flags: interface for single implementation, configuration for non-configurable things,
utility class for one-time operation, code 3x longer than necessary
```

### Principle 3: Surgical Changes

**Problem**: LLMs make unnecessary changes to surrounding code.
**Rule**: Touch ONLY the code essential to the task. Preserve everything else.

**Required Actions:**
1. **Minimal Diff Principle** -- change only what's necessary
2. **Match Existing Style** -- follow conventions exactly
3. **Handle Unrelated Issues Carefully** -- MENTION dead code/bugs, don't fix them
4. **Preserve Working Code** -- if it works, don't touch it

**Surgical Changes Checklist:**

```markdown
- [ ] Every changed line is necessary for this task
- [ ] No "drive-by" improvements or cleanups
- [ ] Existing style conventions are preserved
- [ ] Only MY orphaned code was removed
```

### Principle 4: Goal-Driven Execution

**Problem**: Vague instructions lead to vague results.
**Rule**: Transform every request into testable success criteria before implementation.

**Required Actions:**
1. **Define Success Criteria First** -- write "done" before coding
2. **Transform Vague to Specific** -- "Fix the bug" -> "Write test that reproduces bug, make it pass"
3. **Create Verification Commands** -- every change gets a "how to test this"
4. **Iterate Toward Measurable Goals** -- run tests after each significant change

**Success Criteria Template:**

```markdown
**Request**: [Original user request]
**Testable Goals**:
1. [ ] [Specific criterion 1]
2. [ ] [Specific criterion 2]
**Verification**: `[command to verify]`
**Definition of Done**: All criteria pass + no regressions
```

### Integration with Workflow Phases

| Principle | Workflow Phase | Integration Point |
|---|---|---|
| Think Before Coding | ROUTE + PLAN | Pre-routing checklist, planning templates |
| Simplicity First | WORK | Self-review checklist, code review criteria |
| Surgical Changes | WORK | Pre-commit checklist, diff review |
| Goal-Driven Execution | PLAN + WORK | Success criteria in specs, TDD |

### Enhanced Self-Check Protocol

```markdown
Think Before Coding: Assumptions stated? Ambiguities clarified?
Simplicity First: Only what was requested? Minimum viable complexity?
Surgical Changes: Only essential code? No unrelated improvements?
Goal-Driven Execution: Success criteria defined? Testable acceptance criteria?
```

### Quick Reference

```
BEFORE CODING:  List assumptions, define success criteria, ask if confused
WHILE CODING:   Only what was asked, minimal changes, match existing style
BEFORE COMMIT:  Verify success criteria, check diff minimality, no drive-by improvements
```

---

## §7 Context Engineering

**Based on**: Fowler (Context Engineering for Coding Agents), Hightower (Build Agent Skills Faster)

### The Three Dimensions

#### 1. Content Types

| Type | Definition | Plugin Examples |
|---|---|---|
| **Instructions** | Direct behavioral rules | `CLAUDE.md`, routing rules, Karpathy principles |
| **Guides/Rules** | Reference material that shapes decisions | `framework_rules.md`, `architecture-reference.md` |
| **Interface Contexts** | Tools and capabilities | Skills, Commands, MCP servers, Review agents |

#### 2. Activation Methods

| Method | Who Decides | When | Examples |
|---|---|---|---|
| **Always loaded** | System | Every session start | `CLAUDE.md` (~118 lines), `framework_rules.md` (~370 lines) |
| **Scoped rules** | System | When matching file types edited | `testing-rules.md`, `security-rules.md`, `git-rules.md` |
| **LLM-determined** | The model | When judged relevant | Role definitions loaded when adopting a role |
| **Human-triggered** | The user | On explicit invocation | Slash commands, skills |
| **Software-determined** | The system | Automatic on events | Lifecycle hooks |

#### 3. Isolation Level

| Level | Mechanism | Impact on Parent | Use Case |
|---|---|---|---|
| **Shared** | Default | Full bi-directional | Simple commands, role work |
| **Forked** | `context: fork` | Isolated, returns summary only | Heavy analysis, reviews |

### Fork Strategy Providers

**Aggressive Fork** (standard tier -- Opus 4.5, Sonnet, Haiku): Fork everything marked with `context: fork`.
- Forked skills (5): consultant, coverage-checker, solid-analyzer, spec-merger, mcp-connector
- Forked agents (4): security-reviewer, performance-reviewer, architecture-reviewer, code-reviewer

**Selective Fork** (advanced tier -- Opus 4.6+): Fork only when isolation is truly needed.
- Always fork: consultant, security-reviewer, mcp-connector
- Fork only when heavy: coverage-checker (full scan), spec-merger (multiple specs)
- Thresholds: > 30 files -> fork; > 500 lines output -> fork; cross-codebase -> fork; external services -> fork

### Portable Governance (Hooks in Frontmatter)

```yaml
---
name: my-skill
context: fork
hooks:
  PostToolUse:
    - matcher: Bash
      command: "echo '[my-skill] Step completed'"
  Stop:
    - command: "echo '[my-skill] Done.'"
---
```

### Queen Agent Pattern

`/workflows:route` can spawn forked sub-agents for parallel analysis:

```
User Request -> Queen Agent spawns 3 forked workers:
  +-- consultant (0.8s)
  +-- spec-analyzer (0.5s)
  +-- codebase-analyzer (0.6s)
       |
       v
  Aggregated Evidence -> Informed Decision
```

### Hightower's Process Model

| OS Concept | Claude Code Equivalent | Plugin Implementation |
|---|---|---|
| Process | Skill with `context: fork` | 5 forked skills + 4 forked agents |
| Process lifecycle | Hooks | Scoped hooks in skills/agents |
| IPC | Hook emissions + summaries | Queen Agent observes sub-agent hooks |
| Process isolation | Forked context window | Review agents don't pollute work context |

### Fowler's Warnings Applied

1. **"More context = better"** -- False. CLAUDE.md is lean, fork for heavy analysis.
2. **"We can ensure the agent does X"** -- False. Quality gates are probabilistic + BCP retries + human checkpoints.
3. **"Copy someone's config"** -- False. Immutable framework (`core/`) + customizable project (`.ai/`).

---

## §8 Session Continuity & Ralph Discipline

### How State Persists

| Mechanism | What It Stores | When Updated |
|---|---|---|
| **tasks.md** | Workflow State, role statuses, resume point, decision log | After every task and phase |
| **Git commits** | Code changes, checkpoints | At each checkpoint |
| **OpenSpec files** | Specs, design docs, proposal | After each planning phase |
| **scratchpad.md** | Working notes, hypotheses, blockers | During active work (ephemeral) |

### Scratchpad Pattern

Each feature can have `scratchpad.md` in `openspec/changes/${FEATURE_ID}/`:
- **Purpose**: External memory for the active role
- **When to create**: Start of any complex or multi-session phase
- **When to read**: Always on session resume
- **Lifecycle**: Created during work, reviewed during self-review, archived by `/workflows:compound`

### Provider-Aware Thresholds

| Signal | Standard (Opus 4.5) | Advanced (Opus 4.6+) |
|---|---|---|
| Compact at capacity | 70% | 85% |
| Max files read | 20 | 50 |
| Max session duration | 2 hours | 4 hours |
| Max messages | 50 | 150 |
| Checkpoint frequency | Every 30-45 min | At milestones only |

### Resuming a Session

```
1. Read tasks.md -> identify current Workflow State
2. Read scratchpad.md (if exists) -> re-orient with context breadcrumbs
3. Read git log --oneline -10 -> understand recent progress
4. Read the resume point in tasks.md -> know which task/phase is next
5. Read the relevant openspec/changes/<feature>/ files for context
6. Continue from where the previous session left off
```

### Creating a Checkpoint

| Trigger | Rationale |
|---|---|
| Completing a task | Atomic progress marker |
| Before major changes | Safe rollback point |
| End of work session | Resume tomorrow without loss |
| Before role handoff | Enable smooth transitions |
| Context getting heavy | Save point before `/compact` |

### Ralph Discipline -- Core Principles

#### 1. State Externalization

Never rely on conversation memory. All state lives in files:

```
CONVERSATION (volatile)                FILE-BASED (durable)
"We decided to use JWT"           ->   Decision Log in tasks.md
"I was working on the API layer"  ->   Resume Point in tasks.md
"The edge case with null emails"  ->   scratchpad.md hypothesis
"That pattern from last feature"  ->   compound-memory.md
```

**Rule**: If it matters, write it down. If you said it but didn't write it, it doesn't exist.

#### 2. Anti-Context-Rot

| Symptom | Cause | Mitigation |
|---|---|---|
| Repeating the same error | Lost correction context | Write fix rationale to scratchpad.md |
| Forgetting a decision | Compaction removed early messages | Log in tasks.md Decision Log |
| Implementing wrong approach | Drifted from plan | Re-read design.md before each task |
| Missing edge cases | Specs lost from context | Re-read specs.md acceptance criteria |
| Contradicting earlier work | Session too long | Checkpoint and start fresh session |

**Prevention**: Write-Then-Advance, checkpoint at milestones, re-read after interruption, scratchpad as working memory.

#### 3. Deliberate Rotation

One instance = one role:

```
SESSION 1 (Planner):     Read routing + compound -> Write proposal, specs, design, tasks
SESSION 2 (Implementer): Read tasks, design, specs -> Write code, tests, task updates
SESSION 3 (Reviewer):    Read tasks, implementation, specs -> Write QA report
```

#### 4. Context Breadcrumbs

```markdown
## Resume Point (in tasks.md)

**Last completed**: Task 3 - Create User entity
**Currently working on**: Task 4 - Implement CreateUserUseCase
**Status**: IN_PROGRESS (partial)
**Next after current**: Task 5 - Add API endpoint
**Files to read on resume**: design.md, CreateUserUseCase.php, CreateUserUseCaseTest.php
```

### When to Apply Ralph Discipline

| Complexity | Level |
|---|---|
| L1 (Trivial) | Minimal: just quick task log |
| L2 (Simple) | Standard: tasks.md updates, basic resume point |
| L3 (Moderate) | Full: scratchpad, detailed resume points, decision log |
| L4 (Complex) | Maximum: all above + mandatory checkpoints between phases |

### Cross-Role Handoffs

1. Completing role creates a checkpoint
2. New role reads tasks.md
3. New role reads relevant openspec/ files
4. New role continues from resume point

### Token-Efficient Habits

- Use `grep` to find before reading full files
- Read specific line ranges when possible
- Filter command outputs (`--oneline`, `--stat`)
- Disable unused MCP servers

---

## §9 Capability Providers

Model-agnostic abstraction layer. Commands work identically; the plugin resolves the best implementation underneath.

### Detection Protocol

```
1. READ core/providers.yaml
2. IF provider == "auto":
   +-- CHECK model identity -> tier: advanced | standard | lightweight
   +-- CHECK tool availability (TeammateTool? Fork?)
   +-- SELECT provider based on tier + tools
3. IF provider is explicit -> USE directly
4. APPLY thresholds from providers.yaml
5. EXECUTE with resolved provider
```

**Tier detection**: "opus-4-6" or later -> advanced; "opus-4-5"/"sonnet" -> standard; "haiku" -> lightweight.

### Provider: Parallelization

| | Agent Teams (advanced) | Worktrees + tmux (standard) |
|---|---|---|
| Prerequisites | Opus 4.6+, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | git >= 2.30, tmux >= 3.0 |
| Communication | Direct inter-agent | File-based (tasks.md + git) |
| Coordination | Orchestrator mediates | Manual via git sync |

### Provider: Context Management

| Metric | Manual Snapshots (standard) | Compaction-Aware (advanced) |
|---|---|---|
| Compact suggestion | 70% | 85% |
| Max files read | 20 | 50 |
| Max session | 2h | 4h |
| Max messages | 50 | 150 |
| Checkpoint frequency | Every 30-45 min | At milestones only |

### Provider: Execution Mode

| Mode | Behavior |
|---|---|
| **agent-executes** | Generate code following patterns, run tests, iterate autonomously |
| **human-guided** | Create instructions, human implements, agent verifies |
| **hybrid** | Generate code, pause for human review at checkpoints |

**Auto**: Low-trust paths -> hybrid; task has reference file -> agent-executes; otherwise -> agent-executes.

### Model Recommendations by Phase

| Phase | Model | Thinking | Rationale |
|---|---|---|---|
| Route | Sonnet/Haiku | disabled | Classification -- fast, low complexity |
| Shape | Opus | high budget | Ambiguity resolution, deep reasoning |
| Plan (Phase 1-3) | Opus | high budget | Requirements + architecture |
| Plan (Phase 4) | Sonnet | low budget | Task breakdown from established design |
| Work (simple) | Sonnet | low budget | Pattern-following with references |
| Work (complex) | Opus | high budget | Novel code, multi-layer integration |
| Review (security) | Opus | high budget | Threat analysis |
| Compound | Sonnet | low budget | Structured capture |

### Configuration Examples

```yaml
# Opus 4.6 (maximize new capabilities)
providers:
  parallelization: auto
  context_management: auto
  fork_strategy: auto
  coordination: auto

# Opus 4.5 (full compatibility)
providers:
  parallelization: worktrees
  context_management: manual-snapshots
  fork_strategy: aggressive
  coordination: state-plus-git
```

---

## §10 Validation Learning

> Every question asked is an investment. Every answer received is a permanent asset.

### The Learning Cycle

```
Validation (in review) -> Validation Learning Log (skill) -> Learning Loader (install)
```

**Cycle 1 (Cold)**: 5 assumptions, 4 questions asked, 0% effectiveness.
**Cycle 2 (Warm)**: 5 assumptions, 2 already answered, 40% effectiveness.
**Cycle 3 (Learning)**: 6 assumptions, 4 already answered, 67% effectiveness.
**Cycle N (Mature)**: All answered by log, 0 questions, 100% effectiveness.

### Integration with Workflow

```
/workflows:discover --setup -> Creates empty learning log
/workflows:plan -> Reads patterns/preferences for design choices
/workflows:review -> PRIMARY ENTRY (runs validation inline, asks questions, updates log)
/workflows:compound -> Promotes mature patterns to project rules
```

### Learning Log File

**Location**: `.ai/project/validation-learning-log.md` (single file, grep-friendly, git-trackable, max 500 lines)

### Pattern Lifecycle

```
OBSERVATION -> PATTERN -> CONFIRMED -> PROMOTED -> RULE

1. User answers a question -> LOG-XXX
2. Same answer in 2+ features -> PAT-XXX (confidence 70%)
3. Holds in 3+ features -> confidence 85-95%
4. 5+ features, 90%+ confidence -> added to project_rules.md
5. Enforced by framework, validator no longer questions this
```

**Conflict**: New answer contradicts pattern -> record both, lower confidence 20%, present conflict next time.

### Install-Time Learning

During `/workflows:discover --setup`, pre-load universal learnings at 50% confidence:
- Always validate input at API boundary
- Use DTOs for data transfer between layers
- Database migrations need rollback strategy
- Error responses should follow a standard format

### Relationship to Compound Memory

- **Compound Memory** tells agents WHERE problems occur (pain points)
- **Validation Learning Log** tells agents WHAT the user prefers (patterns, preferences)

---

## §11 MCP Integration

Model Context Protocol enables AI agents to interact with external tools and services.

### Architecture

```
AI Agent (Claude Code) -> MCP Client (Tool Router) -> MCP Server (postgres, etc) -> External Service
```

### Tool Naming Convention

```
mcp__<server>__<tool>
```

Examples: `mcp__postgres__query`, `mcp__github__create_pull_request`, `mcp__slack__send_message`

### How Agents Use MCP Tools

1. **Check available servers** -- verify configured servers
2. **Verify role access** -- RBAC in `servers.yaml`
3. **Invoke the tool** -- provide required parameters
4. **Handle results** -- process structured responses

### Role Access Matrix

| Server | Planner | Backend | Frontend | QA |
|---|:---:|:---:|:---:|:---:|
| postgres | Yes | Yes | No | Yes |
| github | Yes | Yes | Yes | Yes |
| slack | Yes | Yes | Yes | Yes |
| puppeteer | No | No | Yes | Yes |

### Common Workflows

1. **DB Migration Validation** -- `list_tables` -> `describe_table` -> `query` -> verify
2. **PR Creation** -- verify tests -> commit -> push -> `create_pull_request`
3. **Blocked Notification** -- status BLOCKED -> `send_message` to Slack
4. **UI Verification** -- `navigate` -> `screenshot` -> `fill` -> `click` -> verify

### Security

- **RBAC**: Verify role before MCP tool usage
- **Trust Levels**: high (read-only), medium (reversible writes), low (destructive -- requires approval)
- **Data Protection**: `read_only: true`, `blocked_tables`, `allowed_domains`
- **Credentials**: Never hardcode. Use environment variables.
- **Audit**: All MCP operations are logged.

### Error Handling

- **Connection errors**: Retry with backoff (max 3), then continue without MCP
- **Permission denied**: Verify role, check if another role should act
- **Timeout**: Simplify the operation

### Best Practices

1. Prefer native tools (git) over MCP for simple operations
2. Batch related MCP operations
3. Document MCP usage in checkpoints
4. Handle failures gracefully -- continue with mock data, note in tasks.md

---

## §12 Cross-Cutting Concepts

### Bounded Correction Protocol (BCP)

```
Test fails -> Identify deviation type -> Auto-correct -> Repeat (within limits)
  simple: 5 iterations | moderate: 10 | complex: 15
  3 same errors -> diagnostic-agent
```

See `core/rules/testing-rules.md` for full BCP specification.

### Spec Lifecycle

```
Plan writes -> openspec/changes/{slug}/specs.md
Work reads + implements against specs
Review validates implementation matches specs
Compound merges -> openspec/specs/ (project baseline)
```

### Context Budget

```
Always loaded:  CLAUDE.md + framework_rules.md (lean)
On demand:      Role definitions, scoped rules, KB sections
Forked:         Heavy skills, review agents (isolated context)
User-triggered: Skills on /skill:X invocation
```

### SOLID Constraint

```
Phase 3 (Plan): Solutions must be SOLID COMPLIANT
Work checkpoint: solid-analyzer verifies compliance
Review: architecture-reviewer validates SOLID
```

---

## §13 Compound Memory Architecture

```
Feature N:                          Feature N+1:
+------------------+               +------------------+
| /workflows:plan  |               | /workflows:plan  |
| Step 0.0d:       |               | Step 0.0d:       |
| Read compound    |<--------------| Read compound    |
| memory + next    |  Feedback     | memory + next    |
| feature brief    |  Loop         | feature brief    |
+--------+---------+               +--------+---------+
         |                                  |
         v                                  v
+------------------+               +------------------+
| /workflows:work  |               | /workflows:work  |
| Step 3.5:        |               | Step 3.5:        |
| Read patterns +  |<--------------| Read patterns +  |
| anti-patterns    |  Feedback     | anti-patterns    |
+--------+---------+  Loop         +--------+---------+
         |                                  |
         v                                  v
+------------------+               +------------------+
| /workflows:      |               | /workflows:      |
| compound         |-------------->| compound         |
| Step 6b:         |  Generates    |                  |
| next-feature-    |  briefing     |                  |
| briefing.md      |  for N+1      |                  |
+------------------+               +------------------+
```

### Memory Files

| File | Purpose | Written By | Read By |
|---|---|---|---|
| `compound-memory.md` | Pain points, patterns | `/workflows:compound` | Plan, Work, Review |
| `next-feature-briefing.md` | Reusable patterns, risks | `/workflows:compound` | Next Plan + Work |
| `validation-learning-log.md` | User preferences | Validation in Review | All agents |
| `compound_log.md` | Historical record | `/workflows:compound` | Analysis |

---

## §14 The 70% Problem (Osmani)

```
0%---------------------70%----------------------100%
|                        |                        |
|  FAST PROGRESS         |  SLOW PROGRESS         |
|  AI excels             |  Human expertise needed |
|                        |                        |
|  - Scaffolding         |  - Edge cases          |
|  - CRUD operations     |  - Error handling      |
|  - Happy paths         |  - Security hardening  |
|  - Boilerplate         |  - Integration issues  |
|  - Standard patterns   |  - Performance tuning  |
```

| Problem | Workflow Solution |
|---|---|
| AI rushes past 70% | Compound captures WHERE the boundary was |
| Edge cases missed | Specs define error scenarios upfront (Phase 2) |
| Security hardening skipped | Security-reviewer in review phase |
| Integration issues late | Test contract sketch (Phase 2.5) pre-validates |
| Comprehension debt | Indicators in framework_rules |

---

## §15 When to Use What

| Situation | Recommended Path | Why |
|---|---|---|
| "Fix this typo" | L1 -> Quick | No planning overhead |
| "Add a field to User" | L1 -> Quick | Simple, well-understood |
| "Fix the login bug" | L2 -> Default plan | Need reproduction + fix |
| "Add email notifications" | L3 -> Task-breakdown | Multiple layers |
| "Implement payment system" | L4 -> Shape first | Unknowns, security, risk |
| "Refactor auth to JWT" | L3-L4 -> Depends | Assess files + unknowns |
| "Investigate slow queries" | Research agents | Not a code change |
| "Review this PR" | `/workflows:review` | Direct review |
| New project from scratch | `/workflows:discover --seed` | Generate compound knowledge |

---

## §16 Plugin Architecture Summary

```
plugins/workflow/
+-- agents/                    # 10 agents (research, review, workflow)
|   +-- research/              # codebase-analyzer, learnings-researcher
|   +-- review/                # code, architecture, security, performance
|   +-- workflow/              # diagnostic-agent, spec-analyzer
+-- commands/workflows/        # 10 commands (core + support)
+-- skills/                    # 16 skills across 7 categories
|   +-- workflow-navigator/    # Session optimizer (NEW in v3.4.0)
+-- core/
|   +-- roles/                 # planner, implementer, reviewer
|   +-- rules/                 # framework, testing, security, git
|   +-- docs/                  # KNOWLEDGE_BASE.md (this file) + workflow-hub.html
|   +-- templates/             # Artifact templates
|   +-- providers.yaml         # Capability provider configuration
|   +-- architecture-reference.md
+-- CLAUDE.md                  # Always-loaded entry point (lean, ~118 lines)
+-- .claude-plugin/plugin.json # Plugin metadata
```

---

## §17 Source References

| Source | Key Concept | Link |
|---|---|---|
| Compound Engineering (Every) | Core philosophy, compounding returns | [Article](https://every.to/source-code/compound-engineering-how-every-codes-with-agents-af3a1bae-cf9b-458e-8048-c6b4ba860e62) |
| Context Engineering (Fowler) | Activation taxonomy, context calibration | [Article](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html) |
| Shape Up (Singer) | Shaping, appetite, breadboards | [Book](https://basecamp.com/shapeup) |
| BMAD Method | Scale-adaptive limits, adversarial review | [GitHub](https://github.com/bmad-code-org/BMAD-METHOD) |
| GSD | Quick mode, deviation detection | [GitHub](https://github.com/gsd-build/get-shit-done) |
| Karpathy Skills | 4 principles for AI development | [GitHub](https://github.com/forrestchang/andrej-karpathy-skills) |
| Addy Osmani | 10 pillars, the 70% problem | [Beyond Vibe Coding](https://addyosmani.com/blog/beyond-vibe-coding/) |
| Rick Hightower | Skill architecture, Queen Agent | [Medium](https://medium.com/@richardhightower/build-agent-skills-faster-with-claude-code-2-1-release-6d821d5b8179) |

---

**This document is the single source of truth for all methodology knowledge in the Multi-Agent Workflow Plugin. For operational rules, see `core/rules/framework_rules.md`. For visual navigation, open `core/docs/workflow-hub.html`. For session initialization, invoke the `workflow-navigator` skill.**
