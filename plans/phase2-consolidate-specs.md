# Plan Fase 2: Consolidación de Especificaciones (Reducir de 9 a 4 archivos por feature)

**Fecha**: 2026-02-22
**Alcance**: Templates, comandos (plan, work, compound, discover), skills, roles, agentes
**Resultado**: De 9 archivos independientes a 4 archivos. 5 archivos eliminados, 0 información perdida.

---

## Resumen Ejecutivo

Después de analizar exhaustivamente los 16 templates en `core/templates/`, los 4 comandos principales (`plan.md`, `work.md`, `compound.md`, `discover.md`), las reglas del framework, los skills (`spec-merger`, `validation-learning-log`), y los roles (`planner.md`), se identifican las siguientes oportunidades de consolidación.

---

## Estado Actual: 9 Archivos por Feature

### Categoría A: Archivos por feature (en `openspec/changes/{slug}/`)
1. **proposal.md** — Phase 1: Problema, contexto, criterios de éxito
2. **specs.md** — Phase 2: Requisitos funcionales + test contract sketch + integración
3. **design.md** — Phase 3: Soluciones SOLID + impacto arquitectónico + restricciones dimensionales
4. **tasks.md** — Phase 4: Tareas + workflow state + decision log + resume point
5. **scratchpad.md** — Runtime: notas de trabajo efímeras

### Categoría B: Archivos a nivel de proyecto (en `.ai/project/` o `openspec/specs/`)
6. **architecture-profile.yaml** — Perfil de arquitectura
7. **compound-memory.md** — Memoria acumulativa de patrones y anti-patrones
8. **validation-learning-log.md** — Log de aprendizaje de validación
9. **compound_log.md** — Registro histórico de features completados

---

## Análisis de Solapamiento de Información

### Solapamientos entre archivos por feature (Categoría A)

| Información | Dónde aparece actualmente | ¿Necesita separación? |
|---|---|---|
| Problem statement y why | `proposal.md` (completo) | NO — es un preámbulo de 20-40 líneas |
| Success criteria | `proposal.md` | NO — son 5-10 líneas referenciadas desde specs |
| Functional specs (WHAT) | `specs.md` | SÍ — núcleo de Phase 2, referenciado por Phase 3 |
| Integration analysis | `specs.md` | SÍ — pero podría ser sección de un doc unificado |
| Test contract sketch | `specs.md` (appendix) | NO — son 15-30 líneas, complementario a specs |
| SOLID solutions (HOW) | `design.md` | SÍ — núcleo de Phase 3 |
| Architectural impact | `design.md` | SÍ — pero solo relevante para features complejas |
| API architecture constraints | `design.md` | NO — son 20-40 líneas, complementario a design |
| Task breakdown | `tasks.md` | SÍ — núcleo de Phase 4, usado durante work |
| Decision log | `tasks.md` | NO — 5-15 líneas, usado por compound |
| Workflow state | `tasks.md` | SÍ — mecanismo central de comunicación entre roles |
| Working notes | `scratchpad.md` | NO — efímero, solo útil durante sesión |

### Solapamientos entre archivos de proyecto (Categoría B)

| Información | Dónde aparece actualmente | ¿Necesita separación? |
|---|---|---|
| Learned patterns | `architecture-profile.yaml` Y `compound-memory.md` | DUPLICADO |
| Learned anti-patterns | `architecture-profile.yaml` Y `compound-memory.md` | DUPLICADO |
| Pain points | `compound-memory.md` | Único |
| Agent calibration | `compound-memory.md` | Único |
| Stack/architecture detection | `architecture-profile.yaml` | Único |
| SOLID relevance | `architecture-profile.yaml` | Único |
| Validation patterns | `validation-learning-log.md` | SOLAPAMIENTO PARCIAL con compound-memory.md |
| Validation preferences | `validation-learning-log.md` | Único |
| Feature history | `compound_log.md` | Único |
| Time metrics | `compound_log.md` | Único |

---

## Propuesta de Consolidación: De 9 a 4 Archivos

### Nuevo esquema por feature: 2 archivos (antes 5)

