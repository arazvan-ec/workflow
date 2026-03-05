# Mejores Prácticas de la Industria — Herramientas Similares y Patrones 2025-2026

**Fecha**: 2026-03-05
**Metodología**: Investigación web de fuentes de la industria (Anthropic, Microsoft, Google, AWS, Thoughtworks, etc.)

---

## 1. Spec-Driven Development (SDD) — El Paradigma Dominante

### Qué dice la industria

SDD se ha consolidado como el paradigma dominante para desarrollo asistido por IA en 2025-2026. El flujo estándar es: **Specify → Plan → Tasks → Implement**.

> "La calidad del output de IA correlaciona directamente con el detalle y claridad de la especificación." — Thoughtworks, 2025

### Herramientas comparables

| Herramienta | Flujo | Fortaleza | Debilidad |
|------------|-------|-----------|-----------|
| **GitHub Spec Kit** | CLI + templates: spec → plan → tasks → implement | Open-source, funciona con cualquier agente (Claude Code, Copilot, Cursor) | Overkill para cambios pequeños, requiere workaround `/speckit.clarify` |
| **AWS Kiro** | IDE (VS Code fork): Requirements → Design → Tasks | Specs formales integradas en IDE, deep AWS integration | No apto para cambios triviales, pricing GA ($19-39/mo) |
| **JetBrains Junie** | Spec-driven approach integrado en JetBrains IDEs | Nativo en ecosistema JetBrains | Ligado al ecosistema JetBrains |
| **BMAD Method** | Similar a nuestro flujo con roles especializados | Soporte brownfield maduro | Menos flexible que workflow-agnostic |
| **OpenSpec** | Especificaciones estructuradas en markdown | Compatible con múltiples agentes | Ecosistema más pequeño |
| **Tessl** | Auto-generación de specs desde codebase existente | Excelente para brownfield | Menos control manual |

### Qué hace bien nuestro plugin vs. la industria

| Aspecto | Nuestro plugin | Industria | Veredicto |
|---------|---------------|-----------|-----------|
| Flujo faseado | ROUTE→SHAPE→PLAN→WORK→REVIEW→COMPOUND | Specify→Plan→Tasks→Implement | **Superior** — tenemos más fases (shape, compound) |
| Artefactos por feature | proposal, specs, design, tasks | spec, plan, tasks | **Superior** — separamos WHAT (specs) de HOW (design) |
| Routing inteligente | `/workflows:route` clasifica antes de actuar | Manual (usuario decide) | **Superior** — automatizado |
| Compound learning | Feature N informa feature N+1 | No existe en la mayoría | **Superior** — innovación diferenciadora |
| Quick mode | `/workflows:quick` para tasks simples | No existe (sledgehammer problem) | **Superior** — resuelve el "sledgehammer to crack a nut" |

### Dónde nos quedamos cortos

| Aspecto | Nuestro plugin | Industria | Brecha |
|---------|---------------|-----------|--------|
| Context budget | CLAUDE.md + framework_rules ~671 líneas always-loaded | Recomendación: < 200 líneas en CLAUDE.md | **Brecha MEDIA** |
| Test contracts tempranos | Tests solo en Phase 4 (tasks) | Test Contract Sketch en Phase 2 (specs) | **Brecha ALTA** |
| Verificación cruzada | Sin self-review antes de entregar | Reflection pattern estándar en 2026 | **Brecha ALTA** |
| Tamaño para cambios pequeños | Incluso quick.md es 210 líneas | Agentes simples en < 50 líneas | **Brecha BAJA** |

