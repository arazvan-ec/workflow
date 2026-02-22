# Plan Fase 1: Eliminar Redundancia (Single Source of Truth)

**Fecha**: 2026-02-22
**Alcance**: 10 archivos de comandos (`commands/workflows/`), 4 archivos de reglas (`core/rules/`), y `CLAUDE.md`
**Total de líneas actuales**: ~7,405 líneas en los 15 archivos objetivo
**Reducción estimada total**: ~226 líneas de contenido redundante eliminado

---

## Inventario de Archivos Analizados

| Archivo | Líneas | Rol |
|---------|--------|-----|
| `CLAUDE.md` | 182 | Punto de entrada, siempre cargado |
| `core/rules/framework_rules.md` | 370 | Reglas operacionales, siempre cargado |
| `core/rules/testing-rules.md` | 101 | Reglas de testing, carga condicional |
| `core/rules/security-rules.md` | 58 | Reglas de seguridad, carga condicional |
| `core/rules/git-rules.md` | 50 | Reglas git, carga condicional |
| `commands/workflows/route.md` | 590 | Comando de enrutamiento |
| `commands/workflows/plan.md` | 1,096 | Comando de planificación |
| `commands/workflows/work.md` | 722 | Comando de implementación |
| `commands/workflows/review.md` | 436 | Comando de revisión |
| `commands/workflows/compound.md` | 1,073 | Comando de captura de aprendizajes |
| `commands/workflows/discover.md` | 1,864 | Comando de descubrimiento |
| `commands/workflows/shape.md` | 336 | Comando de modelado |
| `commands/workflows/quick.md` | 187 | Modo rápido |
| `commands/workflows/help.md` | 221 | Ayuda rápida |
| `commands/workflows/status.md` | 119 | Estado |

---

## Conceptos Redundantes Identificados

---

### COMMIT 1: Bounded Correction Protocol (BCP) — Tipos de Desviación y Límites

**Concepto**: Protocolo de corrección con 3 tipos de desviación (TYPE 1: fallo de test, TYPE 2: funcionalidad faltante, TYPE 3: patrón incompleto) y límites adaptativos por complejidad (simple:5, moderate:10, complex:15).

