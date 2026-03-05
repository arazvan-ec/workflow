# Análisis Detallado del Plugin Workflow v3.2.0

**Fecha**: 2026-03-05
**Objetivo**: Documentar todo lo que hace el plugin con gran detalle, desde cero.

---

## 1. Visión General

El plugin Multi-Agent Workflow es un framework de **compound engineering** que coordina múltiples agentes IA para desarrollo de software. Es 100% stack-agnostic y model-agnostic.

### Datos del Plugin
- **Versión**: 3.2.0
- **Licencia**: MIT
- **Autor**: arazvan-ec
- **Ubicación**: `plugins/workflow/`
- **Líneas totales**: ~21,078 (commands: 6,810 + skills: 4,977 + agents/roles/rules/docs: 6,256 + templates: 3,035)

### Filosofía Central
- **Compound Engineering**: Cada feature completada enseña al sistema patrones que informan la siguiente
- **Spec-Driven Development (SDD)**: Cada feature produce artefactos markdown estructurados
- **80/20**: 80% planificación, 20% ejecución
- **Karpathy Principles**: Think before coding, simplicity first, surgical changes, goal-driven execution
- **Context Engineering**: Carga selectiva de contexto basada en el modelo de Fowler

---

## 2. Inventario Completo de Archivos

### 2.1 Comandos de Workflow (10 archivos — 6,810 líneas)

| Archivo | Líneas | Propósito | Tier |
|---------|--------|-----------|------|
| `commands/workflows/route.md` | 589 | Punto de entrada obligatorio. Clasifica requests, asigna workflow | Tier 1 (Core) |
| `commands/workflows/quick.md` | 210 | Path ligero para tareas simples (≤3 archivos) | Tier 1 (Core) |
| `commands/workflows/shape.md` | 391 | Separa problema de solución (Shape Up), spike unknowns | Tier 1 (Core) |
| `commands/workflows/plan.md` | 1,130 | Planificación en 4 fases: Understand → Specs → Design → Tasks | Tier 1 (Core) |
| `commands/workflows/work.md` | 777 | Ejecución con TDD + Bounded Correction Protocol | Tier 1 (Core) |
| `commands/workflows/review.md` | 436 | Review multi-agente (code, architecture, security, performance) | Tier 1 (Core) |
| `commands/workflows/compound.md` | 1,073 | Captura learnings, actualiza profile, merge specs a baseline | Tier 1 (Core) |
| `commands/workflows/discover.md` | 1,864 | Onboarding: analiza codebase, genera architecture-profile | Tier 2 (Support) |
| `commands/workflows/status.md` | 119 | Muestra progreso de todos los roles | Tier 2 (Support) |
| `commands/workflows/help.md` | 221 | Referencia rápida de comandos y guía | Tier 2 (Support) |

### 2.2 Agentes (8 archivos — 1,747 líneas)

| Agente | Líneas | Categoría | Propósito | Invocado por |
|--------|--------|-----------|-----------|-------------|
| `agents/research/codebase-analyzer.md` | 254 | Research | Análisis profundo del codebase existente | `plan` (Phase 1), `route` |
| `agents/research/learnings-researcher.md` | 182 | Research | Investiga patrones aprendidos y compound-memory | `plan` (Step 0), `work` |
| `agents/review/code-reviewer.md` | 266 | Review | Revisión de calidad de código | `review` |
| `agents/review/architecture-reviewer.md` | 338 | Review | Revisión de diseño arquitectónico y SOLID | `review` |
| `agents/review/security-reviewer.md` | 141 | Review | Análisis de vulnerabilidades y seguridad | `review` |
| `agents/review/performance-reviewer.md` | 165 | Review | Análisis de rendimiento y bottlenecks | `review` |
| `agents/workflow/diagnostic-agent.md` | 238 | Workflow | Diagnóstico tras 3 errores consecutivos (BCP escalation) | `work` (BCP) |
| `agents/workflow/spec-analyzer.md` | 163 | Workflow | Analiza specs para consistencia y completitud | `review` |

### 2.3 Roles (3 archivos — 275 líneas)

