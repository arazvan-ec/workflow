# Plan: De SOLID Numérico a Inteligencia Arquitectónica Contextual

**Fecha**: 2026-02-13
**Estado**: PENDIENTE
**Estimación**: ~28 archivos a modificar, 2 a fusionar, 1 a crear

---

## Contexto

El plugin multi-agent-workflow tiene un sistema SOLID basado en scores numéricos estáticos (≥22/25 para aprobar, ≥18/25 mínimo). Este sistema tiene 3 problemas fundamentales:

1. **Los scores son ficticios**: Asignar "Strategy = 25/25" como propiedad del patrón ignora que el score depende de la implementación, no del patrón abstracto.
2. **La matrix es estática y OOP-centric**: Asume clases + interfaces explícitas. No aplica a Go (interfaces implícitas), Python (duck typing), Rust (traits), JS funcional.
3. **No detecta — prescribe**: En vez de seguir los patrones que el proyecto YA usa, impone patrones de una lookup table.

## Objetivos

1. **Fusionar** `solid-pattern-matrix.md` + `architecture-quality-criteria.md` → un solo documento de referencia (no de config)
2. **Crear** `architecture-profile.yaml` como knowledge detectado del proyecto en `openspec/specs/`
3. **Que `discover --setup` lo genere** analizando el codebase real
4. **Que `compound` lo enriquezca** con cada feature completada
5. **Que `plan.md` Phase 3 lo lea** para diseñar soluciones coherentes con el proyecto
6. **Eliminar el score numérico X/25** y reemplazarlo con verificaciones contextuales por principio
7. **Reescribir `solid-analyzer`** para que analice contra el perfil del proyecto, no contra una tabla estática

---

## El Nuevo Modelo

### Antes (estático, numérico)

```
solid-pattern-matrix.md (tabla: violación → patrón con score fijo)
     +
architecture-quality-criteria.md (métricas: ≤200 líneas, ≤7 métodos)
     +
solid-analyzer skill (detecta violaciones → sugiere patrón de la tabla)
     ↓
Score: 22/25 → APPROVE
Score: 17/25 → REJECT
```

### Después (contextual, por principio)

```
architecture-reference.md (documento fusionado: principios + patrones + anti-patrones como REFERENCIA)
     +
openspec/specs/architecture-profile.yaml (DETECTADO del proyecto real)
     +
solid-analyzer skill (analiza código vs profile del proyecto + principios SOLID)
     ↓
Verificación por principio:
  SRP: "¿Esta clase tiene una razón para cambiar?" → SÍ/NO + evidencia
  OCP: "¿Se puede extender sin modificar?" → SÍ/NO + evidencia
  LSP: "¿Los subtipos respetan el contrato?" → SÍ/NO + evidencia (o N/A si no hay herencia)
  ISP: "¿Hay métodos no usados en interfaces?" → SÍ/NO + evidencia (o N/A si el lenguaje no tiene interfaces)
  DIP: "¿El dominio depende de abstracciones?" → SÍ/NO + evidencia
     ↓
Decisión: COMPLIANT / NEEDS_WORK (con qué principio y por qué) / NON_COMPLIANT (con evidencia)
```

### `architecture-profile.yaml` (ejemplo)

