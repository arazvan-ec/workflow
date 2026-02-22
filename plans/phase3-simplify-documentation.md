# Phase 3: Simplificar Documentación (Eliminar aspiracional, reducir volumen)

**Fecha**: 2026-02-22
**Alcance**: 8 docs en `core/docs/`, `CLAUDE.md`, `README.md`, `core/architecture-reference.md`
**Líneas totales actuales**: ~3,892 líneas
**Objetivo**: Reducir a ~1,580 líneas (~59% reducción)

---

## Resumen Ejecutivo

El análisis revela tres problemas sistémicos:

1. **Contenido aspiracional/no implementado**: CAPABILITY_PROVIDERS.md documenta extensamente Agent Teams y Compaction API que NO están implementados en ningún comando. MCP_INTEGRATION.md documenta servidores (postgres, slack, puppeteer, github) que no existen como configuración real del plugin.
2. **Redundancia masiva**: CONTEXT_ENGINEERING.md, CAPABILITY_PROVIDERS.md y SESSION_CONTINUITY.md repiten información sobre fork strategy, thresholds y provider detection. WORKFLOW_DECISION_MATRIX.md y ROUTING_REFERENCE.md cubren el mismo tema (routing).
3. **Sobre-explicación**: KARPATHY_PRINCIPLES.md usa 328 líneas para 4 principios simples con templates y checklists que replican lo que ya está en framework_rules.md. VALIDATION_LEARNING.md dedica 324 líneas a un sistema cuya implementación real vive en un skill de 8,786 bytes.

---

## Análisis Documento por Documento

---

### 1. CAPABILITY_PROVIDERS.md

**Estado actual**: 502 líneas
**Líneas objetivo**: ~120 (reducción del 76%)

#### Contenido aspiracional/no implementado

| Sección | Líneas aprox. | Problema |
|---------|---------------|----------|
| "Implementation: Agent Teams (tier: advanced)" (L83-106) | 24 | **NO IMPLEMENTADO**: Ningún comando referencia `TeammateTool`. Búsqueda `grep TeammateTool commands/` devuelve 0. |
| "Transition Guide" worktrees a Agent Teams (L120-129) | 10 | Aspiracional — no hay transición posible |
| "Implementation: Compaction-Aware" (L143-159) | 17 | **PARCIALMENTE ASPIRACIONAL**: `pre_compact.sh` solo se menciona aquí y en providers.yaml, sin implementación real |
| "Threshold Comparison" (L168-177) | 10 | Datos para un modo no completamente implementado |
| "Fork Strategy - Selective Fork" (L191-218) | 28 | Reglas inline/fork (>30 files, >500 lines) NO codificadas en ningún comando. Fork real viene de `context: fork` en frontmatter |
| "Coordination - Native + State" (L230-237) | 8 | Requiere Agent Teams que no existe |
| "Execution Mode" completo (L326-391) | 66 | **DUPLICADO**: Toda esta sección está implementada en `work.md` (líneas 64-80) |
| "Model Recommendations" y "API Parameter Recommendations" (L395-465) | 71 | **ASPIRACIONAL PURO**: `api_recommendations` en providers.yaml no es consumido por ningún comando |
| "What the Plugin CANNOT Abstract" (L468-483) | 16 | Informativo pero irrelevante |
| "Adding a New Provider" (L486-494) | 9 | Meta-documentación sin uso |

#### Contenido sobre-explicado

- "Detection Protocol" (L247-281): 35 líneas de pseudocódigo para algo que es 10 líneas
- "Configuration Guide" (L285-323): Redundante con comentarios de providers.yaml

#### Acción propuesta: RECORTAR DRÁSTICAMENTE

- Eliminar: Agent Teams, Compaction API, Model Recommendations, API Parameters, Execution Mode (duplicado), configuración (redundante)
- Mantener: overview, tabla de providers con descripción corta, fork strategy simplificado, referencia a providers.yaml

---

### 2. CONTEXT_ENGINEERING.md

