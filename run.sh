#!/bin/bash

# Check if environment argument is provided
ENV=${1:-dev}  # Default to 'dev' if no argument provided
DEBUG_OVERRIDE=${2:-}  # Optional second argument to override debug mode

# Load common environment variables
source common.env

# Load environment-specific variables
if [ "$ENV" = "dev" ]; then
    source dev.env
    echo "Running in development environment"
elif [ "$ENV" = "prod" ]; then
    source prod.env
    echo "Running in production environment"
else
    echo "Invalid environment: $ENV. Using development as default."
    source dev.env
fi

# Override debug mode if specified
if [ "$DEBUG_OVERRIDE" = "debug" ]; then
    export FLASK_DEBUG=true
    echo "Debug mode manually enabled"
elif [ "$DEBUG_OVERRIDE" = "nodebug" ]; then
    export FLASK_DEBUG=false
    echo "Debug mode manually disabled"
fi

# Run the Docker container with environment variables
docker run -e FLASK_ENV=${FLASK_ENV} -e FLASK_DEBUG=${FLASK_DEBUG} -e NASA_API_KEY=${NASA_API_KEY} -p 5000:5000 nasa-app