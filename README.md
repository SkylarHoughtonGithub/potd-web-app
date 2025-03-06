# Planet Of The Day Flask Web App

A lightweight web application built with the Python Flask framework that displays NASA's Astronomy Picture of the Day (APOD). The application fetches the latest celestial imagery and accompanying explanation from NASA's public API which refreshes daily.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
- [Running the Application](#running-the-application)
  - [Running Container Locally](#running-container-locally)
  - [Accessing the Application](#accessing-the-application)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)
- [License](#license)

## Features

- Displays the current Astronomy Picture of the Day from NASA
- Shows the title, date, and detailed explanation for each image
- Responsive design that works on desktop and mobile devices
- Error handling for API connectivity issues
- Environment-specific configuration for development and production

## Requirements

- Container Orchestration System (Docker, Kubernetes, etc.)
- NASA API key (obtainable from [NASA API Portal](https://api.nasa.gov/))

## Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/potd-web-app.git
   cd potd-web-app
   ```

2. Create the following environment var, suggested env var file:

   `common.env`:
   ```
   export NASA_API_KEY="your_nasa_api_key_here"
   ```

3. Build the Docker container:
   ```bash
   ./build.sh
   ```

## Running the Application

### Running Container Locally

A run script is provided to test and debug the container:

```bash
./docker-run.sh [dev|prod] [debug|nodebug]
```

Positional arguments:
- First argument: Environment (`dev` or `prod`) - defaults to `dev` if not specified
- Second argument: Debug mode override (`debug` or `nodebug`) - optional, overrides the setting in the environment file

Examples:
```bash
# Run in development mode with default debug setting
./docker-run.sh dev

# Run in production mode with default debug setting
./docker-run.sh prod

# Run in development mode with debug forced on
./docker-run.sh dev debug

# Run in production mode with debug forced on (for troubleshooting)
./docker-run.sh prod debug
```

### Accessing the Application

Once running, the application will be available at:
```
http://localhost:5000/
```

Navigate to `http://localhost:5000/nasa_flask_app.html` to see the Astronomy Picture of the Day.

## Testing

The application includes a test suite to verify functionality and maintain code quality.

### Running Tests Locally

To run the tests locally:

```bash
./test.sh
```

This script:
- Sets up a Python virtual environment if not running in CI
- Installs required dependencies
- Runs pytest with coverage reporting
- Generates coverage reports in terminal, XML, and HTML formats

### Test Coverage

The test suite aims to maintain at least 90% code coverage. Coverage reports are generated in:
- Terminal output for quick reference
- XML format for CI tools
- HTML format for detailed local analysis (not in CI mode)

To view the HTML coverage report, open `htmlcov/index.html` in your browser after running tests.

### Continuous Integration

The test suite automatically runs on GitHub Actions for all pull requests and commits to the main branch, ensuring consistent quality across changes.

## Project Structure

```
potd-web-app/
├── app.py                  # Main Flask application
├── Dockerfile              # Docker configuration
├── requirements.txt        # Python dependencies
├── docker-run.sh           # Docker run script for local development
├── test.sh                 # Test script for running unit tests
├── common.env              # Common environment variables
├── dev.env                 # Development-specific variables
├── prod.env                # Production-specific variables
├── tests/                  # Test directory
│   ├── conftest.py         # Test fixtures and configuration
│   └── test_routes.py      # Route tests
└── templates/              # HTML templates
    ├── index.html          # Landing page
    ├── nasa_flask_app.html # APOD display page
    └── error.html          # Error page
```

## Deployment

For production deployment, make sure to:
1. Use the production environment: `./docker-run.sh prod`
2. Ensure your API key is kept secure with a secret management system
3. Consider implementing HTTPS if deploying to a public server

## Troubleshooting

If you encounter any issues:
- Verify your NASA API key is valid
- Check network connectivity to the NASA API endpoint
- Enable debug mode with `./docker-run.sh dev debug` for detailed error messages
- Review test results for any failures using `./test.sh`

## Credits

- NASA for providing the APOD API
- [Flask](https://flask.palletsprojects.com/) web framework

## License

MIT