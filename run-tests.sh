#!/bin/bash

count_traces() {
    trace_file_content=$1

    read_content_lines=$(echo "$trace_file_content" | grep -E 'read_content|write_content|read_dir')

    traces=($(echo "$read_content_lines" | grep -oE '\/[^ ]+' | cut -c 2- | sort -u))

    for trace in "${traces[@]}"; do
        echo "$trace"
    done
}

print_report() {
    local dir_name=$1
    local final_traces=("${@:2}")

    echo "┌─── $dir_name ────────────────────────────"
    echo "│   read_content: ${#final_traces[@]}"
    echo "│"
    
    for trace_file in "${final_traces[@]}"; do
        echo "│   ├─ $trace_file"
    done

    echo "└───────────────────────────────────────"
}

process_directory() {
    local dir=$1

    dir_name=$(basename "$dir")

    cd "$dir" || { echo "Error: Could not enter directory $dir"; return; }

    temp_trace_file=$(mktemp)
    fastn update >/dev/null 2>&1
    nohup fastn --trace serve > "$temp_trace_file" 2>&1 &

    serve_pid=$!

    sleep 2

    initial_traces=($(count_traces "$(<"$temp_trace_file")"))

    curl -s http://127.0.0.1:8000/ >/dev/null

    final_traces=($(count_traces "$(<"$temp_trace_file")"))

    sleep 2

    kill -15 $serve_pid

    rm "$temp_trace_file"
    print_report "$dir_name" "${final_traces[@]}"

    cd ..
}

if [ $# -eq 0 ]; then
    for dir in */; do
        process_directory "$dir"
    done
else
    process_directory "$1"
fi
