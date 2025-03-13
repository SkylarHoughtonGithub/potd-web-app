"""API package initialization."""

from flask_restx import Namespace

# Create namespaces
apod_namespace = Namespace(
    "apod", description="NASA Astronomy Picture of the Day operations"
)

# Don't import routes here to avoid circular imports
