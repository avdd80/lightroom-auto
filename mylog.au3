;----------------------------------------------------
; Add enum for error level

$LOG_FATAL = 0
$LOG_ERROR = 1
$LOG_WARN  = 2
$LOG_INFO  = 3
; < insert new level here >
$LOG_LEVEL_COUNT = 4

; Default
Local $error_level_threshold = $LOG_INFO

Func my_log_set_error_level_threshold ($level)
	$error_level_threshold = $level
EndFunc

Func my_log_get_error_level_threshold ()
	return $error_level_threshold
EndFunc
;----------------------------------------------------

;----------------------------------------------------
; Type of display
$CONSOLE = 0
$MSGBOX  = 1
; < insert new display type here >
$DISPLAY_TYPE_COUNT = 2

; Default
Local $display_type = $LOG_INFO

Func my_log_set_display_type ($type)
	$display_type = $type
EndFunc

Func my_log_get_display_type ()
	return $display_type
EndFunc
;----------------------------------------------------

Func my_log ($level, $str)

	if ($level >= my_log_get_error_level_threshold ()) Then
		Return
	EndIf

	Switch $level
			Case $LOG_FATAL
					$sMsg = "FATAL: "
			Case $LOG_ERROR
					$sMsg = "ERROR: "
			Case $LOG_WARN
					$sMsg = "WARN : "
			Case $LOG_INFO
					$sMsg = "INFO : "
			Case Else
					MsgBox (0, "my_log ERROR" "Unknown $level passed to my_log : " & String($level) & @CRLF)
					Exit()
	EndSwitch
	; Prepare final print string
	$sMsg = $sMsg & $str & @CRLF


   if (my_log_get_display_type() = $CONSOLE) Then
		ConsoleWrite ($sMsg)
	ElseIf (my_log_get_display_type() = $MsgBox) Then
		MsgBox (0, "", $sMsg)	
	EndIf

EndFunc
