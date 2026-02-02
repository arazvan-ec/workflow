# Architecture Quality Criteria (Default)

Criterios de calidad arquitectónica que el plugin aplica **por defecto** a todas las features. Estos criterios definen qué hace una arquitectura "buena".

> "Una buena arquitectura se mide por lo fácil que es hacer cambios, no por lo elegante que se ve el diagrama inicial"

---

## Principio Fundamental

**Cambio Fácil = Cambio Localizado**

Una arquitectura es buena cuando:
- Un cambio simple toca **pocos archivos** (≤3 para cambios triviales)
- Un cambio no genera **efectos cascada** inesperados
- Los patrones de diseño **reducen** la complejidad, no la aumentan

---

## Criterios Base (Siempre Aplicados)

### C-BASE-01: Escalabilidad Estructural

**Definición**: La arquitectura permite crecer sin reescribir.

**Métricas de Verificación**:

| Indicador | Bueno | Aceptable | Malo |
|-----------|-------|-----------|------|
| Añadir nueva entidad | ≤5 archivos | 6-10 archivos | >10 archivos |
| Añadir nuevo endpoint | ≤4 archivos | 5-7 archivos | >7 archivos |
| Añadir nuevo campo a entidad | ≤3 archivos | 4-5 archivos | >5 archivos |

**Verificación Práctica**:
```bash
# Contar archivos modificados en últimos commits de "nueva funcionalidad"
git log --oneline --name-only | grep -A 20 "feat:" | grep -v "^$" | wc -l
# Objetivo: promedio ≤5 archivos por feature simple
```

**Anti-patrones a Evitar**:
- God classes que requieren modificación para todo
- Configuraciones centralizadas que se tocan siempre
- Herencia profunda que propaga cambios

---

### C-BASE-02: SOLID Compliance

**Definición**: Los 5 principios SOLID se respetan en el diseño.

#### S - Single Responsibility

| Indicador | Bueno | Aceptable | Malo |
|-----------|-------|-----------|------|
| Líneas por clase/módulo | ≤200 | 201-400 | >400 |
| Métodos públicos por clase | ≤7 | 8-12 | >12 |
| Razones para cambiar | 1 | 2 | >2 |

**Test Rápido**: "¿Puedo describir esta clase en UNA frase sin usar 'y'?"
- ✅ "Gestiona la persistencia de usuarios"
- ❌ "Gestiona usuarios y envía emails y valida permisos"

#### O - Open/Closed

| Indicador | Bueno | Malo |
|-----------|-------|------|
| Añadir comportamiento | Crear nueva clase | Modificar clase existente |
| Switch/if-else por tipo | 0 | >0 (usar polimorfismo) |

**Test Rápido**: "¿Puedo añadir un nuevo tipo de X sin modificar código existente?"

#### L - Liskov Substitution

| Indicador | Bueno | Malo |
|-----------|-------|------|
| Subclase reemplaza a padre | Sin sorpresas | Comportamiento diferente |
| Override de métodos | Mantiene contrato | Rompe expectativas |

**Test Rápido**: "¿Puedo usar cualquier implementación donde se espera la interfaz?"

#### I - Interface Segregation

| Indicador | Bueno | Aceptable | Malo |
|-----------|-------|-----------|------|
| Métodos por interfaz | ≤5 | 6-8 | >8 |
| Implementaciones que usan todo | 100% | >80% | <80% |

**Test Rápido**: "¿Alguna implementación tiene métodos vacíos o `throw NotImplemented`?"

#### D - Dependency Inversion

| Indicador | Bueno | Malo |
|-----------|-------|------|
| Dependencias en Domain | Solo abstracciones | Clases concretas de infra |
| Constructores | Reciben interfaces | Instancian dependencias |

**Test Rápido**: "¿El Domain layer importa algo de Infrastructure?"

---

### C-BASE-03: Clean Code Metrics

**Definición**: El código es legible, mantenible y auto-documentado.

| Indicador | Bueno | Aceptable | Malo |
|-----------|-------|-----------|------|
| Líneas por función | ≤20 | 21-40 | >40 |
| Parámetros por función | ≤3 | 4-5 | >5 |
| Niveles de indentación | ≤3 | 4 | >4 |
| Complejidad ciclomática | ≤10 | 11-15 | >15 |
| Nombres descriptivos | Sí (sin comentarios) | Con comentarios | Abreviaciones crípticas |

