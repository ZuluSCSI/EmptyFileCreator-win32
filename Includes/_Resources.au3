#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#region    ;************ Includes ************
#include-once
#include <Constants.au3>
#include <GDIPlus.au3>
#include <Memory.au3>
#endregion    ;************ Includes ************

_GDIPlus_Startup()

Func _ResourceGet($ResName, $ResType = 10, $ResLang = 0, $DLL = -1) ; $RT_RCDATA = 10
	Local Const $IMAGE_BITMAP = 0
	Local $hInstance, $hBitmap, $InfoBlock, $GlobalMemoryBlock, $MemoryPointer, $ResSize

	If $DLL = -1 Then
		$hInstance = _WinAPI_GetModuleHandle("")
	Else
		$hInstance = _WinAPI_LoadLibraryEx($DLL, $LOAD_LIBRARY_AS_DATAFILE)
	EndIf
	If $hInstance = 0 Then Return SetError(1, 0, 0)

	If $ResType = $RT_BITMAP Then
		$hBitmap = _WinAPI_LoadImage($hInstance, $ResName, $IMAGE_BITMAP, 0, 0, 0)
		If @error Then Return SetError(2, 0, 0)
		Return $hBitmap ; returns handle to Bitmap
	EndIf

	If $ResLang <> 0 Then
		$InfoBlock = DllCall("kernel32.dll", "ptr", "FindResourceExW", "ptr", $hInstance, "long", $ResType, "wstr", $ResName, "short", $ResLang)
	Else
		$InfoBlock = DllCall("kernel32.dll", "ptr", "FindResourceW", "ptr", $hInstance, "wstr", $ResName, "long", $ResType)
	EndIf

	If @error Then Return SetError(3, 0, 0)
	$InfoBlock = $InfoBlock[0]
	If $InfoBlock = 0 Then Return SetError(4, 0, 0)

	$ResSize = DllCall("kernel32.dll", "dword", "SizeofResource", "ptr", $hInstance, "ptr", $InfoBlock)
	If @error Then Return SetError(5, 0, 0)
	$ResSize = $ResSize[0]
	If $ResSize = 0 Then Return SetError(6, 0, 0)

	$GlobalMemoryBlock = DllCall("kernel32.dll", "ptr", "LoadResource", "ptr", $hInstance, "ptr", $InfoBlock)
	If @error Then Return SetError(7, 0, 0)
	$GlobalMemoryBlock = $GlobalMemoryBlock[0]
	If $GlobalMemoryBlock = 0 Then Return SetError(8, 0, 0)

	$MemoryPointer = DllCall("kernel32.dll", "ptr", "LockResource", "ptr", $GlobalMemoryBlock)
	If @error Then Return SetError(9, 0, 0)
	$MemoryPointer = $MemoryPointer[0]
	If $MemoryPointer = 0 Then Return SetError(10, 0, 0)

	If $DLL <> -1 Then _WinAPI_FreeLibrary($hInstance)
	If @error Then Return SetError(11, 0, 0)

	SetExtended($ResSize)
	Return $MemoryPointer
EndFunc   ;==>_ResourceGet

; for ANSI strings
Func _ResourceGetAsString($ResName, $ResType = 10, $ResLang = 0, $DLL = -1) ; $RT_RCDATA = 10
	Local $ResPointer, $ResSize, $struct

	$ResPointer = _ResourceGet($ResName, $ResType, $ResLang, $DLL)
	If @error Then
		SetError(1, 0, 0)
		Return ''
	EndIf
	$ResSize = @extended
	$struct = DllStructCreate("char[" & $ResSize & "]", $ResPointer)
	Return DllStructGetData($struct, 1) ; returns string
EndFunc   ;==>_ResourceGetAsString

; for Unicode strings (Widechar)
Func _ResourceGetAsStringW($ResName, $ResType = 10, $ResLang = 0, $DLL = -1) ; $RT_RCDATA = 10
	Local $ResPointer, $ResSize, $struct

	$ResPointer = _ResourceGet($ResName, $ResType, $ResLang, $DLL)
	If @error Then
		SetError(1, 0, 0)
		Return ''
	EndIf
	$ResSize = @extended
	$struct = DllStructCreate("wchar[" & $ResSize & "]", $ResPointer)
	Return DllStructGetData($struct, 1) ; returns string
EndFunc   ;==>_ResourceGetAsStringW

