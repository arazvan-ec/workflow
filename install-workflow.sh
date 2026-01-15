#!/usr/bin/env bash
################################################################################
# Claude Code Parallel Workflow System - Self-Contained Installer
#
# This script contains all necessary files embedded within it.
# Simply run it in your project directory to install the workflow system.
#
# Usage:
#   cd /path/to/your-project
#   bash install-workflow.sh
#
# Or download and run:
#   curl -fsSL YOUR_URL/install-workflow.sh | bash
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warning() { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }
header() { echo -e "\n${BOLD}${CYAN}$*${NC}\n"; }
die() { error "$*"; exit 1; }

TARGET_DIR="$(pwd)"

header "🚀 Claude Code Parallel Workflow System - Installer"

echo "Installing in: ${CYAN}$TARGET_DIR${NC}"
echo ""

# Check if ai/ already exists
if [[ -d "$TARGET_DIR/ai" ]]; then
    warning "Directory 'ai/' already exists."
    read -p "$(echo -e ${YELLOW}?${NC} Backup and replace? \(y/N\): )" -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Installation cancelled."
        exit 0
    fi
    BACKUP_NAME="ai.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$TARGET_DIR/ai" "$TARGET_DIR/$BACKUP_NAME"
    success "Backup: $BACKUP_NAME"
fi

info "Extracting files..."

# Function to extract embedded file
extract_file() {
    local filename="$1"
    local start_marker="__FILE_${filename}__"
    local end_marker="__END_${filename}__"

    sed -n "/${start_marker}/,/${end_marker}/p" "$0" | sed '1d;$d'
}

# Function to create file from embedded content
create_file() {
    local filepath="$1"
    local marker="$2"

    mkdir -p "$(dirname "$TARGET_DIR/$filepath")"
    extract_file "$marker" > "$TARGET_DIR/$filepath"

    # Set executable if it's a script
    if [[ "$filepath" =~ ^scripts/ ]] || [[ "$filepath" =~ \.sh$ ]]; then
        chmod +x "$TARGET_DIR/$filepath"
    fi
}

info 'Creating directory structure...'
create_file 'README.md' 'README_md'
__FILE_README_md__
# Claude Code Parallel Workflow System

Sistema escalable para usar múltiples instancias de Claude Code en paralelo con roles definidos, contexto compartido explícito y sincronización mediante archivos.

## 🎯 Propósito

Permite trabajar con **4+ instancias de Claude Code simultáneamente** en el mismo proyecto o proyectos relacionados, cada una con un rol específico (Planner, Backend, Frontend, QA), compartiendo contexto a través de archivos explícitos en lugar de memoria implícita.

## ✨ Características

- ✅ **Contexto explícito**: Todo el conocimiento compartido en `/ai/`
- ✅ **Roles definidos**: Cada instancia Claude = un rol fijo
- ✅ **Workflows declarativos**: YAML define tareas, permisos, dependencias
- ✅ **Estado sincronizado**: Git para compartir progreso entre roles
- ✅ **Paralelismo**: Trabajo simultáneo en diferentes capas/módulos
- ✅ **Validación automática**: Pre-commit hooks garantizan integridad
- ✅ **Consultor interactivo**: Genera workflow óptimo haciendo preguntas

## 📁 Estructura

```
workflow/
├── ai/                          # Contexto compartido (fuente de verdad)
│   ├── PROJECT.md               # Descripción general del proyecto
│   ├── CONSTRAINTS.md           # Reglas y restricciones
│   ├── DECISIONS.md             # Log de decisiones arquitectónicas (ADL)
│   ├── workflows/               # Templates de workflow YAML
│   │   ├── README.md
│   │   ├── feature_template.yaml
│   │   └── ddd_parallel.yaml
│   └── features/                # Features activos
│       └── <feature-id>/
│           ├── workflow.yaml    # Workflow específico del feature
│           ├── definition.md    # Definición del feature
│           ├── tasks.md         # Lista de tareas
│           ├── planner_state.md # Estado del planner
│           ├── backend_state.md # Estado del backend dev
│           └── ...              # Otros archivos de estado por rol
│
├── scripts/
│   ├── workflow                 # CLI principal de gestión
│   └── workflow-consultant      # Consultor interactivo
│
├── src/                         # Código fuente (backend)
└── frontend/                    # Código frontend (si aplica)
```

## 🚀 Inicio Rápido

### Instalación

```bash
# 1. Clonar o inicializar el repo
git clone <your-repo> workflow
cd workflow

# 2. Verificar que tienes Python 3 y PyYAML
pip install pyyaml

# 3. (Opcional) Agregar scripts al PATH
export PATH="$PWD/scripts:$PATH"
```

### Crear tu primer workflow

#### Opción A: Consultor Interactivo (Recomendado)

```bash
./scripts/workflow consult
```

El consultor te hará preguntas sobre tu tarea y generará el workflow óptimo automáticamente.

#### Opción B: Manual

```bash
# 1. Inicializar feature con template
./scripts/workflow init mi-feature

# 2. Editar definición
vim ai/features/mi-feature/definition.md

# 3. Ver estado
./scripts/workflow status mi-feature
```

### Trabajar con el workflow

#### Setup de Tilix (4 instancias paralelas)

1. Abrir Tilix
2. Crear grid 2x2 (4 panes)
3. En cada pane, iniciar Claude Code con un rol:

```
┌─────────────────┬─────────────────┐
│   Planner       │  Backend Dev    │
│   (Tab 1)       │  (Tab 2)        │
├─────────────────┼─────────────────┤
│  Frontend Dev   │  QA/Review      │
│  (Tab 3)        │  (Tab 4)        │
└─────────────────┴─────────────────┘
```

#### Comandos por rol

**Tab 1 - Planner:**
```bash
cd /path/to/workflow
claude  # o tu comando de Claude Code

# Dentro de Claude:
"I am the PLANNER. Read ./ai/features/mi-feature/workflow.yaml
and follow the planning stage instructions."
```

**Tab 2 - Backend Developer:**
```bash
cd /path/to/workflow
claude

# Dentro de Claude:
"I am the BACKEND DEVELOPER. Read ./ai/features/mi-feature/workflow.yaml
and follow the backend implementation stage. First, sync with git pull."
```

**Tab 3 - Frontend Developer:**
```bash
cd /path/to/workflow
claude

# Dentro de Claude:
"I am the FRONTEND DEVELOPER. Read ./ai/features/mi-feature/workflow.yaml
and follow the frontend implementation stage. First, sync with git pull."
```

**Tab 4 - QA/Reviewer:**
```bash
cd /path/to/workflow
claude

# Dentro de Claude:
"I am the QA/REVIEWER. Read ./ai/features/mi-feature/workflow.yaml
and follow the review stage. First, sync with git pull."
```

### Flujo de trabajo típico

```bash
# 1. Antes de empezar, todos sincronizan
./scripts/workflow sync

# 2. Planner define el feature
#    (En Tab 1 - Claude Planner trabaja)
#    Actualiza: definition.md, tasks.md, planner_state.md
#    Hace: git add, git commit, git push

# 3. Backend y Frontend leen definición y trabajan
#    (En Tab 2 y 3 - ambos Claude trabajan en paralelo)
#    Actualizan sus respectivos *_state.md
#    Hacen: git pull (antes), git push (después)

# 4. QA revisa todo
#    (En Tab 4 - Claude QA revisa)
#    Crea: review.md
#    Aprueba o rechaza

# 5. Ver estado consolidado
./scripts/workflow status mi-feature
```

## 📚 Comandos Disponibles

### `workflow` CLI

```bash
# Inicializar nuevo feature
workflow init <feature-id> [template]

# Listar features
workflow list

# Ver estado de feature(s)
workflow status [feature-id]

# Sincronizar con remoto
workflow sync

# Validar workflow(s)
workflow validate [feature-id]

# Consultor interactivo
workflow consult

# Ayuda
workflow help
```

## 🎨 Templates de Workflow

### `feature_template.yaml` - Template Básico

3 roles: Planner → Developer → QA

Ideal para features simples sin arquitectura específica.

```bash
workflow init mi-feature feature_template
```

### `ddd_parallel.yaml` - DDD con Paralelismo

5 roles: Planner → (Domain, Application, Infrastructure en paralelo) → QA

Ideal para features complejos con Domain-Driven Design.

```bash
workflow init mi-feature-ddd ddd_parallel
```

## 🔒 Principios Fundamentales

### 1. Sin Estado Compartido en Memoria

❌ **NO**: "Claude, recuerda que antes dijimos que..."
✅ **SÍ**: "Claude, lee el archivo `./ai/features/X/definition.md`"

### 2. Archivos como Fuente de Verdad

Si no está escrito en `/ai/`, **no existe**.

### 3. Roles Inmutables

Una instancia Claude = un rol fijo durante toda la sesión.

No cambiar de Planner a Developer a mitad de camino.

### 4. Comunicación via Archivos

Roles se comunican escribiendo y leyendo archivos en `./ai/features/<feature-id>/`.

No hay comunicación directa entre instancias.

### 5. Sincronización Explícita

Hacer `git pull` antes de trabajar.
Hacer `git push` después de completar tareas.

## 🎯 Casos de Uso

### Caso 1: Solo tú, trabajo secuencial

```
Roles: Planner → Developer → QA (tú cambias entre roles)
Tabs: 2 (Planner+Dev en 1, QA en 2)
```

### Caso 2: Solo tú, trabajo paralelo

```
Roles: Planner, Backend, Frontend, QA
Tabs: 4 (uno por rol, tú cambias entre tabs)
Paralelismo: Backend + Frontend simultáneamente
```

### Caso 3: Equipo (3 personas)

```
Persona 1: Planner + QA
Persona 2: Backend Developer
Persona 3: Frontend Developer

Cada persona = 1 Claude instance = 1 rol
```

### Caso 4: DDD complejo en paralelo

```
Roles: Planner, Domain Dev, Application Dev, Infrastructure Dev, QA
Tabs: 5 (todos en paralelo después de planning)
```

## 🛠️ Personalización

### Crear tu propio template

1. Copiar template existente:
```bash
cp ai/workflows/feature_template.yaml ai/workflows/mi_template.yaml
```

2. Editar roles, stages, permisos

3. Usar:
```bash
workflow init mi-feature mi_template
```

### Adaptar workflow existente

Editar directamente:
```bash
vim ai/features/mi-feature/workflow.yaml
```

## 📖 Documentación Detallada

- [Workflows README](ai/workflows/README.md) - Formato YAML de workflows
- [PROJECT.md](ai/PROJECT.md) - Descripción del proyecto
- [CONSTRAINTS.md](ai/CONSTRAINTS.md) - Reglas y restricciones
- [DECISIONS.md](ai/DECISIONS.md) - Log de decisiones arquitectónicas

## 🤝 Contribuir

Este es un sistema vivo. Mejoras bienvenidas:

1. Nuevos templates de workflow
2. Validadores adicionales
3. Integraciones (pre-commit hooks, CI)
4. Documentación y ejemplos

## 📝 Licencia

MIT License - Úsalo como quieras.

## 🆘 Soporte

Para preguntas o problemas:
1. Lee la documentación en `/ai/`
2. Revisa ejemplos en `/ai/workflows/`
3. Usa `workflow consult` para generar workflows automáticamente

---

**Hecho con ❤️ para Claude Code**

```
"No memory, only files. No assumptions, only facts."
```
__END_README_md__

create_file 'QUICKSTART.md' 'QUICKSTART_md'
__FILE_QUICKSTART_md__
# Quick Start Guide - Claude Code Parallel Workflow

Guía de 5 minutos para empezar a usar el sistema de workflows en paralelo.

## Escenario: Crear feature de autenticación de usuarios

Vamos a crear un sistema de autenticación con:
- Backend (API de login/register)
- Frontend (formularios de login/register)
- QA (tests y revisión)

## Paso 1: Generar el Workflow (2 min)

### Opción A: Usando el Consultor (Recomendado)

```bash
./scripts/workflow consult
```

Responde las preguntas:

```
? Describe your task: Create user authentication system with login and registration
? What type of task is this? → New feature (frontend + backend)
? What architecture will you use? → Simple (no specific pattern)
? How complex is this task? → Medium (3-10 files, 1-3 days)
? Repository structure? → Monorepo (frontend + backend in same repo)
? Backend source directory: ./src
? Frontend source directory: ./frontend
? Do you have tests? → Yes
? Test directory: ./tests
? Are you working alone? → Yes
? Want to work on multiple parts in parallel? → No (para empezar simple)
? Feature ID: user-authentication
```

El consultor creará automáticamente:
- `ai/features/user-authentication/workflow.yaml`
- `ai/features/user-authentication/definition.md`
- `ai/features/user-authentication/*_state.md`

### Opción B: Manual (para entender el proceso)

```bash
# Inicializar con template básico
./scripts/workflow init user-authentication feature_template

# Editar definición
vim ai/features/user-authentication/definition.md
```

## Paso 2: Verificar el Setup (30 seg)

```bash
# Ver feature creado
./scripts/workflow list

# Ver estado inicial
./scripts/workflow status user-authentication

# Validar workflow
./scripts/workflow validate user-authentication
```

Deberías ver:

```
ℹ Available features:
  user-authentication [active]

ℹ Status of feature: user-authentication
  planner:              PENDING
  developer:            PENDING
  qa:                   PENDING

✓ Feature valid: user-authentication
```

## Paso 3: Configurar Tilix (1 min)

Si usas Tilix en Linux:

1. Abrir Tilix
2. Split horizontal: `Ctrl+H`
3. Split vertical en ambos panes: `Ctrl+V`

Resultado (4 panes):

```
┌──────────────┬──────────────┐
│   PLANNER    │   DEVELOPER  │
├──────────────┼──────────────┤
│   (reserve)  │   QA         │
└──────────────┴──────────────┘
```

## Paso 4: Ejecutar el Workflow (depende de complejidad)

### Tab 1: Planner (5-10 min)

```bash
cd /path/to/workflow
claude  # o como inicies Claude Code

# Dentro de Claude Code, escribe:
```

```
Hi! I am the PLANNER role for this workflow.

Please:
1. Read ./ai/features/user-authentication/workflow.yaml
2. Read ./ai/features/user-authentication/definition.md
3. Follow the instructions for the "planning" stage
4. Create a detailed feature definition and task breakdown
5. Update planner_state.md when done
6. Commit your changes with: git add ai/ && git commit -m "Planning: user authentication" && git push
```

Claude creará:
- `definition.md` (detallado con requisitos)
- `tasks.md` (lista de tareas específicas)
- `planner_state.md` (status: COMPLETED)

### Tab 2: Developer (20-30 min)

Primero, sincronizar:

```bash
./scripts/workflow sync
```

Luego en Claude Code:

```
Hi! I am the DEVELOPER role for this workflow.

Please:
1. Run: git pull
2. Read ./ai/features/user-authentication/workflow.yaml
3. Read ./ai/features/user-authentication/definition.md
4. Read ./ai/features/user-authentication/tasks.md
5. Follow the instructions for the "implementation" stage
6. Implement the backend API and frontend forms
7. Update dev_state.md as you progress
8. Commit your changes when done
```

Claude implementará el código según la definición del Planner.

### Tab 3: QA (10-15 min)

Sincronizar y revisar:

```bash
./scripts/workflow sync
```

En Claude Code:

```
Hi! I am the QA/REVIEWER role for this workflow.

Please:
1. Run: git pull
2. Read ./ai/features/user-authentication/workflow.yaml
3. Read ./ai/features/user-authentication/definition.md
4. Review the implementation in ./src/ and ./frontend/
5. Create a review.md with findings
6. Update qa_state.md with status: APPROVED or REJECTED
7. Commit your review
```

Claude revisará el código y creará un reporte de QA.

## Paso 5: Verificar Resultado

```bash
# Ver estado final
./scripts/workflow status user-authentication

# Debería mostrar:
#   planner:    COMPLETED
#   developer:  COMPLETED
#   qa:         APPROVED (o REJECTED con issues)

# Ver todos los archivos creados
ls -la ai/features/user-authentication/

# Output:
# - workflow.yaml
# - definition.md
# - tasks.md
# - planner_state.md
# - dev_state.md
# - qa_state.md
# - review.md
```

## Paso 6 (Opcional): Trabajo en Paralelo

Si quieres trabajar en backend y frontend **simultáneamente**:

1. Genera workflow con consultor, pero responde:
   - "Want to work in parallel?" → **Yes**
   - "Which parts?" → **Backend, Frontend**

2. El workflow generará stages paralelos

3. Usa 4 tabs:
   - Tab 1: Planner
   - Tab 2: Backend Developer
   - Tab 3: Frontend Developer
   - Tab 4: QA

4. Después de planning, Backend y Frontend pueden trabajar **al mismo tiempo** sin conflictos (cada uno escribe en su directorio).

## Flujo Visual Completo

```
┌─────────────────────────────────────────────────────┐
│  1. workflow consult                                │
│     → Genera workflow.yaml automáticamente          │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  2. Tab 1: PLANNER                                  │
│     Crea: definition.md, tasks.md                   │
│     Estado: COMPLETED                               │
│     Git: commit + push                              │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  3. Tab 2: DEVELOPER                                │
│     git pull (lee definición del Planner)           │
│     Implementa: src/, frontend/                     │
│     Estado: COMPLETED                               │
│     Git: commit + push                              │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  4. Tab 3: QA                                       │
│     git pull (lee implementación)                   │
│     Revisa: código, tests                           │
│     Crea: review.md                                 │
│     Estado: APPROVED/REJECTED                       │
│     Git: commit + push                              │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  5. workflow status user-authentication             │
│     → ✓ All roles COMPLETED                         │
└─────────────────────────────────────────────────────┘
```

## Tips

### 💡 Tip 1: Siempre sincronizar antes de trabajar
```bash
# En cada tab, antes de empezar:
./scripts/workflow sync
# o manualmente:
git pull
```

### 💡 Tip 2: Verificar estado frecuentemente
```bash
# Ver qué están haciendo otros roles:
./scripts/workflow status user-authentication
```

### 💡 Tip 3: Usar múltiples features a la vez
```bash
# Backend trabaja en feature-1
# Frontend trabaja en feature-2
# Ambos pueden estar en paralelo sin conflictos
```

### 💡 Tip 4: Leer el workflow YAML
```bash
# Antes de empezar, siempre lee:
cat ai/features/user-authentication/workflow.yaml

# Especialmente la sección "instructions" para tu rol
```

### 💡 Tip 5: Si Claude se confunde
```
"Stop. Read the workflow.yaml again and specifically the instructions
for the [YOUR_ROLE] stage. You should ONLY do what's described there."
```

## Troubleshooting

### "Feature already exists"
```bash
# Ver features existentes:
./scripts/workflow list

# Usar otro ID o eliminar el existente:
rm -rf ai/features/user-authentication
```

### "Git conflicts"
```bash
# Stash cambios locales:
git stash

# Pull:
git pull

# Aplicar cambios:
git stash pop

# Resolver conflictos manualmente
```

### "Claude no respeta el rol"
```
Asegúrate de decirle explícitamente:

"You are the [ROLE_NAME] role. Read ./ai/features/X/workflow.yaml
and follow ONLY the instructions for your role. Do NOT do work
assigned to other roles."
```

## Siguiente Nivel

Una vez domines el flujo básico:

1. **DDD Workflow**: Usa `ddd_parallel.yaml` para arquitectura DDD
2. **Custom Templates**: Crea tus propios templates en `ai/workflows/`
3. **Pre-commit Hooks**: Valida workflows automáticamente
4. **CI Integration**: Ejecuta validaciones en CI/CD

---

**¿Listo para empezar?**

```bash
./scripts/workflow consult
```

¡Y sigue el flujo! 🚀
__END_QUICKSTART_md__

create_file 'CHEATSHEET.md' 'CHEATSHEET_md'
__FILE_CHEATSHEET_md__
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
__END_CHEATSHEET_md__

create_file 'SUMMARY.md' 'SUMMARY_md'
__FILE_SUMMARY_md__
# Sistema de Workflow Paralelo para Claude Code - Resumen

## 📦 Contenido del Sistema

Sistema completo y funcional para usar múltiples instancias de Claude Code en paralelo con roles definidos, contexto compartido explícito y workflows declarativos.

## 🎯 Problema que Resuelve

**Problema**: Claude Code no comparte estado entre instancias. Trabajar con múltiples instancias requiere coordinación manual y contexto explícito.

**Solución**: Sistema de archivos explícito donde todo el contexto está escrito en `/ai/`, con workflows YAML que definen roles, permisos y flujo de trabajo.

## ✨ Componentes Principales

### 1. Estructura de Contexto (`/ai/`)
- **PROJECT.md** - Descripción general del proyecto
- **CONSTRAINTS.md** - Reglas, restricciones y permisos por rol
- **DECISIONS.md** - Log de decisiones arquitectónicas (ADL)

### 2. Sistema de Workflows (`/ai/workflows/`)
- **feature_template.yaml** - Template básico (Planning → Dev → QA)
- **ddd_parallel.yaml** - Template DDD con paralelismo de capas
- Workflows declarativos en YAML con roles, stages, permisos

### 3. Features Activos (`/ai/features/<feature-id>/`)
Cada feature tiene:
- `workflow.yaml` - Definición del workflow específico
- `definition.md` - Especificación del feature
- `tasks.md` - Desglose de tareas
- `*_state.md` - Archivos de estado por rol (planner, backend, frontend, qa, etc.)

### 4. Herramientas CLI (`/scripts/`)

#### `workflow` - Gestión de workflows
```bash
workflow init <feature-id> [template]  # Inicializar feature
workflow list                          # Listar features
workflow status [feature-id]           # Ver estado
workflow sync                          # Sincronizar con Git
workflow validate [feature-id]         # Validar workflows
workflow consult                       # Consultor interactivo
workflow help                          # Ayuda
```

#### `workflow-consultant` - Generador Interactivo
Sistema de preguntas que genera el workflow óptimo automáticamente:
- Pregunta sobre tu tarea
- Pregunta sobre estructura del proyecto
- Pregunta sobre equipo y paralelismo
- Genera workflow.yaml personalizado
- Crea archivos de estado iniciales
- Proporciona instrucciones claras

### 5. Documentación Completa

- **README.md** - Documentación principal (instalación, uso, casos de uso)
- **QUICKSTART.md** - Tutorial guiado de 5 minutos
- **CHEATSHEET.md** - Comandos rápidos y tips
- **SUMMARY.md** - Este archivo (resumen ejecutivo)

### 6. Ejemplo Funcional

**example-todo-api** - Feature completo y funcional para aprender:
- Workflow pre-configurado
- Definición completa de API REST
- Tareas desglosadas
- Estados iniciales
- Instrucciones paso a paso

### 7. Hooks de Git (`/hooks/`)

- `pre-commit.example` - Validación automática antes de commit
- Instrucciones de instalación
- Extensible para necesidades específicas

## 🚀 Cómo Empezar

### Opción 1: Consultor Interactivo (Recomendado)
```bash
./scripts/workflow consult
# Responde preguntas
# Workflow generado automáticamente
```

### Opción 2: Probar el Ejemplo
```bash
./scripts/workflow status example-todo-api
cat ai/features/example-todo-api/EXAMPLE_USAGE.md
# Sigue las instrucciones
```

### Opción 3: Manual
```bash
./scripts/workflow init mi-feature feature_template
vim ai/features/mi-feature/definition.md
# Edita y empieza a trabajar
```

## 🎨 Casos de Uso Soportados

### 1. Solo tú, trabajo secuencial
1 instancia, cambias de rol manualmente
```
Planning → Implementation → Review
```

### 2. Solo tú, trabajo paralelo
Múltiples tabs Tilix, cada tab = 1 rol
```
Planning → (Backend || Frontend) → Review
```

### 3. Equipo pequeño
Cada miembro = 1 instancia Claude = 1 rol
```
Persona 1: Planner + QA
Persona 2: Backend
Persona 3: Frontend
```

### 4. DDD con paralelismo
Múltiples capas en paralelo después de planning
```
Planning → (Domain || Application || Infrastructure) → Integration
```

## 📊 Flujo de Trabajo Visual

```
┌─────────────────────────────────────────────────────┐
│  workflow consult                                   │
│  └─> Genera workflow.yaml + archivos iniciales     │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  Claude Instance 1: PLANNER                         │
│  • Lee workflow.yaml                                │
│  • Crea definition.md, tasks.md                     │
│  • Actualiza planner_state.md: COMPLETED           │
│  • git commit + push                                │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  Claude Instance 2: BACKEND DEVELOPER               │
│  • git pull (lee trabajo del Planner)               │
│  • Lee definition.md, tasks.md                      │
│  • Implementa en ./src/                             │
│  • Actualiza backend_state.md                       │
│  • git commit + push                                │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  Claude Instance 3: QA/REVIEWER                     │
│  • git pull (lee implementación)                    │
│  • Revisa código                                    │
│  • Crea review.md                                   │
│  • Actualiza qa_state.md: APPROVED/REJECTED        │
│  • git commit + push                                │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  workflow status <feature-id>                       │
│  └─> ✓ Todos los roles COMPLETED                   │
└─────────────────────────────────────────────────────┘
```

## 🎓 Principios del Sistema

1. **Sin estado compartido en memoria** - Claude no comparte contexto entre instancias
2. **Archivos como fuente de verdad** - Si no está escrito, no existe
3. **Roles inmutables** - Una instancia = un rol fijo
4. **Comunicación via archivos** - Git para sincronización
5. **Workflows declarativos** - YAML define el flujo completo
6. **Validación automática** - Garantiza integridad del sistema

## 📁 Estructura Final del Proyecto

```
workflow/
├── README.md                    # Documentación principal
├── QUICKSTART.md                # Tutorial de 5 minutos
├── CHEATSHEET.md                # Comandos rápidos
├── SUMMARY.md                   # Este archivo
├── .gitignore                   # Git ignore
│
├── ai/                          # ⭐ Contexto compartido
│   ├── PROJECT.md
│   ├── CONSTRAINTS.md
│   ├── DECISIONS.md
│   ├── workflows/               # Templates YAML
│   │   ├── README.md
│   │   ├── feature_template.yaml
│   │   └── ddd_parallel.yaml
│   └── features/                # Features activos
│       └── example-todo-api/    # ⭐ Ejemplo funcional
│           ├── workflow.yaml
│           ├── definition.md
│           ├── tasks.md
│           ├── EXAMPLE_USAGE.md
│           ├── planner_state.md
│           ├── backend_state.md
│           └── qa_state.md
│
├── scripts/                     # ⭐ Herramientas CLI
│   ├── workflow                 # Gestión de workflows
│   ├── workflow-consultant      # Consultor interactivo
│   └── setup-project            # Setup inicial
│
├── hooks/                       # Git hooks
│   ├── README.md
│   └── pre-commit.example
│
└── [src/, frontend/, tests/]    # Tu código (creado al trabajar)
```

