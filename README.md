# ryddeScript - cleanupScript

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
- **Repository protection:** reject deletion of the repository itself, anything inside it, or any ancestor directory containing it.
- **Windows maintenance tools:** invoke utilities such as Disk Cleanup, DISM, `compact`, `powercfg`, and `vssadmin`.
- **Modern Windows caches:** include Delivery Optimization files and the DirectX shader cache through Windows Disk Cleanup.
- **Current-user temporary files:** remove top-level files and folders from `%TEMP%` only after they are at least seven days old.
- **Server-role cleanup:** handle generic IIS, Exchange, and WSUS log or maintenance locations when present.
- **Logging and reporting:** record attempted actions and compare free disk space before and after execution.
- **Elevation:** relaunch through `cscript.exe` with administrative rights when required.

Environment-specific product paths, private deployment conventions, personal names, credentials, machine names, and organization-specific cleanup rules are intentionally excluded from the public version.

All direct file and folder deletions pass through a single repository-protection boundary. The boundary rejects the repository, its contents, ancestor folders, wildcard file deletions, and filesystem reparse points. Folder trees are traversed item by item without following junctions. Runtime logs are stored under `%ProgramData%\ryddeScript\Logs`, not in the checkout, and only logs created by ryddeScript are rotated.

### Additional cleanup added

- Current-account `%TEMP%` items are eligible only after seven days.
- Font-cache files are eligible only after 30 days and are deleted through the protected wrapper.
- Delivery Optimization and DirectX shader caches are included through Windows Disk Cleanup.
- DISM component-store cleanup supports modern Windows versions.

### Optional CCleaner

CCleaner is never run by default. Supplying both `/execute` and `/ccleaner` runs CCleaner's supported `/AUTO` command, which uses the options already saved in Custom Clean and does not run Registry Cleaner. Review CCleaner's saved includes and exclusions first: external CCleaner rules cannot be constrained by ryddeScript's repository-protection wrapper. See [CCleaner's official command-line documentation](https://support.ccleaner.com/articles/en_US/Master_Article/command-line-parameters-for-ccleaner-for-windows).

### Important safety warning

This is historical code, not a production-ready cleanup utility. It performs broad and potentially destructive actions, including deleting files, user-profile data, shadow copies, restore points, and installer caches. Some logic targets Windows and server products that are now old. Running it without arguments is a non-destructive preview; destructive execution requires the explicit `/execute` switch.

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

GitHub Actions is configured to run both commands for every pull request and every push to `main`. The check is temporarily optional while repository billing prevents hosted jobs from starting; make it required again once Actions is available.

### Historical invocation

The safe default displays the execution plan without changing the machine:

```bat
cscript //nologo ryddeScript.vbs
```

After a complete code and safety review, the destructive legacy workflow can be explicitly enabled from an elevated command prompt with:

```bat
cscript //nologo ryddeScript.vbs /execute
```

CCleaner can additionally be requested with:

```bat
cscript //nologo ryddeScript.vbs /execute /ccleaner
```

The execution commands document the interface; they are not a recommendation to run the script on a real machine.

### Recommended modernization

A safer successor should be split into small operations, make dry-run behavior the default, require explicit opt-in for every destructive category, validate deletion boundaries, avoid following reparse points, and expose testable decision logic separately from filesystem and registry changes.

### License and responsibility

The project is available under the [MIT License](LICENSE). Anyone may use, copy, modify, merge, publish, distribute, sublicense, or sell copies. The software is provided “as is”, without warranty; users are responsible for reviewing, testing, and operating it safely.

## Norsk (kortversjon)

**«Rydde» betyr å ordne eller gjøre rent. `ryddeScript` betyr derfor «ryddeskript».**

Dette er et eldre VBScript fra 2015 for opprydding på Windows-maskiner og -servere. Det beskytter repoet og mapper som inneholder det, og kan rydde midlertidige filer som er eldre enn sju dager. Uten argumenter viser skriptet bare en trygg forhåndsvisning; `/execute` må oppgis for å kjøre oppryddingen. CCleaner kjøres bare når både `/execute` og `/ccleaner` er oppgitt, og bruker da CCleaners egne lagrede valg.

Skriptet kan slette filer, profildata, skyggekopier, gjenopprettingspunkter og installasjonsbuffere. Det er historisk kode og er **ikke trygt å kjøre som publisert**. Les hele kildekoden, innfør en reell tørrkjøringsmodus, ta sikkerhetskopi og test i en midlertidig virtuell maskin først.

Testene er ikke-destruktive og kjøres automatisk for pull requests. Prosjektet bruker [MIT-lisensen](LICENSE), uten garanti; brukeren har selv ansvar for sikker bruk.