| Rol | Líneas | Propósito | Activo durante |
|-----|--------|-----------|----------------|
| `core/roles/planner.md` | 81 | Define permisos y contexto del planificador | `plan` |
| `core/roles/implementer.md` | 102 | Define permisos y contexto del implementador | `work` |
| `core/roles/reviewer.md` | 92 | Define permisos y contexto del revisor | `review` |

### 2.4 Skills (16 archivos — 4,977 líneas)

| Skill | Líneas | Categoría | Propósito | Context |
|-------|--------|-----------|-----------|---------|
| `skills/checkpoint/SKILL.md` | 181 | Core | Quality gates con auto-correction, BCP, verificación goal-backward | fork |
| `skills/git-sync/SKILL.md` | 84 | Core | Sincronización de repos con stash/conflict handling | inline |
| `skills/commit-formatter/SKILL.md` | 204 | Core | Conventional commits (feat/fix/docs/etc.) | inline |
| `skills/test-runner/SKILL.md` | 182 | Quality | Ejecuta PHPUnit/Jest/Cypress, TDD Red-Green-Refactor | inline |
| `skills/coverage-checker/SKILL.md` | 155 | Quality | Valida cobertura (80% backend, 70% frontend) | fork |
| `skills/lint-fixer/SKILL.md` | 199 | Quality | Auto-fix PHP CS Fixer, ESLint, Prettier | inline |
| `skills/consultant/SKILL.md` | 414 | Research | Análisis profundo de proyecto en 7 capas | fork |
| `skills/validation-learning-log/SKILL.md` | 261 | Compound | Q&A persistente que evita preguntas repetidas | inline |
| `skills/source-report/SKILL.md` | 135 | Research | Audita fuentes/referencias en planes, clasifica credibilidad | fork |
| `skills/spec-merger/SKILL.md` | 566 | Compound | Merge feature specs a baseline (ADD/MODIFY/CONFLICT/SKIP) | fork |
| `skills/policy-gate/SKILL.md` | 200 | Governance | Evalúa cambios contra contract.json, calcula risk tier | inline |
| `skills/shaper/SKILL.md` | 378 | Shaping | Shape Up: requisitos (R) vs shapes (A/B/C), fit checks | fork |
| `skills/breadboarder/SKILL.md` | 287 | Shaping | Affordance tables, Mermaid diagrams, vertical slices | fork |
| `skills/mcp-connector.md` | 509 | Integration | Conecta a MCP servers con validación y RBAC | fork |
| `skills/workflow-skill-criteria-generator.md` | 694 | SOLID | Genera criteria de decisión arquitectónica (SOLID + feature-specific) | fork |
| `skills/workflow-skill-solid-analyzer.md` | 528 | SOLID | Análisis SOLID contextual en 3 modos: baseline, design, verify | fork |

### 2.5 Reglas (4 archivos — 580 líneas)

| Archivo | Líneas | Alcance | Activación |
|---------|--------|---------|-----------|
| `core/rules/framework_rules.md` | 371 | Reglas fundamentales del framework | Siempre cargado |
| `core/rules/testing-rules.md` | 101 | TDD, cobertura, Bounded Correction Protocol | Cuando se editan archivos de test |
| `core/rules/security-rules.md` | 58 | Trust model, supervision, prohibiciones de seguridad | Cuando se editan paths de auth/security/payment |
| `core/rules/git-rules.md` | 50 | Branching, commits, conflict management | Cuando se ejecutan operaciones git |

### 2.6 Documentación (8 archivos — 2,546 líneas)

| Archivo | Líneas | Propósito | Activación |
|---------|--------|-----------|-----------|
| `core/docs/CAPABILITY_PROVIDERS.md` | 502 | Abstracción model-agnostic, detection protocol | LLM-determined |
| `core/docs/WORKFLOW_DECISION_MATRIX.md` | 344 | Matriz de decisión para selección de workflows | LLM-determined |
| `core/docs/KARPATHY_PRINCIPLES.md` | 328 | Principios para desarrollo asistido por IA con ejemplos | LLM-determined |
| `core/docs/VALIDATION_LEARNING.md` | 324 | Sistema closed-loop de Q&A persistente | LLM-determined |
| `core/docs/CONTEXT_ENGINEERING.md` | 313 | Estrategia de curación de contexto (Fowler) | LLM-determined |
| `core/docs/MCP_INTEGRATION.md` | 497 | Model Context Protocol: config, invocación, validación | LLM-determined |
| `core/docs/SESSION_CONTINUITY.md` | 173 | Patrones de persistencia y reanudación de sesiones | LLM-determined |
| `core/docs/ROUTING_REFERENCE.md` | 65 | Matriz de decisión y clasificaciones de routing | LLM-determined |

