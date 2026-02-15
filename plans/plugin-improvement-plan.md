# Plan de Mejora del Plugin: workflows:plan

> Basado en el análisis de mejores prácticas 2025-2026 aplicadas al plan actual (1365 líneas).
> Fecha: 2026-02-15
> Estado: PENDIENTE
> Priorizado por: Impacto × Esfuerzo

---

## Resumen Ejecutivo

El `plan.md` actual es un workflow maduro con fundamentos sólidos: planificación 80/20, persistencia incremental, Quality Gates con iteración acotada, análisis de integración, y SOLID como constraint obligatorio. Sin embargo, carece de capacidades clave que las mejores prácticas de ingeniería agéntica demandan: reflexión crítica, retroalimentación entre fases, checkpoints humanos en decisiones de alto riesgo, validación temprana con tests, observabilidad de decisiones, y consideración de seguridad.

Este plan de mejora introduce **10 mejoras concretas** priorizadas por impacto, con cambios específicos al `plan.md` y archivos relacionados del plugin.

---

## Priorización

| # | Mejora | Impacto | Esfuerzo | Prioridad |
|---|--------|---------|----------|-----------|
| 1 | HITL entre fases | Alto | Bajo | P0 |
| 2 | Reflection Pattern en Quality Gates | Alto | Medio | P0 |
| 3 | Test Contract Sketch en Phase 2 | Alto | Medio | P0 |
| 4 | SOLID Justification vs auto-score | Alto | Bajo | P0 |
| 5 | Decision Log / Trazabilidad | Medio | Bajo | P1 |
| 6 | Feedback Loop / Retrospectiva | Medio | Bajo | P1 |
| 7 | Chunking explícito por fase | Medio | Bajo | P1 |
| 8 | Security Threat Analysis en Phase 3 | Medio | Medio | P1 |
| 9 | Rollback Protocol | Bajo | Bajo | P2 |
| 10 | Right-sizing de modelo | Bajo | Bajo | P2 |

---

## Mejora 1: Human-in-the-Loop entre Fases (P0)

### Problema

El plan actual solo consulta al usuario en Phase 1 (si confidence < 60%) y al final (Step 4 de Completeness). Un error en specs descubierto en Phase 4 obliga a rehacer 3 fases completas.

### Ubicación en plan.md

Añadir checkpoints HITL entre Phase 2→3 y Phase 3→4.

### Cambio Propuesto

#### 1.1: Checkpoint HITL Post-Phase 2 (entre Phase 2 y Phase 3)

Insertar después de la sección "Phase 2 Quality Gate" (después de línea ~624), antes de "## PHASE 3: DESIGN":

```markdown
### Phase 2 → Phase 3 Checkpoint (HITL — Mandatory)

After writing `specs.md` and before starting Phase 3, present specs summary to the user:

~~~
HITL CHECKPOINT: SPECS REVIEW

Present to user:
  "Specs defined for ${FEATURE_ID}:
   - ${N} functional specs (SPEC-F01 through SPEC-F${N})
   - Integration impact: ${E} extended, ${M} modified, ${C} new entities
   - ${K} potential conflicts identified

   Key specs:
   $(list first 5 spec titles with acceptance criteria count)

   Full specs: openspec/changes/${FEATURE_ID}/specs.md

   Do the specs capture what you want? (approve / review-detail / revise)"

IF "approve" → Proceed to Phase 3
IF "review-detail" → Display full specs.md content, then re-ask
IF "revise" → Ask what to change, update specs.md, re-run Phase 2 Quality Gate
~~~

**Rationale**: Specs are the foundation for design. Catching misunderstandings here
avoids redesigning solutions and tasks downstream.
```

#### 1.2: Checkpoint HITL Post-Phase 3 (entre Phase 3 y Phase 4)

Insertar después de la sección "Phase 3 Quality Gate" (después de línea ~863), antes de "## Complete Planning Workflow":

