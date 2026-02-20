# Phase 2: Specs (Requisitos Funcionales)

Defines **WHAT** the system must do - functional requirements from the user's perspective.

> **Spec Flow**: Phase 2 reads `openspec/specs/` as baseline, writes to `openspec/changes/${FEATURE_ID}/specs.md`. After implementation, `/workflows:compound` merges into baseline.

## Functional Specs

```markdown
## Functional Specs: ${FEATURE_ID}

### SPEC-F01: [Functional Requirement 1]
**Description**: [What it must do - from user perspective]
**Acceptance Criteria**:
- [ ] [Testable criterion]
- [ ] [Testable criterion]
**Verification**: [How to test]
```

| Good Spec (WHAT) | Bad Spec (HOW) |
|-----------------|-----------------|
| "User can register with email and password" | "Use Strategy pattern" |
| "System validates email format" | "Create EmailValidator class" |

**SOLID, patterns, and technical decisions belong in Phase 3, not here.**

## Integration Analysis (when --show-impact=true)

### Step 2.A: Identify Integration Points

For each category (entities, API contracts, business rules), classify as:
- **EXTENDED**: Existing items with new properties/methods
- **MODIFIED**: Existing items with changed behavior
- **NEW**: Items created by this feature

### Step 2.B: API Contract Design (for new/modified endpoints)

Apply RESTful conventions: resource-based URLs, consistent schemas, match existing project conventions.

### Step 2.C: Conflict Detection

```bash
/workflow-skill:spec-analyzer --feature=${FEATURE_ID} --check-conflicts
```

**When planning_speed=fast**: Skip spec-analyzer invocation. Defer conflict detection to `/workflows:review`.

## Phase 2 Quality Gate

Checks before writing `specs.md`:

1. **WHAT not HOW**: Each spec describes functional requirements. FAIL if contains implementation details.
2. **Testable criteria**: >=2 acceptance criteria per spec, each verifiable. FAIL if missing or vague.
3. **Full scope**: Every user requirement maps to at least one spec. FAIL if gaps.
4. **Substantive integration**: Integration analysis identifies extended/modified/new entities AND endpoints. FAIL if all say "None" for non-trivial feature.

## HITL Checkpoint: Phase 2 -> Phase 3

**When planning_speed=standard**: Present spec summary to user, ask: "yes / adjust / restart"
**When planning_speed=fast**: Auto-advance to Phase 3 (skip HITL).

## Phase 2.5: Test Contract Sketch (conditional: full or standard depth)

Outline test contracts before designing solutions:

```markdown
## Test Contract Sketch: ${FEATURE_ID}

### Test Mapping (per spec)
| Spec | Test Type | Key Scenarios | Edge Cases | Dependencies |
|------|-----------|---------------|------------|--------------|

### Test Boundaries
- **System boundary** (where to mock)
- **Trust boundary** (where to validate input)
- **Integration boundary** (where unit tests are insufficient)
```

Append to `specs.md` after functional specs section.
