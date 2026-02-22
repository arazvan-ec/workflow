# Plan Fase 4: Fusionar Skills (15→10) y Agentes (8→3+4)

**Fecha**: 2026-02-22
**Alcance**: 15 skills en `skills/`, 8 agentes en `agents/`, `plugin.json`, `CLAUDE.md`, `README.md`, y todas las referencias cruzadas
**Resultado**: 10 skills (5 fusiones + 5 sin cambio), 3 agentes principales + 4 opcionales

---

## Índice

1. Inventario actual completo
2. Fusión de Skills (5 fusiones + 5 que permanecen)
3. Fusión de Agentes (1 fusión + 2 que permanecen + 4 demotados)
4. Cambios en plugin.json
5. Cambios en CLAUDE.md y README.md
6. Actualización de referencias en comandos y archivos core
7. Orden de commits atómicos
8. Evaluación de riesgos global

---

## 1. Inventario Actual Completo

### 1.1 Skills (15 actuales)

| # | Skill | Ubicación | context | model |
|---|-------|-----------|---------|-------|
| 1 | git-sync | `skills/git-sync/SKILL.md` | - | - |
| 2 | commit-formatter | `skills/commit-formatter/SKILL.md` | - | - |
| 3 | test-runner | `skills/test-runner/SKILL.md` | - | - |
| 4 | coverage-checker | `skills/coverage-checker/SKILL.md` | fork | - |
| 5 | lint-fixer | `skills/lint-fixer/SKILL.md` | - | - |
| 6 | source-report | `skills/source-report/SKILL.md` | fork | sonnet |
| 7 | spec-merger | `skills/spec-merger/SKILL.md` | fork | - |
| 8 | breadboarder | `skills/breadboarder/SKILL.md` | fork | opus |
| 9 | shaper | `skills/shaper/SKILL.md` | fork | opus |
| 10 | consultant | `skills/consultant/SKILL.md` | fork | - |
| 11 | checkpoint | `skills/checkpoint/SKILL.md` | - | - |
| 12 | validation-learning-log | `skills/validation-learning-log/SKILL.md` | fork | inherit |
| 13 | mcp-connector | `skills/mcp-connector.md` | fork | - |
| 14 | workflow-skill-criteria-generator | `skills/workflow-skill-criteria-generator.md` | - | inherit |
| 15 | workflow-skill-solid-analyzer | `skills/workflow-skill-solid-analyzer.md` | fork | inherit |

### 1.2 Agentes (8 actuales)

| # | Agente | Ubicación | Categoría | context |
|---|--------|-----------|-----------|---------|
| 1 | codebase-analyzer | `agents/research/codebase-analyzer.md` | research | - |
| 2 | learnings-researcher | `agents/research/learnings-researcher.md` | research | - |
| 3 | code-reviewer | `agents/review/code-reviewer.md` | review | fork |
| 4 | architecture-reviewer | `agents/review/architecture-reviewer.md` | review | fork |
| 5 | security-reviewer | `agents/review/security-reviewer.md` | review | fork |
| 6 | performance-reviewer | `agents/review/performance-reviewer.md` | review | fork |
| 7 | diagnostic-agent | `agents/workflow/diagnostic-agent.md` | workflow | fork |
| 8 | spec-analyzer | `agents/workflow/spec-analyzer.md` | workflow | - |

---

## 2. Fusión de Skills

### 2.1 FUSIÓN: git-sync + commit-formatter → git-ops

**Archivos involucrados:**
- ELIMINAR: `skills/git-sync/SKILL.md`
- ELIMINAR: `skills/commit-formatter/SKILL.md`
- CREAR: `skills/git-ops/SKILL.md`

**Estructura del contenido fusionado:**

```markdown
---
name: git-ops
description: "Git operations: sync with remote and enforce conventional commit format."
hooks:
  PreToolUse:
    - matcher: Bash
      command: "echo '[git-ops] Validating commit message format...'"
  PostToolUse:
    - matcher: Bash
      command: "echo '[git-ops] Git operation step completed'"
  Stop:
    - command: "echo '[git-ops] Git operations completed successfully.'"
---

# Git Operations Skill

## Part 1: Repository Sync
[Contenido completo de git-sync/SKILL.md]

## Part 2: Commit Formatting
[Contenido completo de commit-formatter/SKILL.md]
```

**Lo que se conserva:** Todo. **Lo que se descarta:** Nada funcional.

**Referencias que necesitan actualización:**