```markdown
### Phase 3 → Phase 4 Checkpoint (HITL — Mandatory)

After writing `design.md` and before starting Phase 4, present design summary to the user:

~~~
HITL CHECKPOINT: DESIGN REVIEW

Present to user:
  "Technical design for ${FEATURE_ID}:
   - ${S} solutions designed (one per spec)
   - SOLID compliance: $(summary of verdicts per principle)
   - Architectural impact: ${L} layers affected, ${F} files to create, ${G} to modify
   - Risk: $(highest risk level from assessment)
   - Key patterns: $(list selected patterns)

   Full design: openspec/changes/${FEATURE_ID}/design.md

   Does the technical design look correct? (approve / review-detail / revise)"

IF "approve" → Proceed to Phase 4
IF "review-detail" → Display full design.md content, then re-ask
IF "revise" → Ask what to change, update design.md, re-run Phase 3 Quality Gate
~~~

**Rationale**: Design decisions are expensive to reverse once tasks are created and
implementation begins. This is the last low-cost opportunity to correct course.
```

#### 1.3: Actualizar el diagrama de flujo

En la sección "The Architecture-First Planning Process" (líneas ~208-234), actualizar el diagrama para incluir los checkpoints:

```markdown
### The Architecture-First Planning Process (with HITL Checkpoints)

~~~
┌─────────────────────────────────────────────────────────────────┐
│                    STEP 0: LOAD PROJECT SPECS                   │
│  Read existing specs → Understand current architecture          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 1: UNDERSTAND                          │
│  Analyze request → Ask clarifying questions → Document problem  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 2: SPECS + INTEGRATION ANALYSIS        │
│  Define WHAT the system must do + Integration impact            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  HITL CHECKPOINT │ ← User validates specs
                    │  Specs Review    │
                    └─────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 3: SOLUTIONS + ARCHITECTURAL IMPACT    │
│  Design HOW + SOLID constraint + Impact analysis                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  HITL CHECKPOINT │ ← User validates design
                    │  Design Review   │
                    └─────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 4: TASKS                               │
│  Task breakdown with TDD, SOLID requirements, verify conditions │
└─────────────────────────────────────────────────────────────────┘
~~~
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Añadir 2 secciones HITL + actualizar diagrama |
| `core/roles/planner.md` | Mencionar responsabilidad de presentar checkpoints |

---

## Mejora 2: Reflection Pattern en Quality Gates (P0)

### Problema

Los Quality Gates actuales son checks estáticos (4 condiciones booleanas). El agente verifica una checklist pero no reflexiona críticamente sobre su propio output. Esto lleva a pasar Quality Gates con contenido técnicamente correcto pero conceptualmente débil.

### Ubicación en plan.md

Modificar cada Quality Gate (Phase 1: ~línea 401, Phase 2: ~línea 591, Phase 3: ~línea 831).

### Cambio Propuesto

#### 2.1: Añadir paso de Reflexión Crítica antes de los checks

Insertar antes de cada bloque `PHASE N QUALITY CHECK`:

```markdown
### Reflection Step (before Quality Gate checks)

Before running the formal Quality Gate checks, switch to a critical reviewer mindset:

~~~
REFLECTION PROTOCOL (pre-Quality Gate):

  ROLE SWITCH: You are now a CRITICAL REVIEWER, not the planner.

  Ask yourself these questions about the phase output:

  1. ASSUMPTIONS: What assumptions did I make that I haven't validated?
     - List each assumption explicitly
     - Mark which ones are validated vs. unvalidated

  2. WEAKNESSES: What is the weakest part of this output?
     - Identify the section with least confidence
     - Explain why it's weak

  3. GAPS: What did the user ask for that I might have missed or glossed over?
     - Re-read the original request
     - Compare against what I produced

  4. ALTERNATIVES: Did I consider alternative approaches? Why did I choose this one?
     - If no alternatives were considered, flag this as a concern

  OUTPUT: Write a brief "## Reflection Notes" section (3-5 bullet points)
  at the end of the phase output file. These notes are for transparency,
  not for blocking progress.

  THEN proceed to the formal Quality Gate checks.
~~~
```

#### 2.2: Integrar las Reflection Notes en el output

Cada archivo de output (`proposal.md`, `specs.md`, `design.md`) debe incluir al final:

```markdown
## Reflection Notes

