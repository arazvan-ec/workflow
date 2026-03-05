# Plan de Mejoras del Plugin Workflow v3.2.0

**Fecha**: 2026-03-05
**Estado**: DOCUMENTADO — Pendiente de ejecución
**Branch**: `claude/plugin-improvement-plan-88GlP`
**Base**: Análisis fresh (01-plugin-analysis.md) + Mejoras detectadas (02-improvements-detected.md) + Mejores prácticas industria (03-best-practices.md)

---

## Estructura del Plan

El plan se organiza en **6 fases**, cada una con **subfases atómicas** que pueden commitearse independientemente.

**Convención de commits**: `refactor(plugin): F{fase}.{subfase} - {descripción corta}`

---

## FASE 1: Bugs y Referencias Rotas

**Objetivo**: Hacer que el 100% de las referencias internas sean válidas.
**Prioridad**: P0 — CRÍTICO
**Archivos afectados**: help.md, route.md, discover.md, framework_rules.md, CONTEXT_ENGINEERING.md, compound.md, work.md, plan.md, SESSION_CONTINUITY.md, CAPABILITY_PROVIDERS.md

### F1.1 — Eliminar refs a archivos inexistentes en help.md (BUG-01)

- **Qué**: help.md líneas 70-72 y 188 referencian QUICKSTART.md, TUTORIAL.md, GLOSSARY.md que no existen
- **Acción**: Eliminar las 3 referencias. No crear archivos nuevos
- **Archivos**: `commands/workflows/help.md`
- **Tamaño**: ~5 líneas cambiadas

### F1.2 — Unificar versiones a 3.2.0 (BUG-02)

- **Qué**: Versiones inconsistentes entre archivos (3.0.0, 1.2.0, 2.1.0, 1.0.0 vs 3.2.0 en plugin.json)
- **Acción**: Actualizar todos los headers de versión a 3.2.0
- **Archivos**: `framework_rules.md`, `CONTEXT_ENGINEERING.md`, `route.md`, `help.md`, `discover.md`
- **Tamaño**: ~5 líneas cambiadas (una por archivo)

### F1.3 — Resolver DECISIONS.md vs Decision Log (BUG-03 + CON-01)

- **Qué**: 10 referencias a DECISIONS.md como archivo, pero no existe template ni se crea en ningún workflow. El Decision Log en tasks.md cubre esta necesidad
- **Acción**: Reemplazar todas las refs a DECISIONS.md por "Decision Log section in tasks.md". Eliminar la ambigüedad
- **Archivos**: `planner.md` (5 refs), `work.md` (2 refs), `framework_rules.md` (2 refs), `git-rules.md` (1 ref)
- **Tamaño**: ~10 líneas cambiadas

### F1.4 — Eliminar refs a comandos inexistentes en SESSION_CONTINUITY.md

- **Qué**: 20+ referencias a `/workflows:snapshot`, `/workflows:restore` que no existen
- **Acción**: Reemplazar por los skills que sí existen: `checkpoint` skill y `git-sync` skill
- **Archivos**: `core/docs/SESSION_CONTINUITY.md`
- **Tamaño**: ~20 líneas cambiadas

### F1.5 — Eliminar refs a `/workflows:parallel` en CAPABILITY_PROVIDERS.md

- **Qué**: 5+ referencias a `/workflows:parallel` que no existe como comando
- **Acción**: Reemplazar por referencia al provider de paralelización (agent-teams o worktrees)
- **Archivos**: `core/docs/CAPABILITY_PROVIDERS.md`
- **Tamaño**: ~5 líneas cambiadas

### F1.6 — Corregir refs rotas en compound.md, work.md, plan.md, discover.md

- **Qué**: Refs a `core/agent-memory.md` (no existe), `core/rules/ddd_rules.md` (no existe), `/workflow-skill:spec-validator` (no existe), `/opsx:archive` (no existe), `/workflows:quickstart` (deprecado), `/workflows:reload` (no existe)
- **Acción**: Eliminar o reemplazar cada referencia según el caso:
  - `core/agent-memory.md` → eliminar ref o inline si necesario
  - `core/rules/ddd_rules.md` → apuntar a `architecture-reference.md`
  - `/workflow-skill:spec-validator` → determinar skill correcto o eliminar
  - `/opsx:archive` → determinar si spec-merger cubre, o eliminar
  - `/workflows:quickstart` → reemplazar por `/workflows:discover --setup`
  - `/workflows:reload` → eliminar o documentar como "re-read CLAUDE.md"
- **Archivos**: `compound.md`, `work.md`, `plan.md`, `discover.md`
- **Tamaño**: ~15 líneas cambiadas

### F1.7 — Verificación final de Fase 1

