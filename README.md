# Claude Code - Sistema Modular y Escalable de Workflow Paralelo

Sistema completo para uso modular y escalable de Claude Code con **roles detallados**, **reglas específicas**, **workflows configurables** y **ejecución en paralelo**.

## 🎯 ¿Qué es esto?

Un sistema profesional para trabajar con **múltiples instancias de Claude Code en paralelo**, cada una con un rol específico (Planner, Backend, Frontend, QA), compartiendo contexto a través de archivos explícitos y workflows YAML configurables.

## ✨ Características

- ✅ **Roles detallados en Markdown** con responsabilidades, permisos, prohibiciones
- ✅ **Reglas por proyecto** (globales, DDD, específicas del proyecto)
- ✅ **Workflows YAML configurables** (default, DDD parallel, custom)
- ✅ **Estado centralizado** (`50_state.md`) sincronizado entre roles
- ✅ **Script Tilix** para abrir múltiples panes automáticamente
- ✅ **Validador automático** de workflows y features
- ✅ **Consultor inteligente** que sugiere workflow según la tarea
- ✅ **Soporte multi-carpeta** (backend, frontend1, frontend2)

## 📁 Estructura

```
./
├── .ai/                        # Configuración centralizada de Claude Code
│   ├── roles/                 # Roles detallados en Markdown
│   │   ├── backend.md         # Rol Backend Engineer (con pairing patterns)
│   │   ├── frontend.md        # Rol Frontend Engineer (con pairing patterns)
│   │   ├── planner.md         # Rol Planner/Architect (con pairing patterns)
│   │   └── qa.md              # Rol QA/Reviewer (con pairing patterns)
│   ├── projects/
│   │   └── PROJECT_X/
│   │       ├── rules/         # Reglas del proyecto
│   │       │   ├── global_rules.md
│   │       │   ├── ddd_rules.md
│   │       │   └── project_specific.md
│   │       ├── features/      # Features activos
│   │       │   └── FEATURE_X/
│   │       │       └── 50_state.md  # Estado centralizado
│   │       └── workflows/     # Workflows YAML
│   │           └── default.yaml
│   ├── scripts/               # Scripts de automatización
│   │   ├── tilix_start.sh     # Abre Tilix con roles configurados
│   │   ├── validate_workflow.py   # Validador automático
│   │   ├── suggest_workflow.py    # Consultor inteligente
│   │   ├── git_sync.sh        # Sincronización Git
│   │   ├── git_commit_push.sh # Commit y push inteligente
│   │   └── install_git_hooks.sh   # Instalador de hooks
│   ├── hooks/                 # Git hooks
│   │   └── pre-commit         # Hook de validación pre-commit
│   ├── GIT_WORKFLOW.md        # Guía completa de Git workflow
│   └── PAIRING_PATTERNS.md    # Guía de pairing con AI agents
│
├── backend/                    # Backend (Symfony + DDD)
│   ├── src/                   # Código backend
│   └── tests/                 # Tests backend
│
├── frontend1/                  # Frontend Admin
│   ├── src/                   # Código frontend
│   └── tests/                 # Tests frontend
│
├── frontend2/                  # Frontend Public
│   ├── src/                   # Código frontend
│   └── tests/                 # Tests frontend
│
├── README.md                   # Este archivo
└── install.sh                  # Instalador del sistema
```

## 🚀 Inicio Rápido

### 1. Consultor Inteligente (⭐ RECOMENDADO)

El consultor te hace preguntas y sugiere el workflow óptimo:

```bash
./.ai/scripts/suggest_workflow.py
```

Te pregunta:
- ¿Qué tipo de tarea? (feature, bug fix, refactoring)
- ¿Qué complejidad? (simple, medium, complex)
- ¿Qué arquitectura? (simple, DDD, clean architecture)
- ¿Trabajo en paralelo? (backend || frontend)
- ¿Solo o en equipo?

Y sugiere el workflow apropiado.

### 2. Iniciar Workflow con Tilix

#### Modo Manual (muestra instrucciones):
```bash
# Abrir Tilix con 4 panes y ver instrucciones
./.ai/scripts/tilix_start.sh [feature-id] [workflow]

# Ejemplo:
./.ai/scripts/tilix_start.sh user-authentication default
```

#### Modo Automático (ejecuta Claude Code automáticamente):
```bash
# Ejecuta Claude Code automáticamente en cada pane con su rol
./.ai/scripts/tilix_start.sh [feature-id] [workflow] --execute

# Ejemplo:
./.ai/scripts/tilix_start.sh user-authentication default --execute
# O forma corta:
./.ai/scripts/tilix_start.sh user-authentication default -x
```

**Diferencias:**
- **Sin `--execute`**: Crea los 4 panes y muestra instrucciones para copiar/pegar manualmente
- **Con `--execute`**: Ejecuta automáticamente `claude` en cada pane con el prompt del rol correspondiente

