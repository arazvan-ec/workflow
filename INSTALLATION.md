# Installation Guide

Guía completa de instalación del Claude Code Parallel Workflow System.

## 📦 Métodos de Instalación

### Método 1: Instalador Auto-Contenido (⭐ RECOMENDADO)

El instalador auto-contenido incluye todos los archivos necesarios en un solo script.

#### Opción A: Desde el repositorio local

Si tienes el repositorio clonado:

```bash
# 1. Genera el instalador (solo necesitas hacerlo una vez)
cd /path/to/workflow
./scripts/generate-installer

# 2. Copia el instalador a tu proyecto
cp install-workflow.sh /path/to/tu-proyecto/

# 3. Ejecuta el instalador en tu proyecto
cd /path/to/tu-proyecto
bash install-workflow.sh
```

#### Opción B: Descarga directa (cuando esté disponible)

```bash
cd /path/to/tu-proyecto
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/workflow/main/install-workflow.sh -o install-workflow.sh
bash install-workflow.sh
```

O en un solo comando:

```bash
cd /path/to/tu-proyecto
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USER/workflow/main/install-workflow.sh)
```

### Método 2: Instalador desde Repositorio Local

Si tienes el repositorio workflow clonado localmente:

```bash
# Desde tu proyecto
cd /path/to/tu-proyecto

# Ejecuta el instalador desde el repo workflow
bash /path/to/workflow/install.sh
```

El script:
- ✅ Copia todos los archivos necesarios
- ✅ Crea la estructura de directorios
- ✅ Instala dependencias (PyYAML)
- ✅ Inicializa Git si es necesario
- ✅ Crea commit inicial

### Método 3: Copia Manual

Para mayor control, puedes copiar los archivos manualmente:

```bash
cd /path/to/tu-proyecto

# Copiar estructura principal
cp -r /path/to/workflow/ai ./
cp -r /path/to/workflow/scripts ./
cp -r /path/to/workflow/hooks ./

# Copiar documentación
cp /path/to/workflow/README.md ./
cp /path/to/workflow/QUICKSTART.md ./
cp /path/to/workflow/CHEATSHEET.md ./
cp /path/to/workflow/SUMMARY.md ./
cp /path/to/workflow/.gitignore ./

# Hacer scripts ejecutables
chmod +x scripts/*

# Instalar dependencias
pip3 install pyyaml
```

### Método 4: Como Template de GitHub

Si el repositorio está en GitHub, puedes usarlo como template:

1. Ve a https://github.com/YOUR_USER/workflow
2. Click en "Use this template"
3. Crea tu nuevo repositorio
4. Clona tu nuevo repositorio

```bash
git clone https://github.com/YOUR_USER/your-new-project.git
cd your-new-project
./scripts/workflow consult
```

## 🔧 Post-Instalación

Después de instalar, verifica que todo funciona:

```bash
# Ver features disponibles
./scripts/workflow list

# Ver estado del ejemplo
./scripts/workflow status example-todo-api

# Validar el sistema
./scripts/workflow validate

# Ejecutar consultor
./scripts/workflow consult
```

## 📋 Requisitos

### Mínimos

- **Bash** 4.0+ (Linux/macOS tienen esto por defecto)
- **Git** 2.0+
- **Python 3.6+** con pip3 (para workflow-consultant)

### Recomendados

- **PyYAML** - Para el consultor interactivo
  ```bash
  pip3 install pyyaml
  ```

- **Tilix** (Linux) - Para trabajar con múltiples panes
  ```bash
  # Ubuntu/Debian
  sudo apt install tilix

  # Fedora
  sudo dnf install tilix

  # Arch
  sudo pacman -S tilix
  ```

- **iTerm2** (macOS) - Alternativa a Tilix en macOS

## 🔍 Verificación de Instalación

### Check 1: Archivos Principales

```bash
ls -la ai/
# Debe mostrar: PROJECT.md, CONSTRAINTS.md, DECISIONS.md, workflows/, features/

ls -la scripts/
# Debe mostrar: workflow, workflow-consultant, setup-project
```

### Check 2: Scripts Ejecutables

```bash
./scripts/workflow help
# Debe mostrar la ayuda del comando

./scripts/workflow list
# Debe mostrar: example-todo-api [active]
```

