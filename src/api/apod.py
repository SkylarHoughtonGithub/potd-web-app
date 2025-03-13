"""APOD API endpoint definitions."""

import requests
from flask_restx import Resource

from src.api import apod_namespace

# Import models after namespace to avoid circular imports
from src.api.models import apod_model, error_model
from src.utils import make_nasa_api_request


@apod_namespace.route("")
class APOD(Resource):
    """NASA APOD resource."""

    @apod_namespace.doc(
        "get_apod",
        params={
            "date": "APOD date (YYYY-MM-DD)",
            "start_date": "Start date for date range",
            "end_date": "End date for date range",
            "count": "Number of random APODs to retrieve",
            "thumbs": "Include thumbnail URLs for video media types",
        },
    )
    @apod_namespace.response(200, "Success", apod_model)
    @apod_namespace.response(400, "Bad Request", error_model)
    @apod_namespace.response(500, "Internal Server Error", error_model)
    def get(self):  # pylint: disable=inconsistent-return-statements
        """Get Astronomy Picture of the Day.

        Returns:
            dict: APOD data or error message
        """
        # Get query parameters from the request
        parser = apod_namespace.parser()
        parser.add_argument("date", type=str, help="APOD date (YYYY-MM-DD)")
        parser.add_argument("start_date", type=str, help="Start date for date range")
        parser.add_argument("end_date", type=str, help="End date for date range")
        parser.add_argument(
            "count", type=int, help="Number of random APODs to retrieve"
        )
        parser.add_argument(
            "thumbs", type=bool, help="Include thumbnail URLs for video media types"
        )
        args = parser.parse_args()

        # Build query parameters
        params = {}
        for key, value in args.items():
            if value is not None:
                params[key] = value

        try:
            data = make_nasa_api_request(params)
            return data
        except (
            requests.exceptions.RequestException
        ) as e:  # pylint: disable=broad-exception-caught
            apod_namespace.abort(500, f"Error fetching NASA APOD: {str(e)}")
