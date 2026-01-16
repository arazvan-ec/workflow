#!/usr/bin/env python3
"""
suggest_workflow.py - Consultor inteligente para configurar proyecto y sugerir workflow

Detecta el tipo de proyecto, pregunta sobre frontend, y configura todo.

Uso:
    ./.ai/workflow/scripts/suggest_workflow.py
    ./workflow consult
"""

import os
import sys
import yaml
from datetime import datetime
from pathlib import Path

# Colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
CYAN = '\033[0;36m'
MAGENTA = '\033[0;35m'
BOLD = '\033[1m'
NC = '\033[0m'

# Paths (relative to project root)
WORKFLOW_DIR = ".ai/workflow"
PROJECT_DIR = ".ai/project"
CONFIG_FILE = f"{PROJECT_DIR}/config.yaml"
FEATURES_DIR = f"{PROJECT_DIR}/features"

def info(msg):
    print(f"{BLUE}ℹ{NC} {msg}")

def success(msg):
    print(f"{GREEN}✓{NC} {msg}")

def warn(msg):
    print(f"{YELLOW}⚠{NC} {msg}")

def error(msg):
    print(f"{RED}✗{NC} {msg}")

def question(msg, default=None):
    if default:
        prompt = f"{CYAN}?{NC} {msg} [{default}]: "
    else:
        prompt = f"{CYAN}?{NC} {msg}: "
    answer = input(prompt).strip()
    return answer if answer else default

def question_choice(msg, options, default=None):
    """Ask a multiple choice question"""
    print(f"\n{CYAN}{msg}{NC}")
    for key, value in options.items():
        marker = f" {YELLOW}(default){NC}" if key == default else ""
        print(f"   {key}) {value}{marker}")

    while True:
        answer = question("Your choice", default)
        if answer and answer.lower() in [k.lower() for k in options.keys()]:
            return answer.lower()
        error(f"Invalid choice. Please enter one of: {', '.join(options.keys())}")

def print_header(text):
    width = 60
    print(f"\n{CYAN}╔{'═'*width}╗{NC}")
    print(f"{CYAN}║{NC}{BOLD}{text.center(width)}{NC}{CYAN}║{NC}")
    print(f"{CYAN}╚{'═'*width}╝{NC}\n")

def print_section(text):
    print(f"\n{CYAN}━━━ {text} ━━━{NC}\n")

# =============================================================================
# PROJECT DETECTION
# =============================================================================

def detect_project_type():
    """Detect project type based on files in current directory"""

    detections = []

    # PHP / Symfony
    if os.path.exists("composer.json"):
        try:
            with open("composer.json", "r") as f:
                composer = f.read()
                if "symfony/framework-bundle" in composer:
                    detections.append(("symfony", "php", "Symfony framework detected (composer.json)"))
                elif "laravel/framework" in composer:
                    detections.append(("laravel", "php", "Laravel framework detected (composer.json)"))
                else:
                    detections.append(("php", "php", "PHP project detected (composer.json)"))
        except:
            detections.append(("php", "php", "PHP project detected (composer.json)"))

    # Node.js / JavaScript
    if os.path.exists("package.json"):
        try:
            with open("package.json", "r") as f:
                package = f.read()
                if "next" in package:
                    detections.append(("nextjs", "node", "Next.js detected (package.json)"))
                elif "react" in package:
                    detections.append(("react", "node", "React detected (package.json)"))
                elif "vue" in package:
                    detections.append(("vue", "node", "Vue.js detected (package.json)"))
                elif "angular" in package:
                    detections.append(("angular", "node", "Angular detected (package.json)"))
                elif "express" in package:
                    detections.append(("express", "node", "Express.js detected (package.json)"))
                elif "fastify" in package:
                    detections.append(("fastify", "node", "Fastify detected (package.json)"))
                else:
                    detections.append(("node", "node", "Node.js project detected (package.json)"))
        except:
            detections.append(("node", "node", "Node.js project detected (package.json)"))

    # Python
    if os.path.exists("requirements.txt") or os.path.exists("pyproject.toml"):
        try:
            content = ""
            if os.path.exists("requirements.txt"):
                with open("requirements.txt", "r") as f:
                    content = f.read()
            elif os.path.exists("pyproject.toml"):
                with open("pyproject.toml", "r") as f:
                    content = f.read()

            if "django" in content.lower():
                detections.append(("django", "python", "Django detected"))
            elif "fastapi" in content.lower():
                detections.append(("fastapi", "python", "FastAPI detected"))
            elif "flask" in content.lower():
                detections.append(("flask", "python", "Flask detected"))
            else:
                detections.append(("python", "python", "Python project detected"))
        except:
            detections.append(("python", "python", "Python project detected"))

    # Go
    if os.path.exists("go.mod"):
        detections.append(("go", "go", "Go project detected (go.mod)"))

    # Rust
    if os.path.exists("Cargo.toml"):
        detections.append(("rust", "rust", "Rust project detected (Cargo.toml)"))

    # Java / Kotlin
    if os.path.exists("pom.xml"):
        detections.append(("maven", "java", "Maven project detected (pom.xml)"))
    elif os.path.exists("build.gradle") or os.path.exists("build.gradle.kts"):
        detections.append(("gradle", "java", "Gradle project detected"))

    return detections

