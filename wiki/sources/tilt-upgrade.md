---
title: "Tilt: Upgrade Guide"
tags: [tilt, upgrade, installation, package-managers]
sources: [tilt-upgrade]
updated: 2026-07-01
---

# Tilt Upgrade Guide

Reference: [Tilt GitHub Releases](https://github.com/tilt-dev/tilt/releases)

The recommended upgrade path depends on how Tilt was originally installed. See [[tilt-install]] for the original install methods.

## Quick Upgrade (Default Install)

For most users who installed via the official script, rerunning the same script is sufficient.

| OS            | Command                                                                                                                         |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| macOS / Linux | `curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh \| bash`                                  |
| Windows       | `iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.ps1'))` |

## Package Manager Upgrades

| Method   | Command                                         | Notes                     |
| -------- | ----------------------------------------------- | ------------------------- |
| Homebrew | `brew update && brew upgrade tilt-dev/tap/tilt` | macOS or Linux            |
| Scoop    | `scoop update tilt`                             | Windows                   |
| Conda    | `conda update -c conda-forge tilt`              | Cross-platform            |
| asdf     | See below                                       | Pin to a specific version |

### asdf

asdf requires explicit version selection:

```sh
asdf plugin add tilt
asdf install tilt 0.37.4
asdf global tilt 0.37.4
```

Replace `0.37.4` with the desired version from the releases page.

## Manual Binary Upgrade

If Tilt was installed by placing a binary in `PATH`, download and replace it manually.

**macOS:**

```sh
curl -fsSL https://github.com/tilt-dev/tilt/releases/download/v0.37.4/tilt.0.37.4.mac.x86_64.tar.gz | tar -xzv tilt && \
  sudo mv tilt /usr/local/bin/tilt
```

**Linux:**

```sh
curl -fsSL https://github.com/tilt-dev/tilt/releases/download/v0.37.4/tilt.0.37.4.linux.x86_64.tar.gz | tar -xzv tilt && \
  sudo mv tilt /usr/local/bin/tilt
```

**Windows (PowerShell):**

```powershell
Invoke-WebRequest "https://github.com/tilt-dev/tilt/releases/download/v0.37.4/tilt.0.37.4.windows.x86_64.zip" -OutFile "tilt.zip"
Expand-Archive "tilt.zip" -DestinationPath "tilt"
Move-Item -Force -Path "tilt\tilt.exe" -Destination "$home\bin\tilt.exe"
```

## Gotchas

- **Wrong upgrade method:** If the install script is rerun but Tilt was originally installed via Homebrew, Scoop, Conda, or asdf, the script-installed binary may shadow or conflict with the package-manager-managed one. Use the method matching the original install.
- **asdf requires explicit version:** Unlike other package managers, asdf does not have an "upgrade to latest" shorthand — you must specify the target version number.
- **Manual install PATH:** On Windows, ensure `$home\bin` is on `PATH`; it is not added automatically.

## See Also

- [[tilt]] — overview of the Tilt dev tool
- [[tilt-install]] — first-time installation guide
