# Plan: Control-Plane Determinista para el Plugin Workflow

**Fecha**: 2026-02-20
**Estado**: BORRADOR — Pendiente de revisión
**Branch**: `claude/review-chatgpt-conversation-8qOYi`
**Origen**: Análisis de la conversación ChatGPT sobre el artículo de Ryan Carson (@ryancarson)

---

## Contexto

El artículo de Carson propone convertir el repo en un "control-plane" con enforcement determinista.
La conversación con ChatGPT sugirió 3 archivos como MVP. Este plan los adapta al repo real.

### Qué ya existe (y la conversación ChatGPT no capturó)

El plugin ya tiene gobierno interno sofisticado:
- Flow Guards (ROUTE→PLAN→WORK→REVIEW→COMPOUND)
- Quality Gates con checklists por fase
- Bounded Correction Protocol (3 tipos de desviación)
- SOLID enforcement contextual (en refactoring activo — ver `solid-intelligence-refactor.md`)
- 14 fases de mejora planificadas (ver `plugin-improvement-plan.md`)
- Investigación de mejores prácticas (ver `ai-workflow-improvement-plan.md`)

### Qué falta (el gap real)

Todo el gobierno actual depende de que el LLM siga las instrucciones.
**No hay enforcement externo, determinista, que corra independientemente del agente.**

Un `risk-policy-gate` como GitHub Action da una capa de seguridad que:
- Corre sin LLM (Python puro, stdlib)
- Es auditable (logs, exit codes)
- Bloquea merges que violan la política
- Es independiente de qué agente escribió el código

---

## Los 3 Archivos a Implementar

### 1. `control-plane/contract.json`

Contrato machine-readable adaptado a la estructura real del repo.

**Diferencias vs propuesta ChatGPT**:
- Risk tiers alineados con la complejidad real de cada directorio
- `docsDriftRules` que reflejan las dependencias reales entre archivos
- Sin `requiresReviewAgent` (no hay review agent externo configurado hoy)
- Añadido: `sha_discipline` como campo explícito del contrato

**Estructura**:
```json
{
  "version": "1",
  "riskTierRules": {
    "high": [
      "plugins/multi-agent-workflow/core/**",
      "plugins/multi-agent-workflow/commands/**",
      "plugins/multi-agent-workflow/agents/**",
      "plugins/multi-agent-workflow/CLAUDE.md",
      ".claude/**",
      "control-plane/**"
    ],
    "medium": [
      "plugins/multi-agent-workflow/skills/**",
      "plugins/multi-agent-workflow/core/templates/**",
      "plans/**"
    ],
    "low": [
      "**"
    ]
  },
  "mergePolicy": {
    "high": {
      "requiredChecks": ["risk-policy-gate", "ci"]
    },
    "medium": {
      "requiredChecks": ["risk-policy-gate", "ci"]
    },
    "low": {
      "requiredChecks": ["risk-policy-gate"]
    }
  },
  "docsDriftRules": [
    {
      "name": "core-change-requires-docs",
      "ifChanged": [
        "plugins/multi-agent-workflow/core/rules/**",
        "plugins/multi-agent-workflow/core/roles/**"
      ],
      "mustAlsoChangeOneOf": [
        "plugins/multi-agent-workflow/CLAUDE.md",
        "plugins/multi-agent-workflow/README.md",
        "plans/**"
      ]
    },
    {
      "name": "command-change-requires-docs",
      "ifChanged": ["plugins/multi-agent-workflow/commands/**"],
      "mustAlsoChangeOneOf": [
        "plugins/multi-agent-workflow/CLAUDE.md",
        "plugins/multi-agent-workflow/README.md",
        "plans/**"
      ]
    },
    {
      "name": "contract-change-requires-plan",
      "ifChanged": ["control-plane/contract.json"],
      "mustAlsoChangeOneOf": [
        "plans/**"
      ]
    }
  ],
  "shaDiscipline": {
    "enforced": true,
    "description": "All evidence (checks, reviews) must reference the current HEAD SHA. Stale evidence is invalid."
  }
}
```