- **Qué**: Ejecutar greps para confirmar 0 referencias rotas
- **Acción**: Verificar con grep que no quedan refs a: agent-memory, ddd_rules, spec-validator, opsx:archive, /workflows:quickstart, /workflows:snapshot, /workflows:restore, /workflows:reload, /workflows:parallel, QUICKSTART.md, TUTORIAL.md, GLOSSARY.md
- **Archivos**: ninguno (solo verificación)

---

## FASE 2: Estado de Workflow y Trazabilidad

**Objetivo**: Un solo formato autoritativo para tasks.md + Decision Log integrado.
**Prioridad**: P0 — CRÍTICO
**Archivos afectados**: tasks-template.md (nuevo), route.md, plan.md, work.md, review.md, compound.md

### F2.1 — Crear template canónico de tasks.md

- **Qué**: No existe un formato único para tasks.md. Cada workflow escribe diferente
- **Acción**: Crear `core/templates/tasks-template.md` con formato canónico:
  - Metadata (feature, dates, current phase)
  - Phase Status table (Route/Shape/Plan/Work/Review/Compound)
  - Tasks table (generada por Plan Phase 4)
  - Resume Information (last completed, next action, blocked by)
  - Decision Log table (decision, alternatives, rationale, phase)
  - QA Summary (code review, security, performance, architecture, SOLID)
- **Archivos**: `core/templates/tasks-template.md` (NUEVO)
- **Tamaño**: ~40 líneas

### F2.2 — Actualizar route.md para crear tasks.md inicial

- **Qué**: route.md no crea tasks.md al iniciar un feature
- **Acción**: Añadir instrucción en route.md para crear tasks.md con Metadata + Phase Status (todo PENDING excepto Route = IN_PROGRESS)
- **Archivos**: `commands/workflows/route.md`
- **Tamaño**: ~10 líneas añadidas

### F2.3 — Actualizar plan.md para escribir en formato canónico

- **Qué**: plan.md Phase 4 genera tasks sin formato estándar
- **Acción**: Añadir referencia al template canónico en Phase 4. Comment: `<!-- Format: see core/templates/tasks-template.md -->`
- **Archivos**: `commands/workflows/plan.md`
- **Tamaño**: ~5 líneas cambiadas

### F2.4 — Actualizar work.md para leer/escribir formato canónico

- **Qué**: work.md actualiza tasks.md sin seguir formato
- **Acción**: Actualizar para que escriba Status de cada task + Resume Information según template
- **Archivos**: `commands/workflows/work.md`
- **Tamaño**: ~10 líneas cambiadas

### F2.5 — Actualizar review.md para escribir QA Summary

- **Qué**: review.md no tiene formato estándar para sus resultados en tasks.md
- **Acción**: Actualizar para que escriba QA Summary section según template
- **Archivos**: `commands/workflows/review.md`
- **Tamaño**: ~5 líneas cambiadas

### F2.6 — Actualizar compound.md para cerrar Phase Status

- **Qué**: compound.md debe marcar Review como APPROVED y Phase Status completo
- **Acción**: Actualizar para que escriba Phase Status final según template
- **Archivos**: `commands/workflows/compound.md`
- **Tamaño**: ~5 líneas cambiadas

---

## FASE 3: Reducción de Contexto

**Objetivo**: Reducir contenido redundante ~50%, mejorar eficiencia del context window.
**Prioridad**: P1 — ALTO
**Archivos afectados**: plan.md, work.md, framework_rules.md, SESSION_CONTINUITY.md, CONTEXT_ENGINEERING.md, shape.md, review.md, compound.md, discover.md

### F3.1 — Simplificar Flow Guards en 5 comandos (RED-01)

- **Qué**: 5 comandos tienen Flow Guards de ~30-40 líneas cada uno (~200 líneas totales de redundancia)
- **Acción**: En cada comando, reducir Flow Guard a 3 líneas: "Read tasks.md, verify {fase anterior} = COMPLETED, if not STOP"
- **Archivos**: `plan.md`, `work.md`, `review.md`, `compound.md`, `shape.md`
- **Tamaño**: ~120 líneas eliminadas

### F3.2 — Reducir repeticiones de BCP (RED-03)

- **Qué**: BCP descrito en testing-rules.md (definición canónica) y repetido en work.md (~40 líneas) y framework_rules.md (~20 líneas)
- **Acción**: En work.md y framework_rules.md, reducir a 1-2 líneas con referencia a testing-rules.md
- **Archivos**: `commands/workflows/work.md`, `core/rules/framework_rules.md`
- **Tamaño**: ~50 líneas eliminadas

### F3.3 — Reducir Write-Then-Advance repetido (RED-02)

- **Qué**: Mencionado 5+ veces entre plan.md, framework_rules.md, shape.md
- **Acción**: Definir UNA VEZ en framework_rules.md. Reducir otras menciones a referencia de 1 línea
- **Archivos**: `commands/workflows/plan.md`, `commands/workflows/shape.md`
- **Tamaño**: ~20 líneas eliminadas

### F3.4 — Reducir ejemplos excesivos en plan.md (parte de UX-01 prep)

