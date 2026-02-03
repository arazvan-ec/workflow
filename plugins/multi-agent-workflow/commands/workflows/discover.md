---
name: workflows:discover
description: "Deep project analysis to build comprehensive knowledge. Scans codebase, detects patterns, and creates project profile."
argument_hint: [--full | --refresh | --report]
---

# /workflows:discover - Descubrimiento Profundo del Proyecto

**Version**: 1.0.0
**Category**: Setup & Analysis
**Priority**: Run once after installation, then periodically

---

## Purpose

Analiza el proyecto en profundidad para construir un conocimiento completo que permita al plugin trabajar de manera más efectiva. Genera un perfil del proyecto con toda la información relevante.

## When to Use

| Situación | Recomendación |
|-----------|---------------|
| Primera instalación del plugin | `/workflows:discover --full` |
| Después de cambios mayores (nueva librería, refactor) | `/workflows:discover --refresh` |
| Ver resumen del conocimiento actual | `/workflows:discover --report` |
| Antes de planificar feature compleja | Automático en `/workflows:plan` |

## Invocation

```bash
# Análisis completo (primera vez)
/workflows:discover --full

# Refrescar conocimiento existente
/workflows:discover --refresh

# Solo mostrar reporte del conocimiento actual
/workflows:discover --report

# Por defecto: análisis inteligente (detecta qué necesita actualizar)
/workflows:discover
```

## Execution Protocol

### Step 1: Create Project Intelligence Directory

```bash
mkdir -p .ai/project/intelligence
```

### Step 2: Detect Project Type and Stack

Scan for configuration files and detect:

```markdown
## Detección de Stack

Escaneando archivos de configuración...

### Backend Detection
| Archivo | Framework/Lenguaje |
|---------|-------------------|
| `package.json` → Node.js, dependencias |
| `composer.json` → PHP, Symfony/Laravel |
| `requirements.txt` / `pyproject.toml` → Python |
| `go.mod` → Go |
| `Cargo.toml` → Rust |
| `pom.xml` / `build.gradle` → Java |
| `.csproj` → .NET |

### Frontend Detection
| Archivo | Framework |
|---------|-----------|
| `package.json` → React/Vue/Angular/Svelte |
| `tsconfig.json` → TypeScript |
| `vite.config.*` → Vite |
| `next.config.*` → Next.js |
| `nuxt.config.*` → Nuxt |

### Infrastructure Detection
| Archivo | Tecnología |
|---------|------------|
| `docker-compose.yml` → Docker |
| `Dockerfile` → Containerization |
| `.github/workflows/` → GitHub Actions |
| `terraform/` → Infrastructure as Code |
| `k8s/` / `kubernetes/` → Kubernetes |
```

### Step 3: Analyze Project Structure

```markdown
## Análisis de Estructura

### Directory Map
```
[Generar árbol de directorios hasta 3 niveles]
```

### Architecture Pattern Detection

| Patrón | Indicadores | Detectado |
|--------|-------------|-----------|
| **DDD (Domain-Driven Design)** | `domain/`, `application/`, `infrastructure/` | ✓/✗ |
| **Clean Architecture** | `entities/`, `usecases/`, `adapters/` | ✓/✗ |
| **MVC** | `models/`, `views/`, `controllers/` | ✓/✗ |
| **Hexagonal** | `ports/`, `adapters/` | ✓/✗ |
| **Atomic Design** | `atoms/`, `molecules/`, `organisms/` | ✓/✗ |
| **Feature-based** | Feature folders with all concerns | ✓/✗ |

### Layer Analysis (if DDD/Clean detected)
- Domain Layer: [path and health]
- Application Layer: [path and health]
- Infrastructure Layer: [path and health]
- Presentation Layer: [path and health]
```

### Step 4: Scan Code Patterns

