# Remote Access to Your Arch Linux Desktop via SSH

This guide explains how to securely set up your Arch Linux desktop for remote SSH access—including port forwarding for web UIs—over your home network. It covers:

- Installing and configuring OpenSSH on your desktop
- Configuring your home router for port forwarding
- (Optional) Setting up Dynamic DNS (DDNS) for dynamic public IPs
- Using SSH port forwarding (`ssh -L`) to access remote web interfaces
- Security best practices

---

## 1. Prerequisites

- **Systems:** Both your desktop and laptop are running Arch Linux.
- **Permissions:** You have root or sudo privileges on your desktop.
- **Network:** Access to your home router's admin interface.
- **(Optional) DDNS:** An account with a service like [DuckDNS](https://www.duckdns.org/) or [No-IP](https://www.noip.com/) if your ISP provides a dynamic IP.

---

## 2. Install and Configure OpenSSH on Your Desktop

### 2.1 Install OpenSSH

```bash
sudo pacman -S openssh
```

### 2.2 Configure SSH Server

Edit `/etc/ssh/sshd_config` to secure your SSH setup. Recommended changes include:

- **Disable Root Login:**  
  ```conf
  PermitRootLogin no
  ```

- **Enable Key-Based Authentication:** (Disable password auth if keys are in use)  
  ```conf
  PasswordAuthentication no
  ```

- **Ensure Port Forwarding is Allowed:**  
  ```conf
  AllowTcpForwarding yes
  ```

After making changes, restart the SSH service:

```bash
sudo systemctl restart sshd
```

### 2.3 Enable SSH Service on Boot

```bash
sudo systemctl enable sshd
```

### 2.4 Adjust Firewall (if applicable)

If using a firewall like UFW or iptables, allow SSH traffic:

_For UFW:_
```bash
sudo ufw allow 22/tcp
```

_For iptables:_
```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

---

## 3. Configure Port Forwarding on Your Home Router

### 3.1 Log into Your Router

- Open a browser and navigate to your router’s IP (commonly `192.168.1.1` or similar).

### 3.2 Set Up a Port Forwarding Rule

- **External Port:** Use port 22, or for additional obscurity, choose a different port (e.g., `2222`).
- **Internal IP:** The LAN IP of your Arch Linux desktop (e.g., `192.168.1.100`).
- **Internal Port:** `22`
- **Protocol:** TCP

Save your changes.

---

## 4. (Optional) Set Up Dynamic DNS (DDNS)

If you have a dynamic public IP, DDNS lets you access your network via a consistent hostname.

### 4.1 Choose a DDNS Service

- [DuckDNS](https://www.duckdns.org/) (free) or [No-IP](https://www.noip.com/) are good choices.

### 4.2 Configure a DDNS Client on Your Desktop

For DuckDNS, create a script to update your IP:

1. **Create the Script**

   Create `/usr/local/bin/duckdns.sh` with the following content:

   ```bash
   #!/bin/bash
   domain="your-domain"      # Replace with your DuckDNS subdomain
   token="your-token"        # Replace with your DuckDNS token
   url="https://www.duckdns.org/update?domains=${domain}&token=${token}&ip="
   
   curl -k $url
   ```

2. **Make it Executable**

   ```bash
   sudo chmod +x /usr/local/bin/duckdns.sh
   ```

3. **Create a Systemd Timer to Run the Script Every 5 Minutes**

   Create `/etc/systemd/system/duckdns.service`:

   ```ini
   [Unit]
   Description=DuckDNS Update Service

   [Service]
   Type=oneshot
   ExecStart=/usr/local/bin/duckdns.sh
   ```

   Create `/etc/systemd/system/duckdns.timer`:

   ```ini
   [Unit]
   Description=Run DuckDNS update every 5 minutes

   [Timer]
   OnBootSec=5min
   OnUnitActiveSec=5min

   [Install]
   WantedBy=timers.target
   ```

4. **Enable and Start the Timer**

   ```bash
   sudo systemctl enable --now duckdns.timer
   ```

_Note:_ Some routers support DDNS directly; if so, configure that in your router’s settings.

---

## 5. Accessing Your Desktop from Your Laptop

### 5.1 Basic SSH Connection

From your laptop, connect using:

```bash
ssh user@<public-ip-or-ddns-domain> -p <external-port>
```

For example, if you set the external port to `2222` and are using DuckDNS:

```bash
ssh user@your-domain.duckdns.org -p 2222
```

### 5.2 SSH Port Forwarding for Web UIs

To forward a remote port (e.g., a web UI on port `8080`) to your local machine:

```bash
ssh -L 8080:localhost:8080 user@your-domain.duckdns.org -p 2222
```

Then, on your laptop, access the web UI via [http://localhost:8080](http://localhost:8080).

### 5.3 Streamlining Connections with SSH Config

Edit `~/.ssh/config` on your laptop to simplify the connection:

```config
Host mydesktop
    HostName your-domain.duckdns.org
    Port 2222
    User your_username
    IdentityFile ~/.ssh/id_rsa
```

Now, you can connect using:

```bash
ssh mydesktop
```

---

## 6. Security Considerations

- **SSH Keys:** Use key-based authentication. Generate a key pair:

  ```bash
  ssh-keygen -t ed25519 -C "your_email@example.com"
  ```

  And copy your public key to your desktop:

  ```bash
  ssh-copy-id user@your-domain.duckdns.org -p 2222
  ```

- **Change the Default Port:** Changing from port 22 can reduce automated attack attempts.
- **Keep Your System Updated:** Regularly update:

  ```bash
  sudo pacman -Syu
  ```

- **Monitor Logs:** Keep an eye on `/var/log/auth.log` or your system’s equivalent for any suspicious activity.

---

## 7. Cheat Sheet

```bash
# On Arch Linux Desktop:
sudo pacman -S openssh
sudo systemctl enable sshd
sudo systemctl start sshd

# /etc/ssh/sshd_config adjustments:
#   PermitRootLogin no
#   PasswordAuthentication no (if using keys)
#   AllowTcpForwarding yes

# On your router: Forward external port (e.g., 2222) to Desktop IP (port 22)

# On Arch Linux Laptop:
ssh -L 8080:localhost:8080 user@your-domain.duckdns.org -p 2222
# Then access the web UI at http://localhost:8080
```

---

## 8. Exercise: Set Up and Test Remote Access

1. **Desktop Setup:**  
   - Install OpenSSH and configure `/etc/ssh/sshd_config`.
   - Enable and start the SSH service.

2. **Router Configuration:**  
   - Log into your router and set up a port forwarding rule (e.g., external port 2222 to internal port 22 on your desktop’s IP).

3. **(Optional) DDNS Configuration:**  
   - Sign up for a DDNS service.
   - Set up a DDNS update script and timer on your desktop.

4. **Laptop Testing:**  
   - Connect via SSH using your public IP or DDNS hostname.
   - Establish a port-forwarding session (`ssh -L`) and verify you can access a web UI running on your desktop.

5. **Document:**  
   - Record your process and any troubleshooting steps. Commit this documentation (and related scripts/config files) to your GitHub repository.

---

## 9. Additional Resources

- [Arch Linux Wiki: OpenSSH](https://wiki.archlinux.org/title/OpenSSH)
- [DuckDNS Documentation](https://www.duckdns.org/install.jsp)
- [SSH Port Forwarding Explained](https://www.ssh.com/academy/ssh/tunneling)

---

Follow these steps to securely access your Arch Linux desktop remotely. Happy hacking!