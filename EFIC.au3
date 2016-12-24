#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\icon.ico
#AutoIt3Wrapper_Outfile=EFIC_v1.2.0.0_x86.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=EFIC1.2.0.0
#AutoIt3Wrapper_Res_Description=EFIC1.2.0.0
#AutoIt3Wrapper_Res_Fileversion=1.2.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Copyright (c) 2012-2013 Gajjar Tejas
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=CompanyName|Gajjar Tejas's Blog
#AutoIt3Wrapper_Res_Field=Compile Date|%longdate% %time%
#AutoIt3Wrapper_Res_Field=Internal Name|EFIC.exe
#AutoIt3Wrapper_Res_Field=ProductName|EFIC.exe
#AutoIt3Wrapper_Res_Field=ProductVersion|1.2.0.0
#AutoIt3Wrapper_Res_Field=OriginalFilename|EFIC.exe
#AutoIt3Wrapper_Res_File_Add=Resources\wintop.jpg, rt_rcdata, wintop
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#AutoIt3Wrapper_Run_After=del "EFIC_stripped.au3"
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#region    ;************ Includes ************
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <GuiDateTimePicker.au3>
#include <String.au3>
#include "Includes\_Resources.au3"
#include "Includes\_FileIsPathValid.au3"
#include "Includes\_FileEx.au3"
#endregion    ;************ Includes ************

OnAutoItExitRegister("_FreeBuffers") ;Empty 2MB Memory Buffer on exit
Opt("MustDeclareVars", 1)

#region global Variables
Global Const $s_Current_Version = "1.2.0.0"
Global Const $s_Win_Title = "EFIC" & $s_Current_Version
Global Const $s_Build_Date = FileGetVersion(@ScriptFullPath, "Compile date")
Global Const $i_xWidth = 282
Global Const $i_yHight = 360
Global Const $i_xWinPos = (@DesktopWidth - $i_xWidth) / 2
Global Const $i_yWinPos = (@DesktopHeight - $i_yHight) / 2

Global $__g_apBuffers = 0, $__g_iMaxWriteSize = (1024 ^ 2) * 2, $__g_hCryptContext[2] = [0, 0]

#endregion global Variables

#region ### START Koda GUI section ###
Local $idMainWin = GUICreate($s_Win_Title, $i_xWidth, $i_yHight, $i_xWinPos, $i_yWinPos)
GUISetBkColor(0xFFFFFF)
Local $idPic1 = GUICtrlCreatePic("", 0, 0, 281, 41, 67108864)
_ResourceSetImageToCtrl($idPic1, "wintop")

#region Location
GUICtrlCreateGroup("Location", 5, 10, 270, 65)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
Local $idInput_File = GUICtrlCreateInput("", 15, 35, 171, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
GUICtrlSetTip(-1, "Browse File Path", "File Location(Required)", 1)
Local $idButton_Browse = GUICtrlCreateButton("Browse...v", 195, 33, 75, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
#endregion Location

GUICtrlCreateGroup("Options", 5, 86, 270, 225)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")

#region Read File Size
Local $idLabel_File_Size = GUICtrlCreateLabel("File Size:", 15, 105, 46, 17)
Local $idInput_File_Size = GUICtrlCreateInput("0", 85, 102, 81, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT, $ES_NUMBER))
GUICtrlSetTip(-1, "File Size in Integer" & @CRLF & "If Empty Then Zero Byte File Will be Created.", "File Size(Optional)", 1)
Local $idButton_UP_DOWN_1 = GUICtrlCreateUpdown($idInput_File_Size)
Local $idCombo_Size = GUICtrlCreateCombo("", 175, 102, 50, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Bytes|KB|MB|GB", "Bytes")
Local $idButton_Menu_Size = GUICtrlCreateButton("6", 230, 101, 30, 23)
GUICtrlSetFont(-1, 10, 400, 0, "Webdings")
#endregion Read File Size

#region Read Filling Char
Local $idLabel_Filling_Bytes = GUICtrlCreateLabel("Fill With:", 15, 135, 62, 17)
Local $idCombo_Fill_Pattern = GUICtrlCreateCombo("", 85, 132, 130, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Do Not Fill (Faster)|Random Hex Type-1|Random Hex Type-2|Random Hex Type-3|Custom Hex---->", "Do Not Fill (Faster)")
GUICtrlSetTip(-1, "" _
		 & "Do Not Fill: Faster Create File on NTFS using NUL Char" & @CRLF _
		 & "Random Hex Type-1: First Random Char Considered Then Every Files Will Filled With This Char." & @CRLF _
		 & "Random Hex Type-2: Different Random Char Considered According To File Index Then Every Files Will Has Different Char Respectively." & @CRLF _
		 & "Random Hex Type-3: Fill Every File(s) With Random Data." & @CRLF _
		 & "Custom Hex: Fill Every File(s) With Custom Hex (ex 0x41, 0x22 etc.)", "Filling Charactor/Data(Optional)", 1)
Local $idInput_Filling_Char = GUICtrlCreateInput("", 223, 132, 36, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_UPPERCASE))
GUICtrlSetTip(-1, "" _
		 & "Represent Hexadecimal Pattern Like 0x41, 0xFF Without Trailing 0x." & @CRLF _
		 & "Example: 00, 41, 1C, FF etc." & @CRLF & "If Empty Then 0x00 Will be Filled as Char.", "Filling Pattern(Optional)", 1)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetLimit(-1, 2)
#endregion Read Filling Char

#region Read No of File To Create
Local $idLabel_No_Of_Files = GUICtrlCreateLabel("No of Files:", 15, 165, 57, 17)
Local $idInput_No_Of_Files = GUICtrlCreateInput("1", 85, 162, 46, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT, $ES_NUMBER))
GUICtrlSetData(-1, 1)
GUICtrlSetTip(-1, "No of Files To Create", "Specify File(s)(Required)", 1)
Local $idButton_UP_DOWN_2 = GUICtrlCreateUpdown($idInput_No_Of_Files)
Local $idButton_No_of_Files = GUICtrlCreateButton("6", 140, 161, 30, 23)
GUICtrlSetFont(-1, 10, 400, 0, "Webdings")
#endregion Read No of File To Create

#region Read %Increment
Local $idLabel_Increment = GUICtrlCreateLabel("Increment:", 15, 195, 68, 17)
Local $idButton_Sign_Increment = GUICtrlCreateButton("+", 85, 191, 30, 23)
GUICtrlSetTip(-1, "Increment(+) Or Decrement(-) Operation", "Operation", 1)
Local $idInput_Size_Increment = GUICtrlCreateInput("0", 120, 192, 82, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT, $ES_NUMBER))
GUICtrlSetTip(-1, "Enter amount of Percentage or Bytes,KB,MB,GB" & @CRLF & "To Increment or Decrement Size of Files When It Created", "Incremental Amount(Optional)", 1)
Local $idButton_UP_DOWN_Increment = GUICtrlCreateUpdown($idInput_Size_Increment)

Local $idCombo_Size_Increment = GUICtrlCreateCombo("", 208, 192, 51, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "%|Bytes|KB|MB|GB", "%")
#endregion Read %Increment

#region Read File Attributes
Local $idLabel_Attribute = GUICtrlCreateLabel("Add Attribute:", 15, 225, 68, 17)
Local $idCheckbox_Attributes_Readonly = GUICtrlCreateCheckbox("R", 85, 221, 25, 23, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE))
GUICtrlSetTip(-1, "READONLY", "Tip", 1)
Local $idCheckbox_Attributes_Archive = GUICtrlCreateCheckbox("A", 115, 221, 25, 23, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE))
GUICtrlSetTip(-1, "ARCHIVE", "Tip", 1)
Local $idCheckbox_Attributes_System = GUICtrlCreateCheckbox("S", 145, 221, 25, 23, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE))
GUICtrlSetTip(-1, "SYSTEM", "Tip", 1)
Local $idCheckbox_Attributes_Hidden = GUICtrlCreateCheckbox("H", 175, 221, 25, 23, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE))
GUICtrlSetTip(-1, "HIDDEN", "Tip", 1)
Local $idCheckbox_Attributes_Offline = GUICtrlCreateCheckbox("O", 205, 221, 25, 23, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE))
GUICtrlSetTip(-1, "OFFLINE", "Tip", 1)
Local $idCheckbox_Attributes_TEMPORARY = GUICtrlCreateCheckbox("T", 235, 221, 25, 23, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE))
GUICtrlSetTip(-1, "TEMPORARY", "Tip", 1)
#endregion Read File Attributes

