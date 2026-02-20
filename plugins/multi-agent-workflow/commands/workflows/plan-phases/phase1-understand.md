# Phase 1: Understand (Entender el Problema)

## Step 1.1: Analyze the Request

```markdown
## Request Analysis

**Original Request**: [user's exact words]
**Request Type**: [feature | refactor | bugfix | architecture | investigation]
**Affected Areas**: [modules/services involved]
**Confidence Level**: [0-100%]
```

## Step 1.2: Ask Clarifying Questions (if confidence < 60%)

| Question Category | Example Questions |
|-------------------|-------------------|
| **Functional Scope** | What must it do? What must it NOT do? |
| **Users/Actors** | Who will use this functionality? |
| **Integration** | External APIs? Affected systems? |
| **Constraints** | Time/technology/performance restrictions? |
| **Success Criteria** | How do we know it's complete and working? |

## Step 1.3: Document the Understood Problem

```markdown
## Problem Statement

### What We're Building
[Clear description]

### Why It's Needed
[Business justification]

### Who Benefits
[Users/stakeholders]

### Constraints
- Technical: [stack, performance, integrations]
- Business: [timeline, budget, compliance]

### Success Criteria
1. [Measurable criterion 1]
2. [Measurable criterion 2]
```

## Phase 1 Quality Gate

Checks before writing `proposal.md`:

1. **Specific to request**: References user's exact words/intent. FAIL if generic/templated.
2. **Substantive content**: >=10 non-header content lines. FAIL if only section headers.
3. **Measurable criteria**: Each success criterion is testable (pass/fail). FAIL if vague.
4. **Complete coverage**: All aspects of user's request addressed. FAIL if significant gaps.

**CDP check**: If request contradicts `constitution.md` or existing specs, apply Contradiction Detection Protocol (`framework_rules.md` section 12).