- **Assumption**: [assumption made and validation status]
- **Weakness**: [weakest aspect identified]
- **Gap risk**: [potential gap with original request]
- **Alternatives**: [alternatives considered or "none — single approach"]
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Añadir Reflection Protocol antes de cada Quality Gate |

---

## Mejora 3: Test Contract Sketch en Phase 2 (P0)

### Problema

Los tests solo aparecen como "Tests to Write FIRST" dentro de cada task (Phase 4). No se valida que las specs sean testeables a nivel de contrato antes de diseñar soluciones. Esto genera specs que son difíciles de verificar.

### Ubicación en plan.md

Añadir un sub-paso después de "Integration Analysis" en Phase 2 (después de ~línea 589).

### Cambio Propuesto

#### 3.1: Añadir Step 2.D — Test Contract Sketch

```markdown
#### Step 2.D: Test Contract Sketch (Acceptance Test Outlines)

Before closing Phase 2, sketch the top-level acceptance tests that validate the specs.
These are NOT implementation tests — they are behavioral contracts that verify the specs
are testable and unambiguous.

~~~
TEST CONTRACT SKETCH PROTOCOL:

For each functional spec (SPEC-F01, SPEC-F02, etc.):
  1. Write 1-3 acceptance test outlines in Given/When/Then format
  2. Each test must map directly to an acceptance criterion from the spec
  3. If a test cannot be written, the spec is AMBIGUOUS — revise it

FORMAT (append to specs.md):

## Test Contract Sketch

### SPEC-F01: [Title]
| Test | Given | When | Then | Criterion |
|------|-------|------|------|-----------|
| TC-01 | A new user with valid email | They submit registration | Account created, confirmation returned | AC-01 |
| TC-02 | A user with duplicate email | They submit registration | Error returned, no account created | AC-02 |

### SPEC-F02: [Title]
| Test | Given | When | Then | Criterion |
|------|-------|------|------|-----------|
| TC-03 | ... | ... | ... | AC-03 |

VALIDATION:
  - Every acceptance criterion must have at least 1 test contract
  - If any criterion has 0 tests → spec is incomplete, revise before proceeding
  - These test contracts become the foundation for "Tests to Write FIRST" in Phase 4
~~~
```

#### 3.2: Actualizar Phase 2 Quality Gate

Añadir un CHECK 5 al Quality Gate de Phase 2:

```markdown
    CHECK 5: Does every spec have a Test Contract Sketch?
      - Each acceptance criterion maps to at least 1 test outline
      - Tests are in Given/When/Then format
      - FAIL if any criterion lacks a test contract
```

#### 3.3: Actualizar Phase 4 Task Template

En la sección "Task Template" (~línea 929), añadir referencia a los test contracts:

```markdown
**Tests to Write FIRST** (from Test Contract Sketch in specs.md):
- [ ] TC-01: test_user_can_register_with_valid_email() ← from SPEC-F01
- [ ] TC-02: test_duplicate_email_returns_error() ← from SPEC-F01
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Añadir Step 2.D + CHECK 5 en QG2 + actualizar Task Template |
| `core/templates/spec-template.md` | Añadir sección Test Contract Sketch |

---

## Mejora 4: SOLID Justification con Evidencia Estructurada (P0)

### Problema

El refactor SOLID ya integrado (commits `9367306`, `84b4aa5`, `f10479c`) transformó exitosamente el sistema de scores numéricos (22/25) a verdicts contextuales (COMPLIANT/NEEDS_WORK/NON_COMPLIANT) con justificación narrativa. El `solid-analyzer` ya emite per-principle analysis con evidencia (ver Mode 2: DESIGN_VALIDATE output). Sin embargo, el formato que `plan.md` Phase 3 Step 3.2 usa para **lo que el planner escribe en `design.md`** (líneas 670-676) todavía usa justificaciones en texto libre por línea, sin estructura que obligue a referenciar archivos concretos como evidencia. Esto puede llevar a justificaciones genéricas que pasan el Quality Gate CHECK 3 sin referenciar código real.

### Ubicación en plan.md

Modificar la sección "Step 3.2: Design Solutions with SOLID" (~línea 658).

### Cambio Propuesto

#### 4.1: Elevar formato de justificación SOLID a tabla con Evidence

El formato actual en `plan.md` Step 3.2:

```markdown
**SOLID Compliance**:
- **SRP**: COMPLIANT — User entity only holds data, validation logic isolated in Email ValueObject
```

Funciona pero permite justificaciones sin referencia a archivos. Elevar a formato tabular con columna de Evidence obligatoria, alineado con el output del `solid-analyzer --mode=design`:

```markdown
### SOLID Justification Protocol

