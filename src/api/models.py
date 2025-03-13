"""API models for Swagger documentation."""

from flask_restx import fields

from src.api import apod_namespace

# Model for APOD response
apod_model = apod_namespace.model(
    "APOD",
    {
        "date": fields.String(required=True, description="The date of the APOD"),
        "explanation": fields.String(
            required=True, description="The explanation of the APOD"
        ),
        "title": fields.String(required=True, description="The title of the APOD"),
        "url": fields.String(required=True, description="The URL of the APOD image"),
        "media_type": fields.String(description="The media type of the APOD"),
        "service_version": fields.String(description="The service version"),
        "hdurl": fields.String(
            description="The high definition URL of the APOD image", required=False
        ),
        "copyright": fields.String(
            description="The copyright information", required=False
        ),
    },
)

# Model for error responses
error_model = apod_namespace.model(
    "Error", {"error": fields.String(required=True, description="Error message")}
)

# Model for query parameters
apod_query_params = apod_namespace.model(
    "APODQueryParams",
    {
        "date": fields.String(description="APOD date (YYYY-MM-DD)"),
        "start_date": fields.String(description="Start date for date range"),
        "end_date": fields.String(description="End date for date range"),
        "count": fields.Integer(description="Number of random APODs to retrieve"),
        "thumbs": fields.Boolean(
            description="Include thumbnail URLs for video media types"
        ),
    },
)
