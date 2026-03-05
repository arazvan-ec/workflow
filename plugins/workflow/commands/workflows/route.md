# /workflows:route - Workflow Router (Mandatory Entry Point)

**Version**: 3.2.0
**Category**: Core
**Priority**: CRITICAL - Must be invoked for ALL new interactions

---

## Purpose

This command is the **MANDATORY entry point** for all interactions with the Multi-Agent Workflow plugin. It analyzes user needs and routes to the appropriate workflow, asking clarifying questions when necessary.

**Karpathy Integration**: This router enforces "Think Before Coding" by requiring explicit assumptions and success criteria before any work begins.

**Decision Quality Integration**: This router also enforces a challenge loop before execution: question key assumptions, compare at least one alternative approach, and ask for missing constraints instead of silently guessing.

## Invocation

```bash
# Automatic (should be triggered for any new request)
/workflows:route

# With initial context
/workflows:route "I need to add user authentication"
```

## Workflow Decision Matrix

### Quick Classification Questions

When the need is unclear, ask these questions in order:

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW ROUTER                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. ¿Qué tipo de trabajo necesitas?                        │
│     [ ] Nueva funcionalidad (feature)                      │
│     [ ] Corrección de bug                                  │
│     [ ] Refactoring/mejora                                 │
│     [ ] Investigación/análisis                             │
│     [ ] Documentación                                      │
│     [ ] Revisión de código                                 │
│     [ ] Configuración/setup                                │
│     [ ] Otro (describir)                                   │
│                                                             │
│  2. ¿Cuál es la complejidad estimada?                      │
│     [ ] Simple (< 1 hora, pocos archivos)                  │
│     [ ] Media (1-4 horas, varios componentes)              │
│     [ ] Compleja (> 4 horas, múltiples capas)              │
│     [ ] No estoy seguro                                    │
│                                                             │
│  3. ¿Necesitas coordinación multi-agente?                  │
│     [ ] Sí, backend + frontend                             │
│     [ ] Sí, múltiples capas (domain, app, infra)           │
│     [ ] No, un solo rol es suficiente                      │
│     [ ] No estoy seguro                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Routing Logic

### Decision Tree

```
USER REQUEST
     │
     ▼
┌────────────────┐
│ Is this a      │──YES──▶ /workflows:discover --seed (generate compound-equivalent
│ greenfield     │         knowledge from requirements, then plan first feature)
│ project with   │
│ requirements?  │
└───────┬────────┘
        │NO
        ▼
┌────────────────┐
│ Is it a        │──YES──▶ Is scope/approach clear?
│ new feature?   │           │
└───────┬────────┘          YES──▶ /workflows:plan (task-breakdown workflow)
        │NO                  │
        │                   NO───▶ /workflows:shape (shape first, then plan)
        ▼
        │NO
        ▼
┌────────────────┐
│ Is it a        │──YES──▶ Invoke diagnostic-agent for reproduction
│ bug fix?       │         Then /workflows:plan (implementation-only)
└───────┬────────┘
        │NO
        ▼
┌────────────────┐
│ Is it code     │──YES──▶ /workflows:review
│ review?        │
└───────┬────────┘
        │NO
        ▼
┌────────────────┐
│ Is it          │──YES──▶ Invoke codebase-analyzer
│ investigation? │
└───────┬────────┘
        │NO
        ▼
┌────────────────┐
│ Is it          │──YES──▶ /workflows:work --role=planner (docs only)
│ documentation? │
└───────┬────────┘
        │NO
        ▼
┌────────────────┐
│ Is it          │──YES──▶ Invoke consultant skill
│ consulting?    │
└───────┬────────┘
        │NO
        ▼
   ASK CLARIFYING QUESTIONS
```

## Workflow Selection Matrix

