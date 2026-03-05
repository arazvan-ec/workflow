# Workflow Decision Matrix

**Version**: 3.2.0
**Purpose**: Guide for selecting the appropriate workflow based on user needs

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW SELECTION QUICK GUIDE                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  🆕 NUEVA FUNCIONALIDAD                                                 │
│     └── Simple (< 2h)     → /workflows:plan --workflow=default          │
│     └── Compleja (> 2h)   → /workflows:plan --workflow=task-breakdown   │
│                                                                         │
│  🐛 BUG FIX                                                             │
│     └── Reproducible      → diagnostic-agent → implementation-only      │
│     └── Intermitente      → codebase-analyzer                           │
│                                                                         │
│  🔄 REFACTORING                                                         │
│     └── Localizado        → /workflows:work (directo)                   │
│     └── Sistémico         → /workflows:plan --workflow=task-breakdown   │
│                                                                         │
│  🔍 INVESTIGACIÓN                                                       │
│     └── Código            → codebase-analyzer agent                     │
│                                                                         │
│  📝 DOCUMENTACIÓN                                                       │
│     └── Técnica           → /workflows:work --role=planner              │
│                                                                         │
│  ✅ CODE REVIEW                                                         │
│     └── General           → /workflows:review                           │
│     └── Seguridad         → security-reviewer agent                     │
│     └── Performance       → performance-reviewer agent                  │
│     └── Architecture      → architecture-reviewer agent                 │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Detailed Decision Matrix

### By User Need Type

| Need Type | Indicators | Workflow | Command | Notes |
|-----------|------------|----------|---------|-------|
| **New Feature** | "quiero añadir", "necesito implementar", "crear funcionalidad" | task-breakdown | `/workflows:plan --workflow=task-breakdown` | Full planning phase |
| **Quick Feature** | "simple", "pequeño cambio", "< 1 hora" | default | `/workflows:plan --workflow=default` | Simplified planning |
| **Bug Fix** | "no funciona", "error", "falla", "bug" | implementation-only | `/workflows:plan --workflow=implementation-only` | Skip to implementation |
| **Refactor** | "refactorizar", "limpiar", "mejorar código" | Depends on scope | See refactoring section | Assess impact first |
| **Investigation** | "cómo funciona", "dónde está", "por qué" | N/A | Invoke research agents | No workflow needed |
| **Documentation** | "documentar", "README", "explicar" | N/A | `/workflows:work --role=planner` | Docs only mode |
| **Code Review** | "revisar", "review", "validar" | N/A | `/workflows:review` | Multi-agent review |
| **Setup/Config** | "configurar", "instalar", "setup" | N/A | Invoke consultant | Guidance mode |

### By Complexity Assessment

| Complexity | Time Estimate | Files Affected | Workflow | Planning Depth |
|------------|---------------|----------------|----------|----------------|
| **Trivial** | < 30 min | 1-2 files | implementation-only | Minimal |
| **Simple** | 30 min - 2 hours | 3-5 files | default | Basic |
| **Medium** | 2-8 hours | 5-15 files | task-breakdown | Full |
| **Complex** | > 8 hours | 15+ files | task-breakdown | Comprehensive |
| **Architectural** | Days/weeks | System-wide | task-breakdown + design agents | Deep analysis |

### By Dimensional Impact

When `openspec/specs/api-architecture-diagnostic.yaml` exists, consider the request's impact on the project's dimensional profile:

| Dimensional Change | Current → New | Complexity Impact | Minimum Workflow |
|---|---|---|---|
| No dimension change | (stays same) | None | Per complexity assessment |
| Adds consumer diversity | single → multi_platform | Medium | task-breakdown |
| Adds data aggregation | single_db → multi_external | High | task-breakdown + shape |
| Adds external vendor | no_externals → single_external | Medium | task-breakdown |
| Introduces concurrency | synchronous → async_capable | Medium | task-breakdown |
| Multiple changes | e.g., sync+single → async+multi_external | Very High | shape + task-breakdown |

**Rule**: If a request increases dimensional complexity, escalate to at least task-breakdown workflow even if the request appears simple by file count or time estimate.

### By Technology/Area Touched

