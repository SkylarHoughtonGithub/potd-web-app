"""Web UI routes for the Flask application."""

from flask import render_template

from src.utils import fetch_apod_data
from src.web import web_blueprint


@web_blueprint.route("/")
def index():
    """Render index from template."""
    return render_template("index.html")


@web_blueprint.route("/today")
def apod_today():
    """Retrieve APOD api info and format flask app output."""
    template, context = fetch_apod_data()
    return render_template(template, **context)
