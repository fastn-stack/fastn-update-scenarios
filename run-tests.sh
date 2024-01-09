#!/bin/bash

for dir in */; do
    cd "$dir" || exit

    output=$(fastn --trace update 2>/dev/null)

    read_count_subdir=$(grep -c 'read_content' <<< "$output")
    copy_count_subdir=$(grep -c 'copy' <<< "$output")
    write_count_subdir=$(grep -c 'write_content' <<< "$output")
    read_dir_subdir=$(grep -c 'read_dir' <<< "$output")

    echo "Summary for package $(echo "$dir" | sed 's:/$::'):"
    echo "Total read_content calls: $read_count_subdir"
    echo "Total write_content calls: $write_count_subdir"
    echo "Total copy calls: $copy_count_subdir"
    echo "Total read_dir calls: $read_dir_subdir"
    echo

    cd ..
done
