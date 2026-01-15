# Constraints and Rules

## Reglas Globales

### 1. Contexto Compartido
- ✅ TODO contexto relevante DEBE estar en `/ai/`
- ❌ NO asumir conocimiento que no esté documentado
- ✅ Leer archivos de estado antes de cada tarea
- ❌ NO depender de conversaciones previas entre instancias

### 2. Roles y Permisos
- ✅ Cada instancia Claude tiene UN rol fijo
- ❌ NO cambiar de rol durante una sesión
- ✅ Respetar permisos de lectura/escritura del workflow
- ❌ NO escribir fuera del workspace asignado sin permiso explícito

### 3. Estado y Sincronización
- ✅ Actualizar archivos de estado después de cada cambio significativo
- ❌ NO asumir que otros ven tus cambios automáticamente
- ✅ Hacer `git pull` antes de trabajar
- ✅ Hacer `git push` después de completar tareas

### 4. Comunicación entre Roles
- ✅ Comunicar via archivos en `/ai/features/FEATURE_X/`
- ❌ NO esperar respuestas síncronas de otros roles
- ✅ Marcar bloqueos como BLOCKED en estado
- ✅ Documentar decisiones en `DECISIONS.md`

## Restricciones Técnicas

### Estructura de Archivos
```
/ai/
  ├── PROJECT.md          # Contexto general (READ-ONLY para todos)
  ├── CONSTRAINTS.md      # Este archivo (READ-ONLY)
  ├── DECISIONS.md        # Log de decisiones (APPEND-ONLY)
  ├── workflows/          # Definiciones YAML (Planner WRITE, otros READ)
  └── features/           # Features activos (según workflow)
```

### Git Workflow
- **Branch principal**: `main` (solo QA/Planner pueden mergear)
- **Feature branches**: `feature/FEATURE_X` (auto-creados por workflow)
- **Commits**: Mensajes descriptivos siguiendo Conventional Commits
- **Conflictos**: Resolver manualmente, no auto-merge

### Validaciones Pre-commit
- Todos los workflows YAML son válidos
- Archivos de estado tienen formato correcto
- No hay archivos huérfanos en `/ai/features/`
- Cada feature tiene `definition.md` y `state.md`

## Límites por Rol

### Planner
- ✅ WRITE: `/ai/workflows/`, `/ai/features/*/definition.md`, `/ai/DECISIONS.md`
- ✅ READ: Todo
- ❌ NO implementar código de producción

### Backend Developer
- ✅ WRITE: `src/`, `/ai/features/*/backend_state.md`
- ✅ READ: `/ai/`, `src/`
- ❌ NO modificar workflows o decisiones

### Frontend Developer
- ✅ WRITE: `frontend/`, `/ai/features/*/frontend_state.md`
- ✅ READ: `/ai/`, `frontend/`, contratos API
- ❌ NO modificar backend sin coordinación

### QA/Reviewer
- ✅ WRITE: `/ai/features/*/qa_state.md`, `/ai/features/*/review.md`
- ✅ READ: Todo
- ❌ NO implementar fixes directamente (reportar a roles correspondientes)

## Anti-patrones

### ❌ NO HACER
1. **Memoria implícita**: "Recordé de antes que..."
2. **Asumir contexto**: "Probablemente uses React..."
3. **Trabajo fuera de alcance**: Backend modificando frontend sin workflow
4. **Estado en memoria**: Guardar info solo en la conversación
5. **Bloqueo silencioso**: No reportar dependencias bloqueadas

### ✅ HACER EN SU LUGAR
1. Leer archivos de contexto explícitamente
2. Preguntar y documentar en `/ai/`
3. Seguir permisos del workflow YAML
4. Escribir TODO en archivos
5. Marcar BLOCKED en estado y notificar

## Excepciones
- **Emergencias**: QA puede hacer hotfixes directos si workflow lo permite
- **Setup inicial**: Planner puede modificar estructura `/ai/` libremente
- **Refactors globales**: Requieren workflow especial con permisos ampliados
