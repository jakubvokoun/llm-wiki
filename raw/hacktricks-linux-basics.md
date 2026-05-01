# Linux Basics

## Overview

This guide covers fundamental Linux concepts and commands essential for understanding Linux systems and security.

## Key Linux Basics Topics

### File System Structure

Linux uses a hierarchical file system with a root directory `/`. Common directories include:

- `/bin` - Essential command binaries
- `/sbin` - System binaries for root user
- `/etc` - Configuration files
- `/home` - User home directories
- `/root` - Root user's home directory
- `/tmp` - Temporary files
- `/var` - Variable data files
- `/usr` - User programs and data
- `/lib` - System libraries
- `/dev` - Device files
- `/proc` - Process information
- `/sys` - System kernel information

### Users and Permissions

Linux supports multiple users with different permission levels:

- **Root user (UID 0)**: Has complete system access
- **Regular users**: Limited permissions
- **System users**: Used for running services

Permissions are represented in three categories:
- **User (owner)**: 4 (read), 2 (write), 1 (execute)
- **Group**: Same permission values
- **Others**: Same permission values

Permission examples:
- `755` = rwxr-xr-x (user full, group and others read/execute)
- `644` = rw-r--r-- (user read/write, group and others read-only)
- `777` = rwxrwxrwx (full permissions for all)

### File Ownership

Files and directories have an owner (user) and a group. Commands:

- `chown user:group file` - Change ownership
- `chmod 755 file` - Change permissions
- `ls -l` - View file permissions and ownership

### Common Commands

#### Navigation and File Operations

- `pwd` - Print working directory
- `cd path` - Change directory
- `ls` - List files
- `mkdir dir` - Create directory
- `touch file` - Create empty file
- `cp src dst` - Copy file
- `mv src dst` - Move/rename file
- `rm file` - Delete file
- `rm -r dir` - Delete directory recursively

#### Viewing File Contents

- `cat file` - Display entire file
- `less file` - View file with pagination
- `head file` - Show first 10 lines
- `tail file` - Show last 10 lines
- `grep pattern file` - Search for pattern in file

#### System Information

- `uname -a` - System information
- `whoami` - Current user
- `id` - User and group IDs
- `ps aux` - List running processes
- `top` - Real-time process monitor
- `df -h` - Disk space usage
- `du -sh dir` - Directory size
- `free -h` - Memory usage
- `w` - Logged-in users
- `last` - Login history

#### Networking

- `ifconfig` / `ip addr` - Network interfaces
- `netstat` / `ss` - Network connections
- `ping host` - Test connectivity
- `nslookup domain` - DNS lookup
- `curl url` - Fetch web content
- `wget url` - Download file

#### Package Management

Varies by distribution:
- **Debian/Ubuntu**: `apt-get`, `apt`
- **RedHat/CentOS**: `yum`, `dnf`
- **Alpine**: `apk`

### Processes and Services

#### Process Management

- `ps` - List processes
- `kill PID` - Terminate process
- `killall name` - Kill by process name
- `bg` - Background process
- `fg` - Foreground process
- `nohup command` - Ignore hangup signals

#### Service Management (systemd)

- `systemctl start service` - Start service
- `systemctl stop service` - Stop service
- `systemctl restart service` - Restart service
- `systemctl enable service` - Enable on boot
- `systemctl status service` - Check status

### Environment Variables

- `echo $VAR` - Display variable value
- `export VAR=value` - Set environment variable
- `env` - List all variables
- `printenv` - Display environment

Common variables:
- `$HOME` - User home directory
- `$PATH` - Command search paths
- `$USER` - Current username
- `$SHELL` - Default shell

### Shell Scripting Basics

Basic shell script structure:

```bash
#!/bin/bash
# Script header

# Variables
VAR="value"

# Conditionals
if [ condition ]; then
    echo "True"
else
    echo "False"
fi

# Loops
for i in {1..5}; do
    echo $i
done

# Functions
my_function() {
    echo "Function"
}

my_function
```

### File Permissions Deep Dive

Special permissions:
- **SUID (4000)**: Execute as file owner
- **SGID (2000)**: Execute as group owner
- **Sticky bit (1000)**: Only owner can delete in shared directories

Example: `chmod 4755 file` sets SUID + rwxr-xr-x

### Sudo and Privilege Escalation

- `sudo command` - Execute as root
- `sudo -i` - Interactive root shell
- `sudo -l` - List available commands
- `visudo` - Safely edit sudoers file
- `su user` - Switch to another user
- `su -` - Switch to root

### Cron Jobs

Schedule tasks with cron:

```
# Edit crontab
crontab -e

# Format: minute hour day month day-of-week command
0 2 * * * /path/to/backup.sh  # Daily at 2 AM
*/5 * * * * /path/to/script.sh  # Every 5 minutes
```

- `crontab -l` - List cron jobs
- `crontab -r` - Remove crontab

### SSH and Remote Access

- `ssh user@host` - Connect to remote system
- `ssh-keygen` - Generate SSH keys
- `ssh-copy-id user@host` - Copy public key
- `scp file user@host:path` - Copy file via SSH
- `sftp user@host` - SFTP connection

### Text Processing

- `sed` - Stream editor for text manipulation
- `awk` - Text processing language
- `cut` - Extract columns
- `sort` - Sort lines
- `uniq` - Remove duplicates
- `wc` - Count lines, words, characters

### Package and Dependency Management

Understanding dependencies and libraries:
- `ldd binary` - Show dependencies
- `ldconfig` - Update library cache
- `apt-cache search package` - Search for packages (Debian)

### File Compression

- `tar cf archive.tar files` - Create tar archive
- `tar xf archive.tar` - Extract tar
- `gzip file` - Compress with gzip
- `gunzip file.gz` - Decompress gzip
- `zip archive.zip files` - Create zip
- `unzip archive.zip` - Extract zip

### Useful Resources

- `man command` - Manual pages
- `command --help` - Help text
- `/etc/` - Configuration files
- `/var/log/` - Log files
- Online documentation and communities

## Conclusion

Understanding Linux basics is essential for system administration, security, and development work. These fundamentals provide the foundation for more advanced topics in Linux hardening and cybersecurity.