#region Read File Date
Local $idLabel_Timestamp = GUICtrlCreateLabel("Timestamp:", 15, 255, 58, 17)
Local $idInput_Date = GUICtrlCreateDate("", 85, 252, 141, 21)
Local $h_Input_Date = GUICtrlGetHandle($idInput_Date)
GUICtrlSetTip(-1, "yyyy.mm.dd HH:mm:ss", "Time Format", 1)
Local $idButton_Time_Stamp = GUICtrlCreateButton("6", 230, 251, 30, 23)
GUICtrlSetFont(-1, 10, 400, 0, "Webdings")
_GUICtrlDTP_SetFormat($h_Input_Date, "yyyy.MM.dd HH:mm:ss")
Local $tDate = _GetCurrentSystemTime()
#endregion Read File Date

#region Read File Name and Extension
Local $idLabel_Filename = GUICtrlCreateLabel("Filename:", 15, 285, 49, 17)
Local $idInput_File_Name = GUICtrlCreateInput("", 85, 282, 81, 21)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, True, "File Name")
GUICtrlSetTip(-1, "Enter File Name", "File Name(Optional)", 1)
Local $idInput_Extension = GUICtrlCreateInput("", 170, 282, 56, 21)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, True, ".extension")
GUICtrlSetTip(-1, "Enter File Extension Starting With .(dot)", "Extension(Optional)", 1)
Local $idButton_Extension = GUICtrlCreateButton("6", 230, 281, 30, 23)
GUICtrlSetFont(-1, 10, 400, 0, "Webdings")

#endregion Read File Name and Extension

GUICtrlCreateGroup("", -99, -99, 1, 1)

#region Info Label and Progress
Local $idButton_Create_File = GUICtrlCreateButton("Create", 5, 312, 75, 25)
GUICtrlSetState(-1, $GUI_DISABLE)

Local $idProgress = GUICtrlCreateProgress(85, 312, 190, 12)
GUICtrlSetState(-1, $GUI_HIDE)

Local $idProgress_child = GUICtrlCreateProgress(85, 325, 190, 12)
GUICtrlSetState(-1, $GUI_HIDE)

Local $idLabel_Info = GUICtrlCreateLabel("Info:Ready", 5, 342, 227, 17)

Local $idLabel_About = GUICtrlCreateLabel("About", 240, 342, 32, 17)
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetCursor(-1, 3)

#endregion Info Label and Progress

#region Contex Menu
#region File Size Contex Menu
Local $hBtnArrowContext0 = GUICtrlCreateContextMenu($idButton_Menu_Size)
Local $MenuItem0 = GUICtrlCreateMenuItem("Clear", $hBtnArrowContext0)
GUICtrlCreateMenuItem("", $hBtnArrowContext0)
Local $MenuItem1 = GUICtrlCreateMenuItem("10 KB", $hBtnArrowContext0)
Local $MenuItem2 = GUICtrlCreateMenuItem("100 KB", $hBtnArrowContext0)
Local $MenuItem3 = GUICtrlCreateMenuItem("1 MB", $hBtnArrowContext0)
Local $MenuItem4 = GUICtrlCreateMenuItem("10 MB", $hBtnArrowContext0)
Local $MenuItem5 = GUICtrlCreateMenuItem("25 MB", $hBtnArrowContext0)
Local $MenuItem6 = GUICtrlCreateMenuItem("50 MB", $hBtnArrowContext0)
Local $MenuItem7 = GUICtrlCreateMenuItem("100 MB", $hBtnArrowContext0)
Local $MenuItem8 = GUICtrlCreateMenuItem("200 MB", $hBtnArrowContext0)
Local $MenuItem9 = GUICtrlCreateMenuItem("400 MB", $hBtnArrowContext0)
Local $MenuItem10 = GUICtrlCreateMenuItem("500 MB", $hBtnArrowContext0)
Local $MenuItem11 = GUICtrlCreateMenuItem("750 MB", $hBtnArrowContext0)
Local $MenuItem12 = GUICtrlCreateMenuItem("1 GB", $hBtnArrowContext0)
Local $MenuItem13 = GUICtrlCreateMenuItem("2 GB", $hBtnArrowContext0)
Local $MenuItem14 = GUICtrlCreateMenuItem("5 GB", $hBtnArrowContext0)
Local $MenuItem15 = GUICtrlCreateMenuItem("10 GB", $hBtnArrowContext0)
Local $MenuItem16 = GUICtrlCreateMenuItem("30 GB", $hBtnArrowContext0)
Local $MenuItem17 = GUICtrlCreateMenuItem("50 GB", $hBtnArrowContext0)
#endregion File Size Contex Menu

#region No of Files Contex Menu
Local $hBtnArrowContext1 = GUICtrlCreateContextMenu($idButton_No_of_Files)
Local $MenuItem30 = GUICtrlCreateMenuItem("Clear", $hBtnArrowContext1)
GUICtrlCreateMenuItem("", $hBtnArrowContext1)
Local $MenuItem31 = GUICtrlCreateMenuItem("1 File", $hBtnArrowContext1)
Local $MenuItem32 = GUICtrlCreateMenuItem("2 Files", $hBtnArrowContext1)
Local $MenuItem33 = GUICtrlCreateMenuItem("3 Files", $hBtnArrowContext1)
Local $MenuItem34 = GUICtrlCreateMenuItem("4 Files", $hBtnArrowContext1)
Local $MenuItem35 = GUICtrlCreateMenuItem("5 Files", $hBtnArrowContext1)
Local $MenuItem36 = GUICtrlCreateMenuItem("6 Files", $hBtnArrowContext1)
Local $MenuItem37 = GUICtrlCreateMenuItem("7 Files", $hBtnArrowContext1)
Local $MenuItem38 = GUICtrlCreateMenuItem("8 Files", $hBtnArrowContext1)
Local $MenuItem39 = GUICtrlCreateMenuItem("9 Files", $hBtnArrowContext1)
Local $MenuItem40 = GUICtrlCreateMenuItem("10 Files", $hBtnArrowContext1)
Local $MenuItem41 = GUICtrlCreateMenuItem("20 Files", $hBtnArrowContext1)
Local $MenuItem42 = GUICtrlCreateMenuItem("30 Files", $hBtnArrowContext1)
Local $MenuItem43 = GUICtrlCreateMenuItem("40 Files", $hBtnArrowContext1)
Local $MenuItem44 = GUICtrlCreateMenuItem("50 Files", $hBtnArrowContext1)
Local $MenuItem45 = GUICtrlCreateMenuItem("60 Files", $hBtnArrowContext1)
Local $MenuItem46 = GUICtrlCreateMenuItem("70 Files", $hBtnArrowContext1)
Local $MenuItem47 = GUICtrlCreateMenuItem("80 Files", $hBtnArrowContext1)
Local $MenuItem48 = GUICtrlCreateMenuItem("90 Files", $hBtnArrowContext1)
Local $MenuItem49 = GUICtrlCreateMenuItem("100 Files", $hBtnArrowContext1)
Local $MenuItem50 = GUICtrlCreateMenuItem("1000 Files", $hBtnArrowContext1)
#endregion No of Files Contex Menu

#region File Attribute Contex Menu
Local $hBtnArrowContext2 = GUICtrlCreateContextMenu($idButton_Time_Stamp)
Local $MenuItem60 = GUICtrlCreateMenuItem("Set All To File Creation", $hBtnArrowContext2,-1,1)
GUICtrlSetState(-1, $GUI_CHECKED)
Local $MenuItem62 = GUICtrlCreateMenuItem("Set Manually", $hBtnArrowContext2,-1,1)



;~ GUICtrlCreateMenuItem("", $idButton_Time_Stamp)
;~ Local $MenuItem63 = GUICtrlCreateMenu("Custom", $hBtnArrowContext2)

