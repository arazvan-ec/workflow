# Phase 4: Tasks (Task Breakdown + Decision Log)

## Task Template (includes SOLID)

Each task must include SOLID requirements:

```markdown
### Task BE-001: [Task Name]

**Role**: [Backend Engineer | Frontend Engineer | etc.]
**Methodology**: TDD (Red-Green-Refactor)

**Functional Requirement** (from SPEC-Fxx):
- [requirement]

**SOLID Requirements** (from solution design):
- **[principle]**: [requirement]
- **Pattern**: [pattern to use]

**Tests to Write FIRST**:
- [ ] test_[scenario]()

**Acceptance Criteria**:
- [ ] [file location]
- [ ] [architecture compliance]

**Reference**: [existing pattern file]
```

## Decision Log Enforcement (MANDATORY)

Every non-obvious design decision MUST be logged in `tasks.md`:

```markdown
## Decision Log

| # | Decision | Alternatives Considered | Rationale | Phase | Risk |
|---|----------|------------------------|-----------|-------|------|
| D-001 | [decision] | [alternatives] | [why] | [phase] | [risk level] |
```

## Self-Review (Reflection Pattern - MANDATORY before Completeness Verification)

```
SELF-REVIEW PROTOCOL:

1. DESIGN COHERENCE: Re-read design.md end-to-end
   - Does each solution solve the spec it references?
   - Contradictions between solutions?
   - Could any solution be simpler?

2. TESTABILITY CHECK: Re-read test contract sketch
   - Can every criterion be tested with the designed architecture?
   - Hidden dependencies?

3. INTEGRATION SANITY: Compare design.md against openspec/specs/ baseline
   - Conflicts with existing patterns?
   - Backward-compatible changes?

4. DECISION LOG AUDIT: Review the Decision Log
   - Every non-obvious choice documented?
   - Implicit decisions that should be explicit?

IF issues found → Fix BEFORE presenting to user
IF no issues → Proceed to Completeness Verification
```

## Plan Completeness Verification (MANDATORY before marking COMPLETED)

1. **Files exist**: All output files exist in `openspec/changes/${FEATURE_ID}/`
2. **Substantive content**: Each file has >=5 non-header content lines
3. **Cross-reference**: Every requirement maps to >=1 spec, every spec to >=1 task
4. **Decision Log**: tasks.md contains >=1 decision entry
5. **Test Contract Sketch**: specs.md contains test mapping (for full/standard depth)
6. **Self-Review done**: Protocol executed, fixes logged
7. **User confirmation**: Present summary, ask: "Ready for /workflows:work? (yes/review/revise)"
8. **Mark COMPLETED**: Update tasks.md Workflow State
