# Análisis del Plan vs. Mejores Prácticas Actuales

> Revisión del plan completo (`plan.md`, 1401 líneas) con investigación de las últimas prácticas recomendadas.

---

## Lo que el plan hace bien

El plan ya incorpora varios conceptos sólidos:

- **Planificación primero (80/20)** — alineado con lo que recomienda Addy Osmani
- **Persistencia incremental** — protege contra interrupciones
- **Quality Gates con iteración acotada** — evita loops infinitos
- **Análisis de integración** — mentalidad de extensión vs. aislamiento
- **SOLID como constraint obligatorio en Phase 3**

---

## Mejoras recomendadas basadas en mejores prácticas 2025-2026

### 1. Falta un Patrón de Reflexión (Reflection Pattern)

El plan tiene Quality Gates, pero son checks estáticos. Las mejores prácticas de agentic workflows recomiendan que el agente **revise críticamente su propio output** antes de validar, no solo que verifique una checklist.

**Mejora concreta:** Añadir un paso de "auto-crítica" en cada Quality Gate donde el agente cambia de rol (de "planificador" a "revisor crítico") y busca debilidades, suposiciones no validadas, y gaps lógicos antes de aplicar los checks formales.

---

### 2. Sin Feedback Loop ni Aprendizaje

El plan es un proceso lineal sin retroalimentación. Según Microsoft Engineering y OpenAI Cookbook, los mejores workflows capturan qué funcionó y qué no para mejorar iteraciones futuras.

**Mejora concreta:** Añadir un archivo `99_retrospective.md` post-planificación que capture:

- Decisiones que fueron revisadas o rechazadas por el usuario
- Patterns que funcionaron bien
- Gaps que se descubrieron tarde en el proceso

Esto alimenta un "organic configuration" como recomienda la comunidad de agentic engineering.

---

### 3. Ausencia de Chunking Explícito para el Agente

Osmani enfatiza que los LLMs fallan con outputs monolíticos. El plan pide generar archivos enteros de una vez (specs, solutions, tasks). No hay guía sobre limitar el scope de cada prompt/generación.

**Mejora concreta:** Añadir directivas de "max chunk size" en cada fase. Por ejemplo: *"Si hay más de 5 specs, generar en grupos de 3, verificar cada grupo, y luego consolidar."* Esto previene el anti-patrón de "jumbled mess".

---

### 4. Falta Validación con Testing Temprano

El plan diseña soluciones (Phase 3) y tareas (Phase 4) pero los tests solo aparecen como "Tests to Write FIRST" dentro de cada task. No hay validación de que las specs sean testeables a nivel de contrato antes de llegar a implementación.

**Mejora concreta:** Añadir en Phase 2 un sub-paso de **"Test Contract Sketch"** donde se bosquejan los tests de aceptación principales. Según investigaciones recientes (CodeSIM, RTADev), validar con simulaciones input/output temprano reduce errores significativamente.

---

### 5. Sin Estrategia de Right-Sizing del Modelo

Las mejores prácticas de UiPath y Google Cloud recomiendan usar modelos grandes para razonamiento complejo y modelos pequeños para clasificación/routing.

**Mejora concreta:** En el Planning Depth Resolution, añadir recomendaciones de qué modelo usar por fase:

| Fase | Modelo recomendado | Razón |
|---|---|---|
| Phase 1 (Understand) | Modelo grande | Razonamiento |
| Phase 2 (Specs) | Modelo grande | Creatividad + estructura |
| Quality Gates | Modelo pequeño rápido | Verificación |
| Phase 4 (Tasks) | Modelo mediano | Templating |

---

### 6. El "Human-in-the-Loop" es débil

El plan solo consulta al usuario en Phase 1 (si confidence < 60%) y al final (Step 4 de Completeness). Según Parseur, Permit.io, y el paradigma emergente de "Human Above the Loop", los checkpoints humanos deben estar en **decisiones de alto riesgo**, no solo al inicio y final.

**Mejora concreta:** Añadir un checkpoint HITL obligatorio entre Phase 2 y Phase 3 (*"¿Las specs capturan lo que quieres?"*) y otro entre Phase 3 y Phase 4 (*"¿El diseño técnico te parece correcto?"*). Esto evita que el plan avance 4 fases para descubrir al final que las specs estaban mal.