```markdown
## Patrones de Código Detectados

### Naming Conventions
| Tipo | Patrón Detectado | Ejemplo |
|------|------------------|---------|
| Archivos | kebab-case / PascalCase / camelCase | `user-service.ts` |
| Clases | PascalCase | `UserService` |
| Funciones | camelCase | `getUserById` |
| Variables | camelCase | `userId` |
| Constantes | UPPER_SNAKE | `MAX_RETRIES` |
| Interfaces | I-prefix / no-prefix | `IUserRepository` |

### Code Style
- Indentation: [tabs/spaces, size]
- Quotes: [single/double]
- Semicolons: [yes/no]
- Line length: [detected max]
- Import style: [absolute/relative]

### Testing Patterns
| Tipo | Framework | Ubicación | Cobertura Estimada |
|------|-----------|-----------|-------------------|
| Unit | Jest/PHPUnit/pytest | `__tests__/`, `tests/` | X% |
| Integration | Supertest/etc | `tests/integration/` | X% |
| E2E | Playwright/Cypress | `e2e/`, `tests/e2e/` | X% |
```

### Step 5: Analyze Dependencies

```markdown
## Análisis de Dependencias

### Core Dependencies
| Paquete | Versión | Propósito |
|---------|---------|-----------|
| [framework] | vX.X | Core framework |
| [orm] | vX.X | Database |
| [auth] | vX.X | Authentication |

### Dev Dependencies Relevantes
| Paquete | Propósito |
|---------|-----------|
| [test-framework] | Testing |
| [linter] | Code quality |
| [formatter] | Formatting |

### Potential Security Concerns
[Ejecutar audit si disponible]

### Dependency Graph Highlights
- Total dependencies: X
- Direct: X
- Transitive: X
- Outdated: X
```

### Step 6: Git History Analysis

```markdown
## Análisis de Historia Git

### Repository Stats
| Métrica | Valor |
|---------|-------|
| Total commits | X |
| Contributors | X |
| First commit | YYYY-MM-DD |
| Last commit | YYYY-MM-DD |
| Active branches | X |

### Commit Patterns
| Patrón | Uso |
|--------|-----|
| Conventional Commits | ✓/✗ |
| Prefix style | feat:/fix:/etc |
| Typical commit size | X files, X lines |

### Hotspots (most changed files)
| Archivo | Cambios | Riesgo |
|---------|---------|--------|
| [file1] | X commits | Alto/Medio/Bajo |
| [file2] | X commits | Alto/Medio/Bajo |

### Recent Activity
[Últimos 10 commits relevantes]
```

### Step 7: Detect Existing Documentation

```markdown
## Documentación Existente

| Archivo | Tipo | Estado |
|---------|------|--------|
| `README.md` | General | ✓/✗ |
| `CONTRIBUTING.md` | Contribution | ✓/✗ |
| `docs/` | Documentation folder | ✓/✗ |
| `API.md` | API docs | ✓/✗ |
| `CHANGELOG.md` | Change history | ✓/✗ |
| `.ai/` | AI context | ✓/✗ |

### Code Documentation
- JSDoc/TSDoc/PHPDoc coverage: X%
- README in key directories: X/Y
```

### Step 8: Generate Project Profile

Create `.ai/project/intelligence/project-profile.md`:

```markdown
# Project Profile: [Project Name]

> Auto-generated by /workflows:discover on [DATE]
> Last updated: [TIMESTAMP]

---

## Quick Facts

| Attribute | Value |
|-----------|-------|
| **Type** | [Web App / API / Library / CLI / Monorepo] |
| **Primary Language** | [TypeScript / PHP / Python / etc] |
| **Framework** | [React + Node / Symfony / Django / etc] |
| **Architecture** | [DDD / MVC / Clean / Monolith / Microservices] |
| **Database** | [PostgreSQL / MySQL / MongoDB / etc] |
| **Complexity** | [Low / Medium / High / Very High] |
| **Test Coverage** | [X%] |
| **Team Size** | [Solo / Small / Medium / Large] (inferred from git) |

---

## Tech Stack

### Backend
- **Runtime**: [Node.js 20 / PHP 8.3 / Python 3.12]
- **Framework**: [Express / NestJS / Symfony / FastAPI]
- **ORM**: [Prisma / TypeORM / Doctrine / SQLAlchemy]
- **Auth**: [JWT / Session / OAuth]

### Frontend
- **Framework**: [React 18 / Vue 3 / Angular 17]
- **State**: [Redux / Zustand / Pinia]
- **Styling**: [Tailwind / CSS Modules / Styled Components]
- **Build**: [Vite / Webpack / Turbopack]

### Infrastructure
- **Container**: [Docker / Podman]
- **CI/CD**: [GitHub Actions / GitLab CI / Jenkins]
- **Cloud**: [AWS / GCP / Azure / Vercel]
- **Monitoring**: [DataDog / Sentry / etc]

---

## Architecture Overview

### Structure
```
[Simplified directory tree with annotations]
```

### Patterns in Use
- [Pattern 1]: Used in [location], purpose: [why]
- [Pattern 2]: Used in [location], purpose: [why]

### Key Abstractions
| Abstraction | Location | Purpose |
|-------------|----------|---------|
| Repository | `src/infrastructure/repositories/` | Data access |
| Service | `src/application/services/` | Business logic |
| Controller | `src/presentation/controllers/` | HTTP handling |

---

## Code Conventions

### Naming
```typescript
// Files: kebab-case
user-service.ts

// Classes: PascalCase
class UserService {}

// Functions: camelCase
function getUserById() {}

// Interfaces: PascalCase (no I-prefix)
interface UserRepository {}
```

### Style Rules
- Indent: 2 spaces
- Quotes: single
- Semicolons: no
- Max line: 100 chars
- Imports: absolute paths from `src/`

### Testing Convention
- Unit tests: `*.test.ts` next to source
- Integration: `tests/integration/`
- E2E: `e2e/`
- Coverage target: 80%

---

## Reference Implementations

When implementing new features, use these as templates:

### Entity Example
→ `src/domain/entities/User.ts`

### Repository Example
→ `src/infrastructure/repositories/UserRepository.ts`

### Service Example
→ `src/application/services/AuthService.ts`

### Controller Example
→ `src/presentation/controllers/UserController.ts`

### Component Example
→ `src/components/UserProfile/UserProfile.tsx`

### Test Example
→ `src/domain/entities/User.test.ts`

---

## Known Patterns & Anti-Patterns

### Patterns to Follow
1. **[Pattern Name]**: [Description and when to use]
2. **[Pattern Name]**: [Description and when to use]

### Anti-Patterns to Avoid
1. **[Anti-Pattern]**: [Why and what to do instead]
2. **[Anti-Pattern]**: [Why and what to do instead]

---

## Project Health

### Strengths
- ✅ [Strength 1]
- ✅ [Strength 2]

### Areas for Improvement
- ⚠️ [Area 1]: [Recommendation]
- ⚠️ [Area 2]: [Recommendation]

### Technical Debt
| Item | Severity | Location |
|------|----------|----------|
| [Debt item] | High/Med/Low | [File/area] |

---

## Workflow Recommendations

Based on this project's characteristics:

| Task Type | Recommended Workflow | Why |
|-----------|---------------------|-----|
| New Feature | `/workflows:plan` (full) | Complex architecture needs planning |
| Bug Fix | `/workflows:route` → work | Direct fix with review |
| Refactor | `/workflows:solid-refactor` | SOLID analysis first |
| Performance | Performance Review Agent | Specialized analysis |

### Trust Level by Area
| Area | Trust | Approach |
|------|-------|----------|
| Domain layer | High | Established patterns |
| New modules | Medium | Verify with reviewer |
| External integrations | Low | Extra review needed |

---

## Quick Commands for This Project

```bash
# Run tests
[detected test command]

# Start dev server
[detected dev command]

# Build
[detected build command]