| # | Archivo consolidado | Contenido | Reemplaza a |
|---|---|---|---|
| 1 | **`spec.md`** (singular) | Phase 1 (proposal) + Phase 2 (specs + test sketch) + Phase 3 (design + SOLID + constraints) | `proposal.md` + `specs.md` + `design.md` |
| 2 | **`tasks.md`** (se mantiene) | Task breakdown + workflow state + decision log + scratchpad notes | `tasks.md` + `scratchpad.md` |

### Nuevo esquema de proyecto: 2 archivos (antes 4)

| # | Archivo consolidado | Contenido | Reemplaza a |
|---|---|---|---|
| 3 | **`architecture-profile.yaml`** (absorbe) | Stack + SOLID + patterns + anti-patterns + quality thresholds + agent calibration + pain points | `architecture-profile.yaml` + `compound-memory.md` |
| 4 | **`compound_log.md`** (absorbe) | Feature history + time metrics + validation learnings + next-feature-briefing | `compound_log.md` + `validation-learning-log.md` |

---

## Consolidación 1: `proposal.md` + `specs.md` + `design.md` → `spec.md`

### Justificación

- `proposal.md` típicamente contiene 30-50 líneas de contexto. No justifica un archivo separado.
- La separación WHAT (specs.md) vs HOW (design.md) es conceptualmente correcta pero genera fricción operativa: el planner necesita leer 3 archivos, el implementer necesita leer 3 archivos, el reviewer necesita leer 3 archivos.
- La información fluye secuencialmente: proposal informa specs, specs informan design. Son secciones de UN mismo documento.

### Estructura propuesta para `spec.md`

```markdown
# Feature Specification: ${FEATURE_ID}

**Created**: ${DATE}
**Status**: DRAFT | VALIDATED | APPROVED
**Planning Depth**: full | standard | minimal

---

## 1. Context & Problem (formerly proposal.md)

### What We're Building
[Clear description of the feature/task]

### Why It's Needed
[Business justification - 2-3 sentences]

### Who Benefits
[Users/stakeholders]

### Constraints
- Technical: [stack, performance, integrations]
- Business: [timeline, compliance]

### Success Criteria
1. [Measurable criterion 1]
2. [Measurable criterion 2]

---

## 2. Functional Specifications (WHAT)

### SPEC-F01: [Requirement Name]
**Description**: [What the system must do - from user perspective]
**Acceptance Criteria**:
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
**Verification**: [How to verify]
**Priority**: Critical | High | Medium | Low

### SPEC-F02: [Requirement Name]
...

### Quality Specifications (Optional)
#### SPEC-Q01: Performance
...

---

## 3. Integration Analysis

### Entities Impact
| Action | Entity | Change | Reason |
|--------|--------|--------|--------|

### API Contracts Impact
| Action | Endpoint | Change | Backward Compatible |
|--------|----------|--------|---------------------|

### Business Rules Impact
| Action | Rule ID | Description |
|--------|---------|-------------|

---

## 4. Test Contract Sketch

| Spec | Test Type | Key Scenarios | Edge Cases | Dependencies |
|------|-----------|---------------|------------|--------------|

### Test Boundaries
- System boundary (where to mock): [...]
- Trust boundary (where to validate): [...]

---

## 5. Design & Solutions (HOW) — SOLID MANDATORY

### SOLID Baseline
- Current compliance: [from solid-analyzer or N/A if greenfield]
- Violations found: [list or none]

### Solution for SPEC-F01: [Name]
**Approach**: [How to implement]
**SOLID Compliance**:
| Principle | Verdict | Reasoning | Pattern Used |
|-----------|---------|-----------|--------------|
| S - SRP | COMPLIANT | [...] | [...] |
| O - OCP | COMPLIANT | [...] | Strategy |

**Files to Create/Modify**:
- `path/to/File1.php` (SRP reason)

### Overall SOLID Compliance
| Solution | Verdict | Notes |
|----------|---------|-------|
| **Global** | **COMPLIANT** | |

---

## 6. API Architecture Constraints (if diagnostic exists)

### Dimensional Context
| Dimension | Value | Relevant | Impact on Design |
|-----------|-------|----------|-----------------|

### Constraints Satisfied
| Constraint (must) | SOLID | How Addressed |
|-------------------|-------|---------------|

---

## 7. Architectural Impact

### Layer Analysis
| Layer | Impact | Changes Required |
|-------|--------|------------------|

### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|

---

## Approval
- [ ] Specs describe WHAT, not HOW (Section 2)
- [ ] All specs testable with >=2 criteria
- [ ] SOLID compliance documented (Section 5)
- [ ] Ready for task breakdown
```