```yaml
# Generado por /workflows:discover --setup
# Enriquecido por /workflows:compound después de cada feature
# Ubicación: openspec/specs/architecture-profile.yaml

stack:
  language: php                    # php | typescript | python | go | rust | java | mixed
  framework: symfony               # symfony | laravel | express | fastapi | gin | spring | next | none
  paradigm: oop                    # oop | functional | mixed
  type_system: strong-static       # strong-static | strong-dynamic | weak-dynamic

architecture:
  pattern: hexagonal               # hexagonal | mvc | layered | clean | microservices | serverless | monolith | none
  layers:                          # Solo si pattern implica capas
    - name: Domain
      path: src/Domain/
      depends_on: []               # No depende de nada (DIP enforced)
    - name: Application
      path: src/Application/
      depends_on: [Domain]
    - name: Infrastructure
      path: src/Infrastructure/
      depends_on: [Domain, Application]
  separation_enforced: true        # ¿El proyecto ya respeta separación de capas?

patterns_detected:
  data_access: repository          # repository | active-record | query-builder | data-mapper | raw-sql
  dependency_management: constructor-injection  # constructor-injection | container-autowire | service-locator | manual
  error_handling: exceptions       # exceptions | result-types | error-codes | mixed
  async_pattern: none              # promises | async-await | callbacks | coroutines | channels | none
  testing_approach: tdd            # tdd | test-after | minimal | none

solid_relevance:
  # Cada principio tiene un nivel de relevancia para ESTE proyecto.
  # Esto evita forzar ISP en un proyecto Go o LSP en código sin herencia.
  srp:
    relevance: high                # high | medium | low
    metric: "classes ≤200 LOC, ≤7 public methods"
    when_violated: "Extract Class, then compose"
    reference_good: src/Domain/Entity/Order.php  # Ejemplo de buena SRP en este proyecto
  ocp:
    relevance: high
    metric: "no switch/if-else chains by type"
    when_violated: "Strategy pattern (this project uses it in src/Domain/Service/Pricing/)"
    reference_good: src/Domain/Service/Pricing/PricingStrategy.php
  lsp:
    relevance: medium              # medium porque el proyecto tiene poca herencia
    metric: "overrides respect parent contract"
    when_violated: "Composition over Inheritance"
  isp:
    relevance: high                # high porque PHP tiene interfaces explícitas
    metric: "interfaces ≤5 methods"
    when_violated: "Role Interfaces"
    reference_good: src/Domain/Repository/ReadableRepository.php
  dip:
    relevance: critical            # critical porque es hexagonal
    metric: "Domain/ imports zero from Infrastructure/"
    when_violated: "Port interface in Domain, Adapter in Infrastructure"
    reference_good: src/Domain/Port/UserRepositoryInterface.php

conventions:
  naming:
    classes: PascalCase
    methods: camelCase
    files: match-class-name
  structure:
    entity_path: src/Domain/Entity/
    usecase_path: src/Application/UseCase/
    repository_interface_path: src/Domain/Port/
    repository_impl_path: src/Infrastructure/Persistence/
  reference_files:
    entity: src/Domain/Entity/Order.php
    value_object: src/Domain/ValueObject/Money.php
    usecase: src/Application/UseCase/CreateOrderUseCase.php
    repository_interface: src/Domain/Port/OrderRepositoryInterface.php
    repository_impl: src/Infrastructure/Persistence/DoctrineOrderRepository.php
    controller: src/Infrastructure/Http/Controller/OrderController.php

quality_thresholds:
  # Thresholds adaptativos, no fijos
  max_class_loc: 200               # Descubierto del promedio del proyecto + margen
  max_public_methods: 7
  max_constructor_deps: 7
  max_interface_methods: 5
  max_files_per_simple_change: 5   # De architecture-quality-criteria C-BASE-01

# Enriquecido por compound:
learned_patterns:
  - pattern: "Value Object for validated fields (Email, Money, etc.)"
    confidence: high               # high = usado 3+ veces exitosamente
    source_features: [user-auth, payments, order-management]
  - pattern: "UseCase orchestrates, never Entity"
    confidence: medium
    source_features: [user-auth]

learned_antipatterns:
  - antipattern: "Putting hashing logic in Entity violates SRP"
    frequency: 2
    prevention: "Hashing, encryption, and encoding belong in Application or Infrastructure layer"
```

---

## Fases de Implementación

### Fase 1: Crear `architecture-reference.md` (fusión)

**Qué**: Fusionar `solid-pattern-matrix.md` + `architecture-quality-criteria.md` en un solo documento `core/architecture-reference.md`.

**Cambios en el documento fusionado**:
- Eliminar TODOS los scores numéricos X/25 de los patrones (Strategy ya no es "25/25")
- Mantener los decision trees (son útiles como referencia)
- Mantener las tablas de síntomas/violaciones (son útiles para detección)
- Mantener los anti-patrones (son universales)
- Añadir sección: "Cómo adaptar estos principios por paradigma" (OOP, funcional, mixed)
- Cambiar el framing: de "tabla de lookup" a "documento de referencia que el agente consulta"
- Eliminar la tabla "SOLID Compliance Score per Pattern" (la del 25/25, 24/25, etc.)
- Reemplazar "Pattern Selection Algorithm" (6 pasos con scores) por uno basado en: (1) qué hace el proyecto ya, (2) qué principio está violado, (3) qué patrón es más simple

**Archivos**:
- CREAR: `core/architecture-reference.md` (fusión)
- ELIMINAR: `core/solid-pattern-matrix.md`
- ELIMINAR: `core/architecture-quality-criteria.md`

