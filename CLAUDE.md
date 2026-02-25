# Multi-Agent Workflow Plugin

A compound engineering framework for coordinating multiple AI agents on software development.

## The Flow

```
  ROUTE --> SHAPE --> PLAN --> WORK --> REVIEW --> COMPOUND
  (entry)  (optional)  (80%)   (15%)    (4%)       (1%)
                        ↑                              │
                        └──── Feedback Loop ←──────────┘

  ROUTE --> QUICK (lightweight alternative for simple tasks)
```

**Every request starts with routing.** No exceptions.

## Core Commands

| # | Command | Purpose | When |
|---|---------|---------|------|
| 0 | `/workflows:route` | Classify request, ask questions, select workflow | **Always first** |
| 0b | `/workflows:quick` | Lightweight path for simple tasks (<=3 files) | Simple tasks |
| 1 | `/workflows:shape` | Separate problem from solution, spike unknowns | Complex/unclear features |
| 2 | `/workflows:plan` | Architecture-first planning with SOLID constraint | Before implementation |
| 3 | `/workflows:work` | Execute with TDD + Bounded Correction Protocol | After plan COMPLETED |
| 4 | `/workflows:review` | Multi-agent quality review | After work COMPLETED |
| 5 | `/workflows:compound` | Capture learnings for future acceleration | After review APPROVED |

### Support Commands

| Command | Purpose |
|---------|---------|
| `/workflows:status` | View all roles' progress |
| `/workflows:help` | Quick reference and guidance |
| `/workflows:discover` | Auto-analyze project architecture (`--setup` for onboarding, `--seed` for greenfield) |

## Flow Guards (enforced)

- `shape` requires: `00_routing.md` exists on disk OR routing context in conversation
- `plan` requires: `00_routing.md` exists on disk OR routing context in conversation. If shaped, `01_shaped_brief.md` Shaping Progress must be all COMPLETED.
- `work` requires: plan status = COMPLETED in `tasks.md` Workflow State
- `review` requires: work status = COMPLETED in `tasks.md` Workflow State
- `compound` requires: QA status = APPROVED in `tasks.md` Workflow State

## Agents

| Category | Agents | Invoked by |
|----------|--------|------------|
| Roles (3) | planner, implementer, reviewer | `plan`, `work`, `review` |
| Review (4) | code-reviewer, architecture-reviewer, security-reviewer, performance-reviewer | `review` |
| Research (2) | codebase-analyzer, learnings-researcher | `route`, `plan` |
| Workflow (2) | diagnostic-agent, spec-analyzer | `work`, `review` |

## Skills (16)

| Category | Skills |
|----------|--------|
| Core | consultant, checkpoint, git-sync, commit-formatter |
| Quality | test-runner, coverage-checker, lint-fixer |
| Compound | spec-merger, validation-learning-log |
| Integration | mcp-connector |
| SOLID | solid-analyzer, criteria-generator |
| Shaping | shaper, breadboarder |
| Research | source-report |
| Session | **workflow-navigator** (session init + context optimizer) |

## Context Activation Model

| Content | Activation | When Loaded |
|---------|-----------|-------------|
| This file (CLAUDE.md) | Always | Every session |
| Operational rules (`core/rules/framework_rules.md`) | Always | Every session |
| Scoped rules (`core/rules/*-rules.md`) | Software-determined | When matching file types are edited |
| Role definitions (`core/roles/*.md`) | LLM-determined | When role is active |
| Skills (`skills/`) | Human-triggered | On `/skill:X` invocation |
| Review agents (`agents/review/*.md`) | Human-triggered | During `/workflows:review` |
| Project rules (`.ai/project/rules/`) | Software-determined | When matching patterns apply |

Heavy skills and review agents run with `context: fork` — isolated context windows returning summaries only.

## State Management

All roles communicate via `tasks.md` (Workflow State section in `openspec/changes/{slug}/tasks.md`). Status values: `PENDING`, `IN_PROGRESS`, `BLOCKED`, `WAITING_API`, `COMPLETED`, `APPROVED`, `REJECTED`.

## Best Practices

1. Route first — every request through `/workflows:route`
2. Ask when unclear — confidence < 60% means ask before acting
3. State assumptions before coding
4. Define testable success criteria
5. Implement only what's requested
6. Touch only essential code, preserve existing style
7. Plan 80%, execute 20%
8. Write tests before implementation (TDD)
9. Snapshot before breaks or risky operations
10. Log decisions — every design choice gets a rationale in the Decision Log
11. Self-review before transition — reflect on output before marking phase COMPLETED

## Knowledge Architecture (3 Layers)

| Layer | File | Purpose |
|-------|------|---------|
| **Source of Truth** | `core/docs/KNOWLEDGE_BASE.md` | Complete methodology reference — all patterns, protocols, principles, and integrations consolidated in one document (17 sections) |
| **Visual Navigator** | `core/docs/workflow-hub.html` | Interactive map of the workflow — browse methodology relationships, complexity levels, agents, and session lifecycle |
| **Session Optimizer** | `skills/workflow-navigator/SKILL.md` | Invoke at session start — reads project state, loads relevant KB sections, configures context |

All detailed reference content (Karpathy Principles, L1-L4 routing, Ralph Discipline, Context Engineering, Capability Providers, Validation Learning, Decision Matrix, MCP Integration) lives in the Knowledge Base. Individual doc files in `core/docs/` redirect to their KB section.

## Operational Rules

- **Framework rules**: `core/rules/framework_rules.md` (always loaded)
- **Scoped rules**: `core/rules/testing-rules.md`, `security-rules.md`, `git-rules.md`
- **Architecture**: `core/architecture-reference.md`, `core/providers.yaml`

---

**Version**: 3.4.0 | **Aligned with**: Compound Engineering + Karpathy + Context Engineering (Fowler) + Spec-Driven Development + Capability Providers + Shape Up (Singer) + AI Validation Learning + GSD + BMAD + Ralph Method + Code Factory + Addy Osmani (10 Pillars)
