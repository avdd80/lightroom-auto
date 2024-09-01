#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here


#include <FileConstants.au3>
#include <Timers.au3>
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include "mylog.au3"


#cs

Algo:

1. Scroll up completely.
2. Copy exposure value and evaluate it.
3. Set the new exposure value.
4. Paste it back and press enter.

Todo:

1. Add a function to detect if filters are turned on.
	a. add function to detect what filters are on.
2. Add a function monitor the mousepointer access.
   If it goes out of bounds, crash the program with a dump.
3. Add a function to 
4. Convert to state machine!!
5. Use stars to track features
6. Add logic for merge
7. Rename dummy clicks with safe_clicks
8. Detect view mode from the square at the bottom of the screen.

#ce

Global $current_function_identifier;

#cs====================================================================
   ENUMERATIONS
#ce====================================================================

Global $TRUE = 1
Global $FALSE = 0

; Parameters
$DEFAULT       = 0
$EXPOSURE      = 1
$CONTRAST      = 2
$HIGHLIGHTS    = 3
$SHADOWS       = 4
$WHITES        = 5
$BLACKS        = 6

$TEMPERATURE   = 7
$TINT          = 8
$HUE           = 9
$SATURATION    = 10

$SUBJECT_EXPOSURE = 51

; Right Panel
;------------------------------;
$PANEL_X = 1700
$PANEL_Y =  400

; Y positions of sliders
;------------------------------;
$EXP_SL_Y = 445       + 45 * 0 ;
;------------------------------;
$CON_SL_Y = $EXP_SL_Y + 45 * 1
$HIG_SL_Y = $EXP_SL_Y + 45 * 2
$SHA_SL_Y = $EXP_SL_Y + 45 * 3
$WHI_SL_Y = $EXP_SL_Y + 45 * 4
$BLK_SL_Y = $EXP_SL_Y + 45 * 5

; iPhone RAW
;$BLK_SL_Y =  679

; Extreme X positions of slider bubbles
;----------------------;
$CMN_SL_X_LEFT  = 1630 ;
$CMN_SL_X_RIGHT = 1842 ;
;----------------------;
$CMN_SL_X_ZERO = $CMN_SL_X_LEFT + Int(($CMN_SL_X_RIGHT - $CMN_SL_X_LEFT) / 2)
$SLIDER_RANGE  = $CMN_SL_X_RIGHT - $CMN_SL_X_LEFT

; X,Y co-ordiates of textbox that displays editable text values of exp, contrast etc.
;------------------;
$CMN_VAL_X = 1840  ;
;------------------;
$EXP_VAL_X = $CMN_VAL_X
$CON_VAL_X = $EXP_VAL_X
$HIG_VAL_X = $EXP_VAL_X
$SHA_VAL_X = $EXP_VAL_X
$WHI_VAL_X = $EXP_VAL_X
$BLK_VAL_X = $EXP_VAL_X



;--------------------------------;
$EXP_VAL_Y = $EXP_SL_Y - 19 + 45 * 0 ;
;--------------------------------;
$CON_VAL_Y = $EXP_VAL_Y     + 45 * 1
$HIG_VAL_Y = $EXP_VAL_Y     + 45 * 2
$SHA_VAL_Y = $EXP_VAL_Y     + 45 * 3
$WHI_VAL_Y = $EXP_VAL_Y     + 45 * 4
$BLK_VAL_Y = $EXP_VAL_Y     + 45 * 5
;$BLK_VAL_Y = 660

$TMP_VAL_Y = 840


; Center of triangle above histogram that indicates if image is saturated at whites or blacks.
;--------------------------------;
$HIST_BLACK_SATURATED_X = 1608   ;
$HIST_BLACK_SATURATED_Y = 104    ;
$HIST_WHITE_SATURATED_X = 1861   ;
;--------------------------------;
$HIST_WHITE_SATURATED_Y = $HIST_BLACK_SATURATED_Y


$SCROLLBAR_X = 1868
$SCROLLBAR_LIGHT_Y = 265
$SCROLLBAR_LIGHT_Y = 265


;--------------------------------;
;Subject Selection ;-------------;
;--------------------------------;
$MASK_ICON_X = 1898
$MASK_ICON_Y = 326

$SELECT_SUBJECT_X = 1650
$SELECT_SUBJECT_Y = 300

;--------------------------------;
$SELECT_SUBJECT_EXPOSURE_0_Y = 499 + 45 * 0 ;
;--------------------------------;
$SELECT_SUBJECT_CONTRAST_0_Y = $SELECT_SUBJECT_EXPOSURE_0_Y  + 45 * 1
$SELECT_SUBJECT_HIGH_0_Y     = $SELECT_SUBJECT_EXPOSURE_0_Y  + 45 * 2
$SELECT_SUBJECT_SHADOW_0_Y   = $SELECT_SUBJECT_EXPOSURE_0_Y  + 45 * 3
$SELECT_SUBJECT_WHITES_0_Y   = $SELECT_SUBJECT_EXPOSURE_0_Y  + 45 * 4
$SELECT_SUBJECT_BLACKS_0_Y   = $SELECT_SUBJECT_EXPOSURE_0_Y  + 45 * 5

$SELECT_SUBJECT_EXPOSURE_0_X = $CMN_SL_X_ZERO;

$SELECT_SUBJECT_BLACKS_0_X = $CMN_SL_X_ZERO; 1736
$SELECT_SUBJECT_BLACKS_0_Y = $SELECT_SUBJECT_BLACKS_0_Y

$SELECT_SUBJECT_BLACKS_NEG_25_X = 1710
$SELECT_SUBJECT_BLACKS_NEG_25_Y = $SELECT_SUBJECT_BLACKS_0_Y

$SELECT_SUBJECT_CONTRAST_0_X = $CMN_SL_X_ZERO; 1736
$SELECT_SUBJECT_CONTRAST_30_X = 1768

$SELECT_SUBJECT_TEXTURE_0_X = $CMN_SL_X_ZERO; 1736
$SELECT_SUBJECT_TEXTURE_0_Y = 574
$SELECT_SUBJECT_TEXTURE_NEG_70_X = 1700
$SELECT_SUBJECT_TEXTURE_NEG_70_Y = $SELECT_SUBJECT_TEXTURE_0_Y

;--------------------------------;
$SELECT_SUBJECT_TEMPERATURE_0_Y  = 403 + 45 * 0
;--------------------------------;
$SELECT_SUBJECT_TINT_0_Y         = $SELECT_SUBJECT_TEMPERATURE_0_Y  + 45 * 1
$SELECT_SUBJECT_HUE_0_Y          = 512
$SELECT_SUBJECT_SATURATION_0_Y   = 588

   $NEW_MASK_PLUS_BUTTON_X = 1545
   $NEW_MASK_PLUS_BUTTON_Y = 187