| Archivo | Referencia actual | Nueva referencia |
|---------|-------------------|------------------|
| `core/rules/git-rules.md` | `git-sync skill` | `git-ops skill` |
| `core/docs/CAPABILITY_PROVIDERS.md` | `git-sync skill` | `git-ops skill` |
| `core/docs/CONTEXT_ENGINEERING.md` | `commit-formatter`, `git-sync` | `git-ops` |
| `core/docs/MCP_INTEGRATION.md` | `git-sync skill` | `git-ops skill` |
| `core/providers.yaml` | `git-sync skill` | `git-ops skill` |
| `skills/checkpoint/SKILL.md` | mención de git-sync | git-ops |
| `CLAUDE.md` | `git-sync, commit-formatter` | `git-ops` |

**Riesgo:** BAJO. Operaciones git complementarias sin lógica compleja.

---

### 2.2 FUSIÓN: test-runner + coverage-checker → test-suite

**Archivos involucrados:**
- ELIMINAR: `skills/test-runner/SKILL.md`
- ELIMINAR: `skills/coverage-checker/SKILL.md`
- CREAR: `skills/test-suite/SKILL.md`

**Estructura:** Unifica bajo `context: fork` del coverage-checker.

**Referencias que necesitan actualización:**

| Archivo | Referencia actual | Nueva referencia |
|---------|-------------------|------------------|
| `commands/workflows/work.md` (líneas 92, 94, 107, 373, 646) | `test-runner` | `test-suite` |
| `core/roles/implementer.md` | `test-runner skill` | `test-suite skill` |
| `core/rules/testing-rules.md` | `/skill:coverage-checker` | `/skill:test-suite` |
| `core/providers.yaml` | `coverage-checker`, `test-runner` | `test-suite` |
| `core/docs/CAPABILITY_PROVIDERS.md` | ambos | `test-suite` |
| `core/docs/CONTEXT_ENGINEERING.md` | ambos | `test-suite` |
| `CLAUDE.md` | `test-runner, coverage-checker` | `test-suite` |

**Riesgo:** MEDIO-BAJO. `context: fork` heredado del coverage-checker es aceptable.

---

### 2.3 FUSIÓN: lint-fixer + source-report → code-quality

**Archivos involucrados:**
- ELIMINAR: `skills/lint-fixer/SKILL.md`
- ELIMINAR: `skills/source-report/SKILL.md`
- CREAR: `skills/code-quality/SKILL.md`

**PRECAUCIÓN:** lint-fixer se ejecuta en CADA ciclo TDD (paso 9 de work). source-report usa `context: fork` y `model: sonnet`. Al fusionar, lint-fix bajo fork sería costoso.

**RECOMENDACIÓN:** Eliminar `context: fork` y `model: sonnet` del skill fusionado. Aplicarlos solo cuando se invoca la función report. Alternativamente, considerar mantener lint-fixer separado.

**Referencias que necesitan actualización:**

| Archivo | Referencia actual | Nueva referencia |
|---------|-------------------|------------------|
| `commands/workflows/work.md` (líneas 100, 652) | `lint-fixer` | `code-quality` |
| `core/roles/implementer.md` | `lint-fixer skill` | `code-quality skill` |
| `core/docs/CAPABILITY_PROVIDERS.md` | `lint-fixer skill` | `code-quality skill` |
| `core/docs/CONTEXT_ENGINEERING.md` | `lint-fixer` | `code-quality` |
| `CLAUDE.md` | `lint-fixer`, `source-report` | `code-quality` |

**Riesgo:** MEDIO. Fusión temática débil; overhead de fork en lint-fix frecuente.

---

### 2.4 FUSIÓN: spec-merger + criteria-generator → spec-ops

**Archivos involucrados:**
- ELIMINAR: `skills/spec-merger/SKILL.md`
- ELIMINAR: `skills/workflow-skill-criteria-generator.md`
- CREAR: `skills/spec-ops/SKILL.md`

**Estructura:** Ambos ya usan `context: fork`. Se unifica bajo `model: inherit`.

**Referencias que necesitan actualización:**

