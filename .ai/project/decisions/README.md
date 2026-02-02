# Architecture Decision Records (ADRs)

Este directorio contiene los **Architecture Decision Records (ADRs)** del proyecto. Los ADRs documentan las decisiones arquitectónicas significativas junto con su contexto y consecuencias.

## ¿Por qué usar ADRs?

1. **Memoria institucional**: Los nuevos miembros del equipo pueden entender el "por qué" de las decisiones
2. **Evitar re-litigar**: Decisiones documentadas con contexto evitan discusiones repetitivas
3. **Facilitar revisiones**: Cuando cambia el contexto, podemos revisar si la decisión sigue siendo válida
4. **Accountability**: Registro claro de quién decidió qué y cuándo

## Cuándo crear un ADR

Crea un ADR cuando:
- Elijas entre múltiples tecnologías/frameworks
- Definas patrones arquitectónicos del proyecto
- Tomes decisiones que afecten múltiples componentes
- Hagas trade-offs significativos
- La decisión sea difícil de revertir

**NO** necesitas un ADR para:
- Decisiones triviales o fácilmente reversibles
- Implementaciones específicas sin impacto arquitectónico
- Bug fixes o mejoras menores

## Estructura del directorio

```
decisions/
├── README.md           # Este archivo
├── TEMPLATE.md         # Template en formato Markdown
├── TEMPLATE.yaml       # Template en formato YAML (validable)
├── ADR-001-*.md        # ADRs individuales
├── ADR-002-*.yaml      # ADRs pueden ser MD o YAML
└── ...
```

## Ciclo de vida de un ADR

```
PROPOSED → ACCEPTED → [DEPRECATED | SUPERSEDED]
```

- **PROPOSED**: Decisión en discusión, aún no implementada
- **ACCEPTED**: Decisión aprobada e implementada
- **DEPRECATED**: Decisión ya no es relevante (contexto cambió)
- **SUPERSEDED**: Reemplazada por otro ADR (indicar cuál)

## Cómo crear un ADR

### Opción 1: Formato Markdown (más legible)

```bash
cp TEMPLATE.md ADR-XXX-nombre-descriptivo.md
# Editar el archivo con los detalles
```

### Opción 2: Formato YAML (validable con JSON Schema)

```bash
cp TEMPLATE.yaml ADR-XXX-nombre-descriptivo.yaml
# Editar y validar contra el schema
```

### Numeración

- Usa números secuenciales: ADR-001, ADR-002, etc.
- Nunca reutilices números, incluso si un ADR es eliminado
- El número no implica orden de importancia

### Nombre del archivo

Usa el formato: `ADR-XXX-descripcion-corta.{md|yaml}`

Ejemplos:
- `ADR-001-usar-tmux-para-paralelismo.md`
- `ADR-002-yaml-para-specs.yaml`
- `ADR-003-patron-agent-harness.md`

## Validación (para YAML)

Los ADRs en formato YAML pueden validarse contra el JSON Schema:

```bash
# Si tienes yajsv instalado
yajsv -s ../../../plugins/multi-agent-workflow/core/schemas/adr_spec.json ADR-XXX.yaml

# O usando el workflow de validación
/workflows:validate --type=adr --file=ADR-XXX.yaml
```

## Integración con el workflow

### Durante Planning

Al usar `/workflows:plan`, considera si hay decisiones arquitectónicas que deban documentarse:

```
/workflows:plan --feature=mi-feature
# Si hay decisiones arquitectónicas → crear ADRs correspondientes
```

### Durante Code Review

Los reviewers deben verificar:
- ¿Hay decisiones arquitectónicas no documentadas?
- ¿Los cambios contradicen algún ADR existente?
- ¿Hay ADRs que deberían marcarse como DEPRECATED?

## Lista de ADRs

| ID | Título | Estado | Fecha |
|----|--------|--------|-------|
| [ADR-001](ADR-001-usar-tmux-sobre-tilix.md) | Usar tmux sobre Tilix | ACCEPTED | 2026-01-27 |
| [ADR-002](ADR-002-yaml-con-json-schema.md) | YAML con JSON Schema para specs | ACCEPTED | 2026-01-27 |
| [ADR-003](ADR-003-formato-agent-file.md) | Agent File format para estado | ACCEPTED | 2026-01-27 |

---

## Referencias

- [Michael Nygard - Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR GitHub Organization](https://adr.github.io/)
- [MADR Template](https://adr.github.io/madr/)