;--------------------------------;
;System Color ;------------------;
;--------------------------------;
$LIGHTROOM_DEFAULT_BLUE_COLOR = 0

;--------------------------------;

Func initialize ()
	my_log_set_display_type ($MSGBOX)
    my_log_set_error_level_threshold( $LOG_INFO)
EndFunc


Func Panel_Scroll_up ($count)
   MouseMove ($PANEL_X, $PANEL_Y)
   Sleep (20)
   ; Move the mouse wheel up 'count' times.
   MouseWheel($MOUSE_WHEEL_UP, $count)
   Sleep (20)
EndFunc

Func Panel_Scroll_down ($count)
   MouseMove ($PANEL_X, $PANEL_Y)
   Sleep (20)
   ; Move the mouse wheel down 30 times.
   MouseWheel($MOUSE_WHEEL_DOWN, $count)
   Sleep (20)
EndFunc


Func Read_Val ($PARAMETER)
   $Y = 0
   Switch ($PARAMETER)
        Case $EXPOSURE
            $Y = $EXP_VAL_Y
        Case $CONTRAST
            $Y = $CON_VAL_Y
        Case $HIGHLIGHTS
            $Y = $HIG_VAL_Y
        Case $SHADOWS
            $Y = $SHA_VAL_Y
        Case $WHITES
            $Y = $WHI_VAL_Y
        Case $BLACKS
            $Y = $BLK_VAL_Y
        Case $TEMPERATURE
			$Y = $TMP_VAL_Y
   EndSwitch
   $is_negative = 0
   MouseClickDrag($MOUSE_CLICK_LEFT, $CMN_VAL_X, $Y, $CMN_VAL_X+5, $Y)
   Sleep (100)
   Send ("^c")
   $value = ClipGet ()
   sleep (100)
   Send ("{ESC}")
   If (Asc(StringLeft($value, 1)) = 45) Then
      $is_negative = 1
      $value = StringTrimLeft ($value, 1)
   EndIf
   $value_num = Number ($value)

   if ($is_negative = 1) Then
      $value_num = 0 - $value_num
   EndIf

   ;MsgBox (0, "", String($value_num))
   Return ($value_num)
EndFunc




Func Paste_Val ($PARAMETER, $value)
   $Y = 0
   Switch ($PARAMETER)
        Case $EXPOSURE
            $Y = $EXP_VAL_Y
        Case $CONTRAST
            $Y = $CON_VAL_Y
        Case $HIGHLIGHTS
            $Y = $HIG_VAL_Y
        Case $SHADOWS
            $Y = $SHA_VAL_Y
        Case $WHITES
            $Y = $WHI_VAL_Y
        Case $BLACKS
            $Y = $BLK_VAL_Y
        Case $TEMPERATURE
			$Y = $TMP_VAL_Y
   EndSwitch
   MouseClickDrag($MOUSE_CLICK_LEFT, $CMN_VAL_X, $Y, $CMN_VAL_X+5, $Y)
   Sleep (100)
   ClipPut (String ($value))
   Send ("^v")
   sleep (100)
   Send ("{ENTER}")

EndFunc



Func Get_Bubble_X_Pos ($PARAMETER, $current_value)
    $SCALE = 200/2
    If (($PARAMETER = $EXPOSURE) Or ($PARAMETER = $SUBJECT_EXPOSURE)) Then
        $SCALE = 10/2
    EndIf

    $X = $CMN_SL_X_ZERO + Int (($SLIDER_RANGE/2) * $current_value / $SCALE)

    Return ($X)
EndFunc


Func Calc_New_Bubble_X_Pos ($PARAMETER, $value)

   ; Scale factor for all parameters except exposure
    $SCALE = 200/2
    If (($PARAMETER = $EXPOSURE) Or ($PARAMETER = $SUBJECT_EXPOSURE)) Then
	   ; Scale factor for exposure
        $SCALE = 10/2
    EndIf

    ;$value = Read_Val ($PARAMETER)
    $X = $CMN_SL_X_ZERO + Int (($SLIDER_RANGE/2) * $value / $SCALE)

   if ($X > $CMN_SL_X_RIGHT) Then
	  $X = $CMN_SL_X_RIGHT
   EndIf

   if ($X < $CMN_SL_X_LEFT) Then
	  $X = $CMN_SL_X_LEFT
   EndIf

    Return ($X)
EndFunc



Func Set_Val ($PARAMETER, $old_value, $new_value)

    $SCALE = 200/2
	$Y     = 0
    Switch ($PARAMETER)
        Case $EXPOSURE
            $Y = $EXP_SL_Y
            $SCALE = 10/2
        Case $CONTRAST
            $Y = $CON_SL_Y
        Case $HIGHLIGHTS
            $Y = $HIG_SL_Y
        Case $SHADOWS
            $Y = $SHA_SL_Y
        Case $WHITES
            $Y = $WHI_SL_Y
        Case $BLACKS
            $Y = $BLK_SL_Y
		 Case $SUBJECT_EXPOSURE
			$Y = $SELECT_SUBJECT_EXPOSURE_0_Y
			$SCALE = 10/2
		 EndSwitch

    $Bubble_pos = Get_Bubble_X_Pos ($PARAMETER, $old_value)
    $New_bubble_pos = Calc_New_Bubble_X_Pos ($PARAMETER, $new_value)
    Move_Slider ($PARAMETER, $Y, $Bubble_pos, $New_bubble_pos)


EndFunc




Func Scroll_Up ($count)
   ;1. Move the mouse wheel up count times.
   MouseMove ($PANEL_X, $PANEL_Y)
   MouseWheel($MOUSE_WHEEL_UP, $count)
EndFunc

Func Scroll_Down ($count)
   ;1. Move the mouse wheel up count times.
   MouseMove ($PANEL_X, $PANEL_Y)
   MouseWheel($MOUSE_WHEEL_DOWN, $count)
EndFunc

; @TODO Implement this wait function
Func    subject_mask_wait_for_create_new_mask_panel ()
	Return
EndFunc

Func Subject_mask ()

   MouseClick ("LEFT", $MASK_ICON_X, $MASK_ICON_Y)
   Sleep (1500)
   
   ; @TODO Wait for mask window to appear 
   subject_mask_wait_for_create_new_mask_panel ()
   
   MouseClick ("LEFT", $SELECT_SUBJECT_X, $SELECT_SUBJECT_Y)
   Sleep (800)
   MouseClick ("LEFT", $SELECT_SUBJECT_X, $SELECT_SUBJECT_Y)
   ; Wait for subject to be selected.

   Sleep (8000)

   ; @TODO Wait for mask window to appear 
   subject_mask_wait_for_subject_selection ()

   If (Wait_Until_New_Mask_Plus_button_Appears(100) == 0) Then
	  ConsoleWriteError ("New mask button not found when creating subject mask " & @CRLF)
	  Exit (1)
   EndIf

