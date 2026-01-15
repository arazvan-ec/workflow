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
