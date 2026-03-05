# Task Tracker — Plan de Mejoras Plugin Workflow v3.2.0

**Última actualización**: 2026-03-05
**Plan**: `04-improvement-plan.md`

---

## Estado General

| Fase | Descripción | Subfases | Estado | Progreso |
|------|-------------|----------|--------|----------|
| F1 | Bugs y Referencias Rotas | 7 | DONE | 7/7 |
| F2 | Estado de Workflow y Trazabilidad | 6 | DONE | 6/6 |
| F3 | Reducción de Contexto | 7 | DONE | 7/7 |
| F4 | Clarificación de Flujo y HITL | 6 | PENDING | 0/6 |
| F5 | Coherencia y Calidad | 6 | PENDING | 0/6 |
| F6 | Mejoras Funcionales | 7 | PENDING | 0/7 |

**Total**: 39 subfases | **Completadas**: 20/39

---

## FASE 1: Bugs y Referencias Rotas

| ID | Subfase | Archivos | Estado | Commit |
|----|---------|----------|--------|--------|
| F1.1 | Eliminar refs QUICKSTART/TUTORIAL/GLOSSARY en help.md | help.md | DONE | c635f30 |
| F1.2 | Unificar versiones a 3.2.0 | framework_rules.md, CONTEXT_ENGINEERING.md, route.md, help.md, discover.md +6 | DONE | 9b55039 |
| F1.3 | Resolver DECISIONS.md → Decision Log en tasks.md | planner.md, work.md, framework_rules.md, git-rules.md | DONE | 8dc87e9 |
| F1.4 | Eliminar refs snapshot/restore en SESSION_CONTINUITY.md | SESSION_CONTINUITY.md | DONE | (ya limpio) |
| F1.5 | Eliminar refs /workflows:parallel en CAPABILITY_PROVIDERS.md | CAPABILITY_PROVIDERS.md | DONE | (no existían) |
| F1.6 | Corregir refs rotas en compound/work/plan/discover | compound.md, work.md, plan.md, discover.md | DONE | be17ad3 |
| F1.7 | Verificación final Fase 1 (grep) | — | DONE | (verificado) |

---

## FASE 2: Estado de Workflow y Trazabilidad

| ID | Subfase | Archivos | Estado | Commit |
|----|---------|----------|--------|--------|
| F2.1 | Crear template canónico de tasks.md | core/templates/tasks-template.md (NUEVO) | DONE | a581621 |
| F2.2 | Actualizar route.md para crear tasks.md inicial | route.md | DONE | 224d48e |
| F2.3 | Actualizar plan.md para formato canónico | plan.md | DONE | 2941271 |
| F2.4 | Actualizar work.md para formato canónico | work.md | DONE | 2941271 |
| F2.5 | Actualizar review.md para QA Summary | review.md | DONE | 2941271 |
| F2.6 | Actualizar compound.md para Phase Status final | compound.md | DONE | 2941271 |

---

## FASE 3: Reducción de Contexto

| ID | Subfase | Archivos | Estado | Commit |
|----|---------|----------|--------|--------|
| F3.1 | Simplificar Flow Guards en 5 comandos | plan.md, work.md, review.md, compound.md, shape.md | DONE | 39bb3d2 |
| F3.2 | Reducir repeticiones de BCP | work.md | DONE | af88af4 |
| F3.3 | Reducir Write-Then-Advance repetido | plan.md, shape.md | DONE | (ya mínimo) |
| F3.4 | Reducir ejemplos excesivos en plan.md | plan.md | DONE | 2538848 |
| F3.5 | Simplificar SESSION_CONTINUITY.md | SESSION_CONTINUITY.md | DONE | (ya 174 líneas) |
| F3.6 | Reducir discover.md | discover.md | DONE | 277618b |
| F3.7 | Reducir compound.md | compound.md | DONE | e2722cd |

---

## FASE 4: Clarificación de Flujo y HITL