### Secciones opcionales según `planning_depth`

| Sección | full | standard | minimal |
|---------|------|----------|---------|
| 1. Context & Problem | SÍ | SÍ | SÍ |
| 2. Functional Specs | SÍ | SÍ | NO |
| 3. Integration Analysis | SÍ | SÍ (simplificado) | NO |
| 4. Test Contract Sketch | SÍ | SÍ | NO |
| 5. Design & Solutions | SÍ | SÍ | NO |
| 6. API Architecture Constraints | SÍ | NO | NO |
| 7. Architectural Impact | SÍ | NO | NO |

### Riesgo de esta consolidación

| Riesgo | Severidad | Mitigación |
|--------|-----------|------------|
| Archivo muy largo para features complejas | MEDIA | Chunking directive: max ~600 líneas. Si excede, split en `spec.md` + `spec-appendix.md` |
| Pérdida de la distinción WHAT vs HOW | BAJA | Las secciones 2 y 5 mantienen la separación conceptual con headers claros |
| Quality Gates necesitan actualizar | BAJA | Se adaptan a validar secciones del mismo archivo |
| Más carga de escritura en un solo paso | MEDIA | Mantener el Write-Then-Advance por sección, no por archivo completo |

---

## Consolidación 2: `scratchpad.md` se absorbe en `tasks.md`

### Justificación

El scratchpad contiene notas efímeras (hipótesis, preguntas, breadcrumbs de contexto). Estas notas son relevantes SOLO durante la sesión de trabajo, que es exactamente cuando `tasks.md` está activo.

### Estructura propuesta para `tasks.md` (actualizado)

```markdown
# Implementation Tasks: ${FEATURE_ID}

## Workflow State
**Planner**: PENDING | **Implementer**: PENDING | **Reviewer**: PENDING
**Feature**: ${FEATURE_ID}
**Started**: ${ISO_TIMESTAMP}
**Last Updated**: ${ISO_TIMESTAMP}
**Last Phase**: (none) | **Resume Point**: Step 0

### Planning Progress
| Phase | Status | Written At |
|-------|--------|------------|

### Implementer Section
<!-- Added by /workflows:work -->

### QA / Reviewer Section
<!-- Added by /workflows:review -->

---

## Progress
| Task | Status | Verify | Completed At |
|------|--------|--------|--------------|

## Task Details
<!-- Each task follows the Task Template -->

---

## Decision Log
| # | Decision | Alternatives Considered | Rationale | Phase | Risk |
|---|----------|------------------------|-----------|-------|------|

---

## Scratchpad (ephemeral working notes)

### Current Hypothesis
[What you're investigating]

### Observations
- [Observation 1]

### Unresolved Questions
| # | Question | Context | Blocking? | Resolved? |
|---|----------|---------|-----------|-----------|

### Blockers & Workarounds
| Blocker | Workaround | Permanent Fix Needed? |
|---------|-----------|----------------------|

### Context Breadcrumbs
**Last action**: [...]
**Next action**: [...]
**Key files**: [...]
**Watch out for**: [...]
```

### Riesgo

| Riesgo | Severidad | Mitigación |
|--------|-----------|------------|
| tasks.md crece demasiado | BAJA | Scratchpad es efímero, se limpia entre fases |
| Scratchpad contamina el workflow state | MÍNIMA | Sección al final del archivo, claramente separada |

---

## Consolidación 3: `compound-memory.md` se absorbe en `architecture-profile.yaml`

### Justificación

Duplicación directa:
- `architecture-profile.yaml` tiene `learned_patterns[]` y `learned_antipatterns[]`
- `compound-memory.md` tiene "Historical Patterns" y "Known Pain Points"

### Secciones nuevas para `architecture-profile.yaml`

```yaml
# === COMPOUND MEMORY (formerly compound-memory.md) ===
# Updated by /workflows:compound (Step 3b)

known_pain_points: []
# Example:
#   - title: "N+1 queries in Doctrine lazy loading"
#     area: "Infrastructure/Persistence"
#     description: "Doctrine default lazy loading causes N+1 on relations"
#     prevention: "Always use ->addSelect() or DQL joins for relations"
#     severity: high
#     frequency: "3/5 features"
#     source: "real"  # real | seed | seed-updated | seed-stale
#     source_features: [user-auth, order-management, payments]

agent_calibration: {}
# Example:
#   security-reviewer:
#     intensity: HIGH
#     reason: "2 security pain points detected"
```

