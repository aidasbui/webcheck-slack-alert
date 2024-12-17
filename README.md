# Website Health Checker with Slack Notifications

This Bash script checks if a given website is responding successfully by sending an HTTP `HEAD` request using `curl`. Once the website responds successfully, the script sends a notification to a Slack channel via a webhook and exits.

---

## Features

- Supports checking any URL or domain.
- Automatically adds `https://` if no protocol is provided.
- Handles `localhost` specifically by ensuring it uses `http://` if no protocol is provided.
- Notifies a specified Slack channel once the website becomes available.
- Retries every 5 seconds until the website responds.
- Add `-s` or `--silent` to run the script without any output.

---

## Usage

1. **Prerequisites**:
   - `curl` must be installed (pre-installed on most systems, including macOS).
   - A Slack webhook URL.

2. **Setup**:
   Save the script locally, e.g., as `website_check.sh`.

3. **Make the Script Executable**:
   ```bash
   chmod +x website_check.sh
   ```

4. **Run the Script**:
   Provide the website URL as an argument:

   ```bash
   ./website_check.sh <website> [slack_webhook_url]
   ```

   To run the script in silent mode:

   ```bash
   ./website_check.sh -s <website> [slack_webhook_url]
   ```

If you want to run the script in the background, just add `&` at the very end of the call:
 ```bash
   ./website_check.sh <website> [slack_webhook_url] &
 ```
---

## Arguments

| Argument         | Description                                           | Example Input           | Behavior                               |
|------------------|-------------------------------------------------------|-------------------------|----------------------------------------|
| `<website>`      | The website or domain to check.                      | `example.com`           | Adds `https://` if missing.            |
|                  |                                                       | `http://example.com`    | Keeps `http://` as provided.           |
|                  |                                                       | `localhost`             | Adds `http://` for localhost.          |
|                  |                                                       | `localhost:3000`        | Keeps `http://localhost:3000`.         |
|                  |                                                       | `https://example.com`   | Keeps `https://` as provided.          |
| `-s` / `--silent`| Suppress all output except errors or important messages. | `-s` or `--silent`     | Runs silently, with no output.         |
| `[slack_webhook_url]` | (Optional) Custom Slack webhook URL.               | `https://hooks.slack...`| Overrides the default webhook URL.     |

---

## Behavior

1. The script checks if the provided website responds with an HTTP 2xx status code using `curl -I`.
2. If no protocol (`http://` or `https://`) is provided:
   - Adds `https://` for general domains (e.g., `example.com`).
   - Adds `http://` for `localhost` URLs.
3. If the website does not respond:
   - Retries every **5 seconds**.
   - Displays a message indicating a retry (unless in silent mode).
4. Once the website responds:
   - Sends a notification to a Slack channel using the provided webhook URL.
   - Exits the script.

---

## Example Runs

### 1. Check a Domain Without Protocol:
```bash
./website_check.sh example.com
```
**Behavior**:
- Automatically checks `https://example.com`.

### 2. Check a Localhost URL:
```bash
./website_check.sh localhost:3000
```
**Behavior**:
- Automatically checks `http://localhost:3000`.

### 3. Check a URL With Silent Mode:
```bash
./website_check.sh -s example.com
```

### 4. Provide a Custom Slack Webhook:
```bash
./website_check.sh example.com https://hooks.slack.com/services/NEW/WEBHOOK/URL
```

---

## Slack Integration

The script sends a notification to a Slack channel using a webhook. Update the `SLACK_WEBHOOK` variable in the script with your Slack webhook URL:

```bash
SLACK_WEBHOOK="https://hooks.slack.com/services/..." 
```

The message sent to Slack will look like this:

> *"The website https://example.com has responded successfully!"*

---

## License

This script is provided under the MIT License. Feel free to modify and use it in your projects.
