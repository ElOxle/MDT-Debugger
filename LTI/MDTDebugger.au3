;MDT Debugger
;Daniel Oxley
;Version 2.4


#NoTrayIcon

#include <GUIConstantsEx.au3>
;#include <GDIPlus.au3>


Opt("GUIOnEventMode", 1)

If $CmdLine[0] < 1 Then

   ; no command line parameters, cannot continue
	MsgBox(48, "MDT Debugger", "You have not specified any command-line parameters for the debugger to use")
	Exit(666)

Else

   ; move the SMS window out of the way
   Call("MoveSMSProgressWindow")

   ; set up folders
	If FileExists("C:\MININT") = 0 Then DirCreate("C:\MININT")
	If FileExists("C:\MININT\SMSOSD") = 0 Then DirCreate("C:\MININT\SMSOSD")
	If FileExists("C:\MININT\SMSOSD\OSDLOGS") = 0 Then DirCreate("C:\MININT\SMSOSD\OSDLOGS")

   ; run command and write output to file
	$val = RunWait(@ComSpec & " /c " & chr(34) & $CmdLineRaw & chr(34) & " > C:\MININT\SMSOSD\OSDLOGS\MDTDebugger.txt") ;$val = RunWait(@ComSpec & " /c " & chr(34) & $CmdLineRaw & chr(34), @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	$file = FileOpen("C:\Minint\Smsosd\Osdlogs\MDTDebugger.txt", 0)

   ; read in output
	If $file <> -1 Then

		Dim $strLine

		While 1

			; loop through each line of file
			$line = FileReadLine($file)
			If @error = -1 Then ExitLoop

			$strLine = $strLine & $line & @CRLF

		Wend

	EndIf

   ; close file
	FileClose($file)

   ; build GUI
	$hGUI = GUICreate("MDT Debugger", 470, 498, 5, 5)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'Quit')

	GUISetState()

	GUICtrlCreateLabel("Command Line Received:", 10, 7, 150, 20)
	GUICtrlCreateLabel("Return Code After Execution:", 10, 34, 150, 20)
	$Input_CommandLine = GUICtrlCreateInput($CmdLineRaw, 155, 4, 303, 20)
	$Input_ReturnCode = GUICtrlCreateInput($val, 155, 31, 55, 20)

	$AboutBtn = GUICtrlCreateButton('About...', 404, 29, 56, 25)
	GUICtrlSetOnEvent($AboutBtn, "AboutBtn")

	If FileExists("C:\MININT\SMSOSD\OSDLOGS\VARIABLES.DAT") = True Then

		$ReRunCommand = GUICtrlCreateButton('Re-run the command line', 10, 58, 250, 40)

		If FileExists("C:\Program Files\Internet Explorer\iexplore.exe") = True Then

			$ViewDATIE = GUICtrlCreateButton('View VARIABLES.DAT in Internet Explorer', 240, 58, 220, 40)
			GUICtrlSetOnEvent($ViewDATIE, "ViewDATIE")

		Else

			$ViewDATNP = GUICtrlCreateButton('View VARIABLES.DAT in Notepad', 240, 58, 220, 40)
			GUICtrlSetOnEvent($ViewDATNP, "ViewDATNP")

		EndIf

	Else

		$ReRunCommand = GUICtrlCreateButton('Re-run the command line', 10, 58, 450, 40)

	EndIf

	$StdOutBox = GUICtrlCreateEdit($strLine, 11, 180, 448, 310);, $ES_MULTILINE)


	;_GDIPlus_StartUp()

	GUICtrlSetOnEvent($ReRunCommand, "ReRunCommand")


	If FileExists("C:\MININT\SMSOSD\OSDLOGS") = True Then

		$ReturnToMDT = GUICtrlCreateButton('Return the error code ' & chr(34) & $val & chr(34) & ' to MDT', 10, 98, 220, 40)
		$OpenLogs = GUICtrlCreateButton('Open Logs Folder', 240, 98, 220, 40)

		GUICtrlSetOnEvent($OpenLogs, "OpenLogsFolder")

	Else

		$ReturnToMDT = GUICtrlCreateButton('Return the error code ' & chr(34) & $val & chr(34) & ' to MDT', 10, 98, 450, 40)

	EndIf

	GUICtrlSetOnEvent($ReturnToMDT, "ReturnToMDT")

	$RefreshErrorCode = GUICtrlCreateButton('Refresh Error Code Return Button', 10, 138, 450, 40)
	GUICtrlSetOnEvent($RefreshErrorCode, "RefreshButton")

   ; GUI built and displayed

	While 1

	  ; wait for user action
	  Sleep(10)

	WEnd

;	_GDIPlus_GraphicsDispose($hGraphic)
;	_GDIPlus_ImageDispose($hImage)
;	_GDIPlus_ShutDown()

EndIf

