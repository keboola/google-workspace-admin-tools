# Google Workspace Admin Tools

A collection of scripts for managing Google Workspace (formerly G Suite) using GAM (Google Apps Manager).

## Overview

This repository contains scripts for:
- Calendar event management (deleting events for specific users)
- User management (updating user types, listing users)

## Prerequisites

### 1. GAM Installation

1. Install GAM (Google Apps Manager):
   ```bash
   # For macOS (using Homebrew)
   brew install gam

   # For Linux
   sudo apt-get install gam  # Debian/Ubuntu
   sudo yum install gam      # RHEL/CentOS
   ```

2. Verify GAM installation:
   ```bash
   gam version
   ```

3. Configure GAM with your Google Workspace admin account:
   ```bash
   gam oauth create
   ```

4. Test GAM access:
   ```bash
   gam info user
   ```

### 2. System Requirements
- Bash shell
- Google Workspace admin access
- Python 3.6+ (required by GAM)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/google-workspace-admin-tools.git
cd google-workspace-admin-tools
```

2. Configure your organization settings:
   ```bash
   # Copy the template configuration file
   cp config/org-config.sh.template config/org-config.sh
   
   # Edit the configuration file with your organization's settings
   nano config/org-config.sh
   ```

   Update the following variables in `config/org-config.sh`:
   - `ORG_UNIT_EXTERNALS`: Your organization's external users OU path
   - `ORG_UNIT_GENEEA`: Path to Geneea sub-OU
   - `ORG_UNIT_NETHOST`: Path to NetHost sub-OU
   - `ORG_UNIT_REVOLGY`: Path to Revolgy sub-OU
   - `CALENDAR_ID`: Your organization's calendar ID

## Usage

### Calendar Management

To delete events for a specific user:
```bash
./scripts/calendar/delete-events.sh --from-date YYYY-MM-DD user@email.com
```

Options:
- `--dry-run`: Show what would be deleted without actually deleting
- `--from-date`: Specify start date for event deletion (YYYY-MM-DD format)
- `--help`: Show usage information

### User Management

To update contractor types:
```bash
./scripts/users/update-contractor-type.sh
```

To list users:
```bash
./scripts/users/list-users.sh
```

## Directory Structure

```
google-workspace-admin-tools/
├── scripts/
│   ├── calendar/     # Calendar management scripts
│   └── users/        # User management scripts
├── config/           # Configuration files
│   ├── org-config.sh        # Your organization's configuration
│   └── org-config.sh.template # Template for configuration
└── docs/            # Documentation and examples
```

## Troubleshooting

### GAM Issues

1. If GAM command is not found:
   ```bash
   # Check if GAM is in PATH
   which gam
   
   # If not found, add GAM to PATH in your shell profile
   echo 'export PATH="$PATH:/path/to/gam"' >> ~/.bashrc  # or ~/.zshrc
   source ~/.bashrc  # or source ~/.zshrc
   ```

2. If GAM authentication fails:
   ```bash
   # Re-authenticate GAM
   gam oauth delete
   gam oauth create
   ```

### Configuration Issues

1. If scripts fail with "configuration not found":
   ```bash
   # Make sure you've copied and configured the org-config.sh file
   cp config/org-config.sh.template config/org-config.sh
   nano config/org-config.sh
   ```

2. If organization unit paths are incorrect:
   ```bash
   # List all organization units to find the correct paths
   gam print orgs
   ```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 