| User Need | Complexity | Multi-Agent | Recommended Workflow | Command |
|-----------|------------|-------------|---------------------|---------|
| **New project from requirements** | **Any** | **Yes** | **project-seed** | **`/workflows:discover --seed`** |
| Any task | Simple (≤3 files) | No | quick | `/workflows:quick` |
| New feature (unclear scope) | Any | Maybe | shape-first | `/workflows:shape` then `/workflows:plan` |
| New feature (clear scope) | Medium/Complex | Yes | task-breakdown | `/workflows:plan --workflow=task-breakdown` |
| New feature (clear scope) | Simple | No | default | `/workflows:plan --workflow=default` |
| Bug fix | Any | No | implementation-only | `/workflows:plan --workflow=implementation-only` |
| Refactoring | Complex | Yes | task-breakdown | `/workflows:plan --workflow=task-breakdown` |
| Refactoring | Simple | No | quick or implementation-only | `/workflows:quick` or `/workflows:work` |
| Investigation | Any | No | N/A | Invoke research agents |
| Code review | Any | Yes | N/A | `/workflows:review` |
| Documentation | Any | No | N/A | `/workflows:work --role=planner` |
| Setup/Config | Any | No | N/A | Invoke consultant skill |

### Dimensional Complexity Factor

When `openspec/specs/api-architecture-diagnostic.yaml` exists, evaluate if the request CHANGES the project's dimensional profile:

| Dimensional Change | Example | Routing Impact |
|---|---|---|
| No dimension change | Add field to existing entity | No impact — route normally |
| Adds consumer diversity | New mobile app consuming API | Escalate: shape or task-breakdown |
| Adds data aggregation | New feature consuming 3+ external APIs | Escalate: task-breakdown + AC-02 |
| Adds external vendor | Integrating new payment SDK | Escalate: task-breakdown + AC-01 |
| Introduces concurrency | Parallelizing existing sequential calls | Escalate: task-breakdown + AC-03 |

If a request increases dimensional complexity, force task-breakdown workflow even if the request seems "simple" by other measures.

**IMPORTANT**: All workflows that produce code MUST comply with SOLID principles:
- **Plan phase**: SOLID is a mandatory constraint in Phase 3 (Solutions)
- **Work phase**: SOLID is verified at each checkpoint
- **Review phase**: SOLID compliance verified for approval

## Clarifying Questions Templates

### For Features

```markdown
Para ayudarte mejor con esta nueva funcionalidad, necesito algunos detalles:

1. **Descripción**: ¿Puedes describir la funcionalidad en 2-3 oraciones?
2. **Usuarios afectados**: ¿Quién usará esta funcionalidad?
3. **Stack involucrado**: ¿Backend, frontend, o ambos?
4. **Integraciones**: ¿Se conecta con APIs externas o servicios?
5. **Seguridad**: ¿Maneja datos sensibles (auth, pagos, PII)?
6. **Prioridad**: ¿Es urgente o puede planificarse?
```

### For Bugs

```markdown
Para diagnosticar y corregir este bug, necesito:

1. **Comportamiento actual**: ¿Qué está pasando ahora?
2. **Comportamiento esperado**: ¿Qué debería pasar?
3. **Pasos para reproducir**: ¿Cómo puedo ver el error?
4. **Frecuencia**: ¿Siempre ocurre o es intermitente?
5. **Entorno**: ¿Local, staging, producción?
6. **Logs/errores**: ¿Hay mensajes de error específicos?
```

### For Refactoring

```markdown
Para planificar este refactoring, necesito saber:

1. **Alcance**: ¿Qué archivos/módulos están involucrados?
2. **Motivación**: ¿Por qué es necesario este cambio?
3. **Riesgos**: ¿Qué podría romperse?
4. **Tests existentes**: ¿Hay cobertura de tests actual?
5. **Deadline**: ¿Hay restricciones de tiempo?
```

### For Investigation

```markdown
Para investigar esto efectivamente, necesito entender:

1. **Pregunta principal**: ¿Qué necesitas saber exactamente?
2. **Contexto**: ¿Por qué necesitas esta información?
3. **Alcance**: ¿Dónde debería buscar? (archivos, commits, docs)
4. **Formato de respuesta**: ¿Necesitas un reporte, código, o solo respuesta?
```

