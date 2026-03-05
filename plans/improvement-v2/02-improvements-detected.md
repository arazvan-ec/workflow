# Mejoras Detectadas — Análisis Fresh del Plugin v3.2.0

**Fecha**: 2026-03-05
**Base**: Análisis fresh desde cero del codebase actual (sin depender de planes previos)

---

## Resumen

Se identifican **23 mejoras** organizadas en 5 categorías, con 4 quick wins de alto impacto.

---

## Categoría 1: Bugs y Referencias Rotas

### BUG-01: Archivos referenciados en help.md que no existen
- **Severidad**: CRÍTICO
- **Archivo**: `commands/workflows/help.md` (líneas 70-72, 188)
- **Problema**: help.md referencia 3 archivos que no existen:
  - `QUICKSTART.md` — "Get started in 5 minutes"
  - `TUTORIAL.md` — "Full step-by-step example"
  - `GLOSSARY.md` — "Term definitions"
- **Impacto**: Usuarios que buscan ayuda no encuentran los recursos prometidos

### BUG-02: Versiones inconsistentes entre archivos
- **Severidad**: ALTO
- **Archivos**: `plugin.json`, `framework_rules.md`, `CONTEXT_ENGINEERING.md`, varios commands
- **Problema**: El plugin declara v3.2.0 en plugin.json pero:
  - `framework_rules.md` header dice "Framework Version: 3.0.0"
  - `CONTEXT_ENGINEERING.md` dice "Version: 3.0.0"
  - `route.md` dice version 1.2.0
  - `help.md` dice version 2.1.0
  - `discover.md` dice version 1.0.0
- **Impacto**: Confusión sobre qué versión se está usando

### BUG-03: DECISIONS.md referenciado pero nunca definido como artefacto
- **Severidad**: MEDIO
- **Archivos**: `planner.md` (5 refs), `work.md` (2 refs), `framework_rules.md` (2 refs), `git-rules.md` (1 ref)
- **Problema**: 10 referencias a `DECISIONS.md` como archivo donde documentar decisiones, pero:
  - No hay template para DECISIONS.md
  - No se crea en ningún workflow
  - El Decision Log en `tasks.md` cubre parcialmente esta necesidad
  - Ambiguo: ¿es DECISIONS.md o el Decision Log en tasks.md?
- **Impacto**: El planner no sabe dónde documentar decisiones

---

## Categoría 2: Redundancias

### RED-01: Flow Guards duplicados en 5 comandos
- **Severidad**: MEDIO
- **Archivos**: `plan.md`, `work.md`, `review.md`, `compound.md`, `shape.md`
- **Problema**: Cada comando implementa su propia sección de "PREREQUISITE CHECK" / "Flow Guard" con lógica similar (~30-40 líneas cada uno, ~150-200 líneas totales de redundancia)
- **Impacto**: Si cambias la lógica de prerequisites, hay que actualizar 5 archivos

### RED-02: Write-Then-Advance repetido
- **Severidad**: BAJO
- **Archivos**: `plan.md` (2 refs), `framework_rules.md` (2 refs), `shape.md` (1 ref)
- **Problema**: El principio Write-Then-Advance se define en framework_rules.md (371 líneas, sección §11) y luego se repite en plan.md y shape.md
- **Impacto**: Menor — son mayormente referencias cruzadas, no repetición completa

### RED-03: BCP descrito en múltiples lugares
- **Severidad**: BAJO
- **Archivos**: `testing-rules.md` (definición), `work.md`, `framework_rules.md`, `CAPABILITY_PROVIDERS.md`
- **Problema**: BCP tiene su definición canónica en testing-rules.md pero otros archivos repiten aspectos del protocolo
- **Impacto**: Bajo — la definición canónica es clara en testing-rules.md

---

## Categoría 3: Gaps Funcionales

### GAP-01: Sin Reflection Pattern real en Quality Gates
- **Severidad**: ALTO
- **Archivos**: `plan.md` (Quality Gates), `work.md` (checkpoints)
- **Problema**: Los Quality Gates verifican condiciones estáticas (archivo existe, secciones presentes) pero no incluyen auto-crítica real ("¿qué suposiciones hago?", "¿qué podría fallar?")
- **Impacto**: El agente avanza sin cuestionar la calidad de su propio output

### GAP-02: Sin Test Contract Sketch temprano
- **Severidad**: ALTO
- **Archivos**: `plan.md` (Phase 2)
- **Problema**: Los tests solo aparecen como "Tests to Write FIRST" en Phase 4 (tasks). No hay sketch de contratos de test durante las specs (Phase 2) para validar que los requisitos son testeables
- **Impacto**: Se descubre tarde que un spec es ambiguo o no testeable

### GAP-03: Sin Security Threat Analysis en diseño
- **Severidad**: MEDIO
- **Archivos**: `plan.md` (Phase 3)
- **Problema**: Phase 3 cubre SOLID exhaustivamente pero no incluye análisis de seguridad. El security-reviewer solo actúa en review (después de implementación)
- **Impacto**: Problemas de seguridad se detectan tarde (post-implementación)

### GAP-04: Sin rutas de error/recovery documentadas
- **Severidad**: MEDIO
- **Archivos**: todos los commands
- **Problema**: Los comandos documentan el happy path pero no qué hacer cuando algo falla:
  - ¿Qué pasa si tasks.md está corrupto?
  - ¿Qué pasa si el SOLID check falla después de 3 iteraciones?
  - ¿Qué pasa si el BCP agota sus iteraciones?