;~ Local $MenuItem62_0 = GUICtrlCreateMenu("Modified Time", $MenuItem63)
;~ Local $MenuItem62_0_3 = GUICtrlCreateMenuItem("Set Manually", $MenuItem62_0)
;~ Local $MenuItem62_0_2 = GUICtrlCreateMenuItem("Set To File Creation", $MenuItem62_0)


;~ Local $MenuItem62_1 = GUICtrlCreateMenu("Created Time", $MenuItem63)
;~ Local $MenuItem62_1_3 = GUICtrlCreateMenuItem("Set Manually", $MenuItem62_1)
;~ Local $MenuItem62_1_2 = GUICtrlCreateMenuItem("Set To File Creation", $MenuItem62_1)


;~ Local $MenuItem62_2 = GUICtrlCreateMenu("Accessed Time", $MenuItem63)
;~ Local $MenuItem62_2_3 = GUICtrlCreateMenuItem("Set Manually", $MenuItem62_2)
;~ Local $MenuItem62_2_2 = GUICtrlCreateMenuItem("Set To File Creation", $MenuItem62_2)

#endregion File Attribute Contex Menu

#region Choose Dir Contex Menu
Local $hBtnArrowContext3 = GUICtrlCreateContextMenu($idButton_Browse)
Local $MenuItem70 = GUICtrlCreateMenuItem("Current Directory", $hBtnArrowContext3)
Local $MenuItem71 = GUICtrlCreateMenuItem("Choose Directory...", $hBtnArrowContext3)
#endregion Choose Dir Contex Menu

#region Extension Contex Menu
Local $hBtnArrowContext4 = GUICtrlCreateContextMenu($idButton_Extension)
Local $MenuItem80 = GUICtrlCreateMenuItem("Clear", $hBtnArrowContext4)
GUICtrlCreateMenuItem("", $hBtnArrowContext4)
Local $MenuItem81 = GUICtrlCreateMenuItem(".txt", $hBtnArrowContext4)
Local $MenuItem82 = GUICtrlCreateMenuItem(".log", $hBtnArrowContext4)
Local $MenuItem83 = GUICtrlCreateMenuItem(".sys", $hBtnArrowContext4)
Local $MenuItem84 = GUICtrlCreateMenuItem(".dmp", $hBtnArrowContext4)
Local $MenuItem85 = GUICtrlCreateMenuItem(".chk", $hBtnArrowContext4)
Local $MenuItem86 = GUICtrlCreateMenuItem(".tmp", $hBtnArrowContext4)
Local $MenuItem87 = GUICtrlCreateMenuItem(".temp", $hBtnArrowContext4)
#endregion Extension Contex Menu
#endregion Contex Menu
GUISetState(@SW_SHOW)
Local $nMsg
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg

		Case $GUI_EVENT_CLOSE
			Exit

		Case $idCombo_Fill_Pattern
			If GUICtrlRead($idCombo_Fill_Pattern) = "Custom Hex---->" Then
				GUICtrlSetState($idInput_Filling_Char, $GUI_ENABLE)
			Else
				GUICtrlSetState($idInput_Filling_Char, $GUI_DISABLE)
			EndIf

		Case $idButton_Sign_Increment
			If GUICtrlRead($idButton_Sign_Increment) = "+" Then
				GUICtrlSetData($idButton_Sign_Increment, "--")
			Else
				GUICtrlSetData($idButton_Sign_Increment, "+")
			EndIf

		Case $idButton_Create_File

			;Folder Path with back\
			Local $s_File = GUICtrlRead($idInput_File)
			Local $s_File_Attribute = _FileGetAttributes() ;Get Attributes

			;Read Date Range from control
			Local $a_Date_Range = _GUICtrlDTP_GetSystemTime($h_Input_Date)

			;Get Date Format
			Local $s_Date_Range = StringFormat("%04d%02d%02d%02d%02d%02d", _
					$a_Date_Range[0], _
					$a_Date_Range[1], _
					$a_Date_Range[2], _
					$a_Date_Range[3], _
					$a_Date_Range[4], _
					$a_Date_Range[5])

			;Read File Size from control and convert into Bytes
			Local $i_File_Size = _Conv_Bytes(Number(GUICtrlRead($idInput_File_Size)), $idCombo_Size)
			Local $s_Pattern_Type = GUICtrlRead($idCombo_Fill_Pattern)
			Local $s_Filling_Char = GUICtrlRead($idInput_Filling_Char)
			Local $i_File_No_of_Files = Number(GUICtrlRead($idInput_No_Of_Files))
			Local $s_File_Name = GUICtrlRead($idInput_File_Name)
			If $s_File_Name = "" Then $s_File_Name = "File"

			Local $s_File_Extension = GUICtrlRead($idInput_Extension)

			If $i_File_Size < 0 Then
				MsgBox(16, "Error", "File Size Can Not Negative: " & $i_File_Size, 0, $idMainWin)
				GUICtrlSetState($idInput_File_Size, $GUI_FOCUS)
				ContinueLoop
			EndIf

			Local $aPatterns
			If $s_Pattern_Type = "Do Not Fill (Faster)" Then
				$aPatterns = -2
			ElseIf $s_Pattern_Type = "Random Hex Type-1" Then
				$aPatterns = Random(0, 255, 1)
			ElseIf $s_Pattern_Type = "Random Hex Type-3" Then
				$aPatterns = -1
			ElseIf $s_Pattern_Type = "Custom Hex---->" Then
				$aPatterns = Dec($s_Filling_Char)
				If @error Then
					MsgBox(16, "Error", "Pattern Must in 0x00 - 0xFF Range", 0, $idMainWin)
					GUICtrlSetState($idInput_Filling_Char, $GUI_FOCUS)
					ContinueLoop
				EndIf
			EndIf

			If $i_File_No_of_Files <= 0 Then
				MsgBox(16, "Error", "No of File Can Not Zero, Negative or Empty: " & $i_File_No_of_Files, 0, $idMainWin)
				GUICtrlSetState($idInput_No_Of_Files, $GUI_FOCUS)
				ContinueLoop
			EndIf

			Local $iFile_Size_Increment = Number(GUICtrlRead($idInput_Size_Increment))
			If $iFile_Size_Increment > 0 Then
				If GUICtrlRead($idCombo_Size_Increment) = "%" Then
					$iFile_Size_Increment = Floor(_Conv_Bytes(($i_File_Size * ($iFile_Size_Increment / 100)), $idCombo_Size_Increment))
				Else
					$iFile_Size_Increment = _Conv_Bytes($iFile_Size_Increment, $idCombo_Size_Increment)
				EndIf

				If GUICtrlRead($idButton_Sign_Increment) = "--" Then $iFile_Size_Increment *= -1

				If $iFile_Size_Increment = 0 Then
					MsgBox(16, "Error", "Percentage Convergence Reached To Zero. Please Increase File Size or Percentage.", 0, $idMainWin)
					GUICtrlSetState($idInput_Size_Increment, $GUI_FOCUS)
					ContinueLoop
				EndIf
			ElseIf $iFile_Size_Increment < 0 Then
				MsgBox(48, "Error", "Incremental File Size or Percentage Can not Negative. Please Use Increment/Decrement Button To Change (+ or -)Sign.", 0, $idMainWin)
				GUICtrlSetState($idButton_Sign_Increment, $GUI_FOCUS)
				ContinueLoop
			EndIf

			;Calculate Total No of Max File(s) To be Created
			For $i = 1 To $i_File_No_of_Files
				If ($i - 1) * $iFile_Size_Increment + $i_File_Size < 0 Then ExitLoop
			Next

			If ($i - 1) < $i_File_No_of_Files Then
				MsgBox(48, "Error", "File Size Reached To Negative at :" & $i & @CRLF & "Please Set to No of File To: " & $i - 1, 0, $idMainWin)
				GUICtrlSetState($idInput_Size_Increment, $GUI_FOCUS)
				ContinueLoop
			EndIf

			;Calculate Total Amount of Data To be Created in Bytes <--
			Local $iTotalFilesSize = $i_File_Size * $i_File_No_of_Files + $iFile_Size_Increment * $i_File_No_of_Files * ($i_File_No_of_Files - 1) / 2

			;Calculate Drive Free Space in Bytes <--
			Local $iDriveFreeSpace = DriveSpaceFree(_sGetDrive($s_File)) * 1024 * 1024

			;Calculate Required File Size
			Local $iRequiredFilesSize = $iDriveFreeSpace - $iTotalFilesSize

			;Check For Drive Space
			If $iRequiredFilesSize < 0 Then
				$iRequiredFilesSize *= -1
				MsgBox(16, "Error", "Not Enought Free Space on Drive " & _sGetDrive($s_File) & " Free Space:" & _File_Size($iDriveFreeSpace) & ". At Least " & _File_Size($iRequiredFilesSize) & " Required.", 0, $idMainWin)
				ContinueLoop
			EndIf

			If Not _IsFileNameValid($s_File_Name) Then
				MsgBox(16, "Error", "Invalid File Name: " & "\/:*?" & '"' & "<>|", 0, $idMainWin)
				GUICtrlSetState($idInput_File_Name, $GUI_FOCUS)
				ContinueLoop
			EndIf

			If Not _IsFileNameValid($s_File_Extension) Then
				MsgBox(16, "Error", "Invalid File Extension: " & "\/:*?" & '"' & "<>|", 0, $idMainWin)
				GUICtrlSetState($idInput_Extension, $GUI_FOCUS)
				ContinueLoop
			EndIf

			;Check For Dot "." In File Extension
			If $s_File_Extension <> "" And StringLeft($s_File_Extension, 1) <> "." Then $s_File_Extension = _StringInsert($s_File_Extension, ".", -StringLen($s_File_Extension))

			_Disable_Controls() ;disable all gui controls
			GUICtrlSetState($idProgress, $GUI_show)
			GUICtrlSetState($idProgress_child, $GUI_show)

			;Remove All File if Exists
			Local $s_File_Child
			Local $s_File_Locked = ""
			For $i = 1 To $i_File_No_of_Files

				$s_File_Child = $s_File & $s_File_Name & "_" & $i & $s_File_Extension

				If FileExists($s_File_Child) Then
					GUICtrlSetData($idLabel_Info, StringFormat("Removing File: %d", $i))
					GUICtrlSetData($idProgress, $i * 100 / $i_File_No_of_Files)
					FileSetAttrib($s_File_Child, "-R+A")
					If FileDelete($s_File_Child) = 0 Then $s_File_Locked &= $s_File_Child & @CRLF
				EndIf
			Next
			GUICtrlSetData($idProgress, 0)

			If $s_File_Locked <> "" Then MsgBox(16, "Error", "Some File(s) Could Not Deleted: " & @CRLF & $s_File_Locked & @CRLF & "Skipped...", 0, $idMainWin)

