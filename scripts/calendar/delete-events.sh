#!/bin/bash

# Configuration
# Dry run flag (can be overridden by --dry-run argument)
DRY_RUN=false

# Function to show usage
show_usage() {
    echo "Usage: $0 [--dry-run] [--from-date YYYY-MM-DD] <deleted_user_email>"
    echo "Example: $0 --dry-run --from-date 2024-12-05 john.doe@keboola.com"
    echo "Options:"
    echo "  --dry-run              Run in dry-run mode (no actual deletions)"
    echo "  --from-date YYYY-MM-DD Optional date to delete events from (default: current date)"
    exit 1
}

# Function to validate date format
validate_date() {
    local date_str=$1
    if [[ ! $date_str =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: Invalid date format. Use YYYY-MM-DD"
        show_usage
    fi
    
    # Convert to format without dashes for comparison
    echo "${date_str//-/}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --from-date)
            if [[ -z "$2" ]]; then
                echo "Error: --from-date requires a date argument"
                show_usage
            fi
            CURRENT_DATE=$(validate_date "$2")
            shift 2
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            if [[ -z "$DELETED_USER" ]]; then
                DELETED_USER="$1"
            else
                echo "Error: Multiple email addresses provided"
                show_usage
            fi
            shift
            ;;
    esac
done

# If no date provided, use current date
if [[ -z "$CURRENT_DATE" ]]; then
    CURRENT_DATE=$(date +%Y%m%d)
fi

# Validate deleted user email
if [[ -z "$DELETED_USER" ]]; then
    echo "Error: No email address provided"
    show_usage
fi

if [[ ! "$DELETED_USER" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "Error: Invalid email address format: $DELETED_USER"
    show_usage
fi

echo "Checking calendar events where $DELETED_USER is the organizer..."
if [[ "$CURRENT_DATE" == $(date +%Y%m%d) ]]; then
    echo "Current date (from today): $CURRENT_DATE"
else
    echo "Current date (from specified date): $CURRENT_DATE"
fi
if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN MODE: No events will be actually deleted"
fi
echo "----------------------------------------"

# Process each user's calendar
while IFS= read -r user_email; do
    if [[ "$user_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo "Checking calendar for: $user_email"
        echo "----------------------------------------"
        
        # Process the events
        event_summary=""
        event_date=""
        event_organizer=""
        in_event=false
        event_id=""
        attendees=()
        in_attendees=false
        current_attendee=""
        current_display_name=""
        is_future_magda_event=false
        
        # Read events directly from command output
        while IFS= read -r line; do
            # Start of new event
            if [[ $line =~ ^[[:space:]]*Event:[[:space:]]*([^[:space:]]+)[[:space:]]*\([0-9]+/[0-9]+\)$ ]]; then
                # Store previous event if it was a future Magda event
                if [ "$is_future_magda_event" = true ]; then
                    all_event_ids+=("$event_id")
                    all_event_summaries+=("$event_summary")
                    all_event_dates+=("$event_date")
                    all_event_calendars+=("$user_email")
                    # Convert attendees array to string with newlines
                    attendees_str=$(printf '%s\n' "${attendees[@]}")
                    all_event_attendees+=("$attendees_str")
                fi
                
                # Reset for new event
                in_event=true
                event_summary=""
                event_date=""
                event_organizer=""
                event_id="${BASH_REMATCH[1]}"
                attendees=()
                in_attendees=false
                current_attendee=""
                current_display_name=""
                is_future_magda_event=false
                continue
            fi
            
            # Only process lines if we're in an event
            if [ "$in_event" = true ]; then
                if [[ $line =~ ^[[:space:]]*summary:[[:space:]]*(.*)$ ]]; then
                    event_summary="${BASH_REMATCH[1]}"
                elif [[ $line =~ ^[[:space:]]*start:[[:space:]]*$ ]]; then
                    # Read the next line which contains the dateTime
                    read -r date_line
                    if [[ $date_line =~ ^[[:space:]]*dateTime:[[:space:]]*([0-9]{4}-[0-9]{2}-[0-9]{2})T([0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
                        event_date="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
                        formatted_date=$(echo "${BASH_REMATCH[1]}" | tr -d '-')
                    fi
                elif [[ $line =~ ^[[:space:]]*attendees:[[:space:]]*$ ]]; then
                    in_attendees=true
                    continue
                elif [[ $line =~ ^[[:space:]]*organizer:[[:space:]]*$ ]]; then
                    in_attendees=false
                    # Read the next line which contains the email
                    read -r org_line
                    if [[ $org_line =~ ^[[:space:]]*email:[[:space:]]*(.*)$ ]]; then
                        event_organizer="${BASH_REMATCH[1]}"
                        # If this is a future event organized by Magda
                        if [[ $formatted_date -ge $CURRENT_DATE && "$event_organizer" == "$DELETED_USER" ]]; then
                            is_future_magda_event=true
                        fi
                    fi
                elif [ "$in_attendees" = true ]; then
                    if [[ $line =~ ^[[:space:]]*displayName:[[:space:]]*(.*)$ ]]; then
                        current_display_name="${BASH_REMATCH[1]}"
                    elif [[ $line =~ ^[[:space:]]*email:[[:space:]]*(.*)$ ]]; then
                        current_attendee="${BASH_REMATCH[1]}"
                    elif [[ $line =~ ^[[:space:]]*responseStatus:[[:space:]]*(.*)$ ]] && [ ! -z "$current_attendee" ]; then
                        response_status="${BASH_REMATCH[1]}"
                        if [ ! -z "$current_display_name" ]; then
                            attendees+=("  - $current_display_name <$current_attendee> ($response_status)")
                        else
                            attendees+=("  - $current_attendee ($response_status)")
                        fi
                        current_attendee=""
                        current_display_name=""
                    fi
                fi
            fi
        done < <(gam user "$user_email" show events)
        
        # Store the last event if it was a future Magda event
        if [ "$is_future_magda_event" = true ]; then
            all_event_ids+=("$event_id")
            all_event_summaries+=("$event_summary")
            all_event_dates+=("$event_date")
            all_event_calendars+=("$user_email")
            # Convert attendees array to string with newlines
            attendees_str=$(printf '%s\n' "${attendees[@]}")
            all_event_attendees+=("$attendees_str")
        fi
    fi
done < <(gam print users | tail -n +2 | cut -d ' ' -f 1)

echo "----------------------------------------"
echo "Found ${#all_event_ids[@]} future events organized by $DELETED_USER:"
echo "----------------------------------------"

# Print all found events
for ((i=0; i<${#all_event_ids[@]}; i++)); do
    echo "Event $((i+1)):"
    echo "Event ID: ${all_event_ids[$i]}"
    echo "Title: ${all_event_summaries[$i]}"
    echo "Date and Time: ${all_event_dates[$i]}"
    echo "Found in calendar of: ${all_event_calendars[$i]}"
    echo "Attendees:"
    echo "${all_event_attendees[$i]}"
    echo "----------------------------------------"
done 