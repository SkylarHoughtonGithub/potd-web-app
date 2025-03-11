#!/bin/bash
set -e  # Exit immediately if a command exits with non-zero status

: "${CI:=false}"
TARGET_PATH="${2:-.}"

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Helper function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Helper function for running a command
run_command() {
    local tool=$1
    local command=$2
    
    print_message "${YELLOW}" "Running ${tool}..."
    
    if ! command_exists "${tool}"; then
        print_message "${RED}" "Error: ${tool} is not installed."
        return 1
    fi
    
    # Run the command
    if eval "${command}"; then
        print_message "${GREEN}" "✓ ${tool} passed"
        return 0
    else
        print_message "${RED}" "✗ ${tool} found issues"
        return 1
    fi
}

# Setup environment
setup_environment() {
    # attempt to set python runtime if missing
    if ! which python >/dev/null 2>&1; then
        PYTHON_CMD="python3"
    else
        PYTHON_CMD=$(which python) 
    fi
    echo "python runtime: $(which $PYTHON_CMD)"
    
    # Create and use a virtual environment if not running in CI
    if [ "$CI" != "true" ]; then
        echo "Setting up venv..."
        $PYTHON_CMD -m venv venv
        source venv/bin/activate
    fi
    
    # Install or update dependencies
    echo "Installing dependencies..."
    if [ -f requirements.txt ]; then 
        pip install -r requirements.txt
    fi
}

# Clean up environment
cleanup_environment() {
    # Deactivate virtual environment if we created one
    if [ "$CI" != "true" ] && [ -d "venv" ]; then
        echo "Deactivating venv..."
        deactivate
    fi
}

# Run tests with coverage
run_tests() {
    print_message "${YELLOW}" "Running tests with coverage..."
    
    if [ "$CI" = "true" ]; then
        # CI environment - use XML for reporting tools and terminal for feedback
        pytest --cov=app --cov-report=xml --cov-report=term tests/
    else
        # Local environment - include HTML report for viewing in browser
        pytest --cov=app --cov-report=term --cov-report=html tests/
        
        # Print message about HTML report location
        echo ""
        echo "HTML coverage report generated in htmlcov/index.html"
        echo "Open this file in your browser to view detailed coverage information."
    fi
    
    print_message "${GREEN}" "Tests completed successfully!"
}

# Run all code quality checks
run_code_quality() {
    local status=0
    
    print_message "${YELLOW}" "Running code quality checks on ${TARGET_PATH}..."
    
    # Run black
    run_command "black" "black --check ${TARGET_PATH}" || status=1
    
    # Run isort
    run_command "isort" "isort --check --profile black  ${TARGET_PATH}" || status=1
    
    # Run pylint
    run_command "pylint" "pylint ${TARGET_PATH}" || status=1
    
    # Run mypy
    run_command "mypy" "mypy ${TARGET_PATH}" || status=1
    
    if [ $status -eq 0 ]; then
        print_message "${GREEN}" "All code quality checks passed!"
    else
        print_message "${RED}" "Some code quality checks failed. See above for details."
    fi
    
    return $status
}

# Run formatting tools
run_format() {
    local status=0
    
    print_message "${YELLOW}" "Formatting code in ${TARGET_PATH}..."
    
    # Run black
    run_command "black" "black ${TARGET_PATH}" || status=1
    
    # Run isort
    run_command "isort" "isort --profile black --remove-redundant-aliases ${TARGET_PATH}" || status=1
    
    if [ $status -eq 0 ]; then
        print_message "${GREEN}" "Code formatting completed successfully!"
    else
        print_message "${RED}" "Code formatting encountered issues."
    fi
    
    return $status
}

# Run linting tools
run_lint() {
    local status=0
    
    print_message "${YELLOW}" "Linting code in ${TARGET_PATH}..."
    
    # Run pylint
    run_command "pylint" "pylint ${TARGET_PATH}" || status=1
    
    if [ $status -eq 0 ]; then
        print_message "${GREEN}" "Linting completed successfully!"
    else
        print_message "${RED}" "Linting found issues. See above for details."
    fi
    
    return $status
}

