# Integrating Google Calendar with OpenWebUI: Step-by-Step Guide

## Step 1: Set Up a Google Cloud Project and Enable Calendar API Access

Begin by creating or using a Google Cloud project and enabling the Google Calendar API for it. In the Google Cloud Console, go to the API Library and **enable the Google Calendar API** for your project. Enabling the API ensures your app can make Calendar requests. If you haven’t already, also create a Google account (or use an existing one) that has access to Google Calendar (most Google accounts do). This setup gives your OpenWebUI tool the necessary API access to manage calendar events.

## Step 2: Configure OAuth 2.0 Credentials (Desktop App)

Next, set up OAuth credentials so your tool can securely access the Calendar API on behalf of your Google account. In the Google Cloud Console, navigate to the **APIs & Services > Credentials** section. Click “Create Credentials” and choose **OAuth client ID**, then select **Application type: Desktop app**. Give it a name (e.g. “OpenWebUI Calendar Tool”) and click **Create**. The console will generate an OAuth 2.0 Client ID and Client Secret. **Download the JSON** configuration for this client (this is often done via a “Download JSON” button after creation) – it contains the `client_id`, `client_secret`, and other info. Save this file as **`credentials.json`** in a secure location (for example, in your OpenWebUI working directory or a config folder). You will supply this file to the tool in a later step. This credentials file allows your OpenWebUI plugin to initiate the OAuth flow with Google. *Note:* If this is a new project, you might need to configure an OAuth consent screen (with at least yourself as a test user) before Google allows the authentication – for personal use you can keep it in testing mode with your own account.

## Step 3: Install Google’s Python Client Library and Set Up Authentication Code

Ensure you have Python 3 installed on the system running OpenWebUI (Arch Linux likely already has this). Install the required Google API libraries using pip. From a terminal (or within OpenWebUI’s environment), run:

```bash
pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
```

This installs the Google Calendar API client and authentication libraries. Now, you’ll write the code to authenticate and perform calendar actions using these libraries. The OAuth flow will follow Google’s Python Quickstart pattern. Key points in the code: define the OAuth **scopes** your tool needs, load or obtain user credentials, then build a Calendar service object to call the API.

**Choose API Scopes:** For creating and editing events, include a calendar scope that allows read/write access. For example, you can use:

```python
SCOPES = ["https://www.googleapis.com/auth/calendar.events"]
```

This scope grants permission to view and modify events in calendars the user has access to. (You might also include `'.../auth/calendar.readonly'` for read access or other scopes as needed. If you want to restrict to only calendars the user owns, Google also offers a scope `.../auth/calendar.events.owned` – but using the general `calendar.events` is common for personal use.)

**Authenticate and Authorize:** Using the client library, implement the OAuth flow. Here’s a code snippet illustrating the process (this will later go inside your OpenWebUI tool, but we show it standalone first):

```python
import os
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build

# Set scopes for Calendar access
SCOPES = ["https://www.googleapis.com/auth/calendar.events"]

# Try to load existing credentials from token file
creds = None
if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
# If no valid creds, do OAuth flow
if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
        creds = flow.run_local_server(port=0)
    # Save the credentials for next time
    with open("token.json", "w") as token_file:
        token_file.write(creds.to_json())
        
# Build the Calendar API service
service = build("calendar", "v3", credentials=creds)
```

In this code, the tool first looks for an existing `token.json` (which will store OAuth access/refresh tokens after the first login). If present, it loads those credentials. If not (or if they’ve expired and can’t refresh), it triggers a new OAuth login by launching a local web server and opening your browser to let you log into Google and consent. This uses the `credentials.json` file you downloaded earlier to know how to request consent. After a successful login, the obtained credentials (including a refresh token) are saved to `token.json` for reuse. **Important:** Keep `token.json` safe – it allows access without re-prompting you. Do not share it, and if it’s ever compromised, revoke the credentials in your Google account.

With a valid `service` object (an authorized Calendar API client), you can now call Google Calendar API methods. For example, to **create an event** you would build an event resource and insert it:

```python
# Example event data:
event_data = {
    "summary": "Meeting with Alice",
    "start": {"dateTime": "2025-07-21T10:00:00", "timeZone": "Europe/Zurich"},
    "end":   {"dateTime": "2025-07-21T11:00:00", "timeZone": "Europe/Zurich"},
    "attendees": [ {"email": "alice@example.com"} ],
    "description": "Discuss project updates"
}
# Call the Calendar API to insert the event
event_result = service.events().insert(calendarId="primary", body=event_data, conferenceDataVersion=1).execute()
print("Event created: %s" % event_result.get('htmlLink'))
```

