#!/usr/bin/env python3
"""
Risk Policy Gate — Deterministic preflight check for PRs.

Reads control-plane/contract.json and evaluates changed files against:
1. Risk tier classification (high > medium > low)
2. Docs drift rules (if you change X, you must also change Y)
3. Required checks per tier

Usage:
    # In CI (auto-detect changed files vs base branch):
    python3 scripts/risk_policy_gate.py --base origin/main

    # Local (explicit files):
    python3 scripts/risk_policy_gate.py --files "file1.md,file2.py"

    # JSON output for downstream consumption:
    python3 scripts/risk_policy_gate.py --base origin/main --json

Exit codes:
    0 = PASS (all checks satisfied)
    1 = FAIL (policy violation detected)
    2 = ERROR (contract not found, invalid JSON, etc.)

Dependencies: Python 3.6+ stdlib only (no pip install needed).
"""

import argparse
import fnmatch
import json
import os
import subprocess
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
CONTRACT_PATH = REPO_ROOT / "control-plane" / "contract.json"

TIER_PRIORITY = {"high": 3, "medium": 2, "low": 1}


def load_contract(path: Path) -> dict:
    """Load and validate the governance contract."""
    if not path.exists():
        print(f"[GATE] ERROR: Contract not found at {path}", file=sys.stderr)
        sys.exit(2)
    try:
        with open(path, "r", encoding="utf-8") as f:
            contract = json.load(f)
    except json.JSONDecodeError as e:
        print(f"[GATE] ERROR: Invalid JSON in contract: {e}", file=sys.stderr)
        sys.exit(2)

    required_keys = ["version", "riskTierRules", "mergePolicy"]
    for key in required_keys:
        if key not in contract:
            print(f"[GATE] ERROR: Contract missing required key: {key}", file=sys.stderr)
            sys.exit(2)

    return contract


def get_changed_files_git(base: str) -> list:
    """Get changed files by diffing against a base branch."""
    try:
        result = subprocess.run(
            ["git", "diff", "--name-only", "--diff-filter=ACMRT", base],
            capture_output=True, text=True, check=True, cwd=str(REPO_ROOT)
        )
        files = [f.strip() for f in result.stdout.strip().split("\n") if f.strip()]
        return files
    except subprocess.CalledProcessError as e:
        print(f"[GATE] ERROR: git diff failed: {e.stderr.strip()}", file=sys.stderr)
        sys.exit(2)


def matches_pattern(filepath: str, pattern: str) -> bool:
    """Check if a filepath matches a glob pattern using fnmatch."""
    if pattern.endswith("/**"):
        prefix = pattern[:-3]
        return filepath.startswith(prefix + "/") or filepath == prefix
    if "**" in pattern:
        prefix = pattern.split("**")[0]
        suffix = pattern.split("**")[-1]
        if prefix and not filepath.startswith(prefix):
            return False
        if suffix and not filepath.endswith(suffix):
            return False
        return filepath.startswith(prefix) if prefix else True
    return fnmatch.fnmatch(filepath, pattern)


def compute_risk_tier(changed_files: list, tier_rules: dict) -> str:
    """Compute the highest risk tier among changed files."""
    highest_tier = "low"
    highest_priority = TIER_PRIORITY["low"]

    for tier, patterns in tier_rules.items():
        if tier not in TIER_PRIORITY:
            continue
        for filepath in changed_files:
            for pattern in patterns:
                if matches_pattern(filepath, pattern):
                    if TIER_PRIORITY[tier] > highest_priority:
                        highest_tier = tier
                        highest_priority = TIER_PRIORITY[tier]

    return highest_tier


def check_docs_drift(changed_files: list, drift_rules: list) -> list:
    """Check docs drift rules. Returns list of violations."""
    violations = []
    changed_set = set(changed_files)

    for rule in drift_rules:
        rule_name = rule.get("name", "unnamed")
        if_changed = rule.get("ifChanged", [])
        must_also = rule.get("mustAlsoChangeOneOf", [])

        # Check if any trigger pattern matches a changed file
        trigger_matched = False
        trigger_files = []
        for pattern in if_changed:
            for filepath in changed_files:
                if matches_pattern(filepath, pattern):
                    trigger_matched = True
                    trigger_files.append(filepath)

        if not trigger_matched:
            continue

        # Check if at least one "must also change" pattern matches
        must_satisfied = False
        for pattern in must_also:
            for filepath in changed_files:
                if matches_pattern(filepath, pattern):
                    must_satisfied = True
                    break
            if must_satisfied:
                break

        if not must_satisfied:
            violations.append({
                "rule": rule_name,
                "trigger_files": trigger_files,
                "must_also_change_one_of": must_also
            })

    return violations


def get_required_checks(tier: str, merge_policy: dict) -> list:
    """Get required checks for a given tier."""
    tier_policy = merge_policy.get(tier, merge_policy.get("low", {}))
    return tier_policy.get("requiredChecks", ["risk-policy-gate"])


def main():
    parser = argparse.ArgumentParser(description="Risk Policy Gate")
    parser.add_argument("--base", help="Base branch to diff against (e.g., origin/main)")
    parser.add_argument("--files", help="Comma-separated list of changed files")
    parser.add_argument("--json", action="store_true", help="Output results as JSON")
    parser.add_argument("--contract", help="Path to contract.json (default: auto-detect)")
    args = parser.parse_args()

    # Load contract
    contract_path = Path(args.contract) if args.contract else CONTRACT_PATH
    contract = load_contract(contract_path)

    # Get changed files
    if args.files:
        changed_files = [f.strip() for f in args.files.split(",") if f.strip()]
    elif args.base:
        changed_files = get_changed_files_git(args.base)
    else:
        print("[GATE] ERROR: Must specify --base or --files", file=sys.stderr)
        sys.exit(2)

    if not changed_files:
        result = {
            "status": "PASS",
            "reason": "No changed files detected",
            "tier": "low",
            "changed_files": 0,
            "required_checks": [],
            "drift_violations": []
        }
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print("[GATE] No changed files detected. PASS.")
        sys.exit(0)

    # Compute risk tier
    tier = compute_risk_tier(changed_files, contract["riskTierRules"])

    # Get required checks
    required_checks = get_required_checks(tier, contract["mergePolicy"])

    # Check docs drift
    drift_rules = contract.get("docsDriftRules", [])
    drift_violations = check_docs_drift(changed_files, drift_rules)

    # Determine result
    passed = len(drift_violations) == 0

    result = {
        "status": "PASS" if passed else "FAIL",
        "tier": tier,
        "changed_files": len(changed_files),
        "required_checks": required_checks,
        "drift_violations": drift_violations,
        "files": changed_files
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"[GATE] Risk tier: {tier}")
        print(f"[GATE] Changed files: {len(changed_files)}")
        print(f"[GATE] Required checks: {', '.join(required_checks)}")

        if drift_violations:
            print(f"[GATE] Docs drift check: FAIL")
            for v in drift_violations:
                trigger = ", ".join(v["trigger_files"])
                must = " OR ".join(v["must_also_change_one_of"])
                print(f"  - Rule '{v['rule']}': changed [{trigger}] but did not change any of [{must}]")
        else:
            print(f"[GATE] Docs drift check: PASS")

        print(f"[GATE] Result: {'PASS' if passed else 'FAIL'}")

    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()