**Estado actual**: 313 líneas
**Líneas objetivo**: ~100 (reducción del 68%)

#### Contenido aspiracional/no implementado

| Sección | Líneas aprox. | Problema |
|---------|---------------|----------|
| "Queen Agent Pattern" (L183-216) | 34 | Explicación teórica redundante con la implementación real en route.md |
| "Fork Strategy - Selective Fork thresholds" (L124-151) | 28 | **NO IMPLEMENTADO**: Los thresholds no están codificados. Fork se determina solo por frontmatter |
| "Hightower's Process Model Applied" (L242-257) | 16 | Analogía teórica sin valor operativo |

#### Datos incorrectos

- Línea 118: "Forked skills (5)" — **INCORRECTO**: Son 9 skills forked
- Línea 120: "Forked agents (4)" — **INCORRECTO**: Son 5 agents forked (falta diagnostic-agent)

#### Acción propuesta

- Reducir "What is Context Engineering" a 5 líneas + link a Fowler
- Mantener: tablas de Content Types, Activation Methods, Isolation Level (referencia canónica)
- Corregir conteos de forked skills/agents
- Eliminar: Fowler's Warnings, Hightower's Process Model, Quick Reference, Sources

---

### 3. KARPATHY_PRINCIPLES.md

**Estado actual**: 328 líneas
**Líneas objetivo**: ~70 (reducción del 79%)

#### Contenido sobre-explicado

| Sección | Líneas aprox. | Problema |
|---------|---------------|----------|
| "Assumptions Template" (L52-75) | 24 | Template que ningún comando genera ni valida |
| "Simplicity Checklist" (L107-127) | 21 | Checklist manual no automatizada |
| "Surgical Changes Checklist" (L159-180) | 22 | Checklist manual no automatizada |
| "Success Criteria Template" (L213-237) | 25 | Template manual no automatizado |
| "Enhanced Self-Check Protocol" (L253-278) | 26 | **DUPLICADO**: framework_rules.md ya tiene el self-check |
| "Expected Outcomes" (L282-291) | 10 | Prosa motivacional |
| "Relationship to Framework Rules" (L294-304) | 11 | Mapping teórico redundante |

#### Acción propuesta

- Mantener los 4 principios con 3-4 líneas cada uno + Quick Reference Card (líneas 307-325)
- Eliminar TODOS los templates (no son usados), Enhanced Self-Check (duplicado), Expected Outcomes

---

### 4. MCP_INTEGRATION.md

**Estado actual**: 497 líneas
**Líneas objetivo**: ~25 (reducción del 95%)

#### Contenido aspiracional/no implementado

| Sección | Líneas aprox. | Problema |
|---------|---------------|----------|
| "Available MCP Servers" (L82-102) | 21 | **ASPIRACIONAL**: No existe `servers.yaml`. Los servidores son hipotéticos |
| "Verify Role Access" RBAC (L106-113) | 8 | No hay implementación de RBAC por rol |
| Workflows 1-4 (L155-275) | 118 | Ejemplos hipotéticos con servidores que no existen |
| "Security Considerations" (L277-348) | 72 | RBAC, trust levels, audit trail — TODO aspiracional |
| "Error Handling" (L350-395) | 46 | Templates de error para servidores inexistentes |
| "Best Practices" (L397-447) | 51 | Para un sistema aspiracional |
| "Troubleshooting" (L461-488) | 28 | Debug de servidores inexistentes |

#### Acción propuesta: ELIMINAR Y REEMPLAZAR CON NOTA MÍNIMA

Reemplazar 497 líneas con ~25 líneas:
1. El plugin ofrece el skill `mcp-connector` para integración con MCP
2. Referencia al SKILL.md del mcp-connector
3. MCP servers se configuran a nivel de Claude Code, no del plugin
4. El skill corre con `context: fork` para aislamiento

---

### 5. ROUTING_REFERENCE.md

**Estado actual**: 65 líneas
**Líneas objetivo**: 0 (ELIMINAR)

