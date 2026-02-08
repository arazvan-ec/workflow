---
name: workflows:parallel
description: "Launch multiple agents in parallel. Auto-detects provider: Agent Teams (Opus 4.6+) or worktrees+tmux (fallback)."
argument_hint: <feature-id> [--roles=backend,frontend,qa] [--provider=auto|agent-teams|worktrees] [--cleanup]
---

# Multi-Agent Workflow: Parallel

Launch multiple AI agents working in parallel on a feature. The command auto-resolves the best parallelization provider based on the running model and available tools.

## Usage

```bash
# Standard (auto-detects provider)
/workflows:parallel user-authentication --roles=backend,frontend,qa

# Force a specific provider
/workflows:parallel user-authentication --provider=agent-teams
/workflows:parallel user-authentication --provider=worktrees

# Cleanup after completion
/workflows:parallel user-authentication --cleanup
```

## Provider Resolution

Before launching agents, resolve the parallelization provider:

```
1. READ core/providers.yaml → providers.parallelization

2. IF "auto":
   ├── Is TeammateTool available in your tool list?
   │   YES → provider = agent-teams
   │   NO  → provider = worktrees
   │
   └── Log: "Resolved parallelization provider: {provider}"

3. IF explicit → use that provider directly

4. IF --provider flag passed → override config (session only)
```

## Provider: Agent Teams

