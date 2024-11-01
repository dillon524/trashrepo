#!/bin/bash

# List of users to delete crontabs for
users=("president" "vicepresident" "defenseminister" "secretary" "general" "admiral" "judge" "bodyguard" "cabinetofficial" "treasurer")

# Loop through each user
for user in "${users[@]}"; do
    echo "Attempting to delete crontab for user: $user"
    
    # Delete crontab for the user and capture the output
    if sudo crontab -u "$user" -r 2>/dev/null; then
        echo "Successfully deleted crontab for $user"
    else
        echo "No crontab found for $user or deletion failed"
    fi
done
