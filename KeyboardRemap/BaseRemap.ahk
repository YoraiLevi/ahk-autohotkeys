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
global taskbarCooldownMs := 5500
global focusUnderMouseGuard := false
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
        . "RControl: " GetKeyState("RCtrl","P") "`n"
        . "LControl: " GetKeyState("LCtrl","P") "`n"
        . "LShift: " GetKeyState("LShift","P") "`n"
        . "RShift: " GetKeyState("RShift","P") "`n"
        . "LAlt: " GetKeyState("LAlt","P") "`n"
        . "RAlt: " GetKeyState("RAlt","P") "`n"
        . "LWin: " GetKeyState("LWin","P") "`n"
        . "RWin: " GetKeyState("RWin","P") "`n`n"
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

$~*!Tab::
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
    Critical
    global altTabLastTime, altTabCooldownMs, mousePressedClass, mousePressedTime, taskbarCooldownMs
    MouseGetPos, , , id ; Gets the unique ID (ahk_id) of the window under the cursor
    WinGetTitle, titleUnderMouse, ahk_id %id% ; Gets the title using the retrieved ID
    WinGetClass, classUnderMouse, ahk_id %id% ; Gets the title using the retrieved ID
    WinGetTitle, activeTitle, A
    WinGetClass, activeClass, A
    ; tooltip, % "titleUnderMouse: " titleUnderMouse " activeTitle: " activeTitle " classUnderMouse: " classUnderMouse " activeClass: " activeClass
    if (titleUnderMouse == "" && classUnderMouse == "") {
        ; tooltip, % "titleUnderMouse == "" && classUnderMouse == """
        return
    }
    if (titleUnderMouse == activeTitle && classUnderMouse == activeClass) { ; Same window under mouse, act normally
        ; tooltip, % "titleUnderMouse == activeTitle && classUnderMouse == activeClass"
        return
    }
    if (activeClass == "#32770"){ ; Win+R Run dialog
        ; tooltip, % "activeClass == #32770"
        return
    }
    if (((classUnderMouse == "Shell_TrayWnd" || mousePressedClass == "Shell_TrayWnd") || (classUnderMouse == "Shell_SecondaryTrayWnd" || mousePressedClass == "Shell_SecondaryTrayWnd")) && (A_TickCount - mousePressedTime < taskbarCooldownMs)){ ; Taskbar
        ; tooltip, % "classUnderMouse == Shell_TrayWnd || mousePressedClass == Shell_TrayWnd"
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
    ; tooltip, % "focusUnderMouseGuard := true"
    focusUnderMouseGuard := true
return
$~*LCtrl Up::
    global focusUnderMouseGuard
    focusUnderMouseGuard := false
return

focusUnderMouseHandler(){
    global focusUnderMouseGuard
    thisHotkey := A_ThisHotkey ; Save immediately before it can be overwritten by another thread

    ; Snapshot modifier physical state BEFORE WinActivate, since the user may
    ; release them during the window switch and {Blind} would then drop them.
    hadLCtrl  := GetKeyState("LCtrl","P")
    hadRCtrl  := GetKeyState("RCtrl","P")
    hadLShift := GetKeyState("LShift","P")
    hadRShift := GetKeyState("RShift","P")
    hadLAlt   := GetKeyState("LAlt","P")
    hadRAlt   := GetKeyState("RAlt","P")
    hadLWin   := GetKeyState("LWin","P")
    hadRWin   := GetKeyState("RWin","P")

    MouseGetPos, , , winId
    if winId
    {
        WinActivate, ahk_id %winId%
        WinWaitActive, ahk_id %winId%,, 0.5
        altTabLastTime := A_TickCount
    }

    keyPressed := SubStr(thisHotkey, 3) ; Skip "$*" prefix to get just the key name

    ; Re-press any modifiers the user was holding when the hotkey fired but
    ; may have released during WinActivate.  Only press those that are no
    ; longer physically held; ones still held are covered by {Blind}.
    modsDown := ""
    modsUp   := ""
    if (hadLCtrl  && !GetKeyState("LCtrl","P")) {
        modsDown .= "{LCtrl Down}"
        modsUp   .= "{LCtrl Up}"
    }
    if (hadRCtrl  && !GetKeyState("RCtrl","P")) {
        modsDown .= "{RCtrl Down}"
        modsUp   .= "{RCtrl Up}"
    }
    if (hadLShift && !GetKeyState("LShift","P")) {
        modsDown .= "{LShift Down}"
        modsUp   .= "{LShift Up}"
    }
    if (hadRShift && !GetKeyState("RShift","P")) {
        modsDown .= "{RShift Down}"
        modsUp   .= "{RShift Up}"
    }
    if (hadLAlt   && !GetKeyState("LAlt","P")) {
        modsDown .= "{LAlt Down}"
        modsUp   .= "{LAlt Up}"
    }
    if (hadRAlt   && !GetKeyState("RAlt","P")) {
        modsDown .= "{RAlt Down}"
        modsUp   .= "{RAlt Up}"
    }
    if (hadLWin   && !GetKeyState("LWin","P")) {
        modsDown .= "{LWin Down}"
        modsUp   .= "{LWin Up}"
    }
    if (hadRWin   && !GetKeyState("RWin","P")) {
        modsDown .= "{RWin Down}"
        modsUp   .= "{RWin Up}"
    }

    ; {Blind} preserves modifiers still physically held.
    ; modsDown/modsUp re-inject any that were released during the switch.
    ; tooltip, % "modsDown: " modsDown " keyPressed: " keyPressed " modsUp: " modsUp "thisHotkey: " thisHotkey
    Send {Blind}%modsDown%{%keyPressed%}%modsUp%
    focusUnderMouseGuard := false
    return
}

#If focusUnderMouseGuard
    ; Left Ctrl + Any key
    $*a::
        Critical
        focusUnderMouseHandler()
    return
    $*b::
        Critical
        focusUnderMouseHandler()
    return
    $*c::
        Critical
        focusUnderMouseHandler()
    return
    $*d::
        Critical
        focusUnderMouseHandler()
    return
    $*e::
        Critical
        focusUnderMouseHandler()
    return
    $*f::
        Critical
        focusUnderMouseHandler()
    return
    $*g::
        Critical
        focusUnderMouseHandler()
    return
    $*h::
        Critical
        focusUnderMouseHandler()
    return
    $*i::
        Critical
        focusUnderMouseHandler()
    return
    $*j::
        Critical
        focusUnderMouseHandler()
    return
    $*k::
        Critical
        focusUnderMouseHandler()
    return
    $*l::
        Critical
        focusUnderMouseHandler()
    return
    $*m::
        Critical
        focusUnderMouseHandler()
    return
    $*n::
        Critical
        focusUnderMouseHandler()
    return
    $*o::
        Critical
        focusUnderMouseHandler()
    return
    $*p::
        Critical
        focusUnderMouseHandler()
    return
    $*q::
        Critical
        focusUnderMouseHandler()
    return
    $*r::
        Critical
        focusUnderMouseHandler()
    return
    $*s::
        Critical
        focusUnderMouseHandler()
    return
    $*t::
        Critical
        focusUnderMouseHandler()
    return
    $*u::
        Critical
        focusUnderMouseHandler()
    return
    $*v::
        Critical
        focusUnderMouseHandler()
    return
    $*w::
        Critical
        focusUnderMouseHandler()
    return
    $*x::
        Critical
        focusUnderMouseHandler()
    return
    $*y::
        Critical
        focusUnderMouseHandler()
    return
    $*z::
        Critical
        focusUnderMouseHandler()
    return
    $*`::
        Critical
        focusUnderMouseHandler()
    return
    $*0::
        Critical
        focusUnderMouseHandler()
    return
    $*1::
        Critical
        focusUnderMouseHandler()
    return
    $*2::
        Critical
        focusUnderMouseHandler()
    return
    $*3::
        Critical
        focusUnderMouseHandler()
    return
    $*4::
        Critical
        focusUnderMouseHandler()
    return
    $*5::
        Critical
        focusUnderMouseHandler()
    return
    $*6::
        Critical
        focusUnderMouseHandler()
    return
    $*7::
        Critical
        focusUnderMouseHandler()
    return
    $*8::
        Critical
        focusUnderMouseHandler()
    return
    $*9::
        Critical
        focusUnderMouseHandler()
    return
    $*-::
        Critical
        focusUnderMouseHandler()
    return
    $*=::
        Critical
        focusUnderMouseHandler()
    return
    $*[::
        Critical
        focusUnderMouseHandler()
    return
    $*]::
        Critical
        focusUnderMouseHandler()
    return
    $*\::
        Critical
        focusUnderMouseHandler()
    return
    $*;::
        Critical
        focusUnderMouseHandler()
    return
    $*'::
        Critical
        focusUnderMouseHandler()
    return
    $*,::
        Critical
        focusUnderMouseHandler()
    return
    $*.::
        Critical
        focusUnderMouseHandler()
    return
    $*/::
        Critical
        focusUnderMouseHandler()
    return
    $*Tab::
        Critical
        focusUnderMouseHandler()
    return
    $*CapsLock::
        Critical
        focusUnderMouseHandler()
    return
#If  ; end if directive

#Include CopilotRemap.ahk

getRCtrlModifierDown(){
    modsDown := ""
    if (GetKeyState("RCtrl")) {
        modsDown .= "{RCtrl Down}"
    }
    return modsDown
}
; Arrow keys
$*>^Up::
    Critical, On
    Send {Blind}{Home}
return

$*>^Down::
    Critical, On
    Send {Blind}{End}
return

$*>^Left::
    Critical, On
    modsDown_ := getRCtrlModifierDown()
    if isLeftToRight()
        Send {Blind}{RControl Up}{Home}%modsDown_%
    else
        Send {Blind}{RControl Up}{End}%modsDown_%
return

$*>^Right::
    Critical, On
    modsDown_ := getRCtrlModifierDown()
    if isLeftToRight()
        Send {Blind}{RControl Up}{End}%modsDown_%
    else
        Send {Blind}{RControl Up}{Home}%modsDown_%
return

$+Pause::
    toggleLaptopKeyboard()
Return

; More Hotkeys
#Include ExplorerHotkeys.ahk
#Include MoveWindowHotkeys.ahk