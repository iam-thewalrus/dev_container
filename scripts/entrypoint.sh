#!/bin/bash
set -e

# Start SSH server in background
/usr/sbin/sshd

# Switch to developer user
cd /app

# Make sure PATH includes the virtual environment
export PATH="/app/.venv/bin:$PATH"

# Start Jupyter Lab in background (if environment variable is set)
if [ "${START_JUPYTER:-false}" = "true" ]; then
  sudo -u developer bash -c "cd /app && source .venv/bin/activate && ./init-jupyter.sh" &
  echo "Jupyter Lab started. Check logs for access token."
fi

# Keep container running
tail -f /dev/null