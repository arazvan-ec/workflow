# Routing Reference

Detailed routing guidance for the workflow router. This file is loaded on-demand when deeper routing context is needed.

For the core routing protocol, see `CLAUDE.md`.
For the full methodology integration, see `KNOWLEDGE_BASE.md`.

---

## Complexity Levels (L1-L4)

Every request is classified into one of 4 complexity levels. Each level activates a different subset of the workflow:

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

---

## Clarifying Question Templates

### For Features
- Can you describe the functionality in 2-3 sentences?
- Who will use this functionality?
- Backend, frontend, or both?
- Does it connect to external APIs?
- Does it handle sensitive data?

### For Bugs
- What is happening now vs what should happen?
- How can I reproduce the error?
- Does it always occur or is it intermittent?
- Are there specific error messages?

### For Refactoring
- Which files/modules are involved?
- Why is this change needed?
- Are there existing tests?

## Workflow Selection Decision Matrix

| User Need | Ask About | Route To |
|-----------|-----------|----------|
| New functionality | Complexity, stack, integrations | `/workflows:plan` |
| Bug fix | Reproducibility, error messages | `diagnostic-agent` then `/workflows:work` |
| Refactoring | Scope, motivation, tests | Depends on scope |
| Investigation | What to learn, where to look | Research agents |
| Code review | What to review, concerns | `/workflows:review` |
| Documentation | Scope, audience | Direct work |

## Confidence Scoring

Calculate confidence (0-100%) based on:
- Clear keywords: +20
- File references: +15
- Action verbs: +15
- Expected behavior described: +20
- Vague language: -25

If confidence < 60%, ask clarifying questions before routing.

## Self-Correction Protocol

If you realize you started work without proper routing:

1. Pause current work
2. Ask clarifying questions now
3. Confirm workflow selection with user
4. Then continue with proper context

## Router Verification Checklist

Before proceeding with routed work:

- [ ] Was the work type clearly identified?
- [ ] Were clarifying questions asked if needed?
- [ ] Is the chosen workflow appropriate for the task?
- [ ] Has trust level been considered for sensitive areas?