## 🎯 Próximos Pasos

1. **Prueba el sistema**:
   ```bash
   ./scripts/workflow consult
   ```

2. **Prueba el ejemplo**:
   ```bash
   cat ai/features/example-todo-api/EXAMPLE_USAGE.md
   ```

3. **Lee la documentación**:
   ```bash
   cat QUICKSTART.md
   ```

4. **Crea tu primer feature real**:
   ```bash
   ./scripts/workflow consult
   # Describe tu tarea real
   # Sigue el workflow generado
   ```

## 🤝 Extensibilidad

El sistema está diseñado para ser extensible:

- ✅ **Nuevos templates**: Crea en `ai/workflows/`
- ✅ **Nuevos roles**: Agrega en workflow YAML
- ✅ **Nuevas validaciones**: Modifica `scripts/workflow`
- ✅ **Hooks personalizados**: Agrega en `hooks/`
- ✅ **Integraciones CI/CD**: Usa `./scripts/workflow validate`

## 📈 Escalabilidad

El sistema escala de:
- **MVP**: 1 persona, 2 roles (Planner + Dev)
- **Pequeño**: 1 persona, 4 roles paralelos
- **Mediano**: 2-3 personas, roles distribuidos
- **Grande**: Múltiples features en paralelo, equipos especializados

## 🔑 Archivos Clave para Entender el Sistema

1. **`ai/workflows/feature_template.yaml`** - Template básico
2. **`ai/features/example-todo-api/workflow.yaml`** - Ejemplo funcional
3. **`scripts/workflow`** - CLI principal
4. **`scripts/workflow-consultant`** - Generador interactivo
5. **`QUICKSTART.md`** - Tutorial práctico

## 💡 Innovaciones del Sistema

1. **Consultor interactivo** - Genera workflows preguntando, no requiere conocer YAML
2. **Estado granular** - Un archivo de estado por rol (evita conflictos Git)
3. **Workflows declarativos** - YAML legible define todo el flujo
4. **Ejemplo funcional** - Aprende haciendo, no solo leyendo
5. **Documentación exhaustiva** - README, Quickstart, Cheatsheet, Ejemplo

## 🎉 Resultado Final

Un sistema **completo, funcional y documentado** para usar Claude Code en paralelo de forma organizada, escalable y mantenible.

**No más**: "Claude, ¿recuerdas que hablamos de...?"
**Ahora**: "Claude, lee `./ai/features/X/definition.md`"

---

**Sistema creado el**: 2026-01-15
**Versión**: 1.0.0
**Estado**: ✅ Completo y funcional
__END_SUMMARY_md__

create_file '.gitignore' '_gitignore'
__FILE__gitignore__
# Dependencies
node_modules/
vendor/
venv/
__pycache__/
*.pyc

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Build outputs
dist/
build/
*.log

# Environment
.env
.env.local

# Keep ai/ directory structure
!ai/
!ai/**

# But ignore any generated/temporary files in ai/
ai/**/*.tmp
ai/**/*.bak
__END__gitignore__

create_file 'ai/CONSTRAINTS.md' 'ai_CONSTRAINTS_md'
__FILE_ai_CONSTRAINTS_md__
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
__END_ai_CONSTRAINTS_md__

create_file 'ai/DECISIONS.md' 'ai_DECISIONS_md'
__FILE_ai_DECISIONS_md__
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
__END_ai_DECISIONS_md__

create_file 'ai/PROJECT.md' 'ai_PROJECT_md'
__FILE_ai_PROJECT_md__
# Project Overview

## Descripción
Sistema de workflow escalable para Claude Code en paralelo. Permite ejecutar múltiples instancias de Claude Code con roles definidos, contexto compartido explícito y sincronización mediante archivos.

## Objetivo
Facilitar desarrollo paralelo y organizado usando múltiples instancias de Claude Code trabajando en el mismo proyecto o en proyectos relacionados.

## Arquitectura
- **Contexto explícito**: Todo el conocimiento compartido está en `/ai/`
- **Roles definidos**: Cada instancia Claude tiene un rol específico
- **Estado centralizado**: Archivos de estado sincronizados via Git
- **Workflows declarativos**: YAML define tareas, dependencias y permisos

## Stack Tecnológico
- Claude Code CLI
- Git para sincronización
- YAML para definición de workflows
- Markdown para documentación y contexto
- Bash scripts para automatización

## Principios
1. **Sin estado compartido en memoria**: Claude Code no comparte contexto entre instancias
2. **Archivos como fuente de verdad**: Si no está escrito, no existe
3. **Roles inmutables**: Una instancia = un rol fijo
4. **Validación automática**: Pre-commit hooks garantizan integridad
5. **Incremental**: Empezar simple, escalar según necesidad
__END_ai_PROJECT_md__

create_file 'ai/workflows/ddd_parallel.yaml' 'ai_workflows_ddd_parallel_yaml'
__FILE_ai_workflows_ddd_parallel_yaml__
metadata:
  name: "DDD Feature with Parallel Implementation"
  id: "ddd-parallel"
  description: "Feature usando Domain-Driven Design con capas implementadas en paralelo"
  created: "2026-01-15"
  status: "template"

roles:
  - id: planner
    name: "Planner"
    description: "Define arquitectura DDD del feature"

  - id: domain_dev
    name: "Domain Developer"
    description: "Implementa capa de dominio (entidades, value objects, domain services)"

  - id: application_dev
    name: "Application Developer"
    description: "Implementa capa de aplicación (use cases, DTOs)"

  - id: infrastructure_dev
    name: "Infrastructure Developer"
    description: "Implementa capa de infraestructura (repositories, adapters)"

  - id: qa
    name: "QA/Integration Tester"
    description: "Valida integración entre capas"

stages:
  - id: planning
    name: "DDD Architecture Planning"
    owner: planner
    workspace: "./ai/features/{FEATURE_ID}/"
    permissions:
      read:
        - "./ai/**"
        - "./src/**"
      write:
        - "./ai/features/{FEATURE_ID}/definition.md"
        - "./ai/features/{FEATURE_ID}/ddd_architecture.md"
        - "./ai/features/{FEATURE_ID}/planner_state.md"
    dependencies: []
    parallel: false
    state_file: "planner_state.md"
    outputs:
      - "definition.md"
      - "ddd_architecture.md"

  - id: domain
    name: "Domain Layer Implementation"
    owner: domain_dev
    workspace: "./src/Domain/"
    permissions:
      read:
        - "./ai/features/{FEATURE_ID}/**"
        - "./src/Domain/**"
      write:
        - "./src/Domain/**"
        - "./ai/features/{FEATURE_ID}/domain_state.md"
    dependencies: ["planning"]
    parallel: true
    state_file: "domain_state.md"
    outputs:
      - "Domain entities and value objects"

  - id: application
    name: "Application Layer Implementation"
    owner: application_dev
    workspace: "./src/Application/"
    permissions:
      read:
        - "./ai/features/{FEATURE_ID}/**"
        - "./src/Domain/**"
        - "./src/Application/**"
      write:
        - "./src/Application/**"
        - "./ai/features/{FEATURE_ID}/application_state.md"
    dependencies: ["domain"]
    parallel: true
    state_file: "application_state.md"
    outputs:
      - "Use cases and application services"

  - id: infrastructure
    name: "Infrastructure Layer Implementation"
    owner: infrastructure_dev
    workspace: "./src/Infrastructure/"
    permissions:
      read:
        - "./ai/features/{FEATURE_ID}/**"
        - "./src/Domain/**"
        - "./src/Infrastructure/**"
      write:
        - "./src/Infrastructure/**"
        - "./ai/features/{FEATURE_ID}/infrastructure_state.md"
    dependencies: ["domain"]
    parallel: true
    state_file: "infrastructure_state.md"
    outputs:
      - "Repositories and infrastructure adapters"

  - id: integration
    name: "Integration & Testing"
    owner: qa
    workspace: "./"
    permissions:
      read:
        - "./ai/**"
        - "./src/**"
        - "./tests/**"
      write:
        - "./ai/features/{FEATURE_ID}/qa_state.md"
        - "./ai/features/{FEATURE_ID}/integration_review.md"
    dependencies: ["application", "infrastructure"]
    parallel: false
    state_file: "qa_state.md"
    outputs:
      - "integration_review.md"

validation:
  required_files:
    - "definition.md"
    - "ddd_architecture.md"
  state_format: "markdown"
  allow_parallel_writes: true

instructions:
  planning:
    prompt: |
      Eres el PLANNER especializado en DDD. Tu trabajo es:

      1. Analizar el feature request
      2. Diseñar la arquitectura DDD en `ddd_architecture.md`:
         - **Domain Layer**: Entidades, Value Objects, Domain Events
         - **Application Layer**: Use Cases, DTOs, Interfaces
         - **Infrastructure Layer**: Repositories impl, External services
         - **Dependencias**: Qué capa depende de qué
      3. Crear `definition.md` con:
         - Bounded Context
         - Ubiquitous Language (términos del dominio)
         - Invariantes del dominio
      4. Actualizar `planner_state.md`: COMPLETED

      Define contratos claros entre capas para permitir trabajo paralelo.

  domain:
    prompt: |
      Eres el DOMAIN DEVELOPER. Tu trabajo es:

      1. Leer `ddd_architecture.md` - sección Domain Layer
      2. Implementar en `./src/Domain/`:
         - Entities (lógica de negocio rica)
         - Value Objects (inmutables)
         - Domain Services
         - Domain Events
         - Interfaces de Repositories (sin implementación)
      3. Actualizar `domain_state.md`:
         - Entidades creadas
         - Value Objects creados
         - Contratos de repositorio definidos

      NO implementes infraestructura. Solo lógica de dominio pura.
      NO dependas de frameworks. Dominio debe ser framework-agnostic.

  application:
    prompt: |
      Eres el APPLICATION DEVELOPER. Tu trabajo es:

      1. Leer contratos de Domain Layer
      2. Implementar en `./src/Application/`:
         - Use Cases (orquestación)
         - DTOs (input/output)
         - Application Services
      3. Usar interfaces de Repository (inyección de dependencias)
      4. Actualizar `application_state.md`

      Si Domain Layer no está completo, marca estado: BLOCKED

  infrastructure:
    prompt: |
      Eres el INFRASTRUCTURE DEVELOPER. Tu trabajo es:

      1. Leer interfaces de Repository de Domain Layer
      2. Implementar en `./src/Infrastructure/`:
         - Repository implementations (ORM, DB access)
         - External service adapters
         - Framework integrations
      3. Actualizar `infrastructure_state.md`

      Si Domain Layer no está completo, marca estado: BLOCKED

  integration:
    prompt: |
      Eres el QA/INTEGRATION TESTER. Tu trabajo es:

      1. Verificar que las tres capas se integran correctamente
      2. Validar que se respetan las dependencias DDD:
         - Application NO depende de Infrastructure
         - Domain NO depende de nada externo
         - Infrastructure depende de Domain (implementa interfaces)
      3. Probar flujo completo: API → Application → Domain → Infrastructure → DB
      4. Crear `integration_review.md` con:
         - ✅ Integraciones funcionando
         - ❌ Dependencias violadas
         - 💡 Mejoras arquitectónicas
      5. Actualizar `qa_state.md`: APPROVED o REJECTED

# Ejemplo de paralelización
#
# Tilix Layout (4 panes):
# ┌──────────────┬──────────────┐
# │   Planner    │  Domain Dev  │
# ├──────────────┼──────────────┤
# │ App Dev      │ Infra Dev    │
# └──────────────┴──────────────┘
#
# Flujo:
# 1. Planner define arquitectura → COMPLETED
# 2. Domain Dev lee y empieza (sin esperar App/Infra)
# 3. Cuando Domain tiene contratos básicos → WORKING
# 4. App Dev + Infra Dev arrancan EN PARALELO (ambos leen contratos)
# 5. Cuando ambos COMPLETED → QA integra
__END_ai_workflows_ddd_parallel_yaml__

create_file 'ai/workflows/feature_template.yaml' 'ai_workflows_feature_template_yaml'
__FILE_ai_workflows_feature_template_yaml__
metadata:
  name: "Feature Template"
  id: "template"
  description: "Template base para crear nuevos features"
  created: "2026-01-15"
  status: "template"

roles:
  - id: planner
    name: "Planner"
    description: "Define el feature, crea tareas, toma decisiones arquitectónicas"

  - id: developer
    name: "Developer"
    description: "Implementa el feature según la definición"

  - id: qa
    name: "QA/Reviewer"
    description: "Revisa implementación, documenta problemas, valida calidad"