#### Redundancia con WORKFLOW_DECISION_MATRIX.md

| Sección | Duplicado con |
|---------|---------------|
| "Clarifying Question Templates" (L7-26) | WORKFLOW_DECISION_MATRIX.md L101-183 |
| "Workflow Selection Decision Matrix" (L28-37) | WORKFLOW_DECISION_MATRIX.md L48-58 |
| "Confidence Scoring" (L39-47) | WORKFLOW_DECISION_MATRIX.md L260-278 |

Solo 15 líneas son únicas: Self-Correction Protocol + Router Verification Checklist.

#### Acción: FUSIONAR CON WORKFLOW_DECISION_MATRIX.md

Migrar las 15 líneas únicas y eliminar el archivo.

---

### 6. SESSION_CONTINUITY.md

**Estado actual**: 173 líneas
**Líneas objetivo**: ~110 (reducción del 36%)

#### Contenido aspiracional

- "Provider-Aware Thresholds" columna "Advanced (Opus 4.6+)" (L37-47): no verificado como implementado

#### Sobre-explicado

- "Scratchpad Pattern" (L20-31): 12 líneas para "usa scratchpad.md como memoria de trabajo"
- "What to Do When Resuming Fails" (L129-144): 16 líneas de troubleshooting básico → 6 líneas

#### Acción propuesta

- Eliminar columna Advanced thresholds
- Condensar Scratchpad Pattern a 4 líneas
- Condensar troubleshooting a 6 líneas
- Eliminar Quick Reference (ya está en CLAUDE.md)

---

### 7. VALIDATION_LEARNING.md

**Estado actual**: 324 líneas
**Líneas objetivo**: ~60 (reducción del 81%)

#### Contenido aspiracional

| Sección | Líneas aprox. | Problema |
|---------|---------------|----------|
| "Cycle 1-3 + Cycle N" examples (L42-106) | 65 | Ejemplos hipotéticos |
| "Install-Time Learning (The Loader)" (L229-264) | 36 | "Universal Learnings" UNI-001 a UNI-005 no existen como datos reales |
| "Metrics & Effectiveness" (L268-290) | 23 | Métricas teóricas sin tracking real |
| "Pattern Lifecycle" (L188-225) | 38 | Más detallado que la implementación real |

#### Acción propuesta

- Mantener: propósito (5 líneas), ciclo de aprendizaje (10 líneas), estructura del log (5 líneas), constraints (7 líneas)
- Eliminar: ejemplos de Cycle 1-N, Universal Learnings, Metrics, diagrama ASCII, loader details
- La implementación real vive en `validation-learning-log/SKILL.md`

---

### 8. WORKFLOW_DECISION_MATRIX.md

**Estado actual**: 355 líneas
**Líneas objetivo**: ~200 (reducción del 44%, absorbiendo ROUTING_REFERENCE)

#### Sobre-explicado

| Sección | Líneas aprox. | Problema |
|---------|---------------|----------|
| "Clarification Question Trees" (L101-183) | 83 | Árboles verbosos → condensar a 40 líneas |
| "Workflow Selection Flowchart" ASCII (L187-256) | 70 | Redundante con Quick Reference Card |
| "Integration Points" (L282-308) | 26 | Pseudocódigo YAML redundante |
| "Common Patterns" (L311-342) | 32 | Condensar a 15 líneas |

#### Acción propuesta

- Mantener: Quick Reference Card, Detailed Decision Matrix tables
- Absorber 15 líneas únicas de ROUTING_REFERENCE.md
- Condensar Clarification Question Trees, eliminar flowchart ASCII
- Condensar Integration Points y Common Patterns

---

### 9. CLAUDE.md

**Estado actual**: 182 líneas
**Líneas objetivo**: ~145 (reducción del 20%)

#### Acción propuesta: COMPRIMIR MODERADAMENTE

