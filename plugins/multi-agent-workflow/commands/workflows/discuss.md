---
name: workflows:discuss
description: "Capture implementation preferences and resolve gray areas before planning. Prevents rework from undiscovered preferences."
argument_hint: <feature-name>
---

# Multi-Agent Workflow: Discuss (Pre-Planning Preferences)

Capture implementation preferences and resolve ambiguities BEFORE planning begins.

## Philosophy

> "Decisions discovered during execution are expensive. Decisions captured before planning are free."
> — Inspired by GSD Discussion Phase

Many planning failures happen because preferences are implicit: the user assumes Redis for caching but the planner designs with Memcached. The developer prefers immutable DTOs but the plan uses mutable ones. These mismatches cause rework during execution.

The Discuss phase makes these preferences explicit by writing them to `01_preferences.md`, which feeds directly into planning Phases 1 and 3.

## Flow Position

```
ROUTE ──> [DISCUSS] ──> SHAPE ──> PLAN ──> WORK ──> ...
              │         (optional)
              │
              └── Writes: 01_preferences.md
                  Read by: /workflows:plan (Step 0.0)
```

This command is **optional** (Tier 2). It sits between Route and Shape/Plan.

## When to Use

```
RECOMMEND DISCUSS when:
  ✅ Feature is classified as MEDIUM or COMPLEX by /workflows:route
  ✅ Multiple implementation approaches are viable
  ✅ The user has strong opinions about technology choices
  ✅ Previous features in this area had preference-related rework

SKIP DISCUSS when:
  ❌ Feature is simple (use /workflows:quick instead)
  ❌ Existing 01_preferences.md already covers this area
  ❌ Technology stack is fully determined by project constraints
```

## Execution Flow

### Step 1: Identify Gray Areas

Analyze the user's request and identify areas where multiple valid approaches exist:

```markdown
## Gray Areas Identified for: ${FEATURE_ID}

Based on your request, I've identified these areas where your preference matters:

### Technology Choices
- **Caching**: Redis vs Memcached vs in-memory?
- **Queue**: RabbitMQ vs Kafka vs database queue?
- **Storage**: Local filesystem vs S3 vs CDN?

### Architecture Preferences
- **DTOs**: Mutable vs immutable?
- **Events**: Domain events vs application events vs both?
- **Error handling**: Exceptions vs Result objects?

### Code Style Preferences
- **Naming**: Verbose (CreateUserRegistrationUseCase) vs concise (RegisterUser)?
- **Test style**: Given/When/Then vs Arrange/Act/Assert?
- **Comments**: Minimal (self-documenting) vs comprehensive?

### Integration Preferences
- **API format**: REST vs GraphQL?
- **Auth**: JWT vs session-based vs OAuth?
- **Validation**: Domain-level vs application-level vs both?
```

### Step 2: Ask Preference Questions

For each gray area, present options with trade-offs:

```markdown
To plan ${FEATURE_ID}, I need to understand your preferences:

1. **Caching strategy**:
   a) Redis (recommended for distributed systems)
   b) In-memory (simpler, single-instance only)
   c) No caching (simplest, may need later)

2. **DTO approach**:
   a) Immutable DTOs with readonly properties (safer, more verbose)
   b) Mutable DTOs with setters (flexible, less code)
   c) Use arrays/maps (simplest, no type safety)

3. **Error handling**:
   a) Custom exceptions per domain (DDD standard)
   b) Result<T, Error> objects (functional style)
   c) Mix: exceptions for unexpected, results for expected

[Wait for user response before writing preferences]
```

### Step 3: Write Preferences File

After collecting answers, write `01_preferences.md`:

```markdown
# Implementation Preferences: ${FEATURE_ID}

**Captured**: ${ISO_TIMESTAMP}
**Captured by**: /workflows:discuss

## Technology Choices
| Area | Preference | Rationale |
|------|-----------|-----------|
| Caching | Redis | Distributed system, multiple instances |
| Queue | RabbitMQ | Already in infrastructure |
| Storage | S3 | CDN integration planned |

## Architecture Preferences
| Area | Preference | Rationale |
|------|-----------|-----------|
| DTOs | Immutable (readonly) | User prefers safety over convenience |
| Events | Domain events only | Keep it simple initially |
| Error handling | Custom exceptions | Consistent with existing codebase |

## Code Style Preferences
| Area | Preference | Rationale |
|------|-----------|-----------|
| Naming | Concise (RegisterUser) | User prefers short names |
| Test style | Given/When/Then | Team convention |

## Constraints Discovered
- Must support PHP 8.3 strict_types
- PostgreSQL only (no MySQL)
- API must be backwards-compatible

## Notes
- User mentioned: "We might add GraphQL later, design REST with that in mind"
- User mentioned: "Keep handlers under 50 lines"
```

### Step 4: Update State

```markdown
# In 50_state.md:
## Discuss Phase
**Status**: COMPLETED
**Date**: ${ISO_TIMESTAMP}
**Output**: 01_preferences.md
**Gray Areas Resolved**: ${COUNT}
```

## How Planning Uses Preferences

When `/workflows:plan` runs and finds `01_preferences.md`:

- **Phase 1 (Understand)**: Constraints from preferences inform problem statement
- **Phase 3 (Solutions)**: Technology choices and architecture preferences guide solution design
- **Phase 4 (Tasks)**: Code style preferences inform task specifications

The planner reads preferences at Step 0.0 and does NOT ask questions already answered in the preferences file.

## Integration with Validation Learning

Preferences captured here are cross-referenced with `validation-learning-log.md`:
- If a preference matches a pattern already in the learning log → auto-confirmed
- If a preference contradicts a previous pattern → flag for user resolution
- New preferences are candidates for promotion to project rules after ≥5 features

## Output

```
Discussion complete for: ${FEATURE_ID}

Preferences captured: 8
Gray areas resolved: 5
Constraints discovered: 3

Output: .ai/project/features/${FEATURE_ID}/01_preferences.md

Next step: /workflows:shape ${FEATURE_ID} (if complex)
       or: /workflows:plan ${FEATURE_ID} (if scope is clear)
```
