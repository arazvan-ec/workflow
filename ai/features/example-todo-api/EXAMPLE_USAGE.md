# How to Use This Example

This is a pre-configured example feature to help you learn the workflow system.

## Quick Test (Solo Mode - Sequential)

### Setup
```bash
# From project root
cd /home/user/workflow

# Verify example exists
./scripts/workflow list

# Should show:
#   example-todo-api [active]
```

### Step 1: Planning (Optional - already done)

The `definition.md` is pre-filled as an example. In a real workflow, you'd ask Claude to create this.

**Optional**: Ask Claude to create `tasks.md`:

```
I am the PLANNER for the example-todo-api feature.

Please:
1. Read ./ai/features/example-todo-api/definition.md
2. Create ./ai/features/example-todo-api/tasks.md breaking down the implementation into specific tasks
3. Update ./ai/features/example-todo-api/planner_state.md with status: COMPLETED
```

### Step 2: Backend Implementation

Start a new Claude Code session:

```
I am the BACKEND DEVELOPER for the example-todo-api feature.

Please:
1. Read ./ai/features/example-todo-api/workflow.yaml
2. Read ./ai/features/example-todo-api/definition.md
3. Follow the implementation stage instructions
4. Create a simple REST API in ./src/ for managing TODO items
5. Update ./ai/features/example-todo-api/backend_state.md as you work
```

Claude will implement:
- `src/todos.js` (or similar) with the REST API
- All 5 CRUD endpoints
- In-memory storage
- Error handling

### Step 3: QA Review

Start another Claude Code session:

```
I am the QA/REVIEWER for the example-todo-api feature.

Please:
1. Read ./ai/features/example-todo-api/workflow.yaml
2. Read ./ai/features/example-todo-api/definition.md
3. Review the implementation in ./src/
4. Create ./ai/features/example-todo-api/review.md with your findings
5. Update ./ai/features/example-todo-api/qa_state.md with status: APPROVED or REJECTED
```

### Step 4: Check Results

```bash
# View final status
./scripts/workflow status example-todo-api

# Should show:
#   planner:     COMPLETED
#   backend:     COMPLETED
#   qa:          APPROVED (or REJECTED)

# Read the review
cat ai/features/example-todo-api/review.md
```

## Advanced Test (Parallel Mode)

To test parallel workflow with multiple Claude instances:

### Setup Tilix (4 panes)

```
┌──────────────┬──────────────┐
│   Tab 1      │   Tab 2      │
│   (Planner)  │  (Backend)   │
├──────────────┼──────────────┤
│   Tab 3      │   Tab 4      │
│   (Monitor)  │   (QA)       │
└──────────────┴──────────────┘
```

### Tab 1: Planner
```bash
cd /home/user/workflow
claude

# Inside Claude:
"I am the PLANNER. Create tasks.md for example-todo-api feature."
```

### Tab 2: Backend (wait for Planner)
```bash
cd /home/user/workflow
git pull  # Get planner's work
claude

# Inside Claude:
"I am the BACKEND DEVELOPER. Implement the example-todo-api according to the definition."
```

### Tab 3: Monitor
```bash
cd /home/user/workflow

# Keep checking status
watch -n 5 './scripts/workflow status example-todo-api'
```

### Tab 4: QA (wait for Backend)
```bash
cd /home/user/workflow
git pull  # Get backend's work
claude

# Inside Claude:
"I am the QA/REVIEWER. Review the example-todo-api implementation."
```

## What You'll Learn

1. **File-based context**: How Claude instances communicate through files
2. **Role separation**: Each Claude has a specific responsibility
3. **State tracking**: How `*_state.md` files track progress
4. **Git synchronization**: How `git pull/push` keeps everyone in sync
5. **Workflow structure**: How YAML defines roles and stages

## Expected Output

After completing the workflow, you'll have:

```
ai/features/example-todo-api/
├── workflow.yaml          # Workflow definition
├── definition.md          # API specification (pre-filled)
├── tasks.md               # Task breakdown (created by Planner)
├── planner_state.md       # COMPLETED
├── backend_state.md       # COMPLETED
├── qa_state.md            # APPROVED
└── review.md              # QA findings

src/
└── todos.js               # REST API implementation (or similar)
```

## Cleanup

To reset the example and try again:

```bash
# Remove implementation
rm -rf src/

# Reset state files
git checkout ai/features/example-todo-api/*_state.md

# Remove generated files
rm -f ai/features/example-todo-api/tasks.md
rm -f ai/features/example-todo-api/review.md
```

## Next Steps

Once you've completed this example:

1. Create your own feature: `./scripts/workflow consult`
2. Try the DDD parallel workflow: `./scripts/workflow init my-feature ddd_parallel`
3. Customize templates in `ai/workflows/`
4. Read the full documentation in `README.md`

---

**Pro tip**: This example is intentionally simple. Real features will be more complex, but the workflow process is identical.
