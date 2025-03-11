#!/bin/bash
# This script starts Jupyter Lab in the development container

# Create a Jupyter config if it doesn't exist
jupyter lab --generate-config

# Set password to empty and disable it to allow token authentication
echo "c.ServerApp.password = ''" >> ~/.jupyter/jupyter_lab_config.py
echo "c.ServerApp.password_required = False" >> ~/.jupyter/jupyter_lab_config.py

# Allow access from any IP
echo "c.ServerApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_lab_config.py
echo "c.ServerApp.allow_origin = '*'" >> ~/.jupyter/jupyter_lab_config.py
echo "c.ServerApp.allow_remote_access = True" >> ~/.jupyter/jupyter_lab_config.py

# Start Jupyter Lab
jupyter lab --port=8888 --no-browser