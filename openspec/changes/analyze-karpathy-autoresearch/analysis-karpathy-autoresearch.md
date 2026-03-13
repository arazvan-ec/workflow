# Análisis: Patrones de Autoresearch de Karpathy → Mejoras para el Plugin

**Fecha**: 2026-03-13
**Versión del plugin**: 3.2.0
**Fuente**: Autoresearch de Andrej Karpathy (~630 líneas de Python)

---

## 1. Resumen de Autoresearch

Autoresearch es un script de ~630 líneas que permite a agentes LLM ejecutar experimentos de ML de forma autónoma en una sola GPU. Su filosofía: **"One GPU, one file, one metric."**

### Ciclo del agente

```
program.md (dirección humana)
    ↓
PROPOSE → EXECUTE (5 min) → EVALUATE (val_bpb) → DECIDE (keep/revert)
    ↑                                                      ↓
    └──────────── ITERATE (siguiente experimento) ←────────┘
```

### Principios de diseño clave

| # | Principio | Descripción |
|---|-----------|-------------|
| 1 | **Codebase-in-context** | 630 líneas = cabe entero en la ventana de contexto del LLM |
| 2 | **Fixed vs. Editable split** | `prepare.py` (inmutable) vs `train.py` (editable por el agente) |
| 3 | **Bounded execution** | Cada experimento = exactamente 5 minutos, coste de fallo predecible |
| 4 | **Single metric** | `val_bpb` — sin ambigüedad sobre qué es "mejor" |
| 5 | **Git como memoria** | Cada éxito se commitea, los fallos se revierten |
| 6 | **Error → Context → Retry** | Errores se alimentan de vuelta al LLM como contexto |
| 7 | **Human sets direction, agent iterates** | `program.md` define QUÉ investigar; el agente decide CÓMO |
| 8 | **Automatic rollback** | Fallos no se acumulan; se restaura el estado anterior |

### Resultados

- ~12 experimentos/hora, ~100 overnight
- Shopify CEO: 37 experimentos overnight, modelo 0.8B superó al 1.6B manual
- Karpathy: 700 experimentos en 2 días, encontró bugs que él no vio en años
- 20 mejoras apiladas: "Time to GPT-2" bajó de 2.02h a 1.80h (~11%)

---

## 2. Mapeo: Patrones de Autoresearch → Oportunidades para el Plugin

### 2.1 — Bounded Execution Windows (tiempo fijo por experimento)

**Patrón autoresearch**: Cada experimento = 5 minutos exactos. Coste de fallo constante y predecible.

**Estado actual del plugin**: BCP usa conteo de iteraciones (simple:5, moderate:10, complex:15) pero no tiene límites de tiempo.

**Idea de mejora**: Añadir **time-boxing por tarea** al BCP.
- Cada tarea podría tener un `max_duration` además de `max_iterations`
- Si una tarea excede el tiempo, se fuerza checkpoint + escalación (similar a cuando se agotan iteraciones)
- Beneficio: previene "rabbit holes" donde el agente itera durante 30+ minutos en un solo error

**Evaluación** (framework_rules §Governance):
| Criterio | Puntuación |
|----------|-----------|
| Solves a real problem | 4/5 — rabbit holes son comunes |
| Proven in production | 4/5 — autoresearch lo demuestra |
| Integrates with our system | 5/5 — encaja directamente en BCP |
| Benefit vs complexity | 4/5 — implementación simple |
| Maintainable | 5/5 — un timer |
| **Media ponderada** | **4.3/5** ✅ |

---

### 2.2 — Single Metric per Task (métrica única y no ambigua)

**Patrón autoresearch**: `val_bpb` es LA única métrica. Sin subjetividad.

**Estado actual del plugin**: Las tareas tienen "acceptance criteria" que pueden ser múltiples y heterogéneos (test pass, coverage %, SOLID compliance, manual checks).

**Idea de mejora**: Introducir un **"primary success signal"** por tarea.
- Cada tarea en `tasks.md` define UN criterio primario que es el gate real
- Los demás criterios son secundarios (deseable pero no bloqueante)
- Simplifica la lógica del Goal-Backward Verification (Step 7)
- Ejemplo: `primary_signal: "tests pass"` vs `secondary: ["coverage >80%", "SOLID compliant"]`

