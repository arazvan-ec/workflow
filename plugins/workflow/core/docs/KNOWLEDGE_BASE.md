# AI Workflow Knowledge Base

> Consolidated reference mapping all methodology sources, their contributions, and how they integrate into the Multi-Agent Workflow Plugin.

**Version**: 1.0.0
**Created**: 2026-02-24

---

## Ecosystem Map

This workflow integrates ideas from 8 distinct methodologies. Each contributes specific capabilities:

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

## Methodology Contributions

### What Each Methodology Brings

| Methodology | Primary Contribution | Where It Lives in the Plugin |
|---|---|---|
| **Compound Engineering** | Core loop (Plan→Work→Review→Compound), compounding returns, 50/50 rule | `compound.md`, `CLAUDE.md`, compound-memory |
| **Shape Up (Singer)** | Shaping phase, appetite-based scoping, fat marker sketches, breadboards | `shape.md`, `shaper/`, `breadboarder/` |
| **Karpathy Principles** | Think before coding, simplicity first, surgical changes, goal-driven | `KARPATHY_PRINCIPLES.md`, routing checks |
| **Spec-Driven Dev (OpenSpec)** | Artifact pipeline, baseline freeze, spec merge cycle | `plan.md`, `spec-merger/`, `openspec/` |
| **BMAD Method** | Scale-adaptive limits, adversarial self-review, BCP | `testing-rules.md`, BCP in `work.md` |
| **Context Engineering (Fowler)** | Activation taxonomy, fork strategy, context budget | `CONTEXT_ENGINEERING.md`, `providers.yaml` |
| **Code Factory** | Risk tiers, deterministic gates, policy enforcement | `policy-gate/`, `security-rules.md` |
| **Ralph Method** | Anti-context-rot, state externalization, deliberate rotation | `SESSION_CONTINUITY.md`, `tasks.md` state |
| **GSD** | Quick mode, deviation detection, goal-backward verification | `quick.md`, BCP deviation types |
| **Addy Osmani** | The 70% Problem, 10 pillars, comprehension debt | `compound.md` (70% boundary), `framework_rules.md` |

### Cross-Methodology Synergies

```
Compound × Shape Up = Shape BEFORE Plan (explore unknowns, then compound learnings)

Karpathy × Context Eng. = Think before coding + strategic context calibration

SDD × Compound = Feature specs merge into baseline (spec-merger in compound phase)

BMAD × GSD = Scale-adaptive BCP limits + quick mode escape to full workflow

Ralph × Context Eng. = State externalization + fork strategy prevent context rot

Code Factory × Security Rules = Risk tiers inform trust model and HITL checkpoints

Osmani × Compound = 70% boundary analysis feeds compound memory for next feature
```

---

## The Integrated Workflow (7 Phases)

### Phase Overview

```
Phase 0: ROUTE    → Classify, question, select workflow
Phase 0b: QUICK   → Lightweight path (≤3 files, no arch impact)
Phase 1: SHAPE    → Separate problem from solution (optional)
Phase 2: PLAN     → Architecture-first with SOLID constraint
Phase 3: WORK     → TDD + Bounded Correction Protocol
Phase 4: REVIEW   → Multi-agent quality review + validation learning
Phase 5: COMPOUND → Extract patterns, update specs, brief next feature
```

