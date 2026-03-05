# Task Tracker — Plan de Mejoras Plugin Workflow v3.2.0

**Última actualización**: 2026-03-05
**Plan**: `04-improvement-plan.md`
**Estado**: 🔄 EN PROGRESO — 39/50 subfases (F1-F6 DONE, F7 PENDIENTE)

---

## Estado General

| Fase | Descripción | Subfases | Estado | Progreso |
|------|-------------|----------|--------|----------|
| F1 | Bugs y Referencias Rotas | 7 | DONE | 7/7 |
| F2 | Estado de Workflow y Trazabilidad | 6 | DONE | 6/6 |
| F3 | Reducción de Contexto | 7 | DONE | 7/7 |
| F4 | Clarificación de Flujo y HITL | 6 | DONE | 6/6 |
| F5 | Coherencia y Calidad | 6 | DONE | 6/6 |
| F6 | Mejoras Funcionales | 7 | DONE | 7/7 |
| **F7** | **Best Practices Industria (03-best-practices.md)** | **11** | **PENDING** | **0/11** |

**Total**: 50 subfases | **Completadas**: 39/50 | **Pendientes**: 11 (FASE 7)

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
| F4.1 | Añadir diagrama de decisión en route.md | route.md | DONE | 2d024d5 |
| F4.2 | Eliminar ejecución sin routing en plan.md | plan.md | DONE | 2d024d5 |
| F4.3 | Definir re-entrada de quick a plan | quick.md | DONE | 2d024d5 |
| F4.4 | Clarificar discover como onboarding | discover.md | DONE | 2d024d5 |
| F4.5 | Añadir HITL checkpoints entre fases de plan | plan.md | DONE | 2d024d5 |
| F4.6 | Actualizar help.md con flujo de decisión | help.md | DONE | 2d024d5 |

---

## FASE 5: Coherencia y Calidad

| ID | Subfase | Archivos | Estado | Commit |
|----|---------|----------|--------|--------|
| F5.1 | Definir SOLID Verdict Matrix | architecture-reference.md | DONE | (ya existía) |
| F5.2 | Referenciar Verdict Matrix desde plan/work/review | work.md, review.md | DONE | 381d3b7 |
| F5.3 | Cambiar SOLID de auto-scoring a justificación | architecture-reference.md | DONE | (ya existía) |
| F5.4 | Implementar Reflection Pattern en Quality Gates | plan.md | DONE | (ya existía) |
| F5.5 | Implementar Reflection en work.md y review.md | review.md | DONE | 381d3b7 |
| F5.6 | Estandarizar terminología | implementer.md, CAPABILITY_PROVIDERS.md, framework_rules.md | DONE | 381d3b7 |

---

## FASE 6: Mejoras Funcionales

| ID | Subfase | Archivos | Estado | Commit |
|----|---------|----------|--------|--------|
| F6.1 | Añadir Test Contract Sketch en Phase 2 | plan.md | DONE | (ya existía Phase 2.5) |
| F6.2 | Añadir Security Threat Analysis en Phase 3 | plan.md | DONE | (ya existía Phase 3.5) |
| F6.3 | Implementar Feedback Loop REVIEW → PLAN | plan.md | DONE | 5998720 |
| F6.4 | Documentar rutas de error en cada comando | 6 comandos | DONE | (ya existía en 6/6) |
| F6.5 | Añadir chunking de outputs | plan.md | DONE | (ya existía) |
| F6.6 | Añadir Retrospective en compound | compound.md, plan.md | DONE | (ya existía) |
| F6.7 | Verificación final del plan completo | — | DONE | 5998720 |

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
| 11 | 277618b | F3.6 | Reduce discover.md de 1864 a 1175 líneas (-37%) | 2026-03-05 |
| 12 | e2722cd | F3.7 | Reduce compound.md de 1063 a 267 líneas (-75%) | 2026-03-05 |
| 13 | a7bef1a | — | update tasks tracker F1-F3 complete | 2026-03-05 |
| 14 | 2d024d5 | F4.1-F4.6 | Clarificación de flujo y HITL | 2026-03-05 |
| 15 | 381d3b7 | F5.1-F5.6 | Coherencia y calidad | 2026-03-05 |
| 16 | 5998720 | F6.1-F6.7 | Mejoras funcionales | 2026-03-05 |

---

## Métricas Finales

| Métrica | Antes | Después | Cambio |
|---------|-------|---------|--------|
| Referencias rotas | 10+ | 0 | -100% |
| Versiones inconsistentes | 5 | 0 (todas 3.2.0) | -100% |
| DECISIONS.md vs Decision Log | 2 mecanismos | 1 | consolidado |
| plan.md | ~1365 líneas | 889 líneas | -35% |
| compound.md | 1063 líneas | 267 líneas | -75% |
| discover.md | 1864 líneas | 1177 líneas | -37% |
| Total core commands | ~7500 líneas | 5442 líneas | -27% |

---

## FASE 7: Best Practices de la Industria (03-best-practices.md)

| ID | Subfase | Fuente (sección best practices) | Archivos | Estado | Commit |
|----|---------|--------------------------------|----------|--------|--------|
| F7.1 | Reducir CLAUDE.md a < 200 líneas | §3 Context Engineering | CLAUDE.md, REFERENCE_TABLES.md (NUEVO) | PENDING | — |
| F7.2 | Documentar Plan-and-Execute pattern | §2 Multi-agent (Google ADK) | CAPABILITY_PROVIDERS.md, providers.yaml | PENDING | — |
| F7.3 | HITL progresivo (risk-based) | §2 Multi-agent (Deloitte) | framework_rules.md, route.md, plan.md, work.md | PENDING | — |
| F7.4 | Métricas de context usage | §3 Context Engineering (Anthropic) | CONTEXT_ENGINEERING.md, work.md, compound.md | PENDING | — |
| F7.5 | Generator-Evaluator pattern | §2 Multi-agent (SitePoint) | CAPABILITY_PROVIDERS.md, work.md | PENDING | — |
| F7.6 | Enforcer scratchpad per-feature | §3 Context Engineering (Anthropic) | route.md, work.md, plan.md, framework_rules.md | PENDING | — |
| F7.7 | Progressive disclosure en skills | §5 Ecosistema (Anthropic) | help.md, route.md, skills/*.md | PENDING | — |
| F7.8 | Writer/Reviewer pattern (sesiones separadas) | §5 Ecosistema | CONTEXT_ENGINEERING.md, review.md | PENDING | — |
| F7.9 | Cost-awareness como first-class concern | §2 Tendencias 2026 | CONTEXT_ENGINEERING.md, CLAUDE.md, compound.md | PENDING | — |
| F7.10 | Protocolos emergentes (A2A, ACP) future-ready | §2 Protocolos | MCP_INTEGRATION.md | PENDING | — |
| F7.11 | Verificación final FASE 7 | — | — | PENDING | — |

---

## Trazabilidad: Best Practices → Plan

> Ver tabla completa en `04-improvement-plan.md` sección "Trazabilidad: Best Practices → Plan"
>
> Resumen: 20 hallazgos totales → 8 ya cubiertos (F1-F6) + 10 nuevos (F7) + 2 informacionales

---

*Tracker actualizado el 2026-03-05. FASE 7 añadida — best practices de la industria pendientes de ejecutar.*