| ID | Subfase | Archivos | Estado | Commit |
|----|---------|----------|--------|--------|
| F4.1 | Añadir diagrama de decisión en route.md | route.md | PENDING | — |
| F4.2 | Eliminar ejecución sin routing en plan.md | plan.md | PENDING | — |
| F4.3 | Definir re-entrada de quick a plan | quick.md | PENDING | — |
| F4.4 | Clarificar discover como onboarding | discover.md | PENDING | — |
| F4.5 | Añadir HITL checkpoints entre fases de plan | plan.md | PENDING | — |
| F4.6 | Actualizar help.md con flujo de decisión | help.md | PENDING | — |

---

## FASE 5: Coherencia y Calidad

| ID | Subfase | Archivos | Estado | Commit |
|----|---------|----------|--------|--------|
| F5.1 | Definir SOLID Verdict Matrix | architecture-reference.md | PENDING | — |
| F5.2 | Referenciar Verdict Matrix desde plan/work/review | plan.md, work.md, review.md | PENDING | — |
| F5.3 | Cambiar SOLID de auto-scoring a justificación | architecture-reference.md | PENDING | — |
| F5.4 | Implementar Reflection Pattern en Quality Gates | plan.md | PENDING | — |
| F5.5 | Implementar Reflection en work.md y review.md | work.md, review.md | PENDING | — |
| F5.6 | Estandarizar terminología | búsqueda global | PENDING | — |

---

## FASE 6: Mejoras Funcionales

| ID | Subfase | Archivos | Estado | Commit |
|----|---------|----------|--------|--------|
| F6.1 | Añadir Test Contract Sketch en Phase 2 | plan.md | PENDING | — |
| F6.2 | Añadir Security Threat Analysis en Phase 3 | plan.md | PENDING | — |
| F6.3 | Implementar Feedback Loop REVIEW → PLAN | review.md, plan.md | PENDING | — |
| F6.4 | Documentar rutas de error en cada comando | route.md, plan.md, work.md, review.md, compound.md, quick.md | PENDING | — |
| F6.5 | Añadir chunking de outputs | plan.md | PENDING | — |
| F6.6 | Añadir Retrospective en compound | compound.md, plan.md | PENDING | — |
| F6.7 | Verificación final del plan completo | — | PENDING | — |

---

## Registro de Commits

| # | Commit Hash | Subfase(s) | Mensaje | Fecha |
|---|-------------|------------|---------|-------|
| 1 | c635f30 | F1.1 | remove refs to nonexistent QUICKSTART/TUTORIAL/GLOSSARY | 2026-03-05 |
| 2 | 9b55039 | F1.2 | unify all version headers to 3.2.0 | 2026-03-05 |
| 3 | 8dc87e9 | F1.3 | consolidate DECISIONS.md refs to Decision Log in tasks.md | 2026-03-05 |
| 4 | be17ad3 | F1.6 | remove deprecated /workflows:quickstart reference | 2026-03-05 |
| 5 | a581621 | F2.1 | create canonical tasks.md template | 2026-03-05 |
| 6 | 224d48e | F2.2 | route.md creates initial tasks.md from template | 2026-03-05 |
| 7 | 2941271 | F2.3-F2.6 | reference canonical tasks-template in work/review/compound | 2026-03-05 |
| 8 | 39bb3d2 | F3.1 | simplify Flow Guards in 5 commands | 2026-03-05 |
| 9 | af88af4 | F3.2 | reduce BCP repetition in work.md | 2026-03-05 |
| 10 | 2538848 | F3.4 | reduce plan.md from 1109 to 869 lines (-22%) | 2026-03-05 |
| 11 | 277618b | F3.6 | Reduce discover.md de 1864 a 1175 líneas | 2026-03-05 |
| 12 | e2722cd | F3.7 | Reduce compound.md de 1063 a 267 líneas | 2026-03-05 |

---

*Tracker actualizado el 2026-03-05. Actualizar después de cada commit.*
