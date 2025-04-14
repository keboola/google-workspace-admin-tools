#!/bin/bash

# Script to find a Google Group by its primary email or alias using GAM.

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to display usage information
show_usage() {
  echo "Usage: $(basename "$0") <email_address>"
  echo
  echo "Finds a Google Group by its primary email or alias."
  echo
  echo "Arguments:"
  echo "  <email_address>  The email address (primary or alias) of the group to find."
  echo
  echo "Options:"
  echo "  -h, --help       Show this help message and exit."
  echo
  echo "Example:"
  echo "  $(basename "$0") marketing@your-domain.com"
}

# --- Configuration ---
# Source the organization configuration if it exists
# Determine the script's directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
CONFIG_FILE="${SCRIPT_DIR}/../../config/org-config.sh"

if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=../../config/org-config.sh
  source "$CONFIG_FILE"
else
  echo "Error: Configuration file not found at $CONFIG_FILE" >&2
  echo "Please ensure config/org-config.sh exists and is configured." >&2
  exit 1
fi

# Check if GAM command exists in the configured path
if [[ ! -x "$GAM" ]]; then
    echo "Error: GAM command not found or not executable at path specified in config: $GAM" >&2
    echo "Please check the GAM variable in $CONFIG_FILE" >&2
    exit 1
fi

# --- Argument Parsing ---
EMAIL_TO_FIND=""

if [[ $# -eq 0 ]]; then
  show_usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    *)
      # Assume the first non-option argument is the email address
      if [[ -z "$EMAIL_TO_FIND" ]]; then
        EMAIL_TO_FIND="$1"
      else
        echo "Error: Unexpected argument '$1'." >&2
        show_usage
        exit 1
      fi
      shift # past argument
      ;;
  esac
done

# Validate email address presence
if [[ -z "$EMAIL_TO_FIND" ]]; then
  echo "Error: Email address is required." >&2
  show_usage
  exit 1
fi

# --- Main Logic ---

echo "Searching for group with email or alias: $EMAIL_TO_FIND..."
echo "(Fetching all group aliases, this might take a moment...)"

# GAM command to get all groups and their aliases.
# Capture stdout and stderr separately to check for errors.
gam_stderr_file=$(mktemp)
gam_stdout_file=$(mktemp)

# Run GAM and capture exit code
if ! "$GAM" print groups aliases nodata > "$gam_stdout_file" 2> "$gam_stderr_file"; then
    gam_exit_code=$?
    echo "Error running GAM command (Exit Code: $gam_exit_code):" >&2
    cat "$gam_stderr_file" >&2
    rm -f "$gam_stdout_file" "$gam_stderr_file"
    exit $gam_exit_code
fi

# Clean up temp files on exit
trap 'rm -f "$gam_stdout_file" "$gam_stderr_file"' EXIT

# Process the output using awk to find the email in the relevant fields (email, aliases)
# -F, sets the field separator to a comma
# $1 == email checks the primary email (first field)
# index("," $2 ",", "," email ",") checks if the email is within the aliases field (second field).
# We add commas around the search string and the field to ensure whole-word matching.
found_groups=$(awk -F, -v email="$EMAIL_TO_FIND" 'BEGIN{IGNORECASE=1} NR > 1 { 
    # Check primary email (field 1)
    if ($1 == email) { print $0; next } 
    # Check aliases (field 2), handle cases where it might be empty
    if (NF >= 2 && $2 != "") {
        # Split aliases by space and check each one
        split($2, alias_list, " "); 
        for (i in alias_list) { 
            if (alias_list[i] == email) { print $0; next }
        } 
    }
}' < "$gam_stdout_file")

# Check if any groups were found by awk
if [[ -n "$found_groups" ]]; then
    echo
    echo "Found matching group(s):"
    echo "------------------------"
    echo "email,aliases,nonEditableAliases" # Print header
    echo "$found_groups"
    echo "------------------------"
else
    echo "No group found with the email address or alias: $EMAIL_TO_FIND"
fi

exit 0 