stages:
  - id: planning
    name: "Planning & Definition"
    owner: planner
    workspace: "./ai/features/{FEATURE_ID}/"
    permissions:
      read:
        - "./ai/**"
      write:
        - "./ai/features/{FEATURE_ID}/definition.md"
        - "./ai/features/{FEATURE_ID}/tasks.md"
        - "./ai/features/{FEATURE_ID}/planner_state.md"
    dependencies: []
    parallel: false
    state_file: "planner_state.md"
    outputs:
      - "definition.md"
      - "tasks.md"

  - id: implementation
    name: "Implementation"
    owner: developer
    workspace: "./src/"
    permissions:
      read:
        - "./ai/**"
        - "./src/**"
      write:
        - "./src/**"
        - "./ai/features/{FEATURE_ID}/dev_state.md"
    dependencies: ["planning"]
    parallel: false
    state_file: "dev_state.md"
    outputs:
      - "Código implementado en ./src/"

  - id: review
    name: "QA & Review"
    owner: qa
    workspace: "./"
    permissions:
      read:
        - "./ai/**"
        - "./src/**"
        - "./tests/**"
      write:
        - "./ai/features/{FEATURE_ID}/qa_state.md"
        - "./ai/features/{FEATURE_ID}/review.md"
    dependencies: ["implementation"]
    parallel: false
    state_file: "qa_state.md"
    outputs:
      - "review.md"

validation:
  required_files:
    - "definition.md"
    - "tasks.md"
    - "planner_state.md"
  state_format: "markdown"
  allow_parallel_writes: false

# Instrucciones por Stage

instructions:
  planning:
    prompt: |
      Eres el PLANNER. Tu trabajo es:

      1. Leer el feature request del usuario
      2. Crear `definition.md` con:
         - Objetivo del feature
         - Requisitos funcionales
         - Criterios de aceptación
         - Consideraciones técnicas
      3. Crear `tasks.md` con lista de tareas específicas
      4. Actualizar `planner_state.md` con estado: COMPLETED

      NO implementes código. Solo planifica y define.

  implementation:
    prompt: |
      Eres el DEVELOPER. Tu trabajo es:

      1. Leer `definition.md` y `tasks.md`
      2. Implementar el código necesario en `./src/`
      3. Actualizar `dev_state.md` con:
         - Tareas completadas
         - Archivos modificados
         - Decisiones técnicas tomadas
         - Bloqueos o dudas (estado: BLOCKED)

      Sigue la definición estrictamente. Si algo no está claro, marca BLOCKED.

  review:
    prompt: |
      Eres el QA/REVIEWER. Tu trabajo es:

      1. Leer `definition.md` para entender expectativas
      2. Revisar código implementado
      3. Verificar que cumple criterios de aceptación
      4. Crear `review.md` con:
         - ✅ Aspectos que cumplen
         - ❌ Problemas encontrados
         - 💡 Sugerencias de mejora
      5. Actualizar `qa_state.md` con estado: APPROVED o REJECTED

      NO fixes código tú mismo. Reporta problemas al Developer.
__END_ai_workflows_feature_template_yaml__

create_file 'ai/workflows/README.md' 'ai_workflows_README_md'
__FILE_ai_workflows_README_md__
# Workflows Directory

Este directorio contiene las definiciones de workflows en formato YAML.

## Estructura de un Workflow

```yaml
metadata:
  name: "Nombre del Feature"
  id: "feature-id"
  description: "Descripción breve"
  created: "YYYY-MM-DD"
  status: "active|completed|blocked"

roles:
  - id: planner
    name: "Planner"
    description: "Define y coordina el feature"

  - id: backend
    name: "Backend Developer"
    description: "Implementa lógica de servidor"

stages:
  - id: planning
    name: "Planning & Design"
    owner: planner
    workspace: "./ai/features/FEATURE_X/"
    permissions:
      read: ["./ai/**"]
      write: ["./ai/features/FEATURE_X/definition.md"]
    dependencies: []
    parallel: false
    state_file: "planner_state.md"

  - id: implementation
    name: "Implementation"
    owner: backend
    workspace: "./src/"
    permissions:
      read: ["./ai/**", "./src/**"]
      write: ["./src/**", "./ai/features/FEATURE_X/backend_state.md"]
    dependencies: ["planning"]
    parallel: false
    state_file: "backend_state.md"

validation:
  required_files:
    - "definition.md"
    - "planner_state.md"
  state_format: "markdown"
  allow_parallel_writes: false
```

## Campos Explicados

### metadata
- **name**: Nombre legible del feature
- **id**: Identificador único (sin espacios, kebab-case)
- **status**: Estado actual del workflow
  - `active`: En progreso
  - `completed`: Terminado
  - `blocked`: Bloqueado esperando algo
  - `paused`: Pausado temporalmente

### roles
Define qué roles participan en este workflow.

- **id**: Identificador único del rol
- **name**: Nombre legible
- **description**: Qué hace este rol

### stages
Etapas secuenciales o paralelas del workflow.

- **id**: Identificador de la etapa
- **owner**: ID del rol responsable
- **workspace**: Directorio principal de trabajo
- **permissions**: Qué puede leer/escribir
  - `read`: Array de globs de archivos/directorios
  - `write`: Array de globs de archivos/directorios
- **dependencies**: IDs de etapas que deben completarse antes
- **parallel**: `true` si puede ejecutarse en paralelo con otras etapas
- **state_file**: Nombre del archivo de estado para esta etapa

### validation
Reglas de validación del workflow.

- **required_files**: Archivos que deben existir
- **state_format**: Formato esperado de archivos de estado
- **allow_parallel_writes**: Si se permiten escrituras simultáneas

## Workflows Disponibles

- `feature_template.yaml` - Template base para features
- `ddd_parallel.yaml` - Workflow DDD con paralelismo
- `fullstack_feature.yaml` - Feature full-stack coordinado

## Uso

1. Copiar template apropiado
2. Adaptar a tu feature específico
3. Validar con `./scripts/workflow validate FEATURE_ID`
4. Inicializar con `./scripts/workflow init FEATURE_ID`
5. Ejecutar stages siguiendo el workflow
__END_ai_workflows_README_md__

create_file 'ai/features/example-todo-api/EXAMPLE_USAGE.md' 'ai_features_example-todo-api_EXAMPLE_USAGE_md'
__FILE_ai_features_example-todo-api_EXAMPLE_USAGE_md__
# How to Use This Example

This is a pre-configured example feature to help you learn the workflow system.

## Quick Test (Solo Mode - Sequential)

### Setup
```bash
# From project root
cd /home/user/workflow

# Verify example exists
./scripts/workflow list

# Should show:
#   example-todo-api [active]
```

### Step 1: Planning (Optional - already done)

The `definition.md` is pre-filled as an example. In a real workflow, you'd ask Claude to create this.

**Optional**: Ask Claude to create `tasks.md`:

```
I am the PLANNER for the example-todo-api feature.

Please:
1. Read ./ai/features/example-todo-api/definition.md
2. Create ./ai/features/example-todo-api/tasks.md breaking down the implementation into specific tasks
3. Update ./ai/features/example-todo-api/planner_state.md with status: COMPLETED
```

### Step 2: Backend Implementation

Start a new Claude Code session:

```
I am the BACKEND DEVELOPER for the example-todo-api feature.

Please:
1. Read ./ai/features/example-todo-api/workflow.yaml
2. Read ./ai/features/example-todo-api/definition.md
3. Follow the implementation stage instructions
4. Create a simple REST API in ./src/ for managing TODO items
5. Update ./ai/features/example-todo-api/backend_state.md as you work
```

Claude will implement:
- `src/todos.js` (or similar) with the REST API
- All 5 CRUD endpoints
- In-memory storage
- Error handling

### Step 3: QA Review

Start another Claude Code session:

```
I am the QA/REVIEWER for the example-todo-api feature.

Please:
1. Read ./ai/features/example-todo-api/workflow.yaml
2. Read ./ai/features/example-todo-api/definition.md
3. Review the implementation in ./src/
4. Create ./ai/features/example-todo-api/review.md with your findings
5. Update ./ai/features/example-todo-api/qa_state.md with status: APPROVED or REJECTED
```

### Step 4: Check Results

```bash
# View final status
./scripts/workflow status example-todo-api

# Should show:
#   planner:     COMPLETED
#   backend:     COMPLETED
#   qa:          APPROVED (or REJECTED)

# Read the review
cat ai/features/example-todo-api/review.md
```

## Advanced Test (Parallel Mode)

To test parallel workflow with multiple Claude instances:

### Setup Tilix (4 panes)

```
┌──────────────┬──────────────┐
│   Tab 1      │   Tab 2      │
│   (Planner)  │  (Backend)   │
├──────────────┼──────────────┤
│   Tab 3      │   Tab 4      │
│   (Monitor)  │   (QA)       │
└──────────────┴──────────────┘
```

### Tab 1: Planner
```bash
cd /home/user/workflow
claude

# Inside Claude:
"I am the PLANNER. Create tasks.md for example-todo-api feature."
```

### Tab 2: Backend (wait for Planner)
```bash
cd /home/user/workflow
git pull  # Get planner's work
claude

# Inside Claude:
"I am the BACKEND DEVELOPER. Implement the example-todo-api according to the definition."
```

### Tab 3: Monitor
```bash
cd /home/user/workflow

# Keep checking status
watch -n 5 './scripts/workflow status example-todo-api'
```

### Tab 4: QA (wait for Backend)
```bash
cd /home/user/workflow
git pull  # Get backend's work
claude

# Inside Claude:
"I am the QA/REVIEWER. Review the example-todo-api implementation."
```

## What You'll Learn

1. **File-based context**: How Claude instances communicate through files
2. **Role separation**: Each Claude has a specific responsibility
3. **State tracking**: How `*_state.md` files track progress
4. **Git synchronization**: How `git pull/push` keeps everyone in sync
5. **Workflow structure**: How YAML defines roles and stages

## Expected Output

After completing the workflow, you'll have:

```
ai/features/example-todo-api/
├── workflow.yaml          # Workflow definition
├── definition.md          # API specification (pre-filled)
├── tasks.md               # Task breakdown (created by Planner)
├── planner_state.md       # COMPLETED
├── backend_state.md       # COMPLETED
├── qa_state.md            # APPROVED
└── review.md              # QA findings

src/
└── todos.js               # REST API implementation (or similar)
```

## Cleanup

To reset the example and try again:

```bash
# Remove implementation
rm -rf src/

# Reset state files
git checkout ai/features/example-todo-api/*_state.md

# Remove generated files
rm -f ai/features/example-todo-api/tasks.md
rm -f ai/features/example-todo-api/review.md
```

## Next Steps

Once you've completed this example:

1. Create your own feature: `./scripts/workflow consult`
2. Try the DDD parallel workflow: `./scripts/workflow init my-feature ddd_parallel`
3. Customize templates in `ai/workflows/`
4. Read the full documentation in `README.md`

---

**Pro tip**: This example is intentionally simple. Real features will be more complex, but the workflow process is identical.
__END_ai_features_example-todo-api_EXAMPLE_USAGE_md__

create_file 'ai/features/example-todo-api/backend_state.md' 'ai_features_example-todo-api_backend_state_md'
__FILE_ai_features_example-todo-api_backend_state_md__
# State: Backend Developer

**Feature**: example-todo-api
**Last Updated**: 2026-01-15 00:00:00 UTC
**Status**: PENDING

## Current Task
Waiting for Planner to complete definition

## Completed Tasks
- (none)

## Blocked By
- Planning stage not completed yet

## Notes

**Instructions for Backend Developer:**
1. Wait for Planner to complete (status: COMPLETED)
2. Run: `git pull` to get latest definition
3. Read `definition.md` and `tasks.md`
4. Implement the REST API in `./src/`
5. Update this file as you progress
6. Commit and push when done

**Implementation checklist:**
- [ ] Create Todo model/type
- [ ] Implement in-memory storage
- [ ] Implement GET /todos
- [ ] Implement GET /todos/:id
- [ ] Implement POST /todos
- [ ] Implement PUT /todos/:id
- [ ] Implement DELETE /todos/:id
- [ ] Add error handling
- [ ] Test manually (optional)
__END_ai_features_example-todo-api_backend_state_md__

create_file 'ai/features/example-todo-api/definition.md' 'ai_features_example-todo-api_definition_md'
__FILE_ai_features_example-todo-api_definition_md__
# Example Feature: TODO API

**Status**: Template/Example
**Complexity**: Simple
**Estimated Time**: 1-2 hours for complete workflow

## Overview

A simple REST API for managing TODO items. This serves as an example to demonstrate the Claude Code parallel workflow system.

## Objectives

- Create a functional REST API with CRUD operations
- Demonstrate the workflow from Planning → Implementation → Review
- Show how roles communicate via files
- Provide a working example for learning the system

## API Specification

### Endpoints

#### GET /todos
- **Description**: List all TODO items
- **Response**: Array of Todo objects
- **Status Codes**: 200 OK

#### GET /todos/:id
- **Description**: Get a single TODO item by ID
- **Parameters**: `id` (integer)
- **Response**: Todo object
- **Status Codes**: 200 OK, 404 Not Found

#### POST /todos
- **Description**: Create a new TODO item
- **Request Body**:
  ```json
  {
    "title": "string (required)",
    "description": "string (optional)"
  }
  ```
