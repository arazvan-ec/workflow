#!/usr/bin/env python3
"""
ai_consultant.py - AI-Powered Project Consultant

Uses Claude CLI to intelligently analyze projects and recommend workflows.
Supports both existing projects and new project creation.

Usage:
    ./.ai/workflow/scripts/ai_consultant.py [--interactive] [--batch] [--new-project]

Modes:
    --interactive   Ask questions during consultation (default)
    --batch         Generate recommendations without questions
    --new-project   Guide creation of a new project from scratch

Examples:
    ./.ai/workflow/scripts/ai_consultant.py                    # Interactive mode
    ./.ai/workflow/scripts/ai_consultant.py --batch            # No questions, auto-detect
    ./.ai/workflow/scripts/ai_consultant.py --new-project      # Create new project
"""

import sys
import os
import subprocess
import json
import yaml
from pathlib import Path
from datetime import datetime
import argparse
import tempfile

# Colors for terminal output
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
CYAN = '\033[0;36m'
MAGENTA = '\033[0;35m'
NC = '\033[0m'  # No Color

def info(msg):
    print(f"{BLUE}info{NC} {msg}")

def success(msg):
    print(f"{GREEN}success{NC} {msg}")

def error(msg):
    print(f"{RED}error{NC} {msg}")

def warn(msg):
    print(f"{YELLOW}warn{NC} {msg}")

def header(msg):
    print(f"\n{MAGENTA}{'='*60}{NC}")
    print(f"{MAGENTA}{msg:^60}{NC}")
    print(f"{MAGENTA}{'='*60}{NC}\n")


