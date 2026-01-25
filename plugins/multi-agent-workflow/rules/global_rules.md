# Global Rules - PROJECT_X

**Project**: PROJECT_X
**Last Updated**: 2026-01-15
**Version**: 1.0

---

## 🎯 Propósito

Este archivo contiene las reglas globales que **todos los roles** deben seguir sin excepción. Son las reglas más generales y aplican a todo el proyecto.

---

## 📜 Reglas Fundamentales

### 1. Contexto Explícito - Sin Memoria Implícita

❌ **NO**: "Recuerda que antes dijimos que..."
✅ **SÍ**: "Lee el archivo `./.ai/project/features/FEATURE_X/50_state.md`"

**Regla**: Todo conocimiento compartido debe estar explícitamente en archivos. No asumas contexto implícito.

### 2. Roles Inmutables

**Regla**: Una instancia de Claude = un rol fijo durante toda la sesión.

- No cambies de Backend a Frontend a mitad de camino
- No implementes código si eres QA
- No tomes decisiones de diseño si eres Backend/Frontend

### 3. Workflow es Ley

**Regla**: Sigue el workflow YAML definido sin saltarte stages.

- No implementes antes de que Planning esté `COMPLETED`
- No hagas QA antes de que Implementation esté `COMPLETED`
- Si necesitas cambiar el workflow, documenta por qué en `DECISIONS.md`

### 4. Estado Sincronizado

**Regla**: Usa `50_state.md` para comunicar estado entre roles.

- Actualiza tu `50_state.md` frecuentemente
- Lee `50_state.md` de otros roles antes de empezar
- Usa estados estándar: `PENDING`, `IN_PROGRESS`, `BLOCKED`, `WAITING_API`, `COMPLETED`, `APPROVED`, `REJECTED`

### 5. Git como Sincronización

**Regla**: Git es el mecanismo de sincronización entre instancias.

- `git pull` antes de empezar a trabajar
- `git push` después de completar tareas
- Commits claros y descriptivos
- No fuerces push a menos que sea absolutamente necesario

### 6. Context Window Management (Sesiones Limpias)

**Regla**: Gestiona el contexto como recurso limitado. Trata la memoria como una Commodore 64.

#### Principios de Context Management

```
🧠 Context Window ≈ 100k tokens (aproximadamente)
   └── Código leído
   └── Historial de conversación
   └── Resultados de herramientas
   └── Errores y outputs

⚠️ Síntomas de contexto lleno:
   └── Respuestas más lentas
   └── "Olvidar" información reciente
   └── Respuestas incompletas o cortadas
   └── Errores de referencia a código anterior
```

#### Reglas de Context Management

1. **Cada checkpoint = Oportunidad de contexto limpio**
   - Después de completar un checkpoint, considera si necesitas reiniciar
   - Si el contexto se siente "pesado", haz git sync y reinicia sesión

2. **Señales para reiniciar sesión**:
   - Has leído más de 20 archivos en la sesión
   - Llevas más de 2 horas en la misma sesión
   - La conversación tiene más de 50 mensajes
   - Estás olvidando cosas que se discutieron antes
   - Las respuestas se vuelven más lentas o incompletas

3. **Protocolo de reinicio de sesión**:
   ```bash
   # 1. Guardar estado actual
   # Actualizar 50_state.md con progreso exacto

   # 2. Commit todo el trabajo
   ./.ai/workflow/scripts/git_commit_push.sh [rol] [feature-id] "Checkpoint: [descripción]"

   # 3. Documentar punto de retoma
   # En 50_state.md, incluir:
   # - Último checkpoint completado
   # - Siguiente tarea a realizar
   # - Archivos relevantes a leer al retomar

   # 4. Iniciar nueva sesión
   # Leer: rol.md, 50_state.md, archivos relevantes
   # Continuar desde el checkpoint documentado
   ```

4. **Evitar chats interminables**:
   - Mejor: Múltiples sesiones cortas y enfocadas
   - Peor: Una sesión larga que acumula contexto innecesario
   - Ideal: Una sesión por checkpoint o grupo de checkpoints relacionados

5. **Limpieza proactiva de contexto**:
   - No releas archivos que ya leíste si no han cambiado
   - Usa resúmenes en lugar de texto completo cuando sea posible
   - Evita outputs verbosos innecesarios (usa `--quiet` cuando aplique)

#### Ejemplo de Documentación para Retoma

```markdown
## Estado para Retoma de Sesión

**Último checkpoint completado**: Domain Layer (User entity, Email value object)
**Tests pasando**: tests/Unit/Domain/UserTest.php (5/5 ✅)

**Siguiente tarea**: Implementar Application Layer (CreateUserUseCase)

**Archivos a leer al retomar**:
- .ai/workflow/roles/backend.md (sección TDD)
- .ai/project/features/user-auth/30_tasks.md (Task 2)
- backend/src/Domain/Entity/User.php (referencia)
- backend/src/Domain/ValueObject/Email.php (referencia)

**Contexto importante**:
- Email validation usa filter_var con FILTER_VALIDATE_EMAIL
- User entity tiene factory method create() para construcción
- Password se hashea en el UseCase, no en el entity
```