**Evaluación**:
| Criterio | Puntuación |
|----------|-----------|
| Solves a real problem | 3/5 — a veces hay ambigüedad en "done" |
| Proven in production | 4/5 — principio universal de SRE/ML |
| Integrates with our system | 4/5 — extiende tasks.md |
| Benefit vs complexity | 4/5 — clarifica el flujo de decisión |
| Maintainable | 5/5 — campo adicional en template |
| **Media ponderada** | **3.8/5** ✅ |

---

### 2.3 — Fixed vs. Editable Scope (separación inmutable/mutable)

**Patrón autoresearch**: `prepare.py` nunca se toca. `train.py` es lo único editable. Previene que el agente desestabilice la infraestructura core.

**Estado actual del plugin**: El plugin tiene Baseline Freeze (openspec/specs/ es read-only) y permisos por rol. Pero no hay una demarcación explícita de "archivos que el implementer NUNCA debe tocar" a nivel de tarea.

**Idea de mejora**: Añadir **"frozen files"** al diseño de cada feature.
- En `design.md` o `tasks.md`, listar explícitamente archivos que son OFF-LIMITS durante work
- El implementer verifica contra esta lista antes de editar
- Complementa el Baseline Freeze existente pero a nivel de código fuente

**Evaluación**:
| Criterio | Puntuación |
|----------|-----------|
| Solves a real problem | 4/5 — cambios colaterales son un pain point |
| Proven in production | 5/5 — patrón fundamental de autoresearch |
| Integrates with our system | 4/5 — extiende design.md/tasks.md |
| Benefit vs complexity | 4/5 — lista simple, gran impacto |
| Maintainable | 5/5 — declarativo |
| **Media ponderada** | **4.3/5** ✅ |

---

### 2.4 — Error Context Injection (errores como contexto, no como fallos)

**Patrón autoresearch**: Cuando un experimento falla (CUDA OOM, shape mismatch, NaN loss), el error se inyecta al LLM como contexto para la siguiente iteración. No hay handlers hardcoded.

**Estado actual del plugin**: El BCP clasifica errores en 3 tipos de desviación (test failure, missing functionality, incomplete pattern) y aplica fixes. El diagnostic-agent se invoca tras 3 errores consecutivos idénticos.

**Idea de mejora**: **Structured error accumulator** en el scratchpad.
- En lugar de solo contar iteraciones, acumular un log estructurado de errores+intentos
- Cada iteración del BCP añade: `{error, hypothesis, fix_attempted, result}`
- Este log se pasa completo al diagnostic-agent (no solo el último error)
- Beneficio: el diagnostic-agent tiene TODO el contexto de intentos previos, no adivina

**Evaluación**:
| Criterio | Puntuación |
|----------|-----------|
| Solves a real problem | 5/5 — diagnostic-agent con contexto parcial es menos útil |
| Proven in production | 4/5 — autoresearch lo demuestra a escala |
| Integrates with our system | 5/5 — extiende scratchpad.md existente |
| Benefit vs complexity | 4/5 — estructura simple, impacto alto |
| Maintainable | 4/5 — crece con cada iteración pero se limpia por feature |
| **Media ponderada** | **4.5/5** ✅ — **prioridad más alta** |

---

### 2.5 — Git como Memoria del Agente (commits = memoria persistente)

**Patrón autoresearch**: Cada experimento exitoso → git commit. Historia de commits = memoria persistente del agente. Permite rollback y análisis post-hoc.

**Estado actual del plugin**: El checkpoint system ya commitea con git. Pero los mensajes de commit son genéricos y no capturan "qué se aprendió" del checkpoint.

**Idea de mejora**: **Learning-annotated commits**.
- Extender commit-formatter para incluir una línea de "learning" en cada checkpoint commit
- Formato: `[checkpoint] Task X complete | Learning: {insight breve}`
- El compound step puede luego minar estos commits para extraer patrones
- Beneficio: compound tiene datos más ricos sin esfuerzo adicional durante work

