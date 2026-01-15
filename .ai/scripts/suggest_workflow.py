#!/usr/bin/env python3
"""
suggest_workflow.py - Consultor inteligente para sugerir workflow según tarea

Hace preguntas sobre la tarea y sugiere el workflow más apropiado.

Uso:
    ./.ai/scripts/suggest_workflow.py
"""

import sys

# Colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
CYAN = '\033[0;36m'
NC = '\033[0m'

def info(msg):
    print(f"{BLUE}ℹ{NC} {msg}")

def success(msg):
    print(f"{GREEN}✓{NC} {msg}")

def question(msg):
    return input(f"{CYAN}?{NC} {msg}: ")

def print_header(text):
    print(f"\n{CYAN}{'='*60}{NC}")
    print(f"{CYAN}{text.center(60)}{NC}")
    print(f"{CYAN}{'='*60}{NC}\n")

def suggest_workflow():
    """Ask questions and suggest appropriate workflow"""

    print_header("WORKFLOW CONSULTANT")

    info("I'll ask you some questions about your task to suggest the best workflow.\n")

    # Question 1: Type of task
    print(f"{CYAN}1. What type of task is this?{NC}")
    print("   a) New feature (full-stack: backend + frontend)")
    print("   b) Backend only")
    print("   c) Frontend only")
    print("   d) Bug fix")
    print("   e) Refactoring")
    task_type = question("Your choice (a/b/c/d/e)").lower()

    # Question 2: Complexity
    print(f"\n{CYAN}2. How complex is this task?{NC}")
    print("   a) Simple (1-2 files, < 1 day)")
    print("   b) Medium (3-10 files, 1-3 days)")
    print("   c) Complex (10+ files, > 3 days, multiple modules)")
    complexity = question("Your choice (a/b/c)").lower()

    # Question 3: Architecture
    print(f"\n{CYAN}3. What architecture pattern will you use?{NC}")
    print("   a) Simple/Standard (no specific pattern)")
    print("   b) DDD (Domain-Driven Design)")
    print("   c) Clean Architecture")
    architecture = question("Your choice (a/b/c)").lower()

    # Question 4: Parallel work
    print(f"\n{CYAN}4. Do you want backend and frontend to work in parallel?{NC}")
    print("   (Frontend can mock API if backend is not ready)")
    parallel = question("Yes/No (y/n)").lower()

    # Question 5: Team
    print(f"\n{CYAN}5. Are you working alone or in a team?{NC}")
    print("   a) Alone (I'll switch between roles)")
    print("   b) Team (different people for different roles)")
    team = question("Your choice (a/b)").lower()

    # Analyze answers and suggest workflow
    print_header("RECOMMENDATION")

    # Determine workflow
    suggested_workflow = "default"
    reasons = []

    if architecture == "b":  # DDD
        suggested_workflow = "ddd_parallel"
        reasons.append("Task uses DDD architecture → DDD Parallel workflow")

    if complexity == "c":  # Complex
        suggested_workflow = "ddd_parallel"
        reasons.append("Task is complex → Better suited for DDD Parallel workflow")

    if task_type in ["b", "c"]:  # Backend or Frontend only
        suggested_workflow = "simple"
        reasons.append("Task is single-stack → Simple workflow is enough")

    if task_type == "d":  # Bug fix
        suggested_workflow = "simple"
        reasons.append("Bug fix → Simple workflow (skip planning)")

    # Print recommendation
    success(f"Suggested workflow: {YELLOW}{suggested_workflow}.yaml{NC}\n")

    print(f"{CYAN}Reasons:{NC}")
    for reason in reasons:
        print(f"  • {reason}")

    # Print workflow details
    print(f"\n{CYAN}Workflow Details:{NC}\n")

    if suggested_workflow == "default":
        print(f"  {GREEN}default.yaml{NC} - Standard feature workflow")
        print(f"    Stages: Planning → Backend → Frontend → QA")
        if parallel == "y":
            print(f"    Note: Backend and Frontend can work in parallel")
        print(f"    Best for: Standard features, full-stack work")

    elif suggested_workflow == "ddd_parallel":
        print(f"  {GREEN}ddd_parallel.yaml{NC} - DDD with parallel layers")
        print(f"    Stages: Planning → (Domain, Application, Infrastructure in parallel) → Integration → QA")
        print(f"    Best for: Complex features, DDD architecture, multiple developers")

    elif suggested_workflow == "simple":
        print(f"  {GREEN}simple.yaml{NC} - Simplified workflow")
        print(f"    Stages: Implementation → QA (skip planning for simple tasks)")
        print(f"    Best for: Bug fixes, single-stack changes, simple features")

    # Print next steps
    print(f"\n{CYAN}Next Steps:{NC}\n")

    feature_id = question("Enter feature ID (e.g., user-auth, fix-login-bug)")

    print(f"\n{GREEN}Commands to run:{NC}\n")
    print(f"  # 1. Initialize feature")
    print(f"  mkdir -p ./.ai/projects/PROJECT_X/features/{feature_id}")
    print(f"  cp ./.ai/projects/PROJECT_X/features/FEATURE_X/50_state.md \\")
    print(f"     ./.ai/projects/PROJECT_X/features/{feature_id}/50_state.md")
    print(f"")
    print(f"  # 2. Start Tilix with roles")
    print(f"  ./.ai/scripts/tilix_start.sh {feature_id} {suggested_workflow}")
    print(f"")
    print(f"  # 3. Monitor progress")
    print(f"  watch -n 5 'cat ./.ai/projects/PROJECT_X/features/{feature_id}/50_state.md'")

    print(f"\n{GREEN}Happy coding! 🚀{NC}\n")

def main():
    try:
        suggest_workflow()
    except KeyboardInterrupt:
        print(f"\n\n{YELLOW}Cancelled by user{NC}")
        sys.exit(1)

if __name__ == "__main__":
    main()
