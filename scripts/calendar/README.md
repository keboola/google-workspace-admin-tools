# Calendar Management Scripts

This directory contains scripts for managing Google Calendar events.

## Scripts

### delete-events.sh

Main script for deleting calendar events for a specific user.

Usage:
```bash
./delete-events.sh --from-date YYYY-MM-DD user@email.com
```

Options:
- `--dry-run`: Show what would be deleted without actually deleting
- `--from-date`: Specify start date for event deletion (YYYY-MM-DD format)
- `--help`: Show usage information

Example:
```bash
# Dry run to see events that would be deleted
./delete-events.sh --dry-run --from-date 2024-11-07 user@example.com

# Actually delete events
./delete-events.sh --from-date 2024-11-07 user@example.com
```

### Helper Scripts

- `delete-user-events-script.sh`: Generates a script to remove events for each user
- `remove_events.sh`: Helper script for removing events from a specific user's calendar

## Notes

- Scripts require GAM to be installed and configured
- Make sure to use the `--dry-run` option first to verify what will be deleted
- Events are permanently deleted and cannot be recovered 