**Evaluación**:
| Criterio | Puntuación |
|----------|-----------|
| Solves a real problem | 3/5 — compound ya captura learnings |
| Proven in production | 4/5 — git-as-memory es core de autoresearch |
| Integrates with our system | 5/5 — extiende commit-formatter existente |
| Benefit vs complexity | 3/5 — beneficio incremental |
| Maintainable | 5/5 — una línea extra por commit |
| **Media ponderada** | **3.7/5** ✅ (borderline) |

---

### 2.6 — Automatic Rollback on Failure (reversión automática)

**Patrón autoresearch**: Fallos no se acumulan. Si un experimento falla, se restaura el estado anterior automáticamente, y el siguiente experimento parte de un estado limpio.

**Estado actual del plugin**: El Rollback Protocol existe (framework_rules.md) pero es manual — requiere que el implementer decida hacer rollback y ejecute los pasos. El BCP intenta corregir en lugar de revertir.

**Idea de mejora**: **Auto-rollback after BCP exhaustion**.
- Cuando el BCP agota iteraciones en una tarea, en lugar de solo marcar BLOCKED, automáticamente:
  1. `git stash` los cambios fallidos
  2. Restaurar al último checkpoint verde
  3. Documentar el intento en scratchpad
  4. Intentar la tarea con un enfoque diferente (informed by error accumulator de 2.4)
- Solo marcar BLOCKED si el segundo intento también falla

**Evaluación**:
| Criterio | Puntuación |
|----------|-----------|
| Solves a real problem | 4/5 — BLOCKED manual pierde momentum |
| Proven in production | 5/5 — core de autoresearch |
| Integrates with our system | 4/5 — extiende BCP y Rollback Protocol |
| Benefit vs complexity | 3/5 — lógica de "segundo intento" es moderada |
| Maintainable | 4/5 — requiere testing cuidadoso |
| **Media ponderada** | **4.0/5** ✅ |

---

### 2.7 — Human Direction File (program.md)

**Patrón autoresearch**: El humano escribe `program.md` con la dirección de investigación. El agente lo lee y ejecuta. Separación clara de responsabilidades.

**Estado actual del plugin**: El routing + proposal ya cumplen esta función. El humano define QUÉ en la routing/proposal, el agente planifica y ejecuta.

**Idea de mejora**: Ninguna necesaria — **el plugin ya implementa este patrón** de forma más sofisticada (routing → proposal → specs → design → tasks es un program.md con esteroides).

**Evaluación**: N/A — patrón ya cubierto.

---

### 2.8 — Codebase-in-Context (todo cabe en la ventana)

**Patrón autoresearch**: 630 líneas = el agente puede leer TODO el código relevante. Sin "blind spots".

**Estado actual del plugin**: El plugin usa context: fork para aislar agentes pesados. Pero no hay una métrica de "cuánto del codebase relevante puede ver el agente para esta tarea".

**Idea de mejora**: **Context coverage metric** por tarea.
- En tasks.md, cada tarea lista los archivos relevantes (ya existe como "Reference files")
- Añadir una estimación de tokens de esos archivos
- Si la suma excede un umbral (ej. 60% de la ventana), la tarea debería usar per-task isolation
- Beneficio: decisión automática de cuándo usar `--isolation=task`

**Evaluación**:
| Criterio | Puntuación |
|----------|-----------|
| Solves a real problem | 3/5 — context rot es conocido pero manejable |
| Proven in production | 4/5 — principio fundamental de autoresearch |
| Integrates with our system | 4/5 — extiende task isolation existente |
| Benefit vs complexity | 3/5 — estimación de tokens es imprecisa |
| Maintainable | 3/5 — heurística que requiere tuning |
| **Media ponderada** | **3.3/5** ❌ (bajo umbral de 3.5) |

---

## 3. Ranking de Ideas por Prioridad

| Rank | Idea | Puntuación | Esfuerzo | Impacto |
|------|------|-----------|----------|---------|
| 1 | **Error Context Injection** (2.4) | 4.5 | Bajo | Alto |
| 2 | **Frozen Files** (2.3) | 4.3 | Bajo | Alto |
| 3 | **Bounded Time per Task** (2.1) | 4.3 | Bajo | Medio-Alto |
| 4 | **Auto-rollback after BCP** (2.6) | 4.0 | Medio | Alto |
| 5 | **Primary Success Signal** (2.2) | 3.8 | Bajo | Medio |
| 6 | **Learning-annotated Commits** (2.5) | 3.7 | Bajo | Bajo-Medio |
| 7 | ~~Context Coverage Metric (2.8)~~ | 3.3 | Medio | Bajo |

