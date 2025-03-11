# Financial Data Analysis Development Environment

A Docker-based development environment for financial data analysis using Python, Poetry, and PostgreSQL with TimescaleDB (for time series data).

## Features

- Python 3.11 with Poetry for dependency management
- PostgreSQL with TimescaleDB for time series data storage
- SSH access for remote development with Windsurf IDE
- Jupyter Lab for interactive analysis
- pgAdmin for database management
- Pre-configured with popular data science and financial analysis packages

## Prerequisites

- Docker and Docker Compose
- SSH key pair for authentication

## Setup Instructions

1. Clone this repository:

```bash
git clone <repository-url>
cd dev_env
```

2. Create a `.env` file from the example:

```bash
cp .env.example .env
```

3. Edit the `.env` file and add your API credentials.

4. Ensure you have an SSH key:

```bash
# Check if you have an existing key
ls -la ~/.ssh/id_rsa.pub

# If not, generate a new SSH key
ssh-keygen -t rsa -b 4096
```

5. Start the development environment:

```bash
docker-compose up -d
```

## Connecting with Windsurf IDE

1. Open Windsurf IDE
2. Go to Settings > SSH Configurations
3. Add a new SSH configuration:
   - Host: localhost
   - Port: 2222
   - Username: developer
   - Authentication: SSH Key
   - SSH Key Path: Path to your private key file (usually `~/.ssh/id_rsa`)
4. Connect to the development environment

## Services

- **Development Container**: SSH accessible on port 2222
- **PostgreSQL/TimescaleDB**: Available on port 5432
- **pgAdmin**: Available at http://localhost:5050
  - Email: admin@example.com
  - Password: pgadmin
- **Jupyter Lab**: Available at http://localhost:8888 (token provided in container logs)

## Working with the Environment

### SSH Access

```bash
ssh developer@localhost -p 2222
```

### Viewing Jupyter Lab Token

```bash
docker logs python_dev_env | grep token
```

### Database Connection Details

- Host: localhost
- Port: 5432
- Database: devdb
- Username: postgres
- Password: postgres

## Installed Python Packages

The environment comes with a comprehensive set of data science and financial analysis packages:

- **Data Processing**: pandas, numpy
- **Visualization**: matplotlib, seaborn, plotly, dash
- **Machine Learning**: scikit-learn, statsmodels, prophet
- **Time Series**: pandas-ta, timescale-vector (Note: Using pandas-ta instead of ta-lib due to build compatibility)
- **API Integration**: requests, httpx, aiohttp, websockets, ccxt
- **Development Tools**: pytest, black, isort, mypy, pylint

## Security Considerations

- SSH password authentication is enabled but not recommended. Use SSH key authentication.
- Default database credentials should be changed in production environments.
- API keys and secrets should never be committed to the repository.

## Troubleshooting

- **SSH Connection Issues**: Ensure your SSH key is properly mounted in the container.
- **Database Connection Issues**: Check if the database container is running with `docker ps`.
- **Package Installation Issues**: Update the pyproject.toml file and rebuild the container.

## License

[MIT License](LICENSE)