# Claude Code - AI-Powered Workflow System

Sistema completo para uso modular y escalable de Claude Code con **consultor AI**, **roles detallados**, **reglas específicas**, **workflows configurables** y **ejecución en paralelo**.

## 🎯 ¿Qué es esto?

Un sistema profesional para trabajar con **múltiples instancias de Claude Code en paralelo**, cada una con un rol específico (Planner, Backend, Frontend, QA), compartiendo contexto a través de archivos explícitos y workflows YAML configurables.

**Nuevo en v2.0**: Consultor AI que analiza tu proyecto y recomienda el workflow óptimo usando Claude CLI.

## ✨ Características

- ✅ **Consultor AI** que analiza proyectos y recomienda workflows
- ✅ **Roles detallados en Markdown** con responsabilidades, permisos, prohibiciones
- ✅ **Reglas por proyecto** (globales, DDD, específicas del proyecto)
- ✅ **Workflows YAML configurables** (default, task-breakdown, implementation-only)
- ✅ **Estado centralizado** (`50_state.md`) con completion signals
- ✅ **Context injection** - cada rol conoce el contexto del proyecto
- ✅ **Checkpointing** para gestión de context window
- ✅ **Script Tilix** para abrir múltiples panes automáticamente
- ✅ **Herramientas atómicas** para análisis de proyectos
- ✅ **Agent-native architecture** siguiendo mejores prácticas

## 📁 Estructura

```
./
├── .ai/
│   ├── workflow/                    # Sistema genérico de workflow
│   │   ├── roles/                   # Definiciones de roles
│   │   │   ├── backend.md
│   │   │   ├── frontend.md
│   │   │   ├── planner.md
│   │   │   └── qa.md
│   │   ├── rules/                   # Reglas globales
│   │   │   ├── global_rules.md
│   │   │   └── ddd_rules.md
│   │   ├── workflows/               # Workflows YAML
│   │   │   ├── default.yaml
│   │   │   ├── task-breakdown.yaml
│   │   │   └── implementation-only.yaml
│   │   ├── scripts/                 # Scripts de automatización
│   │   │   ├── ai_consultant.py     # 🆕 Consultor AI
│   │   │   ├── workflow.sh          # Script maestro
│   │   │   ├── tilix_start.sh
│   │   │   ├── create_checkpoint.sh # 🆕 Checkpointing
│   │   │   ├── git_sync.sh
│   │   │   ├── git_commit_push.sh
│   │   │   └── validate_workflow.py
│   │   ├── tools/                   # 🆕 Herramientas atómicas
│   │   │   ├── analyze_structure.sh
│   │   │   ├── detect_framework.sh
│   │   │   ├── read_dependencies.sh
│   │   │   ├── generate_context.sh
│   │   │   ├── validate_config.sh
│   │   │   └── suggest_workflow.sh
│   │   ├── templates/               # 🆕 Templates
│   │   │   ├── context.md.template
│   │   │   ├── 50_state.md.template
│   │   │   └── checkpoint.md.template
│   │   └── docs/
│   │       ├── GIT_WORKFLOW.md
│   │       └── PAIRING_PATTERNS.md
│   │
│   └── project/                     # Configuración específica del proyecto
│       ├── config.yaml              # 🆕 Configuración del proyecto
│       ├── context.md               # 🆕 Contexto AI del proyecto
│       ├── rules/
│       │   └── project_specific.md
│       └── features/
│           └── {FEATURE_ID}/
│               ├── 50_state.md
│               └── checkpoints/     # 🆕 Checkpoints de sesión
│
├── backend/                         # Tu código backend
├── frontend/                        # Tu código frontend
└── README.md
```

## 🚀 Inicio Rápido

### Script Maestro

Usa `workflow.sh` para todas las operaciones:

```bash
# Ver ayuda
./.ai/workflow/scripts/workflow.sh help
```

### 1. 🤖 Consultor AI (⭐ RECOMENDADO para empezar)

El consultor AI analiza tu proyecto y recomienda el workflow óptimo:

```bash
# Modo interactivo (default) - Claude hace preguntas
./.ai/workflow/scripts/workflow.sh consult

# Modo batch - Auto-detecta sin preguntas
./.ai/workflow/scripts/workflow.sh consult --batch

# Crear proyecto nuevo desde cero
./.ai/workflow/scripts/workflow.sh consult --new-project
```

El consultor:
- Detecta frameworks (Symfony, Laravel, React, Vue, etc.)
- Analiza estructura del proyecto
- Genera `config.yaml` con configuración
- Genera `context.md` para awareness de AI
- Recomienda workflow según complejidad

### 2. Iniciar Workflow Completo (Tilix)

```bash
# Modo automático (ejecuta Claude en cada pane)
./.ai/workflow/scripts/workflow.sh start user-auth default --execute

# Modo manual (muestra instrucciones)
./.ai/workflow/scripts/workflow.sh start user-auth default
```

Layout de Tilix:
```
┌────────────────┬────────────────┐
│   PLANNER      │   BACKEND      │
├────────────────┼────────────────┤
│   FRONTEND     │   QA           │
└────────────────┴────────────────┘
```

### 3. Trabajar como Un Rol Específico

```bash
./.ai/workflow/scripts/workflow.sh role planner user-auth
./.ai/workflow/scripts/workflow.sh role backend user-auth
./.ai/workflow/scripts/workflow.sh role frontend user-auth
./.ai/workflow/scripts/workflow.sh role qa user-auth
```