# Lint
[detected lint command]

# Type check
[detected type check command]
```

---

*Profile regenerated automatically. Manual edits will be preserved in sections marked `<!-- CUSTOM -->`*
```

### Step 9: Generate Config if Missing

If `.ai/project/config.yaml` doesn't exist, create it:

```yaml
# Auto-generated by /workflows:discover
# Manual edits are preserved on refresh

project:
  name: "[detected]"
  type: "[web-app|api|library|cli|monorepo]"
  description: "[from README or package.json]"

backend:
  framework: "[detected]"
  language: "[detected]"
  path: "[detected]"

frontend:
  framework: "[detected]"
  language: "[detected]"
  path: "[detected]"

database:
  type: "[detected]"
  orm: "[detected]"

architecture:
  pattern: "[ddd|mvc|clean|hexagonal|feature-based]"
  layers:
    - name: domain
      path: src/domain
    - name: application
      path: src/application
    - name: infrastructure
      path: src/infrastructure

testing:
  framework: "[detected]"
  coverage_target: 80
  locations:
    unit: "**/*.test.ts"
    integration: "tests/integration/"
    e2e: "e2e/"

conventions:
  commits: conventional
  branches: "[detected pattern]"
  file_naming: kebab-case

ai_analysis:
  last_scan: "[timestamp]"
  complexity: "[low|medium|high|very-high]"
  detected_patterns: []
  reference_files: {}

workflow:
  default: standard
  auto_refresh: true
  session_max_messages: 50
```

### Step 10: Display Summary

```markdown
╔══════════════════════════════════════════════════════════════════════╗
║                    Discovery Completado                              ║
╚══════════════════════════════════════════════════════════════════════╝

## Resumen del Proyecto

| Aspecto | Detectado |
|---------|-----------|
| **Nombre** | [project-name] |
| **Tipo** | [type] |
| **Stack** | [backend] + [frontend] |
| **Arquitectura** | [pattern] |
| **Complejidad** | [level] |

## Archivos Generados

✅ `.ai/project/intelligence/project-profile.md` - Perfil completo
✅ `.ai/project/config.yaml` - Configuración del proyecto
✅ `.ai/project/context.md` - Contexto para agentes

## Conocimiento Capturado

- 📁 Estructura: [X] directorios mapeados
- 🔧 Patrones: [X] patrones detectados
- 📦 Dependencias: [X] analizadas
- 📝 Commits: [X] analizados
- 🎯 Referencias: [X] archivos template identificados

## Próximos Pasos

1. **Revisar el perfil**: `cat .ai/project/intelligence/project-profile.md`
2. **Ajustar si necesario**: Edita `config.yaml` para correcciones
3. **Empezar a trabajar**: `/workflows:plan tu-feature`

> El plugin ahora tiene conocimiento profundo de tu proyecto.
> Este conocimiento se usa automáticamente en planning y reviews.
```

## Flags

| Flag | Description |
|------|-------------|
| `--full` | Análisis completo desde cero (sobrescribe) |
| `--refresh` | Actualiza solo lo que cambió |
| `--report` | Solo muestra el perfil actual sin re-escanear |
| `--quiet` | Menos output, solo errores |

## Integration with Other Commands

- **`/workflows:plan`**: Lee el project-profile para informar planificación
- **`/workflows:work`**: Usa convenciones detectadas para código consistente
- **`/workflows:review`**: Valida contra patrones documentados
- **`/workflows:compound`**: Actualiza perfil con nuevos aprendizajes

## Auto-Discovery Triggers

El discovery se ejecuta automáticamente cuando:
1. Se detecta que no existe `.ai/project/config.yaml`
2. Han pasado más de 7 días desde el último scan
3. Se detectan cambios significativos en `package.json` o equivalente

## Related Commands

- `/workflows:onboarding` - Para nuevos usuarios
- `/workflows:status` - Estado actual
- `/workflows:reload` - Recargar sin re-discovery