- **Qué**: plan.md tiene ~400 líneas de ejemplos de output detallados que el agente no necesita
- **Acción**: Reducir ejemplos de output de cada Phase a ~5 líneas (headers esperados, no contenido completo). Mantener Quality Gates, Phase transitions y SOLID integration points intactos
- **Archivos**: `commands/workflows/plan.md`
- **Tamaño**: ~300 líneas eliminadas
- **Objetivo post-cambio**: plan.md < 900 líneas

### F3.5 — Simplificar SESSION_CONTINUITY.md

- **Qué**: 570 líneas, ~60% sobre comandos que no existen (ya corregidos en F1.4). El resto es verboso
- **Acción**: Reescribir enfocándose en: cómo persiste el estado (tasks.md, git, openspec), cómo resumir sesión (4 pasos), cómo crear checkpoint, qué hacer si falla
- **Archivos**: `core/docs/SESSION_CONTINUITY.md`
- **Tamaño**: Objetivo ~200 líneas (reducción de ~370 líneas)
- **Nota**: F1.4 corrige las refs rotas primero, F3.5 simplifica el documento completo

### F3.6 — Reducir discover.md (UX-01)

- **Qué**: 1,864 líneas para un comando de onboarding que se ejecuta una vez
- **Acción**: Eliminar bloques de ejemplo extensos, consolidar instrucciones repetidas, mantener la lógica de detección y generación de artifacts
- **Archivos**: `commands/workflows/discover.md`
- **Tamaño**: Objetivo < 1200 líneas (reducción de ~600 líneas)

### F3.7 — Reducir compound.md (UX-02)

- **Qué**: 1,073 líneas para un paso mayormente mecánico post-review
- **Acción**: Eliminar repeticiones, consolidar instrucciones, mantener la lógica de aprendizaje
- **Archivos**: `commands/workflows/compound.md`
- **Tamaño**: Objetivo < 700 líneas (reducción de ~370 líneas)

---

## FASE 4: Clarificación de Flujo y HITL

**Objetivo**: Eliminar ambigüedades de routing, añadir checkpoints humanos entre fases.
**Prioridad**: P1 — ALTO
**Archivos afectados**: route.md, plan.md, quick.md, discover.md, help.md

### F4.1 — Añadir diagrama de decisión en route.md

- **Qué**: No está claro cuándo ir a quick vs plan vs shape vs discover
- **Acción**: Añadir diagrama ASCII de decisión (Request → route → ¿setup? → discover / ¿simple? → quick / ¿claro? → plan / → shape → plan)
- **Archivos**: `commands/workflows/route.md`
- **Tamaño**: ~15 líneas añadidas

### F4.2 — Eliminar ejecución sin routing en plan.md

- **Qué**: plan.md sugiere que planner puede ejecutar sin routing (--workflow=task-breakdown)
- **Acción**: Eliminar cualquier referencia a ejecución directa sin routing previo
- **Archivos**: `commands/workflows/plan.md`
- **Tamaño**: ~5 líneas cambiadas

### F4.3 — Definir re-entrada de quick a plan

- **Qué**: quick.md dice "redirect to full workflow if scope grows" sin definir el punto de re-entrada
- **Acción**: Añadir bloque explícito: "Si >3 archivos o diseño arquitectónico → STOP quick → /workflows:plan. El estado descubierto se traslada como input para plan Phase 1"
- **Archivos**: `commands/workflows/quick.md`
- **Tamaño**: ~10 líneas añadidas

### F4.4 — Clarificar discover como onboarding (no workflow)

- **Qué**: discover.md no deja claro que es un comando de onboarding independiente del routing
- **Acción**: Añadir nota: "/workflows:discover --setup es onboarding, no workflow. No requiere routing. Se ejecuta UNA VEZ"
- **Archivos**: `commands/workflows/discover.md`
- **Tamaño**: ~5 líneas añadidas

### F4.5 — Añadir HITL checkpoints entre fases de plan (GAP-05)

- **Qué**: No hay checkpoint humano entre Phase 3 (design) y Phase 4 (tasks) ni durante decisiones de alto riesgo
- **Acción**: Añadir en plan.md: "Present summary to user between Phase 2→3 and Phase 3→4. If corrections → apply. If approved → advance."
- **Archivos**: `commands/workflows/plan.md`
- **Tamaño**: ~15 líneas añadidas

### F4.6 — Actualizar help.md con flujo de decisión

- **Qué**: help.md debe reflejar el flujo de decisión actualizado
- **Acción**: Verificar que la sección de quick reference en help.md refleja los cambios de F4.1-F4.4
- **Archivos**: `commands/workflows/help.md`
- **Tamaño**: ~10 líneas cambiadas

---

## FASE 5: Coherencia y Calidad