EndFunc


Func Inverse_subject_mask ()
   Subject_mask()
   Send ("^i")
   Sleep (1000)
EndFunc

Func Wait_Until_New_Mask_Plus_button_Appears ($new_mask_button_timeout)

   $second_mask_button_color = 0
   ; Loop while progress bar is running or until timeout
   While ($new_mask_button_timeout > 0)

	  $second_mask_button_color = PixelGetColor ($NEW_MASK_PLUS_BUTTON_X, $NEW_MASK_PLUS_BUTTON_X)
	  $second_mask_button_color_blue_ch = BitAND ($second_mask_button_color, 255)
	  If ($second_mask_button_color_blue_ch < 220) Then
		 ConsoleWrite ("Waiting for second mask button. Timeout = " & String ($new_mask_button_timeout) & @CRLF)
	  Endif

	  If ($new_mask_button_timeout > 0) Then
		 $new_mask_button_timeout = $new_mask_button_timeout - 1
	  EndIf

	  Sleep (100)
   WEnd

   $second_mask_button_color = PixelGetColor ($NEW_MASK_PLUS_BUTTON_X, $NEW_MASK_PLUS_BUTTON_X)
   $second_mask_button_color_blue_ch = BitAND ($second_mask_button_color, 255)
   If ($second_mask_button_color_blue_ch < 220) Then
	  ConsoleWriteError ("Second mask button not found. " & @CRLF)
	  Return (0)
   Endif

   Return (1)

EndFunc


Func Second_Subject_mask ($continuity_mode)

   ; Open subject selection panel
   If ($continuity_mode == 0) Then
	  MouseClick ("LEFT", $MASK_ICON_X, $MASK_ICON_Y)
	  Sleep (600)
   EndIf


   If (Wait_Until_New_Mask_Plus_button_Appears(20) == 0) Then
	  ConsoleWriteError ("Exiting..." & @CRLF)
	  Exit (1)
   EndIf


   MouseClick ("LEFT", $NEW_MASK_PLUS_BUTTON_X, $NEW_MASK_PLUS_BUTTON_Y)
   Sleep (500)

   $NEW_MASK_BACKGROUND_BUTTON_X = 1750
   $NEW_MASK_BACKGROUND_BUTTON_Y = 250

   MouseClick ("LEFT", $NEW_MASK_BACKGROUND_BUTTON_X, $NEW_MASK_BACKGROUND_BUTTON_Y)

   Sleep (2500)

EndFunc


Func Move_Slider ($PARAMETER, $Y, $PREV_POS, $NEW_POS)
#cs
	  If ($NEW_POS > 100) Then
		 $NEW_POS = 100
	  ElseIf ($NEW_POS < -100) Then
		 $NEW_POS = -100
	  EndIf
#ce
;	  MouseClick ($MOUSE_CLICK_LEFT, $SLIDER_RIGHT_EXTREME_X, $Y)
;	  MouseMove ($SLIDER_RIGHT_X, $Y)
;	  $new_slider_pos = $SLIDER_RIGHT_X + Round ($SLIDER_RATE * ($POS - 100), 0)
;	  $new_slider_pos = $new_slider_pos + $SLIDER_OFFSET
	  MouseClickDrag($MOUSE_CLICK_LEFT, $PREV_POS, $Y, $NEW_POS, $Y)
EndFunc





#cs
Func Move_Slider ($PARAMETER, $Y, $POS)

   Switch ($PARAMETER)
        Case $EXPOSURE
            $Y = $EXP_VAL_Y
        Case $CONTRAST
            $Y = $CON_VAL_Y
        Case $HIGHLIGHTS
            $Y = $HIG_VAL_Y
        Case $SHADOWS
            $Y = $SHA_VAL_Y
        Case $WHITES
            $Y = $WHI_VAL_Y
        Case $BLACKS
            $Y = $BLK_VAL_Y
   EndSwitch


	  If ($POS > 100) Then
		 $POS = 100
	  ElseIf ($POS < -100) Then
		 $POS = -100
	  EndIf

	  MouseClick ($MOUSE_CLICK_LEFT, $SLIDER_RIGHT_EXTREME_X, $Y)
	  MouseMove ($SLIDER_RIGHT_X, $Y)
	  $new_slider_pos = $SLIDER_RIGHT_X + Round ($SLIDER_RATE * ($POS - 100), 0)
	  $new_slider_pos = $new_slider_pos + $SLIDER_OFFSET
	  MouseClickDrag($MOUSE_CLICK_LEFT, $SLIDER_RIGHT_X, $Y, $new_slider_pos, $Y)
EndFunc


Func Get_temperature ()
   Return (Read_Val ($TMP_BOX_Y))
EndFunc

Func Get_saturation ()
   Return (Read_Val ($SAT_BOX_Y))
EndFunc

Func Get_vibrance ()
   Return (Read_Val ($BLACKS_BOX_Y))
EndFunc
#ce

Func Is_Lightroom_window_active ()
	If (WinGetTitle ("[ACTIVE]") == "Lightroom" ) Then
		Return 1
	Else
		Return 0
	EndIf	
EndFunc

Func Exit_if_Lightroom_window_not_active ()
	If (Is_Lightroom_window_active () == $FALSE) Then
		MsgBox ($MB_ICONERROR, "Lightroom Not Active", "Lightroom window is not active. Exiting script!")
		Exit()
	Endif
EndFunc

Func Set_Exp ($value)
    $X_POS = Int (($value * ($CMN_SL_X_RIGHT - $CMN_SL_X_LEFT))/10.0)
   ConsoleWrite ("Set exposure")
   Move_Slider ($EXPOSURE_Y, $value * 20)
EndFunc

Func Set_Contrast ($value)
   ConsoleWrite ("Set contrast")
   Move_Slider ($CONTRAST_Y, $value)
EndFunc


Func Set_Highlights ($value)
   ConsoleWrite ("Set highlights")
   Move_Slider ($HIGHLIGHTS_Y, $value)
EndFunc

Func Set_Shadows ($value)
   ConsoleWrite ("Set shadows")
   Move_Slider ($SHADOWS_Y, $value)
EndFunc

Func Set_Whites ($value)
   ConsoleWrite ("Set whites")
   Move_Slider ($WHITES_Y, $value)
EndFunc

Func Set_Blacks ($value)
   ConsoleWrite ("Set blacks")
   Move_Slider ($BLACKS_Y, $value)
EndFunc


Func Set_saturation ($value)
   ConsoleWrite ("Set saturation")
   Move_Slider ($SAT_Y, $value)
EndFunc

Func Set_vibrance ($value)
   ConsoleWrite ("Set vibrance")
   Move_Slider ($VIB_Y, $value)
EndFunc

Func Delta_Exp ($delta_value)
   ConsoleWrite ("Delta exposure")
   Set_Exp (Get_Exp () + $delta_value)
