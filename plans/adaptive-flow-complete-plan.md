# Adaptive Flow — Plan Completo de Diseño

**Fecha**: 2026-02-25
**Estado**: PROPUESTA — Pendiente de implementación
**Branch**: `claude/explore-code-plugins-3CXVS`
**Origen**: Análisis del ecosistema (30+ repos) + mejores prácticas 2025-2026 + experiencia con Multi-Agent Workflow v3.3.0

---

## 1. Qué Es Adaptive Flow

Adaptive Flow es un **framework de ingeniería compuesta para Claude Code** que aplica principios SOLID al propio proceso de desarrollo asistido por IA. No es una reescritura del plugin actual — es una **evolución arquitectónica** que resuelve los problemas fundamentales que ningún repo del ecosistema ha resuelto.

### La Tesis Central

> El proceso de desarrollo con IA debe adaptarse a la gravedad de la tarea, no forzar un proceso uniforme. Y el conocimiento que acumula el usuario sobre cómo trabajar con IA es tan valioso como el conocimiento técnico del proyecto.

### Problemas que Resuelve

| Problema | Cómo lo resuelven otros | Cómo lo resuelve Adaptive Flow |
|----------|------------------------|-------------------------------|
| "Proceso pesado para tareas simples" | Un flujo único para todo | **Gravedad adaptativa**: 4 niveles de proceso proporcionales a la complejidad |
| "La IA olvida lo que funcionó" | Sin memoria entre sesiones | **Compound Memory**: patrones, anti-patrones y briefings que sobreviven entre features |
| "El usuario sabe cosas que la IA no" | Reglas rígidas en CLAUDE.md | **User Insights bidireccional**: heurísticas graduadas que influyen en decisiones |
| "Contexto sobrecargado" | CLAUDE.md de 500+ líneas | **Progressive disclosure**: ~100 líneas siempre + contexto bajo demanda |
| "Workers contaminan el contexto" | Todo en una ventana | **Workers con contexto fresco**: subagentes que no arrastran historial |
| "Quality gates inconsistentes" | Checklists manuales | **Hooks determinísticos**: validaciones automáticas via Claude Code hooks |
| "Sin retroalimentación real" | Flujo lineal | **Feedback loops**: review → plan, compound → next feature, insights ⇄ ambos |

---

## 2. Principios de Diseño

### 2.1 SOLID Aplicado al Framework

El framework mismo sigue SOLID — no solo el código que genera:

| Principio | Aplicación al Framework |
|-----------|------------------------|
| **SRP** | Cada archivo tiene una responsabilidad única. CLAUDE.md = routing. Flows = proceso. Workers = ejecución. Memory = persistencia. |
| **OCP** | Nuevo comportamiento se añade creando archivos, no modificando los existentes. Nuevos flows, workers, hooks, insights. |
| **LSP** | Cualquier flow puede sustituir a otro en el mismo nivel de gravedad sin romper el sistema. |
| **ISP** | El agente solo carga el contexto que necesita para la fase actual. No hay "carga todo". |
| **DIP** | Los flows dependen de abstracciones (workers, hooks) no de implementaciones concretas. |

### 2.2 Principios Operativos

1. **Gravedad proporcional**: El proceso debe pesar lo mismo que la tarea
2. **Contexto mínimo viable**: Cargar solo lo necesario para la decisión actual
3. **Insights sobre reglas**: Preferir heurísticas graduadas sobre reglas binarias
4. **Workers efímeros**: Subagentes con contexto fresco, no acumulado
5. **Hooks determinísticos**: Las validaciones que se pueden automatizar, se automatizan
6. **Compound por defecto**: Cada tarea alimenta la siguiente
7. **El usuario tiene la última palabra**: Los insights del usuario siempre tienen prioridad sobre los descubiertos por la IA

---

## 3. Arquitectura

### 3.1 Estructura de Archivos

