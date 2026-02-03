# Task Dependencies: SOLID Refactor

## Dependency Graph

```
                            START
                              │
                              ▼
        ┌─────────────────────┴─────────────────────┐
        │                                           │
        ▼                                           ▼
   TASK-001                                    TASK-002
   (BodyElement                                (Multimedia
    Interface)                                  Interface)
        │                                           │
        │                                           │
        ▼                                           ▼
   TASK-003 ◄───────────────────────────────────────┘
   (Symfony DI Config)
        │
        │
        ├───────────────────────────────────────────┐
        │                                           │
        ▼                                           ▼
┌───────────────────────────┐         ┌───────────────────────────┐
│   PARALLEL GROUP A        │         │   PARALLEL GROUP B        │
│   (BodyElement Creators)  │         │   (Multimedia Creators)   │
│                           │         │                           │
│   TASK-010 (Paragraph)    │         │   TASK-030 (Photo)        │
│   TASK-011 (SubHead)      │         │   TASK-031 (EmbedVideo)   │
│   TASK-012 (Picture)      │         │   TASK-032 (Widget)       │
│   TASK-013 (PictureMem)   │         │   TASK-033 (Fallback)     │
│   TASK-014 (VideoYT)      │         │                           │
│   TASK-015 (Video)        │         └───────────┬───────────────┘
│   TASK-016 (Html)         │                     │
│   TASK-017 (Summary)      │                     │
│   TASK-018 (ExplSum)      │                     │
│   TASK-019 (InsertedNews) │                     │
│   TASK-020 (MemberCard)   │                     │
│   TASK-021 (Link)         │                     │
│   TASK-022 (UnorderedList)│                     │
│   TASK-023 (NumberedList) │                     │
│   TASK-024 (GenericList)  │                     │
│   TASK-025 (Fallback)     │                     │
│                           │                     │
└───────────┬───────────────┘                     │
            │                                     │
            ▼                                     ▼
       TASK-040                              TASK-041
       (Refactor                             (Refactor
       BodyElement                           Multimedia
       Factory)                              Factory)
            │                                     │
            │                                     │
            ▼                                     ▼
┌───────────────────────────────────────────────────────────┐
│                    PARALLEL GROUP C                       │
│                                                           │
│   TASK-050                           TASK-051             │
│   (BodyElement                       (Media               │
│    DataTransformer                    DataTransformer     │
│    Handler)                           Handler)            │
│                                                           │
└───────────────────────────┬───────────────────────────────┘
                            │
                            ▼
                       TASK-060
                       (ImageSize
                        Config)
                            │
                            ▼
                       TASK-061
                       (Multimedia
                        UrlGenerator)
                            │
                            ▼
                       TASK-062
                       (Migrate Trait
                        Consumers)
                            │
                            ▼
                       TASK-063
                       (Delete Trait)
                            │
                            ▼
                ┌───────────┴───────────┐
                │                       │
                ▼                       ▼
           TASK-070                TASK-071
           (PHPStan)               (Tests)
                │                       │
                └───────────┬───────────┘
                            │
                            ▼
                       TASK-072
                       (Documentation)
                            │
                            ▼
                           END
```

## Parallel Execution Plan

### Wave 1 (Foundation)
```
Sequential: TASK-001 → TASK-002 → TASK-003
```

### Wave 2 (Creators) - MAXIMUM PARALLELISM
```
┌────────────────────────────────────────────────────────────────┐
│  STREAM A              │  STREAM B              │  STREAM C   │
│  (Agent 1)             │  (Agent 2)             │  (Agent 3)  │
├────────────────────────┼────────────────────────┼─────────────┤
│  TASK-010              │  TASK-014              │  TASK-030   │
│  TASK-011              │  TASK-015              │  TASK-031   │
│  TASK-012              │  TASK-016              │  TASK-032   │
│  TASK-013              │  TASK-017              │  TASK-033   │
│                        │  TASK-018              │             │
│                        │  TASK-019              │             │
│                        │  TASK-020              │             │
│                        │  TASK-021              │             │
│                        │  TASK-022              │             │
│                        │  TASK-023              │             │
│                        │  TASK-024              │             │
│                        │  TASK-025              │             │
└────────────────────────┴────────────────────────┴─────────────┘
```

### Wave 3 (Factory Refactor)
```
Sequential: TASK-040 → TASK-041
(Must wait for ALL creators to be done)
```

### Wave 4 (Handlers) - PARALLEL
```
┌─────────────────────────┬─────────────────────────┐
│  STREAM A               │  STREAM B               │
├─────────────────────────┼─────────────────────────┤
│  TASK-050               │  TASK-051               │
│  (BodyElement Handler)  │  (Media Handler)        │
└─────────────────────────┴─────────────────────────┘
```

### Wave 5 (Trait Elimination)
```
Sequential: TASK-060 → TASK-061 → TASK-062 → TASK-063
```

### Wave 6 (Cleanup)
```
Sequential: TASK-070 → TASK-071 → TASK-072
```

## Critical Path

The critical path (longest chain of dependent tasks):

```
TASK-001 → TASK-003 → TASK-010..025 → TASK-040 → TASK-050 → TASK-060 → TASK-061 → TASK-062 → TASK-063 → TASK-071 → TASK-072
```

**Critical path length**: 12 tasks (minimum sequential work)

## Blockers

| Task | Can Block | Mitigation |
|------|-----------|------------|
| TASK-001 | All Phase 2A | Create interface first thing |
| TASK-002 | All Phase 2B | Can be done parallel with TASK-001 |
| TASK-003 | Phase 2 | Simple config, quick to complete |
| TASK-040 | Phase 4 | Cannot proceed until all creators done |

## Risk Analysis

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Creator interface changes mid-implementation | HIGH | LOW | Finalize interface before Phase 2 |
| Symfony DI issues with tagged services | MEDIUM | MEDIUM | Test config early with one creator |
| Test failures in Phase 6 | HIGH | MEDIUM | Run tests incrementally after each creator |
| MultimediaTrait consumers break | MEDIUM | HIGH | Create service first, migrate one consumer as proof |

## Recommended Execution Order

### For Single Agent (Sequential-ish)
1. TASK-001 + TASK-002 (5 min each)
2. TASK-003 (10 min)
3. TASK-010 + tests (verify pattern works)
4. TASK-011 to TASK-025 (batch creators)
5. TASK-030 to TASK-033 (batch multimedia)
6. TASK-040 (major refactor)
7. TASK-041 (copy pattern)
8. Continue Phase 4-6

### For Multiple Agents (True Parallel)

**Agent 1 (Backend - BodyElement)**:
```
TASK-001 → TASK-003 → TASK-010..025 → TASK-040 → TASK-050
```

**Agent 2 (Backend - Multimedia)**:
```
TASK-002 → (wait TASK-003) → TASK-030..033 → TASK-041 → TASK-051
```

**Agent 3 (Backend - Infrastructure)**:
```
TASK-060 → TASK-061 → (wait TASK-050, TASK-051) → TASK-062 → TASK-063
```

**Agent 4 (QA)**:
```
(wait all) → TASK-070 → TASK-071 → TASK-072
```
