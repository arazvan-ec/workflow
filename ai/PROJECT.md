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
