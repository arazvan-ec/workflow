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