Each SOLID verdict in Phase 3 MUST follow this format:

~~~
**SOLID Compliance** (with mandatory justification):

| Principle | Verdict | Justification | Evidence |
|-----------|---------|---------------|----------|
| SRP | COMPLIANT | User entity holds only data fields. Validation extracted to Email ValueObject. No business logic in entity. | `Domain/Entity/User.php` — data only; `Domain/ValueObject/Email.php` — validation |
| OCP | COMPLIANT | New validators added via Strategy pattern without modifying User. | `Domain/Validator/ValidatorInterface.php` — extension point |
| LSP | N/A | No inheritance hierarchy in this solution. All types are concrete or implement interfaces. | No subtypes defined |
| ISP | COMPLIANT | Repository interface has 3 methods (find, save, delete). No client forced to depend on unused methods. | `Domain/Repository/UserRepositoryInterface.php` — 3 focused methods |
| DIP | COMPLIANT | Domain depends on abstractions (interfaces). Infrastructure implements them. No direct imports from Infrastructure in Domain. | `Domain/Repository/UserRepositoryInterface.php` ← abstraction; `Infrastructure/Repository/DoctrineUserRepository.php` ← implementation |

RULES:
  - "Justification" must explain WHY the verdict was given (not just restate the principle)
  - "Evidence" must reference concrete file paths or design decisions
  - N/A verdicts must explain why the principle does not apply to this specific solution
  - Verdicts without justification are INVALID and fail the Quality Gate
~~~
```

#### 4.2: Actualizar Phase 3 Quality Gate CHECK 3

Cambiar de:

```
CHECK 3: Does each relevant SOLID principle have a reasoned verdict?
```

A:

```
CHECK 3: Does each SOLID verdict have a textual justification with file evidence?
  - Each verdict must include WHY (not just a label)
  - Each verdict must reference concrete files or design decisions
  - FAIL if any verdict lacks justification or evidence columns
  - FAIL if justification merely restates the principle definition
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Elevar formato SOLID en Step 3.2 a tabla con justificación + evidencia |

> **Nota**: El `solid-analyzer` ya emite output con evidencia por principio (ver Mode 2: DESIGN_VALIDATE). Esta mejora alinea lo que el **planner escribe en design.md** con ese nivel de detalle.

---

## Mejora 5: Decision Log / Trazabilidad (P1)

### Problema

El `tasks.md` registra estado de progreso pero no decisiones tomadas ni alternativas descartadas. Cuando se revisa el plan después, no hay forma de entender *por qué* se eligió un approach sobre otro.

### Ubicación en plan.md

Añadir al output de `design.md` y al `tasks.md` Workflow State.

### Cambio Propuesto

#### 5.1: Añadir Decision Log a design.md

En la sección "design.md Structure" (~línea 1135), expandir "Key Decisions":

```markdown
### design.md Structure (updated)

~~~markdown
## Key Decisions (Decision Log)

| ID | Decision | Alternatives Considered | Rationale | Phase | Risk |
|----|----------|------------------------|-----------|-------|------|
| D-001 | Use JWT for auth tokens | Session-based auth, OAuth tokens | Stateless, scales horizontally, matches existing API pattern | Phase 3 | LOW — industry standard |
| D-002 | Repository pattern for persistence | Active Record, Direct ORM | Project already uses Repository pattern (see Order entity), DIP compliance | Phase 3 | LOW — consistent with codebase |
| D-003 | Separate Email Value Object | Inline validation in entity | SRP compliance, reusable across entities, testable in isolation | Phase 3 | LOW |

RULES:
  - Every non-trivial design choice must have an entry
  - "Alternatives Considered" must list at least 1 alternative (even if obvious choice)
  - "Rationale" must explain WHY this option was chosen over alternatives
  - If user requested a specific approach, note: "User preference" in Rationale
~~~
```

