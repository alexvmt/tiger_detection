#!/bin/bash

# Check if the user has provided all required arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <source_directory> <base_target_directory> <num_classes>"
    exit 1
fi

# Input arguments
source_dir="$1"
base_target_dir="$2"
num_classes="$3"

# Validate the source directory
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory $source_dir does not exist."
    exit 1
fi

# Validate the number of classes
if ! [[ "$num_classes" =~ ^[0-9]+$ ]] || [ "$num_classes" -lt 1 ]; then
    echo "Error: Invalid number of classes. Please provide a positive integer."
    exit 1
fi

# Create the target directories for each class (train, test for each class, and class_1 for test2)
for class_num in $(seq 1 "$num_classes"); do
    mkdir -p "$base_target_dir/train/class_$class_num"
    mkdir -p "$base_target_dir/test/class_$class_num"
done

# Create the class_1 directory under test2 (special case)
mkdir -p "$base_target_dir/test2/class_1"

# Process each file in the source directory
for file in "$source_dir"/*; do
    # Skip if it's not a file
    [ -f "$file" ] || continue

    # Extract the class number, subset, and file extension from the file name
    filename=$(basename "$file")
    class_num=$(echo "$filename" | cut -d'_' -f1 | sed 's/class_//')
    subset=$(echo "$filename" | cut -d'_' -f2)
    ext="${filename##*.}"

    # Check if the class number is within the valid range
    if [ "$class_num" -gt "$num_classes" ]; then
        echo "Skipping $filename: class number exceeds the specified range."
        continue
    fi

    # Determine the target directory based on the subset
    case "$subset" in
        "train" | "test")
            target_dir="$base_target_dir/$subset/class_$class_num"
            ;;
        "test2")
            target_dir="$base_target_dir/test2/class_1"
            ;;
        *)
            echo "Unknown subset: $subset in file $filename. Skipping."
            continue
            ;;
    esac

    # Copy the file to the corresponding target directory
    cp "$file" "$target_dir/$(basename "$file")" || { echo "Error copying $file"; exit 1; }

done

echo "Files copied successfully."