Los campos existentes `learned_patterns` y `learned_antipatterns` solo necesitan agregar el campo `source`:

```yaml
learned_patterns:
  - pattern: "Value Object for validated fields"
    confidence: high
    source_features: [user-auth, payments]
    source: real  # real | seed | seed-updated | seed-stale
```

### Riesgo

| Riesgo | Severidad | Mitigación |
|--------|-----------|------------|
| YAML se vuelve muy largo | MEDIA | Pain points y calibration son 20-40 líneas típicamente |
| Compound loop se rompe | CRÍTICA | Verificar que compound Step 3b apunte al mismo archivo |
| discover --seed genera compound-memory | ALTA | Actualizar seed protocol para escribir a architecture-profile.yaml |

---

## Consolidación 4: `validation-learning-log.md` se absorbe en `compound_log.md`

### Justificación

`validation-learning-log.md` almacena patterns (ya cubiertos por architecture-profile.yaml), preferences (único), y entry log (histórico cronológico). `compound_log.md` ya es un registro cronológico de features.

### Estructura propuesta para `compound_log.md` (actualizado)

```markdown
# Compound Log

## Validation Learnings (formerly validation-learning-log.md)

### Metadata
- **Total entries**: ${COUNT}
- **Questions avoided (learned)**: ${AVOIDED_COUNT}
- **Learning effectiveness**: ${RATE}%

### Active Preferences
| ID | Preference | Value | Last Confirmed | Source Feature |
|----|-----------|-------|---------------|----------------|

### Active Patterns (quick reference — canonical source: architecture-profile.yaml)
| ID | Pattern | Confidence | Status |
|----|---------|-----------|--------|

---

## Feature History

### 2026-01-16: user-authentication

#### Summary
[...]

#### Time Investment
[...]

#### Learnings Captured
[...]

#### Validation Entries (formerly LOG-xxx entries)
| # | Question | Answer | Phase |
|---|---------|--------|-------|

#### Specs Updated
[...]

#### Next Feature Briefing
[Previously in next-feature-briefing.md — now inline]
- Reusable patterns: [...]
- Known risks: [...]
- Test strategy: [...]
- 70% boundary: [...]
```

### Riesgo

| Riesgo | Severidad | Mitigación |
|--------|-----------|------------|
| compound_log.md crece con muchas features | MEDIA | Archiving: mover entries > 10 features a compound_log_archive.md |
| validation-learning-log skill necesita rewrite | ALTA | Actualizar el skill para leer/escribir en compound_log.md |
| next-feature-briefing inline dificulta lectura rápida | BAJA | Sección claramente marcada |

---

## Archivos a Eliminar, Modificar o Crear

### Templates a ELIMINAR

| Template | Ruta actual | Razón |
|----------|-------------|-------|
| `scratchpad-template.md` | `core/templates/scratchpad-template.md` | Absorbido en tasks-template.md |

### Templates a MODIFICAR

| Template | Ruta | Cambio |
|----------|------|--------|
| `spec-template.md` | `core/templates/spec-template.md` | Reescribir completamente: unificar proposal + specs + design |
| `tasks-template.md` | `core/templates/tasks-template.md` | Agregar sección `## Scratchpad` al final |
| `architecture-profile-template.yaml` | `core/templates/architecture-profile-template.yaml` | Agregar secciones `known_pain_points`, `agent_calibration`, campo `source` |

### Templates que NO CAMBIAN

Todos los templates OpenSpec independientes (feature_spec.yaml, entity_spec.yaml, api_contract.yaml, business_rule_spec.yaml, etc.) no se ven afectados.

---

## Comandos a Actualizar

### 1. `commands/workflows/plan.md` (CAMBIOS EXTENSOS)

