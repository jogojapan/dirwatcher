#!/bin/bash
set -e

# Validate environment variables
if [ -z "$SOURCE_DIR" ] || [ -z "$DESTINATION_DIR" ]; then
  echo "ERROR: SOURCE_DIR and DESTINATION_DIR must be set"
  exit 1
fi

# Create directories if they don't exist
mkdir -p "$SOURCE_DIR" "$DESTINATION_DIR"

echo "Starting file monitor..."
echo "Watching directory: $SOURCE_DIR"
echo "Destination directory: $DESTINATION_DIR"

# Function to check file age and move if it's old enough
check_and_move_file() {
  local file="$1"

  # Check if file still exists
  if [ ! -f "$file" ]; then
    return
  fi

  local filename=$(basename "$file")
  local current_time=$(date +%s)
  local file_mtime=$(stat -c %Y "$file")
  local age=$((current_time - file_mtime))

  if [ $age -ge 60 ]; then
    echo "Moving file: $filename (age: $age seconds)"
    mv "$file" "$DESTINATION_DIR/"
  else
    echo "File $filename is too new (age: $age seconds). Waiting..."
    # Schedule another check after the remaining time
    (
      sleep $((60 - age))
      check_and_move_file "$file"
    ) &
  fi
}

# Process existing files first
echo "Checking for existing files..."
find "$SOURCE_DIR" -type f | while read -r file; do
  check_and_move_file "$file"
done

# Monitor for new files
echo "Monitoring for new files..."
inotifywait -m -e create -e moved_to --format "%w%f" "$SOURCE_DIR" | while read -r file; do
  if [ -f "$file" ]; then
    echo "New file detected: $(basename "$file")"
    # Start a background process to check the file
    (
      # Wait at least 60 seconds
      sleep 60
      check_and_move_file "$file"
    ) &
  fi
done
