"""Configuration settings for the Flask application."""

import os


class Config:  # pylint: disable=too-few-public-methods
    """Base configuration."""

    # Flask settings
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-key-please-change-in-production")
    DEBUG = os.environ.get("FLASK_DEBUG", "false").lower() == "true"

    # API settings
    NASA_API_KEY = os.environ.get("NASA_API_KEY", "DEMO_KEY")
    NASA_APOD_URL = "https://api.nasa.gov/planetary/apod"

    # Swagger settings
    SWAGGER_UI_DOC_EXPANSION = "list"
    RESTX_VALIDATE = True
    RESTX_MASK_SWAGGER = False
