# Step 0: Load Project Specs (Architecture Context)

Before planning any new feature, load and understand the existing project architecture.

## Compound Loading Scope

Read `core/providers.yaml` → `thresholds.step0_compound_scope` for the active `planning_depth`:

```
IF planning_depth == "full":     Load ALL compound sources (5 files)
IF planning_depth == "standard": Load compound-memory.md + architecture-profile.yaml ONLY
IF planning_depth == "minimal":  Load architecture-profile.yaml ONLY
```

## Step 0.0: Load Implementation Preferences (if exists)

```bash
PREFERENCES="openspec/changes/${FEATURE_ID}/01_preferences.md"
if [ -f "$PREFERENCES" ]; then
  # Read technology choices, architecture preferences, code style, constraints
  # Do NOT re-ask questions already answered in 01_preferences.md
fi
```

## Step 0.0b: Check for Shaped Brief (if exists)

```bash
SHAPED_BRIEF="openspec/changes/${FEATURE_ID}/01_shaped_brief.md"
if [ -f "$SHAPED_BRIEF" ]; then
  # Read shaped brief, breadboard, slices
  # Accelerate Phase 1 and Phase 2 with existing context
fi
```

## Step 0.0c: Load Project Constitution (if exists)

```bash
CONSTITUTION="openspec/specs/constitution.md"
if [ -f "$CONSTITUTION" ]; then
  # Read architecture principles, quality standards, technology constraints
  # ALL planning decisions must be consistent with constitution.md
fi
```

## Step 0.0d: Load Compound Learnings (Scope-Dependent)

Load only the compound sources specified by `step0_compound_scope` for the active depth:

### Full Depth (all 5 sources)

| # | File | What to Extract |
|---|------|----------------|
| 1 | `.ai/project/compound-memory.md` | Pain points, reliable patterns, agent calibration |
| 2 | `openspec/changes/*/99_retrospective.md` | Lessons from similar past features |
| 3 | `openspec/specs/architecture-profile.yaml` | Learned patterns/anti-patterns with confidence levels |
| 4 | `.ai/project/compound_log.md` | Past feature scope and time calibration |
| 5 | `.ai/project/next-feature-briefing.md` | Actionable recs, risks, test strategy for next feature |

### Standard Depth (2 sources)

| # | File | What to Extract |
|---|------|----------------|
| 1 | `.ai/project/compound-memory.md` | Pain points and reliable patterns |
| 3 | `openspec/specs/architecture-profile.yaml` | Learned patterns/anti-patterns |

### Minimal Depth (1 source)

| # | File | What to Extract |
|---|------|----------------|
| 3 | `openspec/specs/architecture-profile.yaml` | Pattern reference only |

**How compound learnings inform planning:**

| Compound Data | Used In | How |
|--------------|---------|-----|
| Pain points | Phase 2 (specs) | Add acceptance criteria for known pain areas |
| Learned patterns | Phase 3 (design) | Default to proven patterns |
| Learned anti-patterns | Phase 3 (design) | Add "## Avoid" section |
| Retrospectives | Phase 1 (understand) | Calibrate complexity with real data |
| Next feature briefing | Phase 2 + 3 | Apply risk mitigations, reuse patterns |

## Step 0.1: Read Existing Specifications

```bash
SPECS_BASE="openspec/specs"
# Load: entities, api-contracts, business-rules, architectural-constraints
```

## Step 0.2: Display Specs Summary (when --show-impact=true)

Summarize loaded specs as a table and display to user.
