CoordMode, Mouse, Screen ; Ensures coordinates are relative to the screen, not the active window
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
global laptopKeyboardStateFile := A_ScriptDir . "\laptopKeyboard.state"
global laptopKeyboard := loadLaptopKeyboardState()

; --- "Cooldown" tracking for Alt+Tab switching ---
global altTabLastTime := 0
altTabCooldownMs := 500  ; Cooldown in ms before Ctrl window focus will work again
; Global state
global tabPressed := false
global beforeAltTabClass := ""
global beforeLWinClass := ""
global mousePressedClass := ""
global mousePressedTime := 0
global taskbarCooldownMs := 3500
#Include KeyboardLayout.ahk
#Persistent

loadLaptopKeyboardState() {
    global laptopKeyboardStateFile
    if (FileExist(laptopKeyboardStateFile)) {
        FileRead, savedState, %laptopKeyboardStateFile%
        return (savedState = "1")
    }
    return false
}

saveLaptopKeyboardState(state) {
    global laptopKeyboardStateFile
    FileDelete, %laptopKeyboardStateFile%
    FileAppend, %state%, %laptopKeyboardStateFile%
}

toggleLaptopKeyboard(){
    global laptopKeyboard
    laptopKeyboard := !laptopKeyboard
    saveLaptopKeyboardState(laptopKeyboard ? "1" : "0")
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

$~*Tab::
    global tabPressed, beforeAltTabClass
    tabPressed := true
    WinGetClass, beforeAltTabClass, A ; keep track of window class before Alt+Tab is pressed
return

; Move mouse to selected window when Alt is released after Alt+Tab
$~*Alt Up::
    global altTabLastTime, altTabCooldownMs, tabPressed
    if (!tabPressed) {
        tabPressed := false
        return
    }
    tabPressed := false
    ; Only execute if the active window is XamlExplorerHostlslandWindow (Task Switching)
    WinGetClass, activeClass, A
    condition := (activeClass && activeClass != "" && activeClass != "XamlExplorerHostIslandWindow")
    if (!activeClass && activeClass != "" && activeClass != "XamlExplorerHostIslandWindow") {
        return
    }
    altTabLastTime := A_TickCount
    WinWaitNotActive ,ahk_class %beforeAltTabClass%,, 0.5 ; Wait for defocus from previous window
    WinWaitNotActive ,ahk_class XamlExplorerHostIslandWindow,, 0.5 ; And also wait for defocus from Task Switching window
    MoveMouseToSelectedWindow()
return

$~*LWin::
    global beforeLWinClass
    ; track the class of the window before LWin is pressed so mouse can be moved on the automatic window focus switch
    WinGetClass, beforeLWinClass, A
return
$~*#r::
    global beforeLWinClass, altTabLastTime
    WinGetClass, activeClass, A
    if (activeClass == "#32770"){ ; Win+R Run dialog is focused, act normally
        return
    }
    altTabLastTime := A_TickCount
    WinWaitNotActive ,ahk_class %beforeLWinClass%,, 0.5
    MoveMouseToSelectedWindow()
return
~LButton::
    global mousePressedClass
    global mousePressedTime
    MouseGetPos, , , id
    WinGetClass, mousePressedClass, ahk_id %id%
    mousePressedTime := A_TickCount
return
; --- Hotkey: Focus Window Under Mouse When Ctrl Pressed, but NOT after recent AltTab ---
$~LCtrl::
    global altTabLastTime, altTabCooldownMs, mousePressedClass, mousePressedTime, taskbarCooldownMs
    MouseGetPos, , , id ; Gets the unique ID (ahk_id) of the window under the cursor
    WinGetTitle, titleUnderMouse, ahk_id %id% ; Gets the title using the retrieved ID
    WinGetClass, classUnderMouse, ahk_id %id% ; Gets the title using the retrieved ID
    WinGetTitle, activeTitle, A
    WinGetClass, activeClass, A
    ; tooltip, % "titleUnderMouse: " titleUnderMouse " activeTitle: " activeTitle " classUnderMouse: " classUnderMouse " activeClass: " activeClass
    if (titleUnderMouse == activeTitle && classUnderMouse == activeClass) { ; Same window under mouse, act normally
        ; tooltip, % "titleUnderMouse == activeTitle && classUnderMouse == activeClass"
        return
    }
    if (activeClass == "#32770"){ ; Win+R Run dialog
        ; tooltip, % "activeClass == #32770"
        return
    }
    if ((classUnderMouse == "Shell_TrayWnd" || mousePressedClass == "Shell_TrayWnd") && (A_TickCount - mousePressedTime < taskbarCooldownMs)){ ; Taskbar
        tooltip, % "classUnderMouse == Shell_TrayWnd || mousePressedClass == Shell_TrayWnd"
        return
    }
    ; Don't switch focus if Ctrl is being held down (key repeat)
    if (A_PriorKey = "LControl") {
        ; tooltip, % "A_PriorKey = LControl"
        altTabLastTime := A_TickCount ;replace with ctrl specific cooldown timer instead
        return
    }
    if (altTabLastTime && (A_TickCount - altTabLastTime < altTabCooldownMs)) {
        ; tooltip, % "altTabLastTime && (A_TickCount - altTabLastTime < altTabCooldownMs)"
        return
    }
    ; Focus window under mouse
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