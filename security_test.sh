#!/bin/bash
# Minimal Python security scanning script that avoids config files

# Create directory for reports
mkdir -p security_reports

# Install tools if not present
pip install bandit safety

# Run bandit directly with command line parameters (no config file)
echo "Running bandit..."
bandit -r . \
  --exclude ./venv,./env,./.venv,./.git,./tests,./__pycache__ \
  --skip B101,B303,B311 \
  -f txt -o security_reports/bandit_report.txt

# Handle requirements.txt with extra caution
echo "Running safety check..."
if [ -f "requirements.txt" ]; then
  # Try to create a safe version of requirements.txt
  echo "Creating clean requirements file..."
  
  # Create a clean file with only ASCII content
  tr -cd '\11\12\15\40-\176' < requirements.txt > requirements_clean.txt
  
  # Check if the clean file has content
  if [ -s requirements_clean.txt ]; then
    safety check -r requirements_clean.txt --output text > security_reports/safety_report.txt 2>&1 || true
  else
    echo "Warning: Could not process requirements.txt file" > security_reports/safety_report.txt
    echo "Please check that requirements.txt is a valid text file" >> security_reports/safety_report.txt
  fi
  
  # Clean up
  rm requirements_clean.txt
else
  echo "requirements.txt not found. Skipping safety check."
fi

echo "Security scanning complete. Reports are in the security_reports directory."