In this snippet, `calendarId="primary"` indicates we’re adding to the user’s primary calendar (you could use a specific calendar ID or keep it configurable). We passed a `conferenceDataVersion=1` parameter to request a Google Meet link as well (optional). The `event_data` includes key fields of the **event schema**:

* **summary** – the title of the event
* **start** – start date/time of the event (here using an RFC3339 timestamp with time zone)
* **end** – end date/time of the event (same format as start)
* **attendees** – a list of attendees (each attendee is an object with an email; in Python client you can just provide a list of `{'email': ...}` dicts)
* **description** – a description or notes for the event

Other common fields can include **location** (physical location or meeting URL), **reminders**, **recurrence**, etc. (The Google Calendar API’s Events resource defines many optional fields, but the above are the basics for a single one-time meeting.) When the insert call executes, it returns a full event object (including an `id`, and possibly an `htmlLink` to the calendar event). The printed output in our example shows the Calendar URL of the created event.

To **update an event**, you would typically fetch the event by its `eventId`, modify the fields, and then call `service.events().update(...)` or `service.events().patch(...)`. For example, to change the time of an event: fetch it with `service.events().get(calendarId="primary", eventId=EVENT_ID).execute()`, modify the `start`/`end` in the returned dict, and call `service.events().update(calendarId="primary", eventId=EVENT_ID, body=updated_event).execute()`. For quick edits (like just changing the time or title), you can also use `events().patch` with only the fields you want to change. To **delete** an event, use `service.events().delete(calendarId="primary", eventId=EVENT_ID).execute()` – this performs a permanent deletion (it doesn’t move to trash like in Gmail, it’s gone). Always handle possible exceptions (like `HttpError`) around these calls – for example, if the eventId is wrong or network fails, catch the error and respond accordingly (perhaps by informing the user the action failed).

## Step 4: Implement an OpenWebUI Tool Plugin for Calendar Actions

With the core Python logic figured out, wrap it into an OpenWebUI Tool plugin. OpenWebUI tools are defined in a single Python file that contains a special **metadata docstring** and a `Tools` class with your functions.

**Create the Tool File:** On your OpenWebUI server, create a new file (for example, `google_calendar_tool.py`). At the very top, include a docstring that OpenWebUI will read as metadata. For example:

```python
"""
title: Google Calendar Tool
author: Your Name
description: "Enables the assistant to create, update, or delete Google Calendar events via the Google Calendar API."
required_open_webui_version: 0.5.0
requirements: google-api-python-client, google-auth-httplib2, google-auth-oauthlib
version: 1.0.0
"""
```

This metadata provides a title, a short description, and specifies external Python packages the tool needs (OpenWebUI will ensure these are installed). The above `requirements` include the Google API client libraries we installed earlier. Adjust the `required_open_webui_version` if needed to match your OpenWebUI version (and include any license or author URL as desired).

**Define the Tools class:** Next, define a class named `Tools` in the file. Inside it, you can optionally define a nested `Valves` class for configuration values (more on that below), and then your tool methods. Each method will become a callable tool function that the LLM can use. Make sure to include **type hints** for all function parameters and return types – this is crucial for OpenWebUI to generate a proper JSON schema for function calling. Also document each function with a clear docstring, because the model will see these descriptions to decide how and when to use them.

For example, your `Tools` class might look like:

```python
from pydantic import BaseModel, Field
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import datetime

class Tools:
    def __init__(self):
        """Initialize the tool and its configuration valves."""
        self.valves = self.Valves()  # Load default valve values

    class Valves(BaseModel):
        credentials_path: str = Field("credentials.json", description="Path to Google API OAuth client JSON file")
        default_calendar_id: str = Field("primary", description="Which calendar ID to use by default for events")
        default_event_duration: int = Field(60, description="Default event duration in minutes if end time not provided")
        default_time_zone: str = Field("Europe/Zurich", description="Default time zone name for events (IANA format)")
    
    def create_event(self, summary: str, start_time: str, duration_minutes: int = None, attendees: list[str] = None, description: str = "") -> str:
        """
        Creates a calendar event on Google Calendar.
        :param summary: Title of the event.
        :param start_time: Start time of the event (ISO 8601 format datetime string, e.g. "2025-07-21T10:00:00").
        :param duration_minutes: Optional duration of the event in minutes. If not provided, uses default_event_duration.
        :param attendees: Optional list of attendee email addresses.
        :param description: Optional description for the event.
        :return: A confirmation message or details of the created event.
        """
        try:
            creds = self._get_credentials()
            service = build("calendar", "v3", credentials=creds)
            # Parse start_time string to a datetime object (if needed, or assume it's in correct format)
            start_dt = datetime.datetime.fromisoformat(start_time)  # expecting ISO format input
            if duration_minutes is None:
                duration_minutes = self.valves.default_event_duration
            end_dt = start_dt + datetime.timedelta(minutes=duration_minutes)
            event_body = {
                "summary": summary,
                "start": {"dateTime": start_dt.isoformat(), "timeZone": self.valves.default_time_zone},
                "end":   {"dateTime": end_dt.isoformat(), "timeZone": self.valves.default_time_zone},
            }
            if attendees:
                event_body["attendees"] = [ {"email": em} for em in attendees ]
            if description:
                event_body["description"] = description
            # Create event
            event = service.events().insert(calendarId=self.valves.default_calendar_id, body=event_body, conferenceDataVersion=1).execute()
            return f"Event created: {event.get('summary')} on {event.get('start').get('dateTime')}."
        except HttpError as error:
            return f"Failed to create event: {error}"
        except Exception as e:
            return f"Error: {e}"
```