---

### 7. Sin Consideración de Seguridad Explícita

El plan menciona SOLID exhaustivamente pero no tiene un paso dedicado a seguridad. OWASP y las mejores prácticas de AWS recomiendan threat modeling como parte del diseño.

**Mejora concreta:** Añadir en Phase 3 un sub-paso **"Security Threat Analysis"** que identifique:

- Superficie de ataque de la nueva feature
- Validación de inputs en boundaries
- Autenticación/autorización requerida
- Datos sensibles involucrados

---

### 8. El Scoring SOLID es Rígido y Potencialmente Artificial

Pedir un score numérico de SOLID (22/25) a un LLM puede generar "gaming" donde el agente simplemente se auto-asigna puntuaciones altas. Según LangChain's State of Agent Engineering, las evaluaciones de agentes deben usar rúbricas o LLM-as-judge, no auto-evaluación con score numérico.

**Mejora concreta:** Cambiar de auto-scoring a un enfoque de **"SOLID Justification"** donde el agente debe justificar textualmente cada principio aplicado con referencia a código/archivos concretos, y el usuario o un segundo agente valida. El score numérico puede mantenerse como resumen, pero la justificación es lo que realmente importa.

---

### 9. Falta Observabilidad y Trazabilidad

El `50_state.md` es un buen inicio, pero no registra decisiones tomadas ni alternativas descartadas. Según Qodo y la tendencia de "Attribution-Based Review", cada decisión debe ser trazable.

**Mejora concreta:** Añadir un "Decision Log" en `50_state.md` o un archivo separado `51_decisions.md`:

| Decision | Alternatives Considered | Rationale | Phase |
|----------|------------------------|-----------|-------|
| ... | ... | ... | ... |

---

### 10. Sin Estrategia de Rollback/Recovery

El Incremental Persistence Protocol escribe archivos, pero no hay guía sobre qué hacer si una fase produce resultados incorrectos y hay que volver atrás.

**Mejora concreta:** Añadir un protocolo de rollback: *"Si el Quality Gate de Phase N falla después de 3 iteraciones, el usuario puede decidir volver a Phase N-1 y revisar los supuestos."*

---

## Resumen de prioridad

| # | Mejora | Impacto | Esfuerzo |
|---|--------|---------|----------|
| 6 | HITL entre fases | Alto | Bajo |
| 1 | Reflection Pattern | Alto | Medio |
| 4 | Test Contract Sketch | Alto | Medio |
| 8 | SOLID Justification vs auto-score | Alto | Bajo |
| 9 | Decision Log / Trazabilidad | Medio | Bajo |
| 2 | Feedback Loop / Retrospectiva | Medio | Bajo |
| 3 | Chunking explícito | Medio | Bajo |
| 7 | Security Threat Analysis | Medio | Medio |
| 10 | Rollback Protocol | Bajo | Bajo |
| 5 | Right-sizing de modelo | Bajo | Bajo |

---

## Sources

- [Addy Osmani - My LLM coding workflow going into 2026](https://addyosmani.com/blog/llm-coding-workflow/)
- [ByteByteGo - Top AI Agentic Workflow Patterns](https://bytebytego.com/)
- [Google Cloud - Choose a design pattern for agentic AI](https://cloud.google.com/architecture)
- [AWS - Agentic AI patterns](https://aws.amazon.com/architecture/)
- [Microsoft - AI Agent Orchestration Patterns](https://learn.microsoft.com/)
- [UiPath - 10 best practices for building reliable AI agents](https://www.uipath.com/)
- [Microsoft Engineering - AI-Powered Code Reviews](https://devblogs.microsoft.com/)
- [LangChain - State of Agent Engineering](https://www.langchain.com/)
- [Permit.io - HITL for AI Agents Best Practices](https://www.permit.io/)
- [Diginomica - From human-in-the-loop to humans-above-the-loop](https://diginomica.com/)
- [Qodo - 5 AI Code Review Pattern Predictions 2026](https://www.qodo.ai/)
- [arXiv - Production-Grade Agentic AI Workflows](https://arxiv.org/)
- [Digital Applied - Practical Agentic Engineering Workflow 2025](https://digitalapplied.com/)
