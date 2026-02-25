---
name: workflow-navigator
description: "Session initialization and context optimizer. Reads project state, detects complexity level, loads relevant Knowledge Base sections, and configures the session for optimal workflow execution. Invoke at session start or when switching context."
model: auto
context: shared
user_invocable: true
---

# Workflow Navigator Skill

Session-level orchestrator that bridges the Knowledge Base (source of truth) with the active Claude Code session. It reads current state and loads only what's needed.

## Purpose

Session-level orchestrator that bridges the Knowledge Base (source of truth) with the active Claude Code session. It reads current state and loads only what's needed.

## When to Invoke

- At the start of every new session
- When resuming work after a break
- When switching between features
- When context feels stale or confused

## Execution Protocol

### Step 1: State Detection

Read these files (if they exist):
- `openspec/changes/*/tasks.md` — find the active feature's Workflow State
- `.ai/project/compound-memory.md` — check for existing learnings
- `.ai/project/validation-learning-log.md` — check for learned patterns
- `core/providers.yaml` — determine provider configuration

Run: `git log --oneline -5` to see recent activity.

### Step 2: Provider Resolution

Detect model tier from system prompt:
- Model contains "opus-4-6" or later → tier: advanced
- Model contains "opus-4-5" or "sonnet" → tier: standard
- Model contains "haiku" → tier: lightweight
- Otherwise → tier: standard (safe default)

Apply thresholds from `KNOWLEDGE_BASE.md §9 Capability Providers`.

### Step 3: Context Loading

Based on detected state, determine which KB sections are relevant:

| Detected State | Load KB Sections |
|---|---|
| No active feature | §5 Decision Matrix, §15 When to Use What |
| Feature in ROUTING | §4 Complexity Levels L1-L4, §5 Decision Matrix |
| Feature in PLANNING | §6 Karpathy Principles, §9.5 Execution Mode |
| Feature in WORK | §6 Karpathy (Surgical Changes), §12 Cross-Cutting (BCP) |
| Feature in REVIEW | §10 Validation Learning, §12 Cross-Cutting |
| Feature in COMPOUND | §13 Compound Memory Architecture |
| Multi-session detected | §8 Session Continuity & Ralph Discipline |
| MCP servers configured | §11 MCP Integration |
| Low-trust paths detected | §7 Context Engineering (Fork Strategy) |

Read ONLY the relevant sections from `core/docs/KNOWLEDGE_BASE.md`, not the entire file.

### Step 4: Session Brief

Present a concise summary to the user:

```markdown
## Session Initialized

**Active Feature**: {feature-slug} | **Phase**: {current phase}
**Complexity**: L{n} ({name}) | **Provider Tier**: {tier}
**Last Checkpoint**: {commit message} ({time ago})

### Current State
- Planner: {status}
- Implementer: {status}
- Reviewer: {status}

### Next Step
{Recommended next command based on state}

### Loaded Context
- KB sections: §{n}, §{n}, §{n}
- Rules: framework_rules.md {+ scoped rules if applicable}
- Compound memory: {available/not found}
```

### Step 5: Ready

The session is now configured. Proceed with the recommended next step or wait for user instruction.

## Relationship to Other Components

- **CLAUDE.md**: Always-loaded minimal pointer. workflow-navigator extends it per-session.
- **KNOWLEDGE_BASE.md**: The source of truth. This skill reads sections from it on demand.
- **framework_rules.md**: Operational rules. Always loaded independently.
- **workflow-hub.html**: Visual navigator (for humans). This skill is the programmatic equivalent (for Claude).
