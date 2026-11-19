"""AI review for the Phase 5 pipeline: sends the review prompt and the plan JSON
to Gemini on Vertex AI and prints the answer, ending with a VERDICT line.

Auth: the Google credentials from the workflow's auth step (Workload Identity
Federation). No API key is needed.

Usage (from environments/dev):
  python ../../review/ai_review.py --prompt ../../review/review-prompt.txt --input tfplan.json
"""
import argparse
import json
import os
import sys

import google.auth
from google.auth.transport.requests import AuthorizedSession

parser = argparse.ArgumentParser()
parser.add_argument("--prompt", required=True)
parser.add_argument("--input", required=True)
parser.add_argument("--model", default=os.environ.get("REVIEW_MODEL", "gemini-3.5-flash"))
parser.add_argument("--location", default=os.environ.get("REVIEW_LOCATION", "global"))
args = parser.parse_args()

prompt = open(args.prompt, encoding="utf-8").read()
plan = json.load(open(args.input, encoding="utf-8"))

# Send only what the review needs: the planned changes and any drift.
slim = {
    "resource_changes": plan.get("resource_changes", []),
    "resource_drift": plan.get("resource_drift", []),
}

creds, project = google.auth.default(scopes=["https://www.googleapis.com/auth/cloud-platform"])
project = os.environ.get("GOOGLE_CLOUD_PROJECT") or project
host = "aiplatform.googleapis.com" if args.location == "global" else f"{args.location}-aiplatform.googleapis.com"
url = (f"https://{host}/v1/projects/{project}/locations/{args.location}"
       f"/publishers/google/models/{args.model}:generateContent")

body = {
    "contents": [{
        "role": "user",
        "parts": [{"text": prompt + "\n\nPLAN JSON:\n" + json.dumps(slim)}],
    }],
    "generationConfig": {"temperature": 0},
}

resp = AuthorizedSession(creds).post(url, json=body, timeout=120)
if resp.status_code != 200:
    sys.exit(f"Vertex AI call failed: {resp.status_code} {resp.text[:500]}")

candidates = resp.json().get("candidates", [])
text = "".join(p.get("text", "") for p in candidates[0]["content"]["parts"]) if candidates else ""
text = text.replace("**", "")   # models sometimes bold the verdict; the pipeline greps plain text
print(text)

if not any(line.strip().startswith("VERDICT:") for line in text.splitlines()):
    sys.exit("AI review returned no VERDICT line")