; _ResourceGetAsBytes() doesn't work for RT_BITMAP type
; because _ResourceGet() returns hBitmap instead of memory pointer in this case
Func _ResourceGetAsBytes($ResName, $ResType = 10, $ResLang = 0, $DLL = -1) ; $RT_RCDATA = 10
	Local $ResPointer, $ResSize

	$ResPointer = _ResourceGet($ResName, $ResType, $ResLang, $DLL)
	If @error Then Return SetError(1, 0, 0)
	$ResSize = @extended
	Return DllStructCreate("byte[" & $ResSize & "]", $ResPointer) ; returns struct with bytes
EndFunc   ;==>_ResourceGetAsBytes

; returned hImage can be used in many GDI+ functions:
; $width =  _GDIPlus_ImageGetWidth ($hImage)
; $height = _GDIPlus_ImageGetHeight($hImage)
Func _ResourceGetAsImage($ResName, $ResType = 10, $DLL = -1) ; $RT_RCDATA = 10
	Local $ResData, $nSize, $hData, $pData, $pStream

	$ResData = _ResourceGet($ResName, $ResType, 0, $DLL)
	If @error Then Return SetError(1, 0, 0)
	$nSize = @extended

	If $ResType = $RT_BITMAP Then
		; $ResData is hBitmap type
		Local $hImage = _GDIPlus_BitmapCreateFromHBITMAP($ResData)
	Else
		; $ResData is memory pointer
		; thanks ProgAndy
		$hData = _MemGlobalAlloc($nSize, 2)
		$pData = _MemGlobalLock($hData)
		_MemMoveMemory($ResData, $pData, $nSize)
		_MemGlobalUnlock($hData)
		$pStream = DllCall("ole32.dll", "int", "CreateStreamOnHGlobal", "ptr", $hData, "int", 1, "ptr*", 0)
		$pStream = $pStream[3]
		$hImage = DllCall($__g_hGDIPDll, "int", "GdipCreateBitmapFromStream", "ptr", $pStream, "ptr*", 0)
		$hImage = $hImage[2]
		_WinAPI_DeleteObject($pStream)
		; next line must be commented otherwise animated GIFs will not work
;~ 		_MemGlobalFree($hData)
	EndIf

	Return $hImage ; hImage type
EndFunc   ;==>_ResourceGetAsImage

Func _ResourceGetAsBitmap($ResName, $ResType = 10, $DLL = -1) ; $RT_RCDATA = 10
	Local $hImage = _ResourceGetAsImage($ResName, $ResType, $DLL)
	If @error Then Return SetError(1, 0, 0)
	Local $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	Return $hBitmap ; hBitmap type
EndFunc   ;==>_ResourceGetAsBitmap

Func _ResourceSaveToFile($FileName, $ResName, $ResType = 10, $ResLang = 0, $CreatePath = 0, $DLL = -1) ; $RT_RCDATA = 10
	Local $ResStruct, $ResSize, $FileHandle

	If $CreatePath Then $CreatePath = 8 ; mode 8 = Create directory structure if it doesn't exist in FileOpen()

	If $ResType = $RT_BITMAP Then
		; workaround: for RT_BITMAP _ResourceGetAsBytes() doesn't work so use _ResourceGetAsImage()
		Local $hImage = _ResourceGetAsImage($ResName, $ResType)
		If @error Then Return SetError(10, 0, 0)

		; create filepath if doesn't exist
		$FileHandle = FileOpen($FileName, 2 + 16 + $CreatePath)
		If @error Then Return SetError(11, 0, 0)
		FileClose($FileHandle)
		If @error Then Return SetError(12, 0, 0)

		_GDIPlus_ImageSaveToFile($hImage, $FileName)
		_GDIPlus_ImageDispose($hImage)

		$ResSize = FileGetSize($FileName)
	Else
		; standard way
		$ResStruct = _ResourceGetAsBytes($ResName, $ResType, $ResLang, $DLL)
		If @error Then Return SetError(1, 0, 0)
		$ResSize = DllStructGetSize($ResStruct)

		$FileHandle = FileOpen($FileName, 2 + 16 + $CreatePath)
		If @error Then Return SetError(2, 0, 0)
		FileWrite($FileHandle, DllStructGetData($ResStruct, 1))
		If @error Then Return SetError(3, 0, 0)
		FileClose($FileHandle)
		If @error Then Return SetError(4, 0, 0)
	EndIf

	Return $ResSize
EndFunc   ;==>_ResourceSaveToFile

