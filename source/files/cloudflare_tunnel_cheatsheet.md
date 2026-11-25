# Cloudflare Tunnel Cheat Sheet  
## Add / Remove Hostname and Tunnel

> This guide is for the SCMC QQ Camp deployment setup using Cloudflare Tunnel.

---

## 1. Basic Concept

Cloudflare Tunnel has **three important parts**:

```text
Tunnel        = the connection profile in Cloudflare
Hostname      = domain/subdomain, e.g. game.scmcqqcamp.com
Local service = app running on your device, e.g. http://127.0.0.1:8080
```

Example:

```text
game.scmcqqcamp.com
        ↓
Cloudflare DNS hostname route
        ↓
Cloudflare Tunnel
        ↓
Your laptop
        ↓
http://127.0.0.1:8080
```

---

## 2. Your Recommended Setup

```text
scmcqqcamp.com         → Hostinger / Raspberry Pi advertisement page
www.scmcqqcamp.com     → Hostinger / Raspberry Pi advertisement page

game.scmcqqcamp.com    → Laptop tunnel, actual game system
admin.scmcqqcamp.com   → Laptop tunnel, admin dashboard
```

Recommended tunnel names:

```text
Laptop tunnel:
scmcqqcamp

Advertisement tunnel:
scmcqqcamp-ad
```

---

## 3. Check Existing Tunnels

Use this command:

```bash
cloudflared tunnel list
```

Example output:

```text
ID                                   NAME
60a9b8f4-dad0-4e1d-8636-2be0f7bd050b scmcqqcamp
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx scmcqqcamp-ad
```

To check one tunnel in more detail:

```bash
cloudflared tunnel info scmcqqcamp
```

or:

```bash
cloudflared tunnel info scmcqqcamp-ad
```

---

## 4. Create a New Tunnel

Use this when you want to create a new server tunnel.

Example for laptop game server:

```bash
cloudflared tunnel create scmcqqcamp
```

Example for Raspberry Pi / advertisement server:

```bash
cloudflared tunnel create scmcqqcamp-ad
```

After creating, Cloudflare will generate:

```text
Tunnel ID
Tunnel name
Credential JSON file
```

The credential file is usually stored here:

```text
~/.cloudflared/
```

Example:

```text
~/.cloudflared/60a9b8f4-dad0-4e1d-8636-2be0f7bd050b.json
```

---

## 5. Add a Hostname to a Tunnel

This is also called adding a **DNS route**.

### Add `game.scmcqqcamp.com` to laptop tunnel

```bash
cloudflared tunnel route dns scmcqqcamp game.scmcqqcamp.com
```

### Add `admin.scmcqqcamp.com` to laptop tunnel

```bash
cloudflared tunnel route dns scmcqqcamp admin.scmcqqcamp.com
```

### Add root domain to advertisement tunnel

```bash
cloudflared tunnel route dns scmcqqcamp-ad scmcqqcamp.com
```

### Add `www` to advertisement tunnel

```bash
cloudflared tunnel route dns scmcqqcamp-ad www.scmcqqcamp.com
```

---

## 6. Important: `route dns` Does Not Create a Tunnel

This command:

```bash
cloudflared tunnel route dns scmcqqcamp game.scmcqqcamp.com
```

does **not** create a new tunnel.

It only attaches a hostname to an existing tunnel.

Meaning:

```text
game.scmcqqcamp.com → existing tunnel named scmcqqcamp
```

To create a tunnel, use:

```bash
cloudflared tunnel create tunnel-name
```

To attach a hostname, use:

```bash
cloudflared tunnel route dns tunnel-name hostname
```

---

## 7. Configure Tunnel Hostnames

Open the tunnel configuration file:

```bash
nano ~/.cloudflared/config.yml
```

Example laptop config:

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

Example advertisement server config:

