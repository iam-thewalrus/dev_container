#!/bin/bash
# Script to set up a new user in the development environment
# Run with: ./setup-user.sh <username> <email>

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <username> <email>"
    exit 1
fi

USERNAME=$1
EMAIL=$2

# Set up git configuration
git config --global user.name "$USERNAME"
git config --global user.email "$EMAIL"

# Create project directory structure
mkdir -p ~/projects/{data,models,notebooks,src,tests,docs}

# Set up Python environment configuration
cat > ~/.pyrc << EOF
# Python startup file
import readline
import rlcompleter
import atexit
import os

# Tab completion
readline.parse_and_bind('tab: complete')

# History file
histfile = os.path.join(os.environ['HOME'], '.python_history')
try:
    readline.read_history_file(histfile)
except IOError:
    pass
atexit.register(readline.write_history_file, histfile)

# Clean up namespace
del readline, rlcompleter, atexit, os, histfile
EOF

# Configure environment variables
cat >> ~/.bashrc << EOF

# Python configuration
export PYTHONSTARTUP=~/.pyrc
export PYTHONPATH=\$PYTHONPATH:/app

# Aliases
alias ll='ls -la'
alias jl='jupyter lab'
alias psh='poetry shell'
alias pt='poetry run pytest'

# Environment variables from .env
if [ -f /app/.env ]; then
    set -a
    source /app/.env
    set +a
fi
EOF

echo "User setup complete for $USERNAME ($EMAIL)"
echo "Log out and log back in to apply all changes"