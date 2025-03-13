"""Flask app to interact with NASA APOD API."""

import os

from src import create_app

app = create_app()

if __name__ == "__main__":
    debug_mode = os.environ.get("FLASK_DEBUG", "false").lower() == "true"
    app.run(debug=debug_mode)  # pragma: no cover