```
adaptive-flow/
├── CLAUDE.md                          # Entry point (~100 líneas)
│                                      # Solo: gravedad, routing, referencia a flows
│
├── flows/                             # Procesos por nivel de gravedad
│   ├── direct.md                      # Gravedad 1: Ejecución directa
│   ├── plan-execute.md                # Gravedad 2: Plan ligero → ejecutar
│   ├── full-cycle.md                  # Gravedad 3: Plan completo → TDD → review
│   └── shape-first.md                 # Gravedad 4: Shape → plan → TDD → review → compound
│
├── workers/                           # Subagentes con contexto fresco
│   ├── planner.md                     # Diseño y arquitectura
│   ├── implementer.md                 # Ejecución TDD
│   ├── reviewer.md                    # Review multi-dimensional
│   └── researcher.md                  # Análisis de codebase
│
├── hooks/                             # Quality gates determinísticos
│   ├── pre-commit.sh                  # Validación antes de commit
│   ├── post-plan.sh                   # Validación después de planificar
│   ├── pre-work.sh                    # Verificar que el plan existe
│   └── post-review.sh                 # Verificar criteria met
│
├── memory/                            # Persistencia entre sesiones
│   ├── user-insights.yaml             # Meta-conocimiento del usuario (Tipo 3)
│   ├── discovered-insights.yaml       # Patrones descubiertos por IA
│   ├── learnings.yaml                 # Patrones técnicos del proyecto (Tipo 2)
│   └── patterns.yaml                  # Patrones de código extraídos
│
├── templates/                         # Templates para artefactos
│   ├── spec.md                        # Template de especificación
│   ├── design.md                      # Template de diseño SOLID
│   ├── tasks.md                       # Template de tareas
│   └── retrospective.md              # Template de retrospectiva
│
├── core/                              # Referencia técnica (carga bajo demanda)
│   ├── solid-reference.md             # SOLID patterns y analysis
│   ├── testing-guide.md               # TDD y test strategy
│   ├── security-guide.md              # Security patterns
│   └── api-patterns.md                # API architecture patterns
│
└── skills/                            # Skills invocables
    ├── insights-manager.md            # CRUD de insights
    ├── solid-analyzer.md              # Análisis SOLID contextual
    └── compound-capture.md            # Captura de learnings
```

### 3.2 Comparación con Plugin Actual

| Aspecto | Multi-Agent Workflow v3.3.0 | Adaptive Flow |
|---------|---------------------------|---------------|
| CLAUDE.md | 182 líneas, siempre cargado | ~100 líneas, minimal |
| Flujos | 1 flujo con 6 fases | 4 flujos por gravedad |
| Workers | 8 agentes + 3 roles | 4 workers especializados |
| Skills | 16 skills | 3 skills esenciales |
| Rules | 370 líneas obligatorias (framework_rules.md) | 0 reglas obligatorias — todo son insights |
| Docs | 8 docs reference (~3,900 líneas) | 4 guides bajo demanda (~800 líneas) |
| Memory | compound-memory.md + compound_log.md | 4 archivos de memoria estructurada |
| Hooks | Descritos en docs, no implementados | Hooks reales de Claude Code |
| Insights | Nuevo (v3.3.0) | Sistema central del framework |
| Token budget base | ~15K tokens (CLAUDE.md + rules) | ~3K tokens (CLAUDE.md solo) |

---

## 4. CLAUDE.md — El Entry Point Minimal

```markdown
# Adaptive Flow

Framework de ingeniería compuesta. Adapta el proceso a la gravedad de la tarea.

## Routing: Determinar Gravedad

Antes de actuar, clasifica la solicitud:

| Gravedad | Criterio | Flow | Ejemplo |
|----------|----------|------|---------|
| 1 | ≤3 archivos, cambio claro, sin ambigüedad | `flows/direct.md` | "Añade campo email a User" |
| 2 | 4-8 archivos, requiere planificar, scope claro | `flows/plan-execute.md` | "Implementa paginación en API" |
| 3 | >8 archivos o multi-capa o seguridad/pagos | `flows/full-cycle.md` | "Añade autenticación OAuth" |
| 4 | Scope ambiguo, requiere investigación/shaping | `flows/shape-first.md` | "Reestructura el módulo de billing" |

Si la confianza en la clasificación es < 60%, preguntar al usuario.

## En cada decisión, consultar:

1. `memory/user-insights.yaml` — Heurísticas del usuario (influence: high → aplicar, medium → considerar)
2. `memory/learnings.yaml` — Patrones del proyecto (si existen)
3. El flow correspondiente a la gravedad

## Workers (subagentes con contexto fresco)

| Worker | Cuándo | Contexto que recibe |
|--------|--------|---------------------|
| planner | Gravedad 2-4 | Flow + specs existentes + insights de planning |
| implementer | Gravedad 2-4 | Plan + insights de implementation |
| reviewer | Gravedad 3-4 | Código + specs + insights de review |
| researcher | Cuando se necesita análisis | Pregunta específica |

Workers corren en `context: fork` — contexto fresco, retornan solo resumen.

## Hooks (quality gates automáticos)

Los hooks en `hooks/` se ejecutan automáticamente via Claude Code hooks API.
No dependen de que el agente "recuerde" ejecutarlos.

## Skills

- `/adaptive-flow:insights-manager` — Gestionar insights del usuario
- `/adaptive-flow:solid-analyzer` — Análisis SOLID contextual
- `/adaptive-flow:compound-capture` — Capturar learnings post-feature

## Compound: Cada tarea mejora la siguiente

Después de completar una tarea de gravedad 3+, ejecutar compound-capture para:
- Extraer patrones y anti-patrones → `memory/learnings.yaml`
- Proponer discovered insights → `memory/discovered-insights.yaml`
- Generar briefing para la siguiente tarea
```

