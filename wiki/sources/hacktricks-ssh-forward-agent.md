---
title: "HackTricks: SSH Agent Forwarding Exploitation"
tags: [linux-hardening, privilege-escalation, ssh, lateral-movement]
sources: [hacktricks-ssh-forward-agent.md]
updated: 2026-05-01
---

# HackTricks: SSH Agent Forwarding Exploitation

Source: [hacktricks-ssh-forward-agent.md](../../raw/hacktricks-ssh-forward-agent.md)

## Key Takeaways

When `ForwardAgent yes` is set in SSH config, the SSH agent socket is forwarded to intermediate hosts and left in `/tmp` or `/run/user/`. Anyone (especially root) on that host can steal the agent socket and impersonate the original user to any host the user's key grants access to. The private key lives **unencrypted in the agent's memory**.

## Finding Agent Sockets

```bash
ls -la /run/user/*/ssh-* /tmp/ssh-* 2>/dev/null
find /run/user /tmp -type s -name 'agent.*' 2>/dev/null
```

## Exploitation

```bash
# Impersonate bob using his forwarded agent
SSH_AUTH_SOCK=/tmp/ssh-haqzR16816/agent.16816 ssh bob@target
```

## Why It Works

Setting `SSH_AUTH_SOCK` directs the SSH client to use Bob's in-memory agent, which holds his private key. No password or key file is needed — the agent performs the private-key operation on behalf of the attacker. If the key is still loaded (it normally is for the session duration), any host that trusts it is reachable.

## Detection / Hardening

- Avoid `ForwardAgent yes` in global configs; use it only for specific hosts that require it
- Use `ForwardAgent` only to hosts you fully trust (a compromised intermediate host = credential theft)
- `ssh-add -D` on logout removes keys from the agent
- Restrict `/tmp` permissions on sensitive hosts

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Linux Privilege Escalation Checklist](hacktricks-privilege-escalation-checklist.md)
- [HackTricks](../entities/hacktricks.md)