| Archivo | Referencia actual | Nueva referencia |
|---------|-------------------|------------------|
| `commands/workflows/plan.md` (líneas 440, 1087) | `/workflow-skill:criteria-generator` | `/multi-agent-workflow:spec-ops criteria` |
| `commands/workflows/compound.md` (líneas 683-684, 691, 960, 984) | `spec-merger` | `spec-ops merge` |
| `core/rules/framework_rules.md` | `spec-merger` | `spec-ops` |
| `core/docs/CONTEXT_ENGINEERING.md` | `spec-merger` | `spec-ops` |
| `core/templates/spec-template.md` | `/workflow-skill:criteria-generator` | `/multi-agent-workflow:spec-ops criteria` |
| `skills/workflow-skill-solid-analyzer.md` | `criteria-generator` | `spec-ops criteria` |
| `CLAUDE.md` | `spec-merger`, `criteria-generator` | `spec-ops` |

**Riesgo:** MEDIO. Temáticamente coherentes, pero archivo fusionado será ~870 líneas. Fork lo mitiga.

---

### 2.5 FUSIÓN: breadboarder + shaper → shape-tools

**Archivos involucrados:**
- ELIMINAR: `skills/breadboarder/SKILL.md`
- ELIMINAR: `skills/shaper/SKILL.md`
- CREAR: `skills/shape-tools/SKILL.md`

**Estructura:** Ambos usan `model: opus` y `context: fork`. Fusión natural — shaper produce brief, breadboarder lo consume.

**Referencias que necesitan actualización:**

| Archivo | Referencia actual | Nueva referencia |
|---------|-------------------|------------------|
| `commands/workflows/shape.md` (líneas 122, 156, 159, 178, 184, 329-335) | `shaper`, `breadboarder` | `shape-tools shape`, `shape-tools breadboard` |
| `CLAUDE.md` | `shaper, breadboarder` | `shape-tools` |

**Riesgo:** BAJO. Fusión más natural de todas — secuenciales por diseño.

---

### 2.6 Skills que permanecen sin cambios

| Skill | Justificación |
|-------|---------------|
| consultant | Skill grande y autónomo (383 líneas), responsabilidad única |
| checkpoint | Pieza crítica del BCP, referenciada extensivamente en work.md |
| validation-learning-log | Funcionalidad única de persistencia de aprendizajes |
| mcp-connector | Integra con infraestructura externa MCP |
| solid-analyzer | Skill complejo con 3 modos, referenciado en 20+ lugares |

---

### 2.7 Resumen de Skills después de la fusión

| # | Skill | Origen | context | model |
|---|-------|--------|---------|-------|
| 1 | **git-ops** | git-sync + commit-formatter | - | - |
| 2 | **test-suite** | test-runner + coverage-checker | fork | - |
| 3 | **code-quality** | lint-fixer + source-report | fork* | sonnet* |
| 4 | **spec-ops** | spec-merger + criteria-generator | fork | inherit |
| 5 | **shape-tools** | breadboarder + shaper | fork | opus |
| 6 | consultant | (sin cambio) | fork | - |
| 7 | checkpoint | (sin cambio) | - | - |
| 8 | validation-learning-log | (sin cambio) | fork | inherit |
| 9 | mcp-connector | (sin cambio) | fork | - |
| 10 | solid-analyzer | (sin cambio) | fork | inherit |

**Total: 10 skills** (no 8 como propuesto originalmente — ver sección de riesgos)

*Para code-quality: ver recomendación en sección 2.3 sobre eliminar fork/sonnet.

---

## 3. Fusión de Agentes

### 3.1 FUSIÓN: codebase-analyzer + learnings-researcher → project-analyzer

**Archivos involucrados:**
- ELIMINAR: `agents/research/codebase-analyzer.md`
- ELIMINAR: `agents/research/learnings-researcher.md`
- CREAR: `agents/research/project-analyzer.md`

**Estructura:** Unifica análisis de estructura + búsqueda de conocimiento institucional bajo `model: haiku`.

**Referencias que necesitan actualización:**

| Archivo | Referencia actual | Nueva referencia |
|---------|-------------------|------------------|
| `commands/workflows/route.md` (líneas 89, 101, 429, 473, 516) | `codebase-analyzer` | `project-analyzer` |
| `commands/workflows/discover.md` (9 ocurrencias) | `codebase-analyzer` | `project-analyzer` |
| `commands/workflows/compound.md` (línea 957) | `learnings-researcher` | `project-analyzer` |
| `core/providers.yaml` | `codebase-analyzer` | `project-analyzer` |
| `core/docs/WORKFLOW_DECISION_MATRIX.md` | `codebase-analyzer` | `project-analyzer` |
| `core/docs/CONTEXT_ENGINEERING.md` | `codebase-analyzer` | `project-analyzer` |
| `CLAUDE.md` | `codebase-analyzer, learnings-researcher` | `project-analyzer` |
| `README.md` | ambos | `project-analyzer` |

