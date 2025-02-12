#!/bin/bash

# Get the port number from the command-line argument.  Default to 8000 if not provided.
PORT="${1:-8000}"  # $1 is the first argument, :-8000 provides a default

# Check if the port number is a valid integer
if [[ ! "$PORT" =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid port number '$PORT'.  Please provide a positive integer."
  exit 1  # Exit with an error code
fi


# Get the process ID (PID) of the process listening on the specified port
PID=$(lsof -i :"$PORT" | grep LISTEN | awk '{print $2}')

# Check if a process is running on the specified port
if [[ -n "$PID" ]]; then
  echo "Process running on port $PORT found with PID: $PID"

  # Get process information *before* killing it
  PROCESS_INFO=$(ps -p "$PID" -o pid,comm,cmd)

  # Kill the process
  kill "$PID"

  # Verify if the process is killed
  if [[ ! -f /proc/$PID ]]; then
    echo "Process with PID $PID successfully killed."
    echo "Process information (before kill):"
    echo "$PROCESS_INFO"
  else
    echo "WARNING: Process with PID $PID could not be killed. Trying forceful kill..."
    kill -9 "$PID"
    if [[ ! -f /proc/$PID ]]; then
      echo "Process with PID $PID forcefully killed."
      echo "Process information (before kill):"
      echo "$PROCESS_INFO"
    else
      echo "ERROR: Process with PID $PID still could not be killed."
    fi
  fi
else
  echo "No process is running on port $PORT."
fi