**~95 líneas**. Todo lo demás se carga bajo demanda cuando el flow lo requiere.

---

## 5. Sistema de Gravedad

### 5.1 Gravedad 1: Direct (`flows/direct.md`)

```
Usuario → Clasificar (gravedad 1) → Ejecutar directamente
                                      ↓
                                   Consultar insights (high influence only)
                                      ↓
                                   Hacer el cambio
                                      ↓
                                   Verificar (tests pasan)
```

**Qué carga**: Solo CLAUDE.md + insights de implementation con influence=high
**Qué NO hace**: No planifica, no crea specs, no hace review formal
**Cuándo**: Cambios triviales, fixes obvios, adiciones simples

### 5.2 Gravedad 2: Plan-Execute (`flows/plan-execute.md`)

```
Usuario → Clasificar (gravedad 2) → Worker: planner (ligero)
                                      ↓
                                   Plan: spec + tasks (un solo archivo)
                                      ↓
                                   HITL: "¿Este plan captura tu intención?"
                                      ↓
                                   Worker: implementer (TDD)
                                      ↓
                                   Verificar (tests + lint)
```

**Qué carga**: CLAUDE.md + flow + insights de planning + insights de implementation
**Workers**: planner (plan ligero), implementer
**Artefactos**: `openspec/changes/{slug}/plan-and-tasks.md` (un solo archivo combinado)

### 5.3 Gravedad 3: Full Cycle (`flows/full-cycle.md`)

```
Usuario → Clasificar (gravedad 3) → Cargar compound learnings
                                      ↓
                                   Worker: planner
                                      ↓
                                   Artefactos: spec.md → design.md → tasks.md
                                      ↓
                                   HITL: "¿Specs correctas?" → "¿Diseño correcto?"
                                      ↓
                                   Worker: implementer (TDD + BCP)
                                      ↓
                                   Worker: reviewer (multi-dimensional)
                                      ↓
                                   APPROVED → Worker: compound-capture
                                      ↓
                                   Actualizar memory/
```

**Qué carga**: Todo lo relevante, pero incrementalmente por fase
**Workers**: planner, implementer, reviewer + compound
**Artefactos**: spec.md, design.md, tasks.md, retrospective.md
**SOLID**: Mandatory en design phase (Phase 3)

### 5.4 Gravedad 4: Shape First (`flows/shape-first.md`)

```
Usuario → Clasificar (gravedad 4) → Worker: researcher (análisis)
                                      ↓
                                   Shaped brief: frame + shape + slices
                                      ↓
                                   HITL: "¿El scope es correcto?"
                                      ↓
                                   → Gravedad 3 flow (con shaped brief como input)
```

**Cuándo**: El scope no está claro, hay incertidumbre técnica, se necesita investigación
**Diferencia con Gravedad 3**: Añade una fase de descubrimiento antes de planificar

---

## 6. Sistema de User Insights Bidireccional

### 6.1 Tres Tipos de Conocimiento

```
Tipo 1: Conocimiento del proyecto     → memory/learnings.yaml
         "Nuestra API usa JWT con refresh tokens"
         Fuente: compound capture, codebase analysis

Tipo 2: Patrones técnicos             → memory/patterns.yaml
         "jose funciona mejor que jsonwebtoken en Edge"
         Fuente: compound capture, retrospectives

Tipo 3: Meta-conocimiento del usuario → memory/user-insights.yaml
         "Cuando le pido SOLID a la IA, el código escala mejor"
         Fuente: experiencia del usuario trabajando con IA

Tipo 3b: Patrones descubiertos por IA → memory/discovered-insights.yaml
          "En este proyecto, los endpoints sin validación generan 4x más bugs"
          Fuente: análisis cross-feature durante compound
```