EndFunc

Func Delta_Contrast ($delta_value)
   ConsoleWrite ("Delta contrast")
   Set_Contrast (Get_Contrast () + $delta_value)
EndFunc

Func Delta_Highlights ($delta_value)
   ConsoleWrite ("Delta highlights")
   Set_Highlights (Get_Highlights () + $delta_value)
EndFunc

Func Delta_Shadows ($delta_value)
   ConsoleWrite ("Delta shadows")
   Set_Shadows (Get_Shadows () + $delta_value)
EndFunc

Func Delta_Whites ($delta_value)
   ConsoleWrite ("Delta whites")
   Set_Whites (Get_Whites () + $delta_value)
EndFunc

Func Delta_Blacks ($delta_value)
   ConsoleWrite ("Delta blacks")
   Set_Blacks (Get_Blacks () + $delta_value)
EndFunc

Func Delta_temperature ($delta_value)
   ConsoleWrite ("Delta temperature")
   Scroll_up(20)
   sleep (100)
   Scroll_down(5)
   sleep (100)
   Set_temperature (Get_temperature () + $delta_value/30)
EndFunc

Func Delta_saturation ($delta_value)
   ConsoleWrite ("Delta saturation")
   Scroll_up(20)
   sleep (100)
   Scroll_down(5)
   sleep (100)
   Set_saturation (Get_saturation () + $delta_value)
EndFunc

Func Delta_vibrance ($delta_value)
   ConsoleWrite ("Delta vibrance")
   Scroll_up(20)
   sleep (100)
   Scroll_down(5)
   sleep (100)
   Set_vibrance (Get_vibrance () + $delta_value)
EndFunc

Func Get_overexposed_blacks ()
   Return (PixelGetColor ($HIST_BLACK_SATURATED_X, $HIST_BLACK_SATURATED_Y))
EndFunc

Func Get_overexposed_whites ()
   Return (PixelGetColor ($HIST_WHITE_SATURATED_X, $HIST_WHITE_SATURATED_Y))
EndFunc


Func Is_blacks_overexposed ()

   $color = Get_overexposed_blacks ()

   $R = BitShift (BitAND ($color, 0x0000FF), 0)
   $G = BitShift (BitAND ($color, 0x00FF00), 8)
   $B = BitShift (BitAND ($color, 0xFF0000), 16)

   If ($R > 50) Then
	  Return (1)
   EndIf
   If ($G > 50) Then
	  Return (1)
   EndIf
   If ($B > 50) Then
	  Return (1)
   EndIf

   Return (0)
EndFunc


Func Is_whites_overexposed ()

   $color = Get_overexposed_whites ()

   $R = BitShift (BitAND ($color, 0x0000FF), 0)
   $G = BitShift (BitAND ($color, 0x00FF00), 8)
   $B = BitShift (BitAND ($color, 0xFF0000), 16)

   If ($R > 50) Then
	  Return (1)
   EndIf
   If ($G > 50) Then
	  Return (1)
   EndIf
   If ($B > 50) Then
	  Return (1)
   EndIf

   Return (0)
EndFunc

Func auto_settings ()
   Send ("+a")
   Sleep(500)
EndFunc

Func next_image ()
   Send ("{RIGHT}")
EndFunc

Func prev_image ()
   Send ("{LEFT}")
EndFunc

#cs

L = 0
R = 5
M = 2.5



#ce

Func Auto_exposure ()
	If (Is_whites_overexposed()) Then
		Return 0
	EndIf

	$L = Read_Val($EXPOSURE)
	$old_value = $L
	;MsgBox (0, "", "Current Exp = " & String ($L), 3)
	$R = 5.0

	; Allow a max of 8 steps
	$timeout = 8
	While (($L <= $R) AND $timeout > 0)
		$M = $L + ($R - $L)/2

		 ;MsgBox (0, "", "New Exp = " & String ($M), 3)
		Set_Val($EXPOSURE, $old_value, $M)
		$old_value = $M

		 ; Wait for histogram to respond
		 Sleep (400)
		If (Is_whites_overexposed ()) Then

			$R = $M - 0.02
			;MsgBox (0, "", "overexposed", 2)
		 Else
			;MsgBox (0, "", "underexposed", 2)
			$L = $M + 0.02
		 EndIf

		$timeout = $timeout - 1

		;MsgBox (0, "", String($timeout), 2)
	 WEnd

   Return 1
EndFunc

Func Auto_Blacks ()
	If (Is_blacks_overexposed()) Then
		Return 0
	EndIf

	$R = Read_Val($BLACKS)
	$old_value = $R
	$L = -100
	; Allow a max of 8 steps
	$timeout = 8
	while (($L <= $R) AND $timeout > 0)
		$M = $L + ($R - $L)/2
		Set_Val($BLACKS, $old_value, $M)
		$old_value = $M
		 ; Wait for histogram to respond
		 Sleep (400)
		If (Is_blacks_overexposed ()) Then
		   $L = $M + 2
		Else
			$R = $M - 2
		 EndIf
		$timeout = $timeout - 1
	WEnd

   Return 1
EndFunc


Func Set_Exp_offset ($amount)
   $EXP = Read_Val($EXPOSURE)
   Set_Val($EXPOSURE, $EXP, $EXP + $amount)
   Return 1
EndFunc


Func read_histogram_profile()

	Return $FALSE
EndFunc

; @TODO Implement this function
; WIP
Func smart_exposure_offset ()

	$amount = read_histogram_profile()

	if ( $amount <> 0 ) Then
		Set_Exp_offset ($amount)
	EndIf	

	Return $FALSE

EndFunc



Func Inv_subject_blacks_reduction ($amount)

   Inverse_subject_mask ()

   ; Reduce blacks
   MouseClickDrag($MOUSE_CLICK_LEFT, $SELECT_SUBJECT_BLACKS_0_X, $SELECT_SUBJECT_BLACKS_0_Y, $SELECT_SUBJECT_BLACKS_NEG_25_X, $SELECT_SUBJECT_BLACKS_NEG_25_Y)

   Sleep (100)
   ; Increase contrast
   MouseClickDrag($MOUSE_CLICK_LEFT, $SELECT_SUBJECT_CONTRAST_0_X, $SELECT_SUBJECT_CONTRAST_0_Y, $SELECT_SUBJECT_CONTRAST_30_X, $SELECT_SUBJECT_CONTRAST_30_Y)

   Sleep (1000)
   ; Select another pane
   MouseClick ("LEFT", 1896, 124)
   Sleep (1000)

EndFunc