;~ 			GUICtrlSetData($idLabel_Info, "Filling Buffer...")

			Local $iTimeDiff = 0
			Local $iIntialTime = TimerInit()

			For $i = 1 To $i_File_No_of_Files
				GUICtrlSetData($idLabel_Info, StringFormat("Creating File: %d", $i))

				$s_File_Child = $s_File & $s_File_Name & "_" & $i & $s_File_Extension
				If $s_Pattern_Type = "Random Hex Type-2" Then $aPatterns = Random(0, 255, 1) ;every time random pattern

				;Call Func ===================================>
				_Create_File($s_File_Child, $i_File_Size, $aPatterns)
				If @error Then
					Switch _Error_Msg(@error)
						Case 3 ;Abort
							ExitLoop
						Case 4 ;Retry
							$i -= 1
							ContinueLoop
						Case 5 ;Ignore

					EndSwitch
				EndIf
				$i_File_Size += $iFile_Size_Increment

				GUICtrlSetData($idProgress, $i * 100 / $i_File_No_of_Files)
			Next

			$iTimeDiff = TimerDiff($iIntialTime)

			For $i = 1 To $i_File_No_of_Files
				GUICtrlSetData($idLabel_Info, StringFormat("Setting File Attributes and Time: %d", $i))
				GUICtrlSetData($idProgress, $i * 100 / $i_File_No_of_Files)

				$s_File_Child = $s_File & $s_File_Name & "_" & $i & $s_File_Extension
				FileSetAttrib($s_File_Child, "-RASHOT")
				If $s_File_Attribute <> "+" Then FileSetAttrib($s_File_Child, $s_File_Attribute)

				If BitAND(GUICtrlRead($MenuItem60), $GUI_UNCHECKED) Then
					FileSetTime($s_File_Child, $s_Date_Range, 0)
					FileSetTime($s_File_Child, $s_Date_Range, 1)
					FileSetTime($s_File_Child, $s_Date_Range, 2)
				EndIf
			Next

			Local $dSpeed = _Time_Xsec($iTimeDiff)
			Local $dTime = _Speed_Xbps($iTotalFilesSize, $iTimeDiff / 1000)
			Local $dFiles = _Files_Xfps($i_File_No_of_Files, $iTimeDiff / 1000)
			GUICtrlSetData($idLabel_Info, "Info:Created in " & $dSpeed & " Speed:" & $dTime)
			GUICtrlSetTip($idLabel_Info, "" & _
					"Created in:" & $dSpeed & @CRLF & _
					"Write Speed:" & $dTime & @CRLF & _
					"File Creation Speed:" & $dFiles, "Speed")

			GUICtrlSetData($idProgress, 0)
			GUICtrlSetData($idProgress_child, 0)
			GUICtrlSetState($idProgress, $GUI_HIDE)
			GUICtrlSetState($idProgress_child, $GUI_HIDE)
			ShellExecute($s_File)
			_Enable_Controls()

		Case $idLabel_About
			_SwAboutDiloag()

		Case $idButton_Menu_Size
			_ShowMenu($idMainWin, $nMsg, $hBtnArrowContext0)

		Case $idButton_No_of_Files
			_ShowMenu($idMainWin, $nMsg, $hBtnArrowContext1)

		Case $idButton_Time_Stamp
			_ShowMenu($idMainWin, $nMsg, $hBtnArrowContext2)

		Case $idButton_Browse
			_ShowMenu($idMainWin, $nMsg, $hBtnArrowContext3)

		Case $idButton_Extension
			_ShowMenu($idMainWin, $nMsg, $hBtnArrowContext4)

		Case $MenuItem0
			GUICtrlSetData($idInput_File_Size, "")
			GUICtrlSetData($idCombo_Size, "Bytes")
		Case $MenuItem1
			GUICtrlSetData($idInput_File_Size, 10)
			GUICtrlSetData($idCombo_Size, "KB")
		Case $MenuItem2
			GUICtrlSetData($idInput_File_Size, 100)
			GUICtrlSetData($idCombo_Size, "KB")
		Case $MenuItem3
			GUICtrlSetData($idInput_File_Size, 1)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem4
			GUICtrlSetData($idInput_File_Size, 10)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem5
			GUICtrlSetData($idInput_File_Size, 25)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem6
			GUICtrlSetData($idInput_File_Size, 50)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem7
			GUICtrlSetData($idInput_File_Size, 100)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem8
			GUICtrlSetData($idInput_File_Size, 200)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem9
			GUICtrlSetData($idInput_File_Size, 400)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem10
			GUICtrlSetData($idInput_File_Size, 500)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem11
			GUICtrlSetData($idInput_File_Size, 750)
			GUICtrlSetData($idCombo_Size, "MB")
		Case $MenuItem12
			GUICtrlSetData($idInput_File_Size, 1)
			GUICtrlSetData($idCombo_Size, "GB")
		Case $MenuItem13
			GUICtrlSetData($idInput_File_Size, 2)
			GUICtrlSetData($idCombo_Size, "GB")
		Case $MenuItem14
			GUICtrlSetData($idInput_File_Size, 5)
			GUICtrlSetData($idCombo_Size, "GB")
		Case $MenuItem15
			GUICtrlSetData($idInput_File_Size, 10)
			GUICtrlSetData($idCombo_Size, "GB")
		Case $MenuItem16
			GUICtrlSetData($idInput_File_Size, 30)
			GUICtrlSetData($idCombo_Size, "GB")
		Case $MenuItem17
			GUICtrlSetData($idInput_File_Size, 50)
			GUICtrlSetData($idCombo_Size, "GB")

		Case $MenuItem30
			GUICtrlSetData($idInput_No_Of_Files, "")
		Case $MenuItem31
			GUICtrlSetData($idInput_No_Of_Files, 1)
		Case $MenuItem32
			GUICtrlSetData($idInput_No_Of_Files, 2)
		Case $MenuItem33
			GUICtrlSetData($idInput_No_Of_Files, 3)
		Case $MenuItem34
			GUICtrlSetData($idInput_No_Of_Files, 4)
		Case $MenuItem35
			GUICtrlSetData($idInput_No_Of_Files, 5)
		Case $MenuItem36
			GUICtrlSetData($idInput_No_Of_Files, 6)
		Case $MenuItem37
			GUICtrlSetData($idInput_No_Of_Files, 7)
		Case $MenuItem38
			GUICtrlSetData($idInput_No_Of_Files, 8)
		Case $MenuItem39
			GUICtrlSetData($idInput_No_Of_Files, 9)
		Case $MenuItem40
			GUICtrlSetData($idInput_No_Of_Files, 10)
		Case $MenuItem41
			GUICtrlSetData($idInput_No_Of_Files, 20)
		Case $MenuItem42
			GUICtrlSetData($idInput_No_Of_Files, 30)
		Case $MenuItem43
			GUICtrlSetData($idInput_No_Of_Files, 40)
		Case $MenuItem44
			GUICtrlSetData($idInput_No_Of_Files, 50)
		Case $MenuItem45
			GUICtrlSetData($idInput_No_Of_Files, 60)
		Case $MenuItem46
			GUICtrlSetData($idInput_No_Of_Files, 70)
		Case $MenuItem47
			GUICtrlSetData($idInput_No_Of_Files, 80)
		Case $MenuItem48
			GUICtrlSetData($idInput_No_Of_Files, 90)
		Case $MenuItem49
			GUICtrlSetData($idInput_No_Of_Files, 100)
		Case $MenuItem50
			GUICtrlSetData($idInput_No_Of_Files, 1000)

		Case $MenuItem70
			GUICtrlSetData($idInput_File, @ScriptDir)
			GUICtrlSetState($idButton_Create_File, $GUI_ENABLE)

		Case $MenuItem71
			Local $file = FileSelectFolder("Choose a folder to save file(s)...", "", 7, GUICtrlRead($idInput_File), $idMainWin)
			If StringRight($file, 1) <> "\" Then $file &= "\"

			If _FileIsPathValid($file) Then
				GUICtrlSetState($idButton_Create_File, $GUI_ENABLE)
				GUICtrlSetData($idInput_File, $file)
			Else
				If $file <> "\" Then
					If _FileIsPathValid(GUICtrlRead($idInput_File)) Then
						GUICtrlSetState($idButton_Create_File, $GUI_ENABLE)
					Else
						GUICtrlSetState($idButton_Create_File, $GUI_DISABLE)
					EndIf
					MsgBox(48, "Error", '"' & $file & '"' & " is not Valid Folder", 0, $idMainWin)
				Else
					If _FileIsPathValid(GUICtrlRead($idInput_File)) Then
						GUICtrlSetState($idButton_Create_File, $GUI_ENABLE)
					Else
						GUICtrlSetState($idButton_Create_File, $GUI_DISABLE)
					EndIf
				EndIf
			EndIf

