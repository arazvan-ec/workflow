# Plan: Hooks vs Rules en Adaptive Flow

## Análisis del estado actual

### Los 4 hooks actuales y qué hacen realmente

| Hook | Trigger deseado | Qué valida |
|------|----------------|------------|
| `pre-work.sh` | Antes de implementar | Que exista un plan en openspec/changes/ |
| `post-plan.sh` | Después de planificar | Que spec.md tenga acceptance criteria, design.md tenga SOLID |
| `pre-commit.sh` | Antes de git commit | Archivos sensibles, tests, lint |
| `post-review.sh` | Después de review | Que QA report tenga verdict y evidence |

### Cómo funcionan los hooks de Claude Code (realidad)

Los hooks de Claude Code se activan por **eventos de herramientas**:

```json
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [{ "matcher": "Bash", "command": "./script.sh" }],
    "PostToolUse": [{ "matcher": "Write", "command": "./script.sh" }],
    "Stop": [{ "command": "./script.sh" }]
  }
}
```

Eventos disponibles: `PreToolUse`, `PostToolUse`, `Notification`, `Stop`, `SubagentStop`

Los hooks reciben contexto via stdin (JSON con tool_name, tool_input, etc.) y:
- Exit 0 → permitir
- Exit 2 → bloquear la acción
- stdout → feedback que Claude lee

### Cómo funcionan las rules de Claude Code

Archivos `.md` en `.claude/rules/` que se cargan al contexto de Claude automáticamente.
Son instrucciones que Claude internaliza. No ejecutan nada — guían el razonamiento.

---

## El problema fundamental

**3 de 4 hooks no mapean a eventos de Claude Code.**

| Hook | ¿Existe evento en Claude Code? | Problema |
|------|-------------------------------|----------|
| `pre-work.sh` | NO — no hay evento "antes de implementar" | ¿PreToolUse en Task? Pero se ejecutaría en TODA invocación de Task, no solo la del implementer |
| `post-plan.sh` | NO — no hay evento "después de planificar" | Mismo problema. PostToolUse en Write se ejecuta en TODA escritura |
| `pre-commit.sh` | SÍ — `PreToolUse` matcher `Bash` filtrando por `git commit` | Este SÍ funciona como hook real |
| `post-review.sh` | NO — no hay evento "después de review" | No hay forma de saber cuándo el reviewer terminó |

**Conclusión incómoda:** Los hooks `pre-work`, `post-plan`, y `post-review` son scripts que nadie invoca automáticamente. Están ahí como documentación de intención, no como automatización real.

---

## Propuesta: Migrar a un modelo mixto

### Lo que debería ser RULE (guía de razonamiento)

1. **pre-work → rule** `rules/before-implementation.md`
   - "Antes de implementar, verifica que existe un plan"
   - Claude lo internaliza y lo cumple como instrucción

2. **post-plan → integrar en planner.md worker**
   - La validación de que el plan tenga acceptance criteria y SOLID ya debería estar en la definición del worker
   - El planner ya dice que debe producir estos artefactos — redundante tener un hook que lo verifique

3. **post-review → integrar en reviewer.md worker**
   - El reviewer.md ya define que el output debe tener verdict y evidence
   - Tener un hook externo que valide lo que el worker ya promete es doble-check innecesario

### Lo que debería seguir siendo HOOK

4. **pre-commit.sh → hook real en settings.json**
   - Este SÍ es un hook legítimo: ejecuta lint, tests, detecta archivos sensibles
   - Mapea perfectamente a `PreToolUse` + matcher `Bash`
   - Es determinista y no depende del razonamiento de Claude

---

## Cuestionamiento crítico de la propuesta

### Argumento 1: "Las rules son probabilísticas, los hooks son deterministas"

**A favor de hooks:** Un hook bash con exit 1 BLOQUEA la acción. Una rule puede ser ignorada si Claude "olvida" o prioriza otra instrucción.

**Contraargumento:** Los 3 hooks que no mapean a eventos reales no son deterministas tampoco — simplemente no se ejecutan. Un hook que no se puede disparar tiene 0% de efectividad. Una rule que Claude sigue el 95% del tiempo es mejor que eso.