### 6.2 Cómo Fluyen los Insights

```
                    ┌─────────────────────────────────┐
                    │         DECISION POINT           │
                    │  (routing, planning, coding,     │
                    │   reviewing)                     │
                    └──────────┬──────────────────────┘
                               │
                    ┌──────────▼──────────────────────┐
                    │     LOAD RELEVANT INSIGHTS       │
                    │                                  │
                    │  1. Filter by current phase       │
                    │  2. Filter by status = active     │
                    │  3. Sort by influence level       │
                    │                                  │
                    │  high   → apply proactively      │
                    │  medium → suggest if relevant    │
                    │  low    → only if user asks      │
                    └──────────┬──────────────────────┘
                               │
                    ┌──────────▼──────────────────────┐
                    │     APPLY TO DECISION            │
                    │                                  │
                    │  Insight "SOLID scales better"   │
                    │  → Design with SOLID from start  │
                    │                                  │
                    │  Insight "small functions"       │
                    │  → Split functions > 20 lines    │
                    └──────────┬──────────────────────┘
                               │
                    ┌──────────▼──────────────────────┐
                    │     DOCUMENT INFLUENCE           │
                    │                                  │
                    │  "Applied insight: solid-scales  │
                    │   → Designed with Strategy       │
                    │   pattern for validators"        │
                    └─────────────────────────────────┘
```

### 6.3 El Loop Bidireccional

```
USUARIO ──teaches──→ user-insights.yaml ──influences──→ AI decisions
   ↑                                                        │
   │                                                        │
   └──reviews/accepts←── discovered-insights.yaml ←──proposes──┘
                         (during compound capture)
```

El ciclo:
1. **Usuario enseña**: Añade insights basados en su experiencia
2. **IA aplica**: Consulta insights en cada punto de decisión
3. **IA descubre**: Durante compound, detecta patrones cross-feature
4. **IA propone**: Escribe discovered-insights.yaml con confidence score
5. **Usuario revisa**: Acepta, rechaza o modifica las propuestas
6. **Insights maduran**: Los aceptados con confidence >= 0.7 se pueden promover a user-insights

### 6.4 Insights vs. Rules

| Aspecto | Regla (CLAUDE.md) | Insight (user-insights.yaml) |
|---------|-------------------|------------------------------|
| Formato | "Siempre haz X" | "He observado que X funciona porque Y" |
| Contexto | Siempre activa | Solo en fases relevantes |
| Flexibilidad | On/off | Graduada (high/medium/low) |
| Evidencia | Ninguna | Documentada |
| Override | Romperla se siente mal | Ajustarla es natural |
| Evolución | Editar texto | Pausar, ajustar, retirar |
| Propiedad | Del framework | Del usuario |

---

## 7. Workers con Contexto Fresco

### 7.1 Problema que Resuelven

En el plugin actual, toda la conversación acumula contexto. Después de 30 mensajes planificando, el implementer arrastra toda esa historia, perdiendo foco y consumiendo tokens.

### 7.2 Patrón: Queen Agent → Worker

```
QUEEN AGENT (main conversation)
    │
    ├── Determina gravedad
    ├── Selecciona flow
    ├── Carga insights relevantes
    │
    └── SPAWNS Worker (context: fork)
         │
         ├── Recibe: instrucciones + artefactos + insights
         ├── NO recibe: historial de conversación
         ├── Ejecuta: su tarea específica
         └── Retorna: resumen + artefactos producidos
```

### 7.3 Workers Definidos

#### Planner Worker
```yaml
name: planner
context: fork
receives:
  - Flow instructions for current gravity
  - User insights with when_to_apply: [planning, design]
  - Existing specs (if any) from openspec/specs/
  - Compound learnings (if any) from memory/
produces:
  - spec.md (WHAT the system must do)
  - design.md (HOW to implement, with SOLID)
  - tasks.md (actionable task list)
```

#### Implementer Worker
```yaml
name: implementer
context: fork
receives:
  - tasks.md from planner
  - design.md for SOLID reference
  - User insights with when_to_apply: [implementation]
  - Compound learnings for this area
produces:
  - Code changes (committed)
  - Test results
  - Completion status per task
```