### Check 3: Python y PyYAML

```bash
python3 -c "import yaml; print('PyYAML OK')"
# Debe imprimir: PyYAML OK
```

Si falla:
```bash
pip3 install pyyaml
# o
pip3 install --user pyyaml
```

### Check 4: Consultor Interactivo

```bash
./scripts/workflow-consultant
# Debe iniciar el consultor con preguntas
# Puedes cancelar con Ctrl+C
```

## 🚨 Troubleshooting

### Error: "command not found"

**Problema**: Scripts no son ejecutables

**Solución**:
```bash
chmod +x scripts/*
```

### Error: "No module named 'yaml'"

**Problema**: PyYAML no está instalado

**Solución**:
```bash
pip3 install pyyaml
# o
pip3 install --user pyyaml
```

### Error: "ai/ directory already exists"

**Problema**: Ya existe una instalación previa

**Solución**:
```bash
# Opción A: Hacer backup
mv ai/ ai.backup.$(date +%Y%m%d)
# Luego reinstalar

# Opción B: Eliminar si no necesitas el backup
rm -rf ai/
# Luego reinstalar
```

### Error: Git push failed

**Problema**: Rama no existe en remoto

**Solución**:
```bash
git push -u origin nombre-de-tu-rama
```

## 🎨 Personalización Post-Instalación

### 1. Actualizar PROJECT.md

Edita `ai/PROJECT.md` con la información de tu proyecto:

```bash
vim ai/PROJECT.md
```

### 2. Agregar tus propias restricciones

Edita `ai/CONSTRAINTS.md` con reglas específicas de tu proyecto.

### 3. Crear templates personalizados

```bash
cp ai/workflows/feature_template.yaml ai/workflows/my_custom_template.yaml
vim ai/workflows/my_custom_template.yaml
```

### 4. Instalar Git hooks

```bash
cp hooks/pre-commit.example .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## 🔄 Actualización del Sistema

Si hay actualizaciones del workflow system:

```bash
# Opción 1: Re-ejecutar el instalador
# (hará backup automático)
bash install-workflow.sh

# Opción 2: Pull manual si usas como submodule
git submodule update --remote

# Opción 3: Copiar archivos específicos actualizados
cp /path/to/workflow/scripts/workflow ./scripts/
cp /path/to/workflow/ai/workflows/new_template.yaml ./ai/workflows/
```

## 📦 Desinstalación

Si necesitas remover el sistema:

```bash
# Eliminar archivos del workflow
rm -rf ai/
rm -rf scripts/
rm -rf hooks/
rm README.md QUICKSTART.md CHEATSHEET.md SUMMARY.md

# O hacer backup antes de eliminar
tar -czf workflow-backup.tar.gz ai/ scripts/ hooks/ *.md
rm -rf ai/ scripts/ hooks/ README.md QUICKSTART.md CHEATSHEET.md SUMMARY.md
```

## 💡 Siguientes Pasos

Después de instalar:

1. **Lee el Quick Start**
   ```bash
   cat QUICKSTART.md
   ```

2. **Prueba el ejemplo**
   ```bash
   cat ai/features/example-todo-api/EXAMPLE_USAGE.md
   ```

3. **Crea tu primer workflow**
   ```bash
   ./scripts/workflow consult
   ```

4. **Lee la documentación completa**
   ```bash
   cat README.md
   ```

## 🤝 Instalación en Equipo

Si trabajas en equipo:

### Responsable del Setup:

```bash
# 1. Instalar el sistema
bash install-workflow.sh

# 2. Commit y push
git add .
git commit -m "feat: Add workflow system"
git push
```

### Miembros del Equipo:

```bash
# 1. Pull del repositorio
git pull

# 2. Instalar dependencias
pip3 install pyyaml

# 3. Verificar instalación
./scripts/workflow list
```

## 📖 Recursos Adicionales

- **README.md** - Documentación principal
- **QUICKSTART.md** - Tutorial de 5 minutos
- **CHEATSHEET.md** - Referencia rápida
- **SUMMARY.md** - Resumen del sistema
- **ai/workflows/README.md** - Formato de workflows

---

**¿Problemas con la instalación?** Revisa los requisitos y troubleshooting arriba, o consulta la documentación completa.