def detect_existing_frontend():
    """Check if frontend already exists in common locations"""
    frontend_dirs = ["frontend", "frontend1", "frontend2", "client", "web", "app"]

    for dir_name in frontend_dirs:
        if os.path.isdir(dir_name):
            package_json = os.path.join(dir_name, "package.json")
            if os.path.exists(package_json):
                try:
                    with open(package_json, "r") as f:
                        content = f.read()
                        if "react" in content:
                            return (dir_name, "react")
                        elif "vue" in content:
                            return (dir_name, "vue")
                        elif "angular" in content:
                            return (dir_name, "angular")
                        else:
                            return (dir_name, "unknown")
                except:
                    return (dir_name, "unknown")

    return None

# =============================================================================
# CONFIGURATION
# =============================================================================

def load_config():
    """Load existing config or return empty dict"""
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r") as f:
                return yaml.safe_load(f) or {}
        except:
            return {}
    return {}

def save_config(config):
    """Save config to YAML file"""
    os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)

    config["metadata"] = config.get("metadata", {})
    config["metadata"]["updated"] = datetime.now().isoformat()
    if not config["metadata"].get("created"):
        config["metadata"]["created"] = datetime.now().isoformat()

    with open(CONFIG_FILE, "w") as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False, allow_unicode=True)

    success(f"Configuration saved to {CONFIG_FILE}")

# =============================================================================
# MAIN WORKFLOW
# =============================================================================

