;AutoItSetOption ("TrayIconDebug", 1);0-off

;Deployment Guys
;http://blogs.technet.com/deploymentguys
;MDT Debugger

;Version 2.2


#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <GDIPlus.au3>


Opt("GUIOnEventMode", 1)

$hGUI = GUICreate("Deployment Guys - MDT ZTI Debugger", 470, 110, 5, 5)
GUISetOnEvent($GUI_EVENT_CLOSE, 'Quit')

GUISetState()
	
$RemoteComputerLabel = GUICtrlCreateLabel("Remote computer name:", 15, 83, 120, 20)
$Input_RemoteComputer = GUICtrlCreateInput("", 135, 80, 130, 20)
$ConnectRemoteComputer = GUICtrlCreateButton('Connect', 270, 80, 80, 20)
GUICtrlSetOnEvent($ConnectRemoteComputer, 'ConnectRemoteComputer')

_GDIPlus_StartUp()
$hImage   = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\Header.jpg")
$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, 5, 5)

Global $RemoteComputer
Global $ReturnToMDT
Global $LblReturnCode
Global $StdOutBox
Global $CmdLineVal
Global $strRetCode
Global $strStatusFlag


While 1

	Sleep(10)

WEnd
	
_GDIPlus_GraphicsDispose($hGraphic)
_GDIPlus_ImageDispose($hImage)
_GDIPlus_ShutDown()


Func ConnectRemoteComputer()

	If StringLen(GUICtrlRead($Input_RemoteComputer)) > 0 Then

		$RemoteComputer = StringUpper(GUICtrlRead($Input_RemoteComputer))
		
		If FileExists("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG") = True Then

			WinMove($hGui, "", Default, Default, Default, 700)
			$hImage   = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\Header.jpg")
			$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
			_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, 5, 5)
	
			;Remove connect Controls
			GUICtrlDelete($RemoteComputerLabel)
			GUICtrlDelete($Input_RemoteComputer)
			GUICtrlDelete($ConnectRemoteComputer)


			;Build interface
			GUICtrlCreateLabel("Connected to remote computer: " & $RemoteComputer, 31, 80, 400, 20)
	
			GUICtrlCreateLabel("Error Code Returned:", 31, 100, 150, 20)
			$LblReturnCode = GUICtrlCreateLabel("N/A", 135, 100, 80, 20)

			$ReRunCommand = GUICtrlCreateButton('Re-run Command Line', 10, 130, 450, 40)
			GUICtrlSetOnEvent($ReRunCommand, 'ReRunCommand')

			$ReturnToMDT = GUICtrlCreateButton('Return The Error Code 0 to MDT', 10, 170, 225, 40)
			GUICtrlSetOnEvent($ReturnToMDT, 'ReturnToMDT')

			$ReturnZeroToMDT = GUICtrlCreateButton('Return The Error Code 0 to MDT', 235, 170, 225, 40)
			GUICtrlSetOnEvent($ReturnZeroToMDT, 'ReturnZeroToMDT')

			$LblCmdLine = GUICtrlCreateLabel(" Cmd line: ", 18, 218, 55, 20) ;261, 55, 20)
			$CmdLineVal = GUICtrlCreateInput("", 68, 215, 391, 20) ;258, 391, 20)

			$StdOutBox = GUICtrlCreateEdit("", 10, 245, 450, 415);, $ES_MULTILINE)


			;Populate values from CFG
			$strRetCode = IniRead("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "RETURNCODE", "ERR")
			GUICtrlSetData($ReturnToMDT, "Return The Error Code " & $strRetCode & " to MDT")
			GuiCtrlSetData($LblReturnCode, $strRetCode)

			$strCmdLine = IniRead("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "COMMANDLINE", "ERR")
			GUICtrlSetData($CmdLineVal, $strCmdLine)

			;Call("ReadLogFile", $RemoteComputer)
			GUICtrlSetData($StdOutBox, ReadLogFile($RemoteComputer))
						
		Else

			MsgBox(4096, "Deployment Guys - MDT ZTI Debugger", "Unable to connect to remote computer, or the remote computer has not run the debugger component yet.")
		
		EndIf

	Else
		
		MsgBox(4096, "Deployment Guys - MDT ZTI Debugger", "You must enter a remote computer name first!")
		
	EndIf

EndFunc

Func ReadLogFile($strComputer)

	$file = FileOpen("\\" & $strComputer & "\C$\ZTI_CUSTOM_MDTDEBUGGER.txt", 0)
	
	If $file <> -1 Then

		Dim $strLine

		While 1
    
			$line = FileReadLine($file)
			If @error = -1 Then ExitLoop

			$strLine = $strLine & $line & @CRLF
		
		Wend
	
	EndIf

	FileClose($file)

	Return $strLine

EndFunc

Func ReRunCommand()

	GuiCtrlSetData($LblReturnCode, "--")
	GUICtrlSetData($ReturnToMDT, "Return The Error Code -- to MDT")

	IniWrite("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "RERUN")
	IniWrite("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "COMMANDLINE", GUICtrlRead($CmdLineVal))
	GUICtrlSetData($StdOutBox, "Please wait, re-run command sent.  Awaiting input...")
	
	$boolRunComplete = False
	
	Do
		
		$strBoolCheck = IniRead("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "ERR")
		
		If $strBoolCheck = "WAITING" Then $boolRunComplete = True
		
		Sleep(3000)
		
	Until $boolRunComplete = True
	

	;Populate values from CFG
	$strRetCode = IniRead("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "RETURNCODE", "ERR")
	GUICtrlSetData($ReturnToMDT, "Return The Error Code " & $strRetCode & " to MDT")
	GuiCtrlSetData($LblReturnCode, $strRetCode)

	$strCmdLine = IniRead("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "COMMANDLINE", "ERR")
	GUICtrlSetData($CmdLineVal, $strCmdLine)

	GUICtrlSetData($StdOutBox, ReadLogFile($RemoteComputer))
	
EndFunc

Func ReturnToMDT()

	If $strRetCode <> 0 Then
		
		$ReturnResponse = MsgBox(4, "Deployment Guys - MDT ZTI Debugger", "Error code to return: " & $strRetCode & @CRLF & @CRLF & "You are attempting to return a non-zero error code to MDT which may cause it to fail.  Are you sure you want to do this?")

		If $ReturnResponse = 6 Then

			IniWrite("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "FINISHED")
			GUICtrlSetData($StdOutBox, "Return command set, finishing...")
	
			Sleep(3000)
			Exit(0)
		
		EndIf
	
	Else

		IniWrite("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "FINISHED")
		GUICtrlSetData($StdOutBox, "Return command set, finishing...")
	
		Sleep(3000)
		Exit(0)
		
	EndIf
	
EndFunc

Func ReturnZeroToMDT()

		$ReturnResponse = MsgBox(4, "Deployment Guys - MDT ZTI Debugger", "Are you sure you want to do return error code 0 to MDT?")

		If $ReturnResponse = 6 Then

			IniWrite("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "FINISHED")
			GUICtrlSetData($StdOutBox, "Return command set, finishing...")
	
			IniWrite("\\" & $RemoteComputer & "\C$\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "RETURNCODE", "0")
	
			Sleep(3000)
			Exit(0)
		
		EndIf

EndFunc

Func Quit()
	
	Exit

EndFunc