- Condensar "The Flow" a 15 líneas (eliminar "Compound Feedback Loop" detalle, "Project Seed")
- Fusionar "Automatic Operations" en Core Commands como nota
- Condensar "Context Budget Awareness" a 5 líneas
- Reducir "Best Practices" a 7 items
- Mantener intactos: Core Commands, Agents, Skills, Context Activation Model, State Management, SDD

**Riesgo**: ALTO — se carga en CADA sesión. Requiere verificación cuidadosa.

---

### 10. README.md

**Estado actual**: 299 líneas
**Líneas objetivo**: ~200 (reducción del 33%)

#### Bugs encontrados

- Línea 114: "## Skills (14)" — **INCORRECTO**: Son 15 skills (falta `source-report`)

#### Acción propuesta

- Corregir count de skills a 15
- Condensar Key Patterns a lista de nombres con links
- Eliminar Context Engineering tabla (ya en CLAUDE.md)
- Reducir changelogs: solo v3.2.0, 5 líneas
- Eliminar v3.1.0 Changes

---

### 11. architecture-reference.md

**Estado actual**: 854 líneas
**Líneas objetivo**: ~550 (reducción del 36%)

#### Sobre-explicado

| Sección | Líneas aprox. | Problema |
|---------|---------------|----------|
| SOLID "Violations and Corrective Patterns" (L20-291) | 272 | Extremadamente detallado. Eliminar decision trees (el agente ya sabe elegir patrones). Mantener tablas de patrones. |
| "Pattern Selection: Project-Based Approach" (L326-352) | 27 | Redundante con solid-analyzer |
| C-BASE-04 árbol DDD (L387-408) | 22 | Ejemplo específico, no genérico para stack-agnostic |
| AC-01 a AC-04 decision trees (L589-764) | ~50 | Condensar, mantener tablas |

#### Acción propuesta

- Eliminar decision trees de cada principio SOLID, mantener indicadores + Test Rápido + Violations tabla
- Eliminar "Pattern Selection" (redundante con solid-analyzer)
- Eliminar árbol DDD de C-BASE-04
- Mantener intactos: Dimensional Constraint Rules, Quick Reference tabla, SOLID Verdict Matrix

**Riesgo**: MEDIO-ALTO — referencia para plan Phase 3 y solid-analyzer.

---

## Propuesta de Fusiones

### Fusión: ROUTING_REFERENCE.md → WORKFLOW_DECISION_MATRIX.md

**Razón**: ROUTING_REFERENCE (65 líneas) es un subconjunto. Solo 15 líneas son únicas.

**Acción**:
1. Mover Self-Correction Protocol y Router Verification Checklist a WORKFLOW_DECISION_MATRIX.md
2. Eliminar ROUTING_REFERENCE.md
3. Actualizar referencias en CLAUDE.md y route.md

---

## Resumen de Reducciones

| Documento | Actual | Objetivo | Reducción | % |
|-----------|--------|----------|-----------|---|
| CAPABILITY_PROVIDERS.md | 502 | 120 | -382 | 76% |
| CONTEXT_ENGINEERING.md | 313 | 100 | -213 | 68% |
| KARPATHY_PRINCIPLES.md | 328 | 70 | -258 | 79% |
| MCP_INTEGRATION.md | 497 | 25 | -472 | 95% |
| ROUTING_REFERENCE.md | 65 | 0 | -65 | 100% |
| SESSION_CONTINUITY.md | 173 | 110 | -63 | 36% |
| VALIDATION_LEARNING.md | 324 | 60 | -264 | 81% |
| WORKFLOW_DECISION_MATRIX.md | 355 | 200 | -155 | 44% |
| CLAUDE.md | 182 | 145 | -37 | 20% |
| README.md | 299 | 200 | -99 | 33% |
| architecture-reference.md | 854 | 550 | -304 | 36% |
| **TOTAL** | **3,892** | **1,580** | **-2,312** | **59%** |

---

## Plan de Commits (orden de menor a mayor riesgo)