# Run security scanning tools
run_security() {
    local status=0
    
    print_message "${YELLOW}" "Running security scans on ${TARGET_PATH}..."
    
    # Create directory for reports
    mkdir -p security_reports
    
    # Run bandit security scanner
    print_message "${YELLOW}" "Running bandit..."
    if ! command_exists "bandit"; then
        print_message "${YELLOW}" "Installing bandit..."
        pip install bandit
    fi
    
    if bandit -r "${TARGET_PATH}" \
        --exclude ./venv,./env,./.venv,./.git,./tests,./__pycache__ \
        --skip B101,B303,B311 \
        -f txt -o security_reports/bandit_report.txt; then
        print_message "${GREEN}" "✓ bandit scan passed"
    else
        print_message "${RED}" "✗ bandit found security issues"
        status=1
    fi
    
    # Run safety check on dependencies
    print_message "${YELLOW}" "Running safety check..."
    if ! command_exists "safety"; then
        print_message "${YELLOW}" "Installing safety..."
        pip install safety
    fi
    
    if [ -f "requirements.txt" ]; then
        # Create a clean file with only ASCII content
        tr -cd '\11\12\15\40-\176' < requirements.txt > requirements_clean.txt
        
        # Check if the clean file has content
        if [ -s requirements_clean.txt ]; then
            if safety check -r requirements_clean.txt --output text > security_reports/safety_report.txt 2>&1; then
                print_message "${GREEN}" "✓ safety check passed"
            else
                print_message "${RED}" "✗ safety found vulnerable dependencies"
                status=1
            fi
        else
            print_message "${RED}" "Warning: Could not process requirements.txt file"
            echo "Warning: Could not process requirements.txt file" > security_reports/safety_report.txt
            echo "Please check that requirements.txt is a valid text file" >> security_reports/safety_report.txt
            status=1
        fi
        
        # Clean up
        rm requirements_clean.txt
    else
        print_message "${YELLOW}" "requirements.txt not found. Skipping safety check."
        echo "requirements.txt not found. Skipping safety check." > security_reports/safety_report.txt
    fi
    
    if [ $status -eq 0 ]; then
        print_message "${GREEN}" "All security checks passed! Reports are in the security_reports directory."
    else
        print_message "${RED}" "Some security checks found issues. See reports in the security_reports directory."
    fi
    
    return $status
}

# Show help message
show_help() {
    cat << EOF
Development Script - Handles testing, code quality, and security checks
Usage: ./test.sh [option] [path]

Options:
  --test            Run pytest with coverage
  --quality         Run all code quality checks
  --format          Run formatting tools (black, isort)
  --lint            Run linting tools (pylint)
  --security        Run security scanning tools (bandit, safety)
  --all             Run all tests, quality, and security checks
  --help            Show this help message

Examples:
  ./test.sh --test
  ./test.sh --quality app/ tests/
  ./test.sh --format app/ tests/
  ./test.sh --security app/
  ./test.sh --all
EOF
}

# Check for no arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Process arguments
case "$1" in
    --test)
        setup_environment
        run_tests
        cleanup_environment
        ;;
    --quality)
        setup_environment
        run_code_quality
        status=$?
        cleanup_environment
        exit $status
        ;;
    --format)
        setup_environment
        run_format
        status=$?
        cleanup_environment
        exit $status
        ;;
    --lint)
        setup_environment
        run_lint
        status=$?
        cleanup_environment
        exit $status
        ;;
    --security)
        setup_environment
        run_security
        status=$?
        cleanup_environment
        exit $status
        ;;
    --all)
        setup_environment
        run_tests
        run_code_quality
        run_security
        status=$?
        cleanup_environment
        exit $status
        ;;
    --help)
        show_help
        ;;
    *)
        print_message "${RED}" "Unknown option: $1"
        show_help
        exit 1
        ;;
esac