**Objetivo**: SOLID enforcement unificado, reflection pattern, terminología consistente.
**Prioridad**: P1 — ALTO
**Archivos afectados**: architecture-reference.md, plan.md, work.md, review.md, framework_rules.md, solid-analyzer skill

### F5.1 — Definir SOLID Verdict Matrix en architecture-reference.md (CON-03)

- **Qué**: SOLID enforcement varía entre plan.md (bloqueante), work.md (correctivo), review.md (verificativo)
- **Acción**: Añadir tabla "SOLID Verdict Matrix" en architecture-reference.md con comportamiento por fase:
  - COMPLIANT → proceder
  - NEEDS_WORK (critical) → volver / BCP correction / REJECTED
  - NEEDS_WORK (medium) → documentar excepción, proceder
  - NON_COMPLIANT → BLOCKER
  - N/A → Skip
- **Archivos**: `core/architecture-reference.md`
- **Tamaño**: ~20 líneas añadidas

### F5.2 — Referenciar Verdict Matrix desde plan.md, work.md, review.md

- **Qué**: Cada comando debe usar la misma matriz de decisión
- **Acción**: En cada archivo, reemplazar la lógica SOLID ad-hoc por referencia a "Apply SOLID Verdict Matrix (see architecture-reference.md)"
- **Archivos**: `plan.md`, `work.md`, `review.md`
- **Tamaño**: ~15 líneas cambiadas (5 por archivo)

### F5.3 — Cambiar SOLID de auto-scoring a justificación textual (Gap H)

- **Qué**: El agente se auto-asigna scores numéricos altos sin justificación
- **Acción**: En architecture-reference.md, añadir requisito de justificación textual por principio: "SRP: {archivo} tiene responsabilidad única porque {razón}. Evidencia: {ref}". Eliminar cualquier formato "22/25" o similar
- **Archivos**: `core/architecture-reference.md`
- **Tamaño**: ~15 líneas añadidas

### F5.4 — Implementar Reflection Pattern en Quality Gates (GAP-01)

- **Qué**: Quality Gates son checks estáticos sin auto-crítica
- **Acción**: Añadir "Step 1: Self-Review (Reflection)" antes de cada checklist formal en plan.md. Preguntas: suposiciones no validadas, qué podría fallar, gaps lógicos, sobre/sub-diseño
- **Archivos**: `commands/workflows/plan.md`
- **Tamaño**: ~30 líneas añadidas (en 4 Quality Gates)

### F5.5 — Implementar Reflection en work.md y review.md

- **Qué**: work.md (checkpoints) y review.md (QA) no tienen self-review
- **Acción**: Añadir paso de auto-reflexión antes de checkpoint en work.md y antes de veredicto en review.md
- **Archivos**: `commands/workflows/work.md`, `commands/workflows/review.md`
- **Tamaño**: ~15 líneas añadidas

### F5.6 — Estandarizar terminología (CON-02)

- **Qué**: framework_rules.md ya tiene glosario (§ Terminology) pero puede no aplicarse consistentemente
- **Acción**: Verificar y corregir uso en todos los archivos: "Workflow State" (no "Feature state"), "Checkpoint" (no "Snapshot" para git commits), "Agent" vs "Role" sin confusión
- **Archivos**: búsqueda global en todos los archivos del plugin
- **Tamaño**: ~10-20 líneas cambiadas

---

## FASE 6: Mejoras Funcionales

**Objetivo**: Test Contract Sketch, Security Analysis, Feedback Loop, Error Recovery.
**Prioridad**: P2 — MEDIO
**Archivos afectados**: plan.md, compound.md, review.md, framework_rules.md, todos los commands

### F6.1 — Añadir Test Contract Sketch en Phase 2 (GAP-02)

- **Qué**: Tests solo aparecen en Phase 4 (tasks). No hay validación de testeabilidad durante specs
- **Acción**: Añadir sub-paso 2.5 en plan.md: "Para cada spec principal, bosquejar 2-3 tests de aceptación en Given/When/Then. Si un spec no puede expresarse como test → spec ambiguo → refinar"
- **Archivos**: `commands/workflows/plan.md`
- **Tamaño**: ~15 líneas añadidas

### F6.2 — Añadir Security Threat Analysis en Phase 3 (GAP-03)

- **Qué**: Phase 3 cubre SOLID pero no seguridad
- **Acción**: Añadir sub-paso 3.5 en plan.md: "Identificar superficie de ataque, verificar validación de inputs, auth requerida, datos sensibles. Si nueva superficie → documentar mitigaciones en design.md"
- **Archivos**: `commands/workflows/plan.md`
- **Tamaño**: ~15 líneas añadidas

### F6.3 — Implementar Feedback Loop REVIEW → PLAN (GAP-06)