**Verificación Automatizada**:
```bash
# PHP
./vendor/bin/phpstan analyse --level=6
./vendor/bin/php-cs-fixer fix --dry-run

# TypeScript
npx eslint --max-warnings=0
npx tsc --noEmit
```

---

### C-BASE-04: Responsabilidades Definidas (Separation of Concerns)

**Definición**: Cada capa/módulo tiene una responsabilidad clara y única.

**Estructura DDD Esperada**:

```
src/
├── Domain/           # Reglas de negocio PURAS (sin dependencias externas)
│   ├── Entity/       # Entidades con identidad
│   ├── ValueObject/  # Objetos inmutables sin identidad
│   ├── Repository/   # Interfaces (NO implementaciones)
│   ├── Service/      # Lógica de dominio que no cabe en entidades
│   └── Event/        # Eventos de dominio
│
├── Application/      # Orquestación de casos de uso
│   ├── Command/      # Acciones que modifican estado
│   ├── Query/        # Acciones de lectura
│   ├── DTO/          # Objetos de transferencia
│   └── Service/      # Coordinación entre dominio e infra
│
└── Infrastructure/   # Detalles técnicos
    ├── Persistence/  # Implementaciones de repositorios
    ├── Controller/   # Entry points HTTP (thin)
    ├── External/     # APIs externas, servicios third-party
    └── Config/       # Configuración técnica
```

**Reglas de Dependencia**:

```
Domain ← Application ← Infrastructure
   ↑         ↑              ↑
   │         │              │
   └─────────┴──────────────┘

Domain NO conoce Application ni Infrastructure
Application NO conoce Infrastructure (usa interfaces)
Infrastructure conoce todo (implementa interfaces)
```

**Verificación**:

| Check | Esperado |
|-------|----------|
| Domain importa de Application | ❌ Nunca |
| Domain importa de Infrastructure | ❌ Nunca |
| Application importa de Infrastructure | ❌ Nunca (solo interfaces) |
| Controller tiene lógica de negocio | ❌ Nunca (delegación pura) |
| Repository está en Domain | ✅ Interface sí, implementación no |

---

### C-BASE-05: Patrones de Diseño Adecuados

**Definición**: Usar patrones que **simplifican**, no que complican.

**Criterio de Selección de Patrón**:

```
¿Necesito este patrón?
    │
    ├─ ¿Resuelve un problema REAL que tengo AHORA?
    │      NO → No usar (YAGNI)
    │      SÍ ↓
    │
    ├─ ¿La solución sin patrón requiere >3 archivos modificados para cambios?
    │      NO → Solución simple es suficiente
    │      SÍ ↓
    │
    └─ ¿El equipo conoce este patrón?
           NO → Documentar o elegir alternativa conocida
           SÍ → Usar el patrón
```

**Patrones Recomendados por Caso**:

| Problema | Patrón | Resultado Esperado |
|----------|--------|-------------------|
| Múltiples formas de crear objeto | Factory | 1 lugar para lógica de creación |
| Objeto con muchos parámetros opcionales | Builder | Construcción legible y flexible |
| Necesito desacoplar productor/consumidor | Observer/Event | 0 dependencias directas |
| Múltiples algoritmos intercambiables | Strategy | Añadir algoritmo = 1 archivo nuevo |
| Acceso a recursos externos | Repository | Cambiar storage = 1 implementación |
| Operaciones cross-cutting (log, cache) | Decorator | Añadir comportamiento sin modificar |

**Anti-patrones**:

| Anti-patrón | Síntoma | Alternativa |
|-------------|---------|-------------|
| Patrón por si acaso | "Quizás lo necesitemos" | Implementar cuando sea necesario |
| Abstract Factory para 1 tipo | Sobre-ingeniería | Factory simple o constructor |
| Singleton para todo | Estado global, testing difícil | Dependency Injection |
| Herencia profunda (>2 niveles) | Fragilidad, acoplamiento | Composición |

---

### C-BASE-06: Invasividad de Cambios (Change Impact)

**Definición**: Los cambios comunes deben tocar el mínimo de archivos.

**Matriz de Impacto Esperado**:

| Tipo de Cambio | Archivos Máximos | Capas Afectadas |
|----------------|------------------|-----------------|
| Nuevo campo en entidad | 3 | Domain, DTO, Migration |
| Nueva validación de negocio | 2 | Domain (Entity o VO) |
| Nuevo endpoint CRUD | 4 | Controller, UseCase, DTO, Route |
| Cambio en UI de un campo | 1 | Component |
| Nueva regla de autorización | 2 | Policy/Guard, Config |
| Cambio de proveedor externo | 1 | Infrastructure adapter |

