# ryddeScript

## Table of contents

- [English](#english)
- [Norwegian (short version)](#norsk-kortversjon)

## English

**“Rydde” is Norwegian for “tidy up” or “clean up”, so `ryddeScript` means “cleanup script”.**

`ryddeScript` is a legacy VBScript from 2015 that explores automated cleanup of Windows workstations and servers. It inventories common sources of disk usage, applies age- and size-based retention rules, logs its work, and invokes built-in Windows maintenance tools.

### What the script does

The script is organized as a sequential cleanup workflow. Its main concepts are:

- **Discovery:** inspect the Windows version, architecture, registry, filesystem, and installed server roles before deciding whether a cleanup step applies.
- **Retention rules:** identify selected temporary files, dumps, logs, and folders by age, size, name, or location.
- **Windows maintenance tools:** invoke utilities such as Disk Cleanup, DISM, `compact`, `powercfg`, and `vssadmin`.
- **Server-role cleanup:** handle generic IIS, Exchange, and WSUS log or maintenance locations when present.
- **Logging and reporting:** record attempted actions and compare free disk space before and after execution.
- **Elevation:** relaunch through `cscript.exe` with administrative rights when required.

Environment-specific product paths, private deployment conventions, personal names, credentials, machine names, and organization-specific cleanup rules are intentionally excluded from the public version.

### Important safety warning

This is historical code, not a production-ready cleanup utility. It performs broad and potentially destructive actions, including deleting files, user-profile data, shadow copies, restore points, and installer caches. Some logic targets Windows and server products that are now old.

Do not run it on a real machine without first:

1. reading and understanding the complete source;
2. removing or disabling actions that are inappropriate for the target system;
3. implementing and verifying a genuine dry-run mode;
4. creating and testing recoverable backups;
5. testing inside a disposable virtual machine.

The repository currently preserves the legacy implementation for review and modernization. It should be considered unsafe to execute as published.

### Repository contents

- `ryddeScript.vbs` — sanitized legacy cleanup script.
- `lib/RyddeDecisions.vbs` — side-effect-free safety and retention decisions used by the legacy script.
- `tests/` — decision-unit, publication, and parser tests.
- `LICENSE` — MIT License; use and modification are permitted without warranty.

### Tests

The test suite is intentionally non-destructive. It exercises pure decision helpers and validates the public source without running the cleanup workflow:

```powershell
cscript.exe //nologo tests/RyddeDecisions.Tests.vbs
./tests/Test-Publication.ps1
```

GitHub Actions runs both commands for every pull request and every push to `main`. The `Tests` check is required by branch protection, so a failing test prevents the pull request from being merged.

### Historical invocation

After a complete code and safety review, the legacy script would be invoked from an elevated command prompt with:

```bat
cscript //nologo ryddeScript.vbs
```

This command is documentation of the original interface, not a recommendation to execute the current script.

### Recommended modernization

A safer successor should be split into small operations, make dry-run behavior the default, require explicit opt-in for every destructive category, validate deletion boundaries, avoid following reparse points, and expose testable decision logic separately from filesystem and registry changes.

### License and responsibility

The project is available under the [MIT License](LICENSE). Anyone may use, copy, modify, merge, publish, distribute, sublicense, or sell copies. The software is provided “as is”, without warranty; users are responsible for reviewing, testing, and operating it safely.

## Norsk (kortversjon)

**«Rydde» betyr å ordne eller gjøre rent. `ryddeScript` betyr derfor «ryddeskript».**

Dette er et eldre VBScript fra 2015 for opprydding på Windows-maskiner og -servere. Det finner utvalgte midlertidige filer, logger og andre diskplasskrevende data, og bruker regler for alder og størrelse før opprydding.

Skriptet kan slette filer, profildata, skyggekopier, gjenopprettingspunkter og installasjonsbuffere. Det er historisk kode og er **ikke trygt å kjøre som publisert**. Les hele kildekoden, innfør en reell tørrkjøringsmodus, ta sikkerhetskopi og test i en midlertidig virtuell maskin først.

Testene er ikke-destruktive og kjøres automatisk for pull requests. Prosjektet bruker [MIT-lisensen](LICENSE), uten garanti; brukeren har selv ansvar for sikker bruk.
