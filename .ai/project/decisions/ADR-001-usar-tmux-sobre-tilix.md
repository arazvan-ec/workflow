# ADR-001: Usar tmux sobre Tilix para orquestación de agentes paralelos

> **Estado**: ACCEPTED
> **Fecha**: 2026-01-27
> **Decisores**: Planner Agent, Backend Agent
> **Feature relacionada**: workflow-improvements-2026

---

## Contexto

El sistema multi-agente necesita un mecanismo para ejecutar múltiples agentes Claude Code en paralelo, cada uno trabajando en su propio git worktree. Esto permite:

- Backend y Frontend trabajando simultáneamente en la misma feature
- Múltiples agentes de review ejecutándose en paralelo
- Aislamiento de contexto entre agentes

Actualmente se usa Tilix (terminal gráfico), pero presenta limitaciones para automatización y uso en entornos sin GUI.

### Drivers

- Necesidad de scriptabilidad completa para automatización
- Soporte para entornos headless (CI/CD, servidores remotos)
- Compatibilidad cross-platform (Linux, macOS, WSL)
- Gestión programática de sesiones y ventanas

### Restricciones

- Debe funcionar en entornos sin interfaz gráfica
- Debe ser instalable fácilmente en la mayoría de sistemas
- Debe permitir monitoreo del estado de múltiples agentes

## Opciones Consideradas

### Opción 1: tmux

**Descripción**: Terminal multiplexer que funciona en cualquier terminal, permite crear sesiones, ventanas y paneles programáticamente.

**Pros**:
- Completamente scriptable via CLI
- Funciona en entornos headless
- Disponible en todas las plataformas (Linux, macOS, WSL)
- Soporte nativo para sesiones persistentes (sobrevive desconexiones)
- Ecosistema maduro con plugins (tmuxinator, etc.)
- Integración fácil con git worktrees

**Cons**:
- Curva de aprendizaje para usuarios no familiarizados
- Interfaz de usuario menos intuitiva que terminales gráficos
- Requiere instalación adicional (no viene preinstalado)

### Opción 2: Tilix

**Descripción**: Emulador de terminal con tiles/paneles integrados, interfaz gráfica moderna.

**Pros**:
- Interfaz visual intuitiva
- Fácil de usar manualmente
- Buen soporte de temas y personalización

**Cons**:
- Solo disponible en Linux (no macOS nativo, no Windows)
- Requiere entorno gráfico (X11/Wayland)
- Scriptabilidad limitada
- No hay API programática robusta
- No persiste sesiones automáticamente

### Opción 3: Terminal nativo con background processes

**Descripción**: Usar el terminal del sistema con procesos en background (`&`, `nohup`).

**Pros**:
- No requiere instalación adicional
- Simple para casos básicos

**Cons**:
- Difícil monitorear múltiples procesos
- No hay gestión de layout/visualización
- Logs dispersos
- Difícil coordinar entre procesos

## Decisión

> **Elegimos tmux porque** es la única opción que cumple todos los requisitos: scriptabilidad completa, soporte headless, y disponibilidad cross-platform. La curva de aprendizaje es un trade-off aceptable dado que los usuarios principales son desarrolladores/agentes técnicos.

### Trade-offs aceptados

- Los usuarios necesitan tener tmux instalado
- Se requiere documentación/guía de migración desde Tilix
- La interfaz es menos visual que Tilix

## Consecuencias

### Positivas

- Automatización completa de la orquestación de agentes
- Funcionamiento en CI/CD y servidores remotos
- Sesiones persistentes (trabajo no se pierde al desconectar)
- Un solo sistema para todos los entornos

### Negativas

- Usuarios de Tilix necesitan migrar
- Período de aprendizaje para nuevos usuarios

### Neutras

- Tilix se marcará como deprecated pero seguirá funcionando
- Se mantendrá compatibilidad backward por 2 versiones

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Resistencia de usuarios a migrar | Media | Bajo | Documentación clara, período de transición |
| tmux no instalado por defecto | Baja | Bajo | Script de setup automático |

## Plan de Implementación

1. Crear `tmux_orchestrator.sh` con funciones para gestión de sesiones
2. Implementar comandos `/workflows:parallel` usando tmux
3. Crear guía de migración Tilix → tmux
4. Marcar Tilix como deprecated con warning
5. Actualizar documentación principal

**Criterios de éxito**:
- [ ] `/workflows:parallel` funciona con tmux
- [ ] Documentación de migración completada
- [ ] Scripts de setup detectan/instalan tmux
- [ ] Tests de integración pasan en Linux, macOS, y WSL

## Referencias

- [tmux Documentation](https://github.com/tmux/tmux/wiki)
- [tmuxinator - Manage complex tmux sessions](https://github.com/tmuxinator/tmuxinator)
- [Arquitectura del proyecto](../.ai/project/features/workflow-improvements-2026/10_architecture.md)

---

## Notas de Revisión

| Fecha | Autor | Cambio |
|-------|-------|--------|
| 2026-01-27 | Planner Agent | Creación inicial |
| 2026-02-02 | Claude | Migración a formato ADR formal |