Esto abre Tilix con layout 2x2:

```
┌────────────────┬────────────────┐
│   PLANNER      │   BACKEND      │
├────────────────┼────────────────┤
│   FRONTEND     │   QA           │
└────────────────┴────────────────┘
```

Cada pane:
- ✅ Tiene su rol específico claramente identificado
- ✅ Ejecuta Claude Code con el prompt del rol (modo --execute)
- ✅ Incluye referencias a Pairing Patterns
- ✅ Instrucciones para git_sync.sh y git_commit_push.sh
- ✅ Checkpoints de verificación según el rol

### 3. Validar Workflow

```bash
# Validar un feature específico
./.ai/scripts/validate_workflow.py user-authentication

# Validar todos los features
./.ai/scripts/validate_workflow.py
```

## 📚 Documentación de Roles

Cada rol tiene un archivo Markdown detallado con:

### `backend.md` - Backend Engineer

- **Responsabilidades**: Implementar API según DDD
- **Lecturas permitidas**: Reglas, workflows, código backend
- **Escrituras permitidas**: `./backend/src/**`, tests, `50_state.md`
- **Prohibiciones**: NO modificar frontend, NO cambiar reglas
- **Stack**: Symfony 6+, PHP 8.1+, DDD, Doctrine

### `frontend.md` - Frontend Engineer

- **Responsabilidades**: Implementar UI, mockear API si necesario
- **Lecturas permitidas**: Reglas, workflows, código frontend, estado backend
- **Escrituras permitidas**: `./frontend*/src/**`, tests, `50_state.md`
- **Prohibiciones**: NO modificar backend, NO cambiar reglas
- **Stack**: React 18+, TypeScript 5+, Material-UI/Tailwind

### `planner.md` - Planner / Architect

- **Responsabilidades**: Definir features, crear contratos, resolver bloqueos
- **Lecturas permitidas**: TODO (all roles, rules, code)
- **Escrituras permitidas**: Contratos, decisiones, reglas (con justificación)
- **Prohibiciones**: NO implementar código
- **Funciones**: Arquitectura, decisiones, coordinación

### `qa.md` - QA / Reviewer

- **Responsabilidades**: Revisar implementación, validar calidad
- **Lecturas permitidas**: TODO (all roles, rules, code)
- **Escrituras permitidas**: Reports, `50_state.md` (QA section)
- **Prohibiciones**: NO implementar features (solo validar)
- **Decisión**: APPROVED o REJECTED

## 📋 Reglas del Proyecto

### `global_rules.md` - Reglas Globales

- Contexto explícito (sin memoria implícita)
- Roles inmutables
- Workflow es ley
- Estado sincronizado via `50_state.md`
- Git como mecanismo de sincronización
- Testing requirements
- Security requirements
- Code style

### `ddd_rules.md` - Reglas DDD

- Arquitectura de 3 capas (Domain, Application, Infrastructure)
- Entities, Value Objects, Aggregates
- Repository interfaces en Domain, implementaciones en Infrastructure
- Use Cases en Application
- Controllers delgados
- Tests por capa

### `project_specific.md` - Reglas Específicas

- Stack técnico concreto
- API conventions
- Authentication & Authorization
- Rate limiting
- Frontend UI/UX guidelines
- Deployment process
- Performance targets

## 🎨 Workflows Disponibles

### `default.yaml` - Workflow Estándar

```
Planning → Backend → Frontend → Integration → QA
```

- Backend y Frontend pueden trabajar en **paralelo**
- Frontend mockea API si backend no está listo
- Ideal para features estándar full-stack

### `ddd_parallel.yaml` - DDD con Capas Paralelas

```
Planning → (Domain, Application, Infrastructure in parallel) → Integration → QA
```

- Roles especializados por capa DDD
- Máximo paralelismo
- Ideal para arquitectura DDD compleja

### Custom Workflows

Crea tu propio workflow copiando un template:

```bash
cp .ai/projects/PROJECT_X/workflows/default.yaml \\
   .ai/projects/PROJECT_X/workflows/my_workflow.yaml
```

Edita según tus necesidades.

## 🔄 Flujo de Trabajo Típico

### Escenario: Feature de Autenticación de Usuarios

#### 1. Consultor sugiere workflow

```bash
./.ai/scripts/suggest_workflow.py

# Responde preguntas:
# - Tipo: New feature (full-stack)
# - Complejidad: Medium
# - Arquitectura: DDD
# - Paralelo: Yes
# - Team: Alone

# Sugiere: ddd_parallel.yaml
```

#### 2. Inicializar feature

```bash
mkdir -p .ai/projects/PROJECT_X/features/user-auth
cp .ai/projects/PROJECT_X/features/FEATURE_X/50_state.md \\
   .ai/projects/PROJECT_X/features/user-auth/50_state.md
```

