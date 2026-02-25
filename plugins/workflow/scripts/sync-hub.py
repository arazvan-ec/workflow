#!/usr/bin/env python3
"""
Sync workflow-data.yaml -> workflow-hub.html

Reads the YAML source of truth and updates the DATA variable
embedded in the HTML file. The HTML remains self-contained
(no external dependencies at runtime).

Usage:
  python3 scripts/sync-hub.py                    # sync
  python3 scripts/sync-hub.py --check            # validate only (exit 1 if out of sync)

Requires: PyYAML (pip install pyyaml)
"""

import sys
import os
import re
import json

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML required. Install with: pip install pyyaml")
    sys.exit(1)

# Paths relative to script location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PLUGIN_DIR = os.path.dirname(SCRIPT_DIR)
YAML_PATH = os.path.join(PLUGIN_DIR, "core", "data", "workflow-data.yaml")
HTML_PATH = os.path.join(PLUGIN_DIR, "core", "docs", "workflow-hub.html")

# Markers in the HTML file
DATA_START = "var DATA = "
DATA_END = "};"

def load_yaml():
    """Load and return the YAML data."""
    with open(YAML_PATH, "r") as f:
        return yaml.safe_load(f)

def yaml_to_json(data):
    """Convert YAML data to the JSON structure expected by the HTML."""
    # The HTML DATA object has a slightly flattened structure compared to the YAML.
    # We transform to match the HTML's expected schema.

    # Build phases (exclude 'quick' from main list for flow display,
    # but include in the full list for quick reference)
    phases = []
    for p in data["flow"]["phases"]:
        phase = {
            "id": p["id"],
            "name": p["name"],
            "cmd": p["cmd"],
            "purpose": p["purpose"],
            "when": p.get("when", ""),
            "time_pct": p.get("time_pct", 0),
            "color": p.get("color", "accent"),
            "guard": p.get("guard"),
            "details": p.get("details", [])
        }
        if p.get("optional"):
            phase["optional"] = True
        phases.append(phase)

    # Build complexity levels
    levels = {}
    for key, lv in data["complexity"]["levels"].items():
        levels[key] = {
            "name": lv["name"],
            "badge": lv["badge"],
            "color": lv["color"],
            "files": lv["scope"]["files"],
            "duration": lv["scope"]["duration"],
            "phases": " -> ".join(p.upper() for p in lv["phases"]),
            "artifacts": ", ".join(lv["artifacts"]),
            "bcp_limit": lv["bcp_limit"],
            "examples": lv["examples"]
        }

    # Build escalation
    escalation_map = {"L1": "L2", "L2": "L3", "L3": "L4"}
    escalation_triggers = {
        "L1": "scope grows",
        "L2": "multi-component",
        "L3": "unknowns found"
    }
    escalation = []
    for fr, to in escalation_map.items():
        escalation.append({
            "from": fr,
            "to": to,
            "trigger": escalation_triggers.get(fr, "escalation")
        })

    # Build methodologies
    methodologies = []
    for m in data["methodologies"]:
        if isinstance(m, dict) and "name" in m:
            synergy = m.get("synergizes_with", [])
            if isinstance(synergy, list):
                synergy = ", ".join(str(s) for s in synergy)
            methodologies.append({
                "id": m["id"],
                "name": m["name"],
                "source": m["source"],
                "synergy": synergy,
                "contributions": m["contributions"]
            })

    # Build capabilities
    roles = []
    for r in data["capabilities"]["roles"]:
        roles.append({
            "name": r["name"],
            "description": r["description"],
            "invoked_by": r["invoked_by"],
            "color": r["color"]
        })

    agents = {}
    for cat, agent_list in data["capabilities"]["agents"].items():
        agents[cat] = []
        for a in agent_list:
            agents[cat].append({
                "name": a["name"],
                "description": a["description"],
                "invoked_by": a["invoked_by"]
            })

    skills = {}
    for cat, skill_list in data["capabilities"]["skills"].items():
        skills[cat] = []
        for s in skill_list:
            skills[cat].append({
                "name": s["name"],
                "description": s["description"]
            })

    # Build context
    activation_layers = []
    for layer in data["context"]["activation_layers"]:
        activation_layers.append({
            "level": layer["level"],
            "label": layer["label"],
            "icon": layer["icon"],
            "description": layer["description"],
            "items": layer["items"],
            "color": layer["color"]
        })

    fork_strategies = {}
    for key, fs in data["context"]["fork_strategies"].items():
        fork_strategies[key] = {
            "label": fs["label"],
            "color": fs["color"],
            "description": fs["description"],
            "traits": fs["traits"]
        }

    dimensions = []
    for d in data["context"]["dimensions"]:
        dimensions.append({
            "name": d["name"],
            "question": d["question"],
            "description": d["description"],
            "color": d["color"]
        })

    # Build session
    lifecycle_steps = []
    for s in data["session"]["lifecycle_steps"]:
        lifecycle_steps.append({
            "step": s["step"],
            "name": s["name"],
            "description": s["description"],
            "color": s["color"]
        })

    state_files = []
    for f in data["session"]["state_files"]:
        entry = {
            "name": f["name"],
            "label": f["label"],
            "description": f["description"],
            "color": f["color"]
        }
        if "status_values" in f:
            entry["status_values"] = " | ".join(f["status_values"])
        state_files.append(entry)

    # Build patterns
    patterns = []
    for p in data["patterns"]:
        patterns.append({
            "name": p["name"],
            "summary": p["summary"]
        })

    # Build SDD pipeline
    sdd_pipeline = []
    for s in data["sdd_pipeline"]:
        sdd_pipeline.append({
            "phase": s["phase"],
            "artifact": s["artifact"],
            "content": s["content"],
            "color": s["color"]
        })

    # Build common workflows
    common_workflows = []
    for w in data["flow"]["common_workflows"]:
        path = w["path"]
        if isinstance(path, list):
            path = " -> ".join(path)
        common_workflows.append({
            "name": w["name"],
            "level": w["level"],
            "path": path,
            "color": w["color"]
        })

    return {
        "version": data["version"],
        "flow": {
            "phases": phases,
            "support_commands": data["flow"]["support_commands"],
            "time_distribution": data["flow"]["time_distribution"],
            "common_workflows": common_workflows
        },
        "complexity": {
            "levels": levels,
            "signal_matrix": data["complexity"]["signal_matrix"],
            "escalation": escalation
        },
        "methodologies": methodologies,
        "synergies": data.get("methodologies", {})[-1] if False else data.get("synergies", data.get("methodologies", {}).get("synergies", [])),
        "capabilities": {
            "roles": roles,
            "agents": agents,
            "skills": skills
        },
        "context": {
            "activation_layers": activation_layers,
            "fork_strategies": fork_strategies,
            "dimensions": dimensions
        },
        "session": {
            "lifecycle_steps": lifecycle_steps,
            "state_files": state_files,
            "key_principles": data["session"]["key_principles"],
            "handoff_protocol": data["session"]["handoff_protocol"]
        },
        "patterns": patterns,
        "sdd_pipeline": sdd_pipeline
    }