Func subject_texture_reduction ($exp_amount, $texture_amount, $continuity_mode)

   Subject_mask()

   if (($exp_amount >= -4) And ($exp_amount <= 4) And ($exp_amount <> 0)) Then
	  $SELECT_SUBJECT_amount_X = $CMN_SL_X_LEFT + (($exp_amount + 4) * $SLIDER_RANGE)/8

	  ; Reduce exposure
	  MouseClickDrag($MOUSE_CLICK_LEFT, $SELECT_SUBJECT_TEXTURE_0_X, $SELECT_SUBJECT_EXPOSURE_0_Y, $SELECT_SUBJECT_amount_X, $SELECT_SUBJECT_EXPOSURE_0_Y)
   Endif


   if (($texture_amount >= -100) And ($texture_amount <= 100) And ($texture_amount <> 0) ) Then
	  Panel_Scroll_down(30)

	  $SELECT_SUBJECT_amount_X = $CMN_SL_X_LEFT + (($texture_amount + 100) * $SLIDER_RANGE)/200

	  ; Reduce texture
	  MouseClickDrag($MOUSE_CLICK_LEFT, $SELECT_SUBJECT_TEXTURE_0_X, $SELECT_SUBJECT_TEXTURE_0_Y, $SELECT_SUBJECT_amount_X, $SELECT_SUBJECT_TEXTURE_0_Y)

	  Sleep (100)
	  Panel_Scroll_up(30)
   EndIf

   Sleep (200)

   If ($continuity_mode == 0) Then
	  ; Select EDIT pane
	  MouseClick ("LEFT", 1900, 165)
	  Sleep (1000)
   EndIf

EndFunc



Func Min_highlights ()

   $old_value = Read_Val($HIGHLIGHTS)
   Set_Val($HIGHLIGHTS, $old_value, -100)

EndFunc

Func check_if_pixel_color_matches ($x, $y, $target_color)

   Local $blue_channel  = 0
   Local $green_channel = 0
   Local $red_channel   = 0
   Local $target_blue_channel  = 0
   Local $target_green_channel = 0
   Local $target_red_channel   = 0
   Local $is_pixel_color_matched = 0

	Local $color = PixelGetColor ( $x , $y )

   if ($color = -1) Then
	  my_log ($LOG_FATAL, "check_if_pixel_color_matches: Invalid co-ordinates " & String ($x) & " " & String ($y))
	  Exit()
   Else
	   ;-----------------------------------------------------------------------
	   ; For Debugging 
	   ;-----------------------------------------------------------------------
		; my_log ($LOG_INFO, "check_if_pixel_color_matches: pixel color = " & String (Hex ($color, 6)) & " Blue channel = " & String(BitAND ($color, 0x0000FF)))	
		; MsgBox (0, "", "check_if_pixel_color_matches: pixel color = " & String (Hex ($color, 6)) & " Target color = " & String(Hex (BitAND ($target_color, 0xFFFFFF))))
	   ;-----------------------------------------------------------------------

   Endif

   $blue_channel  = BitAND ($color, 0x0000FF)
   $green_channel = BitAND ($color, 0x0000FF)
   $red_channel   = BitAND ($color, 0x0000FF)
   
   $target_blue_channel  = BitAND ($target_color, 0x0000FF)
   $target_green_channel = BitAND ($target_color, 0x0000FF)
   $target_red_channel   = BitAND ($target_color, 0x0000FF)

	;                   Blue channel                                                                             Green channel                                                                                             Red channel
	if ( ($blue_channel > ($target_blue_channel - 5)) AND ($blue_channel < ($target_blue_channel + 5)) AND ($green_channel > ($target_green_channel - 5)) AND ($green_channel < ($target_green_channel + 5)) AND ($red_channel > ($target_red_channel - 5)) AND ($red_channel < ($target_red_channel + 5)) ) Then
	    $is_pixel_color_matched = $TRUE
	Else
		$is_pixel_color_matched = $FALSE
	EndIf

	Return $is_pixel_color_matched

EndFunc


Func ai_denoise_is_denoise_button_active ()

	;-------------------------------------------------------------
	; Denoise greyed out:
	;-------------------------------------------------------------

	Local $CENTER_OF_BIG_STAR_X                = 1631 
	Local $CENTER_OF_BIG_STAR_Y                = 817
	Local $COLOR_OF_CENTER_OF_BIG_STAR         = 0x6B6B6B

	Local $CENTER_OF_UPPER_SMALL_STAR_X        = 1637
	Local $CENTER_OF_UPPER_SMALL_STAR_Y        = 814 
	Local $COLOR_OF_CENTER_OF_UPPER_SMALL_STAR = 0x676767

	Local $CENTER_OF_LOWER_SMALL_STAR_X        = $CENTER_OF_UPPER_SMALL_STAR_X
	Local $CENTER_OF_LOWER_SMALL_STAR_Y        = 820
	Local $COLOR_OF_CENTER_OF_LOWER_SMALL_STAR = $COLOR_OF_CENTER_OF_UPPER_SMALL_STAR

	Local $UPPER_TIP_OF_BIG_STAR_X             = $CENTER_OF_BIG_STAR_X
	Local $UPPER_TIP_OF_BIG_STAR_Y             = $CENTER_OF_UPPER_SMALL_STAR_Y 
	Local $COLOR_OF_UPPER_TIP_OF_BIG_STAR      = 0x2C2C2C

	Local $is_ai_denoise_button_greyed_out = ( (check_if_pixel_color_matches ($CENTER_OF_BIG_STAR_X,         $CENTER_OF_BIG_STAR_Y,         $COLOR_OF_CENTER_OF_BIG_STAR)         == $TRUE) And (check_if_pixel_color_matches ($CENTER_OF_UPPER_SMALL_STAR_X, $CENTER_OF_UPPER_SMALL_STAR_Y, $COLOR_OF_CENTER_OF_UPPER_SMALL_STAR) == $TRUE) And (check_if_pixel_color_matches ($CENTER_OF_LOWER_SMALL_STAR_X, $CENTER_OF_LOWER_SMALL_STAR_Y, $COLOR_OF_CENTER_OF_LOWER_SMALL_STAR) == $TRUE) And (check_if_pixel_color_matches ($UPPER_TIP_OF_BIG_STAR_X,      $UPPER_TIP_OF_BIG_STAR_Y,      $COLOR_OF_UPPER_TIP_OF_BIG_STAR)      == $TRUE) )

	;-------------------------------------------------------------
	; Denoise available:
	;-------------------------------------------------------------

	$CENTER_OF_BIG_STAR_X                      = 1631 
	$CENTER_OF_BIG_STAR_Y                      = 802
	$COLOR_OF_CENTER_OF_BIG_STAR               = 0xE1E1E1
											   
	$CENTER_OF_UPPER_SMALL_STAR_X              = 1637
	$CENTER_OF_UPPER_SMALL_STAR_Y              = 799
	$COLOR_OF_CENTER_OF_UPPER_SMALL_STAR       = 0xD8D8D8
											   
	$CENTER_OF_LOWER_SMALL_STAR_X              = $CENTER_OF_UPPER_SMALL_STAR_X
	$CENTER_OF_LOWER_SMALL_STAR_Y              = 805
	$COLOR_OF_CENTER_OF_LOWER_SMALL_STAR       = $COLOR_OF_CENTER_OF_UPPER_SMALL_STAR
											   
	$UPPER_TIP_OF_BIG_STAR_X                   = $CENTER_OF_BIG_STAR_X
	$UPPER_TIP_OF_BIG_STAR_Y                   = $CENTER_OF_UPPER_SMALL_STAR_Y 
	$COLOR_OF_UPPER_TIP_OF_BIG_STAR            = 0x4C4C4C

	; First check if denoise button is greyed out
	If ($is_ai_denoise_button_greyed_out) Then
	
		MsgBox ($MB_ICONWARNING, "Not available", "AI Denoise is not available!", 2)
		Return $FALSE

	; else if denoise button is active		
	ElseIf ( (check_if_pixel_color_matches ($CENTER_OF_BIG_STAR_X,         $CENTER_OF_BIG_STAR_Y,         $COLOR_OF_CENTER_OF_BIG_STAR)         == $TRUE) And (check_if_pixel_color_matches ($CENTER_OF_UPPER_SMALL_STAR_X, $CENTER_OF_UPPER_SMALL_STAR_Y, $COLOR_OF_CENTER_OF_UPPER_SMALL_STAR) == $TRUE) And	(check_if_pixel_color_matches ($CENTER_OF_LOWER_SMALL_STAR_X, $CENTER_OF_LOWER_SMALL_STAR_Y, $COLOR_OF_CENTER_OF_LOWER_SMALL_STAR) == $TRUE) And (check_if_pixel_color_matches ($UPPER_TIP_OF_BIG_STAR_X,      $UPPER_TIP_OF_BIG_STAR_Y,      $COLOR_OF_UPPER_TIP_OF_BIG_STAR)      == $TRUE) ) Then
		 
		Return $TRUE
	; else throw error
	Else
		;my_log ($LOG_ERROR, "ai_denoise_is_denoise_button_active: Failed to match denoise button")
		MsgBox ($MB_ICONERROR, "AI Denoise Button Error", "ai_denoise_is_denoise_button_active: Failed to match denoise button")
		Exit()
	EndIf