## Execution Protocol

### Step 1: Initial Analysis

```markdown
## Análisis Inicial de Solicitud

**Solicitud original**: [User's request]

**Clasificación automática**:
- Tipo detectado: [feature/bug/refactor/investigation/docs/review/greenfield/other]
- Complejidad estimada: [simple/medium/complex/unknown]
- Multi-agente requerido: [yes/no/unknown]
- Confianza en clasificación: [high/medium/low]

**Greenfield Detection**:
- Does the request describe a FULL PROJECT (multiple features, entities, roles)?
- Is there NO existing codebase (or user explicitly says "new project")?
- Does the request include requirements like entity lists, user roles, tech stack?
- If ALL YES → This is a greenfield project → recommend `/workflows:discover --seed`

**Decisión**:
- Si GREENFIELD detectado → `/workflows:discover --seed` (generate compound knowledge first)
- Si confianza HIGH → Proceder con workflow recomendado
- Si confianza MEDIUM/LOW → Hacer preguntas de clarificación
```

### Step 2: Clarification (if needed)

Present the relevant clarifying questions based on detected type.
Wait for user response before proceeding.

### Step 3: State Assumptions (Karpathy: Think Before Coding)

Before recommending a workflow, explicitly state assumptions:

```markdown
## Pre-Work Assumptions

**Request Interpretation**: [How I understand the request]

**My Assumptions**:
1. **Scope**: [What's included/excluded]
2. **Inputs**: [Expected data, formats, sources]
3. **Outputs**: [What will be produced]
4. **Edge Cases**: [Scenarios to handle]
5. **Dependencies**: [External systems, APIs, libraries]

**Potential Ambiguities**:
- [ ] [Ambiguity 1] - My interpretation: [X]

**If any assumption is wrong, please correct me before we proceed.**
```

### Step 4: Define Success Criteria (Karpathy: Goal-Driven Execution)

Transform vague requests into testable goals:

```markdown
## Success Criteria

**Original Request**: [User's words]

**Testable Goals**:
1. [ ] [Specific, verifiable criterion 1]
2. [ ] [Specific, verifiable criterion 2]
3. [ ] [Specific, verifiable criterion 3]

**Verification Method**:
- Command: `[how to verify completion]`
- Expected: [what success looks like]

**Does this capture what you need? Adjust if needed.**
```

### Step 4.5: Decision-Challenge Loop (Question Every Decision)

Before recommending the workflow, challenge the initial plan:

```markdown
## Decision-Challenge Loop

### Current proposal
- Proposed workflow: [X]
- Why this first choice: [reason]

### Alternatives considered
1. [Alternative A] -- Rejected because: [specific tradeoff]
2. [Alternative B] -- Rejected because: [specific tradeoff]

### Assumptions under stress-test
- Assumption 1: [assumption] -> Evidence: [evidence or unknown]
- Assumption 2: [assumption] -> Evidence: [evidence or unknown]

### Missing constraints (must ask if unknown)
- [ ] Deadline or delivery pressure
- [ ] Non-functional requirements (performance/security/compliance)
- [ ] Backward compatibility constraints
- [ ] Environments affected (dev/staging/prod)

**Blocking question(s) before proceed**:
1. [Highest-leverage question]

If the blocking answer is unknown, keep routing in clarification mode instead of committing to implementation.
```

### Step 5: Workflow Recommendation

```markdown
## Recomendación de Workflow

Basado en tu solicitud, recomiendo:

**Workflow**: [workflow name]
**Comando**: `/workflows:[command] --workflow=[workflow-name]`
**Razón**: [brief explanation]

**Assumptions Confirmed**: [list key assumptions]
**Success Criteria**: [list testable goals]
**Decision Challenge Notes**: [why alternatives were rejected]

**Pasos siguientes**:
1. [step 1]
2. [step 2]
3. [step 3]

¿Quieres proceder con este workflow o prefieres ajustar algo?
```

### Step 6: Persist Routing State and Handoff

Once confirmed, persist the routing decisions to disk before invoking the next command:

```bash
# 1. Create the feature directory (if it doesn't exist)
SLUG="${feature-slug}"  # Normalized: lowercase, hyphens, no spaces
mkdir -p "openspec/changes/${SLUG}"

# 2. Write routing state from template (core/templates/routing-template.md)
#    Fill in: classification, assumptions, success criteria, recommended workflow
#    Save as: openspec/changes/${SLUG}/00_routing.md

# 3. Verify the file was written
ls -la "openspec/changes/${SLUG}/00_routing.md"
```

**Why persist?** Routing decisions (classification, assumptions, success criteria) are lost if context is compacted or the session restarts. The `00_routing.md` file ensures downstream commands (`/workflows:plan`, `/workflows:shape`) can recover routing context from disk.

After persisting, invoke the recommended workflow command with all gathered context (including confirmed assumptions and success criteria).

## Enforcement Rules

### CRITICAL: This router is MANDATORY

1. **Every new user request** must pass through this router
2. **No direct workflow execution** without routing first
3. **If skipped**, Claude must self-correct and run the router
4. **Exceptions**: Only for continuing an already-routed task

### Self-Check Protocol

Before executing ANY code change, Claude must verify:

```markdown
## Router Verification

- [ ] Did this request pass through /workflows:route?
- [ ] Was a workflow explicitly selected?
- [ ] Were clarifying questions asked if needed?
- [ ] Is the chosen workflow appropriate for the task?
- [ ] Were key assumptions challenged against at least one alternative?
- [ ] Did we ask for missing critical constraints rather than guessing?

If ANY checkbox is NO → STOP and run /workflows:route first
```

## Examples

### Example 1: Clear Feature Request

```
User: "Necesito agregar autenticación con Google OAuth"

Router Analysis:
- Type: New feature (detected with HIGH confidence)
- Complexity: Medium (OAuth integration)
- Multi-agent: Yes (backend + possibly frontend)

Recommendation:
/workflows:plan user-auth-google --workflow=task-breakdown
```

### Example 2: Unclear Request

```
User: "El login no funciona"

Router Analysis:
- Type: Possibly bug, possibly feature (LOW confidence)
- Complexity: Unknown
- Multi-agent: Unknown

Clarifying Questions:
1. ¿El login funcionaba antes y dejó de funcionar? (bug)
   O ¿necesitas implementar login por primera vez? (feature)
2. ¿Qué error ves exactamente?
3. ¿En qué entorno ocurre?

[Wait for response before proceeding]
```

### Example 3: Investigation Request

```
User: "¿Cómo funciona el sistema de permisos actual?"

Router Analysis:
- Type: Investigation (HIGH confidence)
- Complexity: N/A
- Multi-agent: No

Recommendation:
Invoking codebase-analyzer agent to investigate the permissions system.
No workflow needed - this is a research task.
```

---

## Karpathy Principles Quick Check

Before completing routing, verify:

```markdown
## Karpathy Routing Check

### Think Before Coding
- [ ] Assumptions explicitly stated
- [ ] Ambiguities clarified or questions asked
- [ ] Would push back if approach seems wrong

### Simplicity First
- [ ] Workflow complexity matches task complexity
- [ ] Not over-planning for simple tasks
- [ ] Not under-planning for complex tasks

### Goal-Driven Execution
- [ ] Success criteria defined and testable
- [ ] User confirmed criteria capture their intent
- [ ] Verification method identified
```

---

## Queen Agent Pattern (Claude Code 2.1+)

The router can leverage forked sub-agents for intelligent parallel analysis before routing decisions. This transforms the router from a static decision tree into a dynamic "Queen Agent" that orchestrates analysis workers.

### How It Works

