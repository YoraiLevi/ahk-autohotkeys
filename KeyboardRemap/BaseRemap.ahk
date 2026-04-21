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
global mousePressedID := ""
global mousePressedTime := 0
global taskbarCooldownMs := 5500
global focusUnderMouseGuard := false
global ModifierTriggerCounts := {}
global msedgeWinID := ""
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

; Generalized function to display window info in a tooltip.
ShowWindowInfo(windowId, windowLabel := "") {
    ; Title and Class
    local winTitle, winClass, winPID, winProc, winProcPath, winMinMax, winStyle, winExStyle, winTransparent, winTransColor, winControlList, winControlListHwnd, winCount, winList
    WinGetTitle, winTitle, ahk_id %windowId%
    WinGetClass, winClass, ahk_id %windowId%

    ; Process Info
    WinGet, winPID, PID, ahk_id %windowId%
    WinGet, winProc, ProcessName, ahk_id %windowId%
    WinGet, winProcPath, ProcessPath, ahk_id %windowId%

    ; State and Style
    WinGet, winMinMax, MinMax, ahk_id %windowId%
    WinGet, winStyle, Style, ahk_id %windowId%
    WinGet, winExStyle, ExStyle, ahk_id %windowId%
    WinGet, winTransparent, Transparent, ahk_id %windowId%
    WinGet, winTransColor, TransColor, ahk_id %windowId%
    WinGet, winControlList, ControlList, ahk_id %windowId%
    WinGet, winControlListHwnd, ControlListHwnd, ahk_id %windowId%

    ; Window List, Count
    winList0 := 0                ; Initialize to prevent uninitialized warning
    WinGet, winCount, Count, ahk_id %windowId%
    WinGet, winList, List, ahk_id %windowId%

    ToolTip, % (windowLabel != "" ? windowLabel ":`n" : "Window Info:`n")
        . "  id: " windowId "`n"
        . "  title: " winTitle "`n"
        . "  class: " winClass "`n"
        . "  proc: " winProc "`n"
        . "  procPath: " winProcPath "`n"
        . "  PID: " winPID "`n"
        . "  MinMax (0=normal,1=min,2=max): " winMinMax "`n"
        . "  Style: " winStyle "`n"
        . "  ExStyle: " winExStyle "`n"
        . "  Transparent: " winTransparent "`n"
        . "  TransColor: " winTransColor "`n"
        . "  ControlList: " winControlList "`n"
        . "  ControlListHwnd: " winControlListHwnd "`n"
        . "  Window Count: " winCount "`n"
        . "  Window List: " (winList0 ? winList0 : "") ; winList returns window handles in winList1 ..
}

ShowWindowUnderMouseInfo() {
    MouseGetPos, , , MouseWinID
    ShowWindowInfo(MouseWinID, "Window under mouse")
    SetTimer, RemoveMouseTooltip, -25000  ; Remove after 25s
}

#F7::
    ShowWindowUnderMouseInfo()
Return

RemoveMouseTooltip:
    ToolTip
Return

ShowWindowActiveInfo() {
    WinGet, activeWinID, ID, A
    ShowWindowInfo(activeWinID, "Active window")
    SetTimer, RemoveActiveTooltip, -25000  ; Remove after 25s
}

#F8::
    ShowWindowActiveInfo()
Return

RemoveActiveTooltip:
    ToolTip
Return

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
    sleep 750
    MoveMouseToSelectedWindow()
return

; Moving Windows makes the mouse follow the window
$~*#Left Up::
    MoveMouseToSelectedWindow()
return
$~*#Right Up::
    MoveMouseToSelectedWindow()
return

