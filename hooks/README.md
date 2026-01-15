# Git Hooks for Workflow System

Git hooks to automate validation and ensure workflow integrity.

## Available Hooks

### pre-commit

Validates workflows before allowing commits.

**Install:**
```bash
cp hooks/pre-commit.example .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**What it does:**
- ✅ Validates all workflow YAML files
- ✅ Checks state file formats
- ⚠️ Warns about sensitive files (.env)
- ❌ Blocks commit if validation fails

**Skip (not recommended):**
```bash
git commit --no-verify
```

## Future Hooks

### post-commit
Automatically push to remote after local commit (optional).

### pre-push
Run extended validation before pushing to remote.

### prepare-commit-msg
Auto-generate commit messages based on changed files in ai/features/.

## Custom Hooks

Create your own hooks for project-specific needs:

```bash
# Example: Notify team when feature status changes
# .git/hooks/post-commit

#!/bin/bash
if git diff --name-only HEAD~1 HEAD | grep -q "_state.md"; then
    # Send notification to Slack/Discord/etc
    echo "Feature state changed, notifying team..."
fi
```

## Installation Script

To install all hooks:

```bash
#!/bin/bash
for hook in hooks/*.example; do
    hook_name=$(basename "$hook" .example)
    cp "$hook" ".git/hooks/$hook_name"
    chmod +x ".git/hooks/$hook_name"
    echo "Installed: $hook_name"
done
```

Save as `install-hooks.sh` and run: `./install-hooks.sh`