- **Qué**: Si review encuentra problemas de diseño (no solo código), no hay path para retroalimentar a plan
- **Acción**: En review.md, añadir: "Si problemas son arquitectónicos → REJECTED con feedback type=DESIGN → tasks.md Phase Plan = NEEDS_REVISION". En plan.md: "Si status = NEEDS_REVISION → re-ejecutar Phase 3 con feedback de review"
- **Archivos**: `commands/workflows/review.md`, `commands/workflows/plan.md`
- **Tamaño**: ~15 líneas añadidas

### F6.4 — Documentar rutas de error en cada comando (GAP-04)

- **Qué**: Solo se documenta el happy path
- **Acción**: Añadir sección "## Error Recovery" al final de cada comando con tabla: Situación | Acción
  - tasks.md no existe → crear desde template
  - Fase anterior no COMPLETED → STOP, informar
  - SOLID NON_COMPLIANT tras 3 iteraciones → pedir decisión humana
  - BCP agota iteraciones → diagnostic-agent, luego BLOCK
  - Review REJECTED → registrar feedback, volver a work
- **Archivos**: `route.md`, `plan.md`, `work.md`, `review.md`, `compound.md`, `quick.md`
- **Tamaño**: ~60 líneas añadidas (10 por archivo)

### F6.5 — Añadir chunking de outputs (GAP-07)

- **Qué**: No hay directivas de tamaño máximo de outputs
- **Acción**: Añadir en plan.md regla general: "Ningún output individual debe exceder 200 líneas. Si excede, dividir en sub-outputs y verificar cada uno"
- **Archivos**: `commands/workflows/plan.md`
- **Tamaño**: ~5 líneas añadidas

### F6.6 — Añadir Retrospective en compound (Gap B)

- **Qué**: No hay retroalimentación estructurada para futuras ejecuciones
- **Acción**: En compound.md, añadir step "Retrospective" que genera `99_retrospective.md` con: decisiones revisadas, patterns exitosos, gaps descubiertos tarde. En plan.md Phase 1: "Si existe retrospective previo, leerlo"
- **Archivos**: `commands/workflows/compound.md`, `commands/workflows/plan.md`
- **Tamaño**: ~20 líneas añadidas

### F6.7 — Verificación final del plan completo

- **Qué**: Ejecutar greps y verificaciones para confirmar todo
- **Acción**: Verificar 0 refs rotas, versiones unificadas, tamaños de archivo reducidos, todas las mejoras aplicadas
- **Archivos**: ninguno (solo verificación)

---

## Resumen de Métricas

| Métrica | Antes | Después |
|---------|-------|---------|
| Referencias rotas | 10+ | 0 |
| Versiones inconsistentes | 5 | 0 (todas 3.2.0) |
| DECISIONS.md vs Decision Log | 2 mecanismos | 1 (Decision Log en tasks.md) |
| Líneas en plan.md | ~1365 | < 900 |
| Líneas en SESSION_CONTINUITY.md | ~570 | ~200 |
| Líneas en discover.md | ~1864 | < 1200 |
| Líneas en compound.md | ~1073 | < 700 |
| Formatos de tasks.md | 3-4 | 1 canónico |
| SOLID enforcement | Ambiguo | Verdict Matrix única |
| Quality Gates con Reflection | No | Sí |
| HITL entre fases de plan | Parcial | Phase 2→3 y 3→4 |
| Test Contracts tempranos | No | Sí (Phase 2.5) |
| Security Analysis en diseño | No | Sí (Phase 3.5) |
| Rutas de error documentadas | 0 | 6 comandos |
| Feedback loop REVIEW→PLAN | No | Sí |
| Retrospective en compound | No | Sí |

---

## Dependencias entre Fases

```
Fase 1 (refs rotas) ──→ Fase 3 (reducción contexto, especialmente F3.5)
Fase 2 (tasks.md)   ──→ Fase 4 (routing necesita saber formato de tasks.md)
Fase 3 (reducción)  ──→ Fase 5 (añadir reflection a plan.md ya simplificado)
Fase 5 (SOLID)      ──→ Fase 6 (test contracts + security necesitan SOLID resuelto)

Orden recomendado: F1 → F2 → F3 → F4 → F5 → F6
```

---

## Lo Que NO Cambia

- El flujo general: Route → Shape → Plan → Work → Review → Compound
- Los 4 artefactos OpenSpec (proposal, specs, design, tasks)
- Los 8 agentes y 15 skills (excepto correcciones de referencias)
- Los 3 roles (planner, implementer, reviewer)
- TDD como metodología
- BCP como protocolo de corrección
- Compound Engineering como filosofía
- Context Activation Model (Fowler taxonomy)
- Capability Providers y model-agnostic design

---

## FASE 7: Best Practices de la Industria — Pendientes de Incorporar

**Objetivo**: Incorporar las recomendaciones del paso 3 (03-best-practices.md) que no fueron cubiertas en F1-F6.
**Prioridad**: P1 — ALTO (el paso 3 de investigación era clave para el usuario)
**Origen**: `plans/improvement-v2/03-best-practices.md` — 25 fuentes, 2025-2026
**Estado**: PENDIENTE

