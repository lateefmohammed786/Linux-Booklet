# 🐧 Linux Server Automation – Project

This project contains a collection of **shell scripts** designed to automate common Linux server administration tasks.  
It is organized into two levels — **basic** and **intermediate** — progressing from foundational scripting to more advanced automation.

---

# 📁 Project Structure

```
linux-server-automation/
│
├── basic/
│   ├── create_users.sh
│   ├── set_permissions.sh
│   ├── install_packages.sh
│   └── system_info.sh
│
└── intermediate/
    ├── automate_backup.sh
    ├── log_cleanup.sh
    ├── check_service_status.sh
    └── performance_monitor.sh
```

### ✔ basic/
Contains beginner-level automation scripts:
- **create_users.sh** – Create users and groups
- **set_permissions.sh** – Set directory ownership & permissions
- **install_packages.sh** – Install software (git, nginx, etc.)
- **system_info.sh** – Display system information

### ✔ intermediate/
Contains more advanced automation:
- **automate_backup.sh** – Compress and rotate backups
- **log_cleanup.sh** – Delete logs older than a set number of days
- **check_service_status.sh** – Verify if services are running
- **performance_monitor.sh** – Capture performance metrics

---

# 📘 Linux Basics – Theory

Below is a simple, friendly introduction to fundamental Linux concepts relevant to automation and scripting.

---

## 🟦 1. What Is Linux?

Linux is an **open-source operating system** widely used in servers, cloud computing, networking, and DevOps.  
It is built on the Unix philosophy:  
➡ *"Do one thing but do it well."*

Most cloud providers (AWS, GCP, Azure) run Linux by default.

---

## 🟦 2. Linux Directory Structure (FHS)

Linux uses the **Filesystem Hierarchy Standard (FHS)**:

| Directory | Description |
|----------|-------------|
| `/` | Root directory |
| `/home/` | User home directories |
| `/root/` | Root user home |
| `/etc/` | Configuration files |
| `/var/` | Logs & variable data |
| `/usr/` | User programs & libs |
| `/bin/` | Essential user commands |
| `/sbin/` | System binaries |
| `/opt/` | Optional software |
| `/tmp/` | Temporary files |

Automation often interacts with `/etc`, `/var/log`, `/opt`, and `/home`.

---

## 🟦 3. File & Directory Commands

Common commands used in scripting:

```
ls      # list files
cd      # change directory
pwd     # print working dir
cp      # copy files
mv      # move/rename
rm      # remove files
mkdir   # create directory
touch   # create empty file
```

---

## 🟦 4. Viewing & Editing Files

```
cat file.txt
less file.txt
head -n 10 file.txt
tail -f logfile.log
```

For editing:
- `vi`
- `nano`
- `vim`

---

## 🟦 5. Linux Permissions

Every file has **owner**, **group**, and **other** permissions.

Example:
```
-rwxr-x---
```

Useful commands:

```
chmod 755 script.sh
chown user:group file
```

Understanding permissions is essential for automation.

---

## 🟦 6. Users & Groups

Linux is multi-user.

Creating users:
```
useradd username
passwd username
```

Creating groups:
```
groupadd devteam
```

Viewing user info:
```
id username
```

Automation scripts often manage users, groups, and permissions.

---

## 🟦 7. Package Management

Linux distributions use package managers:

### Debian/Ubuntu:
```
apt update
apt install nginx
```

### RHEL/CentOS/Amazon Linux:
```
yum install nginx
```

Package installation automates environment setup.

---

## 🟦 8. Managing Services (systemd)

Most modern Linux systems use **systemd**:

```
systemctl status nginx
systemctl start nginx
systemctl stop nginx
systemctl enable nginx
```

Service status checks are often part of automation scripts.

---

## 🟦 9. Monitoring & Performance

Useful tools:

```
top
htop
free -h
df -h
uptime
ps aux
```

Automation scripts can capture system metrics or monitor services.

---

## 🟦 10. Logs in Linux

Logs are stored in:
```
/var/log/
```

Examples:
```
/var/log/messages
/var/log/secure
/var/log/nginx/
```

Understanding logs is essential for troubleshooting.

---

## 🟦 11. Shell Scripting Basics

### Variables
```
NAME="Linux"
echo $NAME
```

### Conditionals
```
if [ -d /opt/project ]; then
  echo "Exists"
fi
```

### Loops
```
for i in 1 2 3; do
  echo $i
done
```

### Shebang
```
#!/bin/bash
```

The foundation for all automation in this project.

---

## 🟦 12. Cron Jobs (Automation Scheduler)

Run tasks automatically:

```
crontab -e
```

Example – run backup nightly at 2 AM:

```
0 2 * * * /usr/local/bin/automate_backup.sh
```

Cron is essential for automated maintenance.

---

# 🎯 Conclusion

This project provides a structured introduction to **Linux automation**, combining theory and real working scripts.  
Perfect for students, DevOps beginners, and system administrators who want hands-on practice.