def run_consultant():
    """Main consultant workflow"""

    print_header("CLAUDE CODE WORKFLOW CONSULTANT")

    info("Analyzing your project...\n")

    # Load existing config
    config = load_config()

    # ==========================================================================
    # STEP 1: Detect project type
    # ==========================================================================
    print_section("1. PROJECT DETECTION")

    detections = detect_project_type()

    if detections:
        for framework, language, message in detections:
            success(message)

        # Use first detection as primary
        primary_framework, primary_language, _ = detections[0]

        # Confirm or override
        print(f"\n{CYAN}Detected: {GREEN}{primary_framework}{NC} ({primary_language})")
        confirm = question("Is this correct? (y/n)", "y")

        if confirm.lower() != "y":
            primary_framework = question("Enter framework (symfony/laravel/express/fastapi/etc)")
            primary_language = question("Enter language (php/node/python/go/etc)")
    else:
        warn("Could not auto-detect project type")
        primary_framework = question("Enter framework (symfony/laravel/express/fastapi/etc)")
        primary_language = question("Enter language (php/node/python/go/etc)")

    # Update config
    config["project"] = config.get("project", {})
    config["backend"] = config.get("backend", {})
    config["backend"]["framework"] = primary_framework
    config["backend"]["language"] = primary_language
    config["backend"]["enabled"] = True
    config["backend"]["path"] = "."

    success(f"Backend configured: {primary_framework} ({primary_language})")

    # ==========================================================================
    # STEP 2: Ask about frontend
    # ==========================================================================
    print_section("2. FRONTEND CONFIGURATION")

    # Check for existing frontend
    existing_frontend = detect_existing_frontend()

    if existing_frontend:
        dir_name, framework = existing_frontend
        success(f"Existing frontend detected: {dir_name}/ ({framework})")
        use_existing = question("Use this frontend? (y/n)", "y")

        if use_existing.lower() == "y":
            config["frontend"] = {
                "enabled": True,
                "location": "same",
                "path": dir_name,
                "framework": framework
            }
            success(f"Frontend configured: {dir_name}/")
        else:
            existing_frontend = None

    if not existing_frontend:
        needs_frontend = question_choice(
            "Does this project need a frontend?",
            {
                "a": "Yes, in this same project",
                "b": "Yes, in a separate project/repo",
                "c": "No, backend only (API)"
            },
            default="c"
        )

        if needs_frontend == "a":
            # Frontend in same project
            frontend_path = question("Frontend directory name", "frontend")
            frontend_framework = question_choice(
                "Frontend framework?",
                {
                    "a": "React",
                    "b": "Vue.js",
                    "c": "Angular",
                    "d": "Next.js",
                    "e": "Other"
                },
                default="a"
            )

            framework_map = {"a": "react", "b": "vue", "c": "angular", "d": "nextjs", "e": "other"}

            config["frontend"] = {
                "enabled": True,
                "location": "same",
                "path": frontend_path,
                "framework": framework_map[frontend_framework]
            }

            # Create frontend directory if it doesn't exist
            if not os.path.exists(frontend_path):
                os.makedirs(frontend_path, exist_ok=True)
                success(f"Created directory: {frontend_path}/")

            success(f"Frontend configured: {frontend_path}/ ({framework_map[frontend_framework]})")

        elif needs_frontend == "b":
            # Frontend in separate project
            frontend_path = question("Full path to frontend project (e.g., /home/user/sportian-frontend)")
            frontend_framework = question("Frontend framework (react/vue/angular)")

            config["frontend"] = {
                "enabled": True,
                "location": "separate",
                "path": frontend_path,
                "framework": frontend_framework
            }

            warn(f"Frontend is in separate project: {frontend_path}")
            info("You'll need to run workflow commands from that project for frontend tasks")

        else:
            # No frontend
            config["frontend"] = {
                "enabled": False,
                "location": None,
                "path": None,
                "framework": None
            }
            success("Configured as backend-only project (API)")

    # ==========================================================================
    # STEP 3: Project name and description
    # ==========================================================================
    print_section("3. PROJECT DETAILS")

    # Get project name from directory if not set
    default_name = config.get("project", {}).get("name") or os.path.basename(os.getcwd())
    project_name = question("Project name", default_name)
    project_description = question("Brief description (optional)", "")

    config["project"]["name"] = project_name
    config["project"]["type"] = primary_framework
    config["project"]["description"] = project_description

    # ==========================================================================
    # STEP 4: Workflow recommendation
    # ==========================================================================
    print_section("4. WORKFLOW RECOMMENDATION")

    # Ask about complexity
    complexity = question_choice(
        "How complex is your typical feature?",
        {
            "a": "Simple (1-2 entities, basic CRUD)",
            "b": "Medium (3-5 entities, some business rules)",
            "c": "Complex (5+ entities, complex business rules, DDD)"
        },
        default="b"
    )

    # Determine recommended workflow
    if complexity == "c":
        recommended_workflow = "task-breakdown"
        workflow_reason = "Complex projects benefit from detailed planning"
    elif complexity == "b":
        recommended_workflow = "task-breakdown"
        workflow_reason = "Medium complexity benefits from upfront planning"
    else:
        recommended_workflow = "default"
        workflow_reason = "Simple projects can use streamlined workflow"

    print(f"\n{GREEN}Recommended workflow: {YELLOW}{recommended_workflow}{NC}")
    print(f"   Reason: {workflow_reason}")

    # Explain workflow options
    print(f"\n{CYAN}Available workflows:{NC}")
    print(f"   {GREEN}task-breakdown{NC} → {YELLOW}implementation-only{NC}")
    print(f"      Best for: Complex features, detailed planning first")
    print(f"      Flow: Planner creates detailed docs → Backend/Frontend implement")
    print(f"")
    print(f"   {GREEN}default{NC}")
    print(f"      Best for: Simple features, quick iterations")
    print(f"      Flow: Planner + Backend + Frontend + QA all at once")

    config["workflow"] = config.get("workflow", {})
    config["workflow"]["default"] = recommended_workflow
    config["workflow"]["complexity"] = complexity

    # ==========================================================================
    # STEP 5: Save configuration
    # ==========================================================================
    print_section("5. SAVE CONFIGURATION")

    save_config(config)

    # ==========================================================================
    # STEP 6: Next steps
    # ==========================================================================
    print_section("6. NEXT STEPS")

    feature_id = question("Enter feature ID to start (e.g., user-auth, sportian-clubs)", "")

    if feature_id:
        # Create feature directory
        feature_dir = f"{FEATURES_DIR}/{feature_id}"
        os.makedirs(feature_dir, exist_ok=True)

        # Create initial 50_state.md
        state_file = f"{feature_dir}/50_state.md"
        if not os.path.exists(state_file):
            state_content = f"""# State: {feature_id}

**Feature**: {feature_id}
**Project**: {project_name}
**Started**: {datetime.now().strftime('%Y-%m-%d')}

---

## 🎭 Planner
**Status**: PENDING
**Progress**: Not started
**Blockers**: None

---

## 💻 Backend
**Status**: PENDING
**Progress**: Waiting for planning
**Blockers**: None

---
"""
            if config["frontend"]["enabled"]:
                state_content += """
## 🎨 Frontend
**Status**: PENDING
**Progress**: Waiting for planning
**Blockers**: None

---
"""
            state_content += """
## ✅ QA
**Status**: PENDING
**Progress**: Waiting for implementation
**Blockers**: None
"""
            with open(state_file, "w") as f:
                f.write(state_content)

            success(f"Created feature directory: {feature_dir}/")
            success(f"Created state file: {state_file}")

        print(f"\n{GREEN}Commands to start:{NC}\n")

        if recommended_workflow == "task-breakdown":
            print(f"  # Step 1: Detailed planning")
            print(f"  {CYAN}./workflow start {feature_id} task-breakdown{NC}")
            print(f"")
            print(f"  # Step 2: Implementation (after planning is done)")
            print(f"  {CYAN}./workflow start {feature_id} implementation-only --execute{NC}")
        else:
            print(f"  # Start all roles")
            print(f"  {CYAN}./workflow start {feature_id} default --execute{NC}")

        print(f"\n  # Or run individual roles:")
        print(f"  {CYAN}./workflow role planner {feature_id}{NC}")
        print(f"  {CYAN}./workflow role backend {feature_id}{NC}")
        if config["frontend"]["enabled"]:
            print(f"  {CYAN}./workflow role frontend {feature_id}{NC}")
        print(f"  {CYAN}./workflow role qa {feature_id}{NC}")

        print(f"\n  # Monitor progress:")
        print(f"  {CYAN}watch -n 5 'cat {feature_dir}/50_state.md'{NC}")

    else:
        print(f"\n{GREEN}When ready to start a feature:{NC}")
        print(f"  {CYAN}./workflow consult{NC}  (run this again)")
        print(f"  or")
        print(f"  {CYAN}./workflow start <feature-id> {recommended_workflow}{NC}")

    print(f"\n{GREEN}Happy coding! 🚀{NC}\n")

def main():
    try:
        run_consultant()
    except KeyboardInterrupt:
        print(f"\n\n{YELLOW}Cancelled by user{NC}")
        sys.exit(1)
    except Exception as e:
        error(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
