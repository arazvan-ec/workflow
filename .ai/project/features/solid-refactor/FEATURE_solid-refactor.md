# Feature: SOLID Refactor - SNAAPI Response Factories & Orchestrators

## Overview

Refactorizar la arquitectura de SNAAPI para cumplir con principios SOLID y mejorar la escalabilidad. Actualmente, agregar nuevos tipos de elementos requiere modificar clases existentes, violando el principio Open/Closed.

## Problem Statement

### Violaciones Identificadas

| Severidad | Archivo | Violación | Impacto |
|-----------|---------|-----------|---------|
| CRÍTICO | `BodyElementResponseFactory.php` | OCP - match(true) con 15+ tipos | Nuevo tipo = modificar clase |
| CRÍTICO | `MultimediaResponseFactory.php` | OCP - match(true) con tipos | Nuevo tipo = modificar clase |
| CRÍTICO | `EditorialResponseFactory.php` | SRP - 46 imports, 11 métodos privados | Frágil a cambios |
| CRÍTICO | `EditorialOrchestrator.php` | SRP + DIP - 17 dependencias | God class imposible de mantener |
| ALTO | `BodyElementDataTransformerHandler.php` | get_class() anti-pattern | Error solo en runtime |
| ALTO | `MediaDataTransformerHandler.php` | get_class() anti-pattern | Error solo en runtime |
| ALTO | `MultimediaTrait.php` | SRP - 128 líneas, 7 clases dependientes | Hardcoding de tamaños |

## Success Criteria

1. **Open/Closed Principle**: Agregar nuevo tipo de elemento = crear 1 clase nueva, 0 modificaciones
2. **Single Responsibility**: Cada clase tiene una única razón para cambiar
3. **Dependency Inversion**: Factories dependen de abstracciones (interfaces), no de concretos
4. **Testability**: Cada componente se puede testear de forma aislada
5. **Escalabilidad**: Nuevas features tocan máximo 1-2 archivos existentes

## Acceptance Criteria

- [ ] Todos los tests existentes pasan
- [ ] Cobertura de tests >= 80% en clases refactorizadas
- [ ] PHPStan nivel 8 sin errores
- [ ] Agregar nuevo tipo de BodyElement requiere solo crear nueva clase
- [ ] Agregar nuevo tipo de Multimedia requiere solo crear nueva clase
- [ ] Documentación de arquitectura actualizada

## Architecture Decision

### Patrón Elegido: Strategy + Tagged Services

```
┌─────────────────────────────────────────────────────────┐
│                    Factory (Orquestador)                │
│  - Solo itera sobre creators                            │
│  - No conoce tipos específicos                          │
│  - Recibe creators via DI (tagged services)             │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│              CreatorInterface (Contrato)                │
│  + supports(element): bool                              │
│  + create(element, resolveData): Response               │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ ParagraphCreator│ │ SubHeadCreator │ │ PictureCreator │
│               │   │               │   │               │
│ supports()    │   │ supports()    │   │ supports()    │
│ create()      │   │ create()      │   │ create()      │
└───────────────┘   └───────────────┘   └───────────────┘
```

### Beneficios

1. **Extensible**: Nuevo tipo = nueva clase con interface
2. **Symfony DI**: Auto-discovery via tagged services
3. **Testeable**: Mock individual creators
4. **Cohesión**: Cada creator conoce solo su tipo

## Parallelization Strategy

### Fase 1: Foundations (Secuencial)
- Crear interfaces base
- Configurar Symfony DI tags

### Fase 2: Factories (Paralelo)
- Stream 1: BodyElement creators
- Stream 2: Multimedia creators
- Stream 3: Editorial extractors

### Fase 3: Handlers (Paralelo)
- Stream 1: BodyElementDataTransformerHandler
- Stream 2: MediaDataTransformerHandler

### Fase 4: Orchestrator (Secuencial)
- Depende de que factories estén completos
- Refactorizar EditorialOrchestrator

### Fase 5: Cleanup (Secuencial)
- Eliminar MultimediaTrait
- Mover configuración a services.yaml

## Timeline Estimate

| Fase | Tareas | Paralelizable | Dependencias |
|------|--------|---------------|--------------|
| 1 | 3 | No | - |
| 2 | 18 | Sí (3 streams) | Fase 1 |
| 3 | 4 | Sí (2 streams) | Fase 1 |
| 4 | 5 | No | Fases 2, 3 |
| 5 | 3 | No | Fase 4 |

## References

- Existing pattern: `EnrichmentPipeline.php` (good example)
- Symfony tagged services: https://symfony.com/doc/current/service_container/tags.html
