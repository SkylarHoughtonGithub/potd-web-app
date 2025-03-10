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

# Show help message
show_help() {
    cat << EOF
Development Script - Handles both testing and code quality
Usage: ./test.sh [option] [path]

Options:
  --test            Run pytest with coverage
  --quality         Run all code quality checks
  --format          Run formatting tools (black, isort)
  --lint            Run linting tools (pylint)
  --all             Run both tests and all quality checks
  --help          Show this help message

Examples:
  ./test.sh --test
  ./test.sh --quality . tests/
  ./test.sh --format . tests/
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
    --all)
        setup_environment
        run_tests
        run_code_quality
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