- **Response**: Created Todo object
- **Status Codes**: 201 Created, 400 Bad Request

#### PUT /todos/:id
- **Description**: Update an existing TODO item
- **Parameters**: `id` (integer)
- **Request Body**:
  ```json
  {
    "title": "string (optional)",
    "description": "string (optional)",
    "completed": "boolean (optional)"
  }
  ```
- **Response**: Updated Todo object
- **Status Codes**: 200 OK, 404 Not Found, 400 Bad Request

#### DELETE /todos/:id
- **Description**: Delete a TODO item
- **Parameters**: `id` (integer)
- **Response**: 204 No Content
- **Status Codes**: 204 No Content, 404 Not Found

### Data Model

**Todo**
```typescript
{
  id: number,           // Auto-incremented, unique
  title: string,        // Required, max 200 chars
  description: string,  // Optional, max 1000 chars
  completed: boolean,   // Default: false
  createdAt: Date,      // Timestamp of creation
  updatedAt: Date       // Timestamp of last update
}
```

## Requirements

### Functional
- ✅ All 5 CRUD endpoints must be implemented
- ✅ Data validation on POST and PUT
- ✅ Proper HTTP status codes
- ✅ JSON request/response format
- ✅ In-memory storage (no database needed for example)

### Non-Functional
- **Performance**: Response time < 100ms for in-memory operations
- **Code Quality**: Clean, readable code with comments where necessary
- **Error Handling**: Graceful error responses with meaningful messages
- **Maintainability**: Modular code structure

## Acceptance Criteria

- [ ] GET /todos returns array of all todos
- [ ] GET /todos/:id returns single todo or 404
- [ ] POST /todos creates new todo with auto-generated ID
- [ ] POST /todos validates required fields (title)
- [ ] PUT /todos/:id updates existing todo
- [ ] PUT /todos/:id returns 404 if todo doesn't exist
- [ ] DELETE /todos/:id removes todo
- [ ] DELETE /todos/:id returns 404 if todo doesn't exist
- [ ] All endpoints return proper Content-Type: application/json
- [ ] Error responses include meaningful error messages

## Technical Considerations

### Architecture
- Simple REST API (no framework required, can use Express, Fastify, etc.)
- In-memory storage (JavaScript array)
- Single file is acceptable for this example

### Storage
```javascript
// In-memory storage example
let todos = [];
let nextId = 1;
```

### Error Handling
- 400 Bad Request: Invalid input data
- 404 Not Found: Todo ID doesn't exist
- 500 Internal Server Error: Unexpected errors

## Out of Scope

This example explicitly does NOT include:
- Database persistence (use in-memory array)
- Authentication/Authorization
- Rate limiting
- CORS configuration
- Unit tests (though you can add them if you want)
- Docker/deployment configuration
- Frontend UI

## Notes for Learners

This feature is intentionally simple to focus on **learning the workflow system**, not the complexity of the feature itself.

**What you'll learn:**
1. How Planner defines a feature
2. How Backend Developer reads the definition and implements
3. How QA reviews the implementation
4. How roles communicate via files
5. How state synchronization works with Git

**Estimated timeline:**
- Planning: 10-15 minutes
- Implementation: 30-45 minutes
- Review: 15-20 minutes

**Total**: 1-1.5 hours for complete workflow cycle
__END_ai_features_example-todo-api_definition_md__

create_file 'ai/features/example-todo-api/planner_state.md' 'ai_features_example-todo-api_planner_state_md'
__FILE_ai_features_example-todo-api_planner_state_md__
# State: Planner

**Feature**: example-todo-api
**Last Updated**: 2026-01-15 00:00:00 UTC
**Status**: PENDING

## Current Task
Initial planning phase - awaiting Planner to start

## Completed Tasks
- (none yet - this is the starting state)

## Blocked By
- (none)

## Notes

This is an example feature to demonstrate the workflow system.

**Instructions for Planner:**
1. Read `workflow.yaml` and understand your role
2. Review the pre-filled `definition.md` (already provided as example)
3. Create `tasks.md` breaking down the implementation
4. Update this file with status: COMPLETED
5. Commit and push your changes

Since this is an example, the `definition.md` is pre-filled for learning purposes.
In a real workflow, the Planner would create this from scratch based on user requirements.
__END_ai_features_example-todo-api_planner_state_md__

create_file 'ai/features/example-todo-api/qa_state.md' 'ai_features_example-todo-api_qa_state_md'
__FILE_ai_features_example-todo-api_qa_state_md__
# State: QA/Reviewer

**Feature**: example-todo-api
**Last Updated**: 2026-01-15 00:00:00 UTC
**Status**: PENDING

## Current Task
Waiting for Backend Developer to complete implementation

## Completed Tasks
- (none)

## Blocked By
- Implementation stage not completed yet

## Notes

**Instructions for QA/Reviewer:**
1. Wait for Backend Developer to complete (status: COMPLETED)
2. Run: `git pull` to get latest implementation
3. Read `definition.md` to understand requirements
4. Review code in `./src/`
5. Create `review.md` with findings
6. Update this file with status: APPROVED or REJECTED
7. Commit and push your review

**Review checklist:**
- [ ] All 5 endpoints implemented
- [ ] Data validation present
- [ ] Error handling works
- [ ] Code is clean and readable
- [ ] API matches specification
- [ ] Acceptance criteria met
__END_ai_features_example-todo-api_qa_state_md__

create_file 'ai/features/example-todo-api/tasks.md' 'ai_features_example-todo-api_tasks_md'
__FILE_ai_features_example-todo-api_tasks_md__
# Tasks: TODO API Feature

**Feature**: example-todo-api
**Status**: Template/Example

## Implementation Tasks

### Phase 1: Setup & Data Model
- [ ] Create Todo type/interface
  - Properties: id, title, description, completed, createdAt, updatedAt
- [ ] Setup in-memory storage (array)
- [ ] Create ID generator (auto-increment)

### Phase 2: CRUD Endpoints

#### GET /todos
- [ ] Implement endpoint handler
- [ ] Return array of all todos
- [ ] Return 200 OK

#### GET /todos/:id
- [ ] Implement endpoint handler
- [ ] Parse ID parameter
- [ ] Find todo by ID
- [ ] Return 200 OK if found
- [ ] Return 404 Not Found if not found

#### POST /todos
- [ ] Implement endpoint handler
- [ ] Parse request body
- [ ] Validate required fields (title)
- [ ] Create new todo with generated ID
- [ ] Add to storage
- [ ] Return 201 Created with created todo
- [ ] Return 400 Bad Request if validation fails

#### PUT /todos/:id
- [ ] Implement endpoint handler
- [ ] Parse ID parameter
- [ ] Find todo by ID
- [ ] Parse request body (partial update)
- [ ] Update todo fields
- [ ] Update `updatedAt` timestamp
- [ ] Return 200 OK with updated todo
- [ ] Return 404 Not Found if todo doesn't exist
- [ ] Return 400 Bad Request if validation fails

#### DELETE /todos/:id
- [ ] Implement endpoint handler
- [ ] Parse ID parameter
- [ ] Find and remove todo by ID
- [ ] Return 204 No Content
- [ ] Return 404 Not Found if todo doesn't exist

### Phase 3: Error Handling
- [ ] Implement 400 Bad Request responses
- [ ] Implement 404 Not Found responses
- [ ] Implement 500 Internal Server Error fallback
- [ ] Ensure all errors return JSON with error message

### Phase 4: Testing (Optional)
- [ ] Manual testing with curl/Postman
- [ ] Test all endpoints
- [ ] Test error cases

## Technical Notes

**Framework**: Choose any (Express, Fastify, native Node.js, etc.)

**Storage**: In-memory array is sufficient for this example
```javascript
let todos = [];
let nextId = 1;
```

**Error format**:
```json
{
  "error": "Error message here"
}
```

**Success responses**: Always JSON format

## Acceptance Criteria

- [ ] All 5 endpoints implemented (GET all, GET one, POST, PUT, DELETE)
- [ ] Proper HTTP status codes (200, 201, 204, 400, 404)
- [ ] Request/response bodies are JSON
- [ ] Input validation works (required fields checked)
- [ ] Error responses include meaningful messages
- [ ] Code is clean and commented where needed

## Estimated Time

- Setup & Data Model: 10 minutes
- CRUD Endpoints: 30 minutes
- Error Handling: 10 minutes
- Testing: 10 minutes

**Total**: ~1 hour
__END_ai_features_example-todo-api_tasks_md__

create_file 'ai/features/example-todo-api/workflow.yaml' 'ai_features_example-todo-api_workflow_yaml'
__FILE_ai_features_example-todo-api_workflow_yaml__
metadata:
  name: "Example: TODO API"
  id: "example-todo-api"
  description: "Example feature - Simple REST API for managing TODO items"
  created: "2026-01-15"
  status: "active"

roles:
  - id: planner
    name: "Planner"
    description: "Defines the TODO API feature, creates tasks, makes architectural decisions"

  - id: backend
    name: "Backend Developer"
    description: "Implements the REST API endpoints"

  - id: qa
    name: "QA/Reviewer"
    description: "Reviews implementation, validates API contracts"

stages:
  - id: planning
    name: "Planning & Definition"
    owner: planner
    workspace: "./ai/features/example-todo-api/"
    permissions:
      read:
        - "./ai/**"
        - "./src/**"
      write:
        - "./ai/features/example-todo-api/definition.md"
        - "./ai/features/example-todo-api/tasks.md"
        - "./ai/features/example-todo-api/planner_state.md"
    dependencies: []
    parallel: false
    state_file: "planner_state.md"
    outputs:
      - "definition.md"
      - "tasks.md"

  - id: implementation
    name: "Backend Implementation"
    owner: backend
    workspace: "./src/"
    permissions:
      read:
        - "./ai/**"
        - "./src/**"
      write:
        - "./src/**"
        - "./ai/features/example-todo-api/backend_state.md"
    dependencies: ["planning"]
    parallel: false
    state_file: "backend_state.md"
    outputs:
      - "REST API implementation"

  - id: review
    name: "QA & Review"
    owner: qa
    workspace: "./"
    permissions:
      read:
        - "./ai/**"
        - "./src/**"
        - "./tests/**"
      write:
        - "./ai/features/example-todo-api/qa_state.md"
        - "./ai/features/example-todo-api/review.md"
    dependencies: ["implementation"]
    parallel: false
    state_file: "qa_state.md"
    outputs:
      - "review.md"

validation:
  required_files:
    - "definition.md"
    - "tasks.md"
    - "planner_state.md"
  state_format: "markdown"
  allow_parallel_writes: false

instructions:
  planning:
    prompt: |
      You are the PLANNER for the TODO API feature.

      Your responsibilities:
      1. Read this workflow.yaml to understand the feature
      2. Create detailed `definition.md` with:
         - Feature overview (REST API for TODO items)
         - API endpoints specification:
           * GET /todos - List all todos
           * GET /todos/:id - Get single todo
           * POST /todos - Create todo
           * PUT /todos/:id - Update todo
           * DELETE /todos/:id - Delete todo
         - Data model (Todo: id, title, description, completed, createdAt)
         - Acceptance criteria (checklist)
      3. Create `tasks.md` with specific implementation tasks
      4. Update `planner_state.md` with status: COMPLETED

      DO NOT implement code. Only plan and define.

      After completing, commit your work:
      git add ai/features/example-todo-api/
      git commit -m "Planning: TODO API feature"
      git push

  implementation:
    prompt: |
      You are the BACKEND DEVELOPER for the TODO API feature.

      Your responsibilities:
      1. First, sync: git pull
      2. Read `definition.md` and `tasks.md` from the Planner
      3. Implement REST API in ./src/:
         - Todo model/entity
         - CRUD endpoints (GET, POST, PUT, DELETE)
         - In-memory storage (array) is fine for this example
         - Basic error handling
      4. Update `backend_state.md` with:
         - Completed tasks (checklist)
         - Files created/modified
         - Any technical decisions made

      Follow the API specification from definition.md strictly.

      After completing, commit your work:
      git add src/ ai/features/example-todo-api/backend_state.md
      git commit -m "Implementation: TODO API endpoints"
      git push

  review:
    prompt: |
      You are the QA/REVIEWER for the TODO API feature.

      Your responsibilities:
      1. First, sync: git pull
      2. Read `definition.md` to understand expectations
      3. Review the implementation in ./src/
      4. Verify:
         - All API endpoints are implemented
         - Data model matches specification
         - Error handling is present
         - Code is clean and maintainable
      5. Create `review.md` with:
         - ✅ Aspects that meet requirements
         - ❌ Issues found
         - 💡 Suggestions for improvement
      6. Update `qa_state.md` with status: APPROVED or REJECTED

      DO NOT fix code yourself. Report issues for the Backend Developer.

      After completing, commit your review:
      git add ai/features/example-todo-api/
      git commit -m "Review: TODO API feature"
      git push
__END_ai_features_example-todo-api_workflow_yaml__

create_file 'scripts/workflow' 'scripts_workflow'
__FILE_scripts_workflow__
#!/usr/bin/env bash

# Claude Code Workflow Manager
# Gestiona workflows, features y sincronización entre instancias Claude

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AI_DIR="$PROJECT_ROOT/ai"
WORKFLOWS_DIR="$AI_DIR/workflows"
FEATURES_DIR="$AI_DIR/features"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helpers
info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warning() { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }
die() { error "$*"; exit 1; }

