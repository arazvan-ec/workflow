---
name: workflow-skill-insights-manager
description: "Manage user insights and review AI-discovered patterns. Actions: add (capture new user insight), review (review pending AI discoveries), adjust (change influence/status of existing insights), list (show active insights for a phase). <example>Context: User wants to capture a collaboration pattern they've discovered.\\nuser: \"I've noticed that when I ask for interfaces before implementations, the code is more testable\"\\nassistant: \"I'll use workflow-skill-insights-manager --action=add to capture this insight\"</example>"
model: inherit
context: fork
hooks:
  Stop:
    - command: "echo '[insights-manager] Insights operation complete.'"
---

# Insights Manager Skill

Manage the bidirectional learning system between user and AI. This skill handles CRUD operations on `memory/user-insights.yaml` (user's meta-knowledge) and `memory/discovered-insights.yaml` (AI-detected patterns).

## Philosophy

> "The user accumulates knowledge about how to work with AI that the AI cannot discover on its own. This knowledge is too valuable to live only in the user's memory."

Insights are NOT rules. They are experience-backed heuristics with graduated influence levels that the agent consults at decision points.

---

## Invocation

```bash
# Add a new user insight (interactive)
/workflow-skill:insights-manager --action=add

# Add with pre-filled observation
/workflow-skill:insights-manager --action=add --observation="When I ask for SOLID, code scales better"

# Review pending AI discoveries
/workflow-skill:insights-manager --action=review

# Adjust an existing insight
/workflow-skill:insights-manager --action=adjust --id=solid-improves-scalability --influence=medium

# List active insights for a phase
/workflow-skill:insights-manager --action=list --phase=implementation

# Promote a discovered insight to user insights
/workflow-skill:insights-manager --action=promote --id=discovered-pattern-id

# Pause/resume an insight
/workflow-skill:insights-manager --action=pause --id=insight-id
/workflow-skill:insights-manager --action=resume --id=insight-id

# Retire an insight (no longer relevant)
/workflow-skill:insights-manager --action=retire --id=insight-id
```

---

## Action: Add (Capture New User Insight)

### Step 1: Gather Insight Details

If `--observation` is provided, use it. Otherwise, ask the user:

```markdown
## New User Insight

I'd like to capture your experience-based observation. Please provide:

1. **What have you observed?**
   (Describe the pattern you've noticed when working with AI)

2. **When should this apply?**
   Phases: routing, planning, design, implementation, review, refactoring, prototyping

3. **When should this NOT apply?**
   (Any contexts where this would be counterproductive)

4. **How strong is this pattern?**
   - **high**: Apply proactively every time
   - **medium**: Suggest when relevant
   - **low**: Only when I explicitly ask

5. **What evidence supports this?**
   (Examples, metrics, or observations)
```

### Step 2: Generate Insight Entry

```yaml
- id: {generated-kebab-case-from-observation}
  observation: "{user's observation}"
  when_to_apply: [{phases}]
  when_to_skip: [{excluded-contexts}]
  influence: {high|medium|low}
  evidence: "{user's evidence}"
  tags: [{auto-detected-tags}]
  created: "{today's date}"
  last_validated: "{today's date}"
  status: active
```

### Step 3: Validate and Write

1. READ `memory/user-insights.yaml`
2. Check for duplicate or conflicting insights:
   - If similar insight exists → ask user: merge, replace, or keep both?
   - If contradictory insight exists → flag the contradiction, ask user to resolve
3. APPEND new insight to the `insights:` list
4. WRITE updated `memory/user-insights.yaml`
5. Confirm to user with summary

---

## Action: Review (Review AI Discoveries)

### Step 1: Load Pending Discoveries

```bash
READ memory/discovered-insights.yaml
FILTER: status == "pending_review"
```

### Step 2: Present Each Discovery

For each pending discovery, present:

```markdown
## AI Discovery: {id}

**Observation**: {observation}
**Confidence**: {confidence} ({confidence_label})
**Evidence**:
{evidence list}

**Detected during**: {detected_during}
**Suggested phases**: {when_to_apply}
**Suggested influence**: {suggested_influence}

---

**Your options**:
1. **Accept** — Add to active insights (you can adjust influence)
2. **Accept & Promote** — Add directly to user-insights.yaml as first-class insight
3. **Reject** — Not useful (please explain why, it helps calibrate future discoveries)
4. **Modify** — Good idea but needs rewording or different settings
5. **Skip** — Review later
```

### Step 3: Process User Decision

| Decision | Action |
|----------|--------|
| Accept | Set status → `accepted`, copy user's influence preference to `final_influence` |
| Accept & Promote | Set status → `promoted`, create entry in `user-insights.yaml` with origin: discovered |
| Reject | Set status → `rejected`, record user_notes, decrease confidence by 0.3 |
| Modify | Update observation/settings per user's changes, set status → `accepted` |
| Skip | Keep status → `pending_review`, no changes |

### Step 4: Write Updates

1. WRITE updated `memory/discovered-insights.yaml`
2. If any promoted → WRITE updated `memory/user-insights.yaml`
3. Show summary: N accepted, N rejected, N promoted, N skipped

---

## Action: Adjust (Modify Existing Insight)

### Step 1: Load Target Insight

```bash
READ memory/user-insights.yaml
FIND: insight with id == {--id}
```

### Step 2: Apply Adjustment

| Flag | Effect |
|------|--------|
| `--influence=high\|medium\|low` | Change influence level |
| `--status=active\|paused\|retired` | Change status |
| `--observation="new text"` | Update observation text |
| `--add-phase=refactoring` | Add phase to when_to_apply |
| `--remove-phase=prototyping` | Remove phase from when_to_skip |

### Step 3: Validate and Write

1. Update `last_validated` to today's date
2. WRITE updated `memory/user-insights.yaml`
3. Confirm change to user

---

## Action: List (Show Active Insights for Phase)

### Step 1: Load and Filter

```bash
READ memory/user-insights.yaml
FILTER: status == "active" AND {--phase} in when_to_apply AND {--phase} NOT in when_to_skip

READ memory/discovered-insights.yaml
FILTER: status == "accepted" AND {--phase} in when_to_apply
```

### Step 2: Present Sorted by Influence

```markdown
## Active Insights for: {phase}

### High Influence (applied proactively)
| ID | Observation | Evidence | Source |
|----|-------------|----------|--------|
| {id} | {observation_summary} | {evidence_summary} | user / discovered |

### Medium Influence (suggested when relevant)
| ID | Observation | Evidence | Source |
|----|-------------|----------|--------|
| {id} | {observation_summary} | {evidence_summary} | user / discovered |

### Low Influence (on explicit request only)
| ID | Observation | Evidence | Source |
|----|-------------|----------|--------|
| {id} | {observation_summary} | {evidence_summary} | user / discovered |

---
Total: {N} active insights for {phase}
```

---

## Action: Promote (Discovered → User Insight)

### Step 1: Load Discovery

```bash
READ memory/discovered-insights.yaml
FIND: insight with id == {--id} AND status IN (accepted, pending_review)
```

### Step 2: Create User Insight Entry

Transform the discovered insight into user insight format:

```yaml
- id: {same-id-or-user-chosen}
  observation: "{user-confirmed wording}"
  when_to_apply: [{user-confirmed phases}]
  when_to_skip: [{user-confirmed exclusions}]
  influence: "{user-chosen level}"
  evidence: "{accumulated evidence from discovery + user additions}"
  tags: [{tags}]
  created: "{original detection date}"
  last_validated: "{today}"
  status: active
  origin: discovered  # marks this was AI-discovered, not user-contributed
```

### Step 3: Write Both Files

1. APPEND to `memory/user-insights.yaml`
2. UPDATE `memory/discovered-insights.yaml`: set status → `promoted`, reviewed_at → today
3. Confirm to user

---

## Action: Pause / Resume

Toggle an insight temporarily on or off:

- **Pause**: Set status → `paused`. Insight will not be loaded at decision points.
  Use when: user wants to test working without a specific insight.
- **Resume**: Set status → `active`. Insight becomes active again.
  Use when: user confirms the insight is still valuable.

---

## Action: Retire

Mark an insight as no longer relevant:

- Set status → `retired`
- Insight stays in the file for historical reference but is never loaded
- Use when: the project has changed and the insight no longer applies

---

## Conflict Detection

When adding or modifying insights, check for conflicts:

```
CONFLICT DETECTION:
  FOR each existing active insight:
    IF new_insight.observation contradicts existing.observation:
      → Flag: "New insight '{new.id}' may conflict with '{existing.id}'"
      → Present both to user
      → Ask: Keep both? Replace? Merge?

    IF new_insight.when_to_apply overlaps AND influence levels differ:
      → Inform: "Both will apply during {phase} with different influence levels"
      → This is OK (not a conflict, just something to be aware of)
```

---

## Integration Points

| Command | How It Uses Insights Manager |
|---------|------------------------------|
| `/workflows:compound` | Proposes new discovered insights from feature analysis |
| `/workflows:review` | Can trigger insight review when patterns are detected |
| `/workflows:route` | Lists insights relevant to the detected phase |

---

## Error Recovery

- **File not found**: Create `memory/user-insights.yaml` or `memory/discovered-insights.yaml` from scratch with empty lists and schema comments.
- **Malformed YAML**: Report parse error to user with line number. Do not overwrite — ask user to fix manually or provide corrected version.
- **Duplicate ID**: If adding an insight with an existing ID, append a numeric suffix (e.g., `solid-scalability-2`).
- **Contradictory insights**: Never silently resolve. Always present the contradiction to the user.
