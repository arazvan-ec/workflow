---
name: workflows:compound
description: "Capture learnings after completing a feature to make future work easier. The compounding effect of engineering."
argument_hint: <feature-name>
---

# Multi-Agent Workflow: Compound

Capture insights from completed features to make future development easier.

## Philosophy

> "Each unit of engineering work should make subsequent units easier—not harder"
> — Compound Engineering Principle

The `/workflows:compound` command is the key differentiator of compound engineering.
Without it, you're just doing work. With it, work builds on work.

## The 70% Problem Awareness

> "AI helps you reach 70% quickly, but the remaining 30% is where real complexity lives." — Addy Osmani

Capture where the 70% boundary was (scaffolding/CRUD/happy paths = fast) and what made the 30% hard (edge cases, security, integration). This helps future planning account for real complexity.

## Prerequisites

Read `openspec/changes/{slug}/tasks.md` and verify:
- QA status = APPROVED. If REJECTED: STOP → fix issues and re-review. If not reviewed: STOP → `/workflows:review` first.

## Usage

```bash
# After QA approval (includes automatic spec updates)
/workflows:compound user-authentication

# Disable automatic spec updates
/workflows:compound user-authentication --update-specs=false

# Only update specs (skip other compound steps)
/workflows:compound user-authentication --specs-only
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--update-specs` | `true` | Automatically update project specs after feature completion |
| `--specs-only` | `false` | Only perform spec updates, skip pattern capture and other compound steps |

## When to Run

Run after:
- ✅ Feature is APPROVED by QA
- ✅ All tests passing
- ✅ Ready to merge

## What This Command Does

### Execution Strategy

Optionally launch parallel subagents (Context Analyzer, Solution Extractor, Related Docs Finder, Prevention Strategist, Pattern Recognizer) for thorough documentation.

**Sequential Steps (Main Flow):**

### Step 1: Analyze Feature History

```bash
# Get all commits for the feature
git log --oneline feature/${FEATURE_ID}

# Get diff from base branch
git diff main...feature/${FEATURE_ID}

# Analyze files changed
git diff --stat main...feature/${FEATURE_ID}
```

### Step 2: Extract Patterns

Identify what went well. For each pattern: where (file path), why it worked, recommendation for reuse.

### Step 3: Identify Anti-Patterns & The 70% Boundary

For each anti-pattern: where, what happened, cost, rule to prevent.

**70% Boundary Analysis**: Document where progress slowed (milestone), what made the 30% hard (edge cases, security, integration), what would have helped, and prevention for future features.

**Dimensional Learnings** (if architecture diagnostic exists):
1. **Accuracy**: Did diagnostic correctly classify dimensions?
2. **Drift**: Did this feature change any dimension? If so → recommend `/workflows:discover --refresh`
3. **Constraint effectiveness**: Which constraints from design.md prevented bugs vs felt unnecessary?

### Step 3b: Update Agent Compound Memory

Update `.ai/project/compound-memory.md` with this feature's data:

1. **Pain points**: Existing → increment frequency. `[SEED]` + accurate → PROMOTE (remove tag). `[SEED]` + wrong → UPDATE as `[SEED-UPDATED]`. New → add entry.
2. **Patterns**: Same logic as pain points (promote/update/add).
3. **Stale seeds**: `[SEED]` not referenced in 3+ features → mark `[SEED-STALE]`.
4. **Agent Calibration**: ≥2 pain points → HIGH intensity. ≥3 reliable patterns → may LOWER intensity.
5. **Promotion**: Pattern/pain point present ≥5 features → PROMOTE to `global_rules.md`.

### Step 3c: Enrich Architecture Profile

Update `openspec/specs/architecture-profile.yaml` (skip if missing — run `/workflows:discover --setup` first):
- **learned_patterns**: Add new (confidence: low) or increment existing (low→medium→high)
- **learned_antipatterns**: Add new (frequency: 1) or increment existing
- **reference_files**: Update if better exemplars found
- **quality_thresholds**: Adjust if actual data differs from defaults