**Ubicación canónica**: `core/rules/testing-rules.md` líneas 39-101

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/work.md` | 395-409 | Re-explica los 3 tipos de desviación completos con definiciones idénticas a testing-rules.md líneas 45-47. También repite los límites adaptativos (simple:5, moderate:10, complex:15) en líneas 348-351 y 399. |
| `commands/workflows/work.md` | 615-638 | Bloque "Escape Hatch" que replica el formato de blocker de testing-rules.md líneas 78-87 con detalles extra pero redundantes. |
| `skills/checkpoint/SKILL.md` | 25-50 | Re-define completamente el BCP con los 3 tipos de desviación y el loop de corrección. Duplicado directo de testing-rules.md líneas 39-75. |
| `CLAUDE.md` | 126 | Resume BCP en 1 línea con los límites. Aceptable como resumen, pero incluye detalles que pertenecen al canónico. |
| `commands/workflows/quick.md` | 58, 100-102 | Menciona BCP con límite de 5 para quick. Este es un OVERRIDE específico, no una re-explicación — es aceptable. |
| `commands/workflows/help.md` | 163 | Re-explica BCP como "Auto-correct up to 10 times, then BLOCKED" — simplificación imprecisa (ignora límites adaptativos). |
| `core/rules/framework_rules.md` | 360 | Terminología con definición condensada — aceptable como glosario. |

**Acción**:

1. En `commands/workflows/work.md` líneas 395-409: Reemplazar la re-explicación de los 3 tipos de desviación con:
   ```markdown
   ### Step 6: Bounded Correction Protocol + Diagnostic Escalation

   Applies the BCP defined in `core/rules/testing-rules.md` with these work-specific additions:

   - **Scale-adaptive limits**: Resolved from `providers.yaml` -> `correction_limits`
   - **Diagnostic escalation**: After 3 consecutive identical errors -> invoke `diagnostic-agent` (forked context)

   > See `core/rules/testing-rules.md` for full protocol: deviation types, correction loop, escape hatch, and iteration limits.
   ```

2. En `commands/workflows/work.md` líneas 348-351: Reemplazar la repetición de límites con: `Resolve max_iterations per core/rules/testing-rules.md § Iteration Limits by Complexity`.

3. En `commands/workflows/work.md` líneas 615-638: Reemplazar el bloque "Escape Hatch" duplicado con: `> When max iterations are reached, use the blocker template from core/rules/testing-rules.md § Escape Hatch.`

4. En `skills/checkpoint/SKILL.md` líneas 25-50: Reemplazar la re-definición completa del BCP con una referencia: `> Implements the Bounded Correction Protocol. See core/rules/testing-rules.md for the full protocol (3 deviation types, correction loop, escape hatch, iteration limits).`

5. En `commands/workflows/help.md` línea 163: Corregir a: `| Bounded Correction Protocol | Auto-correct with scale-adaptive limits (see testing-rules.md) |`

**Reducción estimada**: ~80 líneas

**Riesgo**: BAJO. Los comandos work.md y checkpoint ya referencian testing-rules.md. Dado que testing-rules.md se carga automáticamente para todos los roles que tocan archivos de test, y work.md lo referencia explícitamente, la información siempre estará disponible en contexto.

---

### COMMIT 2: Flow Guards (Prerequisite Checks)

**Concepto**: Cada comando core tiene un bloque "Flow Guard" que verifica prerequisitos. Los prerequisitos están definidos en framework_rules.md §6.

**Ubicación canónica**: `core/rules/framework_rules.md` líneas 69-85 (§6: Workflow Sequence and Flow Guards)

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `CLAUDE.md` | 59-64 | Re-lista los 4 prerequisitos de los flow guards |

**Análisis**: Los bloques en los comandos individuales (plan.md, work.md, review.md, compound.md) contienen lógica ESPECÍFICA de cada comando — no son redundancia pura. Solo CLAUDE.md repite lo que ya dice framework_rules.md §6.

**Acción**:

1. En `CLAUDE.md` líneas 59-64: Reemplazar el listado de flow guards con:
   ```markdown
   ### Flow Guards (enforced)
   Each core command verifies prerequisites before executing. See `core/rules/framework_rules.md` §6 for the complete prerequisite chain.
   ```

**Reducción estimada**: ~5 líneas

**Riesgo**: MUY BAJO.

---

### COMMIT 3: The Flow (Diagrama del Flujo)

**Concepto**: El diagrama ASCII "ROUTE → SHAPE → PLAN → WORK → REVIEW → COMPOUND" con porcentajes.

**Ubicación canónica**: `CLAUDE.md` líneas 5-16

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/help.md` | 150-153 | Diagrama idéntico (en topic: concepts) — duplicado DENTRO de help.md que ya tiene otro en líneas 40-43 |

**Acción**:

1. En `commands/workflows/help.md` líneas 150-153: ELIMINAR el diagrama duplicado del topic "concepts" y reemplazar con: `> See CLAUDE.md for the full flow diagram.`

**Reducción estimada**: ~5 líneas

**Riesgo**: BAJO.

---

### COMMIT 4: Karpathy Principles (re-explicación completa)

**Concepto**: Los 4 principios de Karpathy: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution.

**Ubicación canónica**: `core/docs/KARPATHY_PRINCIPLES.md` (~300 líneas)

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/route.md` | 435-456 | Sección completa "Karpathy Principles Quick Check" con checklist de 22 líneas de re-explicación |

**Acción**:

1. En `commands/workflows/route.md` líneas 435-456: Reemplazar las 22 líneas con:
   ```markdown
   ## Karpathy Principles Quick Check

   Before completing routing, verify compliance with the 4 Karpathy Principles.
   > See `core/rules/framework_rules.md` §2 and `core/docs/KARPATHY_PRINCIPLES.md` for detailed guidance.

   - [ ] Assumptions explicitly stated (Think Before Coding)
   - [ ] Workflow complexity matches task complexity (Simplicity First)
   - [ ] Success criteria defined and testable (Goal-Driven Execution)
   ```

**Reducción estimada**: ~12 líneas

**Riesgo**: BAJO.

---

### COMMIT 5: Contradiction Detection Protocol (CDP)

**Concepto**: Protocolo para detectar contradicciones entre artefactos. Cuando se detecta, PARAR y preguntar al usuario.

**Ubicación canónica**: `core/rules/framework_rules.md` líneas 172-215 (§12)

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/work.md` | 353-361 | Re-explica CDP como "CONTRADICTION CHECK" con 5 líneas de lógica redundante |
| `commands/workflows/review.md` | 209-215 | Re-explica CDP como checklist de verificación de contradicciones |

