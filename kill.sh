#!/bin/bash

existing_serve_pids=$(pgrep -f "fastn --trace serve")

if [ -n "$existing_serve_pids" ]; then
    echo "Terminating previous fastn serve processes in $dir_name."
    kill -9 $(echo "$existing_serve_pids" | tr '\n' ' ')
    sleep 2  # Allow time for the processes to terminate

    # Check again to make sure processes have terminated
    still_running=$(pgrep -f "fastn --trace serve")
    if [ -n "$still_running" ]; then
        echo "Unable to terminate fastn serve processes. Skipping $dir_name."
        cd ..
        continue
    fi
fi