### Step 4: Update Project Rules

If patterns are generalizable, add them to `global_rules.md` with source feature reference.

### Step 5: Create Compound Log Entry

Append to `.ai/project/compound_log.md` with sections:
- **Summary**: What was implemented, iteration count
- **Time Investment**: Per phase (planning, implementation, review, compound)
- **Patterns to Reuse**: Pattern name, file paths, tests
- **Rules Updated**: Which rule files changed
- **Anti-Patterns Documented**: What happened, cost, prevention
- **Specs Updated**: Tables of entities, API contracts, business rules created/modified (with action + file)
- **Impact on Future Work**: Reusable assets, estimated time savings, open questions

### Step 6: Update Feature Templates

If new templates discovered, save successful patterns as templates in `.ai/workflow/templates/`.

### Step 6b: Generate Next Feature Briefing

Write `.ai/project/next-feature-briefing.md` (overwritten each compound run) with:
- **Reusable Patterns**: Pattern, files, confidence, when to use
- **Known Risks**: Risk, area, mitigation, source
- **Recommended Test Strategy**: Integration test priorities, recurring edge cases
- **Time Calibration**: Expected vs actual per phase
- **70% Boundary Warning**: Where complexity started, areas to plan for

This is the forward-looking output — Plan reads it in Step 0.0d, Work in Step 3.5.

### Spec Flow Pipeline

The spec flow ensures feature-level specs merge into the project baseline:

```
/workflows:plan → openspec/changes/{slug}/specs.md (feature specs)
                                    ↓
/workflows:compound → Step 7: Diff Analysis (compare feature vs baseline)
                                    ↓
                    → Step 8: Merge to openspec/specs/ (project baseline)
```

Plan Phase 2 reads `openspec/specs/` as baseline context before generating feature specs. Compound closes the loop by merging feature changes back into the baseline.

### Step 7: Spec Diff Analysis

Compare feature specs (`specs.md`, `design.md`) with project baseline (`openspec/specs/`):

1. Parse feature specs → extract entities, acceptance criteria, business rules
2. Parse feature solutions → extract patterns, API contracts, architectural decisions
3. Compare with existing `openspec/specs/{entities,api-contracts,business-rules}/`
4. Generate diff report: NEW / MODIFIED / UNCHANGED for each entity, endpoint, rule, pattern

### Step 8: Update Project Specs

Skip if `--update-specs=false`. Otherwise update project baseline:

- **8.1 Entity Specs**: Create/update `openspec/specs/entities/{entity}.md` with YAML frontmatter (entity, version, source_feature), properties table, invariants, related entities
- **8.2 API Contract Specs**: Create/update `openspec/specs/api-contracts/{group}.md` with endpoints, request/response schemas, error responses
- **8.3 Business Rules Specs**: Create/update `openspec/specs/business-rules/{domain}.md` with rule IDs, enforcement, errors
- **8.4 Spec Manifest**: Update `openspec/specs/spec-manifest.yaml` with entities, api_contracts, business_rules, and history entry

Use `/workflow-skill:spec-merger --feature=${FEATURE_ID} --source=openspec/changes/${FEATURE_ID}/ --target=openspec/specs/ --mode=merge` for intelligent merging with backup.

## Compound Checklist

- [ ] Analyzed git history for patterns
- [ ] Documented successful patterns (2-3)
- [ ] Documented anti-patterns (1-2)
- [ ] **Identified the 70% boundary** (where progress slowed)
- [ ] **Documented what made the 30% hard**
- [ ] **Listed preventions for future features**
- [ ] **Updated compound-memory.md** (Step 3b: pain points, patterns, agent calibration)
- [ ] **Cross-referenced validation-learning-log.md** (promote mature patterns, reconcile with compound captures)
- [ ] Updated relevant project rules
- [ ] Added entry to compound_log.md
- [ ] Created/updated templates if applicable
- [ ] **Generated next-feature-briefing.md** (Step 6b: reusable patterns, risks, test strategy, time calibration)
- [ ] Estimated time savings for future work
- [ ] **Captured dimensional learnings** (diagnostic accuracy, drift, constraint effectiveness)
- [ ] **Recommended diagnostic refresh** if any dimension changed
- [ ] **Generated spec diff report** (Step 7)
- [ ] **Updated project specs** (Step 8, unless --update-specs=false)
  - [ ] Updated/created entity specs
  - [ ] Updated/created API contract specs
  - [ ] Updated/created business rules specs
  - [ ] Updated spec-manifest.yaml with history

