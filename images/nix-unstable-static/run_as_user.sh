#!/bin/sh -eu
#
# This script can be used as an entrypoint. It's used to synchronize and run
# the container with the same user and group as the host user.
#
# Usage:
#   user_id=$(id -u) user_name=$(id -un) \
#   group_id=$(id -g) group_name=$(id -gn) \
#   ./run_as_user.sh [<command> ...<args>]
#
# shellcheck disable=SC2154

# Install the host user and group into the container
delgroup "${group_name}" 2>/dev/null || true
deluser "${user_name}" 2>/dev/null || true

addgroup -g "${group_id}" "${group_name}"
adduser -D -G "${group_name}" -u "${user_id}" "${user_name}"

# Don't propagate those env vars
user=${user_name}
unset user_id user_name group_id group_name

# Change into the user
if [ $# = 0 ]; then
  exec su "${user}"
else
  exec su "${user}" -c /bin/sh /bin/sh -c "exec \"\$@\"" "$@"
fi
