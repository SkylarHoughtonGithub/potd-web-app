"""API route test assertions."""

from unittest.mock import MagicMock, patch

import requests


def test_root_redirect(client):
    """Test that the root route redirects to web index."""
    response = client.get("/")
    assert response.status_code == 302  # Redirect status code
    assert response.location == "/web/"  # Redirects to web blueprint


def test_web_index_route(client):
    """Test that the web index route returns 200."""
    response = client.get("/web/")
    assert response.status_code == 200
    # Check for expected content in index.html


@patch("requests.get")
def test_apod_today_success(mock_get, client):
    """Test the APOD today route with a successful API response."""
    # Mock the response from the NASA API
    mock_response = MagicMock()
    mock_response.json.return_value = {
        "date": "2023-01-01",
        "explanation": "Test explanation",
        "url": "https://example.com/image.jpg",
        "title": "Test Title",
    }
    mock_response.raise_for_status.return_value = None
    mock_get.return_value = mock_response

    response = client.get("/web/today")

    assert response.status_code == 200
    # Check if the response contains the expected data
    assert b"Test Title" in response.data
    assert b"Test explanation" in response.data
    assert b"2023-01-01" in response.data
    assert b"https://example.com/image.jpg" in response.data


@patch("requests.get")
def test_apod_today_missing_fields(mock_get, client):
    """Test the APOD today route with missing fields in API response."""
    # Mock the response with missing fields
    mock_response = MagicMock()
    mock_response.json.return_value = {
        # Only provide title, missing other fields
        "title": "Test Title Only"
    }
    mock_response.raise_for_status.return_value = None
    mock_get.return_value = mock_response

    response = client.get("/web/today")

    assert response.status_code == 200
    # Verify fallback values are used for missing fields
    assert b"Test Title Only" in response.data
    assert b"No explanation available" in response.data
    assert b"Unknown date" in response.data


@patch("requests.get")
def test_apod_today_api_error(mock_get, client):
    """Test the APOD today route when the API returns an error."""
    # Mock a failed API request
    mock_get.side_effect = requests.exceptions.RequestException("Test API error")

    response = client.get("/web/today")

    assert response.status_code == 200  # Still returns 200 but renders error template
    assert b"Error fetching NASA APOD" in response.data
    assert b"Test API error" in response.data


@patch("requests.get")
def test_api_apod_success(mock_get, client):
    """Test the API APOD endpoint with a successful response."""
    # Mock the response from the NASA API
    mock_response = MagicMock()
    mock_response.json.return_value = {
        "date": "2023-01-01",
        "explanation": "Test explanation",
        "url": "https://example.com/image.jpg",
        "title": "Test Title",
    }
    mock_response.raise_for_status.return_value = None
    mock_get.return_value = mock_response

    response = client.get("/api/apod")

    assert response.status_code == 200
    assert response.json["title"] == "Test Title"
    assert response.json["explanation"] == "Test explanation"
