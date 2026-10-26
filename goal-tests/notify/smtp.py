#!/usr/bin/env python3
"""smtp.py SUBJECT BODY_FILE CONFIG: emails the notice with nothing but the Python standard library.

Config (goal-tests.config.json, notify.smtp):
  host, port, security ("starttls", "ssl" or "none"), username, from, to (a list),
  password_env: the NAME of the environment variable that holds the password.
The password itself never goes in the config. Put it in your owner-only secrets.env.
"""
import json
import os
import smtplib
import ssl
import sys
from email.message import EmailMessage


def main():
    subject, body_file, config = sys.argv[1], sys.argv[2], sys.argv[3]
    with open(config, encoding="utf-8") as fh:
        smtp = json.load(fh).get("notify", {}).get("smtp", {})
    for key in ("host", "from", "to"):
        if not smtp.get(key):
            print(f"smtp: notify.smtp.{key} is not set", file=sys.stderr)
            return 1
    password = os.environ.get(smtp.get("password_env", "GOAL_TESTS_SMTP_PASSWORD"), "")
    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = smtp["from"]
    msg["To"] = ", ".join(smtp["to"]) if isinstance(smtp["to"], list) else smtp["to"]
    with open(body_file, encoding="utf-8") as fh:
        msg.set_content(fh.read())
    security = smtp.get("security", "starttls")
    port = int(smtp.get("port", 465 if security == "ssl" else 587))
    ctx = ssl.create_default_context()
    try:
        if security == "ssl":
            server = smtplib.SMTP_SSL(smtp["host"], port, context=ctx, timeout=30)
        else:
            server = smtplib.SMTP(smtp["host"], port, timeout=30)
            if security == "starttls":
                server.starttls(context=ctx)
        with server:
            if smtp.get("username"):
                server.login(smtp["username"], password)
            server.send_message(msg)
    except (smtplib.SMTPException, OSError) as err:
        print(f"smtp: send failed: {err}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
