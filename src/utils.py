"""Utility functions for the application."""

import requests
from flask import current_app


def fetch_apod_data():
    """Fetch APOD data from NASA API for web templates.

    Returns:
        tuple: (template_name, template_context) or (error_template, error_context)
    """
    try:
        response_dict = make_nasa_api_request()

        # Extract data with defaults in case keys are missing
        context = {
            "date": response_dict.get("date", "Unknown date"),
            "explanation": response_dict.get("explanation", "No explanation available"),
            "image_url": response_dict.get("url", ""),
            "title": response_dict.get("title", "Unknown title"),
        }

        return "apod_template.html", context
    except requests.exceptions.RequestException as e:
        # Handle request errors
        error_context = {"error": f"Error fetching NASA APOD: {str(e)}"}
        return "error.html", error_context


def make_nasa_api_request(additional_params=None):
    """Make a request to the NASA APOD API.

    Args:
        additional_params (dict, optional): Additional query parameters.

    Returns:
        dict: The API response data.

    Raises:
        requests.exceptions.RequestException: If the API request fails.
    """
    api_key = current_app.config.get("NASA_API_KEY")
    api_url = current_app.config.get("NASA_APOD_URL")

    # Build query parameters
    params = {"api_key": api_key}
    if additional_params:
        params.update(additional_params)

    response = requests.get(api_url, params=params, timeout=5)
    response.raise_for_status()

    return response.json()
