#!/usr/bin/env python3
"""
validate_workflow.py - Validador automático de workflows

Valida:
- Estructura de archivos requerida
- Format de YAML
- Consistencia de estados
- Completitud de features

Uso:
    ./.ai/scripts/validate_workflow.py [feature-id]
"""

import sys
import os
import yaml
from pathlib import Path

# Colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

def info(msg):
    print(f"{BLUE}ℹ{NC} {msg}")

def success(msg):
    print(f"{GREEN}✓{NC} {msg}")

def error(msg):
    print(f"{RED}✗{NC} {msg}")

def warn(msg):
    print(f"{YELLOW}⚠{NC} {msg}")

def validate_feature(feature_id):
    """Validate a feature"""
    info(f"Validating feature: {feature_id}")

    feature_path = Path(f"./.ai/projects/PROJECT_X/features/{feature_id}")

    if not feature_path.exists():
        error(f"Feature directory not found: {feature_path}")
        return False

    # Check required files
    required_files = [
        "50_state.md",
        f"{feature_id}.md",  # or FEATURE_X.md
    ]

    missing_files = []
    for file in required_files:
        file_path = feature_path / file
        # Try both feature_id.md and FEATURE_X.md
        if not file_path.exists() and file == f"{feature_id}.md":
            file_path = feature_path / "FEATURE_X.md"

        if file_path.exists():
            success(f"Found: {file}")
        else:
            error(f"Missing: {file}")
            missing_files.append(file)

    if missing_files:
        return False

    # Validate state file format
    state_file = feature_path / "50_state.md"
    with open(state_file, 'r') as f:
        content = f.read()

        required_sections = ["Planner", "Backend", "Frontend", "QA"]
        for section in required_sections:
            if section not in content:
                error(f"Missing section in 50_state.md: {section}")
                return False

        success("All required sections found in 50_state.md")

    # Validate workflow YAML if specified
    try:
        # Try to extract workflow name from state file
        with open(state_file, 'r') as f:
            for line in f:
                if line.startswith("**Workflow**:"):
                    workflow_name = line.split(":")[-1].strip()
                    workflow_file = Path(f"./.ai/projects/PROJECT_X/workflows/{workflow_name}")

                    if workflow_file.exists():
                        with open(workflow_file, 'r') as wf:
                            try:
                                yaml.safe_load(wf)
                                success(f"Workflow YAML is valid: {workflow_name}")
                            except yaml.YAMLError as e:
                                error(f"Invalid YAML in {workflow_name}: {e}")
                                return False
                    break
    except Exception as e:
        warn(f"Could not validate workflow YAML: {e}")

    success(f"Feature validation passed: {feature_id}")
    return True

def validate_all():
    """Validate all features"""
    features_dir = Path("./.ai/projects/PROJECT_X/features")

    if not features_dir.exists():
        error("Features directory not found")
        return False

    features = [d.name for d in features_dir.iterdir() if d.is_dir()]

    if not features:
        warn("No features found to validate")
        return True

    info(f"Found {len(features)} feature(s) to validate")

    all_valid = True
    for feature_id in features:
        if not validate_feature(feature_id):
            all_valid = False

    return all_valid

def main():
    if len(sys.argv) > 1:
        feature_id = sys.argv[1]
        result = validate_feature(feature_id)
    else:
        result = validate_all()

    if result:
        success("Validation passed!")
        sys.exit(0)
    else:
        error("Validation failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
