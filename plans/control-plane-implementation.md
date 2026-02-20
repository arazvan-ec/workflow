# Plan: Control-Plane Determinista para el Plugin Workflow

**Fecha**: 2026-02-20
**Estado**: IMPLEMENTADO
**Branch**: `claude/review-chatgpt-conversation-8qOYi`
**Origen**: Análisis de la conversación ChatGPT sobre el artículo de Ryan Carson (@ryancarson)

---

## Contexto

El artículo de Carson propone convertir el repo en un "control-plane" con enforcement determinista.
La conversación con ChatGPT sugirió 3 archivos como MVP (contract.json, script Python, GitHub Action).

### Decisión: Solución nativa de Claude Code

La propuesta original de ChatGPT usaba un script Python + GitHub Action. Esto mezcla paradigmas: el plugin es un sistema nativo de Claude Code basado en markdown, y meter Python + CI rompe esa coherencia.

**Enfoque elegido**: el control-plane se implementa como un **skill del plugin** que el agente ejecuta nativamente, usando el mismo patrón que `checkpoint`, `git-sync` y los demás skills.

**Ventajas**:
- Sin dependencias externas (ni Python, ni CI, ni GitHub Actions)
- Mismo paradigma que el resto del plugin (markdown + agente)
- Funciona en cualquier entorno donde corra Claude Code
- El contrato JSON sigue siendo machine-readable y auditable
- El agente lee, evalúa y reporta — sin scripts intermedios

---

## Qué ya existe (y la conversación ChatGPT no capturó)

El plugin ya tiene gobierno interno sofisticado:
- Flow Guards (ROUTE→PLAN→WORK→REVIEW→COMPOUND)
- Quality Gates con checklists por fase
- Bounded Correction Protocol (3 tipos de desviación)
- SOLID enforcement contextual (en refactoring activo — ver `solid-intelligence-refactor.md`)
- 14 fases de mejora planificadas (ver `plugin-improvement-plan.md`)
- Investigación de mejores prácticas (ver `ai-workflow-improvement-plan.md`)

## Qué faltaba (el gap real)

No había evaluación de riesgo por paths ni detección de drift entre código y documentación. El contrato machine-readable + el skill policy-gate cubren ese gap dentro del ecosistema nativo del plugin.

---

## Los 2 Entregables Implementados

### 1. `control-plane/contract.json`

Contrato machine-readable con:
- **Risk tiers** por path (high/medium/low)
- **Merge policy** con checks requeridos por tier
- **Docs drift rules**: si cambias reglas/comandos, debes actualizar docs
- **SHA discipline**: declaración explícita de que la evidencia debe ser del HEAD actual

### 2. `skills/policy-gate/SKILL.md`

Skill nativo de Claude Code que:
1. Lee `control-plane/contract.json`
2. Detecta archivos cambiados vía `git diff`
3. Calcula tier de riesgo (el más alto gana)
4. Verifica reglas de docs drift
5. Emite veredicto PASS/FAIL con detalle

**Invocación**:
```
/multi-agent-workflow:policy-gate
/multi-agent-workflow:policy-gate --base origin/main
```

### Integración en route.md

Se añadió un **Step 0: Policy Gate (Pre-vuelo)** en `/workflows:route` que:
- Ejecuta policy-gate antes del análisis inicial
- Advierte al usuario si hay violaciones de drift
- No bloquea el routing — solo informa
- Si el tier es `high`, escala la complejidad del workflow

---

## Lo Que NO Incluye (intencionalmente)

| Excluido | Razón |
|----------|-------|
| Script Python (`risk_policy_gate.py`) | Rompe el paradigma nativo del plugin |
| GitHub Action (`.github/workflows/`) | El usuario prefiere ejecución local |
| Review agent externo | Complejidad sin valor para repo de 1 contributor |
| Remediation agent | El plugin ya tiene BCP + diagnostic-agent |
| Browser evidence harness | No aplica — el plugin genera markdown |
| Incident → harness loop | Fase futura — primero el gate básico |

---

## Relación con Planes Existentes

- **plugin-improvement-plan.md**: Complementa — aquel mejora el gobierno *interno*, este añade evaluación de riesgo y drift
- **ai-workflow-improvement-plan.md**: Complementa — aquel investiga prácticas, este implementa una concreta
- **solid-intelligence-refactor.md**: Independiente — no se solapan

---

## Verificación

```bash
# El contrato debe ser JSON válido:
python3 -m json.tool control-plane/contract.json

# El skill debe existir:
ls plugins/multi-agent-workflow/skills/policy-gate/SKILL.md

# route.md debe incluir Step 0 (Policy Gate):
grep -c "Policy Gate" plugins/multi-agent-workflow/commands/workflows/route.md
```
