# Planet Of The Day Flask Web App

[![Python Unit Tests](https://github.com/SkylarHoughtonGithub/potd-web-app/actions/workflows/python_unit_tests.yml/badge.svg)](https://github.com/SkylarHoughtonGithub/potd-web-app/actions/workflows/python_unit_tests.yml)
[![Python Quality Checks](https://github.com/SkylarHoughtonGithub/potd-web-app/actions/workflows/python_lint_quality_check.yml/badge.svg)](https://github.com/SkylarHoughtonGithub/potd-web-app/actions/workflows/python_lint_quality_check.yml)
[![Python Security Scan](https://github.com/SkylarHoughtonGithub/potd-web-app/actions/workflows/python_security_tests.yml/badge.svg)](https://github.com/SkylarHoughtonGithub/potd-web-app/actions/workflows/python_security_tests.yml)
[![Build and Push Docker Image](https://github.com/SkylarHoughtonGithub/potd-web-app/actions/workflows/ghcr_build_push.yml/badge.svg)](https://github.com/SkylarHoughtonGithub/potd-web-app/actions/workflows/ghcr_build_push.yml)

A lightweight web application built with the Python Flask framework that displays NASA's Astronomy Picture of the Day (APOD). The application fetches the latest celestial imagery and accompanying explanation from NASA's public API which refreshes daily.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
- [Running the Application](#running-the-application)
  - [Running Container Locally](#running-container-locally)
  - [Accessing the Application](#accessing-the-application)
- [Testing](#testing)
  - [Running Tests Locally](#running-tests-locally)
  - [Test Options](#test-options)
  - [Test Coverage](#test-coverage)
  - [Security Scanning](#security-scanning)
  - [Continuous Integration](#continuous-integration)
- [Docker Image Build](#docker-image-build)
  - [Local Docker Build](#local-docker-build)
  - [GitHub Actions Automated Build](#github-actions-automated-build)
  - [Using Container Registry Images](#using-container-registry-images)
  - [Docker Image Tags](#docker-image-tags)
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

The application includes a comprehensive test suite to verify functionality and maintain code quality.

### Running Tests Locally

The test script supports multiple testing modes:

```bash
./test.sh [option] [path]
```

### Test Options

- `--test`: Run pytest with coverage reports
- `--quality`: Run all code quality checks (includes formatting checks, linting, and type checking)
- `--format`: Apply formatting tools (black, isort) to fix style issues
- `--lint`: Run just the linting tools (pylint)
- `--security`: Run security scanning tools (bandit, immunipy)
- `--all`: Run both tests and all quality checks
- `--help`: Show help message with all options

Examples:
```bash
# Run unit tests with coverage
./test.sh --test

# Run code quality checks on specific directories
./test.sh --quality app/ tests/

# Format your code to meet style requirements
./test.sh --format

# Run only linting checks
./test.sh --lint

# Run security scans to identify vulnerabilities
./test.sh --security

# Run all checks (tests and code quality)
./test.sh --all
```

### Test Coverage

The test suite aims to maintain at least 90% code coverage. Coverage reports are generated in:
- Terminal output for quick reference
- XML format for CI tools
- HTML format for detailed local analysis (not in CI mode)

To view the HTML coverage report, open `htmlcov/index.html` in your browser after running tests.

### Security Scanning

The application includes security scanning tools to identify potential vulnerabilities:

- **Bandit**: Static code analysis tool designed to find common security issues in Python code
- **Immunipy**: Dependency vulnerability scanner that checks for known vulnerabilities in installed packages

Security scans can be run with:
```bash
./test.sh --security
```

The scans check for:
- Potential security issues in the Python code
- Use of dangerous functions
- Vulnerabilities in third-party dependencies
- Insecure dependency versions

#### Security Reports

When run through the GitHub Actions workflow, security scan results are automatically saved as artifacts, which can be accessed from the Actions tab in your repository. These reports provide detailed information about any security issues found.

### Continuous Integration

The test suite automatically runs on GitHub Actions for all pull requests and commits to the main branch, ensuring consistent quality across changes. The CI pipeline includes:

- Tests across multiple Python versions (3.8 to 3.12)
- Code quality checks
- Security scanning
- Coverage verification (minimum 90% coverage)

## Docker Image Build

The application can be built both locally and automatically using GitHub Actions.

### Local Docker Build

To build the Docker image locally:

```bash
# Using the provided build script
./build.sh

# Or manually with Docker
docker build -t potd-web-app:local .
```

### GitHub Actions Automated Build

This project includes a GitHub Actions workflow that automatically builds and pushes Docker images to GitHub Container Registry (GHCR) after all quality and security checks have successfully completed on the main branch.

To set up the automated build workflow:

1. **Create the workflow file** at `.github/workflows/docker-build.yml` with the provided content from the repository

2. **Ensure your repository has access to GitHub Container Registry:**
   - Go to your repository settings
   - Navigate to "Packages" settings
   - Confirm GitHub Packages is enabled for the repository

3. **Push changes to trigger the workflow:**
   - Any push to the main branch will trigger the build
   - You can also manually trigger the workflow from the Actions tab in GitHub

### Using Container Registry Images

After the workflow runs successfully, you can pull the Docker image:

```bash
# Replace with your GitHub username and repository name
docker pull ghcr.io/skylar-houghton/potd-web-app:latest
```

Or in Kubernetes/Docker Compose files:

```yaml
image: ghcr.io/skylar-houghton/potd-web-app:main
```

### Docker Image Tags

The GitHub Actions workflow automatically applies several tags to each built image:

- **Branch-based tags** - Images are tagged with the branch name:
  ```
  ghcr.io/skylar-houghton/potd-web-app:main
  ```

- **Pull Request tags** - Images built from PRs get tagged with the PR number:
  ```
  ghcr.io/skylar-houghton/potd-web-app:pr-123
  ```

- **Commit SHA tags** - Each image is tagged with the short commit hash:
  ```
  ghcr.io/skylar-houghton/potd-web-app:a1b2c3d
  ```

- **Latest tag** - The main branch also gets the `latest` tag:
  ```
  ghcr.io/skylar-houghton/potd-web-app:latest
  ```

- **Semantic Version tags** - When you tag a release with a version number (e.g., `v1.2.3`), the image gets these tags:
  ```
  ghcr.io/skylar-houghton/potd-web-app:1.2.3
  ghcr.io/skylar-houghton/potd-web-app:1.2
  ```

To create a versioned release:

```bash
# Tag your commit
git tag v1.0.0
git push origin v1.0.0
```

The workflow will automatically build and tag the image with version `1.0.0`.

## Project Structure

```
potd-web-app/
├── app.py                  # Main Flask application
├── Dockerfile              # Docker configuration
├── requirements.txt        # Python dependencies
├── docker-run.sh           # Docker run script for local development
├── test.sh                 # Test script for running unit and quality tests
├── common.env              # Common environment variables
├── dev.env                 # Development-specific variables
├── prod.env                # Production-specific variables
├── .github/workflows/
│   ├── python_unit_tests.yml        # Unit test workflow
│   ├── python_lint_quality_check.yml # Code quality workflow
│   ├── python_security_scan.yml     # Security scan workflow
│   └── docker-build.yml             # Docker build and push workflow
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
4. Regularly run security scans to identify and address vulnerabilities
5. Keep dependencies updated to mitigate security risks
6. Use specific version tags (e.g., `1.2.3`) for stable deployments rather than `latest`

## Troubleshooting

If you encounter any issues:
- Verify your NASA API key is valid
- Check network connectivity to the NASA API endpoint
- Enable debug mode with `./docker-run.sh dev debug` for detailed error messages
- Run tests with `./test.sh --test` to check for functional issues
- Run code quality checks with `./test.sh --quality` to identify style problems
- Run security scans with `./test.sh --security` to check for vulnerabilities
- If code quality checks fail, run `./test.sh --format` to automatically fix most style issues
- For Docker image issues, check the GitHub Actions workflow run logs

## Credits

- NASA for providing the APOD API
- [Flask](https://flask.palletsprojects.com/) web framework

## License

MIT