#### 3. Abrir Tilix con roles

```bash
./.ai/scripts/tilix_start.sh user-auth ddd_parallel
```

#### 4. En cada pane de Tilix

**Pane 1 - Planner:**
```bash
claude  # o tu comando de Claude Code

# Paste el prompt de Planner (mostrado por tilix_start.sh)
```

Claude lee:
- `.ai/roles/planner.md`
- Todas las reglas del proyecto
- Workflow YAML

Claude crea:
- `user-auth.md` (definición del feature)
- `30_tasks.md` (breakdown de tareas)
- Actualiza `50_state.md` (planner) → `COMPLETED`

**Pane 2 - Backend:**
```bash
git pull  # Sincronizar con Planner
claude

# Paste el prompt de Backend
```

Claude implementa backend según DDD.

**Pane 3 - Frontend:**
```bash
git pull
claude

# Paste el prompt de Frontend
```

Claude implementa UI, mockea API si backend no está listo.

**Pane 4 - QA:**
```bash
git pull
claude

# Paste el prompt de QA
```

Claude revisa todo y aprueba/rechaza.

#### 5. Monitorear progreso

```bash
# En terminal separado
watch -n 5 'cat .ai/projects/PROJECT_X/features/user-auth/50_state.md'
```

#### 6. Validar feature

```bash
./.ai/scripts/validate_workflow.py user-auth
```

## 🎯 Casos de Uso

### Solo tú, trabajo secuencial

```
Planning → Backend → Frontend → QA
(cambias de rol manualmente)
```

### Solo tú, trabajo paralelo

```
Planning → (Backend || Frontend) → QA
(Tilix con 4 panes, cambias entre tabs)
```

### Equipo (3 personas)

```
Persona 1: Planner + QA
Persona 2: Backend
Persona 3: Frontend

(Cada persona = 1 Claude instance = 1 rol)
```

### DDD complejo en paralelo

```
Planning → (Domain || Application || Infrastructure) → Integration → QA
```

## 🔧 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `suggest_workflow.py` | Consultor inteligente que sugiere workflow |
| `tilix_start.sh` | Abre Tilix con roles pre-configurados |
| `validate_workflow.py` | Valida workflows y features |
| `view_state.sh` | (TODO) Muestra estado consolidado de feature |

## 📦 Instalación en Nuevo Proyecto

```bash
# Opción 1: Copiar todo el sistema
cp -r /path/to/workflow/* /path/to/mi-proyecto/

# Opción 2: Usar como template
# (si está en GitHub, usar "Use this template")

# Opción 3: Git submodule
cd /path/to/mi-proyecto
git submodule add <repo-url> workflow-system
```

## 🎓 Ejemplos

Ver carpeta `.ai/projects/PROJECT_X/features/FEATURE_X/` para un ejemplo completo de:
- `50_state.md` - Estado inicial de un feature
- Workflow YAML aplicado
- Roles interactuando

## 📚 Documentación Adicional

Este sistema incluye guías completas:

- **`.ai/GIT_WORKFLOW.md`** (12KB) - Git workflow completo para sincronización multi-instancia
  - Branching strategy por feature
  - Commit y push frecuente por rol
  - Manejo de conflictos en 50_state.md
  - Scripts de sincronización (git_sync.sh, git_commit_push.sh)
  - Pre-commit hooks de validación

- **`.ai/PAIRING_PATTERNS.md`** (18KB) - Guía de pairing efectivo con AI agents
  - Principio: "Sitting Next to Me" test
  - Evitar el "Speed Trap" (generar más rápido de lo que se puede verificar)
  - Feedback loops con checkpoints
  - Pattern matching (referenciar código existente)
  - "Trust = Passing Test Suite"
  - Ejemplos Before/After de prompts efectivos

## 💡 Principios Fundamentales

1. **Contexto Explícito** - Todo en archivos, nada en memoria
2. **Roles Inmutables** - Una instancia = un rol fijo
3. **Estado Sincronizado** - `50_state.md` como fuente de verdad
4. **Workflows Declarativos** - YAML define el proceso
5. **Git como Sincronización** - Pull antes, push después

## 🚫 Anti-patterns (Evitar)

❌ "Recuerda que antes dijimos..."
✅ "Lee el archivo `50_state.md`"

❌ Cambiar de rol a mitad de camino
✅ Mantener rol fijo durante toda la sesión

❌ Implementar sin leer reglas
✅ Leer TODAS las reglas antes de empezar

❌ Saltarse el workflow
✅ Seguir el workflow YAML estrictamente

## 📝 Licencia

MIT License

---

**¿Listo para empezar?**

```bash
./.ai/scripts/suggest_workflow.py
```

🚀 **Disfruta trabajando con múltiples Claude Code en paralelo!**
