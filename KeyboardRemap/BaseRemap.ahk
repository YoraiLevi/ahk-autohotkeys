#Include ../std/ENV.ahk
#Include KeyboardLayout.ahk
#Persistent

; https://www.autohotkey.com/board/topic/55921-multiple-keyboards-workaround/
; Laptop top row, passthrough for modifiers

; ; requires because of mouse without borders
; global rctrl_state := 0 ; good assumption
; global lctrl_state := 0 ; good assumption
; global shift_state := 0 ; good assumption
; global alt_state := 0 ; good assumption
; global winkey_state := 0 ; good assumption

isLeftToRight(){
    if !LangID := GetKeyboardLanguage(WinActive("A"))
    {
        MsgBox, % "GetKeyboardLayout function failed " ErrorLevel
        return
    }
    if (LangID = 0x0409){
        ; msgbox, Language is EN
        return True
    }
    else if (LangID = 0x040D)
    {
        return False
        ; msgbox, Language is HE
    }
}
tooltipState(){
    ToolTip, % "GetKeyState`nRControl " GetKeyState("RCtrl") "`nLControl " GetKeyState("LCtrl") "`nShift " GetKeyState("LShift") + GetKeyState("RShift") "`nAlt " GetKeyState("LAlt") "`nWin " GetKeyState("LWin")
}
; Volume_Down::F2
; Volume_Mute::F1
; Volume_Up::F3
$F1::Volume_Mute
$F2::Volume_Down
$F3::Volume_Up
; compatible with mouse without borders
$#F1::F1
$#F2::F2
$#F3::F3

; ~*RControl::
; ~*RControl Up::
;     rctrl_state := GetKeyState("RCtrl")
;     tooltipState()
; ; ToolTip, % "RControl " rctrl_state
; return
; ~*LControl::
; ; MouseGetPos,,,guideUnderCursor
; ; WinActivate, ahk_id %guideUnderCursor% ; activate the window under the cursor
; ~*LControl Up::
;     lctrl_state := GetKeyState("LCtrl")
;     tooltipState()
; ; ToolTip, % "LControl " lctrl_state
; return
; ~*RShift::
; ~*LShift::
; ~*LShift Up::
; ~*RShift Up::
;     shift_state := GetKeyState("LShift") + GetKeyState("RShift")
;     tooltipState()
; ; ToolTip, % "Shift " shift_state
; return
; ~*LAlt::
; ~*LAlt Up::
;     alt_state := GetKeyState("LAlt")
;     tooltipState()
; ; ToolTip, % "Alt " alt_state
; return
; ~*LWin::
; ~*LWin Up::
;     winkey_state := GetKeyState("LWin")
;     tooltipState()
; ; ToolTip, % "Win " winkey_state
; return

; Arrow keys
*$Up::
    tooltipState()
    if GetKeyState("RCtrl") {
        if GetKeyState("LShift") + GetKeyState("RShift") {
            Send +{PgUp}
        }
        else {
            Send {PgUp}
        }
    }
    else
        Send {Blind}{Up}
return

*$Down::
    tooltipState()
    if GetKeyState("RCtrl") {
        if GetKeyState("LShift") + GetKeyState("RShift") {
            Send +{PgDn}
        }
        else {
            Send {PgDn}
        }
    }
    else
        Send {Blind}{Down}
return

*$Left::
    tooltipState()
    if GetKeyState("RCtrl") {
        if GetKeyState("LShift") + GetKeyState("RShift") {
            if isLeftToRight()
                Send +{Home}
            else
                Send +{End}
        }
        else{
            if isLeftToRight()
                Send {Home}
            else
                Send {End}
        }
    }
    else
        Send {Blind}{Left}
return

*$Right::
    tooltipState()
    if GetKeyState("RCtrl") {
        if GetKeyState("LShift") + GetKeyState("RShift") {
            if isLeftToRight()
                Send +{End}
            else
                Send +{Home}
        }
        else{
            if isLeftToRight()
                Send {End}
            else
                Send {Home}
        }
    }
    else
        Send {Blind}{Right}
return
