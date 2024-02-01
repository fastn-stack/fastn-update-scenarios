#!/bin/bash

process_logs() {
    echo "# $dir_name"
    echo

    # Process logs to count occurrences
    read_content_count=$(grep 'read_content' "$temp_trace_file" | wc -l)

    # Print counts in table
    echo "| Event Type       | Count            |"
    echo "| ---------------- | ---------------- |"
    echo "| read_content     | $read_content_count |"
    
    # Extract read_content data
    echo "## Read Content Data:"
    echo "- $(grep 'read_content' "$temp_trace_file" | sed -n 's/.*read_content \([^ ]*\).*/\1/p' | tr '\n' '\n- ' | sed '$s/- $//')"

    echo
}

process_directory() {
    local dir=$1

    dir_name=$(basename "$dir")

    cd "$dir" || { echo "Error: Could not enter directory $dir"; return; }

    temp_trace_file="traces.log"
    report_file="REPORT.md"

    echo "Processing $dir_name ..."
    
    fastn update > /dev/null 2>&1
    
    (fastn --trace serve --offline | tee "$temp_trace_file") > /dev/null 2>&1 &

    sleep 2

    open -a Safari --background "http://127.0.0.1:8000/"

    sleep 5

    pkill Safari

    sh ../kill.sh > /dev/null 2>&1

    echo "Generating report for $dir_name ..."

    process_logs > $report_file

    echo "Report generated for $dir_name ..."

    cd ..
}

if [ $# -eq 0 ]; then
    for dir in */; do
        process_directory "$dir"
    done
else
    process_directory "$1"
fi
