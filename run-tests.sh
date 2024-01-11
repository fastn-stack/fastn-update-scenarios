#!/bin/bash

count_traces() {
    trace_file_content=$1

    read_content_lines=$(echo "$trace_file_content" | grep -E 'read_content|write_content|read_dir')

    traces=($(echo "$read_content_lines" | grep -oE '\/[^ ]+' | cut -c 2- | sort -u))

    for trace in "${traces[@]}"; do
        echo "$trace"
    done
}

for dir in */; do
    dir_name=$(echo "$dir" | sed 's:/$::')

    cd "$dir" || exit

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
    echo "- $dir_name:"
    echo "  - read_content: ${#final_traces[@]}"
    
    current_directory=$(pwd)
    
    for ((i=0; i<${#final_traces[@]}; i++)); do
        trace_file="${final_traces[$i]}"
        echo "     - $trace_file"
    done

    echo ""

    cd ..
done