### 2.7 Templates (17 archivos — 3,035 líneas)

| Archivo | Líneas | Tipo | Usado por |
|---------|--------|------|-----------|
| `core/templates/routing-template.md` | 24 | Markdown | `route` |
| `core/templates/scratchpad-template.md` | 55 | Markdown | `plan`, `work` |
| `core/templates/tasks-template.md` | 71 | Markdown | `plan` (Phase 4) |
| `core/templates/constitution-template.md` | 87 | Markdown | `discover` |
| `core/templates/spec-template.md` | 246 | Markdown | `plan` (Phase 2+3) |
| `core/templates/project-profile-template.md` | 268 | Markdown | `discover`, `consultant` |
| `core/templates/clarification_prompts.md` | 393 | Markdown | `route`, `plan` |
| `core/templates/architecture-profile-template.yaml` | 148 | YAML | `discover` |
| `core/templates/entity_spec.yaml` | 185 | YAML | `plan`, `discover` |
| `core/templates/feature_spec.yaml` | 164 | YAML | `plan` |
| `core/templates/business_rule_spec.yaml` | 166 | YAML | `plan`, `discover` |
| `core/templates/api-architecture-diagnostic.yaml` | 172 | YAML | `plan` (Phase 3) |
| `core/templates/spec_manifest.yaml` | 233 | YAML | `compound`, `spec-merger` |
| `core/templates/api_contract.yaml` | 242 | YAML | `plan`, `discover` |
| `core/templates/api_contract_spec.yaml` | 318 | YAML | `plan`, `discover` |
| `core/templates/architectural_constraint_spec.yaml` | 263 | YAML | `plan` (Phase 3) |

### 2.8 Configuración y Governance

| Archivo | Líneas | Propósito |
|---------|--------|-----------|
| `core/providers.yaml` | 254 | Configuración de capability providers (parallelization, context, fork, coordination, execution, planning) |
| `core/architecture-reference.md` | 854 | Referencia SOLID completa con violation patterns, corrective patterns, y criteria base |
| `.claude-plugin/plugin.json` | 39 | Manifiesto del plugin (commands, agents, skills) |
| `control-plane/contract.json` | 75 | Governance: risk tiers, merge policy, docs drift rules |
| `CLAUDE.md` | ~300 | Instrucciones principales del plugin (always loaded) |

---

## 3. Flujo de Datos: ROUTE → SHAPE → PLAN → WORK → REVIEW → COMPOUND

### 3.1 ROUTE (`route.md` — 589 líneas)
**Entrada**: Request del usuario
**Proceso**:
1. Clasifica el request (tipo, complejidad, riesgo)
2. Genera preguntas de clarificación si confianza < 60%
3. Determina workflow: quick vs full, si requiere shape
4. Evalúa complejidad: simple / medium / complex
**Salida**: `openspec/changes/{slug}/00_routing.md`
**Lee**: codebase (via codebase-analyzer), compound-memory.md
**Invoca**: codebase-analyzer agent, learnings-researcher agent

### 3.2 SHAPE (`shape.md` — 391 líneas) [OPCIONAL]
**Entrada**: `00_routing.md`
**Proceso**:
1. Separa requisitos (R) de shapes (soluciones A/B/C)
2. Ejecuta spikes para unknowns
3. Valida fit check (scope vs appetite)
4. Genera vertical slices demoables
**Salida**: `01_shaped_brief.md`, `02_breadboard.md`, `03_slices.md`
**Lee**: `00_routing.md`, codebase existente
**Invoca**: shaper skill, breadboarder skill