# Ensure ai/ directory exists
ensure_ai_structure() {
    mkdir -p "$WORKFLOWS_DIR" "$FEATURES_DIR"
}

# Parse YAML (simple key: value parser)
parse_yaml() {
    local yaml_file="$1"
    local prefix="${2:-}"

    python3 -c "
import yaml, sys
try:
    with open('$yaml_file') as f:
        data = yaml.safe_load(f)
    if data:
        for key, value in data.items():
            if isinstance(value, dict):
                for k, v in value.items():
                    print(f'${prefix}{key}_{k}={v}')
            else:
                print(f'${prefix}{key}={value}')
except Exception as e:
    print(f'Error parsing YAML: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Commands

cmd_init() {
    local feature_id="$1"
    local workflow_template="${2:-feature_template}"

    info "Initializing feature: $feature_id"

    local template_file="$WORKFLOWS_DIR/${workflow_template}.yaml"
    [[ -f "$template_file" ]] || die "Template not found: $template_file"

    local feature_dir="$FEATURES_DIR/$feature_id"
    [[ -d "$feature_dir" ]] && die "Feature already exists: $feature_id"

    # Create feature directory
    mkdir -p "$feature_dir"

    # Copy and customize workflow
    local workflow_file="$feature_dir/workflow.yaml"
    sed "s/{FEATURE_ID}/$feature_id/g" "$template_file" > "$workflow_file"

    # Create initial state files based on workflow
    info "Creating state files..."

    # Extract roles from workflow and create state files
    grep "state_file:" "$workflow_file" | sed 's/.*state_file: "\(.*\)"/\1/' | sort -u | while read -r state_file; do
        local state_path="$feature_dir/$state_file"
        if [[ ! -f "$state_path" ]]; then
            cat > "$state_path" << EOF
# State: $(basename "$state_file" .md | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')

**Feature**: $feature_id
**Last Updated**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Status**: PENDING

## Current Task
None

## Completed Tasks
- (none)

## Blocked By
- (none)

## Notes
(Initial state)
EOF
            success "Created $state_file"
        fi
    done

    # Create definition.md template
    cat > "$feature_dir/definition.md" << 'EOF'
# Feature Definition

## Overview
(Describe what this feature does)

## Objectives
- Objetivo 1
- Objetivo 2

## Requirements
### Functional
- Req 1
- Req 2

### Non-Functional
- Performance: ...
- Security: ...

## Acceptance Criteria
- [ ] Criterio 1
- [ ] Criterio 2

## Technical Considerations
(Architecture, dependencies, constraints)

## Out of Scope
(What this feature explicitly does NOT include)
EOF

    success "Feature initialized: $feature_id"
    info "Next steps:"
    echo "  1. Edit $feature_dir/definition.md"
    echo "  2. Run: ./scripts/workflow sync"
    echo "  3. Start working on stages defined in workflow.yaml"
}

cmd_list() {
    info "Available features:"

    if [[ ! -d "$FEATURES_DIR" ]] || [[ -z "$(ls -A "$FEATURES_DIR" 2>/dev/null)" ]]; then
        warning "No features found"
        return
    fi

    for feature_dir in "$FEATURES_DIR"/*; do
        [[ -d "$feature_dir" ]] || continue

        local feature_id="$(basename "$feature_dir")"
        local workflow_file="$feature_dir/workflow.yaml"

        if [[ -f "$workflow_file" ]]; then
            local status="$(grep -A2 "^metadata:" "$workflow_file" | grep "status:" | sed 's/.*status: "\(.*\)"/\1/' || echo "unknown")"
            printf "  ${GREEN}%s${NC} [%s]\n" "$feature_id" "$status"
        else
            printf "  ${YELLOW}%s${NC} [no workflow]\n" "$feature_id"
        fi
    done
}

cmd_status() {
    local feature_id="${1:-}"

    if [[ -z "$feature_id" ]]; then
        # Show status of all features
        cmd_list
        return
    fi

    local feature_dir="$FEATURES_DIR/$feature_id"
    [[ -d "$feature_dir" ]] || die "Feature not found: $feature_id"

    info "Status of feature: $feature_id"
    echo ""

    # Show each state file
    for state_file in "$feature_dir"/*_state.md; do
        [[ -f "$state_file" ]] || continue

        local role="$(basename "$state_file" .md | sed 's/_state//' | tr '_' ' ')"
        local status="$(grep "^\*\*Status\*\*:" "$state_file" | sed 's/.*: //' || echo "UNKNOWN")"

        printf "  ${BLUE}%-20s${NC} %s\n" "$role:" "$status"
    done
}

cmd_sync() {
    info "Syncing with remote..."

    cd "$PROJECT_ROOT"

    # Stash local changes if any
    if ! git diff --quiet || ! git diff --cached --quiet; then
        warning "Local changes detected, stashing..."
        git stash push -m "Auto-stash before sync at $(date)"
    fi

    # Pull latest changes
    git pull origin "$(git branch --show-current)" || {
        warning "Pull failed, trying to pop stash..."
        git stash pop || true
        die "Sync failed"
    }

    # Pop stash if we stashed
    if git stash list | grep -q "Auto-stash before sync"; then
        info "Restoring local changes..."
        git stash pop || warning "Could not auto-restore stash, please check 'git stash list'"
    fi

    success "Synced successfully"
}

cmd_validate() {
    local feature_id="${1:-}"

    if [[ -z "$feature_id" ]]; then
        # Validate all features
        info "Validating all features..."
        local has_errors=0

        for feature_dir in "$FEATURES_DIR"/*; do
            [[ -d "$feature_dir" ]] || continue
            local fid="$(basename "$feature_dir")"

            if ! cmd_validate "$fid" 2>&1 | grep -q "✓"; then
                has_errors=1
            fi
        done

        [[ $has_errors -eq 0 ]] && success "All features valid"
        return $has_errors
    fi

    local feature_dir="$FEATURES_DIR/$feature_id"
    [[ -d "$feature_dir" ]] || die "Feature not found: $feature_id"

    info "Validating feature: $feature_id"

    local workflow_file="$feature_dir/workflow.yaml"

    # Check workflow exists
    [[ -f "$workflow_file" ]] || die "workflow.yaml not found"

    # Validate YAML syntax
    python3 -c "import yaml; yaml.safe_load(open('$workflow_file'))" 2>/dev/null || die "Invalid YAML syntax"

    # Check required files exist (from validation.required_files)
    local required_files="$(grep -A10 "^validation:" "$workflow_file" | grep "    - " | sed 's/.*- "\(.*\)"/\1/')"

    for req_file in $required_files; do
        local file_path="$feature_dir/$req_file"
        if [[ ! -f "$file_path" ]]; then
            error "Missing required file: $req_file"
            return 1
        fi
    done

    success "Feature valid: $feature_id"
}

cmd_consult() {
    info "Starting workflow consultant..."
    exec "$SCRIPT_DIR/workflow-consultant"
}

cmd_help() {
    cat << 'EOF'
Claude Code Workflow Manager

USAGE:
    workflow <command> [args]

COMMANDS:
    init <feature-id> [template]   Initialize a new feature
                                   Templates: feature_template, ddd_parallel

    list                           List all features

    status [feature-id]            Show status of feature(s)

    sync                           Sync with remote (git pull + stash handling)

    validate [feature-id]          Validate feature workflow(s)

    consult                        Interactive workflow consultant
                                   Asks questions about your task and generates
                                   optimal workflow

    help                           Show this help

EXAMPLES:
    # Initialize new feature with default template
    workflow init user-authentication

    # Initialize with DDD parallel template
    workflow init order-processing ddd_parallel

    # Check status of specific feature
    workflow status user-authentication

    # Sync with team before starting work
    workflow sync

    # Run workflow consultant
    workflow consult

WORKFLOW STRUCTURE:
    ai/
    ├── workflows/              # Workflow templates
    └── features/
        └── <feature-id>/
            ├── workflow.yaml   # Feature workflow definition
            ├── definition.md   # Feature definition
            ├── *_state.md      # State files per role
            └── ...

ROLES & INSTANCES:
    Each Claude Code instance = one fixed role
    Roles communicate via files in ai/features/<feature-id>/
    No shared memory between instances

    Typical roles: planner, backend, frontend, qa

See: ai/workflows/README.md for workflow format details
EOF
}

# Main
main() {
    ensure_ai_structure

    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        init)
            [[ $# -ge 1 ]] || die "Usage: workflow init <feature-id> [template]"
            cmd_init "$@"
            ;;
        list)
            cmd_list
            ;;
        status)
            cmd_status "$@"
            ;;
        sync)
            cmd_sync
            ;;
        validate)
            cmd_validate "$@"
            ;;
        consult)
            cmd_consult
            ;;
        help|--help|-h)
            cmd_help
            ;;
        *)
            error "Unknown command: $cmd"
            echo ""
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
__END_scripts_workflow__

create_file 'scripts/workflow-consultant' 'scripts_workflow-consultant'
__FILE_scripts_workflow-consultant__
#!/usr/bin/env python3

"""
Claude Code Workflow Consultant

Interactive tool that asks questions about your task and generates
the optimal workflow configuration.
"""

import os
import sys
import yaml
from datetime import datetime
from typing import Dict, List, Any

# Colors
class Colors:
    BLUE = '\033[0;34m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    CYAN = '\033[0;36m'
    BOLD = '\033[1m'
    NC = '\033[0m'

def info(msg): print(f"{Colors.BLUE}ℹ{Colors.NC} {msg}")
def success(msg): print(f"{Colors.GREEN}✓{Colors.NC} {msg}")
def warning(msg): print(f"{Colors.YELLOW}⚠{Colors.NC} {msg}")
def error(msg): print(f"{Colors.RED}✗{Colors.NC} {msg}", file=sys.stderr)
def header(msg): print(f"\n{Colors.BOLD}{Colors.CYAN}{msg}{Colors.NC}\n")

def ask(question: str, default: str = "") -> str:
    """Ask a question and return the answer."""
    if default:
        prompt = f"{Colors.CYAN}?{Colors.NC} {question} [{default}]: "
    else:
        prompt = f"{Colors.CYAN}?{Colors.NC} {question}: "

    answer = input(prompt).strip()
    return answer if answer else default

def ask_choice(question: str, choices: List[str], default: str = None) -> str:
    """Ask a multiple choice question."""
    print(f"{Colors.CYAN}?{Colors.NC} {question}")
    for i, choice in enumerate(choices, 1):
        marker = "*" if choice == default else " "
        print(f"  {marker} {i}. {choice}")

    while True:
        answer = input(f"{Colors.CYAN}>{Colors.NC} Select (1-{len(choices)}): ").strip()

        if not answer and default:
            return default

        try:
            idx = int(answer) - 1
            if 0 <= idx < len(choices):
                return choices[idx]
        except ValueError:
            pass

        error("Invalid choice, try again")

def ask_yes_no(question: str, default: bool = True) -> bool:
    """Ask a yes/no question."""
    default_str = "Y/n" if default else "y/N"
    answer = ask(f"{question} ({default_str})", "y" if default else "n")
    return answer.lower() in ['y', 'yes', '1', 'true'] if answer else default

def ask_multi_choice(question: str, choices: List[str]) -> List[str]:
    """Ask a question allowing multiple selections."""
    print(f"{Colors.CYAN}?{Colors.NC} {question} (comma-separated numbers)")
    for i, choice in enumerate(choices, 1):
        print(f"    {i}. {choice}")

    while True:
        answer = input(f"{Colors.CYAN}>{Colors.NC} Select: ").strip()

        if not answer:
            error("At least one choice required")
            continue

        try:
            indices = [int(x.strip()) - 1 for x in answer.split(',')]
            if all(0 <= idx < len(choices) for idx in indices):
                return [choices[idx] for idx in indices]
        except ValueError:
            pass

        error("Invalid choice, try again")

class WorkflowConsultant:
    def __init__(self):
        self.answers = {}
        self.workflow = {}

    def run(self):
        """Main consultation flow."""
        header("🤖 Claude Code Workflow Consultant")
        info("I'll ask you some questions about your task to generate the optimal workflow.\n")

        # Phase 1: Understanding the task
        self.phase_task_understanding()

        # Phase 2: Understanding the project structure
        self.phase_project_structure()

        # Phase 3: Understanding team/parallelism needs
        self.phase_team_setup()

        # Phase 4: Generate workflow
        self.phase_generate_workflow()

        # Phase 5: Save and summary
        self.phase_save_workflow()

    def phase_task_understanding(self):
        """Understand what the user wants to build."""
        header("📋 Phase 1: Understanding Your Task")

        self.answers['task_description'] = ask(
            "Describe your task/feature in one sentence",
            ""
        )

        self.answers['task_type'] = ask_choice(
            "What type of task is this?",
            [
                "New feature (frontend + backend)",
                "Backend-only feature",
                "Frontend-only feature",
                "Refactoring existing code",
                "Bug fix",
                "Infrastructure/DevOps",
                "Documentation",
                "Other"
            ],
            default="New feature (frontend + backend)"
        )

        self.answers['architecture'] = ask_choice(
            "What architecture/pattern will you use?",
            [
                "Simple (no specific pattern)",
                "Domain-Driven Design (DDD)",
                "Clean Architecture",
                "Layered Architecture",
                "Microservices",
                "Other"
            ],
            default="Simple (no specific pattern)"
        )

        self.answers['complexity'] = ask_choice(
            "How complex is this task?",
            [
                "Simple (1-2 files, < 1 day)",
                "Medium (3-10 files, 1-3 days)",
                "Complex (10+ files, multiple days)",
                "Very complex (major feature, 1+ week)"
            ],
            default="Medium (3-10 files, 1-3 days)"
        )

    def phase_project_structure(self):
        """Understand the project structure."""
        header("📁 Phase 2: Project Structure")

        self.answers['repo_type'] = ask_choice(
            "What's your repository structure?",
            [
                "Monorepo (frontend + backend in same repo)",
                "Separate repos (frontend and backend separate)",
                "Backend only",
                "Frontend only"
            ],
            default="Monorepo (frontend + backend in same repo)"
        )

        # Ask about directories
        if "Monorepo" in self.answers['repo_type'] or "Backend" in self.answers['repo_type']:
            self.answers['backend_dir'] = ask(
                "Backend source directory",
                "./src"
            )

        if "Monorepo" in self.answers['repo_type'] or "Frontend" in self.answers['repo_type']:
            self.answers['frontend_dir'] = ask(
                "Frontend source directory",
                "./frontend"
            )

        self.answers['has_tests'] = ask_yes_no("Do you have tests?", True)
        if self.answers['has_tests']:
            self.answers['test_dir'] = ask("Test directory", "./tests")

    def phase_team_setup(self):
        """Understand if working solo or in team."""
        header("👥 Phase 3: Team & Parallelism")

        self.answers['working_alone'] = ask_yes_no("Are you working alone?", True)

        if self.answers['working_alone']:
            info("Since you're working alone, I'll optimize for your workflow.")

            self.answers['want_parallel'] = ask_yes_no(
                "Do you want to work on multiple parts in parallel? (e.g., backend + frontend simultaneously)",
                False
            )

            if self.answers['want_parallel']:
                self.answers['parallel_parts'] = ask_multi_choice(
                    "Which parts do you want to work on in parallel?",
                    ["Backend", "Frontend", "Tests", "Documentation", "Infrastructure"]
                )
            else:
                info("You'll work sequentially: Planning → Implementation → Review")

        else:
            warning("Team mode: Each team member = one Claude instance with one role")

            num_members = int(ask("How many team members (including you)?", "2"))
            self.answers['team_size'] = num_members

            info(f"I'll create {num_members} roles, one per team member.")

    def phase_generate_workflow(self):
        """Generate the workflow based on answers."""
        header("⚙️  Phase 4: Generating Workflow")

        feature_id = self.generate_feature_id()
        self.answers['feature_id'] = feature_id

        info(f"Feature ID: {feature_id}")

        # Determine roles
        roles = self.determine_roles()
        info(f"Roles: {', '.join([r['name'] for r in roles])}")

        # Determine stages
        stages = self.determine_stages(roles)
        info(f"Stages: {len(stages)} stages")

        # Build workflow
        self.workflow = {
            'metadata': {
                'name': self.answers['task_description'][:50],
                'id': feature_id,
                'description': self.answers['task_description'],
                'created': datetime.now().strftime('%Y-%m-%d'),
                'status': 'active'
            },
            'roles': roles,
            'stages': stages,
            'validation': {
                'required_files': ['definition.md', 'planner_state.md'],
                'state_format': 'markdown',
                'allow_parallel_writes': self.answers.get('want_parallel', False)
            },
            'instructions': self.generate_instructions(stages)
        }

        success("Workflow generated successfully!")

    def generate_feature_id(self) -> str:
        """Generate feature ID from task description."""
        desc = self.answers['task_description'].lower()
        # Remove special chars, replace spaces with hyphens
        feature_id = ''.join(c if c.isalnum() or c in ' -' else '' for c in desc)
        feature_id = '-'.join(feature_id.split())[:50]

        # Allow user to override
        feature_id = ask("Feature ID", feature_id)
        return feature_id

    def determine_roles(self) -> List[Dict[str, str]]:
        """Determine which roles are needed."""
        roles = [
            {
                'id': 'planner',
                'name': 'Planner',
                'description': 'Defines feature, creates tasks, makes architectural decisions'
            }
        ]

        task_type = self.answers['task_type']

        if 'Backend' in task_type or 'New feature' in task_type:
            if 'DDD' in self.answers['architecture']:
                roles.extend([
                    {'id': 'domain_dev', 'name': 'Domain Developer', 'description': 'Implements domain layer'},
                    {'id': 'application_dev', 'name': 'Application Developer', 'description': 'Implements application layer'},
                    {'id': 'infrastructure_dev', 'name': 'Infrastructure Developer', 'description': 'Implements infrastructure layer'}
                ])
            else:
                roles.append({
                    'id': 'backend',
                    'name': 'Backend Developer',
                    'description': 'Implements backend logic'
                })

        if 'Frontend' in task_type or 'New feature' in task_type:
            roles.append({
                'id': 'frontend',
                'name': 'Frontend Developer',
                'description': 'Implements frontend UI/UX'
            })

        if self.answers.get('has_tests'):
            roles.append({
                'id': 'qa',
                'name': 'QA/Reviewer',
                'description': 'Reviews implementation, runs tests, validates quality'
            })

        return roles

    def determine_stages(self, roles: List[Dict]) -> List[Dict]:
        """Determine workflow stages."""
        stages = []
        feature_id = self.answers['feature_id']

        # Planning stage
        stages.append({
            'id': 'planning',
            'name': 'Planning & Definition',
            'owner': 'planner',
            'workspace': f'./ai/features/{feature_id}/',
            'permissions': {
                'read': ['./ai/**', './src/**'],
                'write': [
                    f'./ai/features/{feature_id}/definition.md',
                    f'./ai/features/{feature_id}/tasks.md',
                    f'./ai/features/{feature_id}/planner_state.md'
                ]
            },
            'dependencies': [],
            'parallel': False,
            'state_file': 'planner_state.md',
            'outputs': ['definition.md', 'tasks.md']
        })

        # Implementation stages
        want_parallel = self.answers.get('want_parallel', False)
        arch = self.answers['architecture']

        if 'DDD' in arch:
            # DDD: Domain, Application, Infrastructure in parallel
            domain_stage = {
                'id': 'domain',
                'name': 'Domain Layer Implementation',
                'owner': 'domain_dev',
                'workspace': f"{self.answers.get('backend_dir', './src')}/Domain/",
                'permissions': {
                    'read': [f'./ai/features/{feature_id}/**'],
                    'write': [
                        f"{self.answers.get('backend_dir', './src')}/Domain/**",
                        f'./ai/features/{feature_id}/domain_state.md'
                    ]
                },
                'dependencies': ['planning'],
                'parallel': False,
                'state_file': 'domain_state.md',
                'outputs': ['Domain entities, value objects, interfaces']
            }
            stages.append(domain_stage)

            app_stage = {
                'id': 'application',
                'name': 'Application Layer Implementation',
                'owner': 'application_dev',
                'workspace': f"{self.answers.get('backend_dir', './src')}/Application/",
                'permissions': {
                    'read': [f'./ai/features/{feature_id}/**', './src/Domain/**'],
                    'write': [
                        f"{self.answers.get('backend_dir', './src')}/Application/**",
                        f'./ai/features/{feature_id}/application_state.md'
                    ]
                },
                'dependencies': ['domain'],
                'parallel': want_parallel,
                'state_file': 'application_state.md',
                'outputs': ['Use cases, application services']
            }
            stages.append(app_stage)

            infra_stage = {
                'id': 'infrastructure',
                'name': 'Infrastructure Layer Implementation',
                'owner': 'infrastructure_dev',
                'workspace': f"{self.answers.get('backend_dir', './src')}/Infrastructure/",
                'permissions': {
                    'read': [f'./ai/features/{feature_id}/**', './src/Domain/**'],
                    'write': [
                        f"{self.answers.get('backend_dir', './src')}/Infrastructure/**",
                        f'./ai/features/{feature_id}/infrastructure_state.md'
                    ]
                },
                'dependencies': ['domain'],
                'parallel': want_parallel,
                'state_file': 'infrastructure_state.md',
                'outputs': ['Repositories, adapters, infrastructure']
            }
            stages.append(infra_stage)

        else:
            # Simple backend
            if any(r['id'] == 'backend' for r in roles):
                backend_stage = {
                    'id': 'backend',
                    'name': 'Backend Implementation',
                    'owner': 'backend',
                    'workspace': self.answers.get('backend_dir', './src'),
                    'permissions': {
                        'read': [f'./ai/features/{feature_id}/**', './src/**'],
                        'write': [
                            './src/**',
                            f'./ai/features/{feature_id}/backend_state.md'
                        ]
                    },
                    'dependencies': ['planning'],
                    'parallel': False,
                    'state_file': 'backend_state.md',
                    'outputs': ['Backend implementation']
                }
                stages.append(backend_stage)

            # Frontend
            if any(r['id'] == 'frontend' for r in roles):
                frontend_deps = ['planning']
                if any(s['id'] == 'backend' for s in stages):
                    frontend_deps.append('backend')

                frontend_stage = {
                    'id': 'frontend',
                    'name': 'Frontend Implementation',
                    'owner': 'frontend',
                    'workspace': self.answers.get('frontend_dir', './frontend'),
                    'permissions': {
                        'read': [f'./ai/features/{feature_id}/**', './frontend/**'],
                        'write': [
                            './frontend/**',
                            f'./ai/features/{feature_id}/frontend_state.md'
                        ]
                    },
                    'dependencies': frontend_deps if not want_parallel else ['planning'],
                    'parallel': want_parallel,
                    'state_file': 'frontend_state.md',
                    'outputs': ['Frontend implementation']
                }
                stages.append(frontend_stage)

        # QA/Review stage
        if any(r['id'] == 'qa' for r in roles):
            qa_deps = [s['id'] for s in stages if s['id'] != 'planning']

            qa_stage = {
                'id': 'review',
                'name': 'QA & Review',
                'owner': 'qa',
                'workspace': './',
                'permissions': {
                    'read': ['./ai/**', './src/**', './frontend/**', './tests/**'],
                    'write': [
                        f'./ai/features/{feature_id}/qa_state.md',
                        f'./ai/features/{feature_id}/review.md'
                    ]
                },
                'dependencies': qa_deps,
                'parallel': False,
                'state_file': 'qa_state.md',
                'outputs': ['review.md']
            }
            stages.append(qa_stage)

        return stages

    def generate_instructions(self, stages: List[Dict]) -> Dict[str, Dict]:
        """Generate role-specific instructions."""
        instructions = {}

        for stage in stages:
            stage_id = stage['id']
            owner = stage['owner']

            if stage_id == 'planning':
                instructions[stage_id] = {
                    'prompt': f"""You are the PLANNER for this feature.

Your responsibilities:
1. Read the feature request from the user
2. Create detailed `definition.md` with:
   - Feature overview and objectives
   - Functional and non-functional requirements
   - Acceptance criteria (checklist)
   - Technical considerations and constraints
3. Create `tasks.md` breaking down implementation into specific tasks
4. Update `planner_state.md` with status: COMPLETED

DO NOT implement code. Your job is to plan and define clearly.

Output files:
- definition.md (feature specification)
- tasks.md (task breakdown)
- planner_state.md (your status)
"""
                }
            elif 'domain' in stage_id:
                instructions[stage_id] = {
                    'prompt': """You are the DOMAIN DEVELOPER (DDD).

Your responsibilities:
1. Read `definition.md` and architectural guidelines
2. Implement in ./src/Domain/:
   - Entities (rich domain models)
   - Value Objects (immutable)
   - Domain Services
   - Repository Interfaces (no implementations!)
   - Domain Events
3. Keep domain layer framework-agnostic
4. Update `domain_state.md` with progress

NO infrastructure code. Pure business logic only.
"""
                }
            elif 'application' in stage_id:
                instructions[stage_id] = {
                    'prompt': """You are the APPLICATION DEVELOPER (DDD).

Your responsibilities:
1. Read Domain layer contracts
2. Implement in ./src/Application/:
   - Use Cases (orchestrate domain logic)
   - DTOs (input/output)
   - Application Services
3. Use repository interfaces via dependency injection
4. Update `application_state.md` with progress

If Domain layer is incomplete, mark yourself as BLOCKED.
"""
                }
            elif 'infrastructure' in stage_id:
                instructions[stage_id] = {
                    'prompt': """You are the INFRASTRUCTURE DEVELOPER (DDD).

Your responsibilities:
1. Read Domain layer repository interfaces
2. Implement in ./src/Infrastructure/:
   - Repository implementations (ORM, database)
   - External service adapters
   - Framework integrations
3. Update `infrastructure_state.md` with progress

If Domain layer is incomplete, mark yourself as BLOCKED.
"""
                }
            elif stage_id == 'backend':
                instructions[stage_id] = {
                    'prompt': """You are the BACKEND DEVELOPER.

Your responsibilities:
1. Read `definition.md` and `tasks.md`
2. Implement backend logic in ./src/
3. Follow architecture guidelines from planner
4. Update `backend_state.md` with:
   - Completed tasks
   - Files created/modified
   - Any blockers or questions

If requirements are unclear, mark BLOCKED and specify what you need.
"""
                }
            elif stage_id == 'frontend':
                instructions[stage_id] = {
                    'prompt': """You are the FRONTEND DEVELOPER.

Your responsibilities:
1. Read `definition.md` for UI/UX requirements
2. Implement frontend in ./frontend/
3. If backend isn't ready, mock API calls
4. Update `frontend_state.md` with:
   - Completed tasks
   - Components created
   - Any blockers

Create mockups if backend API is not available yet.
"""
                }
            elif stage_id == 'review':
                instructions[stage_id] = {
                    'prompt': """You are the QA/REVIEWER.

Your responsibilities:
1. Read `definition.md` to understand expectations
2. Review all implementation (backend, frontend, tests)
3. Verify acceptance criteria are met
4. Create `review.md` with:
   - ✅ What works correctly
   - ❌ Issues found
   - 💡 Suggestions for improvement
5. Update `qa_state.md`: APPROVED or REJECTED

DO NOT fix code yourself. Report issues to respective developers.
"""
                }

        return instructions

    def phase_save_workflow(self):
        """Save the workflow and show summary."""
        header("💾 Phase 5: Saving Workflow")

        feature_id = self.answers['feature_id']

        # Determine project root (go up from scripts/ dir)
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(script_dir)
        features_dir = os.path.join(project_root, 'ai', 'features')

        feature_dir = os.path.join(features_dir, feature_id)

        if os.path.exists(feature_dir):
            if not ask_yes_no(f"Feature '{feature_id}' already exists. Overwrite?", False):
                warning("Cancelled.")
                return
        else:
            os.makedirs(feature_dir, exist_ok=True)

        # Save workflow.yaml
        workflow_file = os.path.join(feature_dir, 'workflow.yaml')
        with open(workflow_file, 'w') as f:
            yaml.dump(self.workflow, f, default_flow_style=False, sort_keys=False)

        success(f"Workflow saved: {workflow_file}")

        # Create initial state files
        for stage in self.workflow['stages']:
            state_file = stage['state_file']
            state_path = os.path.join(feature_dir, state_file)

            if not os.path.exists(state_path):
                role_name = stage['name']
                with open(state_path, 'w') as f:
                    f.write(f"""# State: {role_name}

**Feature**: {feature_id}
**Last Updated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}
**Status**: PENDING

## Current Task
None

## Completed Tasks
- (none)

## Blocked By
- (none)

## Notes
(Initial state)
""")
                info(f"Created {state_file}")

        # Create definition.md template
        definition_file = os.path.join(feature_dir, 'definition.md')
        if not os.path.exists(definition_file):
            with open(definition_file, 'w') as f:
                f.write(f"""# {self.answers['task_description']}

## Overview
{self.answers['task_description']}

## Task Type
{self.answers['task_type']}

## Architecture
{self.answers['architecture']}

## Complexity
{self.answers['complexity']}

## Objectives
- (Define your objectives here)

## Requirements
### Functional
- (List functional requirements)

### Non-Functional
- Performance:
- Security:
- Maintainability:

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Considerations
(Architecture decisions, dependencies, constraints)

## Out of Scope
(What this feature explicitly does NOT include)
""")
            info(f"Created definition.md")

        # Show summary
        header("✨ Workflow Ready!")

        print(f"\n{Colors.BOLD}Feature:{Colors.NC} {feature_id}")
        print(f"{Colors.BOLD}Location:{Colors.NC} {feature_dir}")
        print(f"\n{Colors.BOLD}Roles:{Colors.NC}")
        for role in self.workflow['roles']:
            print(f"  • {role['name']} ({role['id']})")

        print(f"\n{Colors.BOLD}Stages:{Colors.NC}")
        for i, stage in enumerate(self.workflow['stages'], 1):
            parallel_mark = " [PARALLEL]" if stage.get('parallel') else ""
            print(f"  {i}. {stage['name']} (owner: {stage['owner']}){parallel_mark}")

        print(f"\n{Colors.BOLD}Next Steps:{Colors.NC}")
        print(f"  1. Review and edit: {definition_file}")
        print(f"  2. Start with Planning role:")
        print(f"     {Colors.CYAN}cd {project_root}{Colors.NC}")
        print(f"     {Colors.CYAN}claude{Colors.NC} (or your Claude Code command)")
        print(f"  3. In Claude, tell it:")
        print(f"     \"I am the PLANNER. Read ./ai/features/{feature_id}/workflow.yaml")
        print(f"      and follow the planning stage instructions.\"")
        print(f"\n  4. For parallel work, open multiple terminal tabs (Tilix):")
        print(f"     Each tab = one Claude instance = one role")
        print(f"\n  5. Check status anytime:")
        print(f"     {Colors.CYAN}./scripts/workflow status {feature_id}{Colors.NC}")

        print(f"\n{Colors.GREEN}Happy coding! 🚀{Colors.NC}\n")


def main():
    try:
        consultant = WorkflowConsultant()
        consultant.run()
    except KeyboardInterrupt:
        print("\n")
        warning("Consultation cancelled.")
        sys.exit(0)
    except Exception as e:
        error(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
__END_scripts_workflow-consultant__

create_file 'scripts/setup-project' 'scripts_setup-project'
__FILE_scripts_setup-project__
#!/usr/bin/env bash

# Setup project structure for new workflow project
# Creates common directories needed for most projects

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }

cd "$PROJECT_ROOT"

info "Setting up project structure..."

# Create common directories
mkdir -p src
mkdir -p frontend
mkdir -p tests
mkdir -p docs

# Create placeholder README in each
cat > src/README.md << 'EOF'
# Source Code

Backend/server source code goes here.

## Structure

Organize as needed:
- `src/Domain/` - Domain layer (DDD)
- `src/Application/` - Application layer (DDD)
- `src/Infrastructure/` - Infrastructure layer (DDD)

Or simpler:
- `src/models/` - Data models
- `src/controllers/` - Controllers
- `src/services/` - Business logic
- `src/routes/` - API routes
EOF

cat > frontend/README.md << 'EOF'
# Frontend

Frontend/UI source code goes here.

## Structure

Example for React:
- `frontend/src/components/` - React components
- `frontend/src/pages/` - Page components
- `frontend/src/hooks/` - Custom hooks
- `frontend/src/services/` - API clients
- `frontend/public/` - Static assets
EOF

cat > tests/README.md << 'EOF'
# Tests

Test files go here.

## Structure

- `tests/unit/` - Unit tests
- `tests/integration/` - Integration tests
- `tests/e2e/` - End-to-end tests
EOF

cat > docs/README.md << 'EOF'
# Documentation

Additional project documentation goes here.

## Contents

- Architecture diagrams
- API documentation
- Deployment guides
- User manuals
EOF

success "Created src/"
success "Created frontend/"
success "Created tests/"
success "Created docs/"

# Install Python dependencies for workflow tools
if command -v pip3 &> /dev/null; then
    info "Installing Python dependencies..."
    pip3 install pyyaml --quiet || {
        info "Could not install pyyaml globally, trying --user"
        pip3 install --user pyyaml --quiet || {
            info "Could not install pyyaml, workflow-consultant may not work"
        }
    }
    success "Python dependencies installed"
else
    info "pip3 not found, skipping Python dependencies"
    info "Install pyyaml manually: pip3 install pyyaml"
fi

# Make scripts executable
chmod +x "$SCRIPT_DIR"/workflow*

success "Scripts are executable"

# Initialize git if not already
if [[ ! -d .git ]]; then
    info "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: Claude Code Workflow System"
    success "Git repository initialized"
fi

echo ""
success "Project setup complete!"
echo ""
info "Next steps:"
echo "  1. ./scripts/workflow consult    # Generate your first workflow"
echo "  2. ./scripts/workflow list       # See available features"
echo "  3. Read QUICKSTART.md for a guided tutorial"
echo ""
info "Try the example:"
echo "  ./scripts/workflow status example-todo-api"
echo "  See: ai/features/example-todo-api/EXAMPLE_USAGE.md"
__END_scripts_setup-project__

create_file 'hooks/README.md' 'hooks_README_md'
__FILE_hooks_README_md__
# Git Hooks for Workflow System

Git hooks to automate validation and ensure workflow integrity.

## Available Hooks

### pre-commit

Validates workflows before allowing commits.

**Install:**
```bash
cp hooks/pre-commit.example .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**What it does:**
- ✅ Validates all workflow YAML files
- ✅ Checks state file formats
- ⚠️ Warns about sensitive files (.env)
- ❌ Blocks commit if validation fails

**Skip (not recommended):**
```bash
git commit --no-verify
```

## Future Hooks

### post-commit
Automatically push to remote after local commit (optional).

### pre-push
Run extended validation before pushing to remote.

### prepare-commit-msg
Auto-generate commit messages based on changed files in ai/features/.

## Custom Hooks

Create your own hooks for project-specific needs:

```bash
# Example: Notify team when feature status changes
# .git/hooks/post-commit

#!/bin/bash
if git diff --name-only HEAD~1 HEAD | grep -q "_state.md"; then
    # Send notification to Slack/Discord/etc
    echo "Feature state changed, notifying team..."
fi
```

## Installation Script

To install all hooks:

```bash
#!/bin/bash
for hook in hooks/*.example; do
    hook_name=$(basename "$hook" .example)
    cp "$hook" ".git/hooks/$hook_name"
    chmod +x ".git/hooks/$hook_name"
    echo "Installed: $hook_name"
done
```

Save as `install-hooks.sh` and run: `./install-hooks.sh`
__END_hooks_README_md__

create_file 'hooks/pre-commit.example' 'hooks_pre-commit_example'
__FILE_hooks_pre-commit_example__
#!/usr/bin/env bash

# Example pre-commit hook for Claude Code Workflow System
# Install: cp hooks/pre-commit.example .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

set -e

echo "🔍 Running workflow validation..."

# Validate all workflows
if ! ./scripts/workflow validate 2>&1 | grep -q "✓"; then
    echo "❌ Workflow validation failed!"
    echo ""
    echo "Fix the issues above before committing."
    echo "To skip validation (not recommended): git commit --no-verify"
    exit 1
fi

echo "✅ Workflow validation passed"

# Check that state files have proper format
echo "🔍 Checking state file formats..."

for state_file in ai/features/*/*_state.md; do
    [[ -f "$state_file" ]] || continue

    # Check required fields
    if ! grep -q "^\*\*Feature\*\*:" "$state_file" || \
       ! grep -q "^\*\*Status\*\*:" "$state_file"; then
        echo "❌ Invalid state file format: $state_file"
        echo "Required fields: **Feature**, **Status**"
        exit 1
    fi
done

echo "✅ State files valid"

# Optional: Check for common issues
echo "🔍 Checking for common issues..."

# Warn if committing .env files
if git diff --cached --name-only | grep -q "\.env$"; then
    echo "⚠️  WARNING: You are committing a .env file!"
    echo "This may contain secrets. Press Enter to continue or Ctrl+C to abort."
    read
fi

# Check for TODO/FIXME in committed code (optional - comment out if annoying)
# if git diff --cached | grep -q "TODO\|FIXME"; then
#     echo "⚠️  WARNING: Committing code with TODO/FIXME comments"
# fi

echo "✅ All checks passed!"
echo ""
__END_hooks_pre-commit_example__


success "Files extracted"

# Create project directories
info "Creating project structure..."
mkdir -p "$TARGET_DIR"/{src,frontend,tests,docs}

[[ ! -f "$TARGET_DIR/src/README.md" ]] && cat > "$TARGET_DIR/src/README.md" << 'EOF'
# Source Code
Backend/server source code goes here.
EOF

[[ ! -f "$TARGET_DIR/frontend/README.md" ]] && cat > "$TARGET_DIR/frontend/README.md" << 'EOF'
# Frontend
Frontend/UI source code goes here.
EOF

[[ ! -f "$TARGET_DIR/tests/README.md" ]] && cat > "$TARGET_DIR/tests/README.md" << 'EOF'
# Tests
Test files go here.
EOF

success "Project structure created"

# Install Python dependencies
if command -v pip3 &> /dev/null; then
    info "Installing PyYAML..."
    pip3 install pyyaml --quiet 2>/dev/null || pip3 install --user pyyaml --quiet 2>/dev/null || {
        warning "Could not install PyYAML. Install manually: pip3 install pyyaml"
    }
fi

# Initialize git if needed
if [[ ! -d "$TARGET_DIR/.git" ]]; then
    info "Initializing git..."
    cd "$TARGET_DIR"
    git init
    git add .
    git commit -m "feat: Add Claude Code Parallel Workflow System" 2>/dev/null || true
fi

header "✅ Installation Complete!"

echo ""
echo "📁 Installed in: ${CYAN}$TARGET_DIR${NC}"
echo ""
echo "🎯 Quick Start:"
echo ""
echo "  ${CYAN}./scripts/workflow consult${NC}     # Interactive workflow generator"
echo "  ${CYAN}./scripts/workflow status example-todo-api${NC}  # See example"
echo "  ${CYAN}cat QUICKSTART.md${NC}              # 5-minute tutorial"
echo ""
success "Ready to use! 🚀"
echo ""

exit 0
