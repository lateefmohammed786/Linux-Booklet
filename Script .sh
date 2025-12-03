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

Script for Permissions:
#!/bin/bash
mkdir -p /opt/devproject
chown :devteam /opt/devproject
chmod 770 /opt/devproject
echo "permissions set for /opt/devproject"

Script for Packages:
#!/bin/bash
set -euo pipefail

# On Amazon Linux 2/2023 use yum (or dnf) and don't use sudo if already root
yum update -y
yum install -y git nginx

# Amazon Corretto (example): install from Amazon Corretto repo (if you want Corretto)
# For a quick test, install OpenJDK 17 instead:
yum install -y java-17-amazon-corretto-devel || yum install -y java-17-openjdk-devel || echo "No Java 17 package found"

systemctl enable nginx.service || echo "Cannot enable nginx.service (may not be installed)"
systemctl start nginx.service || echo "Cannot start nginx.service (may not be installed)"

echo "Git, nginx & java (if available) installed or attempted."

Script for System Info:
#!/bin/bash
echo "cpu info:"; lscpu
echo "memory info"; free -h
echo "disk info"; df -h

#!/bin/bash
set -euo pipefail

# Source folder to back up
SOURCE="/opt/devproject"
# Destination archive (date in YYYY-MM-DD)
BACKUP="/backup/devproject_$(date +%F).tar.gz"

# Ensure source exists
if [[ ! -d "$SOURCE" ]]; then
  echo "Source not found: $SOURCE" >&2
  exit 1
fi

# Make sure backup directory exists
mkdir -p "$(dirname "$BACKUP")"

# Create the tar.gz (use variables exactly as defined)
tar -czvf "$BACKUP" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"

echo "Backup stored at $BACKUP"Script for Automatebackup.sh:

