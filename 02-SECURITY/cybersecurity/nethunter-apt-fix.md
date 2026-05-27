# Fixing `apt update` DNS Resolution on Kali NetHunter

## The Problem

Running `apt update` inside the Kali NetHunter chroot fails with:

```
Temporary failure resolving 'http.kali.org'
```

This happens even though:
- `/etc/resolv.conf` is correctly configured
- `curl` and `nslookup` work fine
- DNS resolution succeeds in Android itself

## Root Cause

There are two compounding issues:

**1. Android's `aid_inet` group enforcement**

Android's kernel restricts socket access at the kernel level using group ID `3003` (`aid_inet`). Any process that isn't a member of this group is blocked from opening network sockets, regardless of whether it's running as root. This is why curl works but apt's internal sandbox process gets blocked.

**2. apt's sandbox user**

By default, apt drops privileges to an unprivileged sandbox user for network operations. On a normal Linux system this is fine, but inside the NetHunter chroot this sandbox user has no Android group memberships and therefore no network access.

**3. IPv6 preference**

apt prefers IPv6 when a DNS record returns both A and AAAA records. The NetHunter chroot often can't route IPv6 traffic, so connections silently fail before falling back to IPv4.

---

## The Fix

Run these commands inside the **NetHunter terminal** (not a raw adb shell):

### Step 1 — Disable apt's sandbox

```bash
echo 'APT::Sandbox::User "root";' > /etc/apt/apt.conf.d/01-android-nosandbox
```

This forces apt to run its network operations as root rather than dropping to an unprivileged sandbox user.

### Step 2 — Add root to the `aid_inet` group

```bash
usermod -aG 3003 root
```

This adds root to Android's `aid_inet` group (GID 3003), granting it kernel-level permission to open network sockets.

Verify it worked:
```bash
id
```

You should see `3003` in the groups list.

### Step 3 — Force IPv4

```bash
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4
```

Prevents apt from attempting IPv6 connections that the chroot can't route.

### Step 4 — Update

```bash
apt update
```

---

## Summary of Files Created

| File | Purpose |
|------|---------|
| `/etc/apt/apt.conf.d/01-android-nosandbox` | Disables apt sandbox, keeps network ops as root |
| `/etc/apt/apt.conf.d/99force-ipv4` | Forces IPv4 to avoid broken IPv6 routing |

---

## Troubleshooting

**If apt still fails after the fix**, check that you're running commands inside the NetHunter app terminal, not a raw `adb shell` + `chroot`. The NetHunter app sets up bind mounts (`/proc`, `/dev`, `/sys`) and inherits Android group memberships correctly. A raw chroot may not.

**If `usermod` says GID 3003 already exists**, that's fine — it just means the group was already there. The important thing is that root is a *member* of it, which `id` will confirm.

**If the fix reverts after a reboot**, the apt config files persist but group membership may not survive a chroot restart in some NetHunter versions. Re-run Step 2 if needed.