def extract_html_data(html_content):
    """Extract the current DATA JSON from the HTML file."""
    start_marker = "var DATA = "
    end_marker = "\n};\n"
    start = html_content.find(start_marker)
    if start == -1:
        return None
    start += len(start_marker)
    end = html_content.find(end_marker, start)
    if end == -1:
        return None
    return html_content[start:end + 1]

def update_html(html_content, new_json_str):
    """Replace the DATA variable in the HTML with new JSON."""
    start_marker = "var DATA = "
    end_marker = "\n};\n"
    start = html_content.find(start_marker)
    if start == -1:
        raise ValueError("Could not find 'var DATA = ' in HTML file")
    data_start = start + len(start_marker)
    end = html_content.find(end_marker, data_start)
    if end == -1:
        raise ValueError("Could not find closing '};' for DATA variable")
    return html_content[:data_start] + new_json_str + html_content[end + 1:]

def main():
    check_only = "--check" in sys.argv

    # Load YAML
    print(f"Reading: {YAML_PATH}")
    yaml_data = load_yaml()

    # Convert to JSON
    json_data = yaml_to_json(yaml_data)
    new_json_str = json.dumps(json_data, indent=2, ensure_ascii=False)

    # Read HTML
    print(f"Reading: {HTML_PATH}")
    with open(HTML_PATH, "r") as f:
        html_content = f.read()

    # Extract current JSON from HTML
    current_json = extract_html_data(html_content)

    if check_only:
        if current_json is None:
            print("ERROR: Could not extract DATA from HTML")
            sys.exit(1)
        try:
            current = json.loads(current_json)
            expected = json.loads(new_json_str)
            if current == expected:
                print("OK: HTML DATA matches YAML source of truth")
                sys.exit(0)
            else:
                print("OUT OF SYNC: HTML DATA differs from YAML")
                print("Run: python3 scripts/sync-hub.py")
                sys.exit(1)
        except json.JSONDecodeError as e:
            print(f"ERROR: Could not parse JSON: {e}")
            sys.exit(1)
    else:
        # Update HTML
        updated_html = update_html(html_content, new_json_str)
        with open(HTML_PATH, "w") as f:
            f.write(updated_html)
        print(f"Updated: {HTML_PATH}")
        print(f"Version: {json_data['version']}")
        print("Sync complete.")

if __name__ == "__main__":
    main()
