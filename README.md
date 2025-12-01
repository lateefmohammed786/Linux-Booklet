#!/usr/bin/env bash
set -e

# ================================
# README.md Link Generator Script
# ================================
# This script creates a README.md with clickable links.
# Edit the variables below with YOUR GitHub repo + YouTube link.
# ================================

GITHUB_REPO="https://github.com/lateefmohammed786/Linux-Booklet"
YOUTUBE_LINK="https://youtu.be/your_video_id_here"

cat > README.md <<EOF
# Linux Level-1 Automation — Server Setup (v2)

## 🔗 Important Links
- **GitHub Repository:** [Click here]($GITHUB_REPO)
- **YouTube Demo Video:** [Watch the Demo]($YOUTUBE_LINK)
- **Screenshots Folder:** [View Screenshots](./screenshots/)
- **Automation Script:** [setup_level1_v2.sh](./setup_level1_v2.sh)
- **Project Roadmap:** [ROADMAP.md](./ROADMAP.md)
- **Verification Report:** [level1_report.txt](./level1_report.txt)

---

## 📌 Project Overview
This Level-1 automation project prepares a Linux server using a Bash script.
It includes:
- User & group creation
- Project directory setup with permissions
- Package installation (git, nginx, Java)
- System information logging
- Auto-generation of documentation files

---

## 🚀 How to Run
```bash
chmod +x setup_level1_v2.sh
./setup_level1_v2.sh