class ProjectAnalyzer:
    """Analyzes project structure and gathers context for Claude"""

    def __init__(self, project_path: str = "."):
        self.project_path = Path(project_path).resolve()
        self.context = {
            "project_exists": False,
            "detected_files": [],
            "frameworks": [],
            "structure": {},
            "config_exists": False,
            "existing_config": None
        }

    def analyze(self) -> dict:
        """Perform full project analysis"""
        self._check_project_exists()
        self._scan_files()
        self._detect_frameworks()
        self._analyze_structure()
        self._load_existing_config()
        return self.context

    def _check_project_exists(self):
        """Check if this is an existing project or empty directory"""
        important_files = [
            'composer.json', 'package.json', 'requirements.txt',
            'Cargo.toml', 'go.mod', 'pom.xml', 'build.gradle',
            'README.md', 'src', 'app', 'lib'
        ]
        for f in important_files:
            if (self.project_path / f).exists():
                self.context["project_exists"] = True
                break

    def _scan_files(self):
        """Scan for important files"""
        files_to_check = [
            # Package managers
            'composer.json', 'package.json', 'requirements.txt',
            'Pipfile', 'pyproject.toml', 'Cargo.toml', 'go.mod',
            'pom.xml', 'build.gradle', 'Gemfile',
            # Config files
            '.env', '.env.example', 'docker-compose.yml', 'Dockerfile',
            'Makefile', 'webpack.config.js', 'vite.config.ts',
            'tsconfig.json', 'jest.config.js', 'phpunit.xml',
            # Documentation
            'README.md', 'CHANGELOG.md', 'docs/',
            # Framework-specific
            'symfony.lock', 'artisan', 'manage.py',
            'next.config.js', 'nuxt.config.js', 'angular.json'
        ]

        for f in files_to_check:
            path = self.project_path / f
            if path.exists():
                self.context["detected_files"].append(f)

    def _detect_frameworks(self):
        """Detect frameworks based on files"""
        frameworks = []
        files = self.context["detected_files"]

        # Backend frameworks
        if 'symfony.lock' in files or 'config/bundles.php' in self._list_files():
            frameworks.append({'name': 'Symfony', 'type': 'backend', 'language': 'PHP'})
        elif 'artisan' in files:
            frameworks.append({'name': 'Laravel', 'type': 'backend', 'language': 'PHP'})
        elif 'manage.py' in files:
            frameworks.append({'name': 'Django', 'type': 'backend', 'language': 'Python'})
        elif 'requirements.txt' in files and self._check_file_contains('requirements.txt', 'fastapi'):
            frameworks.append({'name': 'FastAPI', 'type': 'backend', 'language': 'Python'})
        elif 'requirements.txt' in files and self._check_file_contains('requirements.txt', 'flask'):
            frameworks.append({'name': 'Flask', 'type': 'backend', 'language': 'Python'})
        elif 'package.json' in files and self._check_file_contains('package.json', 'express'):
            frameworks.append({'name': 'Express', 'type': 'backend', 'language': 'Node.js'})
        elif 'package.json' in files and self._check_file_contains('package.json', 'nestjs'):
            frameworks.append({'name': 'NestJS', 'type': 'backend', 'language': 'Node.js'})
        elif 'go.mod' in files:
            frameworks.append({'name': 'Go', 'type': 'backend', 'language': 'Go'})
        elif 'Cargo.toml' in files:
            frameworks.append({'name': 'Rust', 'type': 'backend', 'language': 'Rust'})

        # Frontend frameworks
        if 'package.json' in files:
            if self._check_file_contains('package.json', '"react"'):
                if self._check_file_contains('package.json', 'next'):
                    frameworks.append({'name': 'Next.js', 'type': 'frontend', 'language': 'TypeScript/React'})
                else:
                    frameworks.append({'name': 'React', 'type': 'frontend', 'language': 'TypeScript/React'})
            elif self._check_file_contains('package.json', 'vue'):
                if 'nuxt.config.js' in files:
                    frameworks.append({'name': 'Nuxt', 'type': 'frontend', 'language': 'TypeScript/Vue'})
                else:
                    frameworks.append({'name': 'Vue', 'type': 'frontend', 'language': 'TypeScript/Vue'})
            elif 'angular.json' in files:
                frameworks.append({'name': 'Angular', 'type': 'frontend', 'language': 'TypeScript/Angular'})
            elif self._check_file_contains('package.json', 'svelte'):
                frameworks.append({'name': 'Svelte', 'type': 'frontend', 'language': 'TypeScript/Svelte'})

        self.context["frameworks"] = frameworks

    def _analyze_structure(self):
        """Analyze directory structure"""
        structure = {
            "has_backend": False,
            "has_frontend": False,
            "has_tests": False,
            "has_docs": False,
            "has_ci": False,
            "directories": []
        }

        # Check common directories
        dirs_to_check = ['src', 'app', 'lib', 'backend', 'frontend', 'api',
                         'tests', 'test', 'spec', 'docs', 'documentation',
                         '.github', '.gitlab-ci', 'config', 'public']

        for d in dirs_to_check:
            if (self.project_path / d).is_dir():
                structure["directories"].append(d)

        # Determine project type
        if any(d in structure["directories"] for d in ['backend', 'api', 'server']):
            structure["has_backend"] = True
        if any(d in structure["directories"] for d in ['frontend', 'client', 'web', 'app']):
            structure["has_frontend"] = True
        if any(d in structure["directories"] for d in ['tests', 'test', 'spec', '__tests__']):
            structure["has_tests"] = True
        if any(d in structure["directories"] for d in ['docs', 'documentation']):
            structure["has_docs"] = True
        if any(d in structure["directories"] for d in ['.github', '.gitlab-ci']):
            structure["has_ci"] = True

        # Check for monorepo or single project
        if 'backend' in structure["directories"] and 'frontend' in structure["directories"]:
            structure["type"] = "monorepo"
        elif structure["has_backend"] and not structure["has_frontend"]:
            structure["type"] = "backend-only"
        elif structure["has_frontend"] and not structure["has_backend"]:
            structure["type"] = "frontend-only"
        else:
            structure["type"] = "unknown"

        self.context["structure"] = structure

    def _load_existing_config(self):
        """Load existing config.yaml if present"""
        config_path = self.project_path / '.ai' / 'project' / 'config.yaml'
        if config_path.exists():
            self.context["config_exists"] = True
            with open(config_path, 'r') as f:
                self.context["existing_config"] = yaml.safe_load(f)

    def _list_files(self) -> list:
        """List all files in project (first 2 levels)"""
        files = []
        for item in self.project_path.iterdir():
            if item.is_file():
                files.append(item.name)
            elif item.is_dir() and not item.name.startswith('.'):
                for subitem in item.iterdir():
                    if subitem.is_file():
                        files.append(f"{item.name}/{subitem.name}")
        return files

    def _check_file_contains(self, filename: str, search: str) -> bool:
        """Check if a file contains a string"""
        filepath = self.project_path / filename
        if filepath.exists():
            try:
                with open(filepath, 'r') as f:
                    return search.lower() in f.read().lower()
            except:
                return False
        return False

    def to_context_string(self) -> str:
        """Convert context to string for Claude"""
        lines = []

        if self.context["project_exists"]:
            lines.append("## Project Status: EXISTING PROJECT")
        else:
            lines.append("## Project Status: NEW PROJECT (empty or minimal)")

        lines.append(f"\n## Project Path: {self.project_path}")

        if self.context["detected_files"]:
            lines.append("\n## Detected Files:")
            for f in self.context["detected_files"]:
                lines.append(f"  - {f}")

        if self.context["frameworks"]:
            lines.append("\n## Detected Frameworks:")
            for fw in self.context["frameworks"]:
                lines.append(f"  - {fw['name']} ({fw['type']}, {fw['language']})")

        if self.context["structure"]["directories"]:
            lines.append("\n## Directory Structure:")
            for d in self.context["structure"]["directories"]:
                lines.append(f"  - {d}/")
            lines.append(f"\n  Project Type: {self.context['structure']['type']}")

        if self.context["config_exists"]:
            lines.append("\n## Existing Configuration:")
            lines.append(f"  Config found at .ai/project/config.yaml")
            if self.context["existing_config"]:
                lines.append(f"  Project Name: {self.context['existing_config'].get('project', {}).get('name', 'N/A')}")

        return "\n".join(lines)


