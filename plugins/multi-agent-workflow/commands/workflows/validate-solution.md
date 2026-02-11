---
name: workflows:validate-solution
description: "Question AI-generated solutions before delivery. Validates assumptions, asks targeted questions, and logs learnings for continuous workflow improvement."
argument_hint: <feature-name> [--intensity=<strict|balanced|light>] [--skip-questions]
---

# Multi-Agent Workflow: Validate Solution

Challenge and validate AI-generated solutions before they reach the user or move to review.

## Philosophy

> "Toda solución de la IA tiene supuestos ocultos. Encontrarlos antes es engineering. Encontrarlos después es debugging."
> — AI Validation Principle

> "The best question is the one you don't need to ask — because you learned the answer last time."
> — Validation Learning Principle

This command implements **self-questioning**: the AI critically examines its own output, identifies hidden assumptions and blind spots, asks the user targeted questions when needed, and logs everything so future validations are smarter.

## Flow Position

```
PLAN → WORK → [VALIDATE-SOLUTION] → REVIEW → COMPOUND
                    │
                    ├── Read validation learning log
                    ├── Question assumptions
                    ├── Ask user (if needed)
                    ├── Update validation learning log
                    └── Produce validation report
```

This command sits between WORK and REVIEW. It can also be invoked:
- During PLAN (to validate architecture decisions)
- After REVIEW (to validate review findings)
- Standalone (for any solution validation)

### Plan-Phase Validation Mode

When invoked during planning (with `--phase=plan` or during active planning), validate-solution operates in plan-validation mode. This mode is automatically triggered by the Plan Completeness Verification in `/workflows:plan`.

```
IF invoked with --phase=plan OR during active planning:

  VALIDATE:
  1. Does 00_problem_statement.md address the user's actual request?
     - Compare against the original request text
     - Flag deviations or omissions

  2. Do specs in 12_specs.md cover all aspects of the request?
     - Map user requirements → specs
     - Flag missing coverage

  3. Do solutions in 15_solutions.md address all specs?
     - Map specs → solutions
     - Flag specs without solutions

  4. Are tasks in 30_tasks.md traceable to solutions?
     - Map solutions → tasks
     - Flag solutions without implementation tasks

  OUTPUT: Planning validation report noting gaps and deviations
  ACTION: If gaps found, return to the relevant phase for correction
```

## Flow Guard (prerequisite check)

```
PREREQUISITE CHECK:
  1. Is there a solution to validate?
     - From 50_state.md: work status = COMPLETED or IN_PROGRESS
     - From direct invocation: solution provided in context
     - NO solution found: STOP. Nothing to validate.

  2. Is validate-solution already COMPLETED for this feature?
     - YES: Confirm re-validation with user.
     - NO: Proceed.
```

## Usage

```bash
# Validate after work phase (standard flow)
/workflows:validate-solution user-authentication

# Validate with strict intensity (override calibration)
/workflows:validate-solution user-authentication --intensity=strict

# Validate without asking user questions (use defaults)
/workflows:validate-solution user-authentication --skip-questions

# Validate a specific solution (not from workflow state)
/workflows:validate-solution --context="Proposed caching strategy using Redis with 15min TTL"
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--intensity` | `auto` | Override validation intensity (strict, balanced, light). Auto reads from compound-memory calibration |
| `--skip-questions` | `false` | Use learned defaults instead of asking user. Only works when learning log has sufficient confidence |
| `--phase` | `auto` | Which phase's output to validate (plan, work, review). Auto-detects from 50_state.md |

## What This Command Does

### Step 1: Load Context

```markdown
1. Read the solution to validate:
   - If feature-name provided: Read from .ai/project/features/${FEATURE_ID}/
     - 15_solutions.md (plan phase output)
     - Implementation files (work phase output)
     - 50_state.md (current status)
   - If --context provided: Use the provided context directly

2. Load validation learning log:
   - READ .ai/project/validation-learning-log.md
   - Extract: Active Patterns, Preferences, relevant past entries
   - Note which learnings apply to this solution

3. Load compound memory:
   - READ .ai/project/compound-memory.md
   - Check: Agent calibration for solution-validator
   - Check: Known pain points relevant to this solution type

4. Determine intensity:
   - If --intensity flag: Use specified intensity
   - If compound-memory has calibration: Use adjusted intensity
   - Otherwise: Use "balanced" (default)
```

### Step 2: Invoke Solution Validator Agent

Launch the `solution-validator` agent with collected context:

```markdown
Agent: solution-validator (context: fork)

Input:
  - Solution content (from Step 1)
  - Validation learning log (applicable entries)
  - Compound memory (relevant pain points)
  - Intensity level

Output:
  - Validation report with:
    - Assumptions detected
    - Blind spots flagged
    - Learnings applied (from log)
    - Questions for user (if any)
    - Validation verdict
```

