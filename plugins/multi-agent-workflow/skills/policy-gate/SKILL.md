---
name: policy-gate
description: "Evalúa cambios contra el contrato de gobernanza (control-plane/contract.json). Calcula tier de riesgo, verifica drift de documentación y emite veredicto PASS/FAIL."
hooks:
  Stop:
    - command: "echo '[policy-gate] Evaluación completada.'"
---

# Policy Gate Skill

Evalúa los archivos cambiados contra el contrato de gobernanza del repositorio. Determina el nivel de riesgo y verifica que los cambios cumplan las reglas de documentación.

## Qué Hace Este Skill

1. **Lee el contrato**: `control-plane/contract.json` (fuente de verdad)
2. **Detecta archivos cambiados**: vía `git diff` contra la rama base
3. **Calcula tier de riesgo**: high > medium > low (gana el más alto)
4. **Verifica docs drift**: si cambias X, debes también cambiar Y
5. **Emite veredicto**: PASS o FAIL con detalle

## Cuándo Usarlo

- **Antes de commit**: para verificar que no faltan actualizaciones de documentación
- **Durante route**: como pre-vuelo automático antes de seleccionar workflow
- **Antes de PR**: para anticipar qué checks serán necesarios
- **Manualmente**: cuando quieras saber el tier de riesgo de tus cambios

## Invocación

```
/multi-agent-workflow:policy-gate
/multi-agent-workflow:policy-gate --base origin/main
/multi-agent-workflow:policy-gate --files "ruta/al/archivo.md"
```

## Protocolo de Ejecución

### Paso 1: Cargar el Contrato

Leer `control-plane/contract.json` desde la raíz del repositorio.

Si no existe:
- ADVERTIR: "No se encontró control-plane/contract.json. No se puede evaluar política."
- DETENER el skill. No adivinar reglas.

### Paso 2: Detectar Archivos Cambiados

**Opción A — Automática** (por defecto):
```bash
git diff --name-only --diff-filter=ACMRT origin/main
```

**Opción B — Explícita** (si el usuario pasa `--files`):
Usar la lista de archivos proporcionada.

**Opción C — Staged** (si no hay rama base):
```bash
git diff --name-only --cached
```

Si no hay archivos cambiados:
- Emitir: "Sin cambios detectados. Tier: low. PASS."
- DETENER.

### Paso 3: Calcular Tier de Riesgo

Para cada archivo cambiado, buscar en `riskTierRules` del contrato qué patrón glob lo cubre. El tier más alto entre todos los archivos gana.

**Prioridad**: high (3) > medium (2) > low (1)

**Reglas de matching**:
- `plugins/multi-agent-workflow/core/rules/**` → cubre cualquier archivo bajo esa ruta
- `**` → comodín, cubre todo (tier por defecto)
- Evaluar de high a low. En cuanto un archivo matchea high, el tier final es high.

**Ejemplo**:
```
Archivos cambiados:
  - plugins/multi-agent-workflow/core/rules/framework_rules.md → high
  - plugins/multi-agent-workflow/README.md → low

Tier resultante: high (el más alto gana)
```

### Paso 4: Verificar Docs Drift

Para cada regla en `docsDriftRules` del contrato:

1. Verificar si algún archivo cambiado matchea los patrones de `ifChanged`
2. Si matchea: verificar que AL MENOS UNO de los archivos cambiados matchee `mustAlsoChangeOneOf`
3. Si ninguno matchea → **VIOLACIÓN DE DRIFT**

**Ejemplo de violación**:
```
Regla: "core-rules-require-docs-update"
  ifChanged: plugins/multi-agent-workflow/core/rules/**
  mustAlsoChangeOneOf: CLAUDE.md, README.md, plans/**

Archivos cambiados: [core/rules/framework_rules.md]
¿Se cambió también CLAUDE.md, README.md o algo en plans/? → NO
→ VIOLACIÓN: Cambiaste reglas del core sin actualizar documentación.
```

### Paso 5: Emitir Resultado

#### Formato de salida:

```markdown
## Policy Gate — Resultado

| Propiedad | Valor |
|-----------|-------|
| **Veredicto** | PASS / FAIL |
| **Tier de riesgo** | high / medium / low |
| **Archivos cambiados** | N |
| **Checks requeridos** | risk-policy-gate, ci |

### Archivos por tier
- **high**: [lista de archivos high]
- **medium**: [lista de archivos medium]
- **low**: [lista de archivos low]

### Violaciones de drift
- Regla "X": Cambiaste [archivos] pero no actualizaste [documentación requerida]

### Acción recomendada
- [Qué debe hacer el usuario para resolver las violaciones]
```

#### Si PASS:
Informar tier y checks requeridos. No bloquear.

#### Si FAIL:
Listar cada violación de drift con:
- Qué regla se violó
- Qué archivos dispararon la regla
- Qué archivos faltan por cambiar
- Sugerencia concreta de qué actualizar

## Reglas del Skill

1. **Nunca adivinar reglas** — toda evaluación viene del contrato JSON
2. **Nunca modificar archivos** — este skill solo lee y reporta
3. **Nunca bloquear silenciosamente** — siempre explicar por qué falla
4. **El contrato es la fuente de verdad** — si algo no está en el contrato, no se evalúa
5. **Tier más alto gana** — un archivo high convierte todo el changeset en high

## Integración con el Workflow

Este skill se invoca automáticamente en dos puntos:

| Punto de invocación | Cuándo | Acción si FAIL |
|---------------------|--------|----------------|
| `/workflows:route` Step 1 | Antes del análisis inicial | Advertir al usuario, no bloquear routing |
| `/workflows:work` Step 7 | Antes del checkpoint | Advertir, recomendar actualizar docs antes de commit |

También se puede invocar manualmente en cualquier momento.

## Ejemplo Completo

```
Usuario: /multi-agent-workflow:policy-gate

Agente:
1. Lee control-plane/contract.json ✓
2. Ejecuta: git diff --name-only --diff-filter=ACMRT origin/main
   → plugins/multi-agent-workflow/commands/workflows/plan.md
   → plugins/multi-agent-workflow/core/rules/testing-rules.md
3. Calcula tier:
   - plan.md → matchea "commands/**" → high
   - testing-rules.md → matchea "core/rules/**" → high
   → Tier final: high
4. Verifica drift:
   - Regla "commands-require-docs-update": plan.md cambió
     ¿Se cambió CLAUDE.md, README.md o plans/**? → NO
     → VIOLACIÓN
   - Regla "core-rules-require-docs-update": testing-rules.md cambió
     ¿Se cambió CLAUDE.md, README.md o plans/**? → NO
     → VIOLACIÓN
5. Resultado:
   → FAIL — 2 violaciones de drift
   → Acción: actualizar CLAUDE.md o README.md o añadir nota en plans/
```