**Riesgo:** BAJO. Ambos agentes son de investigación pre-trabajo, complementarios, nunca se invocan en la misma fase.

---

### 3.2 Agentes que permanecen sin cambios

| Agente | Justificación |
|--------|---------------|
| code-reviewer | 258 líneas, checklists específicos por stack, funcionalidad crítica |
| architecture-reviewer | 339 líneas, verificación DDD/SOLID, integra con solid-analyzer |

---

### 3.3 Agentes demotados a apéndice opcional

Los siguientes 4 agentes se mueven a `agents/optional/` y se eliminan del array `agents` de `plugin.json`. Permanecen accesibles vía invocación directa.

#### 3.3.1 security-reviewer → opcional

**Mover:** `agents/review/security-reviewer.md` → `agents/optional/security-reviewer.md`
**Justificación:** Solo relevante para features de autenticación, pagos, y endpoints públicos.
**Integración residual:** Agregar referencia en `code-reviewer.md`:
```markdown
## Optional: Security-Focused Review
For auth, payment, or public API features, invoke the dedicated security reviewer:
`/multi-agent-workflow:security-reviewer`
(See: agents/optional/security-reviewer.md)
```

#### 3.3.2 performance-reviewer → opcional

**Mover:** `agents/review/performance-reviewer.md` → `agents/optional/performance-reviewer.md`
**Justificación:** Context-activated (solo cuando detecta DB/ORM, API routes, o frontend build). Candidato natural para opcional.

#### 3.3.3 diagnostic-agent → opcional

**Mover:** `agents/workflow/diagnostic-agent.md` → `agents/optional/diagnostic-agent.md`
**Justificación:** Solo se activa bajo condiciones específicas: (1) routing clasifica como BUG, (2) BCP escalation tras 3 errores iguales.
**PRECAUCIÓN:** Referenciado directamente en la lógica del BCP en `work.md`. Las referencias deben mantenerse funcionales con path actualizado.

#### 3.3.4 spec-analyzer → opcional

**Mover:** `agents/workflow/spec-analyzer.md` → `agents/optional/spec-analyzer.md`
**Justificación:** El agente más simple (156 líneas), funcionalidad solapada con el proceso de review.

---

### 3.4 Resumen de Agentes después de la fusión

**Agentes principales (en plugin.json):**

| # | Agente | Ubicación |
|---|--------|-----------|
| 1 | **project-analyzer** | `agents/research/project-analyzer.md` |
| 2 | code-reviewer | `agents/review/code-reviewer.md` |
| 3 | architecture-reviewer | `agents/review/architecture-reviewer.md` |

**Agentes opcionales (NO en plugin.json, accesibles vía path directo):**

| # | Agente | Ubicación |
|---|--------|-----------|
| 4 | security-reviewer | `agents/optional/security-reviewer.md` |
| 5 | performance-reviewer | `agents/optional/performance-reviewer.md` |
| 6 | diagnostic-agent | `agents/optional/diagnostic-agent.md` |
| 7 | spec-analyzer | `agents/optional/spec-analyzer.md` |

**Total: 3 agentes principales + 4 opcionales = 7**

---

## 4. Cambios en plugin.json

**Archivo:** `.claude-plugin/plugin.json`

**Estado nuevo:**
```json
{
  "name": "multi-agent-workflow",
  "version": "3.3.0",
  "description": "...3 core agents (+4 optional), 10 workflow commands, 10 skills, 3 roles...",
  "agents": [
    "./agents/research/project-analyzer.md",
    "./agents/review/architecture-reviewer.md",
    "./agents/review/code-reviewer.md"
  ],
  "skills": "./skills/"
}
```

**Cambios:** Version 3.2.0→3.3.0, agents de 8→3 entradas, description actualizada.

---

## 5. Cambios en CLAUDE.md y README.md

### 5.1 CLAUDE.md — Sección "Agents"

**Nuevo:**
```markdown
| Category | Agents | Invoked by |
|----------|--------|------------|
| Roles (3) | planner, implementer, reviewer | `plan`, `work`, `review` |
| Review (2) | code-reviewer, architecture-reviewer | `review` |
| Research (1) | project-analyzer | `route`, `plan`, `discover` |
| Optional (4) | security-reviewer, performance-reviewer, diagnostic-agent, spec-analyzer | on-demand |
```