**Acción**:

1. En `commands/workflows/work.md` líneas 353-361: Condensar a:
   ```markdown
   5. CONTRADICTION CHECK (CDP): Apply `framework_rules.md` §12.
      Compare task requirements against openspec/specs/ baseline and constitution.md.
      If contradiction detected -> STOP, present both sides, ask user.
   ```

2. En `commands/workflows/review.md` líneas 209-215: Condensar a:
   ```markdown
   6. Contradiction Check (CDP):
      - [ ] Implementation consistent with specs.md, design.md, and constitution.md
      - If contradiction found -> apply CDP (`framework_rules.md` §12)
   ```

**Reducción estimada**: ~8 líneas

**Riesgo**: BAJO. framework_rules.md siempre está cargado en contexto.

---

### COMMIT 6: SOLID Constraint (re-explicación en múltiples comandos)

**Concepto**: SOLID como constraint obligatorio en Phase 3 (plan), verificado en checkpoints (work), y validado en review.

**Ubicación canónica**: `core/architecture-reference.md` para patrones SOLID; `commands/workflows/plan.md` líneas 620-817 para el constraint de planificación.

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/work.md` | 462-485 | Stack-Specific Workflows repite "SOLID: solid-analyzer --mode=verify..." en CADA checkpoint (4 veces el mismo patrón) |
| `commands/workflows/review.md` | 149-175 | Re-explica SOLID checklist con 5 principios y verdicts (26 líneas) |
| `commands/workflows/route.md` | 152-155 | Re-explica que SOLID es obligatorio en plan, work, review (3 líneas) |

**Acción**:

1. En `commands/workflows/work.md` líneas 462-485: Reemplazar los 4 bloques repetitivos con un patrón general:
   ```markdown
   > **All checkpoints include SOLID verification**: Run `solid-analyzer --mode=verify --path=<layer-path> --design=design.md` after each checkpoint. Must be COMPLIANT to proceed.
   ```

2. En `commands/workflows/review.md` líneas 149-175: Condensar a:
   ```markdown
   2. **SOLID Design Implementation (CRITICAL)**:
      Verify implementation matches design.md patterns using solid-analyzer.
      > Run: `/workflow-skill:solid-analyzer --mode=verify --path=src --design=design.md --scope=full`
      > Verdict: COMPLIANT -> approve. NON_COMPLIANT on relevance>=high -> REJECT.
      > See `commands/workflows/plan.md` Phase 3 for the SOLID constraint definition.
   ```

3. En `commands/workflows/route.md` líneas 152-155: Condensar a 1 línea:
   ```markdown
   **SOLID compliance is mandatory** in plan (Phase 3), work (checkpoints), and review.
   ```

**Reducción estimada**: ~45 líneas

**Riesgo**: MEDIO. SOLID es un concepto crítico. Mitigación: asegurar que plan.md Phase 3 (canónico) sea siempre legible y que los comandos downstream tengan referencias explícitas.

---

### COMMIT 7: TDD Cycle (Red-Green-Refactor)

**Concepto**: El ciclo TDD Red-Green-Refactor y su enforcement.

**Ubicación canónica**: `core/rules/testing-rules.md` líneas 9-17

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/work.md` | 377-384 | Re-explica el ciclo completo con emojis (8 líneas duplicadas) |
| `commands/workflows/quick.md` | 89-99 | "QUICK TDD CYCLE" de 11 líneas que re-explica Red-Green-Refactor |

**Acción**:

1. En `commands/workflows/work.md` líneas 377-384: Condensar a:
   ```markdown
   Follow the TDD cycle (Red-Green-Refactor) per `core/rules/testing-rules.md`, then verify SOLID compliance per design.md.
   ```