EndFunc

Func wait_until_pixel_color_matches ($x, $y, $target_color, $timeout_seconds )

   Local $blue_channel  = 0
   Local $green_channel = 0
   Local $red_channel   = 0
   Local $target_blue_channel  = 0
   Local $target_green_channel = 0
   Local $target_red_channel   = 0
   Local $is_pixel_color_matched = $FALSE
   
   If ($timeout_seconds = 0) Then
       $timeout_seconds = 300 ; default timeout of 5 minutes 
   Endif
	   

   Local $timeout_milliseconds = $timeout_seconds * 1000
   Local $wait_time_per_loop = 100; milliseconds
   
   Local $wait_count = 0

   while ($is_pixel_color_matched = $FALSE And $timeout_milliseconds > 0)
   
		$is_pixel_color_matched = check_if_pixel_color_matches ($x, $y, $target_color)
		
		Sleep ($wait_time_per_loop)
		$timeout_milliseconds = $timeout_milliseconds - $wait_time_per_loop;
	WEnd
	
	Return $is_pixel_color_matched

EndFunc

Func ai_denoise_wait_while_progress_bar_is_active ()


   Local $hStarttime = _Timer_Init()

   Local $AI_DENOISE_INITIAL_SLEEP_DURATION_SECONDS = 2

    ; Wait for progress bar to appear
	Sleep ($AI_DENOISE_INITIAL_SLEEP_DURATION_SECONDS * 1000);

	; Check starting point
   Local $DENOISE_PROGRESS_BAR_LEFT_X = 146
   Local $DENOISE_PROGRESS_BAR_Y = 77
   
   Local $x = $DENOISE_PROGRESS_BAR_LEFT_X
   Local $y = $DENOISE_PROGRESS_BAR_Y
   
   Local $pixel_matched = $FALSE
   
   ; This timeout is to ensure progress bar is detected
   Local $AI_DENOISE_PROGRESS_BAR_APPEARANCE_TIMEOUT_SECONDS = 15
   
   ; Time timeout is a safety timer for progress bar to end i.e. it exits the script if progress bar is stuck
   Local $AI_DENOISE_PROGRESS_BAR_COMPLETE_TIMEOUT_SECONDS = 10 * 60
   
   Local $progress_bar_complete_timeout = $AI_DENOISE_PROGRESS_BAR_COMPLETE_TIMEOUT_SECONDS

                                                                          ; RGB Expected value of blue progress bar = 230, 115, 20. Pack into 3x8bit format
	$pixel_matched = wait_until_pixel_color_matches ($DENOISE_PROGRESS_BAR_LEFT_X, $DENOISE_PROGRESS_BAR_Y, ((20 * 256 ) + 115 ) * 256 + 230, $AI_DENOISE_PROGRESS_BAR_APPEARANCE_TIMEOUT_SECONDS)

   ; Wait until the progress bar is active OR until AI_DENOISE_PROGRESS_BAR_COMPLETE_TIMEOUT_SECONDS timeout
	while ($pixel_matched = 1 And $progress_bar_complete_timeout > 0)
																			  ; RGB Expected value of blue progress bar = 230, 115, 20. Pack into 3x8bit format
		$pixel_matched = check_if_pixel_color_matches ($DENOISE_PROGRESS_BAR_LEFT_X, $DENOISE_PROGRESS_BAR_Y, ((20 * 256 ) + 115 ) * 256 + 230)

		; Wait for 1 second
		$progress_bar_complete_timeout = $progress_bar_complete_timeout - 1
		Sleep (1000)
	
	WEnd

;	my_log ($LOG_INFO, "AI Denoise: Exit")

EndFunc

Func ai_denoise_wait_while_enhance_panel_appears ($DENOISE_PANEL_ENHANCE_X, $DENOISE_PANEL_ENHANCE_Y)

	Local $AI_DENOISE_ENHANCE_PANEL_APPEARANCE_TIMEOUT_SECONDS = 15
                                                                             ; RGB Expected value of blue progress bar = 230, 115, 20. Pack into 3x8bit format
   $pixel_matched = wait_until_pixel_color_matches ($DENOISE_PANEL_ENHANCE_X, $DENOISE_PANEL_ENHANCE_Y, ((20 * 256 ) + 115 ) * 256 + 230, $AI_DENOISE_ENHANCE_PANEL_APPEARANCE_TIMEOUT_SECONDS)

   if ($pixel_matched = 0) Then
   		my_log ($LOG_ERROR, "Timeout: AI denoise failed to detect enhance button")
		Exit(1)
   Endif
   Sleep (200) 

EndFunc

#cs

UNUSED

