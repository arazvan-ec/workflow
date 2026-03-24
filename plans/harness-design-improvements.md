# Harness Design Improvements Plan

**Source**: [Anthropic Engineering - Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)
**Date**: 2026-03-24
**Status**: IN_PROGRESS

## Context

Analysis of Anthropic's harness design article revealed 6 improvements applicable to our workflow framework. This plan implements all 6 with maximum parallelism.

## Dependency Analysis

```
T1 (scoring)      ─┐
T2 (calibration)   ├─ Wave 1 (parallel) ─── All touch different sections
T3 (context resets)│
T5 (playwright)    │
T6 (quality bar)  ─┘

T4 (harness audit) ── Wave 2 (after T2, shares compound.md)
```

## Tasks

### T1: Dimensional Scoring in Review (Wave 1)
**Impact**: High | **Effort**: Low
**Files**: `review.md`, `reviewer.md`, `code-reviewer.md`, `architecture-reviewer.md`

**What**: Replace binary PASS/FAIL with 1-5 dimensional scores in QA reports.
**Why**: Article shows evaluators need gradable metrics, not just checklists. Detects gradual quality degradation.

**Changes**:
- Add `## Quality Scores (1-5)` section to QA Report Template in `review.md`
- Add scoring dimensions: Spec Fidelity, Code Craft, Test Quality, Architecture Fit
- Add scoring rubric (what 1-5 means for each dimension)
- Add minimum threshold (average ≥ 3 to APPROVE, any dimension = 1 → REJECT)
- Update `reviewer.md` decision criteria to include score thresholds
- Add `Quality Score` field to code-reviewer and architecture-reviewer report templates

---

### T2: Evaluator Calibration in Compound (Wave 1)
**Impact**: High | **Effort**: Medium
**Files**: `compound.md`, review agent files

**What**: Track false positives/negatives to calibrate review agents over time.
**Why**: Article: "out-of-box evaluator agents approve mediocre work; effective QA demands multiple prompt refinement cycles."

**Changes**:
- Add `Step 3d: Evaluator Calibration` to `compound.md` after Step 3c
- Define calibration events: human-overrides-QA-approval (false positive), human-overrides-QA-rejection (false negative)
- Store in `compound-memory.md` under new `## Evaluator Calibration Log` section
- Review agents read calibration data to adjust strictness
- Add calibration summary to compound checklist and output

---

### T3: Context Resets Between Phases (Wave 1)
**Impact**: High | **Effort**: Medium
**Files**: `CONTEXT_ENGINEERING.md`, `SESSION_CONTINUITY.md`

**What**: Formalize clean context handoffs between PLAN → WORK → REVIEW.
**Why**: Article shows context resets > compaction for long sessions. Eliminates "context anxiety."

**Changes**:
- Add `## Phase Transition Protocol` section to `CONTEXT_ENGINEERING.md`
- Define structured handoff format per transition (plan→work, work→review)
- Each phase starts with clean context reading only its required artifacts
- Add handoff templates showing exactly what each phase loads
- Update `SESSION_CONTINUITY.md` with reset-vs-compaction guidance

---

### T4: Periodic Harness Audit (Wave 2 - after T2)
**Impact**: Medium | **Effort**: Low
**Files**: `compound.md`, `providers.yaml`

**What**: After N features, evaluate which framework components are still load-bearing.
**Why**: Article: "every component encodes an assumption about what the model can't do."

**Changes**:
- Add `Step 3e: Harness Audit` to `compound.md` (triggers every 5 features)
- Track which review agents/gates have caught real issues vs never fired
- Add `harness_audit` section to `providers.yaml` thresholds
- Recommend promoting unused gates from mandatory to optional

---

### T5: Playwright MCP for Review (Wave 1)
**Impact**: Medium | **Effort**: Low (documentation change, integration depends on MCP availability)
**Files**: `review.md`, `code-reviewer.md`

**What**: Enable real UI interaction in review phase via Playwright MCP.
**Why**: Article used Playwright MCP for evaluator to take screenshots, test real flows.

**Changes**:
- Add `### Phase 2b: Live UI Verification (Playwright MCP)` to `review.md`
- Define when to activate (frontend features, UI-heavy changes)
- Add Playwright interaction protocol: navigate, screenshot, verify flows
- Update `code-reviewer.md` UI Verification section with Playwright commands
- Graceful fallback when Playwright MCP not available

---

### T6: Quality Bar Steering in Specs (Wave 1)
**Impact**: Low-Medium | **Effort**: Low
**Files**: `plan.md`

**What**: Add intentionally directional `## Quality Bar` field to spec templates.
**Why**: Article: criterion wording like "museum quality" steered output convergence.

**Changes**:
- Add `## Quality Bar` section to Phase 2 spec template in `plan.md`
- Define quality dimensions with steering language
- Quality bar flows to review as evaluation anchor
- Examples of effective steering language

## Success Criteria

- [ ] All 6 improvements integrated into framework files
- [ ] No breaking changes to existing workflow commands
- [ ] Each improvement is independently useful (no cross-dependencies beyond T2→T4)
- [ ] Changes follow existing patterns and conventions in the codebase
