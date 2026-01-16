---
name: workflows:start
description: "Initialize a feature with multi-agent coordination. Sets up workspace, assigns roles, and begins the workflow."
argument_hint: <feature-name> [workflow-type]
---

# Multi-Agent Workflow: Start

Initialize a new feature for parallel development with specialized AI agents.

## Usage

```
/workflows:start user-authentication
/workflows:start payment-system task-breakdown
```

## Arguments

- `feature-name`: Name for the feature (kebab-case)
- `workflow-type`: (optional) Workflow template to use
  - `default` - Standard 4-role workflow (Plan → Backend → Frontend → QA)
  - `task-breakdown` - Exhaustive planning only (detailed task decomposition)
  - `implementation-only` - Skip planning, go straight to implementation

## What This Command Does

1. **Creates feature workspace** at `.ai/project/features/<feature-name>/`
2. **Initializes state file** `50_state.md` with all role sections
3. **Copies workflow template** for the selected workflow type
4. **Sets up role assignments** ready for parallel work

## Execution Steps

Run these steps in order:

### Step 1: Validate Arguments
- Ensure feature-name is provided
- Default workflow-type to "default" if not specified
- Validate workflow-type is one of: default, task-breakdown, implementation-only

### Step 2: Create Feature Workspace

```bash
FEATURE_ID="$ARGUMENTS"
WORKSPACE=".ai/project/features/${FEATURE_ID}"

mkdir -p "${WORKSPACE}"
```

### Step 3: Initialize State File

Create `50_state.md` with this template:

```markdown
# Feature State: ${FEATURE_ID}

## Overview
**Feature**: ${FEATURE_ID}
**Workflow**: ${WORKFLOW_TYPE}
**Created**: $(date -Iseconds)
**Status**: PLANNING

---

## Planner / Architect
**Status**: PENDING
**Assigned**: Not yet assigned
**Notes**: Waiting to start planning

---

## Backend Engineer
**Status**: PENDING
**Assigned**: Not yet assigned
**Notes**: Waiting for planning to complete

---

## Frontend Engineer
**Status**: PENDING
**Assigned**: Not yet assigned
**Notes**: Waiting for planning to complete

---

## QA / Reviewer
**Status**: PENDING
**Assigned**: Not yet assigned
**Notes**: Waiting for implementation to complete
```

### Step 4: Copy FEATURE Template

Create `FEATURE_${FEATURE_ID}.md`:

```markdown
# Feature: ${FEATURE_ID}

## Objective
[To be defined by Planner]

## Acceptance Criteria
- [ ] [To be defined]

## API Contracts
[To be defined by Planner]

## Tasks
### Backend
- [ ] [To be defined]

### Frontend
- [ ] [To be defined]

### QA
- [ ] [To be defined]
```

### Step 5: Display Next Steps

Output the following guidance:

```
Feature workspace created: .ai/project/features/${FEATURE_ID}/

Next steps:

1. Start as Planner to define the feature:
   /workflows:role planner ${FEATURE_ID}

2. Or start all roles in parallel (requires Tilix terminal):
   ./workflow start ${FEATURE_ID} ${WORKFLOW_TYPE} --execute

3. View workflow documentation:
   /workflows:help
```

## Post-Start Options

After initialization, you can:
- `/workflows:role planner <feature>` - Start working as Planner
- `/workflows:role backend <feature>` - Start working as Backend Engineer
- `/workflows:role frontend <feature>` - Start working as Frontend Engineer
- `/workflows:role qa <feature>` - Start working as QA Reviewer