Func ai_denoise_wait_while_progress_bar_is_active ()

   Local $hStarttime = _Timer_Init()

   Local $AI_DENOISE_INITIAL_SLEEP_DURATION_SECONDS = 3

    ; Wait for progress bar to appear
	Sleep ($AI_DENOISE_INITIAL_SLEEP_DURATION_SECONDS * 1000);

	; Check starting point
   Local $DENOISE_PROGRESS_BAR_LEFT_X = 146
   Local $DENOISE_PROGRESS_BAR_Y = 77
   
   Local $x = $DENOISE_PROGRESS_BAR_LEFT_X
   Local $y = $DENOISE_PROGRESS_BAR_Y

   Local $blue_channel  = 0
   Local $green_channel = 0
   Local $red_channel    = 0
   Local $is_pixel_color_matched = $FALSE
   Local $wait_count = 0
   
   while ($is_pixel_color_matched = $TRUE)
   
	   Local $color = PixelGetColor ( $x , $y )
	   
	   if ($color = -1) Then
		  my_log ($LOG_FATAL, "ai_denoise_wait_while_progress_bar_is_active: Invalid co-ordinates " & String ($x) & " " & String ($y))
		  Exit()
	   Else
			;my_log ($LOG_INFO, "ai_denoise_wait_while_progress_bar_is_active: pixel color = " & String (Hex ($color, 6)) & " Blue channel = " & String(BitAND ($color, 0x0000FF)))
	   Endif
	   
	   Local $blue_channel  = BitAND ($color, 0x0000FF)  ; Expected value = 230
	   Local $green_channel = BitAND ($color, 0x0000FF)  ; Expected value = 115
	   Local $red_channel   = BitAND ($color, 0x0000FF)  ; Expected value = 20
	   Local $is_pixel_color_matched = $FALSE
   
		;                   Blue channel                                            Green channel                                         Red channel
		if ( ($blue_channel > 225) AND ($blue_channel < 235) AND ($green_channel > 110) AND ($green_channel < 120) AND ($red_channel > 15) AND ($red_channel < 25) ) Then
		    $is_pixel_color_matched = $TRUE
		Else
			$is_pixel_color_matched = $FALSE
		EndIf
			
		Sleep (100)
		$wait_count = $wait_count + 1
		
		if (Mod ($wait_count, 10) = 0) Then
			my_log ($LOG_FATAL, "ai_denoise_wait_while_progress_bar_is_active: AI denoise running  " & String (($AI_DENOISE_INITIAL_SLEEP_DURATION_SECONDS + $wait_count) / 10) & " seconds")
		EndIf
   WEnd

	my_log ($LOG_INFO, "ai_denoise_wait_while_progress_bar_is_active: Done. AI denoise took " & String(_Timer_Diff($hStarttime)/1000) & " seconds")
   
   ; Unused 
   Local $DENOISE_PROGRESS_BAR_RIGHT_X = 331
   Local $DENOISE_PROGRESS_BAR_Y = 77

	; Unused
   Local $x = $DENOISE_PROGRESS_BAR_RIGHT_X
   Local $y = $DENOISE_PROGRESS_BAR_Y

	; Wait for things to settle down
	Sleep (2000)

EndFunc
#ce


Func _AI_Denoise ()

	Local $DENOISE_PANEL_OPEN_DELAY_SEC = 1

	;my_log ($LOG_INFO, "AI Denoise: Entry")

   ; Move the mouse pointer to right edit panel
   Mousemove ($PANEL_X, $PANEL_Y)

   ; Scroll down on the panel until Denoise button
   Panel_Scroll_down (54)

	;-------------------------------------
	Exit_if_Lightroom_window_not_active ()
	;-------------------------------------

	;----------------------------------------------------------------------
	; WIP: Disabling this code for now
	;----------------------------------------------------------------------
	#cs
   ; Is AI denoise button available? 
   If (ai_denoise_is_denoise_button_active () = $FALSE) Then
	  MsgBox ($MB_ICONWARNING, "Skipping AI Denoise", "Denoise already applied to this image. Skipping!", 1)
	  
	     ; Scroll up to restore the default panel position
		Panel_Scroll_up (70)
      Return
   Endif
   #ce

   ; Denoise button coordinates after scroll down
   $DENOISE_X = 1660
   $DENOISE_Y = 820

   ; Click Denoise and wait
   MouseClick ($MOUSE_CLICK_LEFT, $DENOISE_X, $DENOISE_Y)

   Sleep ($DENOISE_PANEL_OPEN_DELAY_SEC * 1000)

   $DENOISE_PANEL_ENHANCE_X = 1312
   $DENOISE_PANEL_ENHANCE_Y= 775

	my_log ($LOG_INFO, "AI Denoise: Will wait for enhance panel")

   ; Wait until Enhance panel opens up. Detect the blue "Enhance" button
   ai_denoise_wait_while_enhance_panel_appears ($DENOISE_PANEL_ENHANCE_X, $DENOISE_PANEL_ENHANCE_Y)

	;-------------------------------------
	Exit_if_Lightroom_window_not_active ()
	;-------------------------------------

   MouseClick ($MOUSE_CLICK_LEFT, $DENOISE_PANEL_ENHANCE_X, $DENOISE_PANEL_ENHANCE_Y)

   ; // @TODO ensure "STACK" option is turned off on panel
   
	my_log ($LOG_INFO, "AI Denoise: Will wait for progress bar")
   
   ; Wait until progress bar finishes
   ai_denoise_wait_while_progress_bar_is_active ()

	;-------------------------------------
	Exit_if_Lightroom_window_not_active ()
	;-------------------------------------

	;my_log ($LOG_INFO, "AI Denoise: Exit")

   ; Scroll up to restore the default panel position
   Panel_Scroll_up (70)

   $DUMMY_RIGHT_PANEL_CLICK_X = 1900
   $DUMMY_RIGHT_PANEL_CLICK_Y = 500
   MouseClick ("LEFT", $DUMMY_RIGHT_PANEL_CLICK_X, $DUMMY_RIGHT_PANEL_CLICK_Y)

