# Multi-Agent Workflow Plugin

A Claude Code plugin for coordinating multiple AI agents working in parallel on software development tasks.

## Features

- **4 Specialized Roles**: Planner, Backend, Frontend, QA
- **Parallel Development**: Backend and Frontend can work simultaneously
- **Quality Gates**: Blocking checkpoints with auto-correction loops
- **Context Management**: Strategic checkpoints for session resumption
- **Git-Based Sync**: Seamless coordination between agents

## Installation

```bash
/plugin marketplace add https://github.com/arazvan-ec/workflow
/plugin install multi-agent-workflow
```

## Quick Start

### 1. Start a Feature

```bash
/workflows:start user-authentication
```

### 2. Work as a Role

```bash
# As Planner (first)
/workflows:role planner user-authentication

# As Backend (after planning)
/workflows:role backend user-authentication

# As Frontend (parallel with backend)
/workflows:role frontend user-authentication

# As QA (after implementation)
/workflows:role qa user-authentication
```

### 3. Check Status

```bash
/workflows:status user-authentication
```

## Workflow Templates

| Template | Use Case |
|----------|----------|
| `default` | Standard feature development |
| `task-breakdown` | Complex features needing detailed planning |
| `implementation-only` | When planning is done externally |

## Commands

| Command | Description |
|---------|-------------|
| `/workflows:start <feature>` | Initialize feature workspace |
| `/workflows:role <role> <feature>` | Work as a specific role |
| `/workflows:sync <feature>` | Pull latest changes |
| `/workflows:checkpoint <role> <feature> <msg>` | Save progress |
| `/workflows:status <feature>` | View all roles' status |

## The 4-Role System

### Planner / Architect
- Defines features and acceptance criteria
- Creates API contracts
- Breaks down tasks for each role
- Resolves blockers

### Backend Engineer
- Implements API following DDD
- Writes unit and integration tests
- Follows TDD (Red-Green-Refactor)
- Target: >80% test coverage

### Frontend Engineer
- Builds UI components
- Can mock API while backend develops
- Tests responsive design
- Target: Lighthouse score >90

### QA / Reviewer
- Validates against acceptance criteria
- Runs all test suites
- Creates detailed QA reports
- Approves or rejects features

## State Management

Communication happens via `50_state.md`:

```markdown
## Backend Engineer
**Status**: COMPLETED
**Checkpoint**: All layers implemented
**Tests**: 45/45 passing, 87% coverage
```

## The Ralph Wiggum Pattern

Blocking checkpoints with auto-correction:

```
while tests_failing and iterations < 10:
    fix_code()
    run_tests()
    if passing: checkpoint_complete()

if iterations >= 10:
    mark_blocked()
    document_for_help()
```

## Project Structure

```
plugins/multi-agent-workflow/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── roles/
│       ├── planner.md
│       ├── backend.md
│       ├── frontend.md
│       └── qa.md
├── commands/
│   └── workflows/
│       ├── start.md
│       ├── role.md
│       ├── sync.md
│       ├── checkpoint.md
│       └── status.md
├── skills/
│   ├── git-sync/
│   ├── checkpoint/
│   └── consultant/
├── rules/
│   ├── global_rules.md
│   ├── ddd_rules.md
│   └── project_specific.md
├── CLAUDE.md
└── README.md
```

## License

MIT

## Author

arazvan-ec