*(The above is a conceptual example for illustration; your actual code can vary. The key is to follow the same pattern: get creds, build service, then call the API.)*

Let’s break down what’s happening: we have a `Valves` subclass defining configuration options like the path to the credentials file, default calendar ID (defaulting to `"primary"` which is the main calendar), default event duration (e.g. 60 minutes), and default time zone. These valves can be adjusted from the OpenWebUI interface later, without changing code. The `create_event` method takes the event details as arguments. Inside, it calls a helper `_get_credentials()` (you would implement `_get_credentials` similarly to the snippet in Step 3, using `self.valves.credentials_path` for the credentials file path, and handling token.json as shown earlier). With valid creds, it builds the calendar service and constructs the event body. We parse the provided `start_time` string to a datetime object for ease of calculation – if the user said “Friday at 10 AM” the model would need to convert that to a concrete datetime string; assuming it provides an ISO timestamp, we use that. If `duration_minutes` isn’t given by the model/user, we fall back to the default from valves (e.g. 60). Then we calculate the end time. We populate the `event_body` dict with **summary, start, end** (in ISO format with timezone). If attendees were provided, we add them (each as an object with an email field). If a description was provided, we add that too. Finally, we call the Calendar API `events().insert()` with `calendarId` from our valves (so it could be changed to another calendar if desired) and `conferenceDataVersion=1` to auto-generate a Meet link. On success, we return a simple confirmation string. On failure (any exception), we catch it and return an error message string – this way the assistant can convey the error to the user instead of crashing.

You would implement similar methods for updating or deleting events. For example, an `update_event` method might accept an `event_id` and new parameters (or perhaps a reference like "reschedule meeting titled X to new time Y" – the AI could find the event by querying upcoming events, but that’s an advanced use-case). For simplicity, you could provide `update_event(event_id: str, new_start_time: str = None, new_summary: str = None, ...)` and then in code, retrieve the event by ID and update the provided fields. A `delete_event(event_id: str)` method would call the API to delete that event and return a confirmation. Ensure each function has clear docstrings describing what it does, its parameters, and what it returns, since OpenWebUI will expose these to the model for decision-making.

Lastly, implement the `_get_credentials()` helper inside the class (or as a static function) to encapsulate the OAuth token logic (the code we sketched in Step 3). It should read `self.valves.credentials_path` to find the client secrets file, then either load `token.json` (you might store the token path as well, or just use working directory as in the quickstart) and refresh or run the flow as needed. This method will likely be identical to the standalone snippet from Step 3, except using the path from valves and perhaps storing token in the same directory. By structuring it this way, all your tool methods (create, update, delete) can simply call `_get_credentials()` to get a valid `creds` object before interacting with the API.

## Step 5: Install and Enable the Tool in OpenWebUI

After writing the tool code, you need to load it into OpenWebUI and enable it for your chat model. OpenWebUI provides a UI to manage tools. Go to the **Workspace > Tools** section in OpenWebUI. Click the “＋” (Add Tool) button to create a new custom tool. This will open an editor where you can paste your tool Python code. Give the tool a name and description (these might be pre-filled from your docstring metadata), and save it. OpenWebUI will install any listed `requirements` (internet connection needed for pip installs) and register the tool.

