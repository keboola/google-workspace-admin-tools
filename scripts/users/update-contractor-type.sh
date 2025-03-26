#!/bin/bash

# Source configuration
source "$(dirname "$0")/../../config/org-config.sh"

# Just print the organizational units to see the structure
gam print orgs

echo "Completed printing organizational units"

# Get all users from the externals OU and sub-OUs with correct path format
gam print users query "orgunitpath='$ORG_UNIT_EXTERNALS'" fields primaryEmail > external_users.txt

# Also get users from sub-OUs (Geneea, NetHost, Revolgy)
gam print users query "orgunitpath='$ORG_UNIT_GENEEA'" fields primaryEmail >> external_users.txt
gam print users query "orgunitpath='$ORG_UNIT_NETHOST'" fields primaryEmail >> external_users.txt
gam print users query "orgunitpath='$ORG_UNIT_REVOLGY'" fields primaryEmail >> external_users.txt

# Remove any duplicates that might have been created
sort -u external_users.txt -o external_users.txt

# Update employee type for each user
while IFS= read -r email
do
    gam update user "$email" organization description Contractor primary
    echo "Updated $email - set employee type to Contractor"
done < external_users.txt

# Clean up temporary file
rm external_users.txt

echo "Completed updating contractor types"

# Check calendar ACL
gam calendar "$CALENDAR_ID" show acl 