### 7. Trust Model (Calibración de Supervisión)

**Origen**: Addy Osmani, "Beyond Vibe Coding" (2026)

**Regla**: La cantidad de supervisión que necesita una tarea depende de tres factores.

```
┌─────────────────────────────────────────────────────────────┐
│                     TRUST MODEL                             │
│                                                             │
│   FAMILIARITY ──────▶ TRUST ──────▶ CONTROL                │
│                                                             │
│   ¿Conoces la         ¿Ha entregado    ¿Cuánta supervisión │
│   tecnología/tarea?   bien antes?      necesita?           │
└─────────────────────────────────────────────────────────────┘
```

#### Niveles de Control

| Nivel | Cuándo Aplicar | Qué Significa |
|-------|----------------|---------------|
| 🔴 **ALTO** | Nueva tecnología, código crítico (auth, payments), primer feature de un tipo | Review en cada paso, checkpoints frecuentes, pair review |
| 🟡 **MEDIO** | Tecnología conocida, patrones establecidos | Review en checkpoints principales, tests obligatorios |
| 🟢 **BAJO** | Features similares a anteriores, alta confianza | Review final, confiar en tests automatizados |

#### Matriz de Decisión

| Situación | Familiarity | Control |
|-----------|-------------|---------|
| Primer auth feature | Baja | 🔴 Alto |
| Segundo auth feature (mismo patrón) | Alta | 🟡 Medio |
| Décimo CRUD similar | Alta | 🟢 Bajo |
| Nueva API externa | Baja | 🔴 Alto |
| Refactor de código conocido | Alta | 🟢 Bajo |
| Feature con requisitos de seguridad | Variable | 🔴 Alto siempre |

#### Aplicación Práctica

**Al iniciar un feature, el Planner debe indicar:**

```markdown
## Trust Assessment

**Feature**: user-authentication
**Trust Level**: 🔴 HIGH CONTROL

**Razón**:
- Primera implementación de auth en el proyecto
- Código crítico de seguridad
- Nuevos patrones (JWT, bcrypt)

**Supervisión requerida**:
- [ ] Review de cada checkpoint por Planner
- [ ] Security review obligatorio
- [ ] Tests de seguridad adicionales
- [ ] Documentación detallada de decisiones
```

**Para features con 🟢 LOW CONTROL:**

```markdown
## Trust Assessment

**Feature**: user-profile-edit
**Trust Level**: 🟢 LOW CONTROL

**Razón**:
- Patrón CRUD ya establecido
- Similar a user-registration (completado)
- Sin requisitos de seguridad especiales

**Supervisión requerida**:
- [ ] Review final antes de merge
- [ ] Tests automatizados deben pasar
```

#### The 70% Problem Awareness

> "AI te ayuda a llegar al 70% rápido, pero el 30% restante es donde está la complejidad real."

**Implicación para Trust Model:**
- El 70% inicial puede tener 🟢 LOW CONTROL
- El 30% final (edge cases, security, integration) necesita 🔴 HIGH CONTROL
- Ajustar supervisión conforme avanza el feature

---

## 🔒 Permisos y Restricciones

### Lectura

Cada rol puede leer:
- Su propio rol markdown (`.md`)
- Todas las reglas del proyecto (`rules/*.md`)
- Workflows YAML
- Estados de features (`50_state.md`)
- Código relevante a su rol

### Escritura

Cada rol solo puede escribir en:
- Su área de código asignada
- Su sección de `50_state.md`
- Archivos de report/tasks asignados a su rol

**IMPORTANTE**: Solo el **Planner** puede modificar reglas del proyecto (con justificación en `DECISIONS.md`).

---

## 📝 Documentación Obligatoria

### Todo feature debe tener:

1. **FEATURE_X.md** - Definición del feature (creado por Planner)
2. **50_state.md** - Estado actualizado por cada rol
3. **30_tasks.md** - Breakdown de tareas (creado por Planner)
4. **DECISIONS.md** - Decisiones importantes (actualizado por Planner)

### Todo código debe tener:

1. **Tests** - Unit, integration, o E2E según corresponda
2. **Documentación** inline (PHPDoc, JSDoc)
3. **README** si es un módulo complejo

---

## 🧪 Testing Requirements

### Backend (Symfony/PHP)

- **Cobertura mínima**: 80%
- **Tests obligatorios**:
  - Unit tests para Use Cases
  - Unit tests para Domain entities
  - Integration tests para Repositories
  - Integration tests para API endpoints

### Frontend (React)

- **Cobertura mínima**: 70%
- **Tests obligatorios**:
  - Unit tests para componentes críticos
  - Integration tests para flujos importantes
  - E2E tests para casos de uso principales

### Ejecución de Tests