---

### Fase 2: Crear template de `architecture-profile.yaml`

**Qué**: Crear el template que `discover --setup` usará para generar el perfil de cada proyecto.

**Archivos**:
- CREAR: `core/templates/architecture-profile-template.yaml` (template con comentarios explicativos)
- El archivo real `openspec/specs/architecture-profile.yaml` se genera en runtime por `discover`

---

### Fase 3: Actualizar `discover.md` para generar el perfil

**Qué**: Añadir un paso nuevo a discover que genere `architecture-profile.yaml` a partir del análisis del codebase.

**Cambios**:
- Nuevo Step (después del Step 3 actual "Analyze project structure"): "Generate Architecture Profile"
  - Detectar stack (language, framework, paradigm) — ya lo hace en Step 2
  - Detectar architecture pattern (hexagonal, mvc, etc.) — ya lo hace en Step 3
  - Detectar patterns_in_use (repository, active-record, etc.) — nuevo
  - Detectar solid_relevance por principio — nuevo
  - Detectar conventions (naming, structure, reference_files) — parcialmente nuevo
  - Detectar quality_thresholds del código existente (promedio LOC, métodos, etc.) — nuevo
  - Escribir `openspec/specs/architecture-profile.yaml`
- Actualizar Step 13 (Generate Project Profile) para referenciar el architecture-profile
- Actualizar references a thresholds de SOLID (quitar 22/25, 18/25)

**Archivos**:
- MODIFICAR: `commands/workflows/discover.md`

---

### Fase 4: Reescribir `solid-analyzer` skill

**Qué**: Cambiar de "detectar violaciones → score numérico" a "analizar contra perfil del proyecto → verificaciones por principio".

**Nuevo flujo del skill**:
```
1. LEER openspec/specs/architecture-profile.yaml
   - Si no existe: usar defaults razonables + advertir

2. Para cada principio SOLID:
   a. Verificar relevance del principio para este proyecto
      - Si relevance = low → skip con nota "N/A for this project"
   b. Aplicar las reglas de detección ADAPTADAS al stack:
      - PHP/Java: buscar clases, interfaces, imports
      - Go: buscar structs, implicit interfaces, package imports
      - Python: buscar clases, duck typing patterns, imports
      - TypeScript: buscar types/interfaces, module imports
      - Funcional: buscar composición, side effects, coupling
   c. Comparar contra reference_files del profile
      - "¿Este código nuevo sigue el mismo patrón que Order.php?"
   d. Emitir veredicto por principio: COMPLIANT / NEEDS_WORK / NON_COMPLIANT
      - Con evidencia concreta (archivo:línea, qué viola, por qué)
      - Con sugerencia contextual (no de la tabla, sino del profile)

3. OUTPUT:
   Veredicto global: COMPLIANT / NEEDS_WORK / NON_COMPLIANT
   Por principio:
     SRP: COMPLIANT — "UserService tiene 1 responsabilidad: orchestrate user creation"
     OCP: NEEDS_WORK — "PaymentService.php:45 has switch by type. Profile suggests Strategy (see PricingStrategy.php)"
     LSP: N/A — "No inheritance detected in new code"
     ISP: COMPLIANT — "UserRepositoryInterface has 3 methods, within threshold"
     DIP: COMPLIANT — "Domain/ has zero infrastructure imports"

   Issues (si hay):
     - OCP violation in PaymentService.php:45 — switch(paymentType) should use Strategy
       Reference: src/Domain/Service/Pricing/PricingStrategy.php (from project profile)
```

**Archivos**:
- REESCRIBIR: `skills/workflow-skill-solid-analyzer.md`

---

### Fase 5: Actualizar `plan.md` Phase 3

**Qué**: Cambiar de "score ≥22/25" a "verificación contextual por principio".

**Cambios**:
- Step 3.1 "Analyze Existing Code (SOLID Baseline)": En vez de obtener un score X/25, leer `architecture-profile.yaml` para entender qué patrones usa el proyecto y qué principios son relevantes
- Step 3.2 "Design Solutions with SOLID": En vez de llenar tablas con "S:5 O:5 L:5...", razonar por principio:
  - "¿Esta solución respeta SRP? Sí porque..."
  - "¿Esta solución respeta OCP? Sí porque usamos Strategy como ya hace PricingStrategy.php"
  - "¿LSP aplica aquí? No, no hay herencia"
