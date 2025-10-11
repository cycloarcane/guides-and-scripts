# Infrastructure & DevOps

Guides for cloud management, virtualization, and network infrastructure configuration.

## 📂 Subcategories

### [Cloud Management](cloud-management/)
Cloud infrastructure automation and resource management

**Scripts:**
- `aws-nuke-everything.sh` - Comprehensive AWS resource deletion script
  - Terminates EC2 instances across all regions
  - Deletes EBS volumes, S3 buckets, RDS instances, Lambda functions
  - Includes safety checks and requires jq for JSON parsing
  - **⚠️ DESTRUCTIVE - Use with extreme caution**

### [Virtualization](virtualization/)
Virtual machine configuration and cross-platform setups

**Guides:**
- `WINDOWS-AS-VM.md` - Running bare-metal Windows installation inside VirtualBox on Arch Linux
  - Raw disk access configuration
  - Risk mitigation (Fast Startup, BitLocker, activation)
  - VMDK creation and VM setup
  - Advanced dual-boot virtualization

### [Networking](networking/)
Remote access, SSH configuration, and connectivity solutions

**Guides:**
- `remote-ssh-desktop.md` - Remote SSH access setup for Arch Linux desktop
  - OpenSSH installation and configuration
  - Router port forwarding setup
  - Dynamic DNS (DDNS) configuration
  - SSH port forwarding for web UIs
  - Security best practices

## 🎯 Quick Start

**Clean up AWS account:**
→ Review and run [aws-nuke-everything.sh](cloud-management/aws-nuke-everything.sh) (⚠️ destructive)

**Access home system remotely:**
→ Follow [remote-ssh-desktop.md](networking/remote-ssh-desktop.md)

**Boot Windows in VirtualBox:**
→ Configure with [WINDOWS-AS-VM.md](virtualization/WINDOWS-AS-VM.md)

## 🔑 Key Technologies

- **Cloud Platforms:** AWS (EC2, S3, RDS, Lambda)
- **Virtualization:** VirtualBox, raw disk access, VMDK
- **Remote Access:** OpenSSH, DDNS, port forwarding
- **Automation:** Bash scripting, AWS CLI, jq

## ⚠️ Safety Warnings

### Cloud Management
- **aws-nuke-everything.sh** will DELETE ALL resources in your AWS account
- Always review script before running
- Test in non-production environment first
- Backup critical data before execution

### Virtualization
- Raw disk access can corrupt Windows installation if not configured properly
- Disable Fast Startup in Windows before VM use
- BitLocker may cause boot issues
- Windows activation may be affected

### Remote Access
- SSH port forwarding exposes your system to the internet
- Use strong SSH keys (ED25519 recommended)
- Disable password authentication
- Consider using VPN or Tailscale for added security

## 📊 Use Cases

| Task | Guide | Complexity |
|------|-------|------------|
| AWS complete cleanup | [aws-nuke-everything.sh](cloud-management/aws-nuke-everything.sh) | Medium |
| Remote desktop access | [remote-ssh-desktop.md](networking/remote-ssh-desktop.md) | Easy |
| Dual-boot Windows in VM | [WINDOWS-AS-VM.md](virtualization/WINDOWS-AS-VM.md) | Advanced |

## 🛠️ Common Tasks

**Set up remote SSH access:**
1. Install OpenSSH: `sudo pacman -S openssh`
2. Configure router port forwarding (port 22 → your PC)
3. Set up DDNS (DuckDNS, No-IP, or router built-in)
4. Follow [remote-ssh-desktop.md](networking/remote-ssh-desktop.md) for complete setup

**Run Windows installation in VirtualBox:**
1. Identify Windows disk: `lsblk`
2. Create raw VMDK: `VBoxManage createmedium disk --filename=/path/to/windows.vmdk --variant=RawDisk --property RawDrive=/dev/sdX`
3. Configure VM following [WINDOWS-AS-VM.md](virtualization/WINDOWS-AS-VM.md)

**Clean AWS account:**
1. Review resources to be deleted
2. Ensure backups are complete
3. Run [aws-nuke-everything.sh](cloud-management/aws-nuke-everything.sh)
4. Verify deletion in AWS Console

## 🔐 Security Best Practices

### SSH Access
- Generate ED25519 key: `ssh-keygen -t ed25519`
- Copy key to server: `ssh-copy-id user@host`
- Disable password auth: `PasswordAuthentication no` in `/etc/ssh/sshd_config`
- Use fail2ban to prevent brute force attacks
- Consider SSH over non-standard port

### Cloud Security
- Enable MFA on AWS root account
- Use IAM roles with least privilege
- Enable CloudTrail for audit logging
- Regular security audits
- Tag resources for tracking

### VM Security
- Keep host and guest OS updated
- Use separate disks for critical data
- Regular VM backups
- Network isolation for testing environments

## 🚀 Advanced Topics

**SSH Tunneling:**
```bash
# Forward remote port 8080 to local 8080
ssh -L 8080:localhost:8080 user@remote-host

# Reverse tunnel (expose local port to remote)
ssh -R 8080:localhost:80 user@remote-host
```

**VirtualBox Networking:**
- NAT: Outbound only (default)
- Bridged: Full network access
- Host-only: Isolated host-VM communication
- Internal: VM-to-VM only

---

[← Back to Main README](../README.md)
