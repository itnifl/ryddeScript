' Pure decision helpers. This file must not perform filesystem, registry, process,
' service, or operating-system changes so it can be safely unit tested.

Function NormalizePathForComparison(pathValue)
	Dim normalized
	normalized = Replace(Trim(CStr(pathValue)), "/", "\")
	Do While Len(normalized) > 3 And Right(normalized, 1) = "\"
		normalized = Left(normalized, Len(normalized) - 1)
	Loop
	NormalizePathForComparison = LCase(normalized)
End Function

Function IsDriveRoot(pathValue)
	Dim normalized
	normalized = NormalizePathForComparison(pathValue)
	IsDriveRoot = (Len(normalized) = 3 And Mid(normalized, 2, 2) = ":\")
End Function

Function CanDeletePath(candidatePath, allowedRoot)
	Dim candidate, root
	candidate = NormalizePathForComparison(candidatePath)
	root = NormalizePathForComparison(allowedRoot)

	CanDeletePath = False
	If Len(candidate) = 0 Or Len(root) = 0 Then Exit Function
	If IsDriveRoot(candidate) Then Exit Function
	If candidate = root Then Exit Function
	If Left(candidate, Len(root) + 1) = root & "\" Then
		CanDeletePath = True
	End If
End Function

Function IsOlderThanDays(modifiedAt, referenceAt, minimumDays)
	IsOlderThanDays = (DateDiff("d", CDate(modifiedAt), CDate(referenceAt)) >= CLng(minimumDays))
End Function

Function IsDismComponentCleanupSupported(versionValue)
	Dim parts, majorVersion, minorVersion
	IsDismComponentCleanupSupported = False
	parts = Split(Trim(CStr(versionValue)), ".")
	If UBound(parts) < 1 Then Exit Function
	If Not IsNumeric(parts(0)) Or Not IsNumeric(parts(1)) Then Exit Function

	majorVersion = CLng(parts(0))
	minorVersion = CLng(parts(1))
	IsDismComponentCleanupSupported = (majorVersion > 6 Or (majorVersion = 6 And minorVersion >= 2))
End Function

Function IsProtectedProfileName(profileName, currentProfileName)
	Dim normalizedName, normalizedCurrent, protectedNames, item
	normalizedName = LCase(Trim(CStr(profileName)))
	normalizedCurrent = LCase(Trim(CStr(currentProfileName)))
	protectedNames = Array("all users", "alle brukere", "default", "default user", "public", "administrator", "defaultapppool", "wdagutilityaccount")

	IsProtectedProfileName = False
	If Len(normalizedName) = 0 Then
		IsProtectedProfileName = True
		Exit Function
	End If
	If Len(normalizedCurrent) > 0 And normalizedName = normalizedCurrent Then
		IsProtectedProfileName = True
		Exit Function
	End If
	For Each item In protectedNames
		If normalizedName = item Then
			IsProtectedProfileName = True
			Exit Function
		End If
	Next
End Function