; Only for Microsoft Edge main windows (msedge.exe)
#IfWinActive ahk_exe msedge.exe

    ; On Ctrl+Shift+A + Left Click: pass through input, record and display window info
    $~*<^+a::
        Critical 50
        ; Pass through input (let click happen as normal)
        ; Record the currently active window ID
        WinGet, id, ID, A
        msedgeWinID := id
        ; Also send {Down} (arrow down) key after recording the msedgeWinID
        ; Wait for the current window (id) to lose focus
        WinWaitNotActive, ahk_id %id%,, 0.75
        ; After losing focus, check if we're still in msedge.exe and in Chrome_WidgetWin_2
        WinGet, newId, ID, A
        WinGetClass, newClass, ahk_id %newId%
        WinGet, newProc, ProcessName, ahk_id %newId%
        if (newProc = "msedge.exe" && newClass = "Chrome_WidgetWin_2") {
            Sleep, 25
            SendInput, {Down}
        }
   
        else {
            _msg := "Error: Could not send {Down}. Reasons:`n"
            _msg .= "Process=""" newProc """ (expected msedge.exe)`n"
            _msg .= "Class=""" newClass """ (expected Chrome_WidgetWin_2)`n"
            Tooltip, %_msg%
            SetTimer, RemoveActiveTooltip, -2000
        }
   
   
    Return

; Existing Chrome_WidgetWin_2 class Enter handler
$~*Enter::
$~*NumpadEnter::
    global msedgeWinID
    critical 150
    WinGetClass, _activeClass, A
    if (_activeClass != "Chrome_WidgetWin_2" || msedgeWinID = ""){
        return
    }
    WinWaitNotActive, ahk_class Chrome_WidgetWin_2,, 0.75
    WinGet, newMsedgeWinID, ID, A
    if (msedgeWinID == newMsedgeWinID) {
    }
    else {
        MoveMouseToSelectedWindow()
        sleep 125
        MouseGetPos, , , id ; Gets the unique ID (ahk_id) of the window under the cursor
        WinActivate, ahk_id %id%
        msedgeWinID := ""
    }
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
; Function: Checks if a key (mod) was triggered N times (5) and if the logical state doesn't match the physical state,
; then resets it by sending a key up event.

; Usage: Call CheckAndResetModifier("LControl")
; Supports "LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt", "LWin", "RWin"

CheckAndResetModifier(mod := "") {
    global ModifierTriggerCounts
    static N := 3
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

    msg := ""
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
                    if (msg != "")
                        msg .= "`n"
                    ; msg .= "Sending {" key " up} logicalPressed: " logicalPressed " physicalPressed: " physicalPressed
                    ; Send, {%key% up}
                }
            }
        }
    }
    if (msg != ""){
        ToolTip, %msg%
        SetTimer, RemoveActiveTooltip, -25000  ; Remove after 25s
    }
    return
}

; Example integration:
;   In your hotkeys, after each trigger for a modifier, call:
;   CheckAndResetModifier("LControl")  ; Replace as appropriate
;   Or just CheckAndResetModifier() to check all mods

$~*LButton::
    global mousePressedID
    global mousePressedTime
    global msedgeWinID
    MouseGetPos, , , id
    mousePressedID := id

    WinGetClass, mousePressedClass, ahk_id %id%
    WinGet, winProc, ProcessName, ahk_id %id%
    mousePressedTime := A_TickCount
    if (winProc = "msedge.exe") {
        if (mousePressedClass = "Chrome_WidgetWin_1") {
            msedgeWinID := id
            ; ShowWindowInfo(msedgeWinID, "Edge window before LButton click")
        } else if (mousePressedClass = "Chrome_WidgetWin_2") {
            Critical On
            ; wait untills the _2 class is not active
            WinWaitNotActive, ahk_class Chrome_WidgetWin_2,, 0.75
            ; check that the new active is Chrome_WidgetWin_1 class and msedge.exe process and also not the previous window
            WinGet, newMsedgeWinID, ID, A
            WinGetClass, newMsedgeClass, ahk_id %newMsedgeWinID%
            WinGet, newWinProc, ProcessName, ahk_id %newMsedgeWinID%
            ; ShowWindowInfo(msedgeWinID, "Edge window before LButton click")

            if (newWinProc != "msedge.exe" || newMsedgeClass != "Chrome_WidgetWin_1" || newMsedgeWinID == msedgeWinID) {
            }
            else {
                ; we conclude we are in a new edge window
                msedgeWinID := newMsedgeWinID
                MoveMouseToSelectedWindow()
            }
            Critical Off
        }
    }
    else{
        msedgeWinID := ""
    }

    ; ShowWindowInfo(id, "LButton click")
    ; Remove tooltip after 2.5s
    ; SetTimer, RemoveActiveTooltip, -25000
    CheckAndResetModifier()
return
; --- Hotkey: Focus Window Under Mouse When Ctrl Pressed, but NOT after recent AltTab ---
$~LCtrl::
    CheckAndResetModifier()
    Critical
    global altTabLastTime, altTabCooldownMs, mousePressedID, mousePressedTime, taskbarCooldownMs
    WinGetClass, mousePressedClass, ahk_id %mousePressedID%

    MouseGetPos, , , id ; Gets the unique ID (ahk_id) of the window under the cursor
    WinGetTitle, titleUnderMouse, ahk_id %id% ; Gets the title using the retrieved ID
    WinGetClass, classUnderMouse, ahk_id %id% ; Gets the title using the retrieved ID
    WinGetTitle, activeTitle, A
    WinGetClass, activeClass, A
    WinGet, activeProc, ProcessName, A

    ; tooltip, % "titleUnderMouse: " titleUnderMouse " activeTitle: " activeTitle " classUnderMouse: " classUnderMouse " activeClass: " activeClass
    if (titleUnderMouse == "" && classUnderMouse == "") {
        ; tooltip, % "titleUnderMouse == "" && classUnderMouse == """
        return
    }
    if (titleUnderMouse == activeTitle && classUnderMouse == activeClass) { ; Same window under mouse, act normally
        ; tooltip, % "titleUnderMouse == activeTitle && classUnderMouse == activeClass"
        return
    }
    if (activeProc == "msedge.exe" && activeTitle == "") {
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

ResetFocusUnderMouseGuard(){
    global focusUnderMouseGuard
    focusUnderMouseGuard := false
}

$~*LCtrl Up::
    ResetFocusUnderMouseGuard()
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
    ResetFocusUnderMouseGuard()
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

    ResetFocusUnderMouseGuard()
    return
}

#If focusUnderMouseGuard
    ; Left Ctrl + Any key
    $*a::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*b::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*c::
        CheckAndResetModifier()
        ResetFocusUnderMouseGuard()
    return
    $*d::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*e::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*f::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*g::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*h::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*i::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*j::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*k::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*l::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*m::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*n::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*o::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*p::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*q::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*r::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*s::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*t::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*u::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
  
    $*v::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*w::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*x::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*y::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*z::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*`::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*0::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*1::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*2::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*3::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*4::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*5::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*6::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*7::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*8::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*9::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*-::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*=::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*[::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*]::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*\::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*;::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*'::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*,::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*.::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*/::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*Tab::
        CheckAndResetModifier()
        focusUnderMouseThenHotkeyHandler()
    return
    $*CapsLock::
        CheckAndResetModifier()
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
    Critical 50
    Send {Blind}{Home}
return

$*>^Down::
    Critical 50
    Send {Blind}{End}
return

$*>^Left::
    Critical 50
    modsDown_ := getRCtrlModifierDown()
    if isLeftToRight()
        Send {Blind}{RControl Up}{Home}%modsDown_%
    else
        Send {Blind}{RControl Up}{End}%modsDown_%
return

$*>^Right::
    Critical 50
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