**Señales de Alarma**:

| Señal | Indica |
|-------|--------|
| Cambio simple toca >5 archivos | Acoplamiento alto |
| Cambio en Domain afecta Controllers | Violación de capas |
| Cambio en UI requiere cambio en API | Acoplamiento frontend-backend |
| Añadir feature requiere modificar "base classes" | Herencia mal usada |

**Verificación Post-Cambio**:
```bash
# Después de implementar una feature, verificar
git diff --stat HEAD~1

# Si un cambio "simple" muestra >5 archivos, revisar arquitectura
```

---

## Aplicación de Criterios

### Durante Planning (/workflows:plan)

```markdown
## Architecture Quality Checklist

Antes de aprobar arquitectura, verificar:

### Escalabilidad
- [ ] Añadir nueva entidad requiere ≤5 archivos
- [ ] No hay god classes (>400 líneas)

### SOLID
- [ ] Cada clase tiene 1 responsabilidad
- [ ] Nuevos comportamientos = nuevas clases (no modificar)
- [ ] Domain solo tiene interfaces de repositorio

### Clean Code
- [ ] Funciones ≤20 líneas
- [ ] Máximo 3 parámetros por función
- [ ] Nombres auto-descriptivos

### Separación
- [ ] Domain no importa de Infrastructure
- [ ] Controllers son thin (solo delegación)
- [ ] Lógica de negocio en Domain, no en Application

### Patrones
- [ ] Patrones usados resuelven problemas reales
- [ ] No hay sobre-ingeniería preventiva

### Invasividad
- [ ] Cambios comunes identificados
- [ ] Impacto estimado ≤ matriz de referencia
```

### Durante Review (/workflows:review)

El agente `ddd-compliance` verifica automáticamente:
- Dependencias entre capas
- Tamaño de clases/funciones
- Complejidad ciclomática

### Post-Implementation

```bash
# Verificar impacto real vs esperado
git log --oneline --name-only -5 | grep -c "^src/"
# Comparar con estimación de invasividad
```

---

## Excepciones Documentadas

Hay casos donde romper un criterio es aceptable:

| Excepción | Cuándo es OK | Debe Documentar |
|-----------|--------------|-----------------|
| Clase >200 líneas | Entidad de dominio compleja con muchas reglas | Justificación en ADR |
| >3 parámetros | DTO de request con muchos campos | N/A (DTOs son contenedores) |
| Cambio toca >5 archivos | Refactor planificado | Scope en PR description |
| Patrón "innecesario" | Preparación para feature conocida en roadmap | Link a roadmap item |

**Formato de Excepción**:
```markdown
## Exception: [Criterio violado]
**Razón**: [Por qué es necesario]
**Mitigación**: [Cómo se compensa]
**Revisión**: [Cuándo reconsiderar]
```

---

## Métricas de Salud Arquitectónica

Dashboard de salud que el plugin puede generar:

```
╔════════════════════════════════════════════════════════════╗
║           ARCHITECTURE HEALTH: my-feature                   ║
╚════════════════════════════════════════════════════════════╝

Escalabilidad     [████████░░]  80%  (avg 4.2 files/feature)
SOLID Compliance  [█████████░]  90%  (1 violation: UserService)
Clean Code        [███████░░░]  70%  (5 functions >20 lines)
Layer Separation  [██████████] 100%  (no cross-layer imports)
Pattern Usage     [████████░░]  80%  (1 unnecessary factory)
Change Impact     [█████████░]  90%  (1 feature >5 files)

Overall Health: 85% (GOOD)

Recommendations:
1. Refactor UserService - split into UserAuthService + UserProfileService
2. Simplify functions in OrderProcessor.php (lines 45-89)
3. Remove PaymentProviderFactory - only 1 provider exists
```

---

## Integración con Otros Componentes

Este archivo es leído por:
- `criteria-generator.md` - Para incluir criterios base
- `ddd-compliance.md` - Para verificación automática
- `planner.md` - Durante fase de arquitectura
- `code-simplicity-reviewer.md` - Durante review

---

**Versión**: 1.0
**Última Actualización**: 2026-02-02
**Aplicable a**: Todos los proyectos que usen el plugin
