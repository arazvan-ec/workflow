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