### 3.3 PLAN (`plan.md` — 1,130 líneas)
**Entrada**: `00_routing.md` (o shaped brief si se hizo shape)
**Proceso** (4 fases):
- **Step 0**: Load compound learnings (compound-memory.md, retrospectives, next-feature-briefing.md)
- **Phase 1 (Understand)**: Análisis del problema, propuesta → `proposal.md`
- **Phase 2 (Specs)**: Requisitos funcionales, acceptance criteria, test contract sketch → `specs.md`
- **HITL Checkpoint**: Usuario confirma specs antes de diseño
- **Phase 3 (Design)**: Soluciones SOLID, patrones, arquitectura → `design.md`
- **Phase 4 (Tasks)**: Lista de tareas accionable → `tasks.md`
- **Completeness Verification**: Self-review + user approval
**Salida**: `proposal.md`, `specs.md`, `design.md`, `tasks.md`
**Lee**: `00_routing.md`, `openspec/specs/` (baseline), compound-memory.md
**Invoca**: codebase-analyzer, learnings-researcher, solid-analyzer, criteria-generator

### 3.4 WORK (`work.md` — 777 líneas)
**Entrada**: `tasks.md` con plan COMPLETED
**Proceso**:
- **Step 3.5**: Read learned patterns/anti-patterns, next-feature-briefing.md
- **Step 5**: TDD cycle (Red → Green → Refactor) por cada task
- **Step 7**: Checkpoint (git commit atómico)
- **BCP**: Si test falla, hasta N iteraciones (simple:5, moderate:10, complex:15)
- **Diagnostic escalation**: Tras 3 errores consecutivos iguales → diagnostic-agent
**Salida**: Código implementado, tests, actualizaciones a `tasks.md`
**Lee**: `design.md`, `specs.md`, `tasks.md`, código existente
**Invoca**: test-runner, checkpoint, lint-fixer, diagnostic-agent, solid-analyzer (verify mode)

### 3.5 REVIEW (`review.md` — 436 líneas)
**Entrada**: `tasks.md` con work COMPLETED
**Proceso**:
1. Lanza 4 review agents (code, architecture, security, performance)
2. Cada agente analiza en context: fork
3. Consolida findings en QA Summary
4. Decisión: APPROVED o REJECTED con feedback
**Salida**: QA Summary en `tasks.md`
**Lee**: `design.md`, `specs.md`, `tasks.md`, código implementado
**Invoca**: code-reviewer, architecture-reviewer, security-reviewer, performance-reviewer, spec-analyzer

### 3.6 COMPOUND (`compound.md` — 1,073 líneas)
**Entrada**: `tasks.md` con QA APPROVED
**Proceso**:
1. Extrae patterns exitosos y anti-patterns
2. Actualiza architecture-profile.yaml
3. Genera next-feature-briefing.md para la siguiente feature
4. Merge feature specs a baseline (via spec-merger)
5. Actualiza compound-memory.md
**Salida**: compound-memory.md actualizado, next-feature-briefing.md, baseline actualizado
**Lee**: todos los artefactos de la feature, architecture-profile.yaml
**Invoca**: spec-merger, learnings-researcher

### 3.7 QUICK (`quick.md` — 210 líneas) [ALTERNATIVA LIGERA]
**Entrada**: Request simple del usuario (≤3 archivos)
**Proceso**: Assessment inline, implementación directa, commit
**Escala a**: `/workflows:plan` si scope crece
**Salida**: Código implementado y commiteado

---

## 4. Mapa de Dependencias: Quién Lee / Quién Escribe

### 4.1 Archivos de OpenSpec por Feature

```
openspec/changes/{slug}/
├── 00_routing.md       ← ESCRIBE: route     | LEE: shape, plan
├── 01_shaped_brief.md  ← ESCRIBE: shape     | LEE: plan
├── 02_breadboard.md    ← ESCRIBE: shape     | LEE: plan
├── 03_slices.md        ← ESCRIBE: shape     | LEE: plan, work
├── proposal.md         ← ESCRIBE: plan (P1) | LEE: plan (P2+), work, review
├── specs.md            ← ESCRIBE: plan (P2) | LEE: plan (P3+), work, review
├── design.md           ← ESCRIBE: plan (P3) | LEE: work, review
├── tasks.md            ← ESCRIBE: plan (P4) | LEE/ESCRIBE: work, review, compound
├── scratchpad.md       ← ESCRIBE: plan, work| LEE: plan, work (ephemeral)
└── spike-*.md          ← ESCRIBE: shape     | LEE: plan
```

