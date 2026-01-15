# Architectural Decision Log (ADL)

Este archivo registra todas las decisiones arquitectónicas y de diseño importantes del proyecto.

**Formato**: Cada decisión sigue el patrón:
```
## [YYYY-MM-DD] Título de la Decisión
**Contexto**: ¿Por qué necesitamos decidir esto?
**Decisión**: ¿Qué decidimos?
**Consecuencias**: ¿Qué implica esta decisión?
**Alternativas consideradas**: ¿Qué otras opciones evaluamos?
```

---

## [2026-01-15] Usar archivos para contexto compartido entre instancias Claude

**Contexto**: Claude Code no comparte estado interno entre instancias. Necesitamos un mecanismo de sincronización para trabajo paralelo.

**Decisión**: Todo contexto compartido debe estar explícitamente en archivos dentro de `/ai/`. No se debe asumir conocimiento que no esté documentado.

**Consecuencias**:
- ✅ Contexto verificable y versionado
- ✅ No hay ambigüedad sobre "qué sabe cada Claude"
- ⚠️ Overhead de mantener archivos actualizados
- ⚠️ Requiere disciplina para documentar todo

**Alternativas consideradas**:
- Base de datos compartida → Demasiada complejidad
- Variables de entorno → No versionables ni auditables
- Memoria implícita → No funciona, Claude no comparte contexto

---

## [2026-01-15] Workflows definidos en YAML

**Contexto**: Necesitamos especificar roles, permisos, dependencias y paralelismo de forma declarativa.

**Decisión**: Usar archivos YAML en `/ai/workflows/` con esquema validable.

**Consecuencias**:
- ✅ Declarativo y legible
- ✅ Validable con JSON Schema
- ✅ Fácil de versionar y revisar
- ⚠️ Requiere parser y validador
- ❌ No permite lógica compleja (pero eso es una feature, no un bug)

**Alternativas consideradas**:
- JSON → Menos legible para humanos
- Código (Python/JS) → Demasiado flexible, difícil de auditar
- Markdown → No estructurado, difícil de parsear

---

## [2026-01-15] Estado granular por rol

**Contexto**: Múltiples instancias escribiendo `50_state.md` simultáneamente causa conflictos Git frecuentes.

**Decisión**: Cada rol tiene su propio archivo de estado: `backend_state.md`, `frontend_state.md`, `qa_state.md`, etc.

**Consecuencias**:
- ✅ Reduce conflictos Git dramáticamente
- ✅ Cada rol es dueño de su estado
- ✅ QA puede leer todos sin interferir
- ⚠️ Más archivos para mantener
- ⚠️ Necesitamos script para vista consolidada

**Alternativas consideradas**:
- Estado único → Probado, causa conflictos constantes
- Base de datos → Overkill y sin versionado
- Git branches por rol → Complejidad de merges

---

## [YYYY-MM-DD] [Tu próxima decisión importante aquí]

**Contexto**:

**Decisión**:

**Consecuencias**:

**Alternativas consideradas**:

---

## Cómo Usar Este Archivo

### Cuándo agregar una decisión
- Cambios en arquitectura o estructura del proyecto
- Elección de tecnologías o herramientas
- Patrones de diseño adoptados
- Restricciones o reglas importantes

### Quién puede agregar decisiones
- **Planner**: Puede agregar decisiones (APPEND-ONLY)
- **Otros roles**: Pueden proponer decisiones en feature review, Planner las formaliza aquí

### Formato requerido
```markdown
## [YYYY-MM-DD] Título conciso
**Contexto**: 1-2 párrafos
**Decisión**: 1 párrafo claro
**Consecuencias**: Lista con ✅ beneficios, ⚠️ trade-offs, ❌ costos
**Alternativas consideradas**: Lista de opciones descartadas con razón breve
```
