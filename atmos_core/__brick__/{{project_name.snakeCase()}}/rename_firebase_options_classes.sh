#!/bin/bash

# Check if a working directory was provided

# Get the working directory
WORKING_DIR="."

if [ -n "$1" ]; then
  WORKING_DIR="$1"
fi


# Check if the working directory exists
if [ ! -d "$WORKING_DIR" ]; then
  echo "The directory $WORKING_DIR does not exist."
  exit 1
fi

# Define the files and their corresponding class renames
FILES=("development_firebase_options.dart" "staging_firebase_options.dart" "production_firebase_options.dart")
CLASSES=("DevelopmentFirebaseOptions" "StagingFirebaseOptions" "ProductionFirebaseOptions")

# Iterate over the files and process each one
for i in "${!FILES[@]}"; do
  file="${FILES[$i]}"
  new_class="${CLASSES[$i]}"
  FILE_PATH="$WORKING_DIR/$file"

  # Check if the file exists
  if [ ! -f "$FILE_PATH" ]; then
    # Do nothing
    continue
  fi

  # Replace DefaultFirebaseOptions with the appropriate new class name
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    sed -i '' "s/DefaultFirebaseOptions/$new_class/g" "$FILE_PATH"
  else
    # GNU sed (Linux)
    sed -i "s/DefaultFirebaseOptions/$new_class/g" "$FILE_PATH"
  fi

  # Confirm the changes
  echo "Renamed the class DefaultFirebaseOptions to $new_class in $FILE_PATH."
done