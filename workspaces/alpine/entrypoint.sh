#!/bin/sh

# Git config
if [ ! -z "$GIT_USER_NAME" ] && [ ! -z "$GIT_USER_EMAIL" ]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Change user uid to host user's uid
if [ ! -z "$USER_ID" ] && [ "$(id -u $USER_NAME)" != "$USER_ID" ]; then
    # Create the user group if it does not exist
    groupadd --non-unique -g "$GROUP_ID" usergroup
    
    # Set the user's uid and gid
    usermod --non-unique --uid "$USER_ID" --gid "$GROUP_ID" $USER_NAME
fi

# Setting permissions on user's home directory
# Ignore errors for read-only files/directories (like .ssh)
chown -R $USER_NAME: /home/$USER_NAME 2>/dev/null || true``

# Setting permissions on docker.sock if it exists
if [ -e /var/run/docker.sock ]; then
    chown $USER_NAME: /var/run/docker.sock
fi

# Execute command as user
exec /sbin/su-exec $USER_NAME fish "$@"
