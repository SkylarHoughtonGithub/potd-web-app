import pytest
import requests
from unittest.mock import patch, MagicMock

def test_index_route(client):
    """Test that the index route returns 200 and renders template."""
    response = client.get('/')
    assert response.status_code == 200
    # You might want to check for some expected content in your index.html template
    # For example, if your index page contains a title or specific text
    # assert b'Your expected content' in response.data

@patch('requests.get')
def test_nasa_flask_app_success(mock_get, client):
    """Test the NASA APOD route with a successful API response."""
    # Mock the response from the NASA API
    mock_response = MagicMock()
    mock_response.json.return_value = {
        'date': '2023-01-01',
        'explanation': 'Test explanation',
        'url': 'https://example.com/image.jpg',
        'title': 'Test Title'
    }
    mock_response.raise_for_status.return_value = None
    mock_get.return_value = mock_response
    
    response = client.get('/nasa_flask_app.html')
    
    assert response.status_code == 200
    # Check if the response contains the expected data
    assert b'Test Title' in response.data
    assert b'Test explanation' in response.data
    assert b'2023-01-01' in response.data
    assert b'https://example.com/image.jpg' in response.data

@patch('requests.get')
def test_nasa_flask_app_missing_fields(mock_get, client):
    """Test the NASA APOD route with missing fields in API response."""
    # Mock the response with missing fields
    mock_response = MagicMock()
    mock_response.json.return_value = {
        # Only provide title, missing other fields
        'title': 'Test Title Only'
    }
    mock_response.raise_for_status.return_value = None
    mock_get.return_value = mock_response
    
    response = client.get('/nasa_flask_app.html')
    
    assert response.status_code == 200
    # Verify fallback values are used for missing fields
    assert b'Test Title Only' in response.data
    assert b'No explanation available' in response.data
    assert b'Unknown date' in response.data

@patch('requests.get')
def test_nasa_flask_app_api_error(mock_get, client):
    """Test the NASA APOD route when the API returns an error."""
    # Mock a failed API request
    mock_get.side_effect = requests.exceptions.RequestException("Test API error")
    
    response = client.get('/nasa_flask_app.html')
    
    assert response.status_code == 200  # It should still return 200 but render the error template
    assert b'Error fetching NASA APOD' in response.data
    assert b'Test API error' in response.data