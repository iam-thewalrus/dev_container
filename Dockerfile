FROM python:3.11-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.7.1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    DEBIAN_FRONTEND=noninteractive

ENV PATH="$POETRY_HOME/bin:/app/.venv/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    openssh-server \
    vim \
    nano \
    htop \
    netcat \
    libpq-dev \
    postgresql-client \
    sudo \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# We'll use pandas-ta instead of TA-Lib to avoid build issues
# The required technical analysis functionality is available in pandas-ta

# Configure SSH server
RUN mkdir -p /var/run/sshd \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config \
    && echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config

# Create a non-root user with sudo privileges
RUN useradd -m -s /bin/bash developer \
    && echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer \
    && chmod 0440 /etc/sudoers.d/developer \
    && mkdir -p /home/developer/.ssh \
    && chmod 700 /home/developer/.ssh \
    && chown -R developer:developer /home/developer/.ssh

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Create and configure development directory
WORKDIR /app
RUN mkdir -p /app \
    && chown -R developer:developer /app

# Copy project files
COPY --chown=developer:developer pyproject.toml poetry.lock* /app/
COPY --chown=developer:developer scripts /app/scripts/
COPY --chown=developer:developer init-jupyter.sh /app/

# Make scripts executable
RUN chmod +x /app/init-jupyter.sh /app/scripts/entrypoint.sh

# Switch to non-root user for installation
USER developer

# Configure Poetry with virtualenvs and install dependencies
RUN poetry config virtualenvs.create true \
    && poetry config virtualenvs.in-project true \
    && poetry install --no-interaction --no-ansi --no-root

# Switch back to root for entrypoint
USER root

# Expose ports
EXPOSE 22 8888

# Use entrypoint script
ENTRYPOINT ["/app/scripts/entrypoint.sh"]