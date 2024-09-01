#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here




#include <MsgBoxConstants.au3>
#include "lightroom-params_1080p_v2.au3"


$NUM_PHOTOS = InputBox ("Auto Adjust", "Input the number of photos you want to Auto Adjust.");

#cs
$RESET = 1
$PASTE = 0
$POST_PASTE = 0
$AUTOEDIT = 1
$MIN_HIGHLIGHTS = 0
$ADAPTIVE_EXP = 1
$EXPOSURE_OFFSET = 0
$SET_TEMPERATURE = 0
$ADAPTIVE_BLACK = 1
$SUBJECT_TEXTURE_REDUCE = 0;-20; -30
$SUBJECT_EXPOSURE_INCREASE = 0;0.35;0.4
$BACKGROUND_EXP_REDUCE_SAT_INC = 0
$AI_DENOISE = 1
$COOLDOWN_SECONDS = 15 ; seconds

; Not implemented
$BACKGROUND_BLACK_REDUCE = 0
#ce

;#cs
$RESET = 0
$PASTE = 0
$POST_PASTE = 0
$AUTOEDIT = 0
$MIN_HIGHLIGHTS = 0
$ADAPTIVE_EXP = 0
$EXPOSURE_OFFSET = 0
$SET_TEMPERATURE = 0
$ADAPTIVE_BLACK = 0
$SUBJECT_TEXTURE_REDUCE = -60
$SUBJECT_EXPOSURE_INCREASE = 0
$BACKGROUND_EXP_REDUCE_SAT_INC = 0
$AI_DENOISE = 0
$COOLDOWN_SECONDS = 30 ; seconds
#ce
; Not implemented
$BACKGROUND_BLACK_REDUCE = 0

#cs
$RESET = 1
$PASTE = 0
$AUTOEDIT = 1
$MIN_HIGHLIGHTS = 1
$ADAPTIVE_EXP = 1
$EXPOSURE_OFFSET = 0.5
$ADAPTIVE_BLACK = 0
$SUBJECT_TEXTURE_REDUCE = -50
$SUBJECT_EXPOSURE_INCREASE = 0.3
$AI_DENOISE = 0
$BACKGROUND_BLACK_REDUCE = 0
#ce
if ($NUM_PHOTOS > 0) Then
   Sleep (8000)
EndIf

#cs
AI_Denoise ()
ConsoleWrite ("Done 1")
;Sleep (2000)
send ("{RIGHT}")
Sleep (2000)

AI_Denoise ()
ConsoleWrite ("Done 2")
;MsgBox (0, "", "Will send right now(2)", 5)
send ("{RIGHT}")
Sleep (2000)

AI_Denoise ()
ConsoleWrite ("Done 3")
;MsgBox (0, "", "Will send right now(3)", 5)
send ("{RIGHT}")

Exit (1)
#ce

$auto_exp_applied = 0

For $i = 1 To $NUM_PHOTOS


   If ($RESET == 1) Then
	  Send ("^r")
	  Sleep (600)
   EndIf

   If ($AUTOEDIT == 1) Then
	  Sleep (700)
	  send ("+a")
	  Sleep (2600)
   EndIf

   If ($PASTE == 1) Then
	  Sleep (500)
	  send ("^v")
	  Sleep (600)
   EndIf

   If ($MIN_HIGHLIGHTS = 1) Then
	  Sleep (350)
	  Min_highlights()
	  Sleep (600)
   EndIf

   If ($ADAPTIVE_EXP = 1) Then
	  Sleep (600)
	  if (Auto_exposure() = 1) Then
		 Sleep (1500)
	  EndIf
   EndIf

   If ($EXPOSURE_OFFSET <> 0) Then
	  Sleep (900)
	  if (Set_Exp_offset($EXPOSURE_OFFSET) = 1) Then
		 Sleep (300)
	  EndIf
   EndIf

   If ($ADAPTIVE_BLACK = 1) Then
	  Sleep (800)
	  if (Auto_Blacks() = 1) Then
		 Sleep (300)
	  EndIf
   EndIf

   If ($SET_TEMPERATURE <> 0) Then
	  Sleep (300)
	  Set_temperature ($SET_TEMPERATURE)
	  Sleep (700)
   EndIf

   If ($SUBJECT_TEXTURE_REDUCE <> 0 Or $SUBJECT_EXPOSURE_INCREASE <> 0) Then

	  If ($BACKGROUND_EXP_REDUCE_SAT_INC == 1) Then
		 $continuity_mode = 1
	  Else
		 $continuity_mode = 0
	  EndIf

	  subject_texture_reduction($SUBJECT_EXPOSURE_INCREASE, $SUBJECT_TEXTURE_REDUCE, $continuity_mode)
	  Sleep (800)

   EndIf

   If ($BACKGROUND_BLACK_REDUCE = 1) Then
	  Inv_subject_blacks_reduction ()
	  Sleep (1200)
   EndIf

   If ($BACKGROUND_EXP_REDUCE_SAT_INC = 1) Then
	  Local $param[3] = [2, $EXPOSURE, $SATURATION]
	  Local $value[3] = [0, -0.2, 25]
	  If ($SUBJECT_TEXTURE_REDUCE <> 0 Or $SUBJECT_EXPOSURE_INCREASE <> 0) Then
		 $continuity_mode = 1
	  Else
		 $continuity_mode = 0
	  EndIf
	  Second_Mask_Create_And_Modify($param, $value, $continuity_mode)

   EndIf


   If ($POST_PASTE = 1) Then
	  Sleep (500)
	  send ("^v")
	  Sleep (1500)
   EndIf

   If ($AI_DENOISE = 1) Then
	  Sleep (500)
	  _AI_Denoise ()
	  Sleep (1000)
   EndIf

   Sleep ($COOLDOWN_SECONDS * 1000 / 3)

   ;


#cs
   Paste types:
	  crop
	  noise reduction
	  lens correction
	  temperature
	  tint
	  vibrance
	  saturation
	  highlights
	  clarity
	  texture

#ce



   ;Sleep(1000)
   ;if (() = 1) Then
	  ;Sleep (500)
   ;EndIf

   send ("{RIGHT}")

   Sleep ($COOLDOWN_SECONDS * 2000 / 3)
   ;Sleep(5000)

Next



;For $i = 1 To $NUM_PHOTOS

#cs
   Paste types:
	  crop
	  noise reduction
	  lens correction
	  temperature
	  tint
	  vibrance
	  saturation
	  highlights
	  clarity
	  texture


   Sleep (1000)
   send ("^v")
   Sleep(600)
   send ("{RIGHT}")

Next
#ce