#### 5.2: Añadir Decision Summary al Workflow State

En el template de `tasks.md` (~línea 79), añadir:

```markdown
### Decision Summary
| Total Decisions | User-Directed | Agent-Decided | Deferred |
|-----------------|---------------|---------------|----------|
| ${N} | ${U} | ${A} | ${D} |

See design.md "Key Decisions" for full log.
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Expandir design.md structure + actualizar tasks.md template |

---

## Mejora 6: Feedback Loop / Retrospectiva (P1)

### Problema

El plan es un proceso lineal sin mecanismo de retroalimentación. Lo que se aprende en una sesión de planificación no alimenta las siguientes.

### Ubicación en plan.md

Añadir paso post-completeness como última sección antes de "Related Commands".

### Cambio Propuesto

#### 6.1: Añadir Retrospectiva Post-Planificación

Insertar después de "Plan Completeness Verification" (~línea 1089):

```markdown
## Post-Planning Retrospective (Optional but Recommended)

After marking planning COMPLETED and before starting `/workflows:work`, capture
what worked and what didn't in the planning process itself.

~~~
RETROSPECTIVE PROTOCOL:

IF user agrees to retrospective (or if planning took >2 HITL revisions):

  CREATE: openspec/changes/${FEATURE_ID}/99_retrospective.md

  ## Planning Retrospective: ${FEATURE_ID}

  ### What Worked Well
  - [Aspects of planning that went smoothly]

  ### What Was Revised
  - [Specs/design that were changed after HITL checkpoints]
  - [Quality Gate failures and how they were resolved]

  ### Assumptions That Were Wrong
  - [Assumptions from Phase 1 that proved incorrect in later phases]

  ### Patterns to Reuse
  - [Design patterns or approaches that should be captured for future features]

  ### Gaps Discovered Late
  - [Requirements or constraints discovered in Phase 3/4 that should have been in Phase 1/2]

  ### Recommendations for Future Planning
  - [Process improvements for next planning session]

  ---
  This file is consumed by `/workflows:compound` to enrich project learnings.
~~~

**Integration with compound workflow**: The retrospective feeds into
`/workflows:compound` which can extract patterns and update the project's
learned patterns in `architecture-profile.yaml`.
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Añadir sección Retrospective Protocol |
| `commands/workflows/compound.md` | Añadir lectura de `99_retrospective.md` como fuente de learnings |

---

## Mejora 7: Chunking Explícito por Fase (P1)

### Problema

El plan pide generar archivos enteros de una vez (specs, design, tasks). Para features complejas con >5 specs, esto produce outputs monolíticos que degradan la calidad del LLM.

### Ubicación en plan.md

Añadir directivas de chunking en cada fase.

### Cambio Propuesto

#### 7.1: Añadir Chunking Protocol

Insertar como subsección del "Incremental Persistence Protocol" (~línea 58):

```markdown
### Chunking Protocol (Anti-Monolithic Output)

For complex features, break generation into manageable chunks to maintain quality:

~~~
CHUNKING RULES:

Phase 2 (Specs):
  IF number_of_specs > 5:
    Generate specs in groups of 3-5
    Run Quality Gate checks on each group
    Consolidate into final specs.md
    Verify cross-group consistency

Phase 3 (Design):
  IF number_of_solutions > 5:
    Design solutions in groups of 3
    Run SOLID analysis per group
    Consolidate into final design.md
    Verify inter-solution consistency (shared patterns, no contradictions)

Phase 4 (Tasks):
  IF number_of_tasks > 8:
    Generate tasks in groups by role (Backend, Frontend, QA)
    Verify cross-group dependencies are captured
    Consolidate into final tasks.md

GENERAL RULE:
  Never generate more than ~200 lines of structured content in a single
  generation step. If the expected output exceeds this, chunk it.

  After each chunk:
    1. Write partial output to disk (append to file)
    2. Verify consistency with previous chunks
    3. Continue with next chunk
~~~
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Añadir Chunking Protocol subsección |

---

## Mejora 8: Security Threat Analysis en Phase 3 (P1)

### Problema

El plan menciona SOLID exhaustivamente pero no tiene un paso dedicado a seguridad en la fase de diseño. Las reglas de seguridad existen en `core/rules/security-rules.md` pero no se invocan durante el planning.

### Ubicación en plan.md

Añadir como Step 3.6 después de "Architectural Impact Analysis" (~línea 829).

### Cambio Propuesto

#### 8.1: Añadir Step 3.6 — Security Threat Analysis

```markdown
#### Step 3.6: Security Threat Analysis (when feature involves user input, auth, or data)

