$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $repositoryRoot 'ryddeScript.vbs'
$readmePath = Join-Path $repositoryRoot 'README.md'
$licensePath = Join-Path $repositoryRoot 'LICENSE'
$decisionLibraryPath = Join-Path $repositoryRoot 'lib\RyddeDecisions.vbs'
$decisionTestsPath = Join-Path $repositoryRoot 'tests\RyddeDecisions.Tests.vbs'
$failures = [System.Collections.Generic.List[string]]::new()
$assertions = 0

function Assert-True {
    param([bool] $Condition, [string] $Message)
    $script:assertions++
    if (-not $Condition) {
        $script:failures.Add($Message)
    }
}

Assert-True (Test-Path -LiteralPath $scriptPath) 'ryddeScript.vbs is missing'
Assert-True (Test-Path -LiteralPath $readmePath) 'README.md is missing'
Assert-True (Test-Path -LiteralPath $licensePath) 'LICENSE is missing'

$scriptText = Get-Content -LiteralPath $scriptPath -Raw
$readmeText = Get-Content -LiteralPath $readmePath -Raw
$licenseText = Get-Content -LiteralPath $licensePath -Raw
$decisionLibraryText = Get-Content -LiteralPath $decisionLibraryPath -Raw
$decisionTestsText = Get-Content -LiteralPath $decisionTestsPath -Raw
$publicSourceText = $scriptText, $readmeText, $decisionLibraryText, $decisionTestsText -join "`n"

$forbiddenPatterns = @(
    'C:\\Users\\', '[A-Z]:\\Repos\\', 'gh[pousr]_[A-Za-z0-9_]{20,}', 'AKIA[0-9A-Z]{16}',
    'BEGIN [A-Z ]*PRIVATE KEY', '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
)

foreach ($pattern in $forbiddenPatterns) {
    Assert-True (-not [regex]::IsMatch($publicSourceText, $pattern, 'IgnoreCase')) "Forbidden public-source pattern found: $pattern"
}

