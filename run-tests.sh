#!/bin/bash

count_traces() {
    local trace_output=$1
    local read_count=$(grep -c 'read_content' <<< "$trace_output")
    local read_dir_count=$(grep -c 'read_dir' <<< "$trace_output")
    local copy_count=$(grep -c 'copy' <<< "$trace_output")
    local write_count=$(grep -c 'write_content' <<< "$trace_output")

    local result=("$read_count" "$read_dir_count" "$copy_count" "$write_count")
    echo "${result[@]}"
}

for dir in */; do
    dir_name=$(echo "$dir" | sed 's:/$::')

    cd "$dir" || exit

    temp_trace_file=$(mktemp)
    nohup fastn --trace serve > "$temp_trace_file" 2>&1 &

    serve_pid=$!

    sleep 2

    initial_traces=($(count_traces "$(<"$temp_trace_file")"))

    curl -s http://127.0.0.1:8000/ >/dev/null

    final_traces=($(count_traces "$(<"$temp_trace_file")"))

    sleep 2

    kill -15 $serve_pid

    rm "$temp_trace_file"

    echo "Summary for package $dir_name:"
    echo   "|-----------------|-----------------|-----------------|-----------------|-----------------|"
    printf "| %-15s | %-15s | %-15s | %-15s | %-15s |\n" "Operation" "File Reads" "Dir Reads" "Copies" "Writes"
    echo   "|-----------------|-----------------|-----------------|-----------------|-----------------|"
    printf "| Startup         | %-15s | %-15s | %-15s | %-15s |\n" "${initial_traces[@]}"
    printf "| Request         | %-15s | %-15s | %-15s | %-15s |\n" "${final_traces[@]}"
    echo   "|-----------------|-----------------|-----------------|-----------------|-----------------|"
    echo

    cd ..
done
