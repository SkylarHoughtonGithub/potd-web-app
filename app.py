"""Flask app to interact NASA APOD api."""

import os

import requests
from flask import Flask, render_template

# Set debug mode based on environment variable, defaulting to False
debug_mode = os.environ.get("FLASK_DEBUG", "false").lower() == "true"

app = Flask(__name__)


@app.route("/")
def index():
    """Render index from template."""
    return render_template("index.html")


@app.route("/nasa_flask_app.html")
def nasa_flask_app():
    """Retrieve APOD api info and format flask app output."""
    api_key = os.environ.get("NASA_API_KEY")

    try:
        response = requests.get(
            f"https://api.nasa.gov/planetary/apod?api_key={api_key}", timeout=5
        )
        response.raise_for_status()  # Raise an exception for 4XX/5XX responses

        response_dict = response.json()

        # Extract data with defaults in case keys are missing
        date = response_dict.get("date", "Unknown date")
        explanation = response_dict.get("explanation", "No explanation available")
        image_url = response_dict.get("url", "")
        title = response_dict.get("title", "Unknown title")

        return render_template(
            "nasa_flask_app.html",
            date=date,
            explanation=explanation,
            image_url=image_url,
            title=title,
        )

    except requests.exceptions.RequestException as e:
        # Handle request errors
        error_message = f"Error fetching NASA APOD: {str(e)}"
        return render_template("error.html", error=error_message)


if __name__ == "__main__":
    app.run(debug=debug_mode)  # pragma: no cover
