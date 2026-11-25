# Samba File Sharing Guide (Ubuntu ↔ Windows)

A reference guide for setting up, configuring, and troubleshooting Samba (SMB) file sharing between Ubuntu and Windows on the same local network.

---

## 1. What is Samba?

Samba is the Linux implementation of the **SMB/CIFS protocol**, the same file-sharing protocol Windows uses natively. It lets Ubuntu:

- Share folders that Windows can browse via `\\<ip>\sharename`
- Access Windows shared folders directly from the Ubuntu file manager or terminal

---

## 2. Install Samba on Ubuntu

```bash
sudo apt update
sudo apt install samba
```

Check it installed correctly:
```bash
smbd --version
```

---

## 3. Sharing an Ubuntu Folder to Windows

### 3.1 Edit the Samba config file

Open `/etc/samba/smb.conf`:
```bash
sudo nano /etc/samba/smb.conf
```

Add this block at the bottom (adjust path and share name as needed):
```ini
[shared]
   path = /home/mohnc/Desktop/File/qq_camp
   browseable = yes
   read only = no
   guest ok = no
   valid users = mohnc
```

| Option | Meaning |
|---|---|
| `path` | The actual folder on Ubuntu being shared |
| `browseable` | Whether it shows up when browsing the network |
| `read only` | `no` allows writing to the share |
| `guest ok` | `yes` = no password required, `no` = password required |
| `valid users` | Restricts access to specific Samba users (only relevant if `guest ok = no`) |

### 3.2 Create a Samba user (required if `guest ok = no`)

Samba uses its own password system, separate from your Linux login password:
```bash
sudo smbpasswd -a mohnc
```
Enter a password when prompted.

### 3.3 Restart Samba

```bash
sudo systemctl restart smbd
```

### 3.4 Allow Samba through the firewall (if UFW is active)

```bash
sudo ufw allow samba
```

### 3.5 Find your Ubuntu machine's IP

```bash
ip a
```

### 3.6 Access from Windows

- File Explorer → address bar → `\\192.168.1.15\shared`
- Enter the Samba username/password if prompted
- Optional: **Map network drive** to persist it as a drive letter (e.g. `Z:`), with **Reconnect at sign-in** checked

---

## 4. Guest Access (No Password) — Optional

If you want the share fully open with no login prompt:

In `/etc/samba/smb.conf`, under `[global]`:
```ini
[global]
   map to guest = Bad User
```

Under the share itself:
```ini
[shared]
   path = /home/mohnc/Desktop/File/qq_camp
   browseable = yes
   read only = no
   guest ok = yes
   guest only = yes
```

Restart Samba:
```bash
sudo systemctl restart smbd
```

> ⚠️ **Security note:** Guest access means *anyone* on the same network can read/write the shared folder. Only use this on trusted private networks.

---

## 5. Accessing a Windows Share from Ubuntu

### 5.1 On Windows — enable sharing

1. Right-click the folder → **Properties** → **Sharing** tab → **Advanced Sharing**
2. Check **Share this folder**, set share name
3. **Permissions** → allow the required user(s) Read/Write
4. **Network and Sharing Center** → **Advanced sharing settings**:
   - Turn on **Network discovery**
   - Turn on **File and printer sharing**
   - Turn off **Password protected sharing** only if guest access is intended (trusted networks only)
5. Get the PC's IP via `ipconfig`

### 5.2 On Ubuntu — access it

**GUI (Nautilus/Files app):**
- Files → **Other Locations** → address bar → `smb://<windows-ip>/<sharename>`

**Terminal (one-time mount):**
```bash
sudo apt install cifs-utils
sudo mkdir /mnt/winshare
sudo mount -t cifs //192.168.1.20/SharedFolder /mnt/winshare -o username=WindowsUser,password=WindowsPass
```

**Auto-mount on boot** — add to `/etc/fstab`:
```
//192.168.1.20/SharedFolder /mnt/winshare cifs username=WindowsUser,password=WindowsPass,uid=1000,gid=1000 0 0
```
Test without rebooting:
```bash
sudo mount -a
```

---

## 6. Common Issues & Fixes

| Symptom | Likely Cause | Fix |
|---|---|---|
| Windows can't see the share at all (no password prompt) | Firewall blocking SMB ports on Ubuntu | `sudo ufw allow samba` |
| Password prompt appears but you wanted guest access | `guest ok = yes` not applied correctly, or missing `map to guest = Bad User` | Recheck config in Section 4, restart smbd |
| Password rejected even though it's correct | Using Linux password instead of Samba password | Re-run `sudo smbpasswd -a <user>` |
| Share visible but read-only | `read only = yes` set, or folder permissions on Linux side | Set `read only = no` and check `chmod`/`chown` on the folder |
| Windows shows old cached credentials/errors | Stale saved credentials | Control Panel → **Credential Manager** → Windows Credentials → remove entry for the IP |
| Changes to `smb.conf` not taking effect | Samba service not restarted | `sudo systemctl restart smbd` |

---

## 7. Useful Commands Reference

```bash
# Test smb.conf syntax before restarting
testparm

# Restart Samba service
sudo systemctl restart smbd

# Check Samba service status
sudo systemctl status smbd

# List currently connected Samba sessions
sudo smbstatus

# Add/change a Samba user password
sudo smbpasswd -a <username>

# Remove a Samba user
sudo smbpasswd -x <username>
```

---

## 8. Quick Decision Guide

- **Need password-protected sharing?** → Section 3 (with `guest ok = no`)
- **Need fully open sharing on trusted network?** → Section 4
- **Need to pull files FROM Windows into Ubuntu?** → Section 5
- **Something not working?** → Section 6