| Area | Trust Level | Minimum Workflow | Additional Requirements |
|------|-------------|------------------|------------------------|
| Tests only | HIGH | implementation-only | None |
| Documentation | HIGH | implementation-only | None |
| Config files | MEDIUM | default | Review before commit |
| Business logic | MEDIUM | task-breakdown | Tests required |
| API endpoints | MEDIUM | task-breakdown | Contract validation |
| Authentication | LOW | task-breakdown | Security review + pair |
| Authorization | LOW | task-breakdown | Security review + pair |
| Payments | LOW | task-breakdown | Security review + pair |
| Infrastructure | LOW | task-breakdown | Full review required |
| Database migrations | LOW | task-breakdown | Rollback plan required |

---

## Clarification Question Trees

### Feature Request Clarification

```
Q1: ¿Puedes describir la funcionalidad en una frase?
    │
    ▼
Q2: ¿Quién usará esta funcionalidad?
    ├── Usuarios finales → Considerar UX/UI
    ├── Administradores → Considerar permisos
    ├── API consumers → Considerar contratos
    └── Sistema interno → Considerar logging
    │
    ▼
Q3: ¿Qué stack necesita?
    ├── Solo backend → Workflow por layers
    ├── Solo frontend → Workflow por componentes
    └── Fullstack → Workflow por roles
    │
    ▼
Q4: ¿Se integra con servicios externos?
    ├── Sí → Definir contratos primero (en `/workflows:plan`)
    └── No → Proceder normalmente
    │
    ▼
Q5: ¿Maneja datos sensibles?
    ├── Auth/Permisos → Force HIGH control
    ├── Pagos → Force HIGH control + audit
    ├── PII → Force HIGH control + compliance
    └── No → Control según complejidad
```

### Bug Fix Clarification

```
Q1: ¿Funcionaba antes?
    ├── Sí, dejó de funcionar → Buscar commit causante
    └── No, nunca funcionó → Es una feature incompleta
    │
    ▼
Q2: ¿Puedes reproducirlo consistentemente?
    ├── Sí → Invocar diagnostic-agent
    └── No (intermitente) → Necesita investigación profunda
    │
    ▼
Q3: ¿Hay mensaje de error?
    ├── Sí → Analizar stack trace
    └── No → Necesita logging adicional
    │
    ▼
Q4: ¿En qué entorno ocurre?
    ├── Local → Revisar configuración
    ├── Staging → Revisar datos de prueba
    └── Producción → URGENTE - seguir protocolo de incidentes
```

### Refactoring Clarification

```
Q1: ¿Cuál es la motivación?
    ├── Performance → performance-reviewer primero
    ├── Mantenibilidad → code-reviewer primero
    ├── Seguridad → security-reviewer primero
    └── Nuevos requerimientos → Tratar como feature
    │
    ▼
Q2: ¿Cuántos archivos afecta?
    ├── 1-3 archivos → Puede ser directo
    ├── 4-10 archivos → Necesita planificación
    └── 10+ archivos → Requiere task-breakdown completo
    │
    ▼
Q3: ¿Hay tests existentes?
    ├── Sí, buena cobertura → Proceder con confianza
    ├── Parcial → Escribir tests primero
    └── No → OBLIGATORIO escribir tests antes de refactorizar
    │
    ▼
Q4: ¿Cambia la API pública?
    ├── Sí → Coordinar con consumidores
    └── No → Cambio interno seguro
```

---

## Workflow Selection Flowchart

