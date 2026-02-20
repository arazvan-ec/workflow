# Phase 3: Design (Solutions + SOLID + Architectural Impact)

Defines **HOW** to implement each spec. **SOLID compliance is mandatory**.

## The SOLID Constraint

All solutions MUST comply with SOLID principles:
1. Analyzed per principle (SRP, OCP, LSP, ISP, DIP)
2. Use appropriate design patterns
3. COMPLIANT to proceed, NEEDS_WORK requires revision, NON_COMPLIANT blocks

## Step 3.1: Analyze Existing Code (SOLID Baseline)

**When planning_speed=standard**:
```bash
/workflow-skill:solid-analyzer --mode=baseline --path=src/relevant-module
```

**When planning_speed=fast**: Perform inline SOLID assessment (skip forked solid-analyzer). Analyze the affected module's patterns directly from file reads.

## Step 3.1b: API Architecture Constraints (if diagnostic exists)

Only when `openspec/specs/api-architecture-diagnostic.yaml` exists:

1. **Filter Relevant Dimensions**: Only dimensions touching this feature's code paths
2. **Generate Constraints**: MUST/SHOULD/REVIEW per relevant dimension
3. **Inject Into Design**: Categorize by enforcement level for Step 3.2

**When planning_speed=fast**: Skip dimensional analysis. Use architecture-profile.yaml patterns as constraints.

## Step 3.2: Design Solutions with SOLID

For EACH functional spec, propose a solution:

```markdown
### Solution for SPEC-F01: [Name]

**Approach**: [Implementation strategy]

**SOLID Compliance**:
- **SRP**: [verdict] - [reasoning]
- **OCP**: [verdict] - [reasoning]
- **LSP**: [verdict or N/A] - [reasoning]
- **ISP**: [verdict] - [reasoning]
- **DIP**: [verdict] - [reasoning]

**Files to Create/Modify**:
- [file paths with SRP justification]
```

## Step 3.3: Pattern Selection Guide

| If You Need... | Use Pattern | SOLID Addressed |
|----------------|-------------|-----------------|
| Multiple behaviors/algorithms | **Strategy** | OCP, SRP |
| Add functionality without modification | **Decorator** | OCP, SRP |
| Abstract object creation | **Factory Method** | DIP, OCP |
| Integrate external systems | **Adapter / Ports & Adapters** | DIP, OCP |
| Abstract data persistence | **Repository** | SRP, DIP |

See `core/architecture-reference.md` for complete mapping.

## Step 3.4: Verify SOLID Compliance

**When planning_speed=standard**:
```bash
/workflow-skill:solid-analyzer --mode=design --design=design.md
```

**When planning_speed=fast**: Inline verification (review SOLID verdicts from Step 3.2 without forked skill).

| Verdict | Action |
|---------|--------|
| All COMPLIANT | Proceed to implementation |
| Any NEEDS_WORK | Revise design |
| Any NON_COMPLIANT | Blocked, redesign required |

## Step 3.5: Architectural Impact Analysis (when --show-impact=true)

Layer analysis, affected files diagram, change scope summary, risk assessment.

## Phase 3.5: Security Threat Analysis (conditional: planning_depth=full)

Attack surface, trust boundaries, sensitive data, mitigation strategies.

## Phase 3 Quality Gate

Checks before writing `design.md`:

1. **Spec coverage**: Every spec from Phase 2 has a solution. FAIL if gaps.
2. **Concrete files**: Each solution lists actual file paths. FAIL if abstract.
3. **SOLID verdicts**: Each principle has a reasoned verdict. FAIL if missing reasoning.
4. **Architectural impact**: Specific layers and files listed. FAIL if empty or "TBD".
