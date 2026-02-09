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
global ModifierTriggerCounts := {}
#Include KeyboardLayout.ahk
#Persistent

; https://www.autohotkey.com/boards/viewtopic.php?t=118246 - Detecting When Any New Window Is Created or Displayed?
; DllCall("RegisterShellHookWindow", "UInt", A_ScriptHwnd)
; OnMessage(DllCall("RegisterWindowMessage", "Str", "SHELLHOOK"), "winCenter")

; winCenter(wParam, lParam) {
;  If (wParam != WINDOWCREATED := 1)
;   Return
;  WinGet
;  WinGet pname, ProcessName, % winTitle := "ahk_id" lParam
;  Tooltip, % "Window created: " pname " lParam: " lParam " wParam: " wParam
;  Return
; }

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

; New Window Hotkeys make the mouse follow the window
$~*^n::
$~^+w::
$~!n::
$~+!n::
    sleep 150
    MoveMouseToSelectedWindow()
return

; Moving Windows makes the mouse follow the window
$~*#Left Up::
    MoveMouseToSelectedWindow()
return
$~*#Right Up::
    MoveMouseToSelectedWindow()
return

; In Edge: if Enter is pressed and the window under the mouse changes, refocus to that window
#IfWinActive ahk_exe msedge.exe
    $*Enter::
        Critical On
        WinGet, edgeActiveBefore, ID, A
        Send {Blind}{Enter}
        WinWaitNotActive, ahk_id %edgeActiveBefore%,, 0.75
        WinGet, edgeActiveAfter, ID, A
        tooltip, % "edgeActiveBefore: " edgeActiveBefore " edgeActiveAfter: " edgeActiveAfter
        if (edgeActiveBefore != edgeActiveAfter) {
            MoveMouseToSelectedWindow()
        }
    return
#If  ; end Edge Enter directive

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
; Function: Checks if a key (mod) was triggered N times (5) and if the logical state doesn't match the physical state,
; then resets it by sending a key up event.

; Usage: Call CheckAndResetModifier("LControl")
; Supports "LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt", "LWin", "RWin"

CheckAndResetModifier(mod := "") {
    global ModifierTriggerCounts
    static N := 5
    keyMap := { "LControl": "LControl", "RControl": "RControl"  , "LShift": "LShift", "RShift": "RShift"        , "LAlt": "LAlt", "RAlt": "RAlt"        , "LWin": "LWin", "RWin": "RWin"}

    keysToCheck := []

    if (mod = "" || mod = "") {
        ; No mod provided: check all
        for k, v in keyMap
            keysToCheck.Push(v)
    } else {
        if !(mod in keyMap)
            return
        keysToCheck.Push(keyMap[mod])
    }

    for index, key in keysToCheck
    {
        if !ModifierTriggerCounts.HasKey(key)
            ModifierTriggerCounts[key] := 0

        ModifierTriggerCounts[key] += 1

        if (ModifierTriggerCounts[key] >= N) {
            ModifierTriggerCounts[key] := 0

            logicalPressed := GetKeyState(key)
            physicalPressed := GetKeyState(key, "P")
            if (logicalPressed != physicalPressed) {
                if (logicalPressed) {
                    Send, {%key% up}
                    tooltip, % "Sending {%key% up} logicalPressed: " logicalPressed " physicalPressed: " physicalPressed
                }
            }
        }
    }
    return
}

; Example integration:
;   In your hotkeys, after each trigger for a modifier, call:
;   CheckAndResetModifier("LControl")  ; Replace as appropriate
;   Or just CheckAndResetModifier() to check all mods

~LButton::
    global mousePressedClass
    global mousePressedTime
    MouseGetPos, , , id
    WinGetClass, mousePressedClass, ahk_id %id%
    mousePressedTime := A_TickCount
    CheckAndResetModifier()
return
; --- Hotkey: Focus Window Under Mouse When Ctrl Pressed, but NOT after recent AltTab ---
$~LCtrl::
    CheckAndResetModifier()
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