### 5.2 CLAUDE.md — Sección "Skills"

**Nuevo:**
```markdown
| Category | Skills |
|----------|--------|
| Core | consultant, checkpoint, git-ops |
| Quality | test-suite, code-quality |
| Compound | spec-ops, validation-learning-log |
| Integration | mcp-connector |
| SOLID | solid-analyzer |
| Shaping | shape-tools |
```

### 5.3 README.md

- Línea 7: `8 agents, 10 commands, 15 skills` → `3+4 agents, 10 commands, 10 skills`
- Tablas de agentes y skills: reflejar nueva estructura

---

## 6. Mapa Completo de Referencias a Actualizar

| Archivo | Tipo de cambio | Prioridad |
|---------|---------------|-----------|
| `commands/workflows/work.md` | `test-runner`→`test-suite`, `lint-fixer`→`code-quality`, `diagnostic-agent` path | CRÍTICA |
| `commands/workflows/plan.md` | `criteria-generator`→`spec-ops criteria`, `spec-analyzer` path | CRÍTICA |
| `commands/workflows/shape.md` | `shaper`→`shape-tools shape`, `breadboarder`→`shape-tools breadboard` | CRÍTICA |
| `commands/workflows/compound.md` | `spec-merger`→`spec-ops merge`, `learnings-researcher`→`project-analyzer` | ALTA |
| `commands/workflows/route.md` | `codebase-analyzer`→`project-analyzer`, paths opcionales | ALTA |
| `commands/workflows/discover.md` | `codebase-analyzer`→`project-analyzer` (9 ocurrencias) | ALTA |
| `core/roles/implementer.md` | `test-runner`→`test-suite`, `lint-fixer`→`code-quality` | ALTA |
| `core/rules/testing-rules.md` | `coverage-checker`→`test-suite` | MEDIA |
| `core/rules/git-rules.md` | `git-sync`→`git-ops` | MEDIA |
| `core/rules/framework_rules.md` | `spec-merger`→`spec-ops` | MEDIA |
| `core/providers.yaml` | Múltiples referencias | ALTA |
| `core/docs/CAPABILITY_PROVIDERS.md` | Múltiples referencias | ALTA |
| `core/docs/CONTEXT_ENGINEERING.md` | Múltiples referencias | ALTA |
| `core/docs/WORKFLOW_DECISION_MATRIX.md` | `codebase-analyzer`→`project-analyzer` | MEDIA |
| `core/templates/spec-template.md` | `criteria-generator`→`spec-ops criteria` | MEDIA |

---

## 7. Orden de Commits Atómicos

**REGLA FUNDAMENTAL:** Crear archivos nuevos → actualizar referencias → eliminar archivos viejos.

### Commit 1: Crear directorio agents/optional
- `mkdir -p plugins/multi-agent-workflow/agents/optional/`
- Mensaje: `chore(agents): create optional agents directory`

### Commit 2: Fusión de agentes — project-analyzer
- Crear: `agents/research/project-analyzer.md`
- Mensaje: `feat(agents): merge codebase-analyzer + learnings-researcher into project-analyzer`

### Commit 3: Demotar agentes opcionales
- Mover: security-reviewer, performance-reviewer, diagnostic-agent, spec-analyzer → `agents/optional/`
- Mensaje: `refactor(agents): demote 4 agents to optional`

### Commit 4: Fusión de skills — git-ops
- Crear: `skills/git-ops/SKILL.md`
- Mensaje: `feat(skills): merge git-sync + commit-formatter into git-ops`

### Commit 5: Fusión de skills — test-suite
- Crear: `skills/test-suite/SKILL.md`
- Mensaje: `feat(skills): merge test-runner + coverage-checker into test-suite`

### Commit 6: Fusión de skills — code-quality
- Crear: `skills/code-quality/SKILL.md`
- Mensaje: `feat(skills): merge lint-fixer + source-report into code-quality`

### Commit 7: Fusión de skills — spec-ops
- Crear: `skills/spec-ops/SKILL.md`
- Mensaje: `feat(skills): merge spec-merger + criteria-generator into spec-ops`

### Commit 8: Fusión de skills — shape-tools
- Crear: `skills/shape-tools/SKILL.md`
- Mensaje: `feat(skills): merge breadboarder + shaper into shape-tools`

### Commit 9: Actualizar TODAS las referencias en comandos
- Modificar: work.md, plan.md, shape.md, compound.md, route.md, discover.md, review.md, help.md
- Mensaje: `refactor(commands): update all skill and agent references to new merged names`

