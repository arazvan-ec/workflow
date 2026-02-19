# Plan de Mejora del Workflow IA — Basado en Mejores Prácticas 2025-2026

**Fecha**: 2026-02-19
**Estado**: BORRADOR — Pendiente de revisión
**Branch**: `claude/ai-workflow-improvement-plan-EMzUb`
**Plugin**: Multi-Agent Workflow v3.1.0
**Metodología**: Análisis cruzado entre estado actual del plugin y mejores prácticas de la industria

---

## Resumen Ejecutivo

El plugin Multi-Agent Workflow v3.1.0 está conceptualmente bien diseñado (flujo faseado, SOLID enforcement, Compound Engineering, Context Activation Model). Sin embargo, al contrastarlo con las mejores prácticas de 2025-2026, se identifican **10 áreas de mejora** organizadas en 3 categorías:

1. **Alineación con Spec-Driven Development (SDD)** — El paradigma dominante en 2025-2026
2. **Ingeniería de Contexto** — La disciplina que reemplaza al prompt engineering
3. **Patrones de Orquestación Multi-Agente** — Patrones validados por la industria

---

## Estado Actual vs. Mejores Prácticas

### Lo que el plugin ya hace bien (validado por la industria)

| Práctica del plugin | Validación externa |
|---------------------|-------------------|
| Flujo faseado ROUTE→PLAN→WORK→REVIEW→COMPOUND | Alineado con el patrón Sequential/Pipeline (Microsoft Azure Architecture Center) |
| SOLID enforcement en fase de diseño | Alineado con "architecture-first planning" (AWS AI-DLC) |
| Roles especializados (planner/implementer/reviewer) | Alineado con Maker-Checker pattern (Microsoft, Azure) |
| Context Activation Model (Fowler) | Alineado con "context as layered" (Anthropic Context Engineering) |
| Compound Engineering (learnings capture) | Alineado con "external persistence / memory" (Anthropic, promptingguide.ai) |
| Human-in-the-Loop checkpoints | Alineado con "engineer-in-the-loop" (Leanware, Versent, PwC) |
| `context: fork` para agentes pesados | Alineado con "minimize token usage" y "avoid oversized context" (Anthropic) |
| Bounded Correction Protocol | Alineado con Reflection Pattern (Stack AI, Digital Applied) |
| Capability Providers auto-detect | Alineado con "right-sizing de modelo por fase" (UiPath, Google Cloud) |

### Gaps identificados (ordenados por impacto)

---

## ÁREA 1: Alineación con Spec-Driven Development (SDD)

### Gap 1.1 — Sin estructura SDD estandarizada
**Impacto**: ALTO
**Estado actual**: El plugin usa `tasks.md` con un Workflow State section, pero no sigue el patrón estándar de SDD (spec.md → plan.md → tasks.md → implement).

**Mejor práctica**: Spec-Driven Development se ha consolidado como el paradigma dominante para desarrollo asistido por IA. GitHub Spec Kit, AWS Kiro y JetBrains Junie implementan un flujo de 3-4 documentos markdown por feature:
- `requirements.md` o `spec.md` — Qué se quiere (intención, no implementación)
- `design.md` o `plan.md` — Cómo se va a hacer (arquitectura, secuencia)
- `tasks.md` — Lista accionable de pasos
- `constitution.md` (opcional) — Principios no negociables del proyecto

**Recomendación**:
1. Adoptar la estructura `spec.md → design.md → tasks.md` por feature en `openspec/changes/{slug}/`
2. El `plan.md` actual (1365 líneas) debería dividirse en `spec.md` (requisitos) + `design.md` (soluciones SOLID)
3. Añadir un `constitution.md` a nivel de proyecto que capture los principios inmutables (equivalente a lo que hoy está disperso entre `framework_rules.md` y `CLAUDE.md`)