**Available when**: TeammateTool is in the tool list (Opus 4.6+ with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

### How It Works

```
┌──────────────────────────────────────────────────────────┐
│              ORCHESTRATOR (current session)                │
│                                                          │
│  1. Load feature context from 50_state.md                │
│  2. Parse task assignments per role from 30_tasks.md     │
│  3. Spawn teammates via TeammateTool                     │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Teammate:   │  │  Teammate:   │  │  Teammate:   │     │
│  │  BACKEND     │  │  FRONTEND    │  │  QA           │     │
│  │             │  │             │  │             │     │
│  │  Reads:      │  │  Reads:      │  │  Reads:      │     │
│  │  - backend.md│  │  - frontend  │  │  - qa.md     │     │
│  │  - 50_state  │  │  - 50_state  │  │  - 50_state  │     │
│  │  - tasks_be  │  │  - tasks_fe  │  │  - tasks_qa  │     │
│  │             │  │             │  │             │     │
│  │  Writes:     │  │  Writes:     │  │  Writes:     │     │
│  │  - src/      │  │  - frontend/ │  │  - tests/    │     │
│  │  - tests/    │  │  - tests/    │  │  - 50_state  │     │
│  │  - 50_state  │  │  - 50_state  │  │             │     │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘     │
│         │                │                │             │
│         └────────┬───────┘────────────────┘             │
│                  ▼                                       │
│  4. Monitor progress via shared task list               │
│  5. Synchronize 50_state.md on completion               │
│  6. Report results                                       │
└──────────────────────────────────────────────────────────┘
```

### Orchestrator Prompt for Each Teammate

When spawning a teammate, provide this context:

```markdown
You are the {ROLE} agent for feature "{FEATURE_ID}".

## Your Role
Read: plugins/multi-agent-workflow/core/roles/{role}.md

## Feature Context
Read: .ai/project/features/{feature}/50_state.md
Read: .ai/project/features/{feature}/FEATURE_*.md

## Your Tasks
Read: .ai/project/features/{feature}/30_tasks_{role}.md

## Rules
Read: plugins/multi-agent-workflow/core/rules/framework_rules.md
Read: plugins/multi-agent-workflow/core/rules/testing-rules.md

## Coordination
- Update your section in 50_state.md after each checkpoint
- Follow TDD: Red → Green → Refactor
- SOLID score must meet thresholds at each checkpoint
- If blocked after 10 iterations, mark BLOCKED in 50_state.md
```

### Cleanup (Agent Teams)

```bash
/workflows:parallel user-auth --cleanup
# Agent Teams cleanup is automatic — no filesystem artifacts
# Just verify 50_state.md is synchronized
```

---

## Provider: Worktrees + tmux

**Available when**: Always (fallback provider)

**Prerequisites**: tmux >= 3.0, git >= 2.30

### How It Works

```
┌──────────────────────────────────────────────────────────┐
│              TMUX SESSION: workflow-{feature}              │
│                                                          │
│  ┌──────────────────────┬──────────────────────┐        │
│  │                      │                      │        │
│  │     BACKEND           │     FRONTEND          │        │
│  │     :3001             │     :3002             │        │
│  │                      │                      │        │
│  │  Worktree:            │  Worktree:            │        │
│  │  .worktrees/backend/  │  .worktrees/frontend/ │        │
│  │                      │                      │        │
│  ├──────────────────────┴──────────────────────┤        │
│  │                                              │        │
│  │                    QA                         │        │
│  │                   :3003                       │        │
│  │  Worktree: .worktrees/qa/                    │        │
│  │                                              │        │
│  └──────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────┘
```

### Step 1: Create Git Worktrees

For each role, create an isolated working directory:

```
.worktrees/
├── backend/   (branch: feature/{feature}-backend)
├── frontend/  (branch: feature/{feature}-frontend)
└── qa/        (branch: feature/{feature}-qa)
```

Each worktree:
- Has its own filesystem (no conflicts)
- Is on its own feature branch
- Can run its own dev server
- Shares git history with main repo

### Step 2: Allocate Ports

| Role | Port |
|------|------|
| backend | 3001 |
| frontend | 3002 |
| qa | 3003 |

### Step 3: Launch tmux Session

```bash
PARALLEL_DIR=".ai/workflow/parallel"
source "${PARALLEL_DIR}/tmux_orchestrator.sh"
tmux_create_session "workflow-${FEATURE_ID}" "${ROLES}" "${FEATURE_ID}"
```

### Step 4: Set Up Environment

Each pane has:
- `AGENT_ROLE` — Current role (backend/frontend/qa)
- `AGENT_PORT` — Allocated port
- `FEATURE_ID` — Feature being worked on
- Working directory set to worktree

### Cleanup (Worktrees)

```bash
/workflows:parallel user-auth --cleanup

# This will:
# 1. Kill tmux session
# 2. Remove worktrees (if clean)
# 3. Release allocated ports
```

---

## Output

Both providers produce the same output format:

```
╔════════════════════════════════════════════════════════════╗
║          PARALLEL SESSION CREATED                          ║
╚════════════════════════════════════════════════════════════╝

Provider: {agent-teams | worktrees}
Session: workflow-{feature}
Feature: {feature}

Agents launched:
  [0] backend    {provider-specific details}
  [1] frontend   {provider-specific details}
  [2] qa         {provider-specific details}

State file: .ai/project/features/{feature}/50_state.md

Next steps:
  - Each agent works on assigned tasks from 30_tasks.md
  - Progress tracked in 50_state.md
  - Quality gates enforced at each checkpoint
```

---

## Merging Work

After parallel development (same for both providers):

1. Each agent pushes their branch
2. Create PRs for each branch
3. Review and merge to main
4. Or merge branches locally:

```bash
git checkout main
git merge feature/user-auth-backend
git merge feature/user-auth-frontend
```

---

## Provider Comparison

| Aspect | Agent Teams | Worktrees + tmux |
|--------|------------|------------------|
| **Communication** | Direct (shared task list) | File-based (50_state.md + git) |
| **Isolation** | Context window per agent | Filesystem per agent |
| **Setup** | Automatic | tmux + git worktree commands |
| **Cleanup** | Automatic | Manual (--cleanup) |
| **Visibility** | Orchestrator monitors | tmux panes |
| **Model requirement** | Opus 4.6+ | Any |
| **External deps** | None | tmux, git worktree |

Both providers:
- Use `50_state.md` for persistent state
- Enforce role definitions (one role per agent)
- Apply quality gates (TDD, SOLID, checkpoints)
- Support the same `/workflows:parallel` interface

---

## Tips

1. **Plan first**: Clear specs reduce conflicts between agents
2. **Define contracts**: API contracts let frontend mock while backend implements
3. **Regular syncs**: Merge main periodically to avoid drift
4. **One role per agent**: Don't mix responsibilities

## Related Commands

- `/workflows:plan` — Plan feature before parallel work
- `/workflows:work` — Execute tasks for a specific role
- `/workflows:status` — Check all agent status
- `/workflows:sync` — Sync state between agents

## Sources

- [Claude Code Agent Teams](https://www.anthropic.com/news/claude-opus-4-6) — Native parallel agents (Opus 4.6+)
- [workmux](https://github.com/raine/workmux) — Git worktrees + tmux
- [uzi](https://github.com/devflowinc/uzi) — Parallel coding agents