;~ 		Case $MenuItem60;Use Windows Default File Creation Time
;~ 			If BitAND(GUICtrlRead($MenuItem60), $GUI_CHECKED) Then
;~ 				GUICtrlSetState($MenuItem60, $GUI_UNCHECKED)
;~ 				GUICtrlSetState($MenuItem66, $GUI_CHECKED)
;~ 			Else
;~ 				GUICtrlSetState($MenuItem60, $GUI_CHECKED)
;~ 				GUICtrlSetState($MenuItem66, $GUI_UNCHECKED)
;~ 			EndIf

;~ 		Case $MenuItem61;Set Current Time To Control

;~ 		Case $MenuItem62;Set Current Time To All
;~ 			If BitAND(GUICtrlRead($MenuItem66), $GUI_CHECKED) Then
;~ 				GUICtrlSetState($MenuItem66, $GUI_UNCHECKED)
;~ 			Else
;~ 				GUICtrlSetState($MenuItem60, $GUI_UNCHECKED)
;~ 			EndIf

;~ 		Case $MenuItem63;Created
;~ 			If BitAND(GUICtrlRead($MenuItem66), $GUI_CHECKED) Then
;~ 				GUICtrlSetState($MenuItem66, $GUI_UNCHECKED)
;~ 			Else
;~ 				GUICtrlSetState($MenuItem60, $GUI_UNCHECKED)
;~ 			EndIf

;~ 		Case $MenuItem64;Modified
;~ 			If BitAND(GUICtrlRead($MenuItem66), $GUI_CHECKED) Then
;~ 				GUICtrlSetState($MenuItem66, $GUI_UNCHECKED)
;~ 			Else
;~ 				GUICtrlSetState($MenuItem60, $GUI_UNCHECKED)
;~ 			EndIf

;~ 		Case $MenuItem65;Accessed
;~ 			If BitAND(GUICtrlRead($MenuItem66), $GUI_CHECKED) Then
;~ 				GUICtrlSetState($MenuItem66, $GUI_UNCHECKED)
;~ 			Else
;~ 				GUICtrlSetState($MenuItem60, $GUI_UNCHECKED)
;~ 			EndIf

;~ 		Case $MenuItem66;Choose Time From File...
;~ 			If BitAND(GUICtrlRead($MenuItem66), $GUI_CHECKED) Then
;~ 				GUICtrlSetState($MenuItem66, $GUI_UNCHECKED)
;~ 				GUICtrlSetState($MenuItem60, $GUI_CHECKED)
;~ 			Else
;~ 				GUICtrlSetState($MenuItem66, $GUI_CHECKED)
;~ 				GUICtrlSetState($MenuItem60, $GUI_UNCHECKED)
;~ 			EndIf

		Case $MenuItem80
			GUICtrlSetData($idInput_Extension, "")
		Case $MenuItem81
			GUICtrlSetData($idInput_Extension, ".txt")
		Case $MenuItem82
			GUICtrlSetData($idInput_Extension, ".log")
		Case $MenuItem83
			GUICtrlSetData($idInput_Extension, ".sys")
		Case $MenuItem84
			GUICtrlSetData($idInput_Extension, ".dmp")
		Case $MenuItem85
			GUICtrlSetData($idInput_Extension, ".chk")
		Case $MenuItem86
			GUICtrlSetData($idInput_Extension, ".tmp")
		Case $MenuItem87
			GUICtrlSetData($idInput_Extension, ".temp")
	EndSwitch
WEnd

Func _Create_File($sFile, $iSize, $aPatterns)
	_Create_Blanck_File($sFile, $iSize);<---------------------    Not used in usb drive
	If @error Then Return SetError(@error)

	If $aPatterns <> "-2" Then ; Fill Pattern
		_Write_Data($sFile, $iSize, $aPatterns)
	EndIf
EndFunc   ;==>_Create_File

Func _Write_Data($sFile, $iSize, $aPatterns)
	Local $hFile, $iWriteSize, $iErr = 0

	; create buffers
	_CreateBuffers($aPatterns)
	If @error Then Return SetError(@error)

	$hFile = _FileEx_CreateFile($sFile, $GENERIC_WRITE, BitOR($FILE_SHARE_READ, $FILE_SHARE_WRITE), $OPEN_EXISTING, 0x90000000)

	If $iSize > $__g_iMaxWriteSize Then
		$iWriteSize = $__g_iMaxWriteSize
	Else
		$iWriteSize = 1024 * 64 ;bytes
	EndIf

	_WritePattern($hFile, $iSize, $iWriteSize, $aPatterns)
	If @error Then $iErr = 1
	;
	_WinAPI_CloseHandle($hFile)
	;
	If $iErr Then Return SetError(@error);Error generated by _WritePattern Function