**Veredicto:** A favor de rules para los 3 hooks sin evento real.

### Argumento 2: "Las rules inflán el contexto"

**A favor de hooks:** Cada rule consume tokens del context window. Si tienes 20 rules, estás gastando contexto valioso.

**Contraargumento:** Los workers ya son markdown largo que se carga bajo demanda. Mover la validación DENTRO del worker no añade rules extra — consolida lógica que ya está dispersa. Además, CLAUDE.md ya se carga siempre; una línea extra ahí es negligible.

**Veredicto:** Neutro. La inflación es mínima si se integra en archivos existentes.

### Argumento 3: "Separar validación de definición es buena práctica"

**A favor de hooks:** En software real, separar "qué hacer" del "validar que se hizo bien" es un patrón sólido (tests vs implementation).

**Contraargumento:** Eso aplica cuando AMBOS se ejecutan. Aquí el worker se ejecuta y el hook... no. Además, el worker es un prompt para un LLM — si el prompt dice "produce X con Y secciones", el LLM lo produce. No hay un "bug" que haga que el LLM olvide una sección de forma silenciosa como lo haría un programa. Y si lo olvida, un grep externo tampoco lo arregla — solo reporta el problema.

**Veredicto:** A favor de integrar en workers. La separación solo vale si ambos lados se ejecutan.

### Argumento 4: "¿Y si Claude Code añade eventos de workflow en el futuro?"

**A favor de hooks:** Si Anthropic añade `PreWorker`, `PostWorker`, o eventos custom, tendríamos los hooks listos.

**Contraargumento:** YAGNI. Diseñar para una API que no existe es especulativo. Si esos eventos aparecen, migrar rules→hooks es trivial. El costo de tener hooks muertos HOY es mayor que el costo de migrar MAÑANA.

**Veredicto:** A favor de rules hoy, revisar cuando la API evolucione.

### Argumento 5: "¿Y si en lugar de rules usamos SubagentStop?"

**Posibilidad:** `SubagentStop` se dispara cuando un subagente (worker) termina. Podríamos validar la salida del planner/reviewer ahí.

**Problema:** `SubagentStop` no distingue QUÉ subagente terminó. Si ejecutas el hook en todo SubagentStop, estás validando post-plan cuando termina el implementer, y post-review cuando termina el planner. Habría que parsear el output para saber qué worker fue.

**Veredicto:** Interesante pero frágil. Requiere heurísticas para identificar al worker, lo cual es... lo opuesto a determinista.

---

## Decisión propuesta

```
ANTES                          DESPUÉS
─────                          ───────
hooks/pre-work.sh         →    Instrucción en CLAUDE.md (o rule)
hooks/post-plan.sh        →    Integrar en workers/planner.md (self-validation)
hooks/pre-commit.sh       →    Hook REAL en settings.json (PreToolUse:Bash)
hooks/post-review.sh      →    Integrar en workers/reviewer.md (self-validation)
```

### Cambios concretos

1. **CLAUDE.md** — Añadir regla: "Antes de lanzar el implementer, verificar que existe plan"
2. **workers/planner.md** — Añadir sección "Self-Validation Checklist" al final del output
3. **workers/reviewer.md** — Ya tiene la definición de formato; reforzar que es obligatorio
4. **hooks/pre-commit.sh** — Mantener, pero documentar cómo registrar en settings.json
5. **Eliminar** hooks/pre-work.sh, hooks/post-plan.sh, hooks/post-review.sh
6. **Añadir** ejemplo de settings.json con el hook real de pre-commit

### Riesgo de la propuesta

**Riesgo principal:** Perdemos la "red de seguridad" de validación externa, aunque sea una red que hoy no funciona.

**Mitigación:** El skill `compound-capture` ya ejecuta un análisis post-tarea. Podemos añadir un check ahí que valide que los artefactos esperados existen y tienen las secciones requeridas. Esto sí se ejecuta (es invocado explícitamente) y cubre el gap.

---

## Pregunta abierta

¿Vale la pena mantener el directorio `hooks/` con un solo archivo (`pre-commit.sh`)?
¿O mover la lógica de pre-commit directamente a la documentación de setup en README.md?