---

### Trazabilidad: Best Practices → Plan

Cada hallazgo del documento de best practices mapeado a una acción concreta:

| # | Recomendación (03-best-practices.md) | Sección origen | Cubierta en F1-F6 | Acción FASE 7 |
|---|--------------------------------------|----------------|-------------------|---------------|
| 1 | Reflection Pattern en Quality Gates | §4 Reflection | ✅ F5.4, F5.5 | — |
| 2 | Test Contract Sketch en Phase 2 | §1 SDD | ✅ F6.1 | — |
| 3 | Reducir CLAUDE.md a < 200 líneas | §3 Context Eng. | ❌ | **F7.1** |
| 4 | Feedback loop REVIEW → PLAN | §2 Multi-agent | ✅ F6.3 | — |
| 5 | Security analysis en Phase 3 | §1 SDD | ✅ F6.2 | — |
| 6 | Reducir archivos grandes | §3 Context Eng. | ✅ F3.4-F3.7 | — |
| 7 | Plan-and-Execute (modelo grande planifica, pequeño ejecuta) | §2 Multi-agent | ❌ | **F7.2** |
| 8 | Chunking de outputs | §1 SDD (Osmani) | ✅ F6.5 | — |
| 9 | HITL progresivo (human-on-the-loop para bajo riesgo) | §2 Multi-agent | ⚠️ Parcial (F4.5 solo checkpoints) | **F7.3** |
| 10 | Métricas de context usage por sesión | §3 Context Eng. | ❌ | **F7.4** |
| 11 | Generator-Evaluator pattern (loop iterativo) | §2 Multi-agent | ❌ | **F7.5** |
| 12 | Scratchpad enforcement per-feature | §3 Context Eng. | ❌ (template existe, no se enforce) | **F7.6** |
| 13 | Progressive disclosure en skills | §5 Ecosistema | ⚠️ Parcial (frontmatter existe) | **F7.7** |
| 14 | Writer/Reviewer pattern (sesiones separadas) | §5 Ecosistema | ❌ | **F7.8** |
| 15 | Human-on-the-loop reemplaza human-in-the-loop (bajo riesgo) | §2 Tendencias 2026 | ❌ | Incluido en **F7.3** |
| 16 | Cost optimization de agentes como first-class concern | §2 Tendencias 2026 | ❌ | **F7.9** |
| 17 | Scratchpad real + persistencia externa (no forzar al modelo a recordar) | §3 Context Eng. | ⚠️ scratchpad.md template existe | Incluido en **F7.6** |
| 18 | Comparison con GitHub Spec Kit (clarify workaround) | §1 SDD | ❌ (no action needed, informational) | — |
| 19 | Comparison con AWS Kiro (formal specs en IDE) | §1 SDD | ❌ (informational) | — |
| 20 | A2A/ACP protocolos emergentes | §2 Protocolos | ❌ (future-looking) | **F7.10** |

**Resumen**: 10 subfases nuevas en FASE 7. 8 ya cubiertas. 2 informacionales (no accionables).

---

### F7.1 — Reducir CLAUDE.md a < 200 líneas

- **Fuente**: §3 Context Engineering — HumanLayer, Anthropic docs
- **Qué**: CLAUDE.md tiene ~300 líneas. Recomendación industria: < 200 líneas. "Para cada línea, pregunta: ¿eliminarla causaría errores?"
- **Acción**:
  1. Auditar cada sección de CLAUDE.md con el test "¿eliminarla causa errores?"
  2. Mover tablas detalladas (Agents, Skills, Context Activation Model) a `core/docs/REFERENCE_TABLES.md`
  3. En CLAUDE.md dejar solo: flow diagram, core commands (1 línea cada uno), key patterns (bullets), state management (1 párrafo), link a reference docs
  4. Verificar que el plugin sigue funcionando con el CLAUDE.md reducido
- **Archivos**: `CLAUDE.md`, `core/docs/REFERENCE_TABLES.md` (NUEVO)
- **Tamaño**: ~100 líneas eliminadas de CLAUDE.md
- **Métrica**: CLAUDE.md < 200 líneas

### F7.2 — Documentar patrón Plan-and-Execute en providers.yaml

- **Fuente**: §2 Multi-agent — Google ADK, UiPath
- **Qué**: Actualmente todo usa el mismo modelo. El patrón Plan-and-Execute sugiere: modelo grande planifica, modelo pequeño ejecuta tareas repetitivas
- **Acción**:
  1. Añadir sección en `core/docs/CAPABILITY_PROVIDERS.md`: "Plan-and-Execute Pattern"
  2. Documentar cuándo aplicar: planning phases → modelo grande (opus/sonnet); implementación mecánica → modelo rápido (haiku)
  3. Añadir campo opcional `execution_model` en providers.yaml para permitir override
  4. **NO cambiar el comportamiento por defecto** — solo documentar la opción