| Sección | Cambio |
|---------|--------|
| Incremental Persistence Protocol | De 4 archivos a 2 (`spec.md` + `tasks.md`) |
| Per-Phase Write Directives | Phase 1 → sección 1 de `spec.md`. Phase 2 → secciones 2-4. Phase 3 → secciones 5-7. Phase 4 → `tasks.md` |
| Output Files section | Actualizar árbol de `openspec/changes/${FEATURE_ID}/` |
| Phase 1-3 Quality Gates | Checks se aplican a secciones de spec.md |
| Plan Completeness Verification | "Files exist: spec.md and tasks.md" (ya no 4 archivos) |
| Chunking Directive | spec.md max ~600 líneas |

**Impacto crítico**: Write-Then-Advance necesita adaptarse. Phase 1 CREA spec.md con sección 1. Phase 2 REESCRIBE con secciones 1-4. Phase 3 REESCRIBE completo.

### 2. `commands/workflows/work.md` (CAMBIOS MODERADOS)

| Sección | Cambio |
|---------|--------|
| Step 3: Load Feature Context | Leer `spec.md` + `tasks.md` (no proposal+design+tasks) |
| Step 3.5: Load Compound Learnings | `architecture-profile.yaml` (no compound-memory.md). Última entrada de `compound_log.md` (no next-feature-briefing.md) |
| Flow Guard prerequisite check | Solo `spec.md` (no proposal+specs+design) |
| Step 4.6: Solution Validation | "Section 5 of spec.md" (no design.md) |
| Self-Review | "spec.md Section 1" y "spec.md Section 5" |

### 3. `commands/workflows/compound.md` (CAMBIOS EXTENSOS)

| Sección | Cambio |
|---------|--------|
| Step 3b: Update Agent Compound Memory | Escribe a `architecture-profile.yaml` (no compound-memory.md) |
| Step 3c: Enrich Architecture Profile | Se fusiona con Step 3b |
| Step 5: Create Compound Log Entry | Agregar sección "Validation Entries" |
| Step 6b: Generate Next Feature Briefing | Inline en compound log entry (no archivo separado) |
| Step 7: Spec Diff Analysis | `spec.md` Section 2-3 y Section 5-7 |

### 4. `commands/workflows/discover.md` (CAMBIOS MODERADOS)

| Sección | Cambio |
|---------|--------|
| Seed Step 3: Generate Compound Memory | Escribe a `architecture-profile.yaml` |
| Seed Step 4: Generate Next Feature Briefing | Inicializa primera entrada de `compound_log.md` |
| Setup Step 3: Generate Project Configuration | Eliminar compound-memory.md y validation-learning-log.md del árbol |

### 5. `commands/workflows/review.md` (CAMBIOS MENORES)

| Sección | Cambio |
|---------|--------|
| Referencias a specs.md y design.md | Cambiar a `spec.md` con indicación de sección |
| Validation learning integration | `compound_log.md` sección "Validation Learnings" |

### 6. Otros archivos a actualizar

| Archivo | Cambio |
|---------|--------|
| `CLAUDE.md` | Actualizar tabla SDD de 6 filas a 3. Actualizar "State Management" |
| `core/rules/framework_rules.md` | §6 (Flow Guards): lista de archivos. §10 (Baseline Freeze). §11 (Write-Then-Advance) |
| `core/roles/planner.md` | "Permitted Operations Write" de 4 archivos a 2 |
| `core/roles/implementer.md` | Archivos que lee |
| `core/roles/reviewer.md` | Archivos que lee |
| `skills/spec-merger/SKILL.md` | Step 1: leer `spec.md` en lugar de specs.md + design.md |
| `skills/validation-learning-log/SKILL.md` | Reescribir para operar sobre `compound_log.md` |
| `agents/review/*.md` (4 archivos) | Actualizar referencias |
| `agents/workflow/spec-analyzer.md` | Actualizar referencia de specs.md |
| `commands/workflows/status.md` | Actualizar lista de archivos monitoreados |

---

## Plan de Ejecución: Commits Atómicos

### Commit 1: Crear nuevo `spec-template.md` unificado
- **Archivo**: `core/templates/spec-template.md`
- **Acción**: Reescribir completamente con la estructura de 7 secciones
- **Test**: Verificar que el template es parseable y completo
- **Riesgo**: BAJO — es un template, no afecta funcionalidad existente

### Commit 2: Actualizar `tasks-template.md` con scratchpad
- **Archivo**: `core/templates/tasks-template.md`
- **Acción**: Agregar sección `## Scratchpad` al final
- **Eliminar**: `core/templates/scratchpad-template.md`
- **Riesgo**: BAJO

