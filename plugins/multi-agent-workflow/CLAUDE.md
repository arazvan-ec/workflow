# Multi-Agent Workflow Plugin

A professional framework for coordinating multiple AI agents working in parallel on software development.

## Quick Start

```bash
# Install the plugin
/plugin marketplace add https://github.com/arazvan-ec/workflow
/plugin install multi-agent-workflow

# Start a new feature
/workflows:start user-authentication

# Work as a specific role
/workflows:role planner user-authentication
/workflows:role backend user-authentication
/workflows:role frontend user-authentication
/workflows:role qa user-authentication
```

## Core Concepts

### 4-Role System

This plugin coordinates 4 specialized AI agents:

| Role | Responsibility | Focus |
|------|---------------|-------|
| **Planner** | Define features, create contracts, break down tasks | Architecture & Planning |
| **Backend** | Implement API following DDD, write tests | Server-side code |
| **Frontend** | Implement UI, mock APIs, responsive design | Client-side code |
| **QA** | Review code, run tests, validate criteria | Quality Assurance |

### Workflow Templates

- **`default`**: Standard 4-role workflow (Plan → Backend/Frontend parallel → QA)
- **`task-breakdown`**: Exhaustive planning only (detailed task decomposition)
- **`implementation-only`**: Skip planning, go straight to implementation

### Key Patterns

1. **TDD (Test-Driven Development)**: Red → Green → Refactor
2. **Ralph Wiggum Pattern**: Blocking checkpoints with auto-correction loops
3. **DDD (Domain-Driven Design)**: Domain → Application → Infrastructure layers
4. **Context Management**: Strategic checkpoints for session resumption

## Commands

| Command | Description |
|---------|-------------|
| `/workflows:start` | Initialize a new feature workspace |
| `/workflows:role` | Work as a specific role on a feature |
| `/workflows:sync` | Pull latest changes from other roles |
| `/workflows:checkpoint` | Save progress at a stopping point |
| `/workflows:status` | View status of all roles |

## Skills

| Skill | Description |
|-------|-------------|
| `git-sync` | Safe repository synchronization |
| `checkpoint` | Quality-gated progress saving |
| `consultant` | AI-powered project analysis |

## State Management

All roles communicate via `50_state.md`:

```markdown
## Backend Engineer
**Status**: IN_PROGRESS
**Checkpoint**: Domain layer complete
**Notes**: Working on Application layer
```

Status values: `PENDING`, `IN_PROGRESS`, `BLOCKED`, `WAITING_API`, `COMPLETED`, `APPROVED`, `REJECTED`

## Rules

The plugin includes three rule sets:

1. **Global Rules** (`global_rules.md`): Universal rules for all roles
2. **DDD Rules** (`ddd_rules.md`): Domain-Driven Design patterns
3. **Project Specific** (`project_specific.md`): Customizable per-project rules

## Best Practices

1. **One role per session**: Don't switch roles mid-conversation
2. **Sync before work**: Always pull latest changes first
3. **Checkpoint frequently**: Save progress every 1-2 hours
4. **TDD always**: Write tests before implementation
5. **Document blockers**: Update state when stuck

## Integration

This plugin works best with:
- **Tilix terminal**: For running 4 roles in parallel (2x2 grid)
- **Git**: For synchronization between agents
- **Symfony/React**: Optimized for this stack (but adaptable)
