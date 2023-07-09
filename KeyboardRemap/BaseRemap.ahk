#Include ../std/ENV.ahk
#Include KeyboardLayout.ahk
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
F1::Send {Volume_Mute}
F2::Send {Volume_Down}
F3::Send {Volume_Up}
; compatible with mouse without borders
#F1::F1
#F2::F2
#F3::F3

; Arrow keys
>^Up::Send {PgUp}
+>^Up::Send +{PgUp}
>^Down::Send {PgDn}
+>^Down::Send +{PgDn}

~*RControl::
~*RControl Up::
    rctrl_state := GetKeyState("RCtrl")
return
~*LControl::
~*LControl Up::
    lctrl_state := GetKeyState("LCtrl")
return
~*RShift::
~*LShift::
~*LShift Up::
~*RShift Up::
    shift_state := GetKeyState("LShift") + GetKeyState("RShift")
return
~*LAlt::
~*LAlt Up::
    alt_state := GetKeyState("LAlt")
return
~*LWin::
~*LWin Up::
    winkey_state := GetKeyState("LWin")
return

*Left::
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

*Right::
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
