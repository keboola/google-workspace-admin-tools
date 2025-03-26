# User Management Scripts

This directory contains scripts for managing Google Workspace users.

## Scripts

### update-contractor-type.sh

Updates the employee type to "Contractor" for users in specific organizational units.

Usage:
```bash
./update-contractor-type.sh
```

This script will:
1. Find all users in the externals OU and sub-OUs (Geneea, NetHost, Revolgy)
2. Update their employee type to "Contractor"
3. Show the calendar ACL for verification

### update-employee-type.sh

Updates the employee type for a specific user.

Usage:
```bash
./update-employee-type.sh user@email.com "Employee Type"
```

### list-users.sh

Lists all users in the organization.

Usage:
```bash
./list-users.sh
```

## Notes

- Scripts require GAM to be installed and configured
- Make sure you have the necessary admin permissions
- Always verify changes after running the scripts
- Consider using `--dry-run` option when available 