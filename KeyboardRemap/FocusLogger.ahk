; =============================================================================
; FocusLogger.ahk — Standalone foreground-window change monitor
; =============================================================================
;
; PURPOSE
;   Logs every foreground (active) window change to focus_log.txt and briefly
;   shows a tooltip whenever focus shifts.  Run this alongside your main remap
;   script whenever you suspect a rogue process is stealing keyboard focus.
;
; USAGE
;   Double-click FocusLogger.ahk (or launch it via AutoHotkey.exe).
;   It runs silently in the system tray.  Right-click the tray icon for:
;     • Open Log    — opens focus_log.txt in Notepad
;     • Clear Log   — deletes the current log file
;     • Toggle Monitor — pauses / resumes logging without restarting
;     • Exit        — stops the script entirely
;
; LOG FILE
;   Written to:  <script directory>\focus_log.txt
;   Each focus change appends two lines:
;
;     HH:mm:ss hwnd=<handle> pid=<pid> proc=<process.exe> class=<WinClass> title=<window title>
;              [parent hwnd=<handle> pid=<pid> proc=<process.exe>]
;              FROM hwnd=<handle> proc=<process.exe> class=<WinClass> title=<window title>
;
; FIELD GLOSSARY
;   hwnd        Raw window handle (decimal).  Unique per window instance.
;   pid         Process ID of the window's owning thread (from GetWindowThreadProcessId).
;               Present even when proc/class/title are empty — use it to look up
;               the process in Task Manager (Details tab → PID column).
;   proc        Executable name resolved via WMI.  May be empty for very short-lived
;               (< ~200 ms) windows that die before WMI can query them.
;   class       Window class from GetClassNameA().  More reliable than AHK's
;               WinGetClass for hidden / ghost windows — class is often the only
;               identifier available for stealth windows.
;   title       Window title at the moment of capture.
;   [parent …]  The window that created the stealing window (GetParent + WMI).
;               This is usually the most actionable field: it points to the
;               real application responsible even when the ghost window itself
;               has no proc/class/title.
;   FROM …      The window that HAD focus just before the change.
;
; =============================================================================
; HOW TO READ THE LOG — WORKED EXAMPLES
; =============================================================================
;
; ── EXAMPLE 1: Benign user-initiated switch ─────────────────────────────────
;
;   11:08:17 hwnd=0xa01a2 pid=12264 proc=msedge.exe class=Chrome_WidgetWin_1 title=...Edge...
;            [parent hwnd=0 pid=0 proc=]
;            FROM hwnd=0x3710a6 proc=Cursor.exe class=Chrome_WidgetWin_1 title=...Cursor...
;
;   Reading: User switched from Cursor to Edge.
;   Signals: proc and class are populated, parent is 0 (top-level window), title is present.
;   Action:  Nothing — normal user behaviour.
;
; ── EXAMPLE 2: Ghost / hidden window steal ──────────────────────────────────
;
;   11:33:07 hwnd=2756564 pid=28732 proc=msrdc.exe class= title=
;            [parent hwnd=0 pid=65012 proc=wslhost.exe]
;            FROM hwnd=3608742 proc=Cursor.exe class=Chrome_WidgetWin_1 title=...Cursor...
;
;   Reading: A hidden msrdc.exe window (no class, no title) stole focus.
;            Its parent process is wslhost.exe → this is WSLg's RDP client.
;   Signals: class and title both empty, proc resolved only via pid+WMI.
;            Parent proc is the real culprit.
;   Fix:     Add guiApplications=false to %USERPROFILE%\.wslconfig, run wsl --shutdown.
;
; ── EXAMPLE 3: Windows Shell notification badge ─────────────────────────────
;
;   11:27:14 hwnd=50859280 pid=27428 proc= class= title=
;            [parent hwnd=656422 pid=19960 proc=explorer.exe]
;            FROM hwnd=3608742 proc=Cursor.exe ...
;
;   Reading: A ghost window (no proc, class, title) was created by Explorer.EXE.
;            Explorer creates these transiently when updating taskbar badges /
;            notification counts or animating jump lists.
;   Signals: parent proc=explorer.exe, parent hwnd matches Shell_TrayWnd or
;            XamlExplorerHostIslandWindow.
;   Fix:     Enable Windows Focus Assist (Settings → System → Focus).
;            Disable taskbar badge counts for chatty apps (Discord, Spotify, …).
;
; ── EXAMPLE 4: Clockwork 30-second steal ────────────────────────────────────
;
;   10:57:35  hwnd=0  pid=  proc=  class=  title=   ← focus stolen
;   10:58:06  ... proc=Cursor.exe ...                ← focus returned
;   10:58:07  hwnd=0  pid=  proc=  class=  title=   ← stolen again  (+31 s)
;   10:58:38  ... proc=Cursor.exe ...                ← returned      (+31 s)
;
;   Reading: Perfectly regular 30-31 s interval → a software heartbeat timer.
;   Signals: hwnd=0 means GetForegroundWindow returned NULL (the OS momentarily
;            has no foreground window at all, typical during hidden-window
;            creation/destruction).
;   Approach: Note the interval, check which background services have that
;             polling period.  Common culprits: Zoom (~30 s presence ping),
;             Discord (~30 s heartbeat), WSLg, Teams, VPN clients.
;             Close them one-by-one and watch if the rhythm stops.
;
; =============================================================================
; DIAGNOSTIC WORKFLOW
; =============================================================================
;
;   1. Launch FocusLogger.ahk.
;   2. Reproduce the focus loss (type normally until focus is stolen).
;   3. Right-click tray → Open Log.
;   4. Find the entry where focus left your working window:
;        grep for "FROM hwnd=<your window handle>"
;        or look for the timestamp that matches when you felt the steal.
;   5. Check the fields in order:
;        a. proc=       → easiest: immediately names the culprit.
;        b. pid=        → look up in Task Manager → Details if proc is empty.
;        c. class=      → identify the window type (message-only, shell, etc.)
;        d. parent proc= → the real owner when the ghost window is ephemeral.
;   6. Once identified, fix at the source (close the app, adjust its settings,
;      use Windows Focus Assist, or disable its notifications/badges).
;
; =============================================================================