#cs

   $DENOISE_RUNNING = 1
   $DENOISE_TIMEOUT_MIN = 15
   $DENOISE_TIMEOUT_SEC = $DENOISE_TIMEOUT_MIN * 60


   ; // @TODO Is this needed?

   ; Track progress bar for AI denoise. It is repeated once again
   ; because the progress bar disappears and appears again to save
   ; the enhanced RAW file.
   For $i = 1 To 2 Step 1
	   ; Loop while progress bar is running or until timeout
	   While ($DENOISE_RUNNING == 1)

		  $denoise_progress_bar_color = PixelGetColor ($DENOISE_PROGRESS_BAR_LEFT_X, $DENOISE_PROGRESS_BAR_Y)
		  $denoise_progress_bar_color_blue_ch = BitAND ($denoise_progress_bar_color, 255)
		  If ($denoise_progress_bar_color_blue_ch < 220) Then
			  $DENOISE_RUNNING = 0
		  Endif
		  ;MsgBox (0, "Denoise Running", "Progress Bar color = " & String ($denoise_progress_bar_color_blue_ch), 3)
		  Sleep (3000)
		  ; Decrement by 3 seconds. This value is always divisible by 3
		  $DENOISE_TIMEOUT_SEC = $DENOISE_TIMEOUT_SEC - 3

		  If ($DENOISE_TIMEOUT_SEC == 0) Then
			  $DENOISE_RUNNING = 0
		  Endif
	   WEnd
	   ; Add a delay after thr first progress bar completes to wait for second
	   ; progress bar to appear.
	   if ($i == 1) Then
			;MsgBox (0, "Denoise Running", "Waiting 10 seconds for second progress bar", 10)
			Sleep (10 * 1000)
		EndIf
   Next

   ; Scroll up to restore the default panel position
   Panel_Scroll_up (70)

   $DUMMY_RIGHT_PANEL_CLICK_X = 1900
   $DUMMY_RIGHT_PANEL_CLICK_Y = 500
   MouseClick ("LEFT", $DUMMY_RIGHT_PANEL_CLICK_X, $DUMMY_RIGHT_PANEL_CLICK_Y)
   ;Sleep (4000) <- slow
   Sleep (2000)

   ; Mark current image as rejected.
   ;Send ("x")
#ce

EndFunc


; First mask must have processed already
; $param -> Array of parameters (exposure, saturation etc.) to  be modified
; param[0] has the count
; $value -> Target values for the above params
; $continuity_mode -> Assumes that the mask window is already open
Func Second_Mask_Create_And_Modify ($param, $value, $continuity_mode)
   $num_of_params = $param[0]

   If ($num_of_params = 0) Then
	  Return
   EndIf

   Second_Subject_mask($continuity_mode)

   For $i = 1 To $num_of_params Step 1

	  If ($param[$i] = $EXPOSURE) Then

		 if (($value[$i] >= -4) And ($value[$i] <= 4)) Then
			$SELECT_SUBJECT_amount_X = $CMN_SL_X_LEFT + Int((($value[$i] + 4) * $SLIDER_RANGE)/8)
			#cs
			ConsoleWrite (@CRLF&"Exp amount = " & String ($value[$i]))
			ConsoleWrite (@CRLF&"Exp zero = " & String ($CMN_SL_X_LEFT + Int($SLIDER_RANGE)/2))
			ConsoleWrite (@CRLF&"Exp position = " & String ($SELECT_SUBJECT_amount_X))
			ConsoleWrite (@CRLF&"Exp SLIDER_RANGE = " & String ((($value[$i] + 4) * $SLIDER_RANGE)/8) & @CRLF)
			#ce

			MouseClickDrag($MOUSE_CLICK_LEFT, $CMN_SL_X_LEFT + Int($SLIDER_RANGE)/2, $SELECT_SUBJECT_EXPOSURE_0_Y, $SELECT_SUBJECT_amount_X, $SELECT_SUBJECT_EXPOSURE_0_Y)
		 Endif


		 #cs
		 handles these:

		 $CONTRAST      = 2
		 $HIGHLIGHTS    = 3
		 $SHADOWS       = 4
		 $WHITES        = 5
		 $BLACKS        = 6
		 #ce
	  ElseIf ($param[$i] > $EXPOSURE) And ($param[$i] <= $BLACKS) Then

		 $SELECT_SUBJECT_0_Y = $SELECT_SUBJECT_EXPOSURE_0_Y + 45 * ($param[$i] - 1)
		 $SELECT_SUBJECT_0_X = $CMN_SL_X_ZERO
		 if (($value[$i] >= -100) And ($value[$i] <= 100)) Then

			$SELECT_SUBJECT_amount_X = $CMN_SL_X_LEFT + Int((($value[$i] + 100) * $SLIDER_RANGE)/200)

			; Modify value
			MouseClickDrag($MOUSE_CLICK_LEFT, $CMN_SL_X_LEFT, $SELECT_SUBJECT_0_Y, $SELECT_SUBJECT_amount_X, $SELECT_SUBJECT_0_Y)

			Sleep (100)
		 EndIf

		 #cs
		 handles these:

		 $TEMPERATURE   = 7
		 $TINT          = 8
		 $HUE           = 9
		 $SATURATION    = 10
		 #ce

	  ElseIf ($param[$i] >= $TEMPERATURE) And ($param[$i] <= $SATURATION) Then

		 if (($value[$i] >= -100) And ($value[$i] <= 100)) Then
			Panel_Scroll_down(10)

			$SELECT_SUBJECT_amount_X = $CMN_SL_X_LEFT + (($value[$i] + 100) * $SLIDER_RANGE)/200

			If ($param[$i] == $TEMPERATURE) Then
			   ; Modify temp
			   MouseClickDrag($MOUSE_CLICK_LEFT, $CMN_SL_X_ZERO, $SELECT_SUBJECT_TEMPERATURE_0_Y, $SELECT_SUBJECT_amount_X, $SELECT_SUBJECT_TEMPERATURE_0_Y)
			ElseIf ($param[$i] == $TINT) Then
			   ; Modify tint
			   MouseClickDrag($MOUSE_CLICK_LEFT, $CMN_SL_X_ZERO, $SELECT_SUBJECT_TINT_0_Y, $SELECT_SUBJECT_amount_X, $SELECT_SUBJECT_TINT_0_Y)
			ElseIf ($param[$i] == $HUE) Then
			   ; Modify hue
			   MouseClickDrag($MOUSE_CLICK_LEFT, $CMN_SL_X_ZERO, $SELECT_SUBJECT_HUE_0_Y, $SELECT_SUBJECT_amount_X, $SELECT_SUBJECT_HUE_0_Y)
			ElseIf ($param[$i] == $SATURATION) Then
			   ; Modify saturation
			   MouseClickDrag($MOUSE_CLICK_LEFT, $CMN_SL_X_ZERO, $SELECT_SUBJECT_SATURATION_0_Y, $SELECT_SUBJECT_amount_X, $SELECT_SUBJECT_SATURATION_0_Y)
			EndIf
			Sleep (100)
			Panel_Scroll_up(15)
		 EndIf

	  EndIf
	  Sleep (800)

   Next

   ; Select EDIT pane
   MouseClick ("LEFT", 1900, 165)
   Sleep (1000)

EndFunc


Func Set_temperature ($offset_value)

   $value = Read_Val ($TEMPERATURE)
   ConsoleWrite ("Current temperature: " & String ($value) & @CRLF & " New temperature: " & String ($value + $offset_value) & @CRLF)
   Paste_Val ($TEMPERATURE, $value + $offset_value)

EndFunc





;Sleep (6000)
;Auto_exposure()
;Auto_Blacks()