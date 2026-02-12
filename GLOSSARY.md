# Glosario de Términos

> Definiciones claras de todos los conceptos usados en este workflow.

---

## Metodologías

### Compound Engineering
**Qué es**: Filosofía donde cada tarea completada hace las siguientes más fáciles.

**Ejemplo**: Al crear un componente de botón bien documentado, todos los futuros botones son más rápidos de crear porque ya existe el patrón.

**Origen**: Evolución del "Vibe Coding" de Andrej Karpathy (2025).

---

### Bounded Correction Protocol (BCP)
**Qué es**: Protocolo de auto-corrección acotado que detecta y corrige tres tipos de desviaciones durante el desarrollo, con límites adaptativos según complejidad.

**Tres tipos de desviación**:
- **TYPE 1 — Test Failure**: Tests fallan → arreglar implementación (NUNCA el test)
- **TYPE 2 — Missing Functionality**: Tests pasan pero acceptance criteria no se cumplen → añadir implementación faltante
- **TYPE 3 — Incomplete Pattern**: Implementación no sigue el reference file → completar el patrón

**Límites adaptativos** (según complejidad del task):
| Complejidad | Max iteraciones | Ejemplo |
|-------------|----------------|---------|
| Simple | 5 | Bug fix, refactor, cambio single-file |
| Moderado | 10 | Feature estándar, multi-file |
| Complejo | 15 | Nueva arquitectura, integración multi-capa |

**Cómo funciona**:
```
while (tests_failing OR deviation_detected) and iteration < max_iterations:
    CLASSIFY deviation → TYPE 1, 2, or 3
    Apply targeted fix based on type
    Run verification (tests + acceptance criteria)
    iteration++

if all_verified → checkpoint complete
if max_iterations reached → BLOCKED, documentar con tipo de desviación
```

**Mejoras integradas (GSD + BMAD)**:
- **Solution Validation**: Validar approach ANTES de implementar (evita ciclos desperdiciados)
- **Goal-Backward Verification**: Verificar contra acceptance criteria, no solo tests
- **Adversarial Self-Review**: Agente identifica al menos 1 issue propio antes del checkpoint

**Origen**: Geoffrey Huntley. Mejorado con conceptos de GSD (Get Shit Done) y BMAD (Breakthrough Method for Agile AI Driven Development).

---

### Vibe Coding
**Qué es**: Dejar que la IA genere código basándose en el "vibe" o intención general.

**Problema**: Funciona para el 70% pero el 30% restante es difícil de resolver.

**Solución**: Compound Engineering + especificaciones claras.

---

### Shape Up / Shaping
**Qué es**: Metodología de Ryan Singer para explorar problema y solución antes de planificar. Separa el "qué" (Requirements) del "cómo" (Shapes) y valida el encaje con fit checks.

**Conceptos clave**:
- **Requirements (R)**: Definen el problema, independientes de la solución
- **Shapes (A, B, C)**: Soluciones alternativas con partes concretas (mecanismos)
- **Fit Check (R x A)**: Matriz binaria que verifica qué requisitos cubre cada solución
- **Spike**: Investigación para resolver unknowns antes de comprometerse
- **Breadboard**: Diagrama técnico que combina UI y código en un circuito
- **Vertical Slice**: Subset del breadboard demostrable end-to-end

**Flujo**:
```
Frame → Requirements → Shape → Fit Check → Spike → Breadboard → Slice
```

**Comando**: `/workflows:shape`

**Origen**: Ryan Singer, "Shape Up" (Basecamp/37signals).

---

### Solution Validation (Pre-Implementation Check)
**Qué es**: Paso de validación que ocurre ANTES de escribir código (Step 4.5 en el workflow). Verifica que el approach es arquitecturalmente correcto antes de iniciar TDD.

**4 checks que realiza**:
1. **Reference Check**: ¿Existe un reference file? → Confirmar que el approach sigue el mismo patrón
2. **Integration Check**: ¿Conflicta con checkpoints completados? → Verificar interfaces (DTOs, method signatures)
3. **Decision Check**: ¿Es consistente con DECISIONS.md? → Verificar decisiones arquitectónicas
4. **Complexity Assessment**: Resolver `max_iterations` según complejidad del task

