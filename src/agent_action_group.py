import json
from aws_lambda_powertools import Logger

logger = Logger()

# Dummy data for available events
AVAILABLE_EVENTS = [
    {"event": "Rock Concert", "date": "2025-06-20", "city": "New York"},
    {"event": "Jazz Festival", "date": "2025-06-20", "city": "New York"},
    {"event": "Tech Conference", "date": "2025-06-20", "city": "San Francisco"},
    {"event": "Food Expo", "date": "2025-06-20", "city": "Chicago"},
]


def handle_available_events(params):
    """Handle the /available_events route to find events by date and city."""
    date = params.get("date")
    city = params.get("city")
    logger.info(f"date: {date}")
    logger.info(f"city: {city}")

    # Demo-friendly: Try to return something if either city or date matches
    events = []
    if date and city:
        events = [
            e
            for e in AVAILABLE_EVENTS
            if (date == "CURRENT_MONTH" or e["date"] == date)
            and e["city"].lower() == city.lower()
        ]
        # If no exact match, try city only
        if not events:
            events = [e for e in AVAILABLE_EVENTS if e["city"].lower() == city.lower()]
        # If still no match, try date only
        if not events and date:
            events = [
                e
                for e in AVAILABLE_EVENTS
                if e["date"] == date or date == "CURRENT_MONTH"
            ]
    elif city:
        events = [e for e in AVAILABLE_EVENTS if e["city"].lower() == city.lower()]
    elif date:
        events = [
            e for e in AVAILABLE_EVENTS if e["date"] == date or date == "CURRENT_MONTH"
        ]

    # Always return a message if no events found
    if not events:
        message = (
            "No events found for the given parameters, but please check back later!"
        )
    else:
        message = f"Found {len(events)} event(s) for your query."

    return {"events": events, "message": message}


def create_api_response(event, response_obj, status_code=200):
    """Create a standardized API response for Bedrock Agent."""
    response_body = {"application/json": {"body": json.dumps(response_obj)}}
    action_response = {
        "actionGroup": event["actionGroup"],
        "apiPath": event["apiPath"],
        "httpMethod": event["httpMethod"],
        "httpStatusCode": status_code,
        "responseBody": response_body,
    }
    return {
        "messageVersion": "1.0",
        "response": action_response,
        "sessionAttributes": event.get("sessionAttributes", {}),
        "promptSessionAttributes": event.get("promptSessionAttributes", {}),
    }


@logger.inject_lambda_context
def handler(event, context):
    try:
        logger.info("Processing event")
        logger.info(event)

        # Extract apiPath from event
        api_path = event.get("apiPath")
        logger.info(f"API Path: {api_path}")

        # Extract parameters
        params = {p["name"]: p["value"] for p in event.get("parameters", [])}
        logger.info("params", params)

        # Route to the appropriate handler based on apiPath
        if api_path == "/available_events":
            response_obj = handle_available_events(params)
        else:
            response_obj = {"error": f"Unsupported API path: {api_path}"}
            return create_api_response(event, response_obj, 400)

        return create_api_response(event, response_obj)
    except Exception as e:
        logger.error("Error processing event", e)
        error_obj = {"error": str(e)}
        return create_api_response(event, error_obj, 500)