Once added, make sure the tool is **enabled for your model**. You can do this by going to your model’s settings or the chat interface and selecting the tool. In OpenWebUI’s chat UI, there may be a toggle or a menu to activate tools for the current session – ensure your Google Calendar tool is active (before you send a prompt). If you’re using an Ollama backend with a local LLM, note that the model should ideally support function calling (OpenWebUI uses the function calling paradigm to let the model decide when to use a tool). Many modern models (like GPT-3.5/4 via API, or local fine-tuned models that support the OpenAI function calling format) can work. If your model doesn’t reliably produce function call JSON, you might need to put it in **“Native” function calling mode** in OpenWebUI settings or use a system prompt to encourage tool use. But assuming a compatible setup, simply enabling the tool for the model will allow OpenWebUI to inject the tool schemas to the model.

At this point, OpenWebUI knows about the functions `create_event`, `update_event`, etc. from your `Tools` class, and the model can call them as needed.

## Step 6: Secure OAuth Token Handling and Tool Configuration

Proper handling of credentials and tokens is important for security and smooth operation. Here are some best practices and configurations:

* **Credentials File:** The OAuth client `credentials.json` (containing your Google client ID/secret) should be kept private. In the tool code above, we referenced a path (defaulting to `"credentials.json"` in the same directory). You can place this file in the OpenWebUI server directory (or another secure path) and update the valve `credentials_path` accordingly. OpenWebUI Valves allow you to configure this path from the UI if needed. For example, if you stored it in `/home/user/.config/mycred.json`, you could update the tool’s `credentials_path` valve in the UI to that value. Alternatively, some tools (like community versions) let you paste the **contents** of the credentials JSON into a valve (often called `google_credentials`). In that approach, the tool code would load the JSON data from the valve string instead of a file – this avoids storing the file separately, but means the secret is stored in OpenWebUI’s config. Use whichever method you’re comfortable with, but **never hard-code** your client secret directly in the tool source. Valves and external files are better since they can be changed or revoked without editing code.

* **Token Storage:** When the OAuth flow is first triggered, the browser window will ask you to log in and grant permission. After you complete that, the tool will save an OAuth token in a file (e.g., `token.json` as shown). This file contains your access token and refresh token. **Keep this file safe**. By default, our code saved it in the working directory (likely the OpenWebUI launch directory). You might prefer to specify an absolute path for it. You could modify `_get_credentials()` to save token.json alongside the credentials file or in a designated config folder. The token allows the tool to access your calendar until it expires or is revoked, so treat it like a password. The token file is automatically used in subsequent runs to refresh tokens as needed, so you typically won’t need to log in again unless the token expires and refresh fails or you delete the file. Do not share this file, and if you suspect it was exposed, revoke the app’s access in your Google account security settings.

* **OpenWebUI Valves for Config:** We defined valves for things like default calendar, default duration, time zone, etc. Once the tool is loaded, you can view and adjust these settings in OpenWebUI’s Tools config UI. For example, if you want events to default to 30 minutes instead of 60, change `default_event_duration` to 30. If your Google account uses a different primary calendar or you want to target a specific calendar ID, update `default_calendar_id`. If your time zone is different, set `default_time_zone` (time zone is used when constructing event datetimes; Google Calendar will accept events in any timezone, so it’s good to specify one to avoid ambiguity). These valves make the tool flexible without code changes.

* **Permissions and Security:** The first time you use the tool (when it calls `_get_credentials()` and doesn’t find a token), **Google’s OAuth consent** will pop up in your browser. Since this is a Desktop app OAuth flow, it opens a localhost redirect. Make sure the system running OpenWebUI can open a browser, or if it’s headless, you might need to copy a URL – but the `run_local_server` typically handles it if you have any browser available on that machine. Complete the consent (it will say something like "This app isn't verified" if it’s just for your own use – you can proceed because it’s your app). After consenting, watch the OpenWebUI logs or console – it should log that credentials have been saved. Now token.json is stored for next time. From now on, the tool will use the refresh token to get new access tokens as needed without user intervention.

* **Using OpenWebUI’s Valve System for Sensitive Data:** As mentioned, valves could store the entire credentials JSON content (some community tools use a `google_credentials` text field where you paste the JSON). This keeps everything in OpenWebUI’s database. It’s convenient but ensure your OpenWebUI instance is secure (not exposed to untrusted users), since anyone with admin access to OpenWebUI could view that data. The file-based approach keeps secrets on the file system, which might be preferable in some cases. Either way, *avoid exposing secrets in the chat or logs*. The tool’s code should not print the credentials or token anywhere public. Logging of just actions (like “Event created...”) is fine.