#SingleInstance force
#NoEnv
#Warn
#Persistent

global _lastFocusWinID := 0
global _logFile        := A_ScriptDir . "\focus_log.txt"
global _monitorActive  := true

SetTimer, _FocusPollTimer, 200

Menu, Tray, NoStandardMenu
Menu, Tray, Add, Open Log,       _OpenLog
Menu, Tray, Add, Clear Log,      _ClearLog
Menu, Tray, Add, Toggle Monitor, _ToggleMonitor
Menu, Tray, Add                                   ; separator
Menu, Tray, Add, Exit,           _ExitApp
Menu, Tray, Tip, Focus Logger [ON]
return

; ---------------------------------------------------------------------------
_OpenLog:
    IfExist, %_logFile%
        Run, notepad.exe "%_logFile%"
    else
        MsgBox, Log file does not exist yet — no focus changes recorded.
return

_ClearLog:
    FileDelete, %_logFile%
    ToolTip, Log cleared, 0, 0, 2
    SetTimer, _RemoveFLTooltip, -2000
return

_ToggleMonitor:
    global _monitorActive
    _monitorActive := !_monitorActive
    _state := _monitorActive ? "ON" : "OFF"
    Menu, Tray, Tip, Focus Logger [%_state%]
    ToolTip, % "Monitor " _state, 0, 0, 2
    SetTimer, _RemoveFLTooltip, -2000
return

_ExitApp:
    ExitApp
return

_RemoveFLTooltip:
    ToolTip, , , , 2
return

; ---------------------------------------------------------------------------
; Core polling timer — fires every 200 ms, logs only on actual change.
; Uses DllCall / WMI so it captures hidden and ghost windows that AHK's
; built-in WinGet* commands miss entirely.
; ---------------------------------------------------------------------------
_FocusPollTimer:
    if (!_monitorActive)
        return

    _curHwnd := DllCall("GetForegroundWindow")
    if (_curHwnd = _lastFocusWinID)
        return

    _prevHwnd       := _lastFocusWinID
    _lastFocusWinID := _curHwnd

    _fpid := 0, _fp := "", _fc := "", _ft := ""
    _parentHwnd := 0, _parentPid := 0, _parentProc := "", _wmiParentPid := 0

    if (_curHwnd != 0) {
        ; GetClassNameA works even for hidden / message-only windows
        VarSetCapacity(_fc, 512)
        DllCall("GetClassNameA", "UInt", _curHwnd, "AStr", _fc, "Int", 256)

        WinGetTitle, _ft, ahk_id %_curHwnd%

        ; PID of the thread that owns this window
        DllCall("GetWindowThreadProcessId", "UInt", _curHwnd, "UInt*", _fpid)

        ; Parent window handle → parent process (points to the creating app)
        _parentHwnd := DllCall("GetParent", "UInt", _curHwnd)
        if (_parentHwnd)
            DllCall("GetWindowThreadProcessId", "UInt", _parentHwnd, "UInt*", _parentPid)

        ; WMI: resolve exe name + spawning parent PID from the OS process table.
        ; Called only when focus actually changes, so the latency is acceptable.
        if (_fpid > 0) {
            try {
                for _wProc in ComObjGet("winmgmts:").ExecQuery("SELECT Name,ParentProcessId FROM Win32_Process WHERE ProcessId=" _fpid) {
                    _fp          := _wProc.Name
                    _wmiParentPid := _wProc.ParentProcessId
                }
            }
            if (_parentPid = 0)
                _parentPid := _wmiParentPid
            if (_parentPid > 0) {
                try {
                    for _wProc in ComObjGet("winmgmts:").ExecQuery("SELECT Name FROM Win32_Process WHERE ProcessId=" _parentPid)
                        _parentProc := _wProc.Name
                }
            }
        }
    }

    ; Resolve the window that previously held focus
    if (_prevHwnd != 0 && _prevHwnd != "") {
        WinGetTitle, _pt, ahk_id %_prevHwnd%
        WinGetClass, _pc, ahk_id %_prevHwnd%
        WinGet,      _pp, ProcessName, ahk_id %_prevHwnd%
    } else {
        _pt := "", _pc := "", _pp := ""
    }

    FormatTime, _fts,, HH:mm:ss
    _fLine  := _fts " hwnd=" _curHwnd " pid=" _fpid " proc=" _fp " class=" _fc " title=" _ft
    _fLine  .= " [parent hwnd=" _parentHwnd " pid=" _parentPid " proc=" _parentProc "]"
    _fLine  .= "`n         FROM hwnd=" _prevHwnd " proc=" _pp " class=" _pc " title=" _pt
    FileAppend, %_fLine%`n, %_logFile%
    ToolTip, % "Focus changed:`n" _fLine, 0, 0, 2
    SetTimer, _RemoveFLTooltip, -5000
return
