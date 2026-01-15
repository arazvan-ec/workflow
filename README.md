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

Instala el workflow system en tu proyecto existente:

#### Método 1: Instalador Auto-Contenido (⭐ Recomendado)

```bash
# Genera el instalador (desde este repo)
cd /path/to/workflow
./scripts/generate-installer

# Copia e instala en tu proyecto
cp install-workflow.sh /path/to/tu-proyecto/
cd /path/to/tu-proyecto
bash install-workflow.sh
```

#### Método 2: Desde Repositorio Local

```bash
cd /path/to/tu-proyecto
bash /path/to/workflow/install.sh
```

El instalador:
- ✅ Copia toda la estructura `/ai/`, scripts y documentación
- ✅ Crea directorios del proyecto (`src/`, `frontend/`, `tests/`)
- ✅ Instala dependencias (PyYAML)
- ✅ Inicializa Git si es necesario

**Requisitos**: Bash, Git, Python 3.6+, pip3

Ver [INSTALLATION.md](INSTALLATION.md) para más opciones de instalación.

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
