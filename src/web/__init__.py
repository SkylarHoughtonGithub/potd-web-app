"""Web UI package initialization."""

from flask import Blueprint

# Create a blueprint for web UI routes
web_blueprint = Blueprint("web", __name__, url_prefix="/web")

# Don't import routes here to avoid circular imports
