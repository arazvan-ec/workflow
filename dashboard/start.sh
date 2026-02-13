#!/usr/bin/env bash
set -euo pipefail

DASHBOARD_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$DASHBOARD_DIR/.venv"
PID_FILE="$DASHBOARD_DIR/.dashboard.pid"
PORT="${DASHBOARD_PORT:-8420}"
HOST="${DASHBOARD_HOST:-127.0.0.1}"

# Check if already running
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Dashboard already running (PID $(cat "$PID_FILE")) at http://$HOST:$PORT"
    exit 0
fi

# Create venv if needed
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    echo "Installing dependencies..."
    "$VENV_DIR/bin/pip" install -r "$DASHBOARD_DIR/requirements.txt" --quiet
fi

# Start server
echo "Starting AI Development Dashboard on http://$HOST:$PORT ..."
cd "$DASHBOARD_DIR"
nohup "$VENV_DIR/bin/python" -m uvicorn main:app \
    --host "$HOST" \
    --port "$PORT" \
    --log-level info \
    > "$DASHBOARD_DIR/.dashboard.log" 2>&1 &

echo $! > "$PID_FILE"
echo "Dashboard started (PID $!) -- log: $DASHBOARD_DIR/.dashboard.log"
echo "Open http://$HOST:$PORT in your browser"
