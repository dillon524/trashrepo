#!/bin/bash

# Define the list of admin users to exclude from crontab deletion
ADMIN_USERS=("president" "vicepresident" "defenseminister" "secretary" "whiteteam")

# Get a list of all users on the system
ALL_USERS=$(cut -f1 -d: /etc/passwd)

# Loop through each user and delete crontab if they're not an admin
for USER in $ALL_USERS; do
    # Check if the user is in the admin list
    if [[ " ${ADMIN_USERS[@]} " =~ " ${USER} " ]]; then
        echo "Skipping crontab deletion for admin user: $USER"
    else
        # Delete crontab entries for non-admin users
        crontab -r -u "$USER" 2>/dev/null && echo "Deleted crontab for user: $USER" || echo "No crontab to delete for user: $USER"
    fi
done