- Step 3.4 "Verify SOLID Score": Reemplazar por "Verify SOLID Compliance" — invoca solid-analyzer con el nuevo formato
- Eliminar todos los "≥22/25" y "≥18/25"
- Reemplazar la "SOLID Compliance" table en el template de design.md por una sección narrativa por principio
- Quality Gate Phase 3 Check 3: cambiar de "SOLID table has empty cells" a "each relevant principle has a reasoned verdict"
- Actualizar el "If You Need... Use Pattern" table para que diga "See architecture-profile.yaml for project patterns" en vez de scores
- Actualizar task template: cambiar "SOLID Requirements: Use Strategy pattern for..." por "Architecture: Follow project pattern for X (see profile reference)"
- Actualizar checklist final: quitar "Expected SOLID score ≥22/25"

**Archivos**:
- MODIFICAR: `commands/workflows/plan.md` (~20 secciones a actualizar)

---

### Fase 6: Actualizar `work.md`

**Qué**: Cambiar las verificaciones de score numérico por verificaciones por principio.

**Cambios**:
- Step 5 "TDD + SOLID": quitar "SOLID score" del checkpoint, poner "SOLID compliance check"
- Step 7 "Checkpoint": reemplazar "SOLID score ≥18/25" por "solid-analyzer --validate returns COMPLIANT or NEEDS_WORK (not NON_COMPLIANT)"
- Checkpoint SOLID Requirements table: reemplazar scores per-layer (SRP ≥4/5, DIP ≥4/5) por verificaciones booleanas ("Domain has zero infra imports", "each class has single responsibility")
- Quitar "SOLID Total: Must achieve ≥18/25 overall"
- Actualizar ejemplo de checkpoint output: quitar "SOLID Score: 21/25" → poner "SOLID: COMPLIANT (5/5 principles verified)"

**Archivos**:
- MODIFICAR: `commands/workflows/work.md`

---

### Fase 7: Actualizar `review.md`

**Qué**: Cambiar de "SOLID score matches expected" a "SOLID compliance verified per principle".

**Cambios**:
- Quitar "SOLID score verification -- checks >= 18/25 minimum"
- QA Phase 4: en vez de comparar score numérico de design.md vs implementación, verificar que cada principio marcado como "relevante" en design.md fue respetado
- Decisión de rechazo: "NON_COMPLIANT on any relevant principle" en vez de "score < 18/25"

**Archivos**:
- MODIFICAR: `commands/workflows/review.md`

---

### Fase 8: Actualizar `compound.md` para enriquecer el profile

**Qué**: Después de cada feature, actualizar `architecture-profile.yaml` con lo aprendido.

**Cambios**:
- Nuevo paso (después de Step 3b "Update Agent Compound Memory"):
  - "Step 3c: Enrich Architecture Profile"
  - Leer `openspec/specs/architecture-profile.yaml`
  - Si se descubrió un nuevo patrón exitoso → añadirlo a `learned_patterns`
  - Si se descubrió un anti-patrón → añadirlo a `learned_antipatterns`
  - Si un reference_file cambió → actualizar
  - Si los thresholds demuestran ser incorrectos → ajustar
  - Escribir el archivo actualizado

**Archivos**:
- MODIFICAR: `commands/workflows/compound.md`

---

### Fase 9: Actualizar los demás archivos con referencias

**Qué**: Actualizar todas las referencias a los archivos viejos y scores numéricos en ~19 archivos.

**Lista completa de cambios**:

