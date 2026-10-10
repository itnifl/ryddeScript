Option Explicit

Dim fso, repositoryRoot, libraryPath, libraryFile, failures, assertions
Set fso = CreateObject("Scripting.FileSystemObject")
repositoryRoot = fso.GetParentFolderName(fso.GetParentFolderName(WScript.ScriptFullName))
libraryPath = fso.BuildPath(repositoryRoot, "lib\RyddeDecisions.vbs")
Set libraryFile = fso.OpenTextFile(libraryPath, 1, False)
ExecuteGlobal libraryFile.ReadAll
libraryFile.Close

failures = 0
assertions = 0

AssertTrue IsProtectedProfileName("Public", "CurrentUser"), "Public profile is protected"
AssertTrue IsProtectedProfileName("DEFAULT", "CurrentUser"), "Profile checks are case-insensitive"
AssertTrue IsProtectedProfileName("CurrentUser", "currentuser"), "Current profile is protected"
AssertTrue IsProtectedProfileName("", "CurrentUser"), "Empty profile name is protected"
AssertFalse IsProtectedProfileName("TestUser", "CurrentUser"), "Ordinary inactive profile is not automatically protected"

AssertFalse IsOlderThanDays(DateSerial(2026, 10, 4), DateSerial(2026, 10, 10), 7), "Six days is below retention threshold"
AssertTrue IsOlderThanDays(DateSerial(2026, 10, 3), DateSerial(2026, 10, 10), 7), "Seven days meets retention threshold"
AssertTrue IsOlderThanDays(DateSerial(2025, 1, 1), DateSerial(2026, 10, 10), 7), "Old date exceeds retention threshold"

AssertTrue CanDeletePath("X:\Profiles\Test User", "X:\Profiles"), "Child path with spaces is allowed"
AssertTrue CanDeletePath("x:/profiles/test", "X:\Profiles\"), "Path comparison normalizes case and separators"
AssertFalse CanDeletePath("X:\Profiles", "X:\Profiles"), "Allowed root itself is rejected"
AssertFalse CanDeletePath("X:\", "X:\Profiles"), "Drive root is rejected"
AssertFalse CanDeletePath("X:\ProfilesBackup\Test", "X:\Profiles"), "Sibling prefix is rejected"
AssertFalse CanDeletePath("Y:\Profiles\Test", "X:\Profiles"), "Different drive is rejected"
AssertFalse CanDeletePath("", "X:\Profiles"), "Empty candidate is rejected"

AssertTrue IsPathProtected("X:\Projects\ryddeScript", "X:\Projects\ryddeScript"), "Repository root is protected"
AssertTrue IsPathProtected("X:\Projects\ryddeScript\README.md", "X:\Projects\ryddeScript"), "Files inside the repository are protected"
AssertTrue IsPathProtected("X:\Projects", "X:\Projects\ryddeScript"), "An ancestor containing the repository is protected"
AssertTrue IsPathProtected("X:\", "X:\Projects\ryddeScript"), "The repository drive root is a protected ancestor"
AssertTrue IsPathProtected("X:\Projects\ryddeScript\README.md", "X:\"), "A repository at a drive root protects every child"
AssertTrue IsPathProtected("x:/projects/ryddescript/tests", "X:\Projects\ryddeScript\"), "Repository protection normalizes paths"
AssertFalse IsPathProtected("X:\Projects\another-project", "X:\Projects\ryddeScript"), "Sibling repositories are not protected"
AssertFalse IsPathProtected("C:\Windows\Temp\old.tmp", "X:\Projects\ryddeScript"), "Unrelated cleanup targets are not protected"
AssertTrue IsPathProtected("", "X:\Projects\ryddeScript"), "An empty candidate fails closed"
AssertTrue IsPathProtected("C:\Temp\old.tmp", ""), "An empty protected root fails closed"

AssertFalse IsDismComponentCleanupSupported("6.1.7601"), "Windows 7 and Server 2008 R2 use the legacy cleanup path"
AssertTrue IsDismComponentCleanupSupported("6.2.9200"), "Windows 8 and Server 2012 support component cleanup"
AssertTrue IsDismComponentCleanupSupported("10.0.26100"), "Windows 10 and 11 support component cleanup"
AssertFalse IsDismComponentCleanupSupported("invalid"), "Invalid Windows versions are rejected"

If failures > 0 Then
	WScript.Echo failures & " of " & assertions & " decision tests failed."
	WScript.Quit 1
End If

WScript.Echo "Passed " & assertions & " decision tests."
WScript.Quit 0

Sub AssertTrue(actual, testName)
	assertions = assertions + 1
	If Not CBool(actual) Then
		failures = failures + 1
		WScript.Echo "FAIL: " & testName
	End If
End Sub

Sub AssertFalse(actual, testName)
	AssertTrue Not CBool(actual), testName
End Sub
