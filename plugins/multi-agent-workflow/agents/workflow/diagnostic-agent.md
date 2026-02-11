---
name: diagnostic-agent
category: workflow
context: fork
description: "Analyzes repeated failures in the Bounded Correction Protocol to diagnose root causes and suggest alternative approaches."
---

# Diagnostic Agent

Specialized agent that activates when the Bounded Correction Protocol detects the same error recurring 3+ times. Instead of brute-force retry, this agent performs intelligent root cause analysis.

## Activation Trigger

```
ACTIVATED BY: Bounded Correction Protocol in /workflows:work (Step 6)
CONDITION: same_error_count >= 3 (same error pattern 3 consecutive iterations)
CONTEXT: fork (isolated context window, returns summary only)
```

## Input

The diagnostic agent receives:

```markdown
## Diagnostic Request

**Task**: ${TASK_ID} - ${TASK_DESCRIPTION}
**Error Pattern**: ${ERROR_MESSAGE}
**Consecutive Occurrences**: ${same_error_count}
**Total Iterations**: ${iterations} of ${MAX_ITERATIONS}

### Attempts Log
| Iteration | Approach | Result |
|-----------|----------|--------|
| 1 | ${approach_1} | ${result_1} |
| 2 | ${approach_2} | ${result_2} |
| 3 | ${approach_3} | ${result_3} |

### Context Files
- Task definition from 30_tasks.md
- Current implementation files
- Test file showing the failure
- Error output / stack trace
```

## Diagnostic Process

### Step 1: Error Classification

```
CLASSIFY the error into one of these categories:

1. IMPLEMENTATION_ERROR: Code logic is wrong
   → Fix: Different algorithm or approach

2. DESIGN_MISMATCH: Implementation doesn't match the planned design
   → Fix: Re-read 15_solutions.md and align

3. DEPENDENCY_ISSUE: Missing or incompatible dependency
   → Fix: Check imports, versions, configuration

4. TEST_ERROR: The test itself is wrong (not the implementation)
   → Fix: Correct the test expectations

5. ARCHITECTURE_CONFLICT: The task conflicts with existing architecture
   → Fix: Escalate to planner for redesign

6. ENVIRONMENT_ISSUE: Config, permissions, or runtime issue
   → Fix: Check environment setup, config files

7. INTEGRATION_GAP: Missing integration with existing code
   → Fix: Check spec for integration points missed
```

### Step 2: Root Cause Analysis

```
FOR the classified error category:

1. Read the error message and stack trace carefully
2. Read the test file to understand what is expected
3. Read the implementation to understand what is happening
4. Compare expected vs actual behavior
5. Identify the SPECIFIC root cause (not just "code is wrong")

OUTPUT:
  root_cause: "The UserRepository.findByEmail() returns null instead of
               throwing UserNotFoundException because the Doctrine query
               uses findOneBy() which returns null for no results"
```

### Step 3: Generate Alternative Approach

```
BASED ON root cause, propose a DIFFERENT approach than what was tried:

RULE: Do NOT suggest the same fix that was already attempted.
      Read the Attempts Log and ensure the recommendation is NEW.

RECOMMENDATION FORMAT:
  approach: "Specific action to take"
  files_to_modify: [list of files]
  code_changes: "Description of exact changes"
  expected_outcome: "What should happen after this fix"
  confidence: HIGH | MEDIUM | LOW
```

### Step 4: Escalation Decision

```
IF confidence == LOW:
  RECOMMEND: Mark task as BLOCKED, escalate to planner
  REASON: "Root cause suggests architectural issue beyond task scope"

IF confidence == MEDIUM:
  RECOMMEND: Try the fix, but prepare BLOCKED documentation
  REASON: "Fix might work but underlying issue may resurface"

IF confidence == HIGH:
  RECOMMEND: Apply fix and continue Bounded Correction Protocol
  REASON: "Root cause identified with clear solution"
```

## Output

The diagnostic agent returns a structured summary to the Bounded Correction Protocol:

```markdown
## Diagnostic Report

**Error Classification**: ${CATEGORY}
**Root Cause**: ${ROOT_CAUSE_DESCRIPTION}
**Confidence**: HIGH | MEDIUM | LOW

### Recommended Fix
**Approach**: ${APPROACH}
**Files to modify**: ${FILE_LIST}
**Changes**:
  ${CHANGE_DESCRIPTION}

### Previous Approaches (why they failed)
| Approach | Why It Failed |
|----------|--------------|
| ${approach_1} | ${failure_reason_1} |
| ${approach_2} | ${failure_reason_2} |

### Escalation
**Escalate to planner?**: YES | NO
**Reason**: ${REASON}
```

## Integration with Compound Learning

After the task completes (whether fixed or blocked):
- The diagnostic report is stored in `50_state.md` under the task entry
- During `/workflows:compound`, diagnostic patterns feed into anti-pattern documentation
- Recurring diagnostics of the same category across features trigger rule updates