Func ReRunCommand()

	$val = ""
	$strLine = ""

	GUICtrlSetData($StdOutBox, "Running command line...")
	GUICtrlSetData($Input_ReturnCode, "-")

	$val = RunWait(@ComSpec & " /c " & chr(34) & GuiCtrlRead($Input_CommandLine) & chr(34) & " > C:\MININT\SMSOSD\OSDLOGS\MDTDebugger.txt")
	$file = FileOpen("C:\Minint\Smsosd\Osdlogs\MDTDebugger.txt", 0)

	If $file <> -1 Then

		Dim $strLine

		While 1

			$line = FileReadLine($file)
			If @error = -1 Then ExitLoop

			$strLine = $strLine & $line & @CRLF

		Wend

	EndIf

	FileClose($file)

	GUICtrlSetData($StdOutBox, $strLine)
	GUICtrlSetData($Input_ReturnCode, $val)
	GUICtrlSetData($ReturnToMDT, 'Return the error code ' & chr(34) & $val & chr(34) & ' to MDT')

EndFunc

Func ReturnToMDT()

   If $CmdLineRaw <> $val = GuiCtrlRead($Input_CommandLine) Then MsgBox(48, "MDT Debugger", "You have modified the captured command line or the return code since the last execution of the process."  & chr(13) & chr(13) & "Don't forget to update the MDT task sequence with the updated command or return code if needed.")

   ; try to return SMS progress window back to centre of screen
   Call("ReturnSMSProgressWindow")

   If FileExists("C:\MININT\SMSOSD\OSDLOGS\VARIABLES.XML") = True Then FileDelete("C:\MININT\SMSOSD\OSDLOGS\VARIABLES.XML")
   If FileExists("C:\MININT\SMSOSD\OSDLOGS\MDTDebugger.txt") = True Then FileDelete("C:\MININT\SMSOSD\OSDLOGS\MDTDebugger.txt")

	Exit($val)

EndFunc

Func RefreshButton()

	$val = GuiCtrlRead($Input_ReturnCode)
	GUICtrlSetData($ReturnToMDT, 'Return the error code ' & chr(34) & GuiCtrlRead($Input_ReturnCode) & chr(34) & ' to MDT')

EndFunc

Func ViewDATIE()

	FileCopy("C:\MININT\SMSOSD\OSDLOGS\VARIABLES.DAT", "C:\MININT\SMSOSD\OSDLOGS\VARIABLES.XML", 1)
	Run("C:\Program Files\Internet Explorer\iexplore.exe C:\MININT\SMSOSD\OSDLOGS\VARIABLES.XML")

EndFunc

Func ViewDATNP()

	Run("C:\Windows\System32\notepad.exe C:\MININT\SMSOSD\OSDLOGS\VARIABLES.DAT")

EndFunc

Func OpenLogsFolder()

	If FileExists("C:\Windows\Explorer.exe") = True Then

		Run("C:\Windows\Explorer.exe C:\MININT\SMSOSD\OSDLOGS")

	Else

		MsgBox(48, "MDT Debugger", "Sorry - Unable to locate C:\Windows\Explorer.exe")

	EndIf

EndFunc

Func AboutBtn()

   MsgBox(48, "MDT Debugger", "MDT Debugger by Daniel Oxley" & chr(13) & "Version: 2.4" & chr(13) & chr(13) & "Copyright (c) 2013, Daniel Oxley - http://deploymentpros.wordpress.com" & chr(13) & chr(13) & "You are allowed to distribute this free tool at no charge but reference must be made back to the authors blog." & chr(13) & chr(13) & "The use of this tool is at your own risk, no support whatsoever is provided for it.")

EndFunc

Func MoveSMSProgressWindow()

	If WinExists("Installation Progress") Then

		$size = WinGetPos("Installation Progress")
		Mousemove($size[0]+50, $size[1]+50)
		MouseClick("left")

		$size = WinGetClientSize("Installation Progress")
		$intX = (@DesktopWidth - 20) - $size[0]
		$intY = (@DesktopHeight - 60) - $size[1]


		WinMove("Installation Progress", "", $intX, $intY)

	EndIf

EndFunc

Func ReturnSMSProgressWindow()

	If WinExists("Installation Progress") Then

		$size = WinGetPos("Installation Progress")
		Mousemove($size[0]+50, $size[1]+50)
		MouseClick("left")

		$size = WinGetClientSize("Installation Progress")
		$intX = (@DesktopWidth / 2) - ($size[0] / 2)
		$intY = (@DesktopHeight / 2) - ($size[1] / 2)

		WinMove("Installation Progress", "", $intX, $intY)

	EndIf

EndFunc

Func Quit()

   Call("ReturnSMSProgressWindow")

   If FileExists("C:\MININT\SMSOSD\OSDLOGS\VARIABLES.XML") = True Then FileDelete("C:\MININT\SMSOSD\OSDLOGS\VARIABLES.XML")
   If FileExists("C:\MININT\SMSOSD\OSDLOGS\MDTDebugger.txt") = True Then FileDelete("C:\MININT\SMSOSD\OSDLOGS\MDTDebugger.txt")

   Exit(666)

EndFunc