---

## 4. Ideas Rápidas Adicionales (sin evaluación formal)

### 4.a — "Experiment Mode" para work

Inspirado en el throughput de autoresearch (12 exp/hora), crear un modo experimental para tareas donde hay múltiples enfoques posibles:
- El agente prueba N enfoques diferentes en paralelo (usando subagents)
- Cada uno tiene un time-box corto
- Se queda con el que pase tests + mejor métrica
- **Aplicabilidad**: refactors complejos, optimizaciones de performance

### 4.b — Overnight/Batch Mode

Autoresearch brilla ejecutando sin supervisión. El plugin podría tener un modo batch:
- Cola de features planificadas
- Ejecuta work → review automáticamente
- Humano revisa resultados por la mañana
- **Requiere**: alto nivel de confianza en tests + review automatizado

### 4.c — Dot-Plot Progress Visualization

Autoresearch usa dot-plots para visualizar tendencias. El plugin podría visualizar:
- BCP iterations por feature (trend de mejora)
- Tiempo por tarea (identificar cuellos de botella)
- Compound learnings applied vs. new issues found

---

## 5. Síntesis: Principio Unificador

El patrón más profundo de autoresearch que el plugin debería absorber es:

> **"Cheap failures enable broad exploration."**

Autoresearch es efectivo porque cada fallo cuesta exactamente 5 minutos y se revierte limpiamente. El plugin actual trata los fallos como excepciones a gestionar (BCP, BLOCKED, escalación). La visión de autoresearch sugiere tratar los fallos como **información barata** que alimenta la siguiente iteración.

### Cambio filosófico propuesto

| Actual | Propuesto (inspirado por autoresearch) |
|--------|---------------------------------------|
| Fallo → intentar corregir → BLOCKED | Fallo → acumular contexto → rollback → re-intentar con contexto completo |
| BCP cuenta iteraciones | BCP cuenta iteraciones + tiempo |
| Diagnostic-agent ve último error | Diagnostic-agent ve historial completo de errores |
| Rollback es manual y excepcional | Rollback es automático y normal |
| "Frozen files" implícito por roles | "Frozen files" explícito por tarea |

---

## 6. Próximos Pasos Recomendados

1. **Prioridad 1**: Implementar "Error Context Injection" en scratchpad.md + BCP (idea 2.4)
2. **Prioridad 2**: Añadir "Frozen Files" a design.md template (idea 2.3)
3. **Prioridad 3**: Añadir time-boxing al BCP en testing-rules.md (idea 2.1)
4. **Prioridad 4**: Auto-rollback tras BCP exhaustion (idea 2.6)
5. **Evaluar después**: Primary success signal (2.2) y learning-annotated commits (2.5)

---

## Fuentes

- [MarkTechPost: Karpathy Open-Sources Autoresearch](https://www.marktechpost.com/2026/03/08/andrej-karpathy-open-sources-autoresearch-a-630-line-python-tool-letting-ai-agents-run-autonomous-ml-experiments-on-single-gpus/)
- [Ken Huang: Exploring Autoresearch](https://kenhuangus.substack.com/p/exploring-andrej-karpathys-autoresearch)
- [Firethering: Shopify CEO and Autoresearch](https://firethering.com/karpathy-autoresearch-ai-agent/)
- [Jangwook: 100 Autonomous ML Experiments Overnight](https://jangwook.net/en/blog/en/karpathy-autoresearch-overnight-ml-experiments/)
- [ABHS.in: Autoresearch Explained](https://www.abhs.in/blog/andrej-karpathy-autoresearch-autonomous-ai-ml-experiments-2026)
- [AIM: Karpathy Builds AI Research System](https://analyticsindiamag.com/ai-news/in-630-lines-of-code-andrej-karpathy-builds-ai-research-system-running-on-a-single-gpu)
