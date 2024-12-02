#!/bin/bash

# Function to create a directory and add a blank file
create_dir_with_blank_file() {
  local dir_path=$1
  mkdir -p "$dir_path"
  touch "$dir_path/BLANK_FILE.swift"
  echo "Created $dir_path with BLANK_FILE.swift"
}

# Prompt for the module name with validation
while true; do
  read -p "Enter the module name (at least 3 characters): " module_name
  if [[ -z "$module_name" || ${#module_name} -lt 3 ]]; then
    echo "Error: Module name must be at least 3 characters long and cannot be blank."
  else
    break
  fi
done

# Define base directory structure
base_dirs=(
  "Targets/$module_name/Sources"
  "Targets/$module_name/Resources"
  "Targets/$module_name/Tests"
  "Targets/$module_name/Tests/Resources"
  "Targets/$module_name/UITests"
  "Targets/$module_name/UITests/Resources"
)

# Loop through directories and request permissions if required
for dir in "${base_dirs[@]}"; do
  if [[ "$dir" == *"Resources"* || "$dir" == *"Tests"* ]]; then
    read -p "Do you want to create $dir? (y/N): " permission
    if [[ "$permission" == "y" ]]; then
      create_dir_with_blank_file "$dir"
    else
      echo "Skipping $dir"
    fi
  else
    create_dir_with_blank_file "$dir"
  fi
done

echo "Folder structure creation complete."