### Commit 3: Actualizar `architecture-profile-template.yaml` con compound memory
- **Archivo**: `core/templates/architecture-profile-template.yaml`
- **Acción**: Agregar secciones `known_pain_points`, `agent_calibration`, campo `source`
- **Riesgo**: MEDIO — afecta la lectura/escritura del profile en compound y discover

### Commit 4: Actualizar `plan.md` para usar `spec.md` unificado
- **Archivo**: `commands/workflows/plan.md`
- **Acción**: Todos los cambios listados arriba
- **Riesgo**: ALTO — es el comando más complejo

### Commit 5: Actualizar `work.md` para leer archivos consolidados
- **Archivo**: `commands/workflows/work.md`
- **Riesgo**: MEDIO

### Commit 6: Actualizar `compound.md` para escribir archivos consolidados
- **Archivo**: `commands/workflows/compound.md`
- **Riesgo**: CRÍTICO — el feedback loop depende de que compound escriba en los lugares correctos

### Commit 7: Actualizar `discover.md` para seed y setup
- **Archivo**: `commands/workflows/discover.md`
- **Riesgo**: MEDIO

### Commit 8: Actualizar archivos secundarios (CLAUDE.md, rules, roles, skills, agents)
- **Archivos**: ~15 archivos
- **Acción**: Buscar y reemplazar referencias a archivos eliminados
- **Test**: Grep exhaustivo para verificar que no quedan referencias a `proposal.md`, `design.md`, `scratchpad.md`, `compound-memory.md`, `validation-learning-log.md`, `next-feature-briefing.md`
- **Riesgo**: MEDIO — muchos archivos pero cambios mecánicos

### Commit 9: Actualizar `review.md` y agentes de review
- **Archivos**: `commands/workflows/review.md`, `agents/review/*.md`
- **Riesgo**: BAJO

---

## Verificación del Feedback Loop Post-Consolidación

```
compound (feature N) → writes to architecture-profile.yaml + compound_log.md
                              |
plan (feature N+1) Step 0.0d → reads architecture-profile.yaml
                                  (known_pain_points, learned_patterns, agent_calibration)
                              → reads compound_log.md
                                  (last entry: next feature briefing, validation learnings)
                              |
work (feature N+1) Step 3.5  → reads architecture-profile.yaml
                                  (learned_patterns, learned_antipatterns)
                              → reads compound_log.md
                                  (last entry: next feature briefing)
```

**Conclusión**: El feedback loop se SIMPLIFICA (menos archivos que leer/escribir) sin perder información.

---

## Resultado Final

### Antes (9 archivos)
```
openspec/changes/{slug}/
  proposal.md          # Phase 1 output
  specs.md             # Phase 2 output
  design.md            # Phase 3 output
  tasks.md             # Phase 4 output + state
  scratchpad.md        # Runtime notes

.ai/project/
  compound-memory.md   # Pain points, patterns, calibration
  compound_log.md      # Feature history
  validation-learning-log.md  # Validation Q&A history
  next-feature-briefing.md    # Forward-looking intel

openspec/specs/
  architecture-profile.yaml   # Stack, SOLID, learned patterns
```

### Después (4 archivos)
```
openspec/changes/{slug}/
  spec.md              # Secciones 1-7: context + specs + design (all phases)
  tasks.md             # Tasks + state + decision log + scratchpad

openspec/specs/
  architecture-profile.yaml   # Stack + SOLID + patterns + pain points + calibration

.ai/project/
  compound_log.md      # Feature history + validation learnings + next-feature briefing
```

**Reducción**: De 9 archivos independientes a 4 archivos. 5 archivos eliminados, 0 información perdida.

---

## Archivos Críticos para la Implementación

- `plugins/multi-agent-workflow/commands/workflows/plan.md` — Cambios más extensos
- `plugins/multi-agent-workflow/commands/workflows/compound.md` — Rewrite crítico del feedback loop
- `plugins/multi-agent-workflow/core/templates/spec-template.md` — Nuevo template unificado
- `plugins/multi-agent-workflow/core/templates/architecture-profile-template.yaml` — Absorbe compound-memory
- `plugins/multi-agent-workflow/CLAUDE.md` — Punto de entrada, debe reflejar nueva estructura