Func _ResourceSetImageToCtrl($CtrlId, $ResName, $ResType = 10, $DLL = -1) ; $RT_RCDATA = 10
	Local $ResData, $nSize, $hData, $pData, $pStream, $pBitmap, $hBitmap

	$ResData = _ResourceGet($ResName, $ResType, 0, $DLL)
	If @error Then Return SetError(1, 0, 0)
	$nSize = @extended

	If $ResType = $RT_BITMAP Then
		_SetBitmapToCtrl($CtrlId, $ResData)
		If @error Then Return SetError(2, 0, 0)
	Else
		; thanks ProgAndy
		; for other types than BITMAP use GDI+ for converting to bitmap first
		$hData = _MemGlobalAlloc($nSize, 2)
		$pData = _MemGlobalLock($hData)
		_MemMoveMemory($ResData, $pData, $nSize)
		_MemGlobalUnlock($hData)
		$pStream = DllCall("ole32.dll", "int", "CreateStreamOnHGlobal", "ptr", $hData, "int", 1, "ptr*", 0)
		$pStream = $pStream[3]
		$pBitmap = DllCall($__g_hGDIPDll, "int", "GdipCreateBitmapFromStream", "ptr", $pStream, "ptr*", 0)
		$pBitmap = $pBitmap[2]
		$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($pBitmap)
		_SetBitmapToCtrl($CtrlId, $hBitmap)
		If @error Then SetError(3, 0, 0)
		_GDIPlus_BitmapDispose($pBitmap)
		_WinAPI_DeleteObject($pStream)
		_MemGlobalFree($hData)
	EndIf

	Return 1
EndFunc   ;==>_ResourceSetImageToCtrl

; internal helper function
; thanks for improvements Melba
Func _SetBitmapToCtrl($CtrlId, $hBitmap)
	Local Const $STM_SETIMAGE = 0x0172
	Local Const $BM_SETIMAGE = 0xF7
	Local Const $IMAGE_BITMAP = 0
	Local Const $SS_BITMAP = 0x0E
	Local Const $BS_BITMAP = 0x0080
	Local Const $GWL_STYLE = -16

	Local $hWnd, $hPrev, $Style, $iCtrl_SETIMAGE, $iCtrl_BITMAP

	$hWnd = GUICtrlGetHandle($CtrlId)
	If $hWnd = 0 Then Return SetError(1, 0, 0)

	$CtrlId = _WinAPI_GetDlgCtrlID($hWnd) ; support for $CtrlId = -1
	If @error Then Return SetError(2, 0, 0)

	; determine control class and adjust constants accordingly
	Switch _WinAPI_GetClassName($CtrlId)
		Case "Button" ; button,checkbox,radiobutton,groupbox
			$iCtrl_SETIMAGE = $BM_SETIMAGE
			$iCtrl_BITMAP = $BS_BITMAP
		Case "Static" ; picture,icon,label
			$iCtrl_SETIMAGE = $STM_SETIMAGE
			$iCtrl_BITMAP = $SS_BITMAP
		Case Else
			Return SetError(3, 0, 0)
	EndSwitch

	; set SS_BITMAP/BS_BITMAP style to the control
	$Style = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
	If @error Then Return SetError(4, 0, 0)
	_WinAPI_SetWindowLong($hWnd, $GWL_STYLE, BitOR($Style, $iCtrl_BITMAP))
	If @error Then Return SetError(5, 0, 0)

	; set image to the control
	$hPrev = _SendMessage($hWnd, $iCtrl_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
	If @error Then Return SetError(6, 0, 0)
	If $hPrev Then _WinAPI_DeleteObject($hPrev)

	Return 1
EndFunc   ;==>_SetBitmapToCtrl

; thanks Larry,ProgAndy
; MSDN: http://msdn2.microsoft.com/en-us/library/ms712879.aspx
; default flag is $SND_SYNC = 0
Func _ResourcePlaySound($ResName, $Flag = 0, $DLL = -1)
	If $DLL = -1 Then
		Local $hInstance = 0
	Else
		$hInstance = _WinAPI_LoadLibraryEx($DLL, $LOAD_LIBRARY_AS_DATAFILE)
	EndIf

	Local $ret = DllCall("winmm.dll", "int", "PlaySound", "str", $ResName, "hwnd", $hInstance, "int", BitOR($SND_RESOURCE, $Flag))
	If @error Then Return SetError(1, 0, 0)

	If $DLL <> -1 Then _WinAPI_FreeLibrary($hInstance)
	If @error Then Return SetError(2, 0, 0)

	Return $ret[0]
EndFunc   ;==>_ResourcePlaySound