class AIConsultant:
    """AI-powered project consultant using Claude CLI"""

    def __init__(self, mode: str = "interactive", new_project: bool = False):
        self.mode = mode  # "interactive" or "batch"
        self.new_project = new_project
        self.analyzer = ProjectAnalyzer()
        self.workflow_path = Path(__file__).parent.parent
        self.project_path = Path.cwd()

    def run(self):
        """Run the consultation process"""
        header("AI Project Consultant")

        # Step 1: Gather context
        info("Gathering project context...")
        context = self.analyzer.analyze()
        context_str = self.analyzer.to_context_string()

        if context["project_exists"]:
            success(f"Detected existing project with {len(context['frameworks'])} framework(s)")
        else:
            if self.new_project:
                info("New project mode - will guide you through setup")
            else:
                warn("No existing project detected. Use --new-project to create one.")

        print(f"\n{CYAN}--- Project Context ---{NC}")
        print(context_str)
        print(f"{CYAN}------------------------{NC}\n")

        # Step 2: Prepare Claude prompt
        system_prompt = self._build_system_prompt(context_str)
        user_prompt = self._build_user_prompt()

        # Step 3: Invoke Claude
        info("Starting AI consultation...")
        print(f"\n{YELLOW}Claude will now analyze your project and provide recommendations.{NC}")

        if self.mode == "interactive":
            print(f"{YELLOW}You can ask questions and Claude will guide you through the setup.{NC}")
            print(f"{YELLOW}Type 'done' when you're satisfied with the configuration.{NC}\n")

        # Create prompt file for Claude
        prompt_file = self._create_prompt_file(system_prompt, user_prompt)

        # Run Claude
        self._run_claude(prompt_file, system_prompt)

        # Cleanup
        os.unlink(prompt_file)

    def _build_system_prompt(self, context_str: str) -> str:
        """Build the system prompt for Claude"""

        # Read available workflows
        workflows_info = self._get_workflows_info()

        return f"""You are an AI Project Consultant for the Claude Code Workflow System.
Your role is to analyze projects and recommend the optimal workflow configuration.

## Your Capabilities
1. Analyze existing projects (detect patterns, architecture, tech stack)
2. Guide new project creation (recommend structure, frameworks, architecture)
3. Configure the workflow system for the project
4. Generate configuration files (config.yaml, context.md)

## Current Project Context
{context_str}

## Available Workflows
{workflows_info}

## Available Roles
- **Planner**: Senior architect who creates detailed specifications
- **Backend**: Backend engineer implementing APIs and business logic
- **Frontend**: Frontend engineer implementing UI and UX
- **QA**: Quality assurance reviewing and testing

## Your Tasks Based on Mode

### For EXISTING Projects:
1. Analyze the detected frameworks and structure
2. Identify existing patterns (DDD, MVC, etc.)
3. Recommend the best workflow for new features
4. Suggest project-specific rules based on what you see
5. Generate config.yaml and context.md

### For NEW Projects:
1. Ask about project requirements (what does it need to do?)
2. Recommend tech stack (backend, frontend, database)
3. Recommend architecture (DDD, Clean Architecture, MVC)
4. Create directory structure
5. Generate initial config.yaml and context.md
6. Provide commands to initialize the project

## Output Format

When you're ready to generate configuration, output the following markers:

```yaml CONFIG_START
# Your generated config.yaml content here
CONFIG_END```

```markdown CONTEXT_START
# Your generated context.md content here
CONTEXT_END```

## Guidelines
- Be concise but thorough
- Explain your reasoning
- Reference existing code when analyzing
- For new projects, ask clarifying questions
- Always provide actionable next steps
- If in batch mode, make reasonable assumptions
- If in interactive mode, ask questions to clarify requirements

## Mode
Current mode: {"INTERACTIVE - Ask questions as needed" if self.mode == "interactive" else "BATCH - Make reasonable assumptions, minimize questions"}
New project: {"YES - Guide creation of new project" if self.new_project else "NO - Analyze existing project"}
"""

    def _build_user_prompt(self) -> str:
        """Build the initial user prompt"""
        if self.new_project:
            return """I want to create a new project. Please help me:
1. Understand my requirements (ask me questions)
2. Recommend the best tech stack and architecture
3. Set up the directory structure
4. Configure the workflow system

Let's start - what kind of project do I want to build?"""
        else:
            if self.mode == "batch":
                return """Analyze this project and generate:
1. config.yaml with detected settings
2. context.md with project awareness
3. Recommended workflow for new features
4. Any specific rules based on detected patterns

Output the configuration files directly."""
            else:
                return """Please analyze this project and help me configure the workflow system.
I'd like you to:
1. Tell me what you detected about the project
2. Ask any clarifying questions
3. Recommend the best workflow
4. Generate the configuration files

Let's start with your analysis."""

    def _get_workflows_info(self) -> str:
        """Get information about available workflows"""
        workflows_dir = self.workflow_path / 'workflows'
        info_lines = []

        if workflows_dir.exists():
            for wf_file in workflows_dir.glob('*.yaml'):
                try:
                    with open(wf_file, 'r') as f:
                        wf = yaml.safe_load(f)
                        name = wf.get('name', wf_file.stem)
                        desc = wf.get('description', 'No description')
                        # Truncate description
                        if len(desc) > 200:
                            desc = desc[:200] + "..."
                        info_lines.append(f"- **{wf_file.stem}**: {name}\n  {desc}")
                except:
                    info_lines.append(f"- **{wf_file.stem}**: (Could not read)")

        return "\n".join(info_lines) if info_lines else "No workflows found"

    def _create_prompt_file(self, system_prompt: str, user_prompt: str) -> str:
        """Create a temporary file with the prompt"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(user_prompt)
            return f.name

    def _run_claude(self, prompt_file: str, system_prompt: str):
        """Run Claude CLI with the prompt"""
        # Create system prompt file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
            f.write(system_prompt)
            system_file = f.name

        try:
            # Build claude command
            cmd = ['claude', '--system-prompt', system_file]

            if self.mode == "batch":
                # In batch mode, pipe the prompt and don't use interactive mode
                cmd.extend(['--print'])
                with open(prompt_file, 'r') as f:
                    prompt_content = f.read()

                # Run claude with piped input
                result = subprocess.run(
                    cmd,
                    input=prompt_content,
                    text=True,
                    capture_output=True
                )

                print(result.stdout)
                if result.stderr:
                    print(result.stderr, file=sys.stderr)

                # Parse and save outputs
                self._parse_and_save_outputs(result.stdout)
            else:
                # Interactive mode - just start claude with system prompt
                # Read the prompt file content
                with open(prompt_file, 'r') as f:
                    prompt_content = f.read()

                # Start interactive Claude session
                # We'll pipe the initial prompt but allow interaction
                process = subprocess.Popen(
                    cmd,
                    stdin=subprocess.PIPE,
                    text=True
                )

                # Send initial prompt
                process.communicate(input=prompt_content)

        finally:
            os.unlink(system_file)

    def _parse_and_save_outputs(self, output: str):
        """Parse Claude's output and save config files"""
        # Parse config.yaml
        config_match = self._extract_between(output, 'CONFIG_START', 'CONFIG_END')
        if config_match:
            config_path = self.project_path / '.ai' / 'project' / 'config.yaml'
            config_path.parent.mkdir(parents=True, exist_ok=True)
            with open(config_path, 'w') as f:
                f.write(config_match.strip())
            success(f"Generated: {config_path}")

        # Parse context.md
        context_match = self._extract_between(output, 'CONTEXT_START', 'CONTEXT_END')
        if context_match:
            context_path = self.project_path / '.ai' / 'project' / 'context.md'
            context_path.parent.mkdir(parents=True, exist_ok=True)
            with open(context_path, 'w') as f:
                f.write(context_match.strip())
            success(f"Generated: {context_path}")

    def _extract_between(self, text: str, start_marker: str, end_marker: str) -> str:
        """Extract text between two markers"""
        try:
            start = text.index(start_marker) + len(start_marker)
            end = text.index(end_marker)
            return text[start:end]
        except ValueError:
            return ""


def main():
    parser = argparse.ArgumentParser(
        description='AI-Powered Project Consultant',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                     Interactive consultation for existing project
  %(prog)s --batch             Auto-detect and generate config without questions
  %(prog)s --new-project       Guide creation of a new project
  %(prog)s --new-project --batch  Create new project with reasonable defaults
        """
    )

    parser.add_argument(
        '--interactive', '-i',
        action='store_true',
        default=True,
        help='Interactive mode with questions (default)'
    )

    parser.add_argument(
        '--batch', '-b',
        action='store_true',
        help='Batch mode without questions'
    )

    parser.add_argument(
        '--new-project', '-n',
        action='store_true',
        help='Create a new project from scratch'
    )

    args = parser.parse_args()

    # Determine mode
    mode = "batch" if args.batch else "interactive"

    # Check if claude CLI is available
    try:
        subprocess.run(['claude', '--version'], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        error("Claude CLI not found. Please install it first.")
        error("Visit: https://docs.anthropic.com/en/docs/claude-cli")
        sys.exit(1)

    # Run consultant
    consultant = AIConsultant(mode=mode, new_project=args.new_project)
    consultant.run()


if __name__ == "__main__":
    main()
