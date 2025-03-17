#!/bin/bash

# Path to the file to monitor
MONITOR_FILE="/home/olof/dev/osandell/tomatoland/tomatoland"
PS_SCRIPT="./windows-notifier.ps1"
WIN_PS_SCRIPT=$(wslpath -w "$PS_SCRIPT")

# Initialize with empty content
LAST_CONTENT=""

# Function to check file and send notification if changed
check_and_notify() {
    # Check if file exists
    if [ -f "$MONITOR_FILE" ]; then
        # Get current content
        CURRENT_CONTENT=$(cat "$MONITOR_FILE")
        
        # Only notify if content changed and is not empty
        if [ "$CURRENT_CONTENT" != "$LAST_CONTENT" ] && [ -n "$CURRENT_CONTENT" ]; then
            # Parse first line as title (if multiple lines)
            TITLE="Tomatoland"
            MESSAGE=$(echo "$CURRENT_CONTENT" | head -n 1)
            
            # Call PowerShell with parameters
            /mnt/c/Windows/System32/WindowsPowerShell/v1.0//powershell.exe -ExecutionPolicy Bypass -File "$WIN_PS_SCRIPT" -Title "$TITLE" -Message "$MESSAGE" -Duration 2000
            
            # Update last content
            LAST_CONTENT="$CURRENT_CONTENT"
        fi
    fi
}

# Main loop to monitor the file
echo "Monitoring $MONITOR_FILE for changes..."
while true; do
    check_and_notify
    sleep 1
done
