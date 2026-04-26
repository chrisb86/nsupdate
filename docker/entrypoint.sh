#!/bin/sh
set -e

COMMAND="/usr/local/bin/nsupdate.sh"

# Default schedule if not specified
SCHEDULE="${SCHEDULE:-* * * * *}"

# Default cron log level if not specified
CRON_LOG_LEVEL="${CRON_LOG_LEVEL:-2}"

# Default user name not specified
USERNAME="${USERNAME:-nsupdate}"

# Default UID and GID if not specified
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# Default timezone if not specified
TZ=${TZ:-Etc/UTC}

# Set the timezone
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo "$TZ" >/etc/timezone
echo "Timezone set to $TZ"

# Create group if it doesn't exist yet
if ! getent group "$USERNAME" > /dev/null 2>&1; then
  addgroup -g "$PGID" "$USERNAME"
fi

# Create user if it doesn't exist yet
if ! getent passwd "$USERNAME" > /dev/null 2>&1; then
  adduser -u "$PUID" -G "$USERNAME" -D -H -s /bin/false "$USERNAME"
fi

CRON_FILE="/etc/crontabs/$USERNAME"
mkdir -p /etc/crontabs
printf '%s %s\n' "$SCHEDULE" "$COMMAND" > "$CRON_FILE"
chmod 600 "$CRON_FILE"

# Set correct permissions
chown -R "$USERNAME":"$USERNAME" /config
chown -R "$USERNAME":"$USERNAME" /log
echo "Permissions adjusted"

# Start nsupdate in the foreground with reduced warnings
echo "Starting cron..."
exec crond -l "${CRON_LOG_LEVEL}" -f