For features that handle user input, authentication, authorization, or sensitive data,
perform a lightweight threat analysis as part of Phase 3 design.

~~~
SECURITY THREAT ANALYSIS PROTOCOL:

APPLICABILITY CHECK:
  Does this feature involve any of these?
  - [ ] User input (forms, API parameters, file uploads)
  - [ ] Authentication or authorization changes
  - [ ] Sensitive data (PII, passwords, tokens, financial data)
  - [ ] External API integration
  - [ ] New endpoints exposed to the internet

  IF none checked → Mark "Security: N/A — no attack surface" in design.md, skip analysis
  IF any checked → Perform analysis below

ANALYSIS (append to design.md):

## Security Threat Analysis

### Attack Surface
| Surface | Type | Risk Level |
|---------|------|------------|
| POST /api/auth/register | User input | HIGH — accepts email, password |
| POST /api/auth/login | User input + auth | HIGH — credential handling |

### Input Validation Requirements
| Input | Validation Required | Location |
|-------|---------------------|----------|
| email | Format + uniqueness | Domain/ValueObject/Email.php |
| password | Length ≥8, complexity rules | Application/Service/AuthService.php |

### Auth/Authz Requirements
| Endpoint | Auth Required | Roles | Notes |
|----------|---------------|-------|-------|
| POST /register | No | Public | Rate limiting required |
| POST /login | No | Public | Brute-force protection required |
| GET /profile | Yes | Authenticated | Own profile only |

### Sensitive Data Handling
| Data | Storage | Encryption | Notes |
|------|---------|------------|-------|
| Password | Hashed (bcrypt) | At rest | Never stored plaintext |
| JWT Token | Not stored server-side | In transit (HTTPS) | Short expiry |

### OWASP Top 10 Quick Check
| Risk | Applicable | Mitigation in Design |
|------|-----------|---------------------|
| Injection | YES | Parameterized queries via Repository pattern |
| Broken Auth | YES | JWT with refresh rotation, bcrypt hashing |
| Sensitive Data Exposure | YES | HTTPS only, password never in responses |
| Broken Access Control | YES | Middleware auth check on protected routes |
| Security Misconfiguration | NO | N/A for this feature |

RULES:
  - This is a LIGHTWEIGHT analysis, not a full threat model
  - Focus on threats specific to THIS feature's design
  - Reference security-rules.md for project-specific security constraints
  - If HIGH risk items found, add security-specific tasks in Phase 4
~~~
```

#### 8.2: Actualizar Phase 4 Task Template

Añadir al template de tasks:

```markdown
**Security Requirements** (from Security Threat Analysis, if applicable):
- [ ] Input validation for email (format + uniqueness)
- [ ] Password hashing with bcrypt before storage
- [ ] Rate limiting on public auth endpoints
```

#### 8.3: Actualizar Planning Checklist

En la sección "Planning Checklist" (~línea 962), añadir:

```markdown
### Phase 3: Solutions + Architectural Impact + Security
- [ ] **Security threat analysis completed** (or marked N/A with justification)
- [ ] **Security-specific tasks added to Phase 4** (if HIGH risk items found)
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Añadir Step 3.6 + actualizar Task Template + actualizar Checklist |
| `core/rules/security-rules.md` | Referenciar desde plan.md Security Threat Analysis |
| `agents/review/security-reviewer.md` | Asegurar que valide lo producido en Step 3.6 |

---

