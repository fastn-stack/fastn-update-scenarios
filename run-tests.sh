#!/bin/bash

# Function to log progress
log_progress() {
    # clear_terminal
    printf "\033c"
    echo "-- fastn update/performance test scenarios --"
    echo $1
}

process_logs() {
    echo "# $dir_name"
    echo

    # Process logs to count occurrences
    read_content_count=$(grep 'read_content' "$temp_trace_file" | wc -l)
    write_content_count=$(grep 'write_content' "$temp_trace_file" | wc -l)

    # Print counts in table
    echo "| Event Type       | Count            |"
    echo "| ---------------- | ---------------- |"
    echo "| read_content     | $read_content_count |"
    echo "| write_content     | $write_content_count |"
    
    # Extract read_content data
    echo "## Read Content Data:"
    
    grep -n 'read_content' "$temp_trace_file" | sed -n 's/.*read_content \([^ ]*\).*/- \1/p'

    # Extract write_content data
    echo "## Write Content Data:"
    
    grep -n 'write_content' "$temp_trace_file" | sed -n 's/.*write_content \([^ ]*\).*/- \1/p'

    echo
}

process_directory() {
    local dir=$1

    dir_name=$(basename "$dir")

    cd "$dir" || { echo "Error: Could not enter directory $dir"; return; }

    temp_trace_file="traces.log"
    report_file="REPORT.md"

    log_progress "Entered $dir_name"

    if [ -d ".packages" ]; then
        echo "Removing .packages directory"
        rm -rf .packages
        echo "Removed .packages directory"
    fi

    log_progress "Starting the server"
    
    (fastn --trace serve | tee "$temp_trace_file") > /dev/null 2>&1 &

    log_progress "Server started"

    log_progress "Testing $dir_name ..."

    sleep 2

    open -a Safari --background "http://127.0.0.1:8000/"

    sleep 5

    pkill Safari

    log_progress "$dir_name testing complete!"

    sh ../kill.sh > /dev/null 2>&1

    log_progress "Now generating report for $dir_name ..."

    process_logs > $report_file

    log_progress "Report generated for $dir_name!"

    cd ..
}

if [ $# -eq 0 ]; then
    for dir in */; do
        process_directory "$dir"
    done
else
    process_directory "$1"
fi

log_progress "All done!"
