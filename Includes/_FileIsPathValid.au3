#include-once
; #INDEX# =======================================================================================================================
; Title .........: _FileIsPathValid UDF
; AutoIt Version : 3.3.6+
; Language ......: English
; Description ...: Functions for checking if a File/Directory Path is Valid
; Author(s) .....: Shafayat (sss13x@yahoo.com)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _FileIsPathValid()
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _FileIsPathValid
; Description ...: checks if a File/Directory Path is Valid
; Syntax.........: _FileIsPathValid($Path, $Verbose = 0)
; Parameters ....: $Path - File/Directory Path to work with
;                  $Verbose  - OutPut (ConsoleWrite) additional information of invalidity of Path
;				   |0 - No OutPut
;				   |1 - OutPut to Console if Not Compiled
;				   |1 - OutPut to Console Always
; Return values .: Success - True
;                  Failure - False
; Author ........: Shafayat (sss13x@yahoo.com)
; Example .......: Yes
; ===============================================================================================================================

Func _FileIsPathValid($Path, $Verbose = 0)
	Local $PathOri = $Path
	Local $Excluded[8] = [7, "\\", "?", "*", '"', "<", ">", "|"] ;List of invalid characters
	Local $Alphabet = StringSplit("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "")
	Local $Reasons = ""
	Local $Valid = 1
	; Lenght Check
	If StringLen($Path) < 3 Then
		$Reasons = $Reasons & @CRLF & "LENGTH: Entire Pathname must be more than 3 characters (including drive)."
		$Valid = 0
	EndIf
	; Drive Check
	Local $pos = StringInStr($Path, ":\")
	If $pos <> 2 Then
		$Reasons = $Reasons & @CRLF & 'STRUCTURE: Drive letter must be one chars long and must be followed by ":\".'
		$Valid = 0
	Else
		Local $chrdrv = StringUpper(StringLeft($Path, 1))
		Local $found = 0
		For $i = 0 To $Alphabet[0]
			If $chrdrv = $Alphabet[$i] Then
				$found = 1
			EndIf
		Next
		If $found = 0 Then
			$Reasons = $Reasons & @CRLF & "ILLEGAL CHARACTER: Illegal character used as drive letter."
			$Valid = 0
		EndIf
	EndIf
	$Path = StringTrimLeft($Path, 3)
	; Path + Name Check
	For $i = 0 To $Excluded[0]
		If StringInStr($Path, $Excluded[$i]) <> 0 Then
			$Reasons = $Reasons & @CRLF & "ILLEGAL CHARACTER: " & $Excluded[$i]
			$Valid = 0
		EndIf
	Next

	If $Verbose = 2 And $Valid = 0 Then ConsoleWrite(@CRLF & "Invalid Path: " & $PathOri & $Reasons & @CRLF)
	If $Verbose = 1 And $Valid = 0 And @Compiled = False Then ConsoleWrite(@CRLF & "=============" & @CRLF & "Invalid Path: " & $PathOri & $Reasons & @CRLF)
	Return $Valid
EndFunc   ;==>_FileIsPathValid