#### Reviewer Worker
```yaml
name: reviewer
context: fork
receives:
  - Code diff from implementer
  - spec.md for acceptance criteria
  - design.md for SOLID verification
  - User insights with when_to_apply: [review]
produces:
  - QA report (APPROVED/REJECTED)
  - Issues found (if any)
  - Insights Applied section
```

#### Researcher Worker
```yaml
name: researcher
context: fork
receives:
  - Specific question or analysis request
  - Relevant file paths
produces:
  - Analysis report
  - Recommendations
```

---

## 8. Hooks Determinísticos

### 8.1 Por Qué Hooks

El plugin actual describe quality gates en los documentos, pero depende de que el agente los "recuerde". Los hooks de Claude Code se ejecutan automáticamente — son determinísticos, no probabilísticos.

### 8.2 Hooks Propuestos

```yaml
# .claude/hooks.yaml (Claude Code hooks configuration)

hooks:
  # Antes de commit: verificar que tests pasan
  PreCommit:
    - command: "bash adaptive-flow/hooks/pre-commit.sh"
      description: "Run tests and lint before committing"

  # Después de que el planner termina: verificar completitud
  PostToolUse:
    - matcher: "Task"  # When a worker returns
      command: "bash adaptive-flow/hooks/post-worker.sh"
      description: "Validate worker output completeness"

  # Al inicio de sesión: cargar estado
  SessionStart:
    - command: "bash adaptive-flow/hooks/session-start.sh"
      description: "Load workflow state and pending insights"
```

### 8.3 Qué Valida Cada Hook

| Hook | Validación | Acción si falla |
|------|-----------|-----------------|
| pre-commit.sh | Tests pasan, lint limpio, no archivos sensibles | Bloquea commit, muestra errores |
| post-plan.sh | spec.md tiene acceptance criteria, design.md tiene SOLID verdicts | Warning al usuario |
| pre-work.sh | tasks.md existe, plan está COMPLETED | Bloquea work, sugiere planificar |
| post-review.sh | Todos los criteria verificados con evidencia | Warning si faltan |
| session-start.sh | Carga pending insights para review, muestra estado de workflow activo | Informativo |

---

## 9. Compound Engineering: Cada Tarea Mejora la Siguiente

### 9.1 El Loop Compound

```
Feature N completada
       │
       ▼
┌──────────────────────┐
│  COMPOUND CAPTURE     │
│                       │
│  1. Extraer patterns  │──→ memory/patterns.yaml
│  2. Extraer learnings │──→ memory/learnings.yaml
│  3. Discover insights │──→ memory/discovered-insights.yaml
│  4. Generate briefing │──→ memory/next-briefing.md
│  5. Retrospective     │──→ openspec/changes/{slug}/retrospective.md
│                       │
└───────────┬──────────┘
            │
            ▼
Feature N+1 planificación
       │
       ▼
┌──────────────────────┐
│  LOAD COMPOUND DATA   │
│                       │
│  1. Read learnings    │←── memory/learnings.yaml
│  2. Read insights     │←── memory/user-insights.yaml + discovered
│  3. Read briefing     │←── memory/next-briefing.md
│  4. Apply to planning │
│                       │
└──────────────────────┘
```

### 9.2 Qué Captura el Compound

| Tipo | Ejemplo | Destino |
|------|---------|---------|
| Pattern exitoso | "Value Object for Email encapsuló validación" | patterns.yaml |
| Anti-pattern | "Skipping integration tests → bugs en QA" | learnings.yaml |
| 70% boundary | "La complejidad real estaba en edge cases de auth" | learnings.yaml |
| Discovered insight | "Endpoints sin validación → 4x más bugs" | discovered-insights.yaml |
| Briefing | "Para next feature: reusar Email VO, testear auth temprano" | next-briefing.md |
| Retrospective | "Qué fue bien, qué mejorar, sorpresas" | retrospective.md |

---

## 10. Ideas Nuevas del Análisis del Ecosistema + Investigación

### 10.1 Adaptive Autonomy (de la investigación 2025-2026)

En lugar de un nivel fijo de autonomía, el sistema ajusta cuánto pide confirmación basándose en:
- **Confianza del agente**: Si tiene alta confianza en la clasificación, procede. Si no, pregunta.
- **Trust level del archivo**: Archivos de auth/pagos → siempre confirmar. Tests → proceder.
- **Historial del usuario**: Si el usuario ha aprobado decisiones similares antes, proceder.