EndFunc   ;==>_Write_Data

Func _Create_Blanck_File($sFilePath, $iSizeByte)
	Local $hFileOpen = FileOpen($sFilePath, 18)
	If $hFileOpen = -1 Then
		Return SetError(1)
	EndIf
	FileSetPos($hFileOpen, $iSizeByte - 1, 0)
	If $iSizeByte > 0 Then FileWrite($hFileOpen, Chr(0))
	Return FileClose($hFileOpen)
EndFunc   ;==>_Create_Blanck_File

Func _CreateBuffers(Const ByRef $aBuff)
	Local $pBuff
	_FreeBuffers()
	; create crypt context
	$__g_hCryptContext[1] = DllOpen("advapi32.dll")
	Local $context = DllCall($__g_hCryptContext[1], "bool", "CryptAcquireContext", "handle*", 0, "ptr", 0, "ptr", 0, "dword", 24, "dword", 0xF0000000)
	If @error Or (Not $context[0]) Then
		DllClose($__g_hCryptContext[1])
		$__g_hCryptContext[1] = 0
		Return SetError(2)
	EndIf
	$__g_hCryptContext[0] = $context[1]
	Dim $__g_apBuffers[1] = [0]
	$pBuff = _MemVirtualAlloc(0, $__g_iMaxWriteSize, $MEM_COMMIT, $PAGE_READWRITE)
	If Not $pBuff Then
		_FreeBuffers()
		Return SetError(3)
	EndIf
	; -1 is special value to indicate stream of random data
	If $aBuff > -1 Then
		; fill buffer with pattern
		DllCall("kernel32.dll", "none", "RtlFillMemory", "ptr", $pBuff, "ulong_ptr", $__g_iMaxWriteSize, "byte", $aBuff)
	EndIf
	$__g_apBuffers[0] += 1
	ReDim $__g_apBuffers[$__g_apBuffers[0] + 1]
	$__g_apBuffers[$__g_apBuffers[0]] = $pBuff
EndFunc   ;==>_CreateBuffers

Func _WritePattern($hFile, $iSize, $iBuffSize, Const ByRef $aPatterns)

	If $iBuffSize > $__g_iMaxWriteSize Then $iBuffSize = $__g_iMaxWriteSize

	Local $bytesToWrite = $iBuffSize ; get number of write operations
	Local $iBytes
	Local $bytesWritten = 0
	Local $i_CurrentPercent = 0

	; Write file
	While $bytesWritten < $iSize
		If $bytesToWrite > ($iSize - $bytesWritten) Then $bytesToWrite = $iSize - $bytesWritten
		; overwrite each bytesToWrite size section with each pattern
		For $i = 1 To $__g_apBuffers[0] ; # of overwrites
			If $i > 1 Then
				; reset file pointer to beginning of the overwrite segment on successive passes
				DllCall("kernel32.dll", "bool", "SetFilePointerEx", "handle", $hFile, "int64", -$bytesToWrite, "ptr", 0, "dword", 1)
			EndIf
			; check for pseudo-random pass and fill buffer, special pattern of -1
			; NOTE: $aPatterns is a 0-based array, while $__g_apBuffers is 1-based with a [0] counter
			If $aPatterns = -1 Then _FillBufferRandom($__g_apBuffers[$i], $bytesToWrite)
			; write the data
			If (Not _WinAPI_WriteFile($hFile, $__g_apBuffers[$i], $bytesToWrite, $iBytes)) Or ($bytesToWrite <> $iBytes) Then
				Return SetError(4)
			EndIf
		Next
		; next file section
		$bytesWritten += $bytesToWrite

		$i_CurrentPercent = Round(($bytesWritten * 100 / $iSize), 0)
		GUICtrlSetData($idProgress_child, $i_CurrentPercent)
	WEnd
EndFunc   ;==>_WritePattern

Func _FillBufferRandom($pBuff, $iSize)
	; fill buffer with random data
	Local $ret = DllCall($__g_hCryptContext[1], "bool", "CryptGenRandom", "handle", $__g_hCryptContext[0], "dword", $iSize, "ptr", $pBuff)
	If @error Or (Not $ret[0]) Then
		Return SetError(5)
	Else
		Return 1
	EndIf
EndFunc   ;==>_FillBufferRandom

Func _FreeBuffers()
	If IsArray($__g_apBuffers) Then
		For $i = 1 To $__g_apBuffers[0]
			_MemVirtualFree($__g_apBuffers[$i], 0, $MEM_RELEASE)
		Next
	EndIf
	$__g_apBuffers = 0
	; release crypt context
	If $__g_hCryptContext[0] Then DllCall($__g_hCryptContext[1], "bool", "CryptReleaseContext", "handle", $__g_hCryptContext[0], "dword", 0)
	If $__g_hCryptContext[1] Then DllClose($__g_hCryptContext[1])
	$__g_hCryptContext[0] = 0
	$__g_hCryptContext[1] = 0
EndFunc   ;==>_FreeBuffers

Func _Error_Msg($error)
	Local $iCommand = 0
	Switch $error
		Case 1
			$iCommand = MsgBox(18, "Error", "File(s) Could Not Created. There Serval Reason:" & @CRLF & _
					"1. Unable to Open File. It May Be Locked By Other Application." & @CRLF & _
					"2. You Don't Have Permission to Save In This Location aka Admin Rights Required.", 0, $idMainWin)
		Case 2
			$iCommand = MsgBox(18, "Error", "Could not Create crypt context", 0, $idMainWin)
		Case 3
			$iCommand = MsgBox(18, "Error", "Error while Allocating memory", 0, $idMainWin)
		Case 4
			$iCommand = MsgBox(18, "Error", "Error while Writting data.", 0, $idMainWin)
		Case 5
			$iCommand = MsgBox(18, "Error", "Error While creating buffer.", 0, $idMainWin)
	EndSwitch
	Return $iCommand
EndFunc   ;==>_Error_Msg

Func _Disable_Controls()
	GUICtrlSetState($idMainWin, $GUI_DISABLE)
	GUICtrlSetState($idInput_File, $GUI_DISABLE)
	GUICtrlSetState($idButton_Browse, $GUI_DISABLE)
	GUICtrlSetState($idLabel_File_Size, $GUI_DISABLE)
	GUICtrlSetState($idInput_File_Size, $GUI_DISABLE)
	GUICtrlSetState($idCombo_Size, $GUI_DISABLE)
	GUICtrlSetState($idLabel_Filling_Bytes, $GUI_DISABLE)
	GUICtrlSetState($idCombo_Fill_Pattern, $GUI_DISABLE)
	GUICtrlSetState($idInput_Filling_Char, $GUI_DISABLE)
	GUICtrlSetState($idButton_Menu_Size, $GUI_DISABLE)
	GUICtrlSetState($idLabel_Filling_Bytes, $GUI_DISABLE)
	GUICtrlSetState($idCombo_Fill_Pattern, $GUI_DISABLE)
	GUICtrlSetState($idInput_Filling_Char, $GUI_DISABLE)
	GUICtrlSetState($idLabel_No_Of_Files, $GUI_DISABLE)
	GUICtrlSetState($idInput_No_Of_Files, $GUI_DISABLE)
	GUICtrlSetState($idButton_UP_DOWN_2, $GUI_DISABLE)
	GUICtrlSetState($idButton_No_of_Files, $GUI_DISABLE)
	GUICtrlSetState($idLabel_Attribute, $GUI_DISABLE)
	GUICtrlSetState($idLabel_Increment, $GUI_DISABLE)
	GUICtrlSetState($idButton_Sign_Increment, $GUI_DISABLE)
	GUICtrlSetState($idInput_Size_Increment, $GUI_DISABLE)
	GUICtrlSetState($idCombo_Size_Increment, $GUI_DISABLE)
	GUICtrlSetState($idCheckbox_Attributes_Readonly, $GUI_DISABLE)
	GUICtrlSetState($idCheckbox_Attributes_Archive, $GUI_DISABLE)
	GUICtrlSetState($idCheckbox_Attributes_System, $GUI_DISABLE)
	GUICtrlSetState($idCheckbox_Attributes_Hidden, $GUI_DISABLE)
	GUICtrlSetState($idCheckbox_Attributes_Offline, $GUI_DISABLE)
	GUICtrlSetState($idCheckbox_Attributes_TEMPORARY, $GUI_DISABLE)
	GUICtrlSetState($idLabel_Timestamp, $GUI_DISABLE)
	GUICtrlSetState($idInput_Date, $GUI_DISABLE);
	GUICtrlSetState($idButton_Time_Stamp, $GUI_DISABLE)
	GUICtrlSetState($idLabel_Filename, $GUI_DISABLE)
	GUICtrlSetState($idInput_Extension, $GUI_DISABLE)
	GUICtrlSetState($idInput_File_Name, $GUI_DISABLE)
	GUICtrlSetState($idButton_Extension, $GUI_DISABLE)
	GUICtrlSetState($idProgress, $GUI_DISABLE)
	GUICtrlSetState($idButton_Create_File, $GUI_DISABLE)
	GUICtrlSetState($idLabel_About, $GUI_DISABLE)
	GUICtrlSetState($idButton_Create_File, $GUI_DISABLE)