2. En `commands/workflows/quick.md` líneas 89-99: Condensar a:
   ```markdown
   ## Step 2: TDD Execution

   Follow the TDD cycle (Red-Green-Refactor) per `core/rules/testing-rules.md`.
   Max 5 correction iterations (quick tasks should resolve fast).
   If stuck after 5: STOP, suggest full workflow instead.
   ```

**Reducción estimada**: ~15 líneas

**Riesgo**: BAJO.

---

### COMMIT 8: Compound Feedback Loop (carga de learnings)

**Concepto**: El proceso de cargar compound learnings antes de planificar o implementar.

**Ubicación canónica**: `commands/workflows/plan.md` líneas 241-308 (Step 0.0d)

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/work.md` | 239-286 | Re-implementa casi idéntica la carga de compound learnings (Step 3.5) — 48 líneas que replican la estructura de plan.md Step 0.0d |

**Acción**:

1. En `commands/workflows/work.md` líneas 239-286: Condensar las 48 líneas a:
   ```markdown
   ### Step 3.5: Load Compound Learnings (Feedback Loop)

   Load compound learnings using the same sources as `plan.md` Step 0.0d:
   - `compound-memory.md`: Pain points -> extra BCP vigilance; patterns -> preferred implementation approach
   - `architecture-profile.yaml`: Learned patterns -> code references; anti-patterns -> pre-check before writing
   - `next-feature-briefing.md`: Reusable code references and test strategies

   > See `/workflows:plan` Step 0.0d for the full loading protocol and file locations.

   **How compound learnings inform implementation:**

   | Compound Data | Impact on Work |
   |--------------|----------------|
   | Known pain points | Extra BCP vigilance; pre-emptive test coverage |
   | Learned patterns (high confidence) | Preferred approach; deviation requires justification |
   | Learned anti-patterns | Pre-check before writing; use prevention note |
   | Next feature briefing | Specific reusable code references and test strategies |
   ```

**Reducción estimada**: ~25 líneas

**Riesgo**: MEDIO. Si work.md se carga sin plan.md en contexto, el implementador no tendrá los detalles completos. Mitigación: la referencia cruzada es explícita.

---

### COMMIT 9: Write-Then-Advance Rule (Persistencia Incremental)

**Concepto**: Cada fase de planificación debe escribir su output a disco ANTES de avanzar a la siguiente fase.

**Ubicación canónica**: `core/rules/framework_rules.md` líneas 138-170 (§11: Planning Persistence)

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/plan.md` | 84-103 | Sección "MANDATORY: Incremental Persistence Protocol" de 20 líneas que re-explica la misma regla ya definida en framework_rules.md §11 |

**Acción**:

1. En `commands/workflows/plan.md` líneas 84-103: Condensar a:
   ```markdown
   ## MANDATORY: Incremental Persistence Protocol

   > Follow the **Write-Then-Advance Rule** (`core/rules/framework_rules.md` §11): every phase writes its output to disk BEFORE the next phase begins.

   ### Per-Phase Write Directives

   | Phase | Output File | Extra Steps |
   |-------|------------|-------------|
   | Step 0 | (none) | UPDATE tasks.md: Step 0 -> COMPLETED |
   | Phase 1 | `proposal.md` | — |
   | Phase 2 | `specs.md` | RUN Integration Analysis pre-hook |
   | Phase 3 | `design.md` | — |
   | Phase 4 | Update `tasks.md` | APPEND summary to `proposal.md` |
   ```

**Reducción estimada**: ~8 líneas

**Riesgo**: BAJO.

---

### COMMIT 10: Self-Review / Reflection Pattern

**Concepto**: Auto-revisión obligatoria antes de marcar una fase como COMPLETED.

**Ubicación canónica**: `commands/workflows/plan.md` líneas 928-960 (planner) y `commands/workflows/work.md` líneas 655-688 (implementer)

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `skills/checkpoint/SKILL.md` | 72-90 | "Adversarial Self-Review" de 19 líneas que re-define el concepto con overlap significativo |

**Acción**:

1. En `skills/checkpoint/SKILL.md` líneas 72-90: Condensar a:
   ```markdown
   ## Adversarial Self-Review (Checkpoint Prerequisite)

   Before each checkpoint, the implementer must perform self-review per `/workflows:work` Self-Review Protocol.
   **Checkpoint notes must include**: At least 1 self-review finding.
   ```

**Reducción estimada**: ~12 líneas

**Riesgo**: BAJO.

---

### COMMIT 11: 70% Problem / Last-Mile Problem

**Concepto**: "AI ayuda a alcanzar el 70% rápidamente, pero el 30% restante es donde vive la complejidad real."

**Ubicación canónica**: `commands/workflows/compound.md` líneas 19-44

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `core/rules/security-rules.md` | 36-42 | "The Last-Mile Problem" — re-explica el concepto 70/30 desde perspectiva de seguridad |

**Acción**:

1. En `core/rules/security-rules.md` líneas 36-42: Condensar a:
   ```markdown
   ### The Last-Mile Problem

   The final 30% of a feature (edge cases, security, integration) needs HIGH control.
   > See `/workflows:compound` "70% Problem Awareness" for the full analysis framework.
   ```

**Reducción estimada**: ~3 líneas

**Riesgo**: BAJO.

---

### COMMIT 12: Status Values (lista de estados del workflow)

**Concepto**: Los valores de estado: PENDING, IN_PROGRESS, BLOCKED, WAITING_API, COMPLETED, APPROVED, REJECTED.

**Ubicación canónica**: `core/rules/framework_rules.md` línea 120 (§9)

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `CLAUDE.md` | 134 | Re-lista los 7 estados innecesariamente |

**Acción**:

1. En `CLAUDE.md` línea 134: Condensar a:
   ```markdown
   All roles communicate via `tasks.md` (Workflow State section). See `core/rules/framework_rules.md` §9 for status values and synchronization rules.
   ```

**Reducción estimada**: ~2 líneas

**Riesgo**: BAJO.

---

### COMMIT 13: Diagnostic Escalation (invocación de diagnostic-agent)

**Concepto**: Después de 3 errores consecutivos idénticos en BCP, invocar diagnostic-agent.

**Ubicación canónica**: `commands/workflows/work.md` línea 400 (Step 6)

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `commands/workflows/work.md` | 409 | Re-explica lo mismo en prosa 9 líneas después — duplicado DENTRO del mismo archivo |

**Acción**:

1. En `commands/workflows/work.md` línea 409: Eliminar el párrafo redundante.

**Reducción estimada**: ~3 líneas

**Riesgo**: MUY BAJO.

---

### COMMIT 14: Context Fork Pattern (context: fork)

**Concepto**: Los skills y agentes pesados corren en contexto forked.

**Ubicación canónica**: `core/docs/CONTEXT_ENGINEERING.md` líneas 49, 97-116

**Ubicaciones redundantes**:

| Archivo | Líneas | Contenido duplicado |
|---------|--------|---------------------|
| `CLAUDE.md` | 155 | Segunda mención de context: fork (ya dicho en línea 115) |
| `README.md` | 189 | Segunda mención de context: fork (ya dicho en línea 110) |

**Acción**:

1. En `CLAUDE.md` línea 155: ELIMINAR la segunda mención.
2. En `README.md` línea 189: ELIMINAR la segunda mención.

**Reducción estimada**: ~3 líneas

**Riesgo**: MUY BAJO.

---

## Conceptos Analizados SIN Acción Necesaria (SKIP)

Los siguientes conceptos se analizaron y se determinó que NO son redundancia problemática:

- **Compound Engineering Principle (cita)**: Cita inspiracional en múltiples archivos — intencional.
- **SDD Structure (estructura OpenSpec)**: Cada comando muestra su perspectiva — uso contextual válido.
- **Quality Gate Protocol**: Definido una vez en plan.md, aplicado con checks específicos por fase — no es redundancia.
- **Command Table**: Tabla de comandos en múltiples archivos de referencia — intencional.
- **Validation Learning**: framework_rules.md define la REGLA, VALIDATION_LEARNING.md define el SISTEMA — complementarios.
- **Baseline Freeze Rule**: Solo menciones contextuales breves fuera del canónico.