```yaml
# En user-insights.yaml, el usuario puede añadir:
- id: trust-test-changes
  observation: "No necesito confirmar cambios en archivos de test"
  when_to_apply: [implementation]
  influence: high
  tags: [autonomy, trust]
```

### 10.2 Context Compression Points (de investigación)

En lugar de dejar que Claude Code compacte automáticamente, definir **puntos explícitos de compresión**:
- Al terminar cada fase (plan → work): compactar historial de planificación
- Al spawneear un worker: el worker empieza fresco (ya resuelto por context: fork)
- Al cambiar de gravedad: re-evaluar qué contexto es relevante

### 10.3 Skill Composition (OCP aplicado a skills)

En lugar de skills monolíticos, permitir composición:
```
/adaptive-flow:solid-analyzer --mode=baseline    # Análisis del estado actual
/adaptive-flow:solid-analyzer --mode=design      # Validar diseño
/adaptive-flow:solid-analyzer --mode=verify      # Verificar código vs diseño
```

Un skill, múltiples modos. Esto ya existe en el plugin actual y se mantiene.

### 10.4 Evidence-Based Routing (nuevo)

El router no solo clasifica por heurísticas — puede spawneear workers de investigación rápida para tomar decisiones informadas:

```
Request ambiguo → spawn researcher (30s max)
                   ├── "¿Cuántos archivos afecta?"
                   ├── "¿Hay specs existentes?"
                   └── "¿Qué dice el architecture-profile?"
                        ↓
                   Routing informado por evidencia
```

### 10.5 Insight Decay (nuevo)

Los insights no son eternos. Se propone un mecanismo de "decay":
- `last_validated` se actualiza cada vez que un insight se aplica con éxito
- Si un insight no se aplica en 5+ features → marcarlo como `stale`
- El usuario decide: renovar o retirar
- Esto evita acumulación de insights obsoletos

### 10.6 Progressive Onboarding (nuevo)

Para proyectos nuevos, Adaptive Flow no empieza vacío:

```
/adaptive-flow:discover --seed
    │
    ├── Analiza el stack (framework, lenguaje, ORM, tests)
    ├── Genera architecture-profile.yaml
    ├── Pre-carga insights comunes para ese stack:
    │   "En proyectos {framework}, aplicar {pattern} mejora {outcome}"
    │   (con status: suggested, influence: medium)
    └── El usuario revisa y acepta/rechaza
```

### 10.7 HITL Checkpoints Adaptativos (nuevo)

Los checkpoints Human-in-the-Loop no son fijos — se adaptan:

| Contexto | Checkpoint |
|----------|-----------|
| Primera vez en este tipo de tarea | Checkpoint en CADA transición |
| Ya se ha hecho algo similar | Solo checkpoint en decisiones irreversibles |
| Área de alto riesgo (auth, pagos) | Siempre checkpoint, independiente del historial |
| El usuario tiene insight de autonomía | Reducir checkpoints según insight |

### 10.8 Structured Memory con Semantic Search (futuro)

Cuando la memoria crece (50+ learnings), la búsqueda lineal no escala. Idea futura:
- Indexar learnings con tags semánticos
- Cuando se planifica una feature, buscar learnings por similaridad semántica
- Priorizar los más relevantes al contexto actual

---

## 11. Migración desde Multi-Agent Workflow v3.3.0

### 11.1 Qué se Mantiene (refactorizado)

| De v3.3.0 | En Adaptive Flow | Cambio |
|-----------|-----------------|--------|
| CLAUDE.md (182 líneas) | CLAUDE.md (~100 líneas) | Reducido, solo routing |
| 10 commands (route, plan, work, review, compound...) | 4 flows (direct, plan-execute, full-cycle, shape-first) | Consolidados |
| 3 roles (planner, implementer, reviewer) | 4 workers (planner, implementer, reviewer, researcher) | Renombrados + researcher |
| solid-analyzer skill | solid-analyzer skill | Sin cambio |
| memory/user-insights.yaml | memory/user-insights.yaml | Sin cambio |
| memory/discovered-insights.yaml | memory/discovered-insights.yaml | Sin cambio |
| insights-manager skill | insights-manager skill | Sin cambio |
| SOLID enforcement en Phase 3 | SOLID enforcement en design | Sin cambio |
| Compound Engineering | Compound Engineering | Simplificado |
| BCP (Bounded Correction Protocol) | BCP en implementer worker | Integrado en worker |
| TDD cycle | TDD en implementer worker | Integrado en worker |