### 4. 📌 Crear Checkpoint (Gestión de Context Window)

Cuando el contexto se llena o antes de pausar trabajo:

```bash
./.ai/workflow/scripts/workflow.sh checkpoint backend user-auth "Completed domain layer"
```

Esto crea un checkpoint que permite resumir la sesión después.

### 5. Otros Comandos

```bash
# Sincronizar con Git
./.ai/workflow/scripts/workflow.sh sync user-auth

# Commit y push
./.ai/workflow/scripts/workflow.sh commit backend user-auth "Add User entity"

# Validar feature
./.ai/workflow/scripts/workflow.sh validate user-auth
```

## 📋 Resumen de Comandos

| Comando | Descripción |
|---------|-------------|
| `consult [-i\|-b\|-n]` | Consultor AI para configurar proyecto |
| `start <feature> <workflow> [-x]` | Iniciar todos los roles en Tilix |
| `role <role> <feature>` | Iniciar como un rol específico |
| `checkpoint <role> <feature> [msg]` | Crear checkpoint de sesión |
| `sync <feature>` | Sincronizar con Git |
| `commit <role> <feature> <msg>` | Commit y push |
| `validate [feature]` | Validar workflow |
| `help` | Mostrar ayuda |

## 🎨 Workflows Disponibles

### `default` - Workflow Estándar
```
Planning → Backend ⟷ Frontend → QA
```
- Backend y Frontend trabajan en paralelo
- Planning básico
- Ideal para features medianos

### `task-breakdown` - Planning Exhaustivo
```
Requirements → Architecture → API Contracts → Task Breakdown → Implementation → QA
```
- Genera 10 documentos detallados
- Ideal para features complejos
- Recomendado para proyectos nuevos

### `implementation-only` - Solo Implementación
```
Backend ⟷ Frontend → QA
```
- Requiere ejecutar `task-breakdown` primero
- Salta la fase de planning
- Usa los documentos generados previamente

## 🧠 Agent-Native Architecture

Este sistema implementa principios de arquitectura agent-native:

| Principio | Implementación |
|-----------|----------------|
| **Parity** | Claude puede hacer todo lo que el usuario |
| **Granularity** | Herramientas atómicas en `tools/`, features = prompts |
| **Composability** | Claude compone herramientas según necesidad |
| **Files as Interface** | Todo estado en Markdown/YAML |
| **Context Injection** | `context.md` inyectado en todos los roles |
| **Completion Signals** | Señales explícitas en `50_state.md` |

## 📊 Estado y Completion Signals

El archivo `50_state.md` incluye:

```markdown
## Backend

| Field | Value |
|-------|-------|
| **Status** | `IN_PROGRESS` |
| **Completion Signal** | `false` |
| **Depends On** | Planner |
```

**Workflow Triggers:**
- Backend/Frontend inician cuando: `Planner.completion_signal == true`
- QA inicia cuando: `Backend.completion_signal == true AND Frontend.completion_signal == true`

## 🔧 Herramientas Atómicas

Scripts en `.ai/workflow/tools/` que Claude puede componer:

| Herramienta | Descripción |
|-------------|-------------|
| `analyze_structure.sh` | Analiza estructura de directorios |
| `detect_framework.sh` | Detecta frameworks |
| `read_dependencies.sh` | Lee dependencias |
| `generate_context.sh` | Genera context.md |
| `validate_config.sh` | Valida configuración |
| `suggest_workflow.sh` | Sugiere workflow |

## 📌 Checkpointing

Para gestionar el context window de Claude:

```bash
# Crear checkpoint antes de cerrar sesión
./.ai/workflow/scripts/workflow.sh checkpoint backend user-auth "Completed domain layer"

# El checkpoint incluye:
# - Qué se logró
# - Estado actual
# - Archivos a leer para resumir
# - Próximos pasos
# - Prompt de resume
```

**Cuándo crear checkpoint:**
- Después de completar un checkpoint del workflow
- Cuando el contexto se siente "pesado"
- Antes de pausar trabajo por tiempo
- Cada 20+ archivos leídos

## 💡 Principios Fundamentales

1. **Contexto Explícito** - Todo en archivos, nada en memoria implícita
2. **Roles Inmutables** - Una instancia = un rol fijo
3. **Estado Sincronizado** - `50_state.md` como fuente de verdad
4. **Context Injection** - Cada rol lee `context.md` primero
5. **Completion Signals** - Señales explícitas de finalización
6. **Checkpointing** - Gestión proactiva de context window

## 🚫 Anti-patterns (Evitar)

❌ "Recuerda que antes dijimos..."
✅ "Lee el archivo `context.md` y `50_state.md`"

❌ Cambiar de rol a mitad de camino
✅ Mantener rol fijo durante toda la sesión

❌ Sesiones largas sin checkpoint
✅ Checkpoint después de cada milestone

❌ Implementar sin leer context.md
✅ Siempre leer context.md primero

## 📚 Documentación Adicional

- **`.ai/workflow/docs/GIT_WORKFLOW.md`** - Git workflow para sincronización multi-instancia
- **`.ai/workflow/docs/PAIRING_PATTERNS.md`** - Guía de pairing efectivo con AI agents

## 📝 Licencia

MIT License

---

**¿Listo para empezar?**

```bash
./.ai/workflow/scripts/workflow.sh consult
```

🚀 **¡Disfruta trabajando con Claude Code y AI-powered workflows!**
