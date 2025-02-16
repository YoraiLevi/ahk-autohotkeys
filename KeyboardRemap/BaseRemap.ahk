#Include ../std/ENV.ahk
; Variables
LShiftState := 0
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

*F23::
if(!LShiftState){
    Send, {Blind}{LWin Up}{LShift Up}
}
    Send, {Blind}{LWin Up}
    Send, {Blind}{RControl Down}
    Send, {Blind F23 Up}
Return

*F23 Up::
Send, {Blind}{RControl Up}
return 

~*LShift::
    LWinState := GetKeyState("LWin")
    if(!GetKeyState("LWin")){
        LShiftState := GetKeyState("LShift")
    }
return

~*LShift Up::
    LWinState := GetKeyState("LWin")
    if(!GetKeyState("LWin")){
        LShiftState := GetKeyState("LShift")
    }
Return

; Arrow keys
$*>^Up::
    Send {Blind}{RControl Up}{PgUp}{RControl Down}
return

$*>^Down::
    Send {Blind}{RControl Up}{PgDn}{RControl Down}
return

$*>^Left::
    if isLeftToRight()
        Send {Blind}{RControl Up}{Home}{RControl Down}
    else
        Send {Blind}{RControl Up}{End}{RControl Down}
return

$*>^Right::
    if isLeftToRight()
        Send {Blind}{RControl Up}{End}{RControl Down}
    else
        Send {Blind}{RControl Up}{Home}{RControl Down}
return
; Now with copilot!
F23 & Up::
    Send {Blind}{RControl Up}{PgUp}{RControl Down}
return

F23 & Down::
    Send {Blind}{RControl Up}{PgDn}{RControl Down}
return

F23 & Left::
    if isLeftToRight(){
            Send {Blind}{Home}
        }
    else{
            Send {Blind}{End}
        }
return

F23 & Right::
    if isLeftToRight(){
            Send {Blind}{End}
    }
    else{
            Send {Blind}{Home}
    }

return
; More Hotkeys
#Include ExplorerHotkeys.ahk