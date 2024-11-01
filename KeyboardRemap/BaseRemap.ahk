#Include ../std/ENV.ahk
#Include KeyboardLayout.ahk
#Persistent

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
tooltipState(){
    ToolTip, % "GetKeyState`nRControl " GetKeyState("RCtrl") "`nLControl " GetKeyState("LCtrl") "`nShift " GetKeyState("LShift") + GetKeyState("RShift") "`nAlt " GetKeyState("LAlt") "`nWin " GetKeyState("LWin")
}


; Arrow keys
$*>^Up::Send {Blind}{RControl Up}{PgUp}{RControl Down}
$*>^Down::Send {Blind}{RControl Up}{PgDn}{RControl Down}

$*>^Left::
;   tooltipState()
    if isLeftToRight()
        Send {Blind}{RControl Up}{Home}{RControl Down}
    else
        Send {Blind}{RControl Up}{End}{RControl Down}
return

$*>^Right::
;   tooltipState()
    if isLeftToRight()
        Send {Blind}{RControl Up}{End}{RControl Down}
    else
        Send {Blind}{RControl Up}{Home}{RControl Down}
return
