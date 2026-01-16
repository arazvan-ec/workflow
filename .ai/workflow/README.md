# Claude Code Workflow System

Sistema de workflow para Claude Code con arquitectura agent-native.

## 📁 Estructura

```
workflow/
├── roles/           # Definiciones de roles (Markdown)
├── rules/           # Reglas globales del sistema
├── workflows/       # Definiciones de workflows (YAML)
├── scripts/         # Scripts de automatización
├── tools/           # Herramientas atómicas
├── templates/       # Templates para archivos
└── docs/            # Documentación adicional
```

## 🔧 Componentes

### Scripts (`scripts/`)

| Script | Descripción |
|--------|-------------|
| `workflow.sh` | Script maestro - punto de entrada principal |
| `ai_consultant.py` | Consultor AI usando Claude CLI |
| `tilix_start.sh` | Abre Tilix con layout de roles |
| `create_checkpoint.sh` | Crea checkpoint de sesión |
| `git_sync.sh` | Sincronización Git |
| `git_commit_push.sh` | Commit y push inteligente |
| `validate_workflow.py` | Validador de workflows |

### Herramientas Atómicas (`tools/`)

Siguiendo principio de granularidad agent-native:

| Herramienta | Output | Uso |
|-------------|--------|-----|
| `analyze_structure.sh` | JSON | Análisis de directorios |
| `detect_framework.sh` | JSON | Detección de frameworks |
| `read_dependencies.sh` | JSON | Lectura de dependencias |
| `generate_context.sh` | Markdown | Generación de context.md |
| `validate_config.sh` | Texto | Validación de configuración |
| `suggest_workflow.sh` | Texto | Sugerencia de workflow |

### Templates (`templates/`)

| Template | Genera |
|----------|--------|
| `context.md.template` | `.ai/project/context.md` |
| `50_state.md.template` | Feature state con completion signals |
| `checkpoint.md.template` | Checkpoint de sesión |

### Roles (`roles/`)

| Rol | Archivo | Responsabilidad |
|-----|---------|-----------------|
| Planner | `planner.md` | Arquitectura y especificaciones |
| Backend | `backend.md` | API y lógica de negocio |
| Frontend | `frontend.md` | UI y experiencia de usuario |
| QA | `qa.md` | Testing y validación |

### Rules (`rules/`)

| Archivo | Alcance |
|---------|---------|
| `global_rules.md` | Todos los roles |
| `ddd_rules.md` | Backend con DDD |

### Workflows (`workflows/`)

| Workflow | Uso |
|----------|-----|
| `default.yaml` | Features estándar |
| `task-breakdown.yaml` | Features complejos (planning exhaustivo) |
| `implementation-only.yaml` | Post task-breakdown |

## 🚀 Uso

### Comando Principal

```bash
./.ai/workflow/scripts/workflow.sh <comando> [opciones]
```

### Comandos Disponibles

```bash
# Consultoría AI
workflow.sh consult              # Interactivo
workflow.sh consult --batch      # Sin preguntas
workflow.sh consult --new-project # Proyecto nuevo

# Iniciar workflow
workflow.sh start <feature> <workflow> [-x]

# Rol individual
workflow.sh role <rol> <feature>

# Checkpoint
workflow.sh checkpoint <rol> <feature> [mensaje]

# Git
workflow.sh sync <feature>
workflow.sh commit <rol> <feature> <mensaje>

# Validación
workflow.sh validate [feature]
```

## 🧠 Principios Agent-Native

1. **Parity**: Agentes pueden hacer todo lo que usuarios
2. **Granularity**: Herramientas atómicas, features = prompts
3. **Composability**: Componer herramientas dinámicamente
4. **Files as Interface**: Estado en Markdown/YAML
5. **Context Injection**: context.md en todos los roles
6. **Completion Signals**: Señales explícitas en 50_state.md

## 📊 Context Injection

Cada rol recibe automáticamente:

```markdown
CONTEXT AWARENESS (read first):
0. Read .ai/project/context.md
```

El archivo `context.md` contiene:
- Visión general del proyecto
- Tech stack detectado
- Patrones existentes
- Workflows disponibles
- Recomendaciones AI

## 📌 Checkpointing

Para gestión de context window:

```bash
# Crear checkpoint
workflow.sh checkpoint backend user-auth "Completed domain layer"

# Genera archivo en:
# .ai/project/features/<feature>/checkpoints/checkpoint_<rol>_<timestamp>.md
```

El checkpoint incluye:
- Resumen de lo logrado
- Estado actual
- Instrucciones de resume
- Prompt para nueva sesión

## 🔄 Completion Signals

En `50_state.md`:

```markdown
| **Status** | `COMPLETED` |
| **Completion Signal** | `true` |
```

Triggers:
- Backend/Frontend inician: `Planner.completion_signal == true`
- QA inicia: `Backend.completion_signal == true AND Frontend.completion_signal == true`

## 📚 Documentación

- `docs/GIT_WORKFLOW.md` - Git workflow multi-instancia
- `docs/PAIRING_PATTERNS.md` - Pairing con AI agents

## 🔗 Relación con project/

```
.ai/
├── workflow/     # Este directorio - sistema genérico
└── project/      # Configuración específica del proyecto
    ├── config.yaml
    ├── context.md
    ├── rules/
    └── features/
```

`workflow/` es portable entre proyectos.
`project/` es específico de cada proyecto.