$headerVersion = [regex]::Match($scriptText, "(?m)^''Version\s+([^\r\n]+)$").Groups[1].Value.Trim()
$runtimeVersion = [regex]::Match($scriptText, '(?m)^versionInfo\s*=\s*"([^"]+)"').Groups[1].Value.Trim()
Assert-True ($headerVersion.Length -gt 0) 'Header version was not found'
Assert-True ($headerVersion -eq $runtimeVersion) 'Header and runtime versions differ'
Assert-True ($scriptText.Contains('IsProtectedProfileName(folder.Name, sCurrentProfileName)')) 'Profile cleanup does not use the protected-profile decision helper'
Assert-True ($scriptText.Contains('CanDeletePath(folder.Path, oLocation.Path)')) 'Profile deletion does not enforce an allowed-root boundary'
Assert-True ($scriptText.Contains('folder.Attributes And 1024')) 'Profile deletion does not reject reparse points'
Assert-True ($scriptText.Contains('WScript.Arguments.Named.Exists("execute")')) 'Destructive execution is not protected by an explicit /execute switch'
Assert-True ($scriptText.Contains('WScript.Arguments.Named.Exists("ccleaner")')) 'CCleaner does not require an explicit /ccleaner switch'
Assert-True ($scriptText.Contains('If Not executionEnabled Then')) 'The script does not default to preview-only mode'
Assert-True ($scriptText.Contains('Delivery Optimization Files')) 'Modern Delivery Optimization cleanup is not configured'
Assert-True ($scriptText.Contains('DirectX Shader Cache')) 'Modern DirectX shader-cache cleanup is not configured'
Assert-True ($scriptText.Contains('IsDismComponentCleanupSupported(osVersion)')) 'Modern Windows component cleanup is not enabled'
Assert-True ($scriptText.Contains('sProtectedRoot = oFSO.GetParentFolderName(WScript.ScriptFullName)')) 'Repository root is not derived from the running script'
Assert-True ($scriptText.Contains('IsPathProtected(candidatePath, sProtectedRoot)')) 'Deletion wrappers do not enforce repository protection'
Assert-True ([regex]::Matches($scriptText, 'oFSO\.DeleteFile').Count -eq 1) 'A file deletion bypasses SafeDeleteFile'
Assert-True ([regex]::Matches($scriptText, 'oFSO\.DeleteFolder').Count -eq 1) 'A folder deletion bypasses SafeDeleteFolder'
Assert-True (-not ($scriptText -match '(?im)^\s*[A-Za-z][A-Za-z0-9]*\.Delete\s')) 'An object deletion bypasses the repository-protection wrappers'
Assert-True (-not ($scriptText -match '(?i)\brmdir\b')) 'A shell folder deletion bypasses repository protection'
Assert-True ($scriptText.Contains('If ccleanerEnabled Then')) 'CCleaner invocation is not guarded by its opt-in switch'
Assert-True ($scriptText.Contains('Sub RunOptionalCCleaner')) 'Optional CCleaner runner is missing'
Assert-True ($scriptText.Contains('ccleanerPath & """ /AUTO')) 'CCleaner does not use its documented automatic Custom Clean command'
Assert-True ($scriptText.Contains('""" /elevated" & relaunchArguments')) 'Cleanup options are not preserved during elevation'
Assert-True ($scriptText.Contains('ExpandEnvironmentStrings("%ProgramData%")')) 'Runtime logs are not stored under ProgramData'
Assert-True ($scriptText.Contains('LCase(Left(file.Name, 9)) = "ryddelog-"')) 'Log rotation is not restricted to ryddeScript logs'
Assert-True ($scriptText.Contains('InStr(candidatePath, "*")')) 'Deletion wrapper does not reject wildcard paths'
Assert-True ($scriptText.Contains('SafeDeleteFolder childFolder.Path, forceDelete')) 'Folder deletion does not traverse through the protected wrapper'
Assert-True ($scriptText.Contains('CleanOldTemporaryItems sCurrentTempPath, 7')) 'Current-user temporary cleanup is missing or has no retention period'
Assert-True ($readmeText -match '(?m)^# ryddeScript - cleanupScript\r?$') 'README title does not include the English project name'
Assert-True ($readmeText -match '(?i)tidy up.+clean up') 'README does not translate the project name'
Assert-True ($readmeText -match '(?i)unsafe to execute') 'README does not clearly warn against execution'
Assert-True ($readmeText -match '(?m)^## Table of contents\r?$') 'README is missing its English table of contents'
Assert-True ($readmeText.Contains('[English](#english)')) 'README table of contents does not link to the English version'
Assert-True ($readmeText.Contains('[Norwegian (short version)](#norsk-kortversjon)')) 'README table of contents does not link to the Norwegian version'
$englishIndex = $readmeText.IndexOf('## English', [StringComparison]::Ordinal)
$norwegianIndex = $readmeText.IndexOf('## Norsk (kortversjon)', [StringComparison]::Ordinal)
Assert-True ($englishIndex -ge 0) 'README is missing the English version'
Assert-True ($norwegianIndex -ge 0) 'README is missing the short Norwegian version'
Assert-True (($englishIndex -ge 0) -and ($norwegianIndex -gt $englishIndex)) 'The English version must appear before the Norwegian version'
Assert-True ($licenseText.StartsWith('MIT License')) 'LICENSE is not the MIT License'
Assert-True ($licenseText -match 'THE SOFTWARE IS PROVIDED "AS IS"') 'License warranty disclaimer is missing'

$previewOutput = & cscript.exe //nologo $scriptPath 2>&1 | Out-String
Assert-True ($LASTEXITCODE -eq 0) 'Default preview returned a failure exit code'
Assert-True ($previewOutput -match '(?i)preview only') 'Default invocation did not display preview mode'
Assert-True ($previewOutput -match '(?i)no files, registry values, services, or system settings were changed') 'Default preview did not confirm that it made no system changes'

$ccleanerPreviewOutput = & cscript.exe //nologo $scriptPath /ccleaner 2>&1 | Out-String
Assert-True ($LASTEXITCODE -eq 0) 'CCleaner without /execute returned a failure exit code'
Assert-True ($ccleanerPreviewOutput -match '(?i)preview only') 'The /ccleaner switch bypassed preview-only mode without /execute'

$temporaryScript = Join-Path ([IO.Path]::GetTempPath()) ("ryddeScript-syntax-{0}.vbs" -f [guid]::NewGuid())
try {
    $syntaxText = $scriptText.Replace("Option Explicit`r`n", "Option Explicit`r`nWScript.Quit 0`r`n", [StringComparison]::Ordinal)
    if ($syntaxText -eq $scriptText) {
        $syntaxText = $scriptText.Replace("Option Explicit`n", "Option Explicit`nWScript.Quit 0`n", [StringComparison]::Ordinal)
    }
    [IO.File]::WriteAllText($temporaryScript, $syntaxText, [Text.UTF8Encoding]::new($false))
    & cscript.exe //nologo $temporaryScript
    Assert-True ($LASTEXITCODE -eq 0) 'VBScript syntax validation failed'
}
finally {
    Remove-Item -LiteralPath $temporaryScript -Force -ErrorAction SilentlyContinue
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "$($failures.Count) of $assertions publication tests failed."
}

Write-Host "Passed $assertions publication tests."