- **Archivos**: `core/docs/CAPABILITY_PROVIDERS.md`, `core/providers.yaml`
- **Tamaño**: ~20 líneas añadidas
- **Nota**: Solo documentación. La implementación real depende del SDK del usuario

### F7.3 — Implementar HITL progresivo (risk-based)

- **Fuente**: §2 Multi-agent — Deloitte, Leanware; Tendencias 2026
- **Qué**: F4.5 añadió checkpoints fijos entre fases. Pero la industria recomienda HITL variable según riesgo:
  - **Bajo riesgo** (refactoring, docs): human-on-the-loop (notificar, no bloquear)
  - **Medio riesgo** (nuevas features): human-in-the-loop (checkpoint entre fases clave)
  - **Alto riesgo** (security, DB, API pública): human-in-the-loop estricto (aprobación por paso)
- **Acción**:
  1. Añadir tabla de "Risk Tiers" en `framework_rules.md` §HITL (o crear nueva sección)
  2. En route.md: clasificar el risk tier durante routing
  3. En plan.md, work.md: adaptar checkpoints según risk tier asignado en routing
  4. Documentar que low-risk puede auto-avanzar, high-risk requiere aprobación explícita
- **Archivos**: `core/rules/framework_rules.md`, `commands/workflows/route.md`, `commands/workflows/plan.md`, `commands/workflows/work.md`
- **Tamaño**: ~40 líneas añadidas (distribuidas)

### F7.4 — Añadir métricas de context usage

- **Fuente**: §3 Context Engineering — Anthropic
- **Qué**: No hay visibilidad de cuánto contexto consume cada fase/skill/agent
- **Acción**:
  1. Añadir en `core/docs/CONTEXT_ENGINEERING.md` sección "Context Budget Tracking"
  2. Definir budget estimado por fase: Route (~2K tokens), Plan (~15K), Work (~20K), Review (~10K), Compound (~5K)
  3. Añadir instrucción en work.md: "Al inicio de cada task, registrar en scratchpad.md: `Context: ~{X}K tokens estimated`"
  4. Añadir en compound.md: "Registrar context usage total del feature en retrospective"
- **Archivos**: `core/docs/CONTEXT_ENGINEERING.md`, `commands/workflows/work.md`, `commands/workflows/compound.md`
- **Tamaño**: ~25 líneas añadidas

### F7.5 — Documentar Generator-Evaluator pattern

- **Fuente**: §2 Multi-agent — SitePoint, patrones agentic 2026
- **Qué**: BCP es correctivo (arregla errores). Generator-Evaluator es proactivo (genera → evalúa → mejora antes de entregar). Es complementario al Reflection Pattern (F5.4) pero más estructurado
- **Acción**:
  1. Añadir en `core/docs/CAPABILITY_PROVIDERS.md` sección "Generator-Evaluator Pattern"
  2. Documentar aplicación: work.md genera código → antes de commit, evalúa contra acceptance criteria → si gaps, genera versión mejorada → máximo 2 iteraciones
  3. Diferenciar de BCP: BCP = corregir errores post-test. G-E = mejorar calidad pre-test
  4. En work.md: añadir referencia al pattern como paso opcional antes de TDD cycle
- **Archivos**: `core/docs/CAPABILITY_PROVIDERS.md`, `commands/workflows/work.md`
- **Tamaño**: ~25 líneas añadidas

### F7.6 — Enforcer scratchpad per-feature

- **Fuente**: §3 Context Engineering — Anthropic (persistencia externa)
- **Qué**: El template `scratchpad.md` existe pero no se enforce su uso. La industria dice: "no forzar al modelo a recordar todo — externalizar a archivos"
- **Acción**:
  1. En route.md: al crear tasks.md, también crear `scratchpad.md` desde template
  2. En work.md: hacer obligatorio escribir hipótesis y notas en scratchpad.md (no en conversación)
  3. En plan.md: escribir assumptions no validadas en scratchpad.md
  4. Añadir en framework_rules.md: "Scratchpad is MANDATORY for features with >3 tasks"
- **Archivos**: `commands/workflows/route.md`, `commands/workflows/work.md`, `commands/workflows/plan.md`, `core/rules/framework_rules.md`
- **Tamaño**: ~20 líneas añadidas

### F7.7 — Mejorar progressive disclosure en skills

- **Fuente**: §5 Ecosistema — Anthropic, tendencias 2026
- **Qué**: Skills tienen frontmatter pero no hay "discovery" — el usuario debe saber que existen. La industria recomienda skills como "knowledge packs" descubribles
- **Acción**:
  1. Añadir en `commands/workflows/help.md` sección "Available Skills by Category" con descripción de 1 línea cada uno
  2. En route.md: al clasificar, sugerir skills relevantes (ej: "esta feature podría beneficiarse de `solid-analyzer`")
  3. Verificar que todos los skills tienen frontmatter consistente: `name`, `description`, `context`, `triggers`