- **Impacto**: El agente se bloquea sin guía de recuperación
- **Nota**: `framework_rules.md` tiene un Rollback Protocol básico (§ final) pero los commands no lo referencian

### GAP-05: HITL limitado a inicio y final
- **Severidad**: MEDIO
- **Archivos**: `plan.md`, `framework_rules.md`
- **Problema**: framework_rules.md §1 define 5 HITL checkpoints, pero en la práctica:
  - Entre Phase 2 (specs) y Phase 3 (design) hay HITL ✓
  - Pero entre Phase 3 y Phase 4 no hay HITL explícito
  - Durante work, decisiones de alto riesgo (DB migrations, configs) no tienen HITL
- **Impacto**: El agente puede tomar decisiones costosas sin confirmación humana

### GAP-06: Feedback loop incompleto REVIEW → PLAN
- **Severidad**: MEDIO
- **Archivos**: `review.md`, `compound.md`
- **Problema**: Si el review encuentra problemas arquitectónicos (no solo de código), el flujo es REJECTED → vuelve a WORK. No hay path formal para retroalimentar problemas de diseño a PLAN
- **Impacto**: Se re-implementa con el mismo diseño defectuoso

### GAP-07: Chunking de outputs no guiado
- **Severidad**: BAJO
- **Archivos**: `plan.md`
- **Problema**: No hay directivas sobre tamaño máximo de outputs. Un agente puede generar un specs.md de 500 líneas de golpe, lo cual degrada calidad
- **Impacto**: Outputs monolíticos con mayor probabilidad de errores

### GAP-08: Sin métricas de uso de contexto
- **Severidad**: BAJO
- **Archivos**: `CONTEXT_ENGINEERING.md`
- **Problema**: No hay forma de saber cuánto contexto consume cada capa en una sesión real
- **Impacto**: Difícil optimizar el context budget

---

## Categoría 4: Mejoras UX

### UX-01: discover.md es demasiado largo (1,864 líneas)
- **Severidad**: MEDIO
- **Archivo**: `commands/workflows/discover.md`
- **Problema**: Es el archivo más largo del plugin. Para un comando de onboarding que se ejecuta una vez, 1,864 líneas es excesivo
- **Impacto**: Consume mucho context window cuando se carga

### UX-02: compound.md (1,073 líneas) podría ser más conciso
- **Severidad**: MEDIO
- **Archivo**: `commands/workflows/compound.md`
- **Problema**: compound es un paso automático post-review. 1,073 líneas para un paso que debería ser mayormente mecánico
- **Impacto**: Context window overhead

### UX-03: skills de SOLID (criteria-generator + solid-analyzer = 1,222 líneas)
- **Severidad**: BAJO
- **Archivos**: `workflow-skill-criteria-generator.md` (694), `workflow-skill-solid-analyzer.md` (528)
- **Problema**: Dos skills separados pero estrechamente acoplados. Juntos ocupan 1,222 líneas
- **Impacto**: Podrían consolidarse o referenciarse mutuamente para reducir redundancia

### UX-04: mcp-connector (509 líneas) para una integración opcional
- **Severidad**: BAJO
- **Archivo**: `skills/mcp-connector.md`
- **Problema**: 509 líneas para un skill de integración que muchos usuarios no usan
- **Impacto**: Bajo — solo se carga cuando se invoca (human-triggered)

---

## Categoría 5: Consistencia

### CON-01: DECISIONS.md vs Decision Log en tasks.md
- **Severidad**: ALTO
- **Problema**: Dos mecanismos para documentar decisiones:
  1. `DECISIONS.md` — referenciado 10 veces en planner.md, work.md, framework_rules.md, git-rules.md
  2. Decision Log en `tasks.md` — definido en tasks-template.md
- **Impacto**: El agente no sabe cuál usar

### CON-02: Terminología inconsistente para "snapshot" vs "checkpoint"
- **Severidad**: BAJO
- **Problema**: framework_rules.md define terminología canónica (§ Terminology) pero algunos archivos pueden no seguirla consistentemente
- **Impacto**: Menor — el glosario en framework_rules.md ya existe

### CON-03: SOLID enforcement ambiguo (¿bloqueante o advisory?)
- **Severidad**: MEDIO
- **Problema**: El tratamiento de SOLID varía por fase:
  - plan.md Phase 3: NON_COMPLIANT parece bloqueante
  - work.md: NEEDS_WORK "triggers refactor" (no bloqueante)
  - review.md: Verifica implementación vs diseño (no re-evalúa SOLID)
- **Impacto**: Comportamiento inconsistente entre fases

---

## Quick Wins (Alto Impacto, Bajo Esfuerzo)

| # | Mejora | Esfuerzo | Impacto |
|---|--------|----------|---------|
| 1 | **BUG-01**: Eliminar refs a QUICKSTART/TUTORIAL/GLOSSARY en help.md o crearlos | S | CRÍTICO |
| 2 | **BUG-02**: Unificar versiones a 3.2.0 en todos los headers | S | ALTO |
| 3 | **CON-01**: Decidir entre DECISIONS.md y Decision Log — eliminar el dual | M | ALTO |
| 4 | **GAP-02**: Añadir Test Contract Sketch como sub-paso en plan.md Phase 2 | M | ALTO |

---

## Distribución por Severidad

| Severidad | Cantidad |
|-----------|----------|
| CRÍTICO | 1 |
| ALTO | 6 |
| MEDIO | 9 |
| BAJO | 7 |
| **Total** | **23** |

---

*Análisis completado el 2026-03-05. Basado en lectura directa y grep exhaustivo del codebase.*
