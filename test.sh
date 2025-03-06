#!/bin/bash
set -e  # Exit immediately if a command exits with non-zero status

: "${CI:=false}"

# attempt to set python runtime if missing
if ! which python >/dev/null 2>&1; then
  PYTHON_CMD="python3"
else
  PYTHON_CMD=$(which python) 
fi
echo "python runtime: $PYTHON_CMD"

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
pip install pytest pytest-cov

# Run the tests with coverage
echo "Running coverage tests..."
pytest --cov=app --cov-report=xml --cov-report=term tests/

# Deactivate virtual environment if we created one
if [ "$CI" != "true" ]; then
  echo "deactivating venv..."
  deactivate
fi

echo "Tests completed!"