```
┌──────────────────────────────────────────────────────┐
│                    QUEEN AGENT (route)                │
│                                                      │
│  User Request → Spawn parallel analysis workers      │
│                                                      │
│  ┌─────────────┐  ┌─────────────┐                   │
│  │  consultant  │  │ spec-analyzer│                   │
│  │ (fork)       │  │ (fork)       │                   │
│  │             │  │             │                   │
│  │ Quick stack │  │ Check specs │                   │
│  │ analysis    │  │ exist?      │                   │
│  │             │  │             │                   │
│  └──────┬──────┘  └──────┬──────┘                   │
│         │                │                           │
│         ▼                ▼                           │
│  ┌──────────────────────────────────────────────┐   │
│  │          Aggregate Results                    │   │
│  │  → Complexity assessment                      │   │
│  │  → Existing specs status                      │   │
│  └──────────────────────────────────────────────┘   │
│                        │                             │
│                        ▼                             │
│              Informed Routing Decision                │
│              (with evidence, not just heuristics)     │
└──────────────────────────────────────────────────────┘
```

### When to Activate Queen Pattern

| Condition | Use Queen Pattern? | Reason |
|-----------|-------------------|--------|
| Clear simple request | No | Overhead not justified |
| Ambiguous request | **Yes** | Parallel analysis resolves ambiguity |
| Complex multi-layer feature | **Yes** | Needs stack + spec + history context |
| Sensitive area (auth/payment) | **Yes** | Trust + security pre-analysis |
| Continuing previous work | No | Context already established |

### Forked Sub-Agent Roles

#### 1. Consultant (Quick Mode)
```yaml
skill: consultant
context: fork
purpose: Quick stack detection and complexity estimate
output: { stack, complexity, architecture_pattern }
```

#### 2. Spec Analyzer
```yaml
skill: spec-analyzer
context: fork
purpose: Check if specs exist for requested feature area
output: { specs_exist, coverage_gaps, related_features }
```

### Hooks as Inter-Agent Event Bus

Forked sub-agents emit hooks that the Queen Agent can observe:

```yaml
# Sub-agent hook emissions (in forked context)
hooks:
  Stop:
    - command: "echo '[sub-agent-name] Analysis complete: {summary}'"

# Queen agent observes via PostToolUse on Task tool
# Aggregates results without context pollution
```

**Key benefit**: The Queen Agent's context stays clean. Each forked sub-agent does heavy analysis in isolation, returning only a summary. This follows Fowler's principle of "strategic context calibration" - the router sees summaries, not raw data.

### Example: Queen Agent Routing Flow

```markdown
## Queen Agent Analysis: "Necesito agregar pagos con Stripe"

### Sub-Agent Results (parallel, forked):

**Consultant (0.8s)**:
- Stack: Symfony 6.4 + PHP 8.3
- Architecture: DDD + Hexagonal
- Complexity: HIGH (payment integration)

**Spec Analyzer (0.5s)**:
- No existing payment specs found
- Related: user-authentication has auth patterns to follow
- Gap: No payment domain entities exist

### Informed Routing Decision:

Based on aggregated evidence:
- **Workflow**: task-breakdown (HIGH complexity + no existing specs)
- **Required reviews**: security-reviewer + performance-reviewer
- **Parallelization**: By layer (DDD) recommended
- **Estimated phases**: Plan (extended) → Work → Review

This decision is evidence-based, not heuristic-based.
```

---

## Summary

The `/workflows:route` command ensures:

1. **Correct workflow selection** for every task
2. **Explicit assumptions** stated before work begins (Think Before Coding)
3. **Testable success criteria** defined upfront (Goal-Driven Execution)
4. **Decision-challenge loop** before selecting workflow (question assumptions + compare alternatives)
5. **Appropriate complexity** matching task needs (Simplicity First)
6. **Gathering necessary context** through clarifying questions
7. **Consistent entry point** for all interactions

**Remember**: When in doubt, ASK. State assumptions. Define success criteria. It's better to clarify than to execute the wrong workflow.

---

## Error Recovery

- **Classification confidence LOW and user cannot clarify**: Default to `/workflows:plan` with standard depth
- **Route loop (user keeps being re-routed)**: Break the loop — ask user directly which workflow to use
- **Invalid feature name**: Normalize the name (lowercase, hyphens) and confirm with user