```
                              USER REQUEST
                                   │
                                   ▼
                    ┌──────────────────────────────┐
                    │   ¿Es una pregunta o es      │
                    │   una solicitud de trabajo?  │
                    └──────────────────────────────┘
                           │              │
                      PREGUNTA         TRABAJO
                           │              │
                           ▼              ▼
                    ┌────────────┐  ┌────────────────────┐
                    │ Responder  │  │ ¿Está claro qué    │
                    │ directamente│  │ tipo de trabajo?   │
                    └────────────┘  └────────────────────┘
                                          │         │
                                         SÍ        NO
                                          │         │
                                          │         ▼
                                          │   ┌────────────────┐
                                          │   │ HACER PREGUNTAS│
                                          │   │ CLARIFICADORAS │
                                          │   └────────────────┘
                                          │         │
                                          ▼         ▼
                              ┌─────────────────────────────┐
                              │     CLASIFICAR SOLICITUD    │
                              └─────────────────────────────┘
                                          │
                    ┌─────────┬───────────┼───────────┬─────────┐
                    ▼         ▼           ▼           ▼         ▼
               ┌────────┐┌────────┐┌──────────┐┌──────────┐┌────────┐
               │FEATURE ││  BUG   ││REFACTOR  ││RESEARCH  ││ OTHER  │
               └────────┘└────────┘└──────────┘└──────────┘└────────┘
                    │         │           │           │         │
                    ▼         ▼           ▼           ▼         ▼
               Evaluar    Evaluar     Evaluar      Invocar   Invocar
              complejidad reproducib. impacto     agentes   consultant
                    │         │           │
                    ▼         ▼           ▼
            ┌──────────────────────────────────────┐
            │      SELECCIONAR WORKFLOW YAML       │
            │  - default                           │
            │  - task-breakdown                    │
            │  - implementation-only               │
            └──────────────────────────────────────┘
                              │
                              ▼
            ┌──────────────────────────────────────┐
            │       EVALUAR TRUST LEVEL            │
            │  ¿Toca archivos de bajo trust?       │
            └──────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
               HIGH/MEDIUM            LOW
                    │                   │
                    ▼                   ▼
               Proceder         Forzar controles
               normalmente      adicionales
                    │                   │
                    └─────────┬─────────┘
                              ▼
            ┌──────────────────────────────────────┐
            │    EJECUTAR WORKFLOW SELECCIONADO    │
            └──────────────────────────────────────┘
```

---

## Confidence Scoring

When automatically classifying a request, calculate confidence:

| Signal | Points |
|--------|--------|
| Contains keyword from need type | +20 |
| Contains file/function reference | +15 |
| Mentions specific technology | +10 |
| Clear action verb (add, fix, remove) | +15 |
| Describes expected behavior | +20 |
| Mentions error/bug explicitly | +20 |
| Is a question (?, "cómo", "dónde") | -30 (for work classification) |
| Vague/ambiguous language | -25 |

**Thresholds**:
- Score >= 60: HIGH confidence - proceed directly
- Score 30-59: MEDIUM confidence - confirm with user
- Score < 30: LOW confidence - ask clarifying questions

---

## Integration Points

### With Policy Gate

Risk-tier enforcement happens in `/workflows:work` Step 7, where the policy-gate skill evaluates actual changed files (via `git diff`) against `control-plane/contract.json`. This provides data-driven risk assessment at checkpoint time rather than speculative routing-time guessing.

### With Agents

| Need Type | Primary Agent | Supporting Agents |
|-----------|---------------|-------------------|
| Feature | Planner | Implementer, Reviewer |
| Bug | diagnostic-agent | codebase-analyzer |
| Investigation | codebase-analyzer | - |
| Review | code-reviewer | security-reviewer, performance-reviewer |
| Documentation | Planner | - |

---

## Common Patterns

### Pattern: "Estoy continuando trabajo anterior"

```
Detection: Menciona feature existente, "continuar", "seguir con"
Action:
  1. Verificar estado en tasks.md
  2. Determinar siguiente paso según workflow actual
  3. NO iniciar nuevo routing - continuar workflow existente
```

### Pattern: "No sé qué necesito"

```
Detection: "no estoy seguro", "ayúdame a decidir", vaguedad extrema
Action:
  1. Invocar consultant skill
  2. Hacer preguntas exploratorias
  3. Proponer opciones basadas en contexto del proyecto
```

### Pattern: "Hazlo tú, confío en ti"

```
Detection: Delegación total sin especificaciones
Action:
  1. NUNCA proceder sin clarificación
  2. Explicar que necesitas entender el objetivo
  3. Hacer preguntas mínimas necesarias
  4. Proponer plan antes de ejecutar
```

---

## Summary

This decision matrix ensures:

1. **Consistent routing** - Same type of request always gets same workflow
2. **Appropriate depth** - Complex tasks get comprehensive planning
3. **Safety checks** - Sensitive areas get mandatory reviews
4. **Clear escalation** - When unclear, ask rather than assume

**Golden Rule**: When in doubt, ask. It's faster to clarify than to redo.