- **Archivos**: `commands/workflows/help.md`, `commands/workflows/route.md`, skills/*.md (verificar frontmatter)
- **Tamaño**: ~30 líneas añadidas

### F7.8 — Documentar Writer/Reviewer pattern (sesiones separadas)

- **Fuente**: §5 Ecosistema — Tendencias 2026
- **Qué**: El pattern Writer/Reviewer usa sesiones separadas para que el reviewer tenga contexto fresco (no contaminado por las decisiones del writer)
- **Acción**:
  1. Documentar en `core/docs/CONTEXT_ENGINEERING.md` sección "Writer/Reviewer Isolation"
  2. Recomendar: para features críticas, ejecutar `/workflows:review` en sesión nueva (no continuación de work)
  3. Documentar cómo el reviewer recupera contexto: lee tasks.md + specs.md + git diff (no conversación previa)
  4. **NO hacer obligatorio** — solo documentar como best practice para features high-risk
- **Archivos**: `core/docs/CONTEXT_ENGINEERING.md`, `commands/workflows/review.md`
- **Tamaño**: ~15 líneas añadidas

### F7.9 — Añadir cost-awareness como concern de primera clase

- **Fuente**: §2 Multi-agent — Tendencias 2026 (cost optimization de agentes como cloud cost)
- **Qué**: No hay visibilidad del "costo" de usar el plugin (tokens, calls, etc.)
- **Acción**:
  1. Añadir en `core/docs/CONTEXT_ENGINEERING.md` sección "Cost Awareness"
  2. Documentar: fork agents consumen tokens adicionales; cada MCP tool description consume tokens idle; compaction agresiva ayuda en sesiones largas
  3. Añadir recomendación en CLAUDE.md (1 línea): "Disable unused MCP servers to reduce idle token cost"
  4. En compound.md retrospective: registrar si el feature tuvo problemas de context/cost
- **Archivos**: `core/docs/CONTEXT_ENGINEERING.md`, `CLAUDE.md`, `commands/workflows/compound.md`
- **Tamaño**: ~20 líneas añadidas

### F7.10 — Documentar protocolos emergentes (A2A, ACP) como future-ready

- **Fuente**: §2 Protocolos — Google A2A, IBM ACP
- **Qué**: MCP ya está soportado. A2A (Google, peer-to-peer entre agentes) y ACP (IBM, governance) son emergentes en 2026
- **Acción**:
  1. Añadir en `core/docs/MCP_INTEGRATION.md` sección "Emerging Protocols (2026)"
  2. Documentar A2A y ACP: qué son, cuándo serían relevantes, qué cambiaría en el plugin
  3. **NO implementar** — solo documentar para estar "future-ready"
- **Archivos**: `core/docs/MCP_INTEGRATION.md`
- **Tamaño**: ~15 líneas añadidas

---

### F7.11 — Verificación final de FASE 7

- **Qué**: Verificar que todas las best practices están mapeadas y documentadas
- **Acción**: Cross-check 03-best-practices.md vs plan. Confirmar 0 recomendaciones huérfanas
- **Archivos**: ninguno (solo verificación)

---

## Dependencias entre Fases (actualizado)

```
Fase 1 (refs rotas) ──→ Fase 3 (reducción contexto, especialmente F3.5)
Fase 2 (tasks.md)   ──→ Fase 4 (routing necesita saber formato de tasks.md)
Fase 3 (reducción)  ──→ Fase 5 (añadir reflection a plan.md ya simplificado)
Fase 5 (SOLID)      ──→ Fase 6 (test contracts + security necesitan SOLID resuelto)
Fase 3 (reducción)  ──→ Fase 7.1 (CLAUDE.md ya reducido en F3, ahora target < 200)
Fase 4 (HITL)       ──→ Fase 7.3 (HITL progresivo extiende F4.5)
Fase 5 (reflection) ──→ Fase 7.5 (Generator-Evaluator complementa reflection)
Fase 6 (funcional)  ──→ Fase 7.6 (scratchpad enforcement usa route.md ya actualizado)

Orden: F1 → F2 → F3 → F4 → F5 → F6 → F7
        ✅    ✅    ✅    ✅    ✅    ✅   PENDIENTE

Dentro de F7, independientes entre sí (pueden ejecutarse en cualquier orden):
  F7.1 ← depende de F3 (✅ done)
  F7.2 ← independiente
  F7.3 ← depende de F4 (✅ done)
  F7.4 ← independiente
  F7.5 ← depende de F5 (✅ done)
  F7.6 ← depende de F6 (✅ done)
  F7.7 ← independiente
  F7.8 ← independiente
  F7.9 ← independiente
  F7.10 ← independiente
```

---

*Plan actualizado el 2026-03-05 con FASE 7 (best practices de la industria pendientes de incorporar).*
*Basado en análisis comprensivo del codebase y mejores prácticas de la industria 2025-2026.*
