#Include ../std/ENV.ahk
#Include KeyboardLayout.ahk
; https://www.autohotkey.com/board/topic/55921-multiple-keyboards-workaround/
; Laptop top row, passthrough for modifiers

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
#F1::Send {F1}
#F2::Send {F2}
#F3::Send {F3}

; Arrow keys
>^Up::Send {PgUp}
+>^Up::Send +{PgUp}
>^Down::Send {PgDn}
+>^Down::Send +{PgDn}

>^Left::
    if isLeftToRight()
        Send {Home}
    else
        Send {End}
return

+>^Left::
    if isLeftToRight()
        Send +{Home}
    else
        Send +{End}
return

>^Right::
    if isLeftToRight()
        Send {End}
    else
        Send {Home}
Return

+>^Right::
    if isLeftToRight()
        Send +{End}
    else
        Send +{Home}
Return