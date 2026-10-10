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

AssertTrue IsProtectedProfileName("Public", "Atle"), "Public profile is protected"
AssertTrue IsProtectedProfileName("DEFAULT", "Atle"), "Profile checks are case-insensitive"
AssertTrue IsProtectedProfileName("Atle", "atle"), "Current profile is protected"
AssertTrue IsProtectedProfileName("", "Atle"), "Empty profile name is protected"
AssertFalse IsProtectedProfileName("TestUser", "Atle"), "Ordinary inactive profile is not automatically protected"

AssertFalse IsOlderThanDays(DateSerial(2026, 10, 4), DateSerial(2026, 10, 10), 7), "Six days is below retention threshold"
AssertTrue IsOlderThanDays(DateSerial(2026, 10, 3), DateSerial(2026, 10, 10), 7), "Seven days meets retention threshold"
AssertTrue IsOlderThanDays(DateSerial(2025, 1, 1), DateSerial(2026, 10, 10), 7), "Old date exceeds retention threshold"

AssertTrue CanDeletePath("C:\Users\Test User", "C:\Users"), "Child path with spaces is allowed"
AssertTrue CanDeletePath("c:/users/test", "C:\Users\"), "Path comparison normalizes case and separators"
AssertFalse CanDeletePath("C:\Users", "C:\Users"), "Allowed root itself is rejected"
AssertFalse CanDeletePath("C:\", "C:\Users"), "Drive root is rejected"
AssertFalse CanDeletePath("C:\UsersBackup\Test", "C:\Users"), "Sibling prefix is rejected"
AssertFalse CanDeletePath("D:\Users\Test", "C:\Users"), "Different drive is rejected"
AssertFalse CanDeletePath("", "C:\Users"), "Empty candidate is rejected"

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