| # | Commit message | Archivo | Riesgo |
|---|----------------|---------|--------|
| 1 | `docs: eliminar ROUTING_REFERENCE.md, migrar contenido único a WORKFLOW_DECISION_MATRIX` | ROUTING_REFERENCE.md, WORKFLOW_DECISION_MATRIX.md | BAJO |
| 2 | `docs: reducir MCP_INTEGRATION.md de 497 a ~25 líneas — eliminar contenido aspiracional` | MCP_INTEGRATION.md | BAJO |
| 3 | `docs: reducir KARPATHY_PRINCIPLES.md de 328 a ~70 líneas — eliminar templates no usados` | KARPATHY_PRINCIPLES.md | BAJO |
| 4 | `docs: reducir VALIDATION_LEARNING.md de 324 a ~60 líneas — referir a SKILL.md` | VALIDATION_LEARNING.md | BAJO |
| 5 | `docs: reducir CAPABILITY_PROVIDERS.md de 502 a ~120 líneas — eliminar Agent Teams y API recommendations` | CAPABILITY_PROVIDERS.md | MEDIO |
| 6 | `docs: reducir CONTEXT_ENGINEERING.md de 313 a ~100 líneas — corregir conteos, eliminar teoría` | CONTEXT_ENGINEERING.md | MEDIO |
| 7 | `docs: reducir WORKFLOW_DECISION_MATRIX.md de 355 a ~200 líneas — eliminar flowchart, condensar trees` | WORKFLOW_DECISION_MATRIX.md | MEDIO |
| 8 | `docs: recortar SESSION_CONTINUITY.md de 173 a ~110 líneas` | SESSION_CONTINUITY.md | BAJO |
| 9 | `docs: reducir architecture-reference.md de 854 a ~550 líneas — eliminar decision trees` | architecture-reference.md | MEDIO-ALTO |
| 10 | `docs: optimizar README.md de 299 a ~200 líneas — corregir skill count, condensar changelogs` | README.md | BAJO |
| 11 | `docs: comprimir CLAUDE.md de 182 a ~145 líneas — condensar flow y best practices` | CLAUDE.md | ALTO |

---

## Evaluación de Riesgos

### Riesgo ALTO
- **CLAUDE.md**: Se carga en cada sesión. Cualquier información eliminada que sea necesaria para routing o flow guards causará fallos.
- **architecture-reference.md**: Referencia para plan Phase 3 y solid-analyzer. Eliminar decision trees podría degradar calidad de selección de patrones SOLID.

### Riesgo MEDIO
- **CAPABILITY_PROVIDERS.md**: Si Agent Teams se lanza pronto, habrá que re-escribir.
- **CONTEXT_ENGINEERING.md**: Los conteos incorrectos de forked skills/agents deben corregirse independientemente.

### Riesgo BAJO
- **MCP_INTEGRATION.md**: Todo el contenido eliminado es aspiracional.
- **KARPATHY_PRINCIPLES.md**: Los principios se mantienen. Solo se pierden templates no usados.
- **VALIDATION_LEARNING.md**: La implementación real vive en el SKILL.md.
- **ROUTING_REFERENCE.md**: 100% del contenido útil migra a WORKFLOW_DECISION_MATRIX.md.

### Mitigación general
Todos los contenidos eliminados quedan en el historial de git.

---

## Archivos Críticos para la Implementación

- `plugins/multi-agent-workflow/core/docs/CAPABILITY_PROVIDERS.md` — Mayor contenido aspiracional a eliminar
- `plugins/multi-agent-workflow/core/docs/MCP_INTEGRATION.md` — Mayor ratio de reducción (95%)
- `plugins/multi-agent-workflow/core/architecture-reference.md` — Mayor riesgo (decision trees usados por plan/solid-analyzer)
- `plugins/multi-agent-workflow/CLAUDE.md` — Mayor sensibilidad (cargado cada sesión)
- `plugins/multi-agent-workflow/core/docs/WORKFLOW_DECISION_MATRIX.md` — Target de absorción de ROUTING_REFERENCE.md
