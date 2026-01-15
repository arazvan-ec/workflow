# Cómo Instalar el Workflow System en Cualquier Proyecto

Guía super simple para instalar el sistema de workflows en tu proyecto.

## 🎯 Lo que necesitas

- Un proyecto (puede ser nuevo o existente)
- Este repositorio (`workflow/`) clonado o descargado

## ⚡ Instalación Rápida (3 pasos)

### Paso 1: Navega a tu proyecto

```bash
cd /path/to/tu-proyecto
```

### Paso 2: Ejecuta el instalador

```bash
bash /path/to/workflow/install.sh
```

Reemplaza `/path/to/workflow` con la ruta real donde tienes este repo.

### Paso 3: ¡Listo!

El instalador habrá creado:

```
tu-proyecto/
├── ai/                  # ← Sistema de contexto compartido
├── scripts/             # ← Herramientas CLI
├── hooks/               # ← Git hooks
├── README.md            # ← Documentación
├── QUICKSTART.md        # ← Tutorial
└── CHEATSHEET.md        # ← Referencia rápida
```

## 🚀 Primeros Pasos

Después de instalar, desde tu proyecto:

```bash
# Ver el ejemplo incluido
./scripts/workflow status example-todo-api

# Crear tu primer workflow (interactivo)
./scripts/workflow consult

# Leer el tutorial de 5 minutos
cat QUICKSTART.md
```

## 💡 Ejemplo Completo

```bash
# 1. Ir a tu proyecto
cd ~/mis-proyectos/mi-api

# 2. Instalar (asumiendo que clonaste workflow en ~/workflow)
bash ~/workflow/install.sh

# 3. Verificar
./scripts/workflow list
# Debe mostrar: example-todo-api [active]

# 4. Crear tu primer workflow
./scripts/workflow consult

# Responde las preguntas:
# - Task: "Sistema de autenticación de usuarios"
# - Type: "New feature (frontend + backend)"
# - Architecture: "Simple"
# - etc...

# 5. ¡El workflow está listo!
./scripts/workflow status user-authentication
```

## 🔧 Opciones Avanzadas

### Opción A: Instalador Auto-Contenido

Si quieres un solo archivo que contenga todo:

```bash
# Desde el repo workflow
cd /path/to/workflow
./scripts/generate-installer

# Se crea: install-workflow.sh
# Copia este archivo a cualquier proyecto y ejecútalo

cp install-workflow.sh /path/to/tu-proyecto/
cd /path/to/tu-proyecto
bash install-workflow.sh
```

### Opción B: Copia Manual

Si prefieres control total:

```bash
cd /path/to/tu-proyecto

# Copiar estructura
cp -r /path/to/workflow/ai ./
cp -r /path/to/workflow/scripts ./
cp -r /path/to/workflow/hooks ./

# Copiar docs
cp /path/to/workflow/*.md ./

# Hacer ejecutables
chmod +x scripts/*

# Instalar dependencias
pip3 install pyyaml
```

## ❓ FAQ

### ¿Qué pasa si ya tengo una carpeta `ai/`?

El instalador te preguntará si quieres hacer backup. Dirá algo como:

```
⚠ Directory 'ai/' already exists.
? Do you want to backup and replace it? (y/N):
```

Si dices `y`, hará backup como `ai.backup.20260115_123456/`

### ¿Puedo instalarlo en un proyecto que ya tiene código?

**¡Sí!** El instalador solo agrega archivos, no modifica tu código existente.

### ¿Funciona con cualquier lenguaje?

**¡Sí!** El sistema es agnóstico al lenguaje. Funciona con:
- Node.js / JavaScript
- Python / Django / Flask
- PHP / Laravel / Symfony
- Ruby / Rails
- Go
- Rust
- Java / Spring
- Y cualquier otro

### ¿Necesito Node.js o npm?

**No.** Solo necesitas:
- Bash (viene en Linux/macOS)
- Git
- Python 3 (para el consultor interactivo)

### ¿Funciona en Windows?

Sí, pero necesitas:
- Git Bash o WSL (Windows Subsystem for Linux)
- Python 3

## 🆘 Problemas Comunes

### "command not found: ./scripts/workflow"

**Solución:**
```bash
chmod +x scripts/*
```

### "No module named 'yaml'"

**Solución:**
```bash
pip3 install pyyaml
```

### "Permission denied"

**Solución:**
```bash
chmod +x install.sh
bash install.sh
```

## 📖 Documentación Completa

Después de instalar, lee:

1. **QUICKSTART.md** - Tutorial de 5 minutos
2. **README.md** - Documentación completa
3. **CHEATSHEET.md** - Comandos rápidos
4. **INSTALLATION.md** - Guía detallada de instalación

## 🎉 ¡Eso es Todo!

Con estos pasos ya tienes el sistema instalado y listo para usar múltiples instancias de Claude Code en paralelo.

**Siguiente paso**: Lee `QUICKSTART.md` o ejecuta `./scripts/workflow consult`

---

**¿Dudas?** Revisa `INSTALLATION.md` para más detalles.