### Time Distribution (The 80/20 Rule)

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  PLAN ████████████████████████████████████████  80%          │
│  WORK ████████                                  15%          │
│  REVIEW ██                                       4%          │
│  COMPOUND █                                      1%          │
│                                                              │
│  When planning is thorough, implementation is fast.          │
│  Compound is small effort, massive future returns.           │
└─────────────────────────────────────────────────────────────┘
```

---

## Complexity Levels (L1-L4)

The router classifies requests into 4 complexity levels. Each level activates a different subset of the workflow:

### L1: Trivial (Quick Mode)

```
Scope:     ≤ 3 files, no architecture impact
Duration:  < 30 minutes
Phases:    ROUTE → QUICK
Examples:  Fix typo, rename variable, update dependency, add field
Guards:    No sensitive paths (auth/, security/, payment/)
Artifacts: Quick task log entry only
```

### L2: Simple (Default Workflow)

```
Scope:     4-10 files, single component/layer
Duration:  1-4 hours
Phases:    ROUTE → PLAN (default) → WORK → REVIEW
Examples:  Bug fix, simple feature, single-layer refactor
Guards:    Standard flow guards
Artifacts: proposal.md, specs.md, design.md, tasks.md
```

### L3: Moderate (Task-Breakdown Workflow)

```
Scope:     10-30 files, multiple components/layers
Duration:  4-16 hours (may span sessions)
Phases:    ROUTE → PLAN (task-breakdown) → WORK → REVIEW → COMPOUND
Examples:  Multi-layer feature, API + frontend, integration
Guards:    Full flow guards + HITL checkpoints
Artifacts: Full SDD pipeline + compound capture
```

### L4: Complex (Shape-First Workflow)

```
Scope:     30+ files, architectural change, unknowns
Duration:  16+ hours (multi-session)
Phases:    ROUTE → SHAPE → PLAN (task-breakdown) → WORK → REVIEW → COMPOUND
Examples:  New domain, migration, auth system, payment integration
Guards:    All guards + shaping verification + security review
Artifacts: Shaped brief + breadboard + full SDD pipeline + compound + retrospective
```

### Level Selection Matrix

| Signal | L1 | L2 | L3 | L4 |
|---|---|---|---|---|
| Files affected | ≤ 3 | 4-10 | 10-30 | 30+ |
| Components | 1 | 1 | 2-3 | 4+ |
| New entities | 0 | 0-1 | 1-3 | 3+ |
| External APIs | 0 | 0 | 0-1 | 1+ |
| Dimensional change | No | No | Maybe | Yes |
| Unknowns | None | None | Few | Many |
| Sensitive paths | No | Maybe | Maybe | Likely |
| Multi-session | No | No | Maybe | Yes |

---

## Ralph Discipline (Session Hygiene)

The Ralph Method provides anti-context-rot practices integrated throughout the workflow:

### Core Principles

1. **State Externalization**: Never rely on conversation memory. All state lives in files (`tasks.md`, `scratchpad.md`, openspec artifacts).

2. **Anti-Context-Rot**: Context degrades over long sessions. Prevent it by:
   - Writing before advancing (Write-Then-Advance rule, §11)
   - Checkpointing at milestones, not just time intervals
   - Using scratchpad.md for working hypotheses
   - Reading state files on resume instead of relying on conversation history

3. **Deliberate Rotation**: One instance = one role. When changing focus:
   - Checkpoint current progress
   - Update tasks.md with resume point
   - Start fresh context for new role
   - Read state files to re-orient

4. **Context Breadcrumbs**: Leave trail markers for future sessions:
   - Resume point in tasks.md (last task, next task, files to read)
   - Scratchpad with working notes and hypotheses
   - Decision log entries with rationale

### Integration Points

| Ralph Concept | Plugin Implementation |
|---|---|
| State externalization | `tasks.md` Workflow State, `scratchpad.md` |
| Anti-context-rot | Write-Then-Advance rule (§11), checkpoint skill |
| Deliberate rotation | Immutable Roles (§4), session restart protocol |
| Context breadcrumbs | Resume Point in tasks.md, scratchpad template |
| Handoff protocol | Cross-role handoffs in SESSION_CONTINUITY.md |

---

## The 70% Problem (Osmani)

AI-assisted development follows a predictable pattern:

```
0%──────────────────────70%────────────────────100%
│                        │                       │
│  FAST PROGRESS         │  SLOW PROGRESS        │
│  AI excels             │  Human expertise       │
│                        │  needed                │
│  • Scaffolding         │  • Edge cases          │
│  • CRUD operations     │  • Error handling      │
│  • Happy paths         │  • Security hardening  │
│  • Boilerplate         │  • Integration issues  │
│  • Standard patterns   │  • Performance tuning  │
│                        │                        │
│  Low comprehension     │  High comprehension    │
│  debt                  │  debt risk             │
└────────────────────────┴────────────────────────┘
```

### How the Workflow Addresses This

| Problem | Workflow Solution |
|---|---|
| AI rushes past 70% without noticing | Compound captures WHERE the boundary was |
| Edge cases missed | Specs define error scenarios upfront (Phase 2) |
| Security hardening skipped | Security-reviewer agent in review phase |
| Integration issues surface late | Test contract sketch (Phase 2.5) pre-validates |
| Comprehension debt accumulates | Comprehension Debt indicators in framework_rules §Comprehension Debt |

---

## Compound Memory Architecture

The workflow maintains a growing memory that makes each feature easier:

```
Feature N:                          Feature N+1:
┌─────────────────┐                ┌─────────────────┐
│ /workflows:plan │                │ /workflows:plan │
│                 │                │                 │
│ Step 0.0d:      │                │ Step 0.0d:      │
│ Read compound   │◄──────────────│ Read compound   │
│ memory + next   │  Feedback     │ memory + next   │
│ feature brief   │  Loop         │ feature brief   │
└────────┬────────┘                └────────┬────────┘
         │                                  │
         ▼                                  ▼