focusUnderMouseThenHotkeyHandler(){
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

HotkeyThenFocusUnderMouseHandler(){
    global focusUnderMouseGuard
    thisHotkey := A_ThisHotkey ; Save immediately before it can be overwritten by another thread

    ; ; Snapshot modifier physical state BEFORE WinActivate, since the user may
    ; ; release them during the window switch and {Blind} would then drop them.
    ; hadLCtrl  := GetKeyState("LCtrl","P")
    ; hadRCtrl  := GetKeyState("RCtrl","P")
    ; hadLShift := GetKeyState("LShift","P")
    ; hadRShift := GetKeyState("RShift","P")
    ; hadLAlt   := GetKeyState("LAlt","P")
    ; hadRAlt   := GetKeyState("RAlt","P")
    ; hadLWin   := GetKeyState("LWin","P")
    ; hadRWin   := GetKeyState("RWin","P")

    keyPressed := SubStr(thisHotkey, 3) ; Skip "$*" prefix to get just the key name

    ; ; Re-press any modifiers the user was holding when the hotkey fired but
    ; ; may have released during WinActivate.  Only press those that are no
    ; ; longer physically held; ones still held are covered by {Blind}.
    ; modsDown := ""
    ; modsUp   := ""
    ; if (hadLCtrl  && !GetKeyState("LCtrl","P")) {
    ;     modsDown .= "{LCtrl Down}"
    ;     modsUp   .= "{LCtrl Up}"
    ; }
    ; if (hadRCtrl  && !GetKeyState("RCtrl","P")) {
    ;     modsDown .= "{RCtrl Down}"
    ;     modsUp   .= "{RCtrl Up}"
    ; }
    ; if (hadLShift && !GetKeyState("LShift","P")) {
    ;     modsDown .= "{LShift Down}"
    ;     modsUp   .= "{LShift Up}"
    ; }
    ; if (hadRShift && !GetKeyState("RShift","P")) {
    ;     modsDown .= "{RShift Down}"
    ;     modsUp   .= "{RShift Up}"
    ; }
    ; if (hadLAlt   && !GetKeyState("LAlt","P")) {
    ;     modsDown .= "{LAlt Down}"
    ;     modsUp   .= "{LAlt Up}"
    ; }
    ; if (hadRAlt   && !GetKeyState("RAlt","P")) {
    ;     modsDown .= "{RAlt Down}"
    ;     modsUp   .= "{RAlt Up}"
    ; }
    ; if (hadLWin   && !GetKeyState("LWin","P")) {
    ;     modsDown .= "{LWin Down}"
    ;     modsUp   .= "{LWin Up}"
    ; }
    ; if (hadRWin   && !GetKeyState("RWin","P")) {
    ;     modsDown .= "{RWin Down}"
    ;     modsUp   .= "{RWin Up}"
    ; }

    ; ; {Blind} preserves modifiers still physically held.
    ; ; modsDown/modsUp re-inject any that were released during the switch.
    ; ; tooltip, % "modsDown: " modsDown " keyPressed: " keyPressed " modsUp: " modsUp "thisHotkey: " thisHotkey
    ; Send {Blind}%modsDown%{%keyPressed%}%modsUp%

    Send {Blind}{%keyPressed%}

    MouseGetPos, , , winId
    if winId
    {
        WinActivate, ahk_id %winId%
        WinWaitActive, ahk_id %winId%,, 0.5
        altTabLastTime := A_TickCount
    }

    focusUnderMouseGuard := false
    return
}

#If focusUnderMouseGuard
    ; Left Ctrl + Any key
    $*a::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*b::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*c::
        CheckAndResetModifier()
        Critical
        HotkeyThenFocusUnderMouseHandler()
    return
    $*d::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*e::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*f::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*g::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*h::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*i::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*j::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*k::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*l::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*m::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*n::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*o::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*p::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*q::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*r::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*s::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*t::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*u::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*v::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*w::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*x::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*y::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*z::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*`::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*0::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*1::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*2::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*3::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*4::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*5::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*6::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*7::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*8::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*9::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*-::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*=::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*[::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*]::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*\::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*;::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*'::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*,::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*.::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*/::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*Tab::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
    return
    $*CapsLock::
        CheckAndResetModifier()
        Critical
        focusUnderMouseThenHotkeyHandler()
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