In summary, after configuring, you should have in your tool’s valves: the correct path to `credentials.json` (or the JSON content), and any default values you want to tweak (calendar, duration, timezone). The **combination of credentials.json + initial OAuth + token.json** is what allows the tool to act on your calendar. As a final security note, Google’s tokens will eventually expire if not used for a long time or if the permissions are revoked. If your tool stops working due to auth errors, you might need to delete token.json and let it re-authenticate, or check Google Cloud console for any changes (like publishing status or consent screen issues).

## Step 7: Test the End-to-End Workflow

Now it’s time to test your integration. Ensure OpenWebUI is running, your model is loaded, and the Google Calendar tool is enabled. Try an **interactive prompt** that should trigger the tool. For example, in the chat prompt to your assistant, you might say:

**User:** *“Add a meeting on Friday at 10 AM called Project Sync with Alice.”*

Given the tool and its function descriptions, the LLM should recognize this request involves scheduling an event. It will parse the details (“Friday at 10 AM” as a date/time, “Project Sync with Alice” as the title, possibly infer Alice as an attendee if it has context of her email or ask for it). The model will then decide to call the `create_event` function with the extracted parameters. If everything is set up properly, you should see the OpenWebUI interface indicate a tool function call (and possibly a temporary “working...” status). The tool will execute the API call to Google Calendar. If successful, the assistant’s answer might be something like: *“Sure, I’ve added **Project Sync with Alice** on Fri July 21 at 10:00 AM.”* (It might use the return string from our function, which we formatted as "Event created..." etc.). Check your actual Google Calendar in the browser or on your phone – the new event should appear (possibly within seconds, as the API call is immediate). 🎉

Next, test editing. You could say:

**User:** *“Actually, move that meeting to 11 AM and change the title to Project Review.”*

The model should figure out you mean the event we just created. If your `update_event` function is implemented, it might call `update_event` with the event’s ID and new parameters. (Note: identifying the correct `event_id` is tricky from just natural language – the model might have to search the calendar or keep track of what it created. A simple approach during testing is that there’s only one such recent event, or the model might have gotten the `event_id` if the create function returned it invisibly. In a real assistant, one might implement a search by title or store context. But for a controlled test, you might guide it by providing the event ID explicitly: e.g., *“Update event `<ID>` to start at 11:00.”* if needed.) The tool’s update function would adjust the time and title via the Calendar API. The assistant should confirm the change, and you can verify the event updated in Google Calendar.

Also try the **delete** path:

**User:** *“Please delete the Project Review meeting from my calendar.”*

The model may call `delete_event` with the appropriate event ID. The tool will execute the deletion, and the assistant might say “Deleted the event.” Check your calendar to ensure it's gone.

Throughout these tests, watch the OpenWebUI logs for any errors. Common issues could be: mis-parsed date/time (the model gave a format not expected – you may need to refine the prompt or the parsing in code), wrong email format for attendees, missing authentication (if the tool wasn’t authorized yet – you’d get an OAuth prompt). Resolve any issues by adjusting the code or valves. For instance, if the model tends to pass "Friday 10am" as input directly, you might incorporate a natural language time parser in your code (or have the model call a separate `parse_datetime` tool – though a simpler way is to prompt the model to output ISO timestamps). You can also explicitly instruct the model (via system prompt or user prompt) to provide times in a standard format.

**Confirmation & Safety:** In a real deployment, it’s wise to have the AI assistant confirm actions with the user before finalizing them. The OpenWebUI community guide strongly suggests that for tools which modify user data (emails, calendar events), the AI should double-check with the user. For example, the assistant could say “I will schedule **Project Sync with Alice** on Friday at 10 AM. Should I proceed?” and only call `create_event` after you say yes. This prevents mistakes or unwanted actions. You can implement this protocol by including it in the system prompt (as shown in the OpenWebUI example system prompt in the Google tools README). While testing, you might bypass confirmation for convenience, but for normal use it’s a good practice to include.

Finally, once the workflow is confirmed working: you can now add events to Google Calendar just by chatting with your AI! The integration allows natural language like *“Schedule a 30-minute call with Bob tomorrow at 3pm”* to translate into real calendar events. Be sure to maintain your credentials (if the Google token expires after long disuse, you may need to re-run the OAuth flow). With OAuth 2.0 and the Google Calendar API, your OpenWebUI assistant can manage your schedule hands-free. Happy scheduling!

**Sources:**

* Google Developers – Calendar API Python Quickstart
* Google Developers – Calendar API scopes and event creation guide
* OpenWebUI Documentation – Creating Custom Tools and using Valves
* OpenWebUI Community Forum – Google Tools integration code and best practices
* *P. Hautelman, “Beyond Text: Equipping Your Open WebUI AI with Action Tools,”* OpenWebUI Mastery Series (example of Google Meet Scheduling Tool)