**Por qué importa**: Evita desperdiciar ciclos TDD en un approach fundamentalmente incorrecto.

**Origen**: Adaptado de BMAD Solutioning Phase.

---

### Goal-Backward Verification
**Qué es**: Verificación contra los acceptance criteria del task ADEMÁS de los tests. "Tests pasan" es necesario pero NO suficiente.

**Tipos de criterio**:
- **AUTOMATED**: Verificable por comando → ejecutar y verificar output
- **OBSERVABLE**: Requiere inspección de código → leer archivos y verificar comportamiento
- **MANUAL**: Requiere verificación humana → documentar y marcar PENDING_REVIEW

**Resultado**: Score X/Y criterios verificados. Si alguno falla → re-entra al correction loop como TYPE 2 (missing functionality).

**Origen**: Adaptado de GSD Verify Phase.

---

### Adversarial Self-Review
**Qué es**: Paso obligatorio antes de marcar un checkpoint como completo. El agente implementador DEBE identificar al menos 1 potential issue en su propio código.

**Qué buscar** (al menos 1):
- Edge case no cubierto por tests
- Code smell o violación SOLID (incluso menor)
- Concern de performance u optimización
- Consideración de seguridad

**Regla**: Zero findings = review again. Zero findings en código real es una red flag.

**Origen**: Adaptado de BMAD Adversarial Review Pattern.

---

### Deviation Types (Tipos de Desviación)
**Qué es**: Clasificación de los tres tipos de problemas que el BCP detecta y corrige.

| Tipo | Descripción | Acción |
|------|-------------|--------|
| **TYPE 1** | Tests fallan con errores | Arreglar implementación (nunca el test) |
| **TYPE 2** | Tests pasan pero acceptance criteria no se cumplen | Añadir funcionalidad faltante |
| **TYPE 3** | No sigue el patrón del reference file | Completar el patrón |

**Por qué importa**: Antes solo se detectaban test failures (TYPE 1). Ahora se capturan gaps funcionales y patrones incompletos.

---

### Agent Harness
**Qué es**: Sistema que coordina múltiples agentes de IA trabajando en paralelo.

**Analogía**: Como un director de orquesta que coordina a los músicos.

---

### MCP (Model Context Protocol)
**Qué es**: Estándar abierto de Anthropic para que los modelos de IA accedan a herramientas y contexto.

**Analogía**: Como USB pero para conectar IAs con herramientas.

---

## Arquitectura

### DDD (Domain-Driven Design)
**Qué es**: Arquitectura que organiza el código alrededor del dominio del negocio.

**Capas**:
- **Domain**: Lógica de negocio pura (sin frameworks)
- **Application**: Casos de uso y orquestación
- **Infrastructure**: Base de datos, APIs externas, etc.

---

### TDD (Test-Driven Development)
**Qué es**: Escribir tests ANTES del código.

**Flujo**:
```
1. Escribir test que falla (Red)
2. Escribir código mínimo para pasar (Green)
3. Refactorizar (Refactor)
```

---

## Archivos Clave

### 50_state.md
**Qué es**: Archivo que contiene el estado actual del desarrollo.

**Por qué "50"**: Es la numeración usada para indicar que es un archivo de estado medio en el flujo.

**Contiene**:
- Estado de cada tarea (PENDING, IN_PROGRESS, COMPLETED)
- Checkpoints
- Bloqueos

**Regla**: Este archivo es la ÚNICA fuente de verdad.

---

### 30_tasks.md
**Qué es**: Lista de tareas a realizar para una feature.

**Por qué "30"**: Viene después de arquitectura (10) y contratos (20).

---

### FEATURE_X.md
**Qué es**: Documento que define una feature completa.

**Contiene**:
- Requisitos
- Criterios de aceptación
- Dependencias
- Estimaciones

---

## Roles/Agentes

### Planner
**Qué hace**: Define y descompone features en tareas.

**Cuándo usarlo**: Siempre al inicio de una feature.