**Decisión de diseño**: `core/rules/**` y `commands/**` son high porque cambios ahí alteran el comportamiento de TODOS los workflows. Un cambio en `framework_rules.md` sin actualizar CLAUDE.md crea drift invisible.

---

### 2. `scripts/risk_policy_gate.py`

Script Python 3 (stdlib only) que:
1. Lee `control-plane/contract.json`
2. Detecta archivos cambiados (vía `git diff` o input)
3. Calcula risk tier (highest tier wins)
4. Valida docs drift rules
5. Emite resultado (exit 0 = pass, exit 1 = fail)

**Diferencias vs propuesta ChatGPT** (que se cortó antes de mostrar el código):
- Implementación completa (ChatGPT no la entregó)
- Funciona tanto local (para desarrollo) como en CI
- Output en JSON para integración con otros sistemas
- Glob matching con `fnmatch` (stdlib, sin dependencias)

**Interfaz**:
```bash
# Uso en CI (detecta cambios automáticamente vs base branch)
python3 scripts/risk_policy_gate.py --base origin/main

# Uso local (archivos explícitos)
python3 scripts/risk_policy_gate.py --files "plugins/multi-agent-workflow/core/rules/framework_rules.md"

# Output JSON para integración
python3 scripts/risk_policy_gate.py --base origin/main --json
```

**Output ejemplo**:
```
[GATE] Risk tier: high
[GATE] Changed files: 3
[GATE] Required checks: risk-policy-gate, ci
[GATE] Docs drift check: PASS
[GATE] Result: PASS
```

---

### 3. `.github/workflows/risk-policy-gate.yml`

GitHub Actions workflow que:
1. Se ejecuta en `pull_request` (opened, synchronize, reopened)
2. Corre `scripts/risk_policy_gate.py` contra la base del PR
3. Falla si el gate no pasa
4. Emite outputs (tier, required checks) para workflows downstream

**Características**:
- Solo requiere Python 3 (ya incluido en runners de GitHub)
- Corre primero (antes de CI pesado) — patrón preflight del artículo
- SHA del HEAD está en el contexto del workflow (gratis)

---

## Orden de Implementación

```
1. control-plane/contract.json     ← Define las reglas
2. scripts/risk_policy_gate.py     ← Ejecuta las reglas
3. .github/workflows/risk-policy-gate.yml  ← Automatiza la ejecución
```

Sin dependencias entre pasos — pero el orden lógico es contrato → script → workflow.

---

## Lo Que NO Incluye Este Plan (intencionalmente)

| Excluido | Razón |
|----------|-------|
| Review agent externo (Greptile/CodeRabbit) | Añade complejidad sin valor claro para un repo de 1 contributor |
| Remediation agent | El plugin ya tiene BCP + diagnostic-agent para correcciones |
| Browser evidence harness | No aplica — el plugin genera markdown, no UI |
| Rerun canonical writer | Solo tiene sentido con review agent externo |
| Auto-resolve bot threads | Solo tiene sentido con review agent externo |
| Incident → harness loop | Buena idea, pero fase 2 — primero el gate básico |

---

## Relación con Planes Existentes

- **plugin-improvement-plan.md**: Complementa — aquel plan mejora el gobierno *interno* del agente, este añade gobierno *externo* determinista
- **ai-workflow-improvement-plan.md**: Complementa — aquel investiga mejores prácticas, este implementa una concreta
- **solid-intelligence-refactor.md**: Independiente — no se solapan

---

## Verificación Final

```bash
# El gate debe pasar en el estado actual del repo:
python3 scripts/risk_policy_gate.py --base origin/main

# El contrato debe ser JSON válido:
python3 -m json.tool control-plane/contract.json

# El workflow debe tener syntax válido:
# (se valida automáticamente al pushear a GitHub)
```
