#!/bin/bash

INPUT_FILE="/tmp/shared_input.txt"
OUTPUT_FILE="/tmp/shared_output.txt"
SCRIPT_NAME="✍️ Writing Assistant"

# Ensure required commands are available
command -v wl-paste >/dev/null 2>&1 || { echo >&2 "❌ wl-paste is not installed."; exit 1; }
command -v wl-copy >/dev/null 2>&1 || { echo >&2 "❌ wl-copy is not installed."; exit 1; }

# Optional desktop notification (if available)
if command -v notify-send >/dev/null 2>&1; then
  notify-send "$SCRIPT_NAME" "Trigger detected! Processing clipboard text..."
fi

# Get text from clipboard
TEXT=$(wl-paste --no-newline --primary)
# fallback if empty
if [[ -z "$TEXT" ]]; then
  TEXT=$(wl-paste --no-newline)
fi

if [[ -z "$TEXT" ]]; then
  echo "⚠️ No text found in clipboard."
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$SCRIPT_NAME" "Clipboard was empty. Nothing to improve."
  fi
  exit 1
fi

# Write text to Docker input file
echo "$TEXT" > "$INPUT_FILE"
echo "📨 Sent text to container for processing..."

# Wait for Docker container to produce output
echo "⏳ Waiting for improved text..."
while [ ! -f "$OUTPUT_FILE" ]; do sleep 0.1; done

# Read improved output and copy it to clipboard
IMPROVED=$(cat "$OUTPUT_FILE")
rm "$OUTPUT_FILE"


sleep 0.1
echo "$IMPROVED" | wl-copy

# Confirm
echo "✅ Text improved and copied to clipboard!"

# Notify user (optional)
if command -v notify-send >/dev/null 2>&1; then
  notify-send "✍️ Writing Assistant" "✅ Text improved and ready to paste!"
fi
