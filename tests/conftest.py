"""Test configuration and fixtures."""

import sys
import os
from pathlib import Path
import pytest

# Add the project root directory to the Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# Import after path setup
from src import create_app  # pylint: disable=wrong-import-position

@pytest.fixture
def app():
    """Create and configure a Flask app for testing."""
    app = create_app()
    app.config.update({
        "TESTING": True,
        "NASA_API_KEY": "DEMO_KEY",
    })
    
    # Return test client
    with app.app_context():
        yield app

@pytest.fixture
def client(app):
    """Create a test client for the app."""
    return app.test_client()