| Archivo | Cambio |
|---------|--------|
| `CLAUDE.md` | `solid-pattern-matrix.md` → `architecture-reference.md`. Quitar "score >= 22/25". Añadir "See `openspec/specs/architecture-profile.yaml` for project-specific patterns" |
| `README.md` | Igual que CLAUDE.md |
| `core/roles/planner.md` | Permisos read: reemplazar 2 archivos por 1. Quitar "Reject options with SOLID score < 18/25" → "Reject options that are NON_COMPLIANT" |
| `core/roles/implementer.md` | Quitar "must meet task thresholds" → "must be COMPLIANT per solid-analyzer" |
| `core/templates/spec-template.md` | Quitar scores numéricos. Reescribir SOLID section con formato por-principio. Quitar "Threshold: >=18/25" |
| `core/docs/CONTEXT_ENGINEERING.md` | `solid-pattern-matrix.md` → `architecture-reference.md`. Quitar "SOLID >=18/25" → "SOLID COMPLIANT" |
| `core/docs/CAPABILITY_PROVIDERS.md` | Actualizar references a solid-analyzer |
| `core/providers.yaml` | Actualizar comentarios |
| `commands/workflows/route.md` | Quitar "SOLID score >=18/25" → "SOLID compliance verified" |
| `commands/workflows/discover.md` | Quitar "SOLID >=22/25" y "SOLID >=18/25". Añadir generación de architecture-profile |
| `commands/workflows/help.md` | Quitar "score >= 22/25" → "SOLID compliance per project profile" |
| `skills/workflow-skill-criteria-generator.md` | Quitar scores numéricos. Cambiar "SOLID-Rigorous (no option with <18/25)" → "SOLID-Rigorous (no option NON_COMPLIANT)". Actualizar references |
| `agents/review/architecture-reviewer.md` | Quitar "SOLID Score: ${X}/25". Reescribir checklist con formato por-principio |

---

### Fase 10: Limpieza y verificación

**Verificaciones**:
```bash
# 0 resultados esperados:
grep -r "22/25" plugins/multi-agent-workflow/
grep -r "18/25" plugins/multi-agent-workflow/
grep -r "solid-pattern-matrix" plugins/multi-agent-workflow/
grep -r "architecture-quality-criteria" plugins/multi-agent-workflow/
grep -r "/25.*SOLID\|SOLID.*/25" plugins/multi-agent-workflow/

# Debe existir:
cat plugins/multi-agent-workflow/core/architecture-reference.md
cat plugins/multi-agent-workflow/core/templates/architecture-profile-template.yaml

# No debe existir:
ls plugins/multi-agent-workflow/core/solid-pattern-matrix.md      # DELETED
ls plugins/multi-agent-workflow/core/architecture-quality-criteria.md  # DELETED
```

---

## Resumen de Impacto

| Categoría | Archivos |
|-----------|----------|
| CREAR (2) | `core/architecture-reference.md`, `core/templates/architecture-profile-template.yaml` |
| ELIMINAR (2) | `core/solid-pattern-matrix.md`, `core/architecture-quality-criteria.md` |
| REESCRIBIR (1) | `skills/workflow-skill-solid-analyzer.md` |
| MODIFICAR FUERTE (4) | `plan.md`, `work.md`, `review.md`, `compound.md` |
| MODIFICAR LEVE (5) | `discover.md`, `route.md`, `help.md`, `criteria-generator`, `architecture-reviewer.md` |
| ACTUALIZAR REFS (8) | `CLAUDE.md`, `README.md`, `planner.md`, `implementer.md`, `spec-template.md`, `CONTEXT_ENGINEERING.md`, `CAPABILITY_PROVIDERS.md`, `providers.yaml` |
| **TOTAL** | **22 archivos** (2 creados, 2 eliminados, 18 modificados) |

---

## Orden de Ejecución Recomendado

```
Fase 1: Crear architecture-reference.md (fusión)           ← Base del cambio
Fase 2: Crear template architecture-profile.yaml            ← Define el nuevo modelo
Fase 4: Reescribir solid-analyzer                           ← Core del nuevo comportamiento
Fase 3: Actualizar discover.md                              ← Genera el profile
Fase 5: Actualizar plan.md                                  ← Consume el profile
Fase 6: Actualizar work.md                                  ← Verifica con nuevo formato
Fase 7: Actualizar review.md                                ← Valida con nuevo formato
Fase 8: Actualizar compound.md                              ← Enriquece el profile
Fase 9: Actualizar referencias (~13 archivos)               ← Consistencia
Fase 10: Verificación                                       ← Grep final
```

Nota: Fases 1+2 son independientes y se pueden hacer en paralelo. Fases 5+6+7 son independientes entre sí pero dependen de Fase 4.

---

## Lo Que NO Cambia

- El workflow general (Route → Plan → Work → Review → Compound)
- Los 4 archivos OpenSpec (proposal, specs, design, tasks)
- El Baseline Freeze rule
- El BCP (3 tipos de desviación)
- TDD como metodología
- Los agentes y su función
- Los 14 skills (excepto solid-analyzer que se reescribe)
- Los 3 roles
- El concepto de que Phase 3 diseña con SOLID — solo cambia CÓMO se verifica
