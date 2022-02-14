AutoItSetOption ("TrayIconDebug", 0);0-off 1-on

;Deployment Guys
;http://blogs.technet.com/deploymentguys
;ZTI_MDTDebugger_Launcher

;Version 1.0


#NoTrayIcon
#Include <File.au3>

$logFile = "C:\ZTI_MDTDEBUGGER_LAUNCHER.log"


If $CmdLine[0] < 1 Then

	_FileWriteLog($logFile,  "You have not specified any command-line parameters for the debugger to use.  Existing with code 666")
	Exit(666)

Else

	;Cleanup from any previous run
	If FileExists("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG") Then FileDelete("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG")
	If FileExists("C:\ZTI_CUSTOM_MDTDebugger.txt") Then FileDelete("C:\ZTI_CUSTOM_MDTDebugger.txt")
	If FileExists("C:\ZTI_MDTDEBUGGER_LAUNCHER.log") Then FileDelete("C:\ZTI_MDTDEBUGGER_LAUNCHER.log")

	;Launch command
	_FileWriteLog($logFile, "Command line to run: " & $CmdLineRaw)
	$val = RunWait(@ComSpec & " /c " & chr(34) & $CmdLineRaw & chr(34) & " >> C:\ZTI_CUSTOM_MDTDebugger.txt")

	;Write return code to log and set status
	_FileWriteLog($logFile, "Error code returned: " & $val)
	_FileWriteLog($logFile, "Setting status to WAITING")
	IniWrite("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "WAITING")
	IniWrite("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "RETURNCODE", $val)
	IniWrite("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "COMMANDLINE", $CmdLineRaw)

	;Prepare for wait/processing loop
	$LoopWait = 0
	$LoopStatus = "WAITING"

	Do

		_FileWriteLog($logFile, "Looping.  Current status is: " & $LoopStatus & " - LoopWait = " & $LoopWait)

		;Read status message
		$LoopStatus = IniRead("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "FINISHED")

		_FileWriteLog($logFile, "Received status is: " & $LoopStatus)

		;Process status message
		If $LoopStatus = "RERUN" Then
			
			_FileWriteLog($logFile, "Status changed to: " & $LoopStatus)
			
			IniWrite("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "RUNNING")
			Call("ReRunCommand")
			
			$LoopWait = 0
		
		ElseIf $LoopStatus = "FINISHED" Then

			_FileWriteLog($logFile, "Status changed to: " & $LoopStatus)
			IniWrite("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "FINISHED")
			$LoopWait = 1
			
		Else

			$LoopWait = 0

		EndIf

		sleep(5000)

	Until $LoopWait = 1

	_FileWriteLog($logFile, "Exiting Loop")

	;Setting error code to return to ConfigMgr
	$RetCode = IniRead("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "RETURNCODE", $val)
	_FileWriteLog($logFile, "Setting error code to return to: " & $RetCode)

	;Exiting
	_FileWriteLog($logFile, "Exiting with error code: " & $RetCode)
	Exit ($RetCode)

	;Cleaning up
	Sleep(1000)
	FileClose("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG")
	FileClose("C:\ZTI_CUSTOM_MDTDebugger.txt")
	FileClose("C:\ZTI_MDTDEBUGGER_LAUNCHER.log")
	
	sleep(1000)
	
	If FileExists("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG") Then FileDelete("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG")
	If FileExists("C:\ZTI_CUSTOM_MDTDebugger.txt") Then FileDelete("C:\ZTI_CUSTOM_MDTDebugger.txt")
	If FileExists("C:\ZTI_MDTDEBUGGER_LAUNCHER.log") Then FileDelete("C:\ZTI_MDTDEBUGGER_LAUNCHER.log")

EndIf

Func ReRunCommand()

	$val = ""
	$strLine = ""
	
	_FileWriteLog($logFile, "Rerunning command")
	_FileWriteLog($logFile, "Command line to run: " & IniRead("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "COMMANDLINE", $CmdLineRaw))
	$val = RunWait(@ComSpec & " /c " & chr(34) & IniRead("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "COMMANDLINE", $CmdLineRaw) & chr(34) & " > C:\ZTI_CUSTOM_MDTDebugger.txt")
	
	_FileWriteLog($logFile, "Error code returned: " & $val)

	;Write return code to log and set status
	_FileWriteLog($logFile, "Error code returned: " & $val)
	_FileWriteLog($logFile, "Setting status to WAITING")
	IniWrite("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "STATUS", "WAITING")
	IniWrite("C:\ZTI_MDTDEBUGGER_LAUNCHER.CFG", "DEBUGGER", "RETURNCODE", $val)

EndFunc