## Mejora 9: Rollback Protocol (P2)

### Problema

La persistencia incremental escribe archivos, pero no hay guía sobre qué hacer cuando una fase produce resultados incorrectos tras agotar las 3 iteraciones del Quality Gate.

### Ubicación en plan.md

Añadir como subsección del "Incremental Persistence Protocol" (~línea 58).

### Cambio Propuesto

#### 9.1: Añadir Rollback Protocol

```markdown
### Rollback Protocol (Phase Recovery)

If a Quality Gate fails after exhausting 3 iterations, or if an HITL checkpoint
results in "revise" that requires fundamental changes:

~~~
ROLLBACK PROTOCOL:

SCENARIO 1: Quality Gate exhausted (3 iterations, still failing)
  1. WRITE current best version with "## Quality Warnings" (existing behavior)
  2. ASK user: "Phase ${N} quality concerns: [list]. Options:
     a) Proceed anyway (accept risks)
     b) Rollback to Phase ${N-1} and revise assumptions
     c) Restart planning with different scope"
  3. IF rollback:
     - Mark Phase ${N} as ROLLED_BACK in tasks.md Workflow State
     - Re-open Phase ${N-1} output file for revision
     - Re-run Phase ${N-1} with new context from failed attempt
     - Proceed forward again

SCENARIO 2: HITL checkpoint reveals fundamental spec error
  1. User says "revise" with changes that affect previous phases
  2. Identify which upstream phase is affected:
     - If specs need to change → Rollback to Phase 2
     - If problem statement was wrong → Rollback to Phase 1
  3. Mark rolled-back phases as REVISED in tasks.md
  4. Re-execute from the rolled-back phase forward
  5. Log the rollback reason in Decision Log

WORKFLOW STATE values for rollback:
  | Status | Meaning |
  |--------|---------|
  | PENDING | Not started |
  | IN_PROGRESS | Currently executing |
  | COMPLETED | Successfully finished |
  | ROLLED_BACK | Was completed, then rolled back for revision |
  | REVISED | Rolled back and re-completed with changes |
~~~
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Añadir Rollback Protocol + nuevos estados de Workflow |

---

## Mejora 10: Right-Sizing de Modelo (P2)

### Problema

No hay guía sobre qué capacidad de modelo es recomendable para cada fase. Algunas fases requieren razonamiento profundo (Phase 1, 3) mientras que otras son más mecánicas (Quality Gates, Phase 4).

### Ubicación en plan.md

Añadir como nota en "Planning Depth Resolution" (~línea 177).

### Cambio Propuesto

#### 10.1: Añadir Model Recommendations

```markdown
### Model Capability Recommendations (informational)

When the plugin is used with systems that support model routing or capability providers,
these are the recommended capability levels per phase:

| Phase | Recommended Capability | Reason |
|-------|----------------------|--------|
| Step 0 (Load Specs) | Standard | Data retrieval, no reasoning |
| Phase 1 (Understand) | High | Deep comprehension, ambiguity resolution |
| Phase 2 (Specs) | High | Creative structuring + integration analysis |
| Quality Gates | Standard | Structured verification, checklist matching |
| Reflection Steps | High | Critical self-analysis requires reasoning |
| Phase 3 (Design) | High | Architecture decisions, pattern selection, SOLID |
| Security Analysis | High | Threat modeling requires broad knowledge |
| Phase 4 (Tasks) | Standard | Template-based generation from Phase 2+3 outputs |
| HITL Summaries | Standard | Summarization of existing content |

