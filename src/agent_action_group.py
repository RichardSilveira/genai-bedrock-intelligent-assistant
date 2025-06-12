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


@logger.inject_lambda_context
def handler(event, context):
    try:
        logger.info("Processing event")
        logger.info(event)
        # Bedrock Agent passes parameters as an array of dicts under event["parameters"]

        params = {p["name"]: p["value"] for p in event.get("parameters", [])}
        logger.info("params", params)

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
                events = [
                    e for e in AVAILABLE_EVENTS if e["city"].lower() == city.lower()
                ]
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
                e
                for e in AVAILABLE_EVENTS
                if e["date"] == date or date == "CURRENT_MONTH"
            ]

        # Always return a message if no events found
        if not events:
            message = (
                "No events found for the given parameters, but please check back later!"
            )
        else:
            message = f"Found {len(events)} event(s) for your query."
        response_obj = {"events": events, "message": message}

        # Bedrock Agent OpenAPI action group response format
        response_body = {"application/json": {"body": json.dumps(response_obj)}}
        action_response = {
            "actionGroup": event["actionGroup"],
            "apiPath": event["apiPath"],
            "httpMethod": event["httpMethod"],
            "httpStatusCode": 200,
            "responseBody": response_body,
        }
        api_response = {
            "messageVersion": "1.0",
            "response": action_response,
            "sessionAttributes": event.get("sessionAttributes", {}),
            "promptSessionAttributes": event.get("promptSessionAttributes", {}),
        }
        return api_response
    except Exception as e:
        logger.error("Error processing event", e)
        return {
            "messageVersion": "1.0",
            "response": {
                "actionGroup": event.get("actionGroup", ""),
                "apiPath": event.get("apiPath", ""),
                "httpMethod": event.get("httpMethod", ""),
                "httpStatusCode": 500,
                "responseBody": {
                    "application/json": {"body": json.dumps({"error": str(e)})}
                },
            },
            "sessionAttributes": event.get("sessionAttributes", {}),
            "promptSessionAttributes": event.get("promptSessionAttributes", {}),
        }