## Output

Display summary showing: patterns captured, anti-patterns documented, rules updated, templates created, spec diff analysis (new/modified entities/endpoints/rules), project specs updated (file list with CREATED/UPDATED), estimated time savings, and next feature recommendation.

Variations: `--specs-only` skips pattern capture. `--update-specs=false` skips spec updates.

## Compound Metrics

Track compounding effect: time per feature should decrease as patterns accumulate. Log per-feature metrics (planning, implementation, review, compound, total, patterns new/reused) in `compound_log.md`.

## State Update

Update `tasks.md` Phase Status: all phases COMPLETED, Compound = COMPLETED. Add Compound Summary with patterns captured, rules updated, estimated time savings.

## Best Practices

1. **Run immediately after QA approval** — context is fresh
2. **Be specific about patterns** — include file paths
3. **Quantify impact** — "Saved 2 iterations" not "was helpful"
4. **Update rules** — make patterns enforceable
5. **Reference future work** — connect to next features

## Structured Documentation (docs/solutions/)

For permanent knowledge, create files in `docs/solutions/{category}/` (categories: performance-issues, database-issues, runtime-errors, security-issues, integration-issues, ui-bugs, logic-errors, test-failures, build-errors, best-practices, patterns) with YAML frontmatter (title, category, tags, module, component, symptoms, root_cause, severity, date_discovered, feature_origin).

Create when: problem took >30min to diagnose, root cause non-obvious, applies to multiple modules, security/data issue, or performance >50% degradation.

## Integration

- **Review agents**: security-reviewer, performance-reviewer, architecture-reviewer can enhance documentation
- **Integrates with**: `/workflows:plan` (learnings inform plans), `learnings-researcher` agent, `validation-learning-log` skill, `spec-merger` skill, `compound_log.md`, `openspec/specs/` baseline, `spec-manifest.yaml`
- **Spec flow**: Feature specs (`openspec/changes/{slug}/`) → diff analysis → merge to baseline (`openspec/specs/{entities,api-contracts,business-rules}/`) → update manifest

---

## Retrospective

After compound capture is complete, generate a brief retrospective:

```markdown
# Retrospective: ${FEATURE_ID}

## What went well
- [1-3 bullet points]

## What could improve
- [1-3 bullet points]

## Surprises / Lessons
- [Unexpected findings during implementation or review]

## Metrics
- Planning phases: [N]
- Implementation tasks: [N] completed, [N] blocked
- Review cycles: [N] (rejections before approval)
- BCP activations: [N] (by deviation type)
```

Write this to `openspec/changes/${FEATURE_ID}/99_retrospective.md`. This file is optional but recommended for features with `planning_depth=full` or features that required multiple review cycles.

---

## Error Recovery

- **QA status not APPROVED**: Compound requires QA APPROVED status. If status is REJECTED, do not proceed — fixes must be implemented and re-reviewed first.
- **Spec-merger conflicts with baseline**: If merging feature specs into `openspec/specs/` produces conflicts, present both versions to the user. User decides which version becomes the new baseline.
- **Missing compound_log.md**: Create it fresh. The log is append-only — a missing file means this is the first compound capture for the project.
- **Feature artifacts incomplete**: If proposal.md, specs.md, design.md, or tasks.md are missing from `openspec/changes/${FEATURE_ID}/`, log a warning and capture what's available. Do not block compound on missing optional artifacts.