```yaml
tunnel: scmcqqcamp-ad
credentials-file: /home/pi/.cloudflared/YOUR_AD_TUNNEL_ID.json

ingress:
  - hostname: scmcqqcamp.com
    service: http://127.0.0.1:8080

  - hostname: www.scmcqqcamp.com
    service: http://127.0.0.1:8080

  - service: http_status:404
```

---

## 8. Run a Tunnel

Run the laptop tunnel:

```bash
cloudflared tunnel run scmcqqcamp
```

Run the advertisement tunnel:

```bash
cloudflared tunnel run scmcqqcamp-ad
```

The tunnel must keep running for the website to be online.

---

## 9. Remove a Hostname from a Tunnel

There are two ways.

### Method A: Remove from Cloudflare Dashboard

Go to:

```text
Cloudflare Dashboard
→ Websites
→ scmcqqcamp.com
→ DNS
→ Records
```

Find the hostname you want to remove.

Example:

```text
Name: scmcqqcamp.com
Type: Tunnel
Content: scmcqqcamp
```

Delete only that DNS record.

Do **not** delete the tunnel itself unless you really want to remove all hostnames under that tunnel.

### Method B: Remove from Terminal

Try:

```bash
cloudflared tunnel route dns delete scmcqqcamp scmcqqcamp.com
```

Example:

```bash
cloudflared tunnel route dns delete scmcqqcamp game.scmcqqcamp.com
```

If your `cloudflared` version does not support this command, use the dashboard method.

---

## 10. Remove a Hostname from `config.yml`

After deleting the DNS record, also remove the hostname from:

```bash
nano ~/.cloudflared/config.yml
```

Example: remove this block if you no longer want root domain on the laptop:

```yaml
- hostname: scmcqqcamp.com
  service: http://127.0.0.1:8080
```

Keep only the hostnames that should still point to that device.

Example laptop config should keep:

```yaml
ingress:
  - hostname: game.scmcqqcamp.com
    service: http://127.0.0.1:8080

  - hostname: admin.scmcqqcamp.com
    service: http://127.0.0.1:8080

  - service: http_status:404
```

Restart tunnel after editing:

```bash
cloudflared tunnel run scmcqqcamp
```

---

## 11. Delete a Tunnel

Only do this if you no longer need the tunnel.

```bash
cloudflared tunnel delete tunnel-name
```

Example:

```bash
cloudflared tunnel delete scmcqqcamp-ad
```

or:

```bash
cloudflared tunnel delete scmcqqcamp
```

---

## 12. Warning: Deleting a Tunnel Breaks All Hostnames Using It

If your DNS records are:

```text
game.scmcqqcamp.com   → Tunnel scmcqqcamp
admin.scmcqqcamp.com  → Tunnel scmcqqcamp
```

and you delete:

```bash
cloudflared tunnel delete scmcqqcamp
```

then both will fail:

```text
game.scmcqqcamp.com
admin.scmcqqcamp.com
```

So usually, do **not** delete the tunnel.

Delete only the specific DNS hostname route.

---

## 13. Safe Example: Remove Root Domain from Laptop

Current DNS:

```text
scmcqqcamp.com        → Tunnel scmcqqcamp
game.scmcqqcamp.com   → Tunnel scmcqqcamp
admin.scmcqqcamp.com  → Tunnel scmcqqcamp
```

Goal:

```text
scmcqqcamp.com        → Hostinger / Raspberry Pi
game.scmcqqcamp.com   → Laptop
admin.scmcqqcamp.com  → Laptop
```

Steps:

1. Go to Cloudflare DNS Records.
2. Delete only:

```text
scmcqqcamp.com → Tunnel scmcqqcamp
```

3. Keep:

```text
game.scmcqqcamp.com → Tunnel scmcqqcamp
admin.scmcqqcamp.com → Tunnel scmcqqcamp
```

4. Edit laptop config:

```bash
nano ~/.cloudflared/config.yml
```

5. Remove:

```yaml
- hostname: scmcqqcamp.com
  service: http://127.0.0.1:8080
```

6. Restart tunnel:

```bash
cloudflared tunnel run scmcqqcamp
```

7. Test:

```text
https://game.scmcqqcamp.com
https://admin.scmcqqcamp.com
```

---

## 14. Safe Example: Add Root Domain to Advertisement Server

On Raspberry Pi or Hostinger replacement server:

```bash
cloudflared tunnel create scmcqqcamp-ad
```

Then:

```bash
cloudflared tunnel route dns scmcqqcamp-ad scmcqqcamp.com
cloudflared tunnel route dns scmcqqcamp-ad www.scmcqqcamp.com
```

Config:

```yaml
tunnel: scmcqqcamp-ad
credentials-file: /home/pi/.cloudflared/YOUR_AD_TUNNEL_ID.json

ingress:
  - hostname: scmcqqcamp.com
    service: http://127.0.0.1:8080

  - hostname: www.scmcqqcamp.com
    service: http://127.0.0.1:8080

  - service: http_status:404
```

Run:

```bash
cloudflared tunnel run scmcqqcamp-ad
```

---

## 15. Check DNS Records in Cloudflare

Go to:

```text
Cloudflare Dashboard
→ Websites
→ scmcqqcamp.com
→ DNS
→ Records
```

Final expected setup:

```text
scmcqqcamp.com         Tunnel    scmcqqcamp-ad
www.scmcqqcamp.com     Tunnel    scmcqqcamp-ad
game.scmcqqcamp.com    Tunnel    scmcqqcamp
admin.scmcqqcamp.com   Tunnel    scmcqqcamp
```

If using Hostinger for advertisement page instead of Raspberry Pi:

```text
scmcqqcamp.com         Hostinger DNS record
www.scmcqqcamp.com     Hostinger DNS record
game.scmcqqcamp.com    Tunnel    scmcqqcamp
admin.scmcqqcamp.com   Tunnel    scmcqqcamp
```

---

## 16. Check DNS from Terminal

Check CNAME:

```bash
dig CNAME game.scmcqqcamp.com
dig CNAME admin.scmcqqcamp.com
dig CNAME scmcqqcamp.com
dig CNAME www.scmcqqcamp.com
```

Or:

```bash
nslookup game.scmcqqcamp.com
nslookup admin.scmcqqcamp.com
nslookup scmcqqcamp.com
```

Cloudflare Tunnel DNS may show a target like:

```text
xxxx.cfargotunnel.com
```

---

## 17. Quick Command Summary

### List tunnels

```bash
cloudflared tunnel list
```

### Create tunnel

```bash
cloudflared tunnel create scmcqqcamp-ad
```

### Add hostname

```bash
cloudflared tunnel route dns scmcqqcamp game.scmcqqcamp.com
```

### Run tunnel

```bash
cloudflared tunnel run scmcqqcamp
```

### Delete hostname route

```bash
cloudflared tunnel route dns delete scmcqqcamp game.scmcqqcamp.com
```

If that does not work, delete the DNS record from Cloudflare Dashboard.

### Delete tunnel

```bash
cloudflared tunnel delete scmcqqcamp-ad
```

---

## 18. Best Practice for SCMC QQ Camp

Use this structure:

```text
Root advertisement:
scmcqqcamp.com
www.scmcqqcamp.com

Game system:
game.scmcqqcamp.com

Admin dashboard:
admin.scmcqqcamp.com
```

Do not point the root domain and game system to the same tunnel unless you really want both to be served from the same device.

For the cleanest deployment:

```text
Hostinger or Raspberry Pi:
scmcqqcamp.com

Laptop:
game.scmcqqcamp.com
admin.scmcqqcamp.com
```

---

## 19. Important Safety Notes

Do not delete the main laptop tunnel if game/admin are still using it.

Safe to delete:

```text
DNS record: scmcqqcamp.com → Tunnel scmcqqcamp
```

Dangerous to delete:

```text
Tunnel: scmcqqcamp
```

because this breaks:

```text
game.scmcqqcamp.com
admin.scmcqqcamp.com
```

Always check Cloudflare DNS Records before deleting anything.
