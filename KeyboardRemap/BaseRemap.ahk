#Include ../std/ENV.ahk
; Variables
global tooltipActive := false  ; Start with tooltip active
global LShiftState := 0
global RShiftState := 0
global LCtrlState := 0
global RCtrlState := 0
global LAltState := 0
global RAltState := 0
global LWinState := 0
global RWinState := 0
global laptopKeyboard := false

; --- "Cooldown" tracking for Alt+Tab switching ---
global altTabLastTime := 0
altTabCooldownMs := 500  ; Cooldown in ms before Ctrl window focus will work again

#Include KeyboardLayout.ahk
#Persistent

toggleLaptopKeyboard(){
    laptopKeyboard := !laptopKeyboard
    if(laptopKeyboard){
        MsgBox, Laptop hotkeys are now active
    }
    else{
        MsgBox, Non-Laptop hotkeys are now active
    }
}

; Start the tooltip timer
if(tooltipActive){
    SetTimer, tooltipState, 50
}

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
    ToolTip, % "Logical State (GetKeyState)`n"
        . "RControl: " GetKeyState("RCtrl") " (StateCounter: " RCtrlState ")`n"
        . "LControl: " GetKeyState("LCtrl") " (StateCounter: " LCtrlState ")`n"
        . "LShift: " GetKeyState("LShift") " (StateCounter: " LShiftState ")`n"
        . "RShift: " GetKeyState("RShift") " (StateCounter: " RShiftState ")`n"
        . "LAlt: " GetKeyState("LAlt") " (StateCounter: " LAltState ")`n"
        . "RAlt: " GetKeyState("RAlt") " (StateCounter: " RAltState ")`n"
        . "LWin: " GetKeyState("LWin") " (StateCounter: " LWinState ")`n"
        . "RWin: " GetKeyState("RWin") " (StateCounter: " RWinState ")`n`n"
        . "Physical State (GetKeyState with 'P')`n"
        . "RControl: " GetKeyState("RCtrl", "P") "`n"
        . "LControl: " GetKeyState("LCtrl", "P") "`n"
        . "LShift: " GetKeyState("LShift", "P") "`n"
        . "RShift: " GetKeyState("RShift", "P") "`n"
        . "LAlt: " GetKeyState("LAlt", "P") "`n"
        . "RAlt: " GetKeyState("RAlt", "P") "`n"
        . "LWin: " GetKeyState("LWin", "P") "`n"
        . "RWin: " GetKeyState("RWin", "P") "`n`n"
        . "Press Ctrl+Alt+T to hide/show this tooltip"
}

^!t::  ; Ctrl+Alt+T to toggle the auto-refreshing tooltip
    global tooltipActive
    tooltipActive := !tooltipActive
    if (tooltipActive) {
        SetTimer, tooltipState, 50  ; Update every 50ms
        tooltipState()  ; Show initial state
    } else {
        SetTimer, tooltipState, Off
        ToolTip  ; Clear the tooltip
    }
return

MoveMouseToSelectedWindow(){
    WinGetPos, winX, winY, winWidth, winHeight, A
    if (winX != "" && winY != "") {
        ; Move mouse to center of the active window
        centerX := winX + (winWidth // 2)
        centerY := winY + (winHeight // 2)
        DllCall("SetCursorPos", int, centerX, int, centerY) ; https://www.autohotkey.com/boards/viewtopic.php?t=60433 ;MouseMove, X, Y, 0 ; does not work with multi-monitor
    }
}

$~*#Left Up::
    MoveMouseToSelectedWindow()
return
$~*#Right Up::
    MoveMouseToSelectedWindow()
return

; Move mouse to selected window when Alt is released after Alt+Tab
$~*Alt Up::
    global altTabLastTime, altTabCooldownMs
    ; Only execute if the active window is XamlExplorerHostlslandWindow (Task Switching)
    WinGetClass, activeClass, A
    condition := (activeClass && activeClass != "" && activeClass != "XamlExplorerHostIslandWindow")
    if (!activeClass && activeClass != "" && activeClass != "XamlExplorerHostIslandWindow") {
        return
    }
    altTabLastTime := A_TickCount
    WinWaitNotActive ,ahk_class XamlExplorerHostIslandWindow,, 0.5 ; Not sure if this is the correct syntax but it seem to work
    MoveMouseToSelectedWindow()
return

; --- Hotkey: Focus Window Under Mouse When Ctrl Pressed, but NOT after recent AltTab ---
$~LCtrl::
    global altTabLastTime, altTabCooldownMs
    ; Don't switch focus if Ctrl is being held down (key repeat)
    if (A_PriorKey = "LControl") {
        altTabLastTime := A_TickCount
        return
    }
    if (altTabLastTime && (A_TickCount - altTabLastTime < altTabCooldownMs)) {
        return
    }
    MouseGetPos, , , winId
    if winId
    {
        WinActivate, ahk_id %winId%
        altTabLastTime := A_TickCount
    }
return

#Include CopilotRemap.ahk

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

$+Pause::
    toggleLaptopKeyboard()
Return

; More Hotkeys
#Include ExplorerHotkeys.ahk
#Include MoveWindowHotkeys.ahk