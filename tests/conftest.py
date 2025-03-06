import pytest
from flask import Flask
import os
import sys

# Add the parent directory to sys.path to import your app module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import the app from the main file
from app import app as flask_app

@pytest.fixture
def app():
    """Create and configure a Flask app for testing."""
    # Set testing config
    flask_app.config.update({
        "TESTING": True,
    })
    
    yield flask_app

@pytest.fixture
def client(app):
    """A test client for the app."""
    return app.test_client()