NOTE: This is informational. The plugin operates with whatever model is available.
These recommendations are for systems that support model routing via
`core/providers.yaml` capability_providers.
```

### Archivos Afectados

| Archivo | Cambio |
|---------|--------|
| `commands/workflows/plan.md` | Añadir tabla de recomendaciones |
| `core/providers.yaml` | Potencialmente añadir provider hints por fase |

---

## Plan de Implementación

### Fase de Implementación 1 (P0 — Alto Impacto)

| Orden | Mejora | Secciones de plan.md afectadas |
|-------|--------|-------------------------------|
| 1 | Mejora 1: HITL entre fases | Diagrama de flujo, post-QG2, post-QG3, Complete Workflow |
| 2 | Mejora 2: Reflection Pattern | Pre-QG1, Pre-QG2, Pre-QG3 |
| 3 | Mejora 4: SOLID Justification | Step 3.2, QG3 CHECK 3, design.md structure |
| 4 | Mejora 3: Test Contract Sketch | Step 2.D (nuevo), QG2 CHECK 5, Task Template |

### Fase de Implementación 2 (P1 — Impacto Medio)

| Orden | Mejora | Secciones de plan.md afectadas |
|-------|--------|-------------------------------|
| 5 | Mejora 5: Decision Log | design.md structure, tasks.md template |
| 6 | Mejora 6: Retrospectiva | Nueva sección post-completeness |
| 7 | Mejora 7: Chunking | Subsección de Incremental Persistence |
| 8 | Mejora 8: Security | Step 3.6 (nuevo), Task Template, Checklist |

### Fase de Implementación 3 (P2 — Impacto Bajo)

| Orden | Mejora | Secciones de plan.md afectadas |
|-------|--------|-------------------------------|
| 9 | Mejora 9: Rollback | Subsección de Incremental Persistence |
| 10 | Mejora 10: Right-sizing | Planning Depth Resolution |

---

## Archivos Totales Afectados

| Archivo | Mejoras que lo tocan | Tipo de cambio |
|---------|---------------------|----------------|
| `commands/workflows/plan.md` | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 | MODIFY (principal) |
| `core/roles/planner.md` | 1 | MODIFY (menor) |
| `core/templates/spec-template.md` | 3 | MODIFY (añadir sección) |
| `skills/workflow-skill-solid-analyzer.md` | — | No requiere cambios (ya alineado con refactor SOLID) |
| `commands/workflows/compound.md` | 6 | MODIFY (añadir fuente) |
| `core/rules/security-rules.md` | 8 | MODIFY (cross-reference) |
| `agents/review/security-reviewer.md` | 8 | MODIFY (validación) |
| `core/providers.yaml` | 10 | MODIFY (hints opcionales) |

**Total: 8 archivos a modificar, 0 archivos nuevos requeridos.**

---

## Criterios de Éxito

El plan de mejora se considera completo cuando:

1. Cada Quality Gate incluye un paso de Reflexión previo
2. Existen checkpoints HITL obligatorios entre Phase 2→3 y Phase 3→4
3. Phase 2 incluye Test Contract Sketch como Step 2.D
4. SOLID verdicts en Phase 3 requieren justificación textual con evidencia de archivos
5. `design.md` incluye un Decision Log con alternativas consideradas
6. Existe protocolo de retrospectiva post-planificación
7. Hay directivas de chunking para features complejas (>5 specs)
8. Phase 3 incluye Security Threat Analysis para features con attack surface
9. Existe protocolo de rollback para fallas en Quality Gates
10. Hay recomendaciones de capacidad de modelo por fase

---

## Relación con solid-intelligence-refactor.md

El refactor de inteligencia SOLID (`plans/solid-intelligence-refactor.md`) **ya fue implementado completamente** en el plugin (commits `9367306`, `84b4aa5`, `f10479c`). El plugin ya incorpora:

- Verdicts contextuales (COMPLIANT/NEEDS_WORK/NON_COMPLIANT) en lugar de scores numéricos
- `architecture-reference.md` (merge de `solid-pattern-matrix.md` + `architecture-quality-criteria.md`)
- `architecture-profile-template.yaml` para perfiles de proyecto
- `solid-analyzer` con 3 modos (BASELINE, DESIGN_VALIDATE, CODE_VERIFY)
- Stack-adapted detection (PHP, Go, Python, TypeScript, Functional)
- Actualizaciones en `discover.md`, `work.md`, `review.md`, `compound.md`

Las mejoras de este plan se construyen **sobre** ese trabajo ya integrado. En particular, la Mejora 4 (SOLID Justification con Evidencia Estructurada) eleva el formato de justificación en `design.md` para alinearlo con el nivel de detalle que el `solid-analyzer --mode=design` ya produce en su output.