- **Todos los tests** deben pasar antes de `COMPLETED`
- **CI/CD** debe estar en verde
- **No** hacer push si tests fallan localmente

---

## 🔐 Security Requirements

### Todos los roles deben:

1. **No commits de secrets**
   - No `.env` con credenciales reales
   - No API keys en código
   - Usar variables de entorno

2. **Validar inputs**
   - Backend: valida todos los inputs de API
   - Frontend: valida todos los inputs de usuario (doble validación con backend)

3. **Prevenir vulnerabilidades comunes**
   - No SQL injection
   - No XSS (Cross-Site Scripting)
   - No CSRF (Cross-Site Request Forgery)
   - No exponer información sensible en logs

4. **HTTPS only**
   - Producción siempre usa HTTPS
   - Cookies con `Secure` y `HttpOnly`

---

## 📦 Dependency Management

### Backend (PHP/Composer)

- Usar Composer para dependencias
- Versiones específicas (no `^` o `~` en prod)
- Actualizar dependencias regularmente
- Revisar vulnerabilidades con `composer audit`

### Frontend (NPM/Yarn)

- Usar npm o yarn (ser consistente)
- Lock file (`package-lock.json` o `yarn.lock`) commiteado
- Actualizar dependencias regularmente
- Revisar vulnerabilidades con `npm audit`

---

## 🎨 Code Style

### Backend (PHP)

- **Standard**: PSR-12
- **Linter**: PHP_CodeSniffer
- **Formatter**: PHP CS Fixer
- Ejecutar antes de commit:
  ```bash
  ./vendor/bin/php-cs-fixer fix
  ```

### Frontend (TypeScript/React)

- **Standard**: ESLint + Prettier
- **Config**: Usar config estándar de React
- Ejecutar antes de commit:
  ```bash
  npm run lint:fix
  npm run format
  ```

---

## 🔄 Git Workflow

### Branching Strategy

- **main**: Producción (solo merges de release)
- **develop**: Desarrollo activo
- **feature/[feature-name]**: Features nuevos
- **bugfix/[bug-name]**: Correcciones de bugs
- **hotfix/[hotfix-name]**: Fixes urgentes para producción

### Commit Messages

Formato:
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: Nueva funcionalidad
- `fix`: Bug fix
- `docs`: Documentación
- `style`: Formato de código (no cambia lógica)
- `refactor`: Refactoring
- `test`: Tests
- `chore`: Tareas de mantenimiento

Ejemplo:
```
feat(user): Add user registration endpoint

- Implement CreateUserUseCase
- Add UserRepository
- Add POST /api/users endpoint
- Add unit and integration tests

Closes #123
```

---

## 🚫 Prohibiciones Globales

### Todos los roles están **prohibidos** de:

1. **Commitear código sin tests**
2. **Push con tests fallando**
3. **Cambiar código sin documentar por qué**
4. **Saltarse el workflow**
5. **Implementar features no definidos por Planner**
6. **Cambiar contratos de API sin consenso**
7. **Hacer fuerza push a `main` o `develop`**
8. **Commitear archivos generados** (`.env`, `node_modules/`, `vendor/`, etc.)

---

## ⚠️ Manejo de Conflictos

### Conflictos de Git

1. `git pull` antes de trabajar
2. Si hay conflicto:
   ```bash
   git stash
   git pull
   git stash pop
   # Resolver conflictos manualmente
   ```
3. Nunca uses `--force` sin consultar

### Conflictos de Diseño

1. Reportar en `50_state.md` con estado `BLOCKED`
2. Planner toma la decisión
3. Decisión se documenta en `DECISIONS.md`

---

## 📊 Métricas de Calidad

### Backend

- **Test Coverage**: > 80%
- **Complexity**: Cyclomatic < 10 por función
- **Duplicación**: < 5%
- **Technical Debt**: Bajo (SonarQube A rating)

### Frontend

- **Test Coverage**: > 70%
- **Bundle Size**: < 500KB (gzipped)
- **Lighthouse Score**: > 90
- **Accessibility**: WCAG 2.1 AA

---

## 🎯 Definition of Done

Un feature está **DONE** cuando:

- ✅ Código implementado según `FEATURE_X.md`
- ✅ Tests escritos y pasando (coverage > mínimo)
- ✅ Code review hecho (por QA)
- ✅ Documentación actualizada
- ✅ CI/CD en verde
- ✅ QA aprueba (`APPROVED` en `50_state.md`)
- ✅ Deployed a staging
- ✅ Planner da visto bueno final

---

## 📖 Lectura Obligatoria

**Todos los roles** deben leer este archivo antes de **cada tarea**.

No es suficiente leerlo una vez. Las reglas pueden actualizarse, y es tu responsabilidad estar al día.

---

**Última actualización**: 2026-01-16
**Actualizado por**: Planner
**Cambios recientes**: Añadido Context Window Management (Ralph Wiggum Pattern)
**Próxima revisión**: Mensual o cuando sea necesario