┌─────────────────┐                ┌─────────────────┐
│ /workflows:work │                │ /workflows:work │
│                 │                │                 │
│ Step 3.5:       │                │ Step 3.5:       │
│ Read patterns + │◄──────────────│ Read patterns + │
│ anti-patterns   │  Feedback     │ anti-patterns   │
└────────┬────────┘  Loop         └────────┬────────┘
         │                                  │
         ▼                                  ▼
┌─────────────────┐                ┌─────────────────┐
│ /workflows:     │                │ /workflows:     │
│ compound        │───────────────▶│ compound        │
│                 │  Generates     │                 │
│ Step 6b:        │  briefing      │                 │
│ next-feature-   │  for N+1       │                 │
│ briefing.md     │                │                 │
└─────────────────┘                └─────────────────┘
```

### Memory Files

| File | Purpose | Written By | Read By |
|---|---|---|---|
| `compound-memory.md` | Pain points, patterns, agent calibration | `/workflows:compound` | Plan, Work, Review agents |
| `next-feature-briefing.md` | Reusable patterns, risks, test strategy | `/workflows:compound` | Next feature's Plan + Work |
| `validation-learning-log.md` | User preferences, confirmed patterns | Validation step in Review | All agents |
| `compound_log.md` | Historical record of all features | `/workflows:compound` | Analysis, retrospectives |

---

## Cross-Cutting Concepts

### 1. Validation Learning Loop

```
Question AI Solution → Ask User → Log Answer → Pattern Emerges → Promote to Rule
```

Effectiveness increases with each feature: 0% → 40% → 67% → 100% (mature).

### 2. Bounded Correction Protocol (BCP)

```
Test fails → Identify deviation type → Auto-correct → Repeat (within limits)
                                                         │
                                               simple: 5 iterations
                                               moderate: 10 iterations
                                               complex: 15 iterations
                                                         │
                                          3 same errors → diagnostic-agent
```

### 3. Spec Lifecycle

```
Plan writes → openspec/changes/{slug}/specs.md (feature scope)
                            ↓
Work reads + implements against specs
                            ↓
Review validates implementation matches specs
                            ↓
Compound merges → openspec/specs/ (project baseline)
```

### 4. Context Budget

```
Always loaded:  CLAUDE.md + framework_rules.md (lean)
On demand:      Role definitions, scoped rules
Forked:         Heavy skills, review agents (isolated context)
User-triggered: Skills on /skill:X invocation
```

### 5. SOLID Constraint

```
Phase 3 (Plan): Solutions must be SOLID COMPLIANT
Work checkpoint: solid-analyzer verifies compliance
Review:          architecture-reviewer validates SOLID
```

---

## When to Use What

| Situation | Recommended Path | Why |
|---|---|---|
| "Fix this typo" | L1 → Quick | No planning overhead needed |
| "Add a field to User" | L1 → Quick | Simple, well-understood change |
| "Fix the login bug" | L2 → Default plan | Need reproduction + targeted fix |
| "Add email notifications" | L3 → Task-breakdown | Multiple layers, integration |
| "Implement payment system" | L4 → Shape first | Unknowns, security, high risk |
| "Refactor auth to JWT" | L3-L4 → Depends on scope | Assess: how many files? unknowns? |
| "Investigate slow queries" | Research agents | Not a code change, investigation |
| "Review this PR" | `/workflows:review` | Direct review, no planning |
| New project from scratch | `/workflows:discover --seed` | Generate compound knowledge first |

---

## Source References

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

## Plugin Architecture Summary

```
plugins/workflow/
├── agents/                    # 8 agents (research, review, workflow)
│   ├── research/              # codebase-analyzer, learnings-researcher
│   ├── review/                # code, architecture, security, performance
│   └── workflow/              # diagnostic-agent, spec-analyzer
├── commands/workflows/        # 10 commands (core + support)
├── skills/                    # 15 skills across 6 categories
├── core/
│   ├── roles/                 # planner, implementer, reviewer
│   ├── rules/                 # framework, testing, security, git
│   ├── docs/                  # 9 reference documents (including this one)
│   ├── templates/             # 7 templates for artifacts
│   ├── providers.yaml         # Capability provider configuration
│   └── architecture-reference.md
├── CLAUDE.md                  # Always-loaded entry point
└── README.md                  # Public documentation
```

---

**This document is the single source of truth for understanding how the methodologies integrate. For operational rules, see `framework_rules.md`. For specific commands, see `commands/workflows/`.**