EndFunc   ;==>_Disable_Controls

Func _Enable_Controls()
	GUICtrlSetState($idMainWin, $GUI_ENABLE)
	GUICtrlSetState($idInput_File, $GUI_ENABLE)
	GUICtrlSetState($idButton_Browse, $GUI_ENABLE)
	GUICtrlSetState($idLabel_File_Size, $GUI_ENABLE)
	GUICtrlSetState($idInput_File_Size, $GUI_ENABLE)
	GUICtrlSetState($idCombo_Size, $GUI_ENABLE)
	GUICtrlSetState($idLabel_Filling_Bytes, $GUI_ENABLE)
	GUICtrlSetState($idCombo_Fill_Pattern, $GUI_ENABLE)
	If $s_Pattern_Type = "Custom Hex---->" Then
		GUICtrlSetState($idInput_Filling_Char, $GUI_ENABLE)
	Else
		GUICtrlSetState($idInput_Filling_Char, $GUI_DISABLE)
	EndIf
	GUICtrlSetState($idButton_Menu_Size, $GUI_ENABLE)
	GUICtrlSetState($idLabel_No_Of_Files, $GUI_ENABLE)
	GUICtrlSetState($idInput_No_Of_Files, $GUI_ENABLE)
	GUICtrlSetState($idButton_UP_DOWN_2, $GUI_ENABLE)
	GUICtrlSetState($idButton_No_of_Files, $GUI_ENABLE)
	GUICtrlSetState($idLabel_Attribute, $GUI_ENABLE)
	GUICtrlSetState($idLabel_Increment, $GUI_ENABLE)
	GUICtrlSetState($idButton_Sign_Increment, $GUI_ENABLE)
	GUICtrlSetState($idInput_Size_Increment, $GUI_ENABLE)
	GUICtrlSetState($idCombo_Size_Increment, $GUI_ENABLE)
	GUICtrlSetState($idCheckbox_Attributes_Readonly, $GUI_ENABLE)
	GUICtrlSetState($idCheckbox_Attributes_Archive, $GUI_ENABLE)
	GUICtrlSetState($idCheckbox_Attributes_System, $GUI_ENABLE)
	GUICtrlSetState($idCheckbox_Attributes_Hidden, $GUI_ENABLE)
	GUICtrlSetState($idCheckbox_Attributes_Offline, $GUI_ENABLE)
	GUICtrlSetState($idCheckbox_Attributes_TEMPORARY, $GUI_ENABLE)
	GUICtrlSetState($idLabel_Timestamp, $GUI_ENABLE)
	GUICtrlSetState($idInput_Date, $GUI_ENABLE);
	GUICtrlSetState($idButton_Time_Stamp, $GUI_ENABLE)
	GUICtrlSetState($idLabel_Filename, $GUI_ENABLE)
	GUICtrlSetState($idInput_Extension, $GUI_ENABLE)
	GUICtrlSetState($idInput_File_Name, $GUI_ENABLE)
	GUICtrlSetState($idButton_Extension, $GUI_ENABLE)
	GUICtrlSetState($idProgress, $GUI_ENABLE)
	GUICtrlSetState($idButton_Create_File, $GUI_ENABLE)
	GUICtrlSetState($idLabel_About, $GUI_ENABLE)
	GUICtrlSetState($idButton_Create_File, $GUI_ENABLE)
EndFunc   ;==>_Enable_Controls

Func _FileGetAttributes()
	Local $s_File_Attribute = "+"
	If GUICtrlRead($idCheckbox_Attributes_Readonly) = $GUI_CHECKED Then $s_File_Attribute &= "R"
	If GUICtrlRead($idCheckbox_Attributes_Archive) = $GUI_CHECKED Then $s_File_Attribute &= "A"
	If GUICtrlRead($idCheckbox_Attributes_System) = $GUI_CHECKED Then $s_File_Attribute &= "S"
	If GUICtrlRead($idCheckbox_Attributes_Hidden) = $GUI_CHECKED Then $s_File_Attribute &= "H"
	If GUICtrlRead($idCheckbox_Attributes_Offline) = $GUI_CHECKED Then $s_File_Attribute &= "O"
	If GUICtrlRead($idCheckbox_Attributes_TEMPORARY) = $GUI_CHECKED Then $s_File_Attribute &= "T"
	Return $s_File_Attribute
EndFunc   ;==>_FileGetAttributes

