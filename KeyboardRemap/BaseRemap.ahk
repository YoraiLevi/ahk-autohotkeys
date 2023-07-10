#Include ../std/ENV.ahk
#Include KeyboardLayout.ahk
#Persistent

; https://www.autohotkey.com/board/topic/55921-multiple-keyboards-workaround/
; Laptop top row, passthrough for modifiers

; requires because of mouse without borders
rctrl_state := 0 ; good assumption
lctrl_state := 0 ; good assumption
shift_state := 0 ; good assumption
alt_state := 0 ; good assumption
winkey_state := 0 ; good assumption

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
; Volume_Mute::F1
; Volume_Down::F2
; Volume_Up::F3
$F1::Volume_Mute
$F2::Volume_Down
$F3::Volume_Up
; compatible with mouse without borders
$#F1::F1
$#F2::F2
$#F3::F3

~*RControl::
~*RControl Up::
    rctrl_state := GetKeyState("RCtrl")
    ; ToolTip, % "RControl " rctrl_state
return
~*LControl::
    MouseGetPos,,,guideUnderCursor
    WinActivate, ahk_id %guideUnderCursor% ; activate the window under the cursor
~*LControl Up::
    lctrl_state := GetKeyState("LCtrl")
    ; ToolTip, % "LControl " lctrl_state
return
~*RShift::
~*LShift::
~*LShift Up::
~*RShift Up::
    shift_state := GetKeyState("LShift") + GetKeyState("RShift")
    ; ToolTip, % "Shift " shift_state
return
~*LAlt::
~*LAlt Up::
    alt_state := GetKeyState("LAlt")
    ; ToolTip, % "Alt " alt_state
return
~*LWin::
~*LWin Up::
    winkey_state := GetKeyState("LWin")
    ; ToolTip, % "Win " winkey_state
return

; Arrow keys
*$Up::
    if rctrl_state {
        if shift_state {
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
    if rctrl_state {
        if shift_state {
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
    if rctrl_state {
        if shift_state {
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
    if rctrl_state {
        if shift_state {
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