---

## Resumen de Commits

| # | Concepto | Archivo Principal Afectado | Líneas Reducidas | Riesgo |
|---|---------|---------------------------|------------------|--------|
| 1 | BCP (tipos + límites) | work.md, checkpoint/SKILL.md, help.md | ~80 | BAJO |
| 2 | Flow Guards | CLAUDE.md | ~5 | MUY BAJO |
| 3 | The Flow (diagrama) | help.md | ~5 | BAJO |
| 4 | Karpathy Principles | route.md | ~12 | BAJO |
| 5 | CDP | work.md, review.md | ~8 | BAJO |
| 6 | SOLID Constraint | work.md, review.md, route.md | ~45 | MEDIO |
| 7 | TDD Cycle | work.md, quick.md | ~15 | BAJO |
| 8 | Compound Feedback Loop | work.md | ~25 | MEDIO |
| 9 | Write-Then-Advance | plan.md | ~8 | BAJO |
| 10 | Self-Review Pattern | checkpoint/SKILL.md | ~12 | BAJO |
| 11 | 70% Problem | security-rules.md | ~3 | BAJO |
| 12 | Status Values | CLAUDE.md | ~2 | BAJO |
| 13 | Diagnostic Escalation | work.md | ~3 | MUY BAJO |
| 14 | Context Fork | CLAUDE.md, README.md | ~3 | MUY BAJO |
| **TOTAL** | | | **~226** | |

---

## Orden de Ejecución Recomendado

1. **COMMIT 1** (BCP) — mayor impacto, menor riesgo
2. **COMMIT 6** (SOLID) — segundo mayor impacto, riesgo medio
3. **COMMIT 8** (Compound Feedback Loop) — tercer mayor impacto, riesgo medio
4. **COMMIT 7** (TDD Cycle) — impacto moderado, bajo riesgo
5. **COMMIT 4** (Karpathy) — impacto moderado, bajo riesgo
6. **COMMIT 10** (Self-Review) — impacto moderado, bajo riesgo
7. **COMMIT 5** (CDP) — impacto menor, bajo riesgo
8. **COMMIT 9** (Write-Then-Advance) — impacto menor, bajo riesgo
9. **COMMIT 2** (Flow Guards) — impacto menor, muy bajo riesgo
10. **COMMIT 3** (The Flow diagram) — impacto menor, bajo riesgo
11. **COMMIT 11** (70% Problem) — impacto mínimo, bajo riesgo
12. **COMMIT 12** (Status Values) — impacto mínimo, bajo riesgo
13. **COMMIT 13** (Diagnostic Escalation) — impacto mínimo, muy bajo riesgo
14. **COMMIT 14** (Context Fork) — impacto mínimo, muy bajo riesgo

---

## Nota sobre README.md

README.md NO está incluido como objetivo principal de esta fase porque es documentación EXTERNA. La redundancia en README.md respecto a CLAUDE.md y framework_rules.md es INTENCIONAL — un README debe ser auto-contenido.

---

## Validación Post-Ejecución

1. **Verificar que cada referencia cruzada funciona**: Buscar cada `See ...` y confirmar que el target existe.
2. **Verificar que no hay información huérfana**: Ejecutar los comandos del workflow completo (route → plan → work → review → compound) en un proyecto de prueba.
3. **Verificar el modelo de activación de contexto**: Asegurar que los archivos canónicos se cargan en el momento correcto según la tabla de Context Activation Model en CLAUDE.md.

---

## Archivos Críticos para la Implementación

- `plugins/multi-agent-workflow/commands/workflows/work.md` — Archivo con más redundancia concentrada (~100+ líneas reducibles)
- `plugins/multi-agent-workflow/core/rules/testing-rules.md` — Fuente canónica del BCP y TDD
- `plugins/multi-agent-workflow/commands/workflows/plan.md` — Fuente canónica del SOLID constraint y Quality Gate Protocol
- `plugins/multi-agent-workflow/core/rules/framework_rules.md` — Fuente canónica de Flow Guards, CDP, Write-Then-Advance
- `plugins/multi-agent-workflow/skills/checkpoint/SKILL.md` — Duplica BCP y Self-Review significativamente
