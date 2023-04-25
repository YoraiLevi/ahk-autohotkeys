#Include ../std/ENV.ahk
#Include ./ChromeExtraHotkeys.ahk
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
F1::Volume_Mute
F2::Volume_Down
F3::Volume_Up
#F1::Send {F1}
#F2::Send {F2}
#F3::Send {F3}

; Arrow keys
*>^Up::Send {Blind}{RControl Up}{PgUp}{RControl Down}
*>^Down::Send {Blind}{RControl Up}{PgDn}{RControl Down}

*>^Left::
    if isLeftToRight()
        Send {Blind}{RControl Up}{Home}{RControl Down}
    else
        Send {Blind}{RControl Up}{End}{RControl Down}
return

*>^Right::
    if isLeftToRight()
        Send {Blind}{RControl Up}{End}{RControl Down}
    else
        Send {Blind}{RControl Up}{Home}{RControl Down}
Return