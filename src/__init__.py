"""NASA APOD application package."""

from flask import Flask, redirect, url_for
from flask_restx import Api

import src.api.apod  # noqa
import src.api.models  # noqa
from src.api import apod_namespace
from src.config import Config

# Import routes modules here - before create_app is called
from src.web import routes  # noqa
from src.web import web_blueprint


def create_app(config_class=Config):
    """Create and configure the Flask application."""
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Root redirect
    @app.route("/")
    def root_redirect():
        """Redirect root URL to web blueprint."""
        return redirect(url_for("web.index"))

    # Initialize Flask-RestX API with Swagger
    api = Api(
        app,
        version="1.0",
        title="NASA APOD API",
        description="A Flask API to interact with NASA's Astronomy Picture of the Day",
        doc="/swagger",
        prefix="/api",
    )

    # Register API namespaces
    api.add_namespace(apod_namespace)

    # Register web UI blueprint
    app.register_blueprint(web_blueprint)

    return app
