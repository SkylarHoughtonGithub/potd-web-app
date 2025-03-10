"""pytest configuration"""

import os
import sys

import pytest

from app import app as flask_app

# Add the parent directory to sys.path to import your app module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))


@pytest.fixture
def test_app():
    """Create and configure a Flask app for testing."""
    # Set testing config
    flask_app.config.update(
        {
            "TESTING": True,
        }
    )

    yield flask_app


@pytest.fixture
def client(app):
    """A test client for the app."""
    return app.test_client()
