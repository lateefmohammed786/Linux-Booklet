Script for useradd:


#!/bin/bash
set -euo pipefail

GROUP="devteam"
USERS=(dev1 dev2 dev3)

# create group if missing
if ! getent group "$GROUP" >/dev/null; then
  groupadd "$GROUP"
  echo "Created group $GROUP"
else
  echo "Group $GROUP exists"
fi

for user in "${USERS[@]}"; do
  if id "$user" >/dev/null 2>&1; then
    echo "User $user already exists, skipping"
  else
    useradd -m -g "$GROUP" -s /bin/bash "$user"
    passwd -l "$user"   # lock password (admin can set password later)
    echo "User $user created and added to $GROUP"
  fi
done