Func _SwAboutDiloag()
	GUISetState(@SW_DISABLE, $idMainWin)

	Local $size = WinGetPos($s_Win_Title)
	Local $Child_About = GUICreate("About", 298, 230, $size[0] + $i_xWidth / 2 - 297 / 2, $size[1] + $i_yHight / 2 - 310 / 2, BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE), $idMainWin)
	GUISetBkColor(0xFFFFFF)
	Local $idPic1 = GUICtrlCreatePic("", 0, 0, 281, 41, 67108864)
	_ResourceSetImageToCtrl($idPic1, "wintop")
	Local $Child_About_GroupBox = GUICtrlCreateGroup("", 3, 3, 285, 192)
	Local $idLabel1 = GUICtrlCreateLabel("About " & $s_Win_Title, 77, 29, 205, 17)
	Local $Child_Copyright = GUICtrlCreateLabel("Copyright (c) 2012-13 Gajjar Tejas", 77, 57, 205, 17)
	Local $Child_Icon = GUICtrlCreateIcon(@ScriptFullPath, -1, 10, 30, 42, 42)
	Local $Child_Label_Email = GUICtrlCreateLabel("Email:", 10, 90, 65, 17)
	Local $Child_Label_Website = GUICtrlCreateLabel("Website:", 10, 110, 65, 17)
	Local $Child_Label_Email_ = GUICtrlCreateLabel("gajjartejas26@gmail.com", 77, 90, 205, 17)
	GUICtrlSetFont(-1, 8, 400, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetCursor(-1, 0)
	Local $Child_Label_Website_ = GUICtrlCreateLabel("http://www.gajjartejas26.blogspot.com", 77, 110, 205, 17)
	GUICtrlSetFont(-1, 8, 400, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetCursor(-1, 0)
	Local $Label2 = GUICtrlCreateLabel("EFIC Stand For Empty File Creator" & @CRLF & "Empty File Creator Is Free(GNU GPL v3) Software", 10, 160, 260, 34)
	Local $Child_Label_Date = GUICtrlCreateLabel("Build Date: ", 10, 130, 65, 17)
	Local $Child_Label_Date_ = GUICtrlCreateLabel($s_Build_Date, 77, 130, 205, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $Contribute = GUICtrlCreateButton("&Project Homepage", 3, 197, 150, 25)
	Local $Child_Ok = GUICtrlCreateButton("&OK", 198, 197, 90, 25)
	GUISetState(@SW_SHOW, $Child_About)
	Local $msg
	While 1
		$msg = GUIGetMsg()
		If $msg = $Child_Ok Or $msg = $GUI_EVENT_CLOSE Then ExitLoop
		If $msg = $Contribute Then ShellExecute("http://code.google.com/p/efic/")
		If $msg = $Child_Label_Email_ Then ShellExecute("mailto:gajjartejas26@gmail.com")
		If $msg = $Child_Label_Website_ Then ShellExecute("http://www.gajjartejas26.blogspot.com/")
	WEnd

	GUISetState(@SW_ENABLE, $idMainWin)
	GUIDelete($Child_About)
EndFunc   ;==>_SwAboutDiloag

Func _sGetDrive($sPath)
	Local $szDrive, $szDir, $szFName, $szExt
	Local $TestPath = _PathSplit($sPath, $szDrive, $szDir, $szFName, $szExt)
	Return $TestPath[1]
EndFunc   ;==>_sGetDrive

; Show dropdown menu on control
Func _ShowMenu($hWnd, $CtrlID, $nContextID)
	Local $arPos, $x, $y
	Local $hMenu = GUICtrlGetHandle($nContextID)

	$arPos = ControlGetPos($hWnd, "", $CtrlID)

	$x = $arPos[0]
	$y = $arPos[1] + $arPos[3]

	_ClientToScreen($hWnd, $x, $y)
	_TrackPopupMenu($hWnd, $hMenu, $x, $y)
EndFunc   ;==>_ShowMenu

; Convert the client (GUI) coordinates to screen (desktop) coordinates
Func _ClientToScreen($hWnd, ByRef $x, ByRef $y)
	Local $stPoint = DllStructCreate("int;int")

	DllStructSetData($stPoint, 1, $x)
	DllStructSetData($stPoint, 2, $y)

	DllCall("user32.dll", "int", "ClientToScreen", "hwnd", $hWnd, "ptr", DllStructGetPtr($stPoint))

	$x = DllStructGetData($stPoint, 1)
	$y = DllStructGetData($stPoint, 2)
	; release Struct not really needed as it is a local
	$stPoint = 0
EndFunc   ;==>_ClientToScreen

; Show at the given coordinates (x, y) the popup menu (hMenu) which belongs to a given GUI window (hWnd)
Func _TrackPopupMenu($hWnd, $hMenu, $x, $y)
	DllCall("user32.dll", "int", "TrackPopupMenuEx", "hwnd", $hMenu, "int", 0, "int", $x, "int", $y, "hwnd", $hWnd, "ptr", 0)
EndFunc   ;==>_TrackPopupMenu

; #FUNCTION# ====================================================================================================================
; Name ..........: _IsFileNameValid
; Description ...:
; Syntax ........: _IsFileNameValid($sExtension)
; Parameters ....: $sExtension          - A string value.
; Return values .: 1 - if File name is valid
;				   0 - if File name is not valid (Conatin \/:*?"<>|)
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _IsFileNameValid($sExtension)
	Local $i, $asInvalidChar = StringSplit('\/:*?"<>|', "", 2)
	For $i = 0 To UBound($asInvalidChar) - 1
		If Not StringInStr($sExtension, $asInvalidChar[$i]) = 0 Then Return SetError(1, 0, 0)
	Next
	Return 1
EndFunc   ;==>_IsFileNameValid

; #FUNCTION# ====================================================================================================================
; Name ..........: _File_Size
; Description ...:  Convert Bytes in to equivalent Bytes,KB,MB,GB
; Syntax ........: _File_Size($iBytes)
; Parameters ....: $iBytes              - An integer value in Bytes.
; Return values .: equivalent Bytes,KB,MB,GB in String
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _File_Size($iBytes)
	If $iBytes > 0 And $iBytes <= 1024 Then
		Return $iBytes & " BYTES"
	ElseIf $iBytes > 1024 And $iBytes <= 1048576 Then
		Return Round($iBytes / (1024), 2) & " KB"
	ElseIf $iBytes > 1048576 And $iBytes <= 1073741824 Then
		Return Round($iBytes / (1048576), 2) & " MB"
	ElseIf $iBytes > 1073741824 Then
		Return Round($iBytes / (1073741824), 2) & " GB"
	EndIf
EndFunc   ;==>_File_Size

; #FUNCTION# ====================================================================================================================
; Name ..........: _Speed_Xbps
; Description ...: Convert Bytes in to equivalent X bps
; Syntax ........: _Speed_Xbps($iRn, $iTimeDiff)
; Parameters ....: $iBytes              - An integer value of bytes.
;                  $iTimeDiff           - An integer value of time difference in second.
; Return values .: equivalent X bps in String
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Speed_Xbps($iBytes, $iTimeDiff)
	$iBytes /= $iTimeDiff
	If $iBytes >= 0 And $iBytes < 1024 Then
		Return Round($iBytes, 2) & " bps"
	ElseIf $iBytes >= 1024 And $iBytes < 1048576 Then
		Return Round($iBytes / (1024), 2) & " kbps"
	ElseIf $iBytes >= 1048576 And $iBytes < 1073741824 Then
		Return Round($iBytes / (1048576), 2) & " mbps"
	ElseIf $iBytes >= 1073741824 Then
		Return Round($iBytes / (1073741824), 2) & " gbps"
	EndIf
EndFunc   ;==>_Speed_Xbps

; #FUNCTION# ====================================================================================================================
; Name ..........: _Time_Xsec
; Description ...: Convert Time Difference in to equivalent ms, s, m
; Syntax ........: _Time_Xsec($iTd)
; Parameters ....: $iTd                 - An integer value in second.
; Return values .: equivalent ms, s, m in String
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Time_Xsec($iTd)
	If $iTd >= 0 And $iTd < 1000 Then
		Return Round($iTd) & " ms"
	ElseIf $iTd >= 1000 And $iTd < 60000 Then
		Return Round($iTd / 1000, 1) & " s"
	ElseIf $iTd >= 60000 Then
		Return Round($iTd / 60000, 1) & " m"
	EndIf
EndFunc   ;==>_Time_Xsec

; #FUNCTION# ====================================================================================================================
; Name ..........: _Conv_Bytes
; Description ...:
; Syntax ........: _Conv_Bytes($iByte)
; Parameters ....: $iByte               - An integer value in Bytes.
; Return values .: Bytes in integer
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Conv_Bytes($iByte, $idCombo_Size)
	Switch GUICtrlRead($idCombo_Size)
		Case "Bytes"
			Return $iByte
		Case "KB"
			Return $iByte * 1024
		Case "MB"
			Return $iByte * 1024 * 1024
		Case "GB"
			Return $iByte * 1024 * 1024 * 1024
		Case Else
			Return $iByte
	EndSwitch
EndFunc   ;==>_Conv_Bytes

; #FUNCTION# ====================================================================================================================
; Name ..........: _Speed_Xfps
; Description ...: Convert Files in to equivalent Xfps
; Syntax ........: _Speed_Xfps($iFiles, $iTimeDiff)
; Parameters ....: $iBytes              - An integer value of bytes.
;                  $iTimeDiff           - An integer value of time difference in second.
; Return values .: equivalent X Files per Time in String
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Files_Xfps($iFiles, $iTimeDiff)
	$iFiles /= $iTimeDiff
	If $iFiles >= 0 And $iFiles < 1000 Then
		Return Round($iFiles, 2) & " fps"
	ElseIf $iFiles >= 1000 And $iFiles < 1000000 Then
		Return Round($iFiles / (1000), 2) & " kfps"
	ElseIf $iFiles >= 1000000 And $iFiles < 1000000000 Then
		Return Round($iFiles / (1000000), 2) & " mfps"
	ElseIf $iFiles >= 1000000000 Then
		Return Round($iFiles / (1000000000), 2) & " gfps"
	EndIf
EndFunc   ;==>_Files_Xfps

Func _GetCurrentSystemTime()
	Local $tDate = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tDate, "Year", @YEAR)
	DllStructSetData($tDate, "Month", @MON)
	DllStructSetData($tDate, "Day", @MDAY)
	DllStructSetData($tDate, "Hour", @HOUR)
	DllStructSetData($tDate, "Minute", @MIN)
	DllStructSetData($tDate, "Second", @SEC)
	Return $tDate
EndFunc   ;==>_GetCurrentSystemTime