### 11.2 Qué se Elimina

| De v3.3.0 | Razón |
|-----------|-------|
| framework_rules.md (370 líneas) | Convertido a insights + hooks |
| 8 docs de referencia (~3,900 líneas) | 4 guides compactos (~800 líneas) |
| 8 agentes (4 review + 2 research + 2 workflow) | 4 workers + review dimensions en reviewer |
| 16 skills | 3 skills esenciales |
| Comandos separados (route, plan, work, review, compound) | Flujos integrados por gravedad |
| Context Activation Model complejo | Progressive disclosure simple |

### 11.3 Qué es Nuevo

| Concepto | Descripción |
|----------|------------|
| Gravedad adaptativa | 4 niveles de proceso proporcionales a la tarea |
| Hooks determinísticos | Quality gates automatizados via Claude Code hooks |
| Workers con contexto fresco | Subagentes que no arrastran historial |
| Adaptive Autonomy | El nivel de confirmación se adapta al contexto |
| Insight Decay | Los insights tienen ciclo de vida |
| Evidence-Based Routing | Routing informado por análisis rápido |
| Progressive Onboarding | Insights pre-cargados por stack |
| HITL Adaptativos | Checkpoints que se ajustan al historial |

---

## 12. Plan de Implementación

### Fase 1: Fundación (estructura + CLAUDE.md + flows)
1. Crear estructura de directorios
2. Escribir CLAUDE.md (~100 líneas)
3. Escribir los 4 flows
4. Migrar sistema de insights (ya implementado en v3.3.0)

### Fase 2: Workers
5. Escribir planner worker
6. Escribir implementer worker (TDD + BCP integrado)
7. Escribir reviewer worker (multi-dimensional)
8. Escribir researcher worker

### Fase 3: Hooks + Memory
9. Implementar hooks de Claude Code
10. Estructurar memory/ con schemas
11. Implementar compound-capture skill

### Fase 4: Skills + Core Reference
12. Migrar solid-analyzer
13. Migrar insights-manager
14. Escribir guides compactos (4 archivos, ~200 líneas cada uno)

### Fase 5: Templates + Onboarding
15. Crear templates para artefactos
16. Implementar progressive onboarding (discover --seed)

---

## 13. Métricas de Éxito

| Métrica | v3.3.0 Actual | Adaptive Flow Target |
|---------|---------------|---------------------|
| Token budget base (siempre cargado) | ~15K tokens | ~3K tokens |
| Archivos en plugin | ~50 archivos | ~25 archivos |
| Líneas de documentación | ~6,000+ | ~2,000 |
| Tiempo para tarea simple (gravedad 1) | Pasa por routing completo | Ejecución directa |
| Conocimiento entre sesiones | Compound memory | Compound + Insights bidireccionales |
| Quality gates | Probabilísticos (el agente recuerda) | Determinísticos (hooks) |
| Human checkpoints | Fijos (inicio + final) | Adaptativos (basados en contexto + insights) |

---

## 14. Fuentes e Influencias

### Del Ecosistema Analizado (30+ repos)
- **bmad-method**: Estructura de roles → Workers especializados
- **cline-docs**: Reglas escalables → Progressive disclosure
- **amp-labs**: Contexto mínimo → CLAUDE.md minimal
- **claude-engineer**: Workflows adaptivos → Gravedad
- **openspec**: Spec-Driven Development → Templates
- **kiro** (AWS): Spec → Plan → Tasks → Implement
- **spec-kit** (GitHub): Spec-driven con quality gates

### De la Industria 2025-2026
- **Anthropic**: Context Engineering (Fowler) → Activation Model
- **Karpathy**: Think before coding → Planner worker
- **Addy Osmani**: 70% problem → Compound 70% boundary analysis
- **Shape Up** (Basecamp): Shaping → Gravedad 4 flow
- **Martin Fowler**: SDD Tools → Spec-driven templates

### Ideas Propias
- **User Insights bidireccional**: Ningún repo captura meta-conocimiento de colaboración
- **Insight Decay**: Ciclo de vida para heurísticas
- **Adaptive Autonomy via Insights**: El usuario controla la autonomía con insights, no con config
- **Hooks determinísticos**: Mover quality gates de documentos a código ejecutable
- **Evidence-Based Routing**: Routing informado por análisis, no solo heurísticas

---

*Plan completo generado el 2026-02-25. Listo para revisión e implementación.*