**Fuentes**:
- [Thoughtworks: Spec-Driven Development](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [Martin Fowler: SDD Tools](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [JetBrains: Spec-Driven Approach for AI](https://blog.jetbrains.com/junie/2025/10/how-to-use-a-spec-driven-approach-for-coding-with-ai/)
- [GitHub Spec Kit](https://developer.microsoft.com/blog/spec-driven-development-spec-kit)
- [David Lapsley: SDLD](https://blog.davidlapsley.io/engineering/process/best%20practices/ai-assisted%20development/2026/01/11/spec-driven-development-with-llms.html)

---

### Gap 1.2 — Sin Decision Log trazable
**Impacto**: MEDIO
**Estado actual**: Las decisiones de diseño quedan implícitas en el `plan.md`, sin un registro explícito de alternativas evaluadas y razones de elección.

**Mejor práctica**: Las decisiones de diseño deben ser trazables. Qodo recomienda "Attribution-Based Review" donde cada decisión tiene una razón documentada. AWS Kiro genera design docs con sequence diagrams que documentan el "por qué" además del "qué".

**Recomendación**:
1. Añadir una sección `## Decision Log` al template de `design.md`
2. Formato: `| Decisión | Alternativas | Razón | Riesgo |`
3. El `/workflows:plan` debería generar este log automáticamente en Phase 3

**Fuentes**:
- [Red Hat: SDD and Quality](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality)
- [AWS AI-DLC](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/)

---

### Gap 1.3 — Sin Test Contract Sketch temprano
**Impacto**: ALTO
**Estado actual**: Los tests solo aparecen en la fase WORK (implementación con TDD). No hay sketch de contratos de test en la fase de diseño.

**Mejor práctica**: Los contratos de test (qué se va a testear, con qué criterios de aceptación) deben definirse durante el diseño, no durante la implementación. Esto alinea expectativas antes de escribir código.

**Recomendación**:
1. Añadir "Test Contract Sketch" como step en `/workflows:plan` Phase 2
2. Definir qué se testea (scenarios, edge cases) sin escribir código de test aún
3. Esto alimenta el TDD en `/workflows:work` con criterios ya validados

**Fuentes**:
- [SoftwareSeni: SDD Complete Guide](https://www.softwareseni.com/spec-driven-development-in-2025-the-complete-guide-to-using-ai-to-write-production-code/)
- [Versent: AI-Enabled SDLC](https://versent.com.au/blog/ai-enabled-sdlc-a-structured-human-centered-workflow-for-ai-assisted-development/)

---

## ÁREA 2: Ingeniería de Contexto

### Gap 2.1 — CLAUDE.md y rules sobrecargados (lost-in-the-middle)
**Impacto**: CRÍTICO
**Estado actual**: `framework_rules.md` tiene 13 KB, `CLAUDE.md` + roles + docs suman ~88 KB de contexto potencial. El plan de mejora existente ya identifica ~3500 líneas redundantes.

**Mejor práctica**: Anthropic advierte explícitamente: "When context files exceed a few thousand tokens, critical rules get buried in the middle, exactly where models pay the least attention — triggering 'lost-in-the-middle' failures." La industria ha pasado de AGENTS.md gigantes a "progressive disclosure" donde el contexto se carga incrementalmente.

**Recomendación**:
1. Reducir `CLAUDE.md` al mínimo absoluto (< 500 tokens): solo flujo, comandos, y pointer a docs
2. Cada fase carga su propio contexto bajo demanda (ya lo hace parcialmente con Context Activation Model)
3. Eliminar redundancias entre `CLAUDE.md`, `framework_rules.md`, y los command files
4. Aplicar el principio "frontmatter → body → linked files" de progressive disclosure

**Fuentes**:
- [Anthropic: Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [FlowHunt: Context Engineering Guide](https://www.flowhunt.io/blog/context-engineering/)
- [Promptingguide.ai: Context Engineering Guide](https://www.promptingguide.ai/guides/context-engineering-guide)
- [Faros AI: Context Engineering for Developers](https://www.faros.ai/blog/context-engineering-for-developers)
- [deepset: Context Engineering](https://www.deepset.ai/blog/context-engineering-the-next-frontier-beyond-prompt-engineering)

---

### Gap 2.2 — Sin scratchpad/memoria entre sesiones
**Impacto**: MEDIO
**Estado actual**: `SESSION_CONTINUITY.md` documenta patrones de persistencia pero referencia 5+ comandos que no existen (`/workflows:snapshot`, `/workflows:restore`). La memoria real depende de `tasks.md`.

**Mejor práctica**: Anthropic recomienda "external persistence (scratchpads & memory)" como patrón fundamental: "Don't force the model to remember everything. Persist critical information outside the context window." Los mejores workflows implementan scratchpads por tarea y memoria a largo plazo entre sesiones.

**Recomendación**:
1. Implementar un scratchpad real por feature en `openspec/changes/{slug}/scratchpad.md`
2. Reemplazar los comandos fantasma de SESSION_CONTINUITY por un hook `SessionStart` que lee el estado del workflow automáticamente
3. Usar `compound` para consolidar learnings en memoria a largo plazo (ya lo hace, pero formalizar el formato)

**Fuentes**:
- [Anthropic: Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [alexop.dev: Claude Code Full Stack](https://alexop.dev/posts/understanding-claude-code-full-stack/)
- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

---

### Gap 2.3 — Context Activation sin métricas de uso
**Impacto**: BAJO
**Estado actual**: El Context Activation Model (Fowler) está bien diseñado pero no hay forma de saber cuánto contexto se está usando en cada sesión ni qué capas se activan realmente.

**Mejor práctica**: "Monitor MCP usage with `/context` and remove unused servers" — el mismo principio aplica a todo el contexto. Cada MCP tool description consume tokens, y lo mismo aplica a skills y rules que se cargan innecesariamente.

**Recomendación**:
1. Documentar el peso estimado en tokens de cada capa de contexto
2. Añadir una nota en `CONTEXT_ENGINEERING.md` con recomendaciones de `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50`
3. Considerar un skill de "context audit" que estime el uso

**Fuentes**:
- [mays.co: Optimizing Claude Code](https://mays.co/optimizing-claude-code)
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)

---

## ÁREA 3: Patrones de Orquestación Multi-Agente

### Gap 3.1 — Sin Reflection Pattern real
**Impacto**: ALTO
**Estado actual**: El Bounded Correction Protocol detecta desviaciones tipo 1-3 y escala a diagnostic-agent tras 3 errores. Pero no hay auto-crítica del output antes de entregarlo (reflection). Los Quality Gates son checks estáticos, no auto-evaluación.

**Mejor práctica**: El Reflection Pattern es uno de los 6 patrones canónicos de orquestación multi-agente. "First-pass AI outputs are rarely optimal. Instead of assuming correctness, the system treats generation as a draft. Reflection converts AI from a generator into a self-correcting system."

**Recomendación**:
1. Añadir un paso de "self-review" antes de cada transición de fase
2. En `/workflows:work`: antes de marcar COMPLETED, el implementer revisa su propio output contra los acceptance criteria del spec
3. En `/workflows:plan`: el planner evalúa su design contra los principios SOLID antes de presentarlo al usuario
4. Esto es diferente del review multi-agente — es auto-reflexión interna

**Fuentes**:
- [Stack AI: 2026 Guide to Agentic Workflow Architectures](https://www.stack-ai.com/blog/the-2026-guide-to-agentic-workflow-architectures)
- [Digital Applied: AI Agent Orchestration](https://www.digitalapplied.com/blog/ai-agent-orchestration-workflows-guide)
- [Microsoft: AI Agent Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns)
- [OnAbout: Multi-Agent Enterprise Strategy](https://www.onabout.ai/p/mastering-multi-agent-orchestration-architectures-patterns-roi-benchmarks-for-2025-2026)

---

### Gap 3.2 — Sin Feedback Loop entre fases
**Impacto**: MEDIO
**Estado actual**: El flujo es lineal (ROUTE→PLAN→WORK→REVIEW→COMPOUND). Si el review encuentra problemas, se rechaza y vuelve a WORK, pero no hay retroalimentación estructurada hacia PLAN.

**Mejor práctica**: Los mejores workflows implementan feedback loops donde los hallazgos de fases posteriores informan fases anteriores. Microsoft y OpenAI recomiendan que los errores de implementación que revelan problemas de diseño retroalimenten al plan.

**Recomendación**:
1. Cuando `/workflows:review` encuentra problemas arquitectónicos (no solo de código), permitir retroalimentación a PLAN
2. Documentar un "feedback path" formal: REVIEW → PLAN para problemas de diseño, REVIEW → WORK para problemas de implementación
3. Registrar estos feedback loops en el Decision Log

**Fuentes**:
- [Ciklum: AI Revolutionizing SDLC](https://www.ciklum.com/blog/ai-revolutionize-software-development-lifecycle/)
- [Microsoft: AI-Led SDLC](https://techcommunity.microsoft.com/blog/appsonazureblog/an-ai-led-sdlc-building-an-end-to-end-agentic-software-development-lifecycle-wit/4491896)

---

### Gap 3.3 — HITL limitado a inicio y final
**Impacto**: ALTO
**Estado actual**: Human-in-the-Loop está en routing (inicio) y review (final). Las decisiones de alto riesgo durante planning y work no tienen checkpoints explícitos para el humano.

**Mejor práctica**: "Human escalation or validation can be implemented at any stage of the pipeline." El modelo "Human Above the Loop" propone que el humano supervise las decisiones de alto impacto en cada fase, no solo al inicio y final.

**Recomendación**:
1. Añadir checkpoints HITL en:
   - `/workflows:plan` Phase 3 — Cuando se toman decisiones arquitectónicas irreversibles
   - `/workflows:work` — Cuando el BCP detecta Type 3 deviations (patrones incompletos)
   - `/workflows:work` — Antes de modificar archivos de configuración críticos (DB migrations, env vars, CI configs)
2. Usar el skill `checkpoint` para estos puntos (ya existe pero no se invoca automáticamente)

**Fuentes**:
- [Leanware: Best Practices AI Development 2026](https://www.leanware.co/insights/best-practices-ai-software-development)
- [Bunnyshell: Modern SDLC Practices](https://www.bunnyshell.com/blog/accelerating-software-development-modern-sdlc-prac/)
- [smartsdlc.dev: AI Framework for DX](https://smartsdlc.dev/blog/ai-powered-sdlc-building-an-ai-framework-for-developer-experience/)

---

### Gap 3.4 — Sin Ralph Loop Pattern para tareas de larga duración
**Impacto**: BAJO (nice-to-have)
**Estado actual**: El plugin no implementa autonomous completion loops.

**Mejor práctica**: El "Ralph Wiggum pattern" (Geoffrey Huntley, 2025) ejecuta un agente en loop autónomo hasta que se satisface un criterio de completitud. Equipos lo usan para refactors overnight y triage de backlogs grandes.

**Recomendación**:
1. Documentar como patrón avanzado en `CAPABILITY_PROVIDERS.md`
2. Considerar implementación futura como modo de ejecución del provider de `execution_mode`
3. No es prioritario — el plugin ya tiene Bounded Correction Protocol que cubre parcialmente esto

**Fuentes**:
- [Faros AI: Best AI Coding Agents 2026](https://www.faros.ai/blog/best-ai-coding-agents-2026)
- [Beyond Vibe Coding: 2026 Trends](https://beyond.addy.ie/2026-trends/)

---

## Matriz de Priorización

| # | Mejora | Impacto | Esfuerzo | Prioridad |
|---|--------|---------|----------|-----------|
| 2.1 | Reducir contexto (lost-in-the-middle) | CRÍTICO | Medio | **P0** |
| 1.1 | Adoptar estructura SDD | ALTO | Alto | **P1** |
| 1.3 | Test Contract Sketch en diseño | ALTO | Bajo | **P1** |
| 3.1 | Reflection Pattern | ALTO | Medio | **P1** |
| 3.3 | HITL en todas las fases | ALTO | Bajo | **P1** |
| 1.2 | Decision Log | MEDIO | Bajo | **P2** |
| 2.2 | Scratchpad/memoria real | MEDIO | Medio | **P2** |
| 3.2 | Feedback loops REVIEW→PLAN | MEDIO | Bajo | **P2** |
| 2.3 | Métricas de contexto | BAJO | Bajo | **P3** |
| 3.4 | Ralph Loop Pattern | BAJO | Alto | **P3** |

---

## Relación con Plan de Mejora Existente (v3.1.0)

Este plan **complementa** el `plugin-improvement-plan.md` existente (2026-02-15). Aquel plan se enfoca en correcciones internas (referencias rotas, redundancias, inconsistencias). Este plan se enfoca en **alineación con la industria**.

**Solapamientos**:
- Gap A (Sin Reflection Pattern) = nuestro Gap 3.1
- Gap B (Sin Feedback Loop) = nuestro Gap 3.2
- Gap C (Sin Chunking) ≈ cubierto por nuestra recomendación SDD de dividir plan.md
- Gap D (Sin Test Contract Sketch) = nuestro Gap 1.3
- Gap F (HITL débil) = nuestro Gap 3.3
- Problema #1 (Contaminación de contexto) = nuestro Gap 2.1
- Problema #7 (plan.md sobrecargado) = resuelto por Gap 1.1 (dividir en spec+design+tasks)

**No solapados (nuevos en este plan)**:
- Gap 1.1 (SDD) — Estructura formal de Spec-Driven Development
- Gap 1.2 (Decision Log) — Trazabilidad de decisiones
- Gap 2.2 (Scratchpad) — Persistencia real entre sesiones
- Gap 2.3 (Context metrics) — Monitoreo de uso de contexto
- Gap 3.4 (Ralph Loop) — Autonomous completion loops

---

## Próximos Pasos

1. Revisar este plan con el equipo
2. Priorizar las mejoras P0 y P1
3. Ejecutar el skill `/multi-agent-workflow:source-report` para obtener el informe completo de fuentes
4. Iterar sobre las recomendaciones basándose en el informe de fuentes

---

*Generado el 2026-02-19 usando investigación de 30+ fuentes de la industria.*
*Usar `/multi-agent-workflow:source-report` para ver el informe detallado de fuentes.*