### 4.2 Archivos de Baseline (openspec/specs/)

```
openspec/specs/
├── constitution.md              ← ESCRIBE: discover (setup)   | LEE: plan, review
├── architecture-profile.yaml    ← ESCRIBE: discover, compound | LEE: plan, solid-analyzer
├── entities/                    ← ESCRIBE: compound           | LEE: plan
├── api/                         ← ESCRIBE: compound           | LEE: plan
├── rules/                       ← ESCRIBE: compound           | LEE: plan
└── spec-manifest.yaml           ← ESCRIBE: compound           | LEE: spec-merger
```

### 4.3 Archivos de Compound Memory

```
compound-memory.md         ← ESCRIBE: compound  | LEE: plan (Step 0), work (Step 3.5)
next-feature-briefing.md   ← ESCRIBE: compound  | LEE: plan (Step 0), work (Step 3.5)
validation-learning-log.md ← ESCRIBE: todos      | LEE: todos (antes de preguntar)
```

---

## 5. Sistema de Providers (Model-Agnostic)

### 5.1 Capabilities Configurables (`providers.yaml`)

| Capability | Opciones | Default |
|-----------|----------|---------|
| **parallelization** | auto, agent-teams, worktrees | auto |
| **terminal_orchestrator** | auto, tmux, screen, zellij, none | auto |
| **context_management** | auto, compaction-aware, manual-snapshots | auto |
| **fork_strategy** | auto, selective, aggressive, per-task | auto |
| **coordination** | auto, native-plus-state, state-plus-git | auto |
| **execution_mode** | auto, agent-executes, human-guided, hybrid | auto |
| **planning_depth** | auto, full, standard, minimal | auto |

### 5.2 Thresholds Configurables

- **Context**: compact_at_percent, max_files_read, max_session_duration, max_messages
- **BCP**: simple (5), moderate (10), complex (15), default (10)
- **Fork**: min_files_for_fork, min_output_for_fork

### 5.3 API Recommendations

Incluye recomendaciones de effort level, speed mode, y thinking mode por fase y modelo.

---

## 6. Sistema de Reglas

### 6.1 Modelo de Activación de Contexto

| Contenido | Activación | Cuándo se carga |
|-----------|-----------|-----------------|
| CLAUDE.md | Siempre | Cada sesión |
| framework_rules.md | Siempre | Cada sesión |
| testing-rules.md | Software-determined | Cuando se editan archivos de test |
| security-rules.md | Software-determined | Cuando se editan paths auth/security/payment |
| git-rules.md | Software-determined | Operaciones git |
| Roles (planner/implementer/reviewer) | LLM-determined | Cuando el rol está activo |
| Skills | Human-triggered | Invocación explícita |
| Review agents | Human-triggered | Durante `/workflows:review` |

### 6.2 Reglas Clave del Framework

1. **Route Before Acting** — Todo pasa por routing (excepto quick)
2. **Karpathy Principles** — Think, simplicity, surgical, goal-driven
3. **Explicit Context** — No implicit memory, todo en archivos
4. **Immutable Roles** — Un Claude instance = un rol fijo
5. **Execution Mode Awareness** — Respetar el provider de execution
6. **Flow Guards** — Prerequisites verificados antes de cada comando
7. **Validate Before Delivering** — Self-questioning antes de entregar
8. **Synchronized State** — tasks.md como fuente de verdad
9. **Baseline Freeze** — openspec/specs/ es read-only excepto para compound
10. **Write-Then-Advance** — Escribir output a disco antes de avanzar
11. **Contradiction Detection Protocol** — Stop y preguntar ante contradicciones
12. **Rollback Protocol** — Git checkout targeted + documentar en Decision Log

---

## 7. Control Plane (Governance)

### 7.1 Risk Tiers (`contract.json`)