### Commit 10: Actualizar TODAS las referencias en core
- Modificar: roles, rules, providers.yaml, docs, templates
- Mensaje: `refactor(core): update all skill and agent references to new merged names`

### Commit 11: Actualizar cross-references internas entre skills
- Modificar: solid-analyzer, checkpoint, code-reviewer (agregar secciones de referencia a opcionales)
- Mensaje: `refactor(skills): update internal cross-references`

### Commit 12: Actualizar plugin.json, CLAUDE.md, README.md
- Mensaje: `docs(plugin): update plugin.json, CLAUDE.md, README.md for Phase 4 (15→10 skills, 8→3+4 agents)`

### Commit 13: Eliminar archivos fuente obsoletos
- Eliminar: 9 directorios de skills + 1 archivo suelto + 2 archivos de agentes
- Mensaje: `chore(cleanup): remove original skill and agent files replaced by merges`

### Commit 14: Limpiar directorios vacíos
- Eliminar: `agents/workflow/` si quedó vacío
- Mensaje: `chore(cleanup): remove empty directories after agent restructure`

---

## 8. Evaluación de Riesgos Global

### 8.1 Riesgo de comandos hard-coded

**HALLAZGO CRÍTICO:** Los comandos slash usan el patrón `/multi-agent-workflow:<skill-name>`. Al renombrar skills, los nombres viejos dejan de funcionar.

**Nombres slash que se romperán:**
- `/multi-agent-workflow:git-sync` → `/multi-agent-workflow:git-ops`
- `/multi-agent-workflow:source-report` → `/multi-agent-workflow:code-quality`
- `/multi-agent-workflow:merge-specs` → `/multi-agent-workflow:spec-ops`
- `/multi-agent-workflow:shaper` → `/multi-agent-workflow:shape-tools`
- `/multi-agent-workflow:breadboarder` → `/multi-agent-workflow:shape-tools`
- `/workflow-skill:criteria-generator` → `/multi-agent-workflow:spec-ops`

**Mitigación:** Actualizar TODAS las referencias (commits 9-10) ANTES de eliminar archivos (commit 13).

### 8.2 Riesgo de context: fork en funciones frecuentes

**HALLAZGO:** Al fusionar lint-fixer (sin fork) con source-report (fork), `code-quality` usaría fork para TODAS las invocaciones, incluyendo lint-fix en cada ciclo TDD.

**Mitigación recomendada:** NO declarar `context: fork` a nivel de skill. Documentar que `report` debe invocarse con fork explícitamente.

### 8.3 Tamaño de skills fusionados

| Skill fusionado | Líneas estimadas | Riesgo |
|-----------------|-----------------|--------|
| git-ops | ~280 | BAJO |
| test-suite | ~340 | BAJO |
| code-quality | ~340 | BAJO |
| spec-ops | ~870 | MEDIO (fork mitiga) |
| shape-tools | ~640 | MEDIO (fork mitiga) |

### 8.4 Diagnostic-agent demotado

El diagnostic-agent se invoca automáticamente por el BCP tras 3 errores consecutivos. Al estar demotado, debe cargarse explícitamente. En `work.md`, la referencia debe incluir path completo: `agents/optional/diagnostic-agent.md`.

### 8.5 No se pierde ninguna funcionalidad

Todos los contenidos se conservan íntegramente. Lo que cambia: organización, descubribilidad (agentes opcionales menos visibles), y potencial overhead de fork en code-quality.

---

## Resumen Final

| Métrica | Antes | Después | Reducción |
|---------|-------|---------|-----------|
| Skills | 15 | 10 | -33% |
| Agentes principales | 8 | 3 | -63% |
| Agentes opcionales | 0 | 4 | +4 |
| Agentes total | 8 | 7 | -13% |
| Archivos a actualizar | - | ~30 | N/A |
| Commits atómicos | - | 14 | N/A |

---

## Archivos Críticos para la Implementación

- `.claude-plugin/plugin.json` — Registro central de agentes y skills
- `CLAUDE.md` — Contexto siempre cargado; cada cambio de nombre debe reflejarse
- `commands/workflows/work.md` — Archivo con más referencias densas (mayor riesgo de rotura)
- `commands/workflows/discover.md` — 9 referencias a codebase-analyzer que deben migrar
- `core/docs/CONTEXT_ENGINEERING.md` — Documenta fork context y hook bindings