### Fuentes
- [Thoughtworks: Spec-Driven Development (2025)](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [Martin Fowler: SDD Tools (Kiro, Spec Kit, Tessl)](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [GitHub Blog: Spec Kit toolkit](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [JetBrains: Spec-Driven Approach for AI](https://blog.jetbrains.com/junie/2025/10/how-to-use-a-spec-driven-approach-for-coding-with-ai/)
- [Red Hat: SDD and Quality (Oct 2025)](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality)
- [AWS Kiro](https://kiro.dev/)
- [Addy Osmani: LLM coding workflow into 2026](https://addyosmani.com/blog/ai-coding-workflow/)
- [Addy Osmani: How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/)
- [spec-compare: 6 SDD tools comparison](https://github.com/cameronsjo/spec-compare)

---

## 2. Patrones de Orquestación Multi-Agente

### Patrones clave validados (2025-2026)

| Patrón | Descripción | Relevancia para nosotros |
|--------|-------------|--------------------------|
| **Hub-and-Spoke** | Orquestador central gestiona todos los agentes | Ya lo hacemos (route como hub) |
| **Hierarchical** | Agentes de alto nivel supervisan equipos de workers | Parcialmente (planner → implementer) |
| **Sequential Pipeline** | Estado compartido pasado de agente a agente | Ya lo hacemos (tasks.md como state) |
| **Feedback Loops** | Un agente revisa el output de otro | Parcialmente (review, pero sin feedback a plan) |
| **Plan-and-Execute** | Modelo grande planifica, modelos pequeños ejecutan | No implementado (todo usa mismo modelo) |
| **Reflection** | Auto-revisión antes de entregar | **No implementado** — brecha principal |
| **Generator-Evaluator** | Un LLM genera, otro evalúa en loop iterativo | Parcialmente (BCP es correctivo, no evaluativo) |

### Protocolos de interoperabilidad emergentes

| Protocolo | Por | Propósito |
|-----------|-----|-----------|
| **MCP** | Anthropic | Acceso estandarizado a herramientas y recursos externos |
| **A2A** | Google | Colaboración peer-to-peer entre agentes |
| **ACP** | IBM | Governance y compliance para enterprise |

Nuestro plugin ya soporta MCP (via mcp-connector skill).

### Tendencias clave 2026
- Gartner predice 40% de enterprise apps con agentes IA embebidos para fin de 2026
- Multi-agent > single-agent para tareas complejas (Anthropic reporta hasta 15x más tokens pero mejor calidad)
- Cost optimization de agentes es concern de primera clase (como cloud cost optimization)
- Human-on-the-loop (supervisión) reemplaza human-in-the-loop (aprobación) para tareas de bajo riesgo

### Fuentes
- [Deloitte: AI Agent Orchestration (2026)](https://www.deloitte.com/us/en/insights/industry/technology/technology-media-and-telecom-predictions/2026/ai-agent-orchestration.html)
- [Anthropic: 2026 Agentic Coding Trends Report](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf)
- [Google ADK: Multi-agent patterns](https://developers.googleblog.com/developers-guide-to-multi-agent-patterns-in-adk/)
- [Codebridge: Multi-Agent Orchestration Guide 2026](https://www.codebridge.tech/articles/mastering-multi-agent-orchestration-coordination-is-the-new-scale-frontier)
- [OnAbout: Multi-Agent Enterprise Strategy 2025-2026](https://www.onabout.ai/p/mastering-multi-agent-orchestration-architectures-patterns-roi-benchmarks-for-2025-2026)
- [SitePoint: Agentic Design Patterns 2026](https://www.sitepoint.com/the-definitive-guide-to-agentic-design-patterns-in-2026/)

---

## 3. Context Engineering — La Disciplina que Reemplaza al Prompt Engineering

### Principios clave de Anthropic

1. **Minimizar tokens — solo high-signal**: "Good context engineering means finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."
2. **System prompt a la "altitud correcta"**: Ni demasiado rígido (brittle) ni demasiado vago
3. **Combatir context rot**: Degradación de precisión cuando el context window se llena
4. **Persistencia externa (scratchpads y archivos)**: No forzar al modelo a recordar todo
5. **Multi-agente para tareas complejas**: Contextos aislados > contexto monolítico
6. **Harnesses para agentes de larga duración**: `claude-progress.txt` + git history para resumir estado

### Mejores prácticas para CLAUDE.md (2026)

| Práctica | Fuente | Nuestro estado |
|----------|--------|---------------|
| CLAUDE.md < 200 líneas | HumanLayer, Claude Code docs | **~300 líneas** — por encima |
| "Para cada línea, pregunta: ¿eliminarla causaría errores?" | HumanLayer | No aplicado formalmente |
| Context estable en CLAUDE.md, dinámico en conversación | Claude Code Best Practices | Ya lo hacemos (Context Activation Model) |
| Múltiples CLAUDE.md para monorepos | Claude Code docs | N/A (single repo) |
| Skills como "knowledge packs" con progressive disclosure | Anthropic | Ya lo hacemos (skills con frontmatter) |

### Recomendaciones aplicables

| # | Recomendación | Impacto |
|---|--------------|---------|
| 1 | Reducir CLAUDE.md a < 200 líneas (mover detalles a docs/) | ALTO |
| 2 | Implementar scratchpad real per-feature (ya existe template) | MEDIO |
| 3 | Documentar peso en tokens de cada capa de contexto | BAJO |
| 4 | Considerar `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50` para sesiones largas | BAJO |

### Fuentes
- [Anthropic: Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Claude Code Best Practices (Official)](https://code.claude.com/docs/en/best-practices)
- [FlowHunt: Context Engineering 2025 Guide](https://www.flowhunt.io/blog/context-engineering/)
- [Inkeep: Fighting Context Rot](https://inkeep.com/blog/fighting-context-rot)
- [01.me: Context Engineering Secrets from Anthropic](https://01.me/en/2025/12/context-engineering-from-claude/)

---

## 4. Reflection Pattern — El Gap Principal

### Estado del arte (2026)

El Reflection Pattern se ha convertido en uno de los 6 patrones canónicos de diseño agentic. Es el mecanismo por el cual un agente revisa y mejora su propio output antes de entregarlo.

**Ciclo**: Generate → Critique → Revise → (repeat if needed)

### Implementaciones en la industria

| Implementación | Cómo funciona |
|----------------|--------------|
| **CodeScene** | Analiza output contra métricas de code health antes de entregar |
| **Qodo** | Specialist agents (correctness, security, performance) revisan en paralelo |
| **Scott Logic A-I-R** | Analysis → Implementation → Reflection — harness para evaluar calidad |
| **SitePoint patterns** | Generator-Evaluator loop con criterios explícitos |

### Cómo aplicarlo a nuestro plugin

| Punto de inserción | Qué haría | Esfuerzo |
|-------------------|-----------|----------|
| Quality Gates en plan.md | Antes de checklist formal: self-review con preguntas críticas | BAJO |
| Checkpoint en work.md | Antes de git commit: "¿mi código cumple los acceptance criteria?" | BAJO |
| Review agents | Ya usan specialist agents (alineado con Qodo pattern) | YA EXISTE |
| Compound | Retrospectiva: "¿qué debilidades tenía mi output?" | MEDIO |

### Fuentes
- [CodeScene: Agentic AI Coding Best Practice Patterns](https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality)
- [Qodo: 5 AI Code Review Pattern Predictions 2026](https://www.qodo.ai/blog/5-ai-code-review-pattern-predictions-in-2026/)
- [Scott Logic: Analysis-Implementation-Reflection technique](https://blog.scottlogic.com/2026/03/05/analysis-implementation-reflection-practical-techniques.html)
- [QAT: The Reflection Pattern](https://qat.com/reflection-pattern-ai/)
- [HuggingFace: Test-Time Reasoning and Reflective Agents](https://huggingface.co/blog/aufklarer/ai-trends-2026-test-time-reasoning-reflective-agen)
- [MIT Missing Semester: Agentic Coding 2026](https://missing.csail.mit.edu/2026/agentic-coding/)

---

## 5. Ecosistema de Plugins Claude Code (2026)

### Plugins y workflows comparables

| Plugin/Workflow | Skills | Agentes | Enfoque |
|----------------|--------|---------|---------|
| **Nuestro plugin (workflow)** | 15 | 8 | Compound engineering, SDD, SOLID |
| **claude-code-plugins-plus-skills** | 739 | 270+ plugins | Mega-colección, package manager (CCPI) |
| **wshobson/agents** | 146 | 112 | Automatización + orquestación multi-agente |
| **shinpr/claude-code-workflows** | — | — | Workflows production-ready |
| **ComposioHQ Awesome Plugins** | — | — | Registro curado de plugins |
| **Superpowers** | — | — | TDD, debugging, code review |
| **Local-Review** | — | — | Parallel diff reviews multi-agente |

### Diferenciadores de nuestro plugin

1. **Compound learning** — Único en el ecosistema. Nadie más tiene feedback loop automático entre features
2. **SOLID como constraint** — Enforcement arquitectónico durante diseño (no solo review)
3. **Shape Up integrado** — Separación problema/solución antes de planning
4. **Model-agnostic providers** — Auto-detección de capabilities según modelo
5. **Governance (control-plane)** — Risk tiers y docs drift enforcement

### Tendencias en plugins 2026
- Progressive disclosure: cargar contexto bajo demanda, no todo al inicio
- Skills como "knowledge packs" descubribles por frontmatter
- Writer/Reviewer pattern con sesiones separadas
- Subagentes para research (contexto aislado, solo resumen vuelve)

### Fuentes
- [Composio: 10 Top Claude Code Plugins 2026](https://composio.dev/blog/top-claude-code-plugins)
- [Morph: Claude Code Best Practices 2026](https://www.morphllm.com/claude-code-best-practices)
- [ProductTalk: How to Use Claude Code Features](https://www.producttalk.org/how-to-use-claude-code-features/)
- [Trail of Bits: claude-code-config](https://github.com/trailofbits/claude-code-config)
- [shanraisshan: Claude Code Best Practice](https://github.com/shanraisshan/claude-code-best-practice)

---

## 6. Resumen: Top 10 Recomendaciones Basadas en la Industria

| # | Recomendación | Fuente principal | Impacto | Esfuerzo |
|---|--------------|-----------------|---------|----------|
| 1 | Implementar Reflection Pattern en Quality Gates | CodeScene, Qodo, SitePoint | ALTO | BAJO |
| 2 | Añadir Test Contract Sketch en Phase 2 (specs) | SoftwareSeni, Versent | ALTO | MEDIO |
| 3 | Reducir CLAUDE.md a < 200 líneas | HumanLayer, Anthropic | ALTO | MEDIO |
| 4 | Feedback loop REVIEW → PLAN para problemas de diseño | Microsoft, Ciklum | MEDIO | BAJO |
| 5 | Security analysis en Phase 3 (diseño) | OWASP, CodeScene | MEDIO | MEDIO |
| 6 | Reducir archivos más grandes (discover.md, compound.md) | Anthropic context engineering | MEDIO | ALTO |
| 7 | Plan-and-Execute: modelo grande planifica, pequeño ejecuta | Google ADK, UiPath | MEDIO | BAJO (solo recomendación) |
| 8 | Chunking: dividir outputs grandes en partes verificables | Addy Osmani | BAJO | BAJO |
| 9 | HITL progresivo: human-on-the-loop para bajo riesgo | Deloitte, Leanware | BAJO | MEDIO |
| 10 | Métricas de context usage por sesión | Anthropic | BAJO | BAJO |

---

## Crédito de Fuentes

### Fuentes de Alta Credibilidad (Official Docs / Major Organizations)
1. [Anthropic: Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — HIGHEST
2. [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — HIGHEST
3. [Anthropic: 2026 Agentic Coding Trends Report](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf) — HIGHEST
4. [Claude Code Best Practices (Official)](https://code.claude.com/docs/en/best-practices) — HIGHEST
5. [Google ADK: Multi-agent patterns](https://developers.googleblog.com/developers-guide-to-multi-agent-patterns-in-adk/) — HIGH
6. [Deloitte: AI Agent Orchestration Predictions 2026](https://www.deloitte.com/us/en/insights/industry/technology/technology-media-and-telecom-predictions/2026/ai-agent-orchestration.html) — HIGH
7. [Thoughtworks: SDD (2025)](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices) — HIGH
8. [Martin Fowler: SDD Tools](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) — HIGH
9. [Red Hat: SDD and Quality](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality) — HIGH
10. [GitHub Blog: Spec Kit](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/) — HIGH

### Fuentes de Credibilidad Media (Industry Reports / Expert Blogs)
11. [Addy Osmani: LLM Coding Workflow 2026](https://addyosmani.com/blog/ai-coding-workflow/) — HIGH (authority)
12. [Addy Osmani: Good Spec for AI Agents](https://addyosmani.com/blog/good-spec/) — HIGH (authority)
13. [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — MEDIUM
14. [CodeScene: Agentic AI Best Practices](https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality) — MEDIUM
15. [Qodo: AI Code Review Predictions 2026](https://www.qodo.ai/blog/5-ai-code-review-pattern-predictions-in-2026/) — MEDIUM
16. [SitePoint: Agentic Design Patterns 2026](https://www.sitepoint.com/the-definitive-guide-to-agentic-design-patterns-in-2026/) — MEDIUM
17. [Codebridge: Multi-Agent Orchestration 2026](https://www.codebridge.tech/articles/mastering-multi-agent-orchestration-coordination-is-the-new-scale-frontier) — MEDIUM
18. [FlowHunt: Context Engineering Guide](https://www.flowhunt.io/blog/context-engineering/) — MEDIUM
19. [Inkeep: Fighting Context Rot](https://inkeep.com/blog/fighting-context-rot) — MEDIUM
20. [MIT Missing Semester: Agentic Coding 2026](https://missing.csail.mit.edu/2026/agentic-coding/) — HIGH (academic)
21. [Scott Logic: A-I-R Technique](https://blog.scottlogic.com/2026/03/05/analysis-implementation-reflection-practical-techniques.html) — MEDIUM
22. [Composio: Top Claude Code Plugins 2026](https://composio.dev/blog/top-claude-code-plugins) — MEDIUM
23. [AWS Kiro](https://kiro.dev/) — HIGH
24. [JetBrains Junie: Spec-Driven AI](https://blog.jetbrains.com/junie/2025/10/how-to-use-a-spec-driven-approach-for-coding-with-ai/) — HIGH
25. [spec-compare: 6 SDD tools](https://github.com/cameronsjo/spec-compare) — MEDIUM

**Total**: 25 fuentes (10 HIGH/HIGHEST, 15 MEDIUM)
**Período**: 2025-2026
**Sin fuentes anteriores a 2025**

---

*Investigación completada el 2026-03-05.*