| Tier | Archivos | Required Checks |
|------|----------|----------------|
| **HIGH** | core/rules/**, core/roles/**, commands/**, agents/**, CLAUDE.md, .claude/**, control-plane/** | risk-policy-gate + ci |
| **MEDIUM** | skills/**, templates/**, docs/**, providers.yaml, architecture-reference.md, plans/** | risk-policy-gate + ci |
| **LOW** | Todo lo demás | risk-policy-gate |

### 7.2 Docs Drift Rules

- Si cambias `core/rules/**` o `core/roles/**` → debes actualizar CLAUDE.md, README.md, o plans/**
- Si cambias `commands/**` → debes actualizar CLAUDE.md, README.md, o plans/**
- Si cambias `control-plane/contract.json` → debes actualizar plans/**

### 7.3 SHA Discipline

Toda evidencia (checks, reviews) debe referenciar el SHA actual de HEAD. Evidencia de commits anteriores es inválida.

---

## 8. Estado Persistente y Continuidad

### 8.1 Fuentes de Estado

| Fuente | Propósito | Persistencia |
|--------|-----------|-------------|
| `tasks.md` | Estado del workflow (roles, fases, tasks, resume point) | Por feature, en disco |
| Git commits | Checkpoints de código | Permanente |
| `openspec/changes/{slug}/` | Artefactos de planning y specs | Por feature, en disco |
| `compound-memory.md` | Learnings acumulados entre features | Global, persistente |
| `validation-learning-log.md` | Q&A que evita preguntas repetidas | Global, persistente |
| `next-feature-briefing.md` | Briefing para la siguiente feature | Transitorio, por feature |

### 8.2 Protocolo de Reanudación

1. Leer `tasks.md` → identificar fase actual y último task completado
2. Leer Resume Information section
3. Continuar desde el siguiente task pendiente
4. Checkpoint skill crea commit atómico al completar cada task

---

## 9. Métricas del Plugin

### 9.1 Distribución por Tipo de Archivo

| Categoría | Archivos | Líneas | % del Total |
|-----------|----------|--------|-------------|
| Commands | 10 | 6,810 | 32.3% |
| Skills | 16 | 4,977 | 23.6% |
| Templates | 17 | 3,035 | 14.4% |
| Docs | 8 | 2,546 | 12.1% |
| Agents | 8 | 1,747 | 8.3% |
| Architecture Reference | 1 | 854 | 4.1% |
| Rules | 4 | 580 | 2.8% |
| Roles | 3 | 275 | 1.3% |
| Config (providers + plugin.json + contract.json) | 3 | 368 | 1.7% |
| **TOTAL** | **70** | **~21,078** | **100%** |

### 9.2 Archivos Más Grandes (Top 10)

| # | Archivo | Líneas | Porcentaje |
|---|---------|--------|-----------|
| 1 | `discover.md` | 1,864 | 8.8% |
| 2 | `plan.md` | 1,130 | 5.4% |
| 3 | `compound.md` | 1,073 | 5.1% |
| 4 | `architecture-reference.md` | 854 | 4.1% |
| 5 | `work.md` | 777 | 3.7% |
| 6 | `criteria-generator` skill | 694 | 3.3% |
| 7 | `route.md` | 589 | 2.8% |
| 8 | `spec-merger` skill | 566 | 2.7% |
| 9 | `solid-analyzer` skill | 528 | 2.5% |
| 10 | `mcp-connector` skill | 509 | 2.4% |

### 9.3 Contenido Always-Loaded (Context Budget Base)

Estos archivos se cargan en cada sesión:
- `CLAUDE.md`: ~300 líneas
- `framework_rules.md`: 371 líneas
- **Total always-loaded**: ~671 líneas (~3,000-4,000 tokens estimados)

---

## 10. Compound Feedback Loop

```
Feature N: ROUTE → PLAN → WORK → REVIEW → COMPOUND
                                              │
                                              ├── Extrae patterns exitosos
                                              ├── Actualiza architecture-profile.yaml
                                              ├── Genera next-feature-briefing.md
                                              ├── Merge specs a baseline
                                              └── Actualiza compound-memory.md
                                                     │
Feature N+1: ROUTE → PLAN ←─── Lee compound-memory.md
                    │            Lee next-feature-briefing.md
                    │            Lee patterns aprendidos
                    └── WORK ←── Lee anti-patterns
                         └── (ciclo se repite)
```

Este es el mecanismo que hace que el sistema mejore con cada feature completada.

---

*Análisis completado el 2026-03-05. Basado en lectura directa de los 70 archivos del plugin.*