### Step 3: User Interaction (if needed)

If the validator generated questions:

```markdown
IF questions exist AND --skip-questions is false:
  1. Present questions to user grouped by priority:
     - MUST_ASK: Present and wait for answer
     - SHOULD_ASK: Present with default, accept or override
     - NICE_TO_KNOW: Present briefly, accept default if no response

  2. For each answer received:
     - Record in validation report
     - Update confidence scores
     - Check if answer contradicts any existing learning

IF --skip-questions is true:
  1. Use learned defaults for all questions
  2. Log: "Questions auto-answered from learning log"
  3. If any question has NO learned default (confidence < 50%):
     - WARN: "Cannot skip question Q${N} — no sufficient learning exists"
     - Present that question to user anyway
```

### Step 4: Update Validation Learning Log

```markdown
Invoke: validation-learning-log skill --record

Record:
  - Feature name and context
  - All questions asked + answers received
  - All assumptions validated + results
  - All blind spots checked + findings
  - All learnings applied from log
  - New learnings discovered

The skill will:
  - Create new entry LOG-XXX
  - Update pattern confidence counters
  - Check for promotion-ready patterns
  - Update metadata (effectiveness metrics)
```

### Step 5: Produce Validation Report

Store the report in the feature directory:

```markdown
Output file: .ai/project/features/${FEATURE_ID}/18_validation_report.md

Content: Full validation report from solution-validator agent
         + User answers (from Step 3)
         + Learning log updates (from Step 4)
```

### Step 6: Update State

```markdown
Update 50_state.md:

## Solution Validation
**Status**: VALIDATED | VALIDATED_WITH_CAVEATS | NEEDS_REVISION
**Date**: ${DATE}
**Questions Asked**: ${COUNT}
**Questions Avoided (learned)**: ${COUNT}
**Confidence Score**: ${SCORE}/10
**Caveats**: ${LIST or "None"}
```

## Automatic Integration

This command integrates automatically with the workflow:

| Trigger | Behavior |
|---------|----------|
| `/workflows:review` starts | Checks if validation was done. If not, suggests running it first |
| `/workflows:work` completes | Reminds to validate before review |
| `/workflows:compound` runs | Cross-references validation learnings with compound captures |

## Output

```
Solution validation complete for: ${FEATURE_NAME}

═══════════════════════════════════════════════════════════════
VALIDATION SUMMARY
═══════════════════════════════════════════════════════════════

Status: ✅ VALIDATED (confidence: 8.5/10)

Assumptions checked: 5
  ✓ 4 validated
  ⚠️ 1 needs monitoring (API latency assumption)

Blind spots checked: 12
  ✓ 11 clear
  ⚠️ 1 flagged (missing rollback strategy)

Questions asked: 2 (3 skipped via learnings)
Learning effectiveness: 60% questions avoided

═══════════════════════════════════════════════════════════════
LEARNINGS UPDATED
═══════════════════════════════════════════════════════════════

New patterns detected: 1
  PAT-015: "Team uses event sourcing for audit trails"

Patterns confirmed: 2
  PAT-001: Repository pattern (5/5 features — ready for promotion!)
  PAT-003: Redis for caching (3/4 features)

Preferences updated: 1
  PREF-003: Test naming style confirmed

═══════════════════════════════════════════════════════════════

Validation report: .ai/project/features/${FEATURE_ID}/18_validation_report.md
Next step: /workflows:review ${FEATURE_NAME}
```

## Checklist

- [ ] Loaded solution context
- [ ] Loaded validation learning log
- [ ] Loaded compound memory
- [ ] Ran solution-validator agent
- [ ] Asked user questions (if needed)
- [ ] Recorded all answers in learning log
- [ ] Updated pattern confidence
- [ ] Checked for promotion-ready patterns
- [ ] Generated validation report
- [ ] Updated 50_state.md

## Compound Effect

```
Feature 1: Asked 5 questions, learned 5 patterns
Feature 2: Asked 3 questions (2 learned), confirmed 3 patterns
Feature 3: Asked 1 question (4 learned), promoted 1 pattern to rules
Feature 4: Asked 0 questions — all answered from learnings ✓

Learning effectiveness: 0% → 40% → 80% → 100%
```

The validation system gets smarter with every feature. This is compound engineering applied to the validation process itself.

## Best Practices

1. **Run after work, before review** — validation report enriches the review
2. **Don't skip questions on first 3 features** — build the learning base first
3. **Review promoted patterns periodically** — ensure they're still valid
4. **Commit the learning log** — share knowledge across the team
5. **Use --intensity=strict for critical features** — security, payments, data migrations
