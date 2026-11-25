# Cloudflare Tunnel Setup Guide  
## For SCMC QQ Camp Domain Deployment

> This guide explains how to set up `cloudflared` and connect your local server to your domain using Cloudflare Tunnel.

---

## 1. What This Setup Is For

Cloudflare Tunnel allows your laptop or Raspberry Pi to serve a public website without router port forwarding.

Example:

```text
Visitor
  ↓
https://game.scmcqqcamp.com
  ↓
Cloudflare
  ↓
Cloudflare Tunnel
  ↓
Your laptop
  ↓
http://127.0.0.1:8080
```

For your project:

```text
scmcqqcamp.com         → Hostinger / Raspberry Pi advertisement page
www.scmcqqcamp.com     → Hostinger / Raspberry Pi advertisement page

game.scmcqqcamp.com    → Laptop game system
admin.scmcqqcamp.com   → Laptop admin dashboard
```

---

## 2. Install `cloudflared`

### Method A: Install by `.deb` package

This is recommended if your Ubuntu version has repository issues.

```bash
cd /tmp
curl -L -o cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
```

If there is dependency error:

```bash
sudo apt install -f
```

Check installation:

```bash
cloudflared --version
```

---

## 3. Login to Cloudflare

Run:

```bash
cloudflared tunnel login
```

A browser window will open.

Choose your domain:

```text
scmcqqcamp.com
```

After successful login, Cloudflare will create a certificate file:

```text
~/.cloudflared/cert.pem
```

Check:

```bash
ls -la ~/.cloudflared
```

You should see:

```text
cert.pem
```

---

## 4. Create a Tunnel

### For laptop game system

Create a tunnel:

```bash
cloudflared tunnel create scmcqqcamp
```

This creates a tunnel for:

```text
game.scmcqqcamp.com
admin.scmcqqcamp.com
```

### For Raspberry Pi advertisement page

Create a separate tunnel:

```bash
cloudflared tunnel create scmcqqcamp-ad
```

This creates a tunnel for:

```text
scmcqqcamp.com
www.scmcqqcamp.com
```

---

## 5. Check Created Tunnels

Run:

```bash
cloudflared tunnel list
```

Example output:

```text
ID                                   NAME
60a9b8f4-dad0-4e1d-8636-2be0f7bd050b scmcqqcamp
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx scmcqqcamp-ad
```

The tunnel also creates a JSON credential file inside:

```text
~/.cloudflared/
```

Example:

```text
~/.cloudflared/60a9b8f4-dad0-4e1d-8636-2be0f7bd050b.json
```

---

## 6. Add Hostnames to the Tunnel

### Laptop tunnel hostnames

```bash
cloudflared tunnel route dns scmcqqcamp game.scmcqqcamp.com
cloudflared tunnel route dns scmcqqcamp admin.scmcqqcamp.com
```

### Raspberry Pi / advertisement tunnel hostnames

```bash
cloudflared tunnel route dns scmcqqcamp-ad scmcqqcamp.com
cloudflared tunnel route dns scmcqqcamp-ad www.scmcqqcamp.com
```

---

## 7. Create Tunnel Config File

Create or edit:

```bash
nano ~/.cloudflared/config.yml
```

---

## 8. Laptop Config Example

Use this for the laptop that runs Django/FastAPI/Nginx:

```yaml
tunnel: scmcqqcamp
credentials-file: /home/mohnc/.cloudflared/60a9b8f4-dad0-4e1d-8636-2be0f7bd050b.json

ingress:
  - hostname: game.scmcqqcamp.com
    service: http://127.0.0.1:8080

  - hostname: admin.scmcqqcamp.com
    service: http://127.0.0.1:8080

  - service: http_status:404
```

Important:

```text
Replace the credentials-file path with your real JSON file path.
```

Find your real file using:

```bash
ls -la ~/.cloudflared
```

---

## 9. Raspberry Pi Config Example

Use this if Raspberry Pi serves the advertisement page:

```yaml
tunnel: scmcqqcamp-ad
credentials-file: /home/pi/.cloudflared/YOUR_PI_TUNNEL_ID.json

ingress:
  - hostname: scmcqqcamp.com
    service: http://127.0.0.1:8080

  - hostname: www.scmcqqcamp.com
    service: http://127.0.0.1:8080

  - service: http_status:404
```

---

## 10. Run Your Local Server First

Cloudflare Tunnel only forwards traffic to your local server.  
So your local service must already be running.

For laptop setup, your Nginx should be available at:

```text
http://127.0.0.1:8080
```

Test:

```bash
curl http://127.0.0.1:8080
```

If this does not work locally, the domain will not work either.

---

## 11. Run the Tunnel

### Run laptop tunnel

```bash
cloudflared tunnel run scmcqqcamp
```

### Run Raspberry Pi tunnel

```bash
cloudflared tunnel run scmcqqcamp-ad
```

Keep the terminal open while testing.

---

## 12. Test in Browser

Test laptop game system:

```text
https://game.scmcqqcamp.com
https://admin.scmcqqcamp.com
```

Test advertisement page:

```text
https://scmcqqcamp.com
https://www.scmcqqcamp.com
```

---

## 13. Run Tunnel as a Background Service

After testing works, install it as a system service.

```bash
sudo cloudflared service install
```

Start service:

```bash
sudo systemctl start cloudflared
```

Enable auto-start after boot:

```bash
sudo systemctl enable cloudflared
```

Check status:

```bash
sudo systemctl status cloudflared
```

Restart service:

```bash
sudo systemctl restart cloudflared
```

View logs:

```bash
journalctl -u cloudflared -f
```

---

## 14. Common Error: Credentials File Does Not Exist

Error:

```text
Tunnel credentials file '/home/mohnc/.cloudflared/YOUR_TUNNEL_ID.json' doesn't exist
```

Reason:

```text
YOUR_TUNNEL_ID.json is only a placeholder.
```

Fix:

```bash
ls -la ~/.cloudflared
```

Find the real `.json` file and update:

```bash
nano ~/.cloudflared/config.yml
```

Example:

```yaml
credentials-file: /home/mohnc/.cloudflared/60a9b8f4-dad0-4e1d-8636-2be0f7bd050b.json
```

---

## 15. Common Error: DNS Record Already Exists

Error:

```text
Failed to create record ... An A, AAAA, or CNAME record with that host already exists.
```

Reason:

```text
Cloudflare already has a DNS record for that hostname.
```

Fix:

1. Go to Cloudflare Dashboard.
2. Open:

```text
Websites → scmcqqcamp.com → DNS → Records
```

3. Delete the old record for that hostname.
4. Run the route command again.

Example:

```bash
cloudflared tunnel route dns scmcqqcamp game.scmcqqcamp.com
```

---

## 16. Common Warning: Visitors Cannot Reach `www`

Warning:

```text
Visitors cannot reach www.scmcqqcamp.com
```

Meaning:

```text
There is no DNS record for www.scmcqqcamp.com.
```

Fix if using tunnel:

```bash
cloudflared tunnel route dns scmcqqcamp-ad www.scmcqqcamp.com
```

Fix if using Hostinger:

```text
Add CNAME:
Name: www
Target: scmcqqcamp.com
```

---

## 17. Delete a Hostname Route

### Dashboard method

Go to:

```text
Cloudflare Dashboard
→ Websites
→ scmcqqcamp.com
→ DNS
→ Records
```

Delete only the record you no longer want.

Example:

```text
Delete:
scmcqqcamp.com → Tunnel scmcqqcamp
```

Keep:

```text
game.scmcqqcamp.com → Tunnel scmcqqcamp
admin.scmcqqcamp.com → Tunnel scmcqqcamp
```

### Terminal method

Some versions support:

```bash
cloudflared tunnel route dns delete scmcqqcamp scmcqqcamp.com
```

If this does not work, use the dashboard method.

---

## 18. Delete a Tunnel

Only delete a tunnel if you are sure it is no longer used.

```bash
cloudflared tunnel delete scmcqqcamp-ad
```

or:

```bash
cloudflared tunnel delete scmcqqcamp
```

Warning:

```text
Deleting a tunnel will break all hostnames using that tunnel.
```

Example:

```text
If game.scmcqqcamp.com and admin.scmcqqcamp.com use scmcqqcamp,
deleting scmcqqcamp will break both.
```

---

## 19. Recommended Final DNS Setup

If using Raspberry Pi for advertisement:

```text
scmcqqcamp.com         Tunnel    scmcqqcamp-ad
www.scmcqqcamp.com     Tunnel    scmcqqcamp-ad
game.scmcqqcamp.com    Tunnel    scmcqqcamp
admin.scmcqqcamp.com   Tunnel    scmcqqcamp
```

If using Hostinger for advertisement:

```text
scmcqqcamp.com         Hostinger DNS record
www.scmcqqcamp.com     Hostinger DNS record
game.scmcqqcamp.com    Tunnel    scmcqqcamp
admin.scmcqqcamp.com   Tunnel    scmcqqcamp
```

---

## 20. Quick Command Summary

### Login

```bash
cloudflared tunnel login
```

### List tunnels

```bash
cloudflared tunnel list
```

### Create tunnel

```bash
cloudflared tunnel create scmcqqcamp
```

### Add hostname

```bash
cloudflared tunnel route dns scmcqqcamp game.scmcqqcamp.com
```

### Run tunnel

```bash
cloudflared tunnel run scmcqqcamp
```

### Check tunnel info

```bash
cloudflared tunnel info scmcqqcamp
```

### Install as service

```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

### Check service logs

```bash
journalctl -u cloudflared -f
```

---

## 21. Safety Notes

For the laptop game system:

```text
Django/FastAPI should bind to 127.0.0.1 only.
Cloudflare Tunnel should forward to Nginx.
Do not expose Django/FastAPI directly to 0.0.0.0 for public use.
```

Recommended:

```text
Cloudflare Tunnel
  ↓
Nginx on 127.0.0.1:8080
  ↓
Django on 127.0.0.1:8000
FastAPI on 127.0.0.1:8001
```

---

## 22. Best Practice for SCMC QQ Camp

Use:

```text
scmcqqcamp.com
```

for advertisement and event information.

Use:

```text
game.scmcqqcamp.com
```

for actual game pages and NFC checkpoint links.

Use:

```text
admin.scmcqqcamp.com
```

for admin dashboard.

NFC tags should use:

```text
https://game.scmcqqcamp.com/cp/CHECKPOINT_CODE/in/
https://game.scmcqqcamp.com/cp/CHECKPOINT_CODE/out/
```

Do not use root domain for NFC game links if the root domain is only the advertisement page.
