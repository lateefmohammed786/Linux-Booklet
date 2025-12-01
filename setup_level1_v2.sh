#!/usr/bin/env bash
set -euo pipefail
trap 'echo "ERROR on line $LINENO. See debug for details." >&2' ERR

# Level-1 automation + create ROADMAP / README / report in script directory
# Usage:
#   chmod +x setup_level1_v2.sh
#   ./setup_level1_v2.sh
# Optional (on Linux as root):
#   sudo ./setup_level1_v2.sh
#
# This script writes files next to itself (so run it inside your repo folder)

# Determine script directory (where files will be written)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/level1_setup_v2.log"
exec 1>>"$LOG_FILE" 2>&1

echo "=== Level1 v2 started at $(date) ==="

# config (override by env)
USERS="${USERS:-alice,bob,carol}"
GROUP="${GROUP:-devs}"
PROJECT_DIRS="${PROJECT_DIRS:-/srv/project,/opt/project}"

is_root() { [ "$(id -u)" -eq 0 ]; }

# ---------- system actions (only when root on Linux) ----------
if is_root; then
  echo "Running as root — will attempt group/user/dir/package actions"
  # create group
  if getent group "$GROUP" >/dev/null 2>&1; then
    echo "Group $GROUP exists"
  else
    groupadd "$GROUP" && echo "Created group $GROUP" || true
  fi

  # create users and .ssh
  IFS=',' read -r -a UARR <<< "$USERS"
  for u in "${UARR[@]}"; do
    u="$(echo "$u" | xargs)"
    [ -z "$u" ] && continue
    if id "$u" >/dev/null 2>&1; then
      echo "User $u exists; adding to $GROUP"
      usermod -aG "$GROUP" "$u" || true
    else
      useradd -m -s /bin/bash -G "$GROUP" "$u" && echo "Created user $u"
      mkdir -p "/home/$u/.ssh"
      chmod 700 "/home/$u/.ssh"
      chown -R "$u:$u" "/home/$u/.ssh"
    fi
  done

  # create project dirs with setgid
  IFS=',' read -r -a DARR <<< "$PROJECT_DIRS"
  for d in "${DARR[@]}"; do
    d="$(echo "$d" | xargs)"
    [ -z "$d" ] && continue
    mkdir -p "$d"
    chown root:"$GROUP" "$d"
    chmod 2775 "$d"
    echo "Prepared $d with owner root:$GROUP and perms 2775"
  done

  # attempt to install minimal packages (best-effort)
  if command -v apt-get >/dev/null 2>&1; then
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    apt-get install -y git nginx openjdk-11-jdk || true
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y git nginx java-11-openjdk-devel || true
  elif command -v yum >/dev/null 2>&1; then
    yum install -y git nginx java-11-openjdk-devel || true
  else
    echo "No known package manager found; skip installs"
  fi

  # try to enable nginx
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now nginx || echo "Could not enable/start nginx"
  fi
else
  echo "Not running as root — skipping system-level steps (group/user/dirs/install)."
fi

# ---------- create ROADMAP.md in script dir ----------
ROADMAP_PATH="${SCRIPT_DIR}/ROADMAP.md"
cat > "$ROADMAP_PATH" <<'EOF'
# Project Roadmap — Linux Level-1 Automation

## Goal
Provide a Level-1 cross-distro Bash script to automate basic Linux server setup for dev teams.

## Deliverables
- setup_level1_v2.sh — automation script (this file)
- README.md — documentation & run instructions
- level1_report.txt — verification output after running the script
- screenshots/ — images of script run & verification
- demo video (YouTube link)

## Steps
1. Run this script in your repo folder.
2. If running on Linux as root, system-level tasks will be attempted.
3. Collect verification output: level1_report.txt
4. Commit files to GitHub and upload screenshots + video.

EOF
echo "Wrote ROADMAP.md to $ROADMAP_PATH"

# ---------- create README.md in script dir ----------
README_PATH="${SCRIPT_DIR}/README.md"
cat > "$README_PATH" <<'EOF'
# Linux Level-1 Automation — Server Setup (v2)

This repo contains a Level-1 automation script that prepares basic server items and
generates documentation files for submission.

Files created by this script:
- ROADMAP.md
- README.md (this file)
- level1_report.txt
- level1_setup_v2.log

How to run:
1. Save script in your repo and make executable:
   chmod +x setup_level1_v2.sh
2. Run:
   ./setup_level1_v2.sh
   (Use sudo on Linux if you want system-level changes)

Notes:
- Run on Linux/WSL for full behavior. On Windows (Git Bash) the script will still produce
  ROADMAP.md and level1_report.txt but will skip system-level operations.

EOF
echo "Wrote README.md to $README_PATH"

# ---------- collect verification into level1_report.txt ----------
REPORT_PATH="${SCRIPT_DIR}/level1_report.txt"
{
  echo "===== Level1 v2 Report ====="
  echo "Date: $(date)"
  echo
  echo "Script dir: $SCRIPT_DIR"
  echo
  echo "---- Group 'devs' ----"
  getent group "$GROUP" || echo "Group $GROUP not present"
  echo
  echo "---- Users sample ----"
  for u in $(echo "$USERS" | tr ',' ' '); do
    if id "$u" >/dev/null 2>&1; then
      id "$u"
    else
      echo "User $u: not present"
    fi
  done
  echo
  echo "---- Project directories ----"
  for d in $(echo "$PROJECT_DIRS" | tr ',' ' '); do
    ls -ld "$d" 2>/dev/null || echo "$d: not present"
  done
  echo
  echo "---- Packages / versions ----"
  git --version 2>/dev/null || echo "git: not found"
  nginx -v 2>/dev/null || echo "nginx: not found or no permission"
  java -version 2>/dev/null || echo "java: not found or no permission"
  echo
  echo "---- system info ----"
  free -h 2>/dev/null || cat /proc/meminfo 2>/dev/null || echo "memory info not available"
  if command -v lscpu >/dev/null 2>&1; then lscpu || true; else cat /proc/cpuinfo | head -n 10 || true; fi
  lsblk 2>/dev/null || echo "lsblk not available"
  df -h || true
} > "$REPORT_PATH"
echo "Wrote level1_report.txt to $REPORT_PATH"

echo "=== Level1 v2 completed at $(date) ==="
echo "Log file: $LOG_FILE"