---

### Backend Engineer
**Qué hace**: Implementa código del servidor (API, base de datos, lógica).

**Stack típico**: Laravel/Symfony (PHP), Node.js, etc.

---

### Frontend Engineer
**Qué hace**: Implementa la interfaz de usuario.

**Stack típico**: React, TypeScript.

---

### QA Engineer
**Qué hace**: Prueba el código y valida calidad.

**Herramienta principal**: Bounded Correction Protocol.

---

## Estados de Tareas

| Estado | Significado |
|--------|-------------|
| `PENDING` | No iniciada |
| `IN_PROGRESS` | En desarrollo |
| `BLOCKED` | Esperando algo |
| `WAITING_API` | Esperando que backend termine |
| `COMPLETED` | Terminada |
| `APPROVED` | Aprobada por QA |
| `REJECTED` | Rechazada, necesita arreglos |

---

## Comandos

### /workflows:discover
Analiza el proyecto en profundidad y genera un perfil completo con toda la información que el plugin necesita para trabajar efectivamente.

### /workflows:onboarding
Experiencia guiada interactiva para nuevos usuarios.

### /workflows:help
Ayuda rápida y navegación entre comandos y conceptos.

### /workflows:shape
Explora problema y solución antes de planificar. Separa requirements de shapes, ejecuta spikes, genera breadboards y slices verticales. Opcional pero recomendado para features complejas.

### /workflows:plan
Inicia la planificación de una feature.

### /workflows:work
Ejecuta el trabajo de implementación.

### /workflows:review
Ejecuta revisión de calidad.

### /workflows:compound
Captura aprendizajes para el efecto compuesto.

### /workflows:sync
Sincroniza estado entre sesiones.

### /workflows:status
Muestra el estado actual.

### /workflows:specs
Gestiona Living Specs del proyecto. Extrae specs del código existente, detecta drift, y mantiene especificaciones sincronizadas.

---

## Sistema de Conocimiento del Proyecto

### Project Profile
**Qué es**: Documento completo con todo lo que el plugin sabe sobre tu proyecto.

**Ubicación**: `.ai/project/intelligence/project-profile.md`

**Contiene**:
- Stack tecnológico completo
- Patrones de arquitectura detectados
- Convenciones de código
- Archivos de referencia (templates)
- Recomendaciones de workflow

**Generado por**: `/workflows:discover`

---

### Project Discovery
**Qué es**: Proceso de análisis profundo del proyecto.

**7 Capas de Análisis**:
1. Detección de stack (frameworks, lenguajes)
2. Detección de arquitectura (DDD, MVC, etc.)
3. Análisis de convenciones de código
4. Descubrimiento de implementaciones de referencia
5. Análisis de historia git
6. Evaluación de complejidad
7. Recomendación de workflow

---

### Reference Implementation
**Qué es**: Archivo existente en el proyecto que sirve como template para nuevas implementaciones.

**Ejemplo**: Si `src/domain/entities/User.ts` es tu mejor entidad, el plugin lo usará como referencia cuando cree nuevas entidades.

**Por qué importa**: Mantiene consistencia en el código generado.

---

### config.yaml
**Qué es**: Archivo de configuración del proyecto para el plugin.

**Ubicación**: `.ai/project/config.yaml`

**Contiene**:
- Información del proyecto
- Configuración de backend/frontend
- Patrones de arquitectura
- Configuración de testing
- Convenciones detectadas

---

### Compound Log
**Qué es**: Registro histórico de aprendizajes capturados después de cada feature.

**Ubicación**: `.ai/project/compound_log.md`

**Contiene**:
- Patrones descubiertos
- Anti-patrones documentados
- Estimaciones de tiempo ahorrado
- Reglas actualizadas

---

## Living Specs System

### Living Specs
**Qué es**: Especificaciones que se mantienen sincronizadas automáticamente con el código fuente.

**Por qué importa**: Las especificaciones tradicionales se desactualizan rápidamente. Living Specs evolucionan con el código.

**Ubicación**: `.ai/project/specs/`

---

### Spec Extraction
**Qué es**: Proceso de analizar código existente y generar especificaciones automáticamente.

**Cuándo ocurre**: Durante `/workflows:discover` o `/workflows:specs --extract`.

**Resultado**: Specs estructuradas que documentan la realidad actual del código.

---

### Spec Drift
**Qué es**: Cuando las especificaciones documentadas divergen del comportamiento real del código.

**Problema**: Causa confusión y errores cuando la IA trabaja con specs desactualizadas.

**Solución**: Living Specs con detección automática de drift via `/workflows:specs --check`.

---

### Architecture-First Planning
**Qué es**: Metodología donde se definen las especificaciones y arquitectura ANTES de escribir código.

**Flujo**:
```
0. (Opcional) Shape: explorar problema y solución
1. Definir specs de la feature
2. Validar contra arquitectura existente
3. Planificar implementación
4. Implementar siguiendo specs
```

**Beneficio**: Reduce retrabajo y mantiene consistencia arquitectónica.

---

### Shaped Brief (01_shaped_brief.md)
**Qué es**: Documento producido por `/workflows:shape` que contiene el frame (problema/resultado), requirements, shape seleccionada, y fit check.

**Ubicación**: `.ai/project/features/{feature}/01_shaped_brief.md`

**Contiene**:
- Frame (problema y outcome)
- Requirements (R0, R1, R2...)
- Shape seleccionada con partes
- Fit check (R x A)
- Decisiones pendientes/resueltas

**Generado por**: `/workflows:shape`

---

### Breadboard (02_breadboard.md)
**Qué es**: Diagrama técnico que mapea Places, UI affordances, Code affordances y Data stores con su wiring.

**Analogía**: Como un diagrama de circuito eléctrico donde los switches son UI y los componentes son código.

**Ubicación**: `.ai/project/features/{feature}/02_breadboard.md`

---

### Vertical Slice (03_slices.md)
**Qué es**: Subset del breadboard que incluye tanto UI como backend, demostrable end-to-end.

**Diferencia con horizontal slice**: Un slice horizontal es "solo backend" o "solo frontend". Un slice vertical incluye ambos y se puede demostrar.

**Ejemplo**: V1 = tabla estática con datos reales (UI + API + DB). V2 = input de comandos que modifica la tabla.

---

### Spec Manifest
**Qué es**: Archivo índice que lista todas las specs del proyecto y su estado.

**Ubicación**: `.ai/project/specs/manifest.yaml`

**Contiene**:
- Lista de specs por dominio
- Estado de cada spec (draft, approved, implemented)
- Fecha de última sincronización
- Relaciones entre specs

---

## Conceptos de Contexto

### Context Window
**Qué es**: La "memoria" limitada que tiene la IA durante una conversación.

**Problema**: Si es muy larga, la IA "olvida" el inicio.

**Solución**: Sesiones cortas + checkpoints + `50_state.md`.

---

### Checkpoint
**Qué es**: Punto de guardado del progreso.

**Cuándo hacer uno**:
- Después de completar una tarea
- Antes de terminar una sesión
- Cuando el contexto se vuelve muy largo

---

### Trust Model
**Qué es**: Nivel de supervisión según qué tan conocido es el código.

| Nivel | Supervisión | Ejemplo |
|-------|-------------|---------|
| 🔴 Alto | Mucha | Código nuevo, crítico |
| 🟡 Medio | Moderada | Código existente modificado |
| 🟢 Bajo | Poca | Código bien probado |

---

## Anti-Patterns

### Context Bleeding
**Qué es**: Cuando la IA "contamina" una sesión con información de otra.

**Solución**: Una instancia = un rol.

---

### One-Shot Feature
**Qué es**: Intentar hacer una feature completa de un solo golpe.

**Problema**: Muy propenso a errores.

**Solución**: Desarrollo incremental.

---

## Referencias Rápidas

- **README.md**: Documentación completa
- **QUICKSTART.md**: Guía de 5 minutos
- **INDEX.md**: Mapa de navegación
- **global_rules.md**: Reglas universales
- **ddd_rules.md**: Reglas de arquitectura DDD
