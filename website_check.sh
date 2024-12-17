#!/bin/bash

# Default Slack webhook URL
DEFAULT_SLACK_WEBHOOK=""

# Global flag for silent mode
SILENT=false

# Function to ensure the correct protocol is added
ensure_protocol() {
  local url="$1"
  if [[ $url == *localhost* ]]; then
    # If the URL contains localhost, ensure it starts with "http://"
    if [[ $url != http://* && $url != https://* ]]; then
      echo "http://$url"
    else
      echo "$url"
    fi
  else
    # For other URLs, ensure it starts with "https://"
    if [[ $url != http://* && $url != https://* ]]; then
      echo "https://$url"
    else
      echo "$url"
    fi
  fi
}

# Function to send Slack notification
send_slack_notification() {
  local message="$1"
  local webhook="$2"

  if [[ -z "$webhook" ]]; then
    echo "Error: No Slack webhook URL provided. Exiting..." >&2
    exit 1
  fi

  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$webhook" > /dev/null 2>&1
}

# Function to log messages (checks silent mode)
log() {
  if [[ $SILENT == false ]]; then
    echo "$1"
  fi
}

# Parse arguments for silent mode and positional parameters
SLACK_WEBHOOK="$DEFAULT_SLACK_WEBHOOK"
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -s|--silent) SILENT=true ;;
    *) 
      if [[ -z "$TARGET" ]]; then
        TARGET=$(ensure_protocol "$1")
      elif [[ -z "$SLACK_WEBHOOK" || "$SLACK_WEBHOOK" == "$DEFAULT_SLACK_WEBHOOK" ]]; then
        SLACK_WEBHOOK="$1"
      fi
      ;;
  esac
  shift
done

# Check if a target website was provided
if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 [-s|--silent] <website> [slack_webhook_url]" >&2
  exit 1
fi

# Check if the webhook URL is empty
if [[ -z "$SLACK_WEBHOOK" ]]; then
  echo "Error: Slack webhook URL is missing and no default is set. Exiting..." >&2
  exit 1
fi

# Slack message payload
MESSAGE="The website $TARGET has responded successfully!"

log "Checking $TARGET using curl. Waiting for a successful response..."

# Loop until the website responds with a 200 OK status
while true; do
  # Use curl to send a HEAD request with a timeout
  if curl -I --max-time 5 --silent --fail "$TARGET" > /dev/null; then
    log "$TARGET is responding!"
    send_slack_notification "$MESSAGE" "$SLACK_WEBHOOK"
    log "Slack notification sent. Exiting..."
    exit 0
  else
    log "No response from $TARGET. Retrying in 5 seconds..."
  fi

  # Wait 5 seconds before retrying
  sleep 5
done

