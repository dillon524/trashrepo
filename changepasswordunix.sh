#!/bin/bash

# Define authorized user lists
ADMIN_USERS=("president" "vicepresident" "defenseminister" "secretary")
OTHER_USERS=("general" "admiral" "judge" "bodyguard" "cabinetofficial" "treasurer")

# Define essential users to keep
ESSENTIAL_USERS=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail"
    "news" "uucp" "operator" "gopher" "ftp" "nobody" "systemd-timesync"
    "www-data" "sshd" "uuidd" "mysql" "postfix")

# Function to generate a random password
generate_random_password() {
    local LENGTH=12
    < /dev/urandom tr -dc 'A-Za-z0-9_!@#$%&*' | head -c $LENGTH
}

# Function to check if a user is authorized
is_authorized_user() {
    local user=$1
    for admin in "${ADMIN_USERS[@]}"; do
        if [[ "$user" == "$admin" ]]; then
            return 0
        fi
    done
    for other in "${OTHER_USERS[@]}"; do
        if [[ "$user" == "$other" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if a user is essential
is_essential_user() {
    local user=$1
    for essential in "${ESSENTIAL_USERS[@]}"; do
        if [[ "$user" == "$essential" ]]; then
            return 0
        fi
    done
    return 1
}

# Set passwords for authorized users
echo "Setting passwords for authorized users:"
for admin in "${ADMIN_USERS[@]}"; do
    ADMIN_PASSWORD=$(generate_random_password)
    echo "$admin: $ADMIN_PASSWORD"  # Print new password
    echo "$ADMIN_PASSWORD" | passwd --stdin "$admin"  # Set password
done

for user in "${OTHER_USERS[@]}"; do
    USER_PASSWORD=$(generate_random_password)
    echo "$user: $USER_PASSWORD"  # Print new password
    echo "$USER_PASSWORD" | passwd --stdin "$user"  # Set password
done

# Remove unauthorized users
echo "Removing unauthorized users:"
ALL_USERS=$(cut -f1 -d: /etc/passwd)
for user in $ALL_USERS; do
    if ! is_authorized_user "$user" && ! is_essential_user "$user"; then
        userdel -r "$user" && echo "Deleted unauthorized user: $user" || echo "Failed to delete user: $user"
    fi
done

echo "Password changes complete. Unauthorized users have been deleted."