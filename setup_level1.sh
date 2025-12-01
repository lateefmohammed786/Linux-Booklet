#!/usr/bin/env bash
set -euo pipefail
trap 'echo "ERROR on line $LINENO. Check log or run with bash -x for debug." >&2' ERR

# Level 1 server setup & automation script
# Usage:
#   sudo ./setup_level1.sh
# or
#   USERS="alice,bob" PROJECT_DIRS="/srv/app1,/srv/app2" ./setup_level1.sh

# Choose a log path that requires root. If not root, fallback to /tmp for safe testing.
LOG_DIR="/var/log"
LOG_FILE="level1_setup.log"
if [ "$(id -u)" -eq 0 ]; then
  LOG="${LOG_DIR}/${LOG_FILE}"
else
  LOG="/tmp/${LOG_FILE}"
fi

# Redirect stdout/stderr to log (append). Use exec after determining LOG.
exec 1>>"$LOG" 2>&1

printf "=== Level1 Setup started at %s ===\n" "$(date)"

# Configurable defaults (override by environment)
USERS="${USERS:-alice,bob,carol}"        # comma-separated usernames
GROUP="${GROUP:-devs}"
PROJECT_DIRS="${PROJECT_DIRS:-/srv/project,/opt/project}" # comma-separated dirs
SHELL_FOR_USERS="${SHELL_OVERRIDE:-/bin/bash}"    # default shell for new users

# Detect distro id from /etc/os-release
detect_distro() {
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    printf "%s" "${ID:-unknown}"
  else
    printf "unknown"
  fi
}

is_root() { [ "$(id -u)" -eq 0 ]; }

install_pkgs() {
  # installs packages passed as arguments (array)
  local pkgs=("$@")
  echo "Installing packages: ${pkgs[*]}"
  case "$DISTRO" in
    ubuntu|debian)
      apt-get update -y
      DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
      ;;
    centos|rhel|ol|rocky)
      if command -v dnf >/dev/null 2>&1; then
        dnf install -y "${pkgs[@]}"
      else
        yum install -y "${pkgs[@]}"
      fi
      ;;
    fedora)
      dnf install -y "${pkgs[@]}"
      ;;
    *)
      echo "Unknown distro ($DISTRO) — trying common package managers"
      if command -v apt-get >/dev/null 2>&1; then
        apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
      elif command -v dnf >/dev/null 2>&1; then
        dnf install -y "${pkgs[@]}"
      elif command -v yum >/dev/null 2>&1; then
        yum install -y "${pkgs[@]}"
      else
        echo "No supported package manager found. Please install: ${pkgs[*]}"
      fi
      ;;
  esac
}

enable_start_service() {
  local svc="$1"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now "$svc" || echo "Warning: could not enable/start $svc via systemctl"
  else
    service "$svc" start || echo "Warning: could not start $svc via service"
  fi
}

# ---- start main ----
DISTRO="$(detect_distro)"
echo "Detected distro: $DISTRO"

if ! is_root; then
  echo "NOTE: Running as non-root; some operations (package installs, systemctl, groupadd) will fail unless you run as root."
fi

# 1) Create group if missing
if getent group "$GROUP" >/dev/null 2>&1; then
  echo "Group $GROUP already exists"
else
  if is_root; then
    groupadd "$GROUP"
    echo "Created group $GROUP"
  else
    echo "Skipping groupadd: not running as root"
  fi
fi

# 2) Create users and add to group
IFS=',' read -r -a user_array <<< "$USERS"
for u in "${user_array[@]}"; do
  u_trim="$(echo "$u" | xargs)"
  [ -z "$u_trim" ] && continue
  if id "$u_trim" >/dev/null 2>&1; then
    echo "User $u_trim exists — ensuring membership in $GROUP"
    if is_root; then
      usermod -aG "$GROUP" "$u_trim" || true
    fi
  else
    if is_root; then
      useradd -m -s "$SHELL_FOR_USERS" -G "$GROUP" "$u_trim"
      echo "Created user $u_trim and added to $GROUP"
      mkdir -p "/home/$u_trim/.ssh"
      chmod 700 "/home/$u_trim/.ssh"
      chown -R "$u_trim:$u_trim" "/home/$u_trim/.ssh"
      echo "Created /home/$u_trim/.ssh (no keys installed)"
    else
      echo "Cannot create user $u_trim: not running as root"
    fi
  fi
done

# 3) Setup project directories with permissions
IFS=',' read -r -a proj_array <<< "$PROJECT_DIRS"
for d in "${proj_array[@]}"; do
  d_trim="$(echo "$d" | xargs)"
  [ -z "$d_trim" ] && continue
  if is_root; then
    mkdir -p "$d_trim"
    chown root:"$GROUP" "$d_trim"
    chmod 2775 "$d_trim"  # setgid
    echo "Prepared project dir $d_trim (owner root:$GROUP, perms 2775)"
  else
    echo "Skipping directory creation $d_trim: not running as root"
  fi
done

# 4) Install packages: git, nginx, java (OpenJDK)
case "$DISTRO" in
  ubuntu|debian)
    install_pkgs git nginx openjdk-11-jdk || install_pkgs git nginx default-jdk
    ;;
  centos|rhel|ol|rocky|fedora)
    install_pkgs git nginx java-11-openjdk-devel
    ;;
  *)
    install_pkgs git nginx openjdk-11-jdk || echo "Please install git, nginx, and Java manually"
    ;;
esac

# 5) Enable & start nginx if possible
if is_root; then
  enable_start_service nginx || echo "Could not enable/start nginx"
else
  echo "Skipping nginx start (not root)."
fi

# 6) Basic system info (append to log)
echo "---- System Information ----"
echo "Date: $(date)"
echo "--- Memory ---"
free -h || true
echo "--- CPU ---"
if command -v lscpu >/dev/null 2>&1; then
  lscpu || true
else
  cat /proc/cpuinfo | head -n 20 || true
fi
echo "--- Disk (lsblk) ---"
lsblk || true
echo "--- Filesystems ---"
df -h || true

printf "=== Level1 Setup completed at %s ===\n" "$(date)"
echo "Log written to $LOG"

