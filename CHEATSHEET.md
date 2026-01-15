# Claude Code Workflow System - Cheatsheet

Comandos rápidos para uso diario.

## 🚀 Inicio Rápido

```bash
# Generar workflow interactivamente
./scripts/workflow consult

# Inicializar feature manualmente
./scripts/workflow init <feature-id> [template]

# Ver todos los features
./scripts/workflow list

# Ver estado de un feature
./scripts/workflow status <feature-id>
```

## 📋 Workflow Management

```bash
# Sincronizar con remoto (pull con manejo de stash)
./scripts/workflow sync

# Validar workflow
./scripts/workflow validate <feature-id>

# Validar todos los workflows
./scripts/workflow validate

# Ayuda
./scripts/workflow help
```

## 🎭 Roles de Claude Code

### Iniciar Claude con rol específico

```bash
cd /path/to/workflow
claude  # o tu comando para iniciar Claude Code
```

Dentro de Claude, especifica el rol:

```
I am the [ROLE] for feature [FEATURE_ID].

Please:
1. Read ./ai/features/[FEATURE_ID]/workflow.yaml
2. Follow the instructions for the [STAGE_ID] stage
3. Update my state file when done
```

### Roles Comunes

**Planner**
```
I am the PLANNER. Read ./ai/features/X/workflow.yaml and create
the feature definition and task breakdown.
```

**Backend Developer**
```
I am the BACKEND DEVELOPER. Read ./ai/features/X/workflow.yaml
and implement the backend according to definition.md.
First, run git pull to sync.
```

**Frontend Developer**
```
I am the FRONTEND DEVELOPER. Read ./ai/features/X/workflow.yaml
and implement the frontend according to definition.md.
First, run git pull to sync.
```

**QA/Reviewer**
```
I am the QA/REVIEWER. Read ./ai/features/X/workflow.yaml
and review the implementation. Create review.md.
First, run git pull to sync.
```

## 📁 Estructura de Archivos

```
ai/
├── PROJECT.md              # Contexto del proyecto
├── CONSTRAINTS.md          # Reglas y permisos
├── DECISIONS.md            # Log de decisiones
├── workflows/              # Templates YAML
│   ├── feature_template.yaml
│   └── ddd_parallel.yaml
└── features/
    └── <feature-id>/
        ├── workflow.yaml       # Workflow del feature
        ├── definition.md       # Definición (Planner crea)
        ├── tasks.md            # Tareas (Planner crea)
        ├── planner_state.md    # Estado del Planner
        ├── backend_state.md    # Estado del Backend
        ├── frontend_state.md   # Estado del Frontend
        ├── qa_state.md         # Estado del QA
        └── review.md           # Review (QA crea)
```

## 🔄 Flujo de Trabajo

### Secuencial (1 persona)

```
1. Planning      →  2. Implementation  →  3. Review
   (Planner)         (Developer)           (QA)
```

### Paralelo (1 persona, múltiples tabs)

```
1. Planning
   (Planner)
      ↓
   ┌──┴──────────┐
   ↓             ↓
2. Backend    Frontend
   (parallel)
   └──┬──────────┘
      ↓
   3. Review
      (QA)
```

### Equipo (múltiples personas)

```
Person 1: Planner + QA
Person 2: Backend Developer
Person 3: Frontend Developer

Cada persona = 1 Claude instance = 1 rol fijo
```

## 🔧 Estados de Feature

### Ver estados

```bash
./scripts/workflow status <feature-id>
```

### Estados posibles

- `PENDING` - No iniciado
- `IN_PROGRESS` - Trabajando
- `BLOCKED` - Bloqueado, esperando algo
- `COMPLETED` - Completado
- `APPROVED` - Aprobado por QA
- `REJECTED` - Rechazado por QA

## 📝 Archivos de Estado

Formato de `*_state.md`:

```markdown
# State: [Role Name]

**Feature**: feature-id
**Last Updated**: YYYY-MM-DD HH:MM:SS UTC
**Status**: PENDING|IN_PROGRESS|BLOCKED|COMPLETED|APPROVED|REJECTED

## Current Task
What you're working on now

## Completed Tasks
- [x] Task 1
- [x] Task 2

## Blocked By
- Waiting for X to complete Y
- Need clarification on Z

## Notes
Additional context, decisions, etc.
```

## 🎯 Templates Disponibles

### feature_template
Workflow simple: Planning → Implementation → Review

```bash
./scripts/workflow init my-feature feature_template
```

### ddd_parallel
DDD con capas paralelas: Planning → (Domain, Application, Infrastructure) → Integration

```bash
./scripts/workflow init my-feature ddd_parallel
```

## 🐛 Troubleshooting

### Claude no sigue el rol
```
"Stop. You are the [ROLE] role only.
Read ./ai/features/X/workflow.yaml again.
Follow ONLY the instructions for your stage.
Do NOT do work assigned to other roles."
```

### Conflictos de Git
```bash
git stash           # Guardar cambios locales
git pull            # Traer cambios remotos
git stash pop       # Aplicar cambios locales
# Resolver conflictos manualmente
```

### Feature ya existe
```bash
# Ver features existentes
./scripts/workflow list

# Eliminar feature
rm -rf ai/features/<feature-id>
```

### Workflow inválido
```bash
# Validar
./scripts/workflow validate <feature-id>

# Verificar YAML syntax
python3 -c "import yaml; yaml.safe_load(open('ai/features/X/workflow.yaml'))"
```

## ⚡ Tips Productividad

### 1. Alias útiles

Agregar a `~/.bashrc` o `~/.zshrc`:

```bash
alias wf='./scripts/workflow'
alias wfc='./scripts/workflow consult'
alias wfs='./scripts/workflow status'
alias wfl='./scripts/workflow list'
alias wfsync='./scripts/workflow sync'
```

Uso:
```bash
wf init my-feature
wfs my-feature
wfsync
```

### 2. Tilix Layout

Guardar layout de Tilix con 4 panes pre-configurados para reutilizar.

### 3. Watch Status

Monitor estado en tiempo real:

```bash
watch -n 5 './scripts/workflow status <feature-id>'
```

### 4. Git Hooks

Agregar validación pre-commit:

```bash
# .git/hooks/pre-commit
#!/bin/bash
./scripts/workflow validate || {
    echo "Workflow validation failed!"
    exit 1
}
```

## 📚 Documentación Completa

- `README.md` - Documentación principal
- `QUICKSTART.md` - Tutorial guiado
- `ai/workflows/README.md` - Formato de workflows
- `ai/features/example-todo-api/EXAMPLE_USAGE.md` - Ejemplo funcional

## 🎓 Ejemplo Práctico

Probar el ejemplo pre-configurado:

```bash
# Ver el ejemplo
./scripts/workflow status example-todo-api

# Leer instrucciones
cat ai/features/example-todo-api/EXAMPLE_USAGE.md

# Empezar con el rol Backend
claude

# Dentro de Claude:
"I am the BACKEND DEVELOPER for example-todo-api.
Read the workflow and implement the TODO API."
```

## 💡 Reglas de Oro

1. **Sincroniza siempre**: `git pull` antes de trabajar
2. **Lee el workflow**: Cada rol debe leer su `workflow.yaml`
3. **Actualiza estado**: Escribe en tu `*_state.md` frecuentemente
4. **Respeta permisos**: No escribas fuera de tu workspace
5. **Comunica via archivos**: No asumas contexto implícito

---

**Workflow exitoso = Contexto explícito + Roles claros + Sincronización constante**
