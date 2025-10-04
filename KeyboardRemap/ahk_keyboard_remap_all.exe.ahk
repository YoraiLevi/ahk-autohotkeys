#Include ../std/ENV.ahk
#Include BaseRemap.ahk

$F1:: Send { Volume_Mute }
$F2:: Send { Volume_Down }
$F3:: Send { Volume_Up }
$#F1:: Send { F1 } ; Required for vscode
$#F2:: Send { F2 } ; Required for vscode
$#F3:: Send { F3 } ; Required for vscode

$ScrollLock:: Send { Media_Next }
Pause:: Send { Media_Play_Pause }
$#ScrollLock:: Send { ScrollLock }

; --- Window Maximize/Restore Helper Function ---
ToggleMaximizeRestore() {
    local windowState
    WinGet, windowState, MinMax, A
    if (windowState = 1)
        WinRestore, A
    else
        WinMaximize, A
}

; F11 and various Win+Arrow combos toggle maximize/restore
F11::
#Down::
#Up::
#^Down::
#^Up::
#+Down::
#+Up::
    ToggleMaximizeRestore()
return

$#F11:: Send { F11 }

; Win+Alt+Up: Maximize if not maximized, else restore
#!Up::
    WinGet, windowState, MinMax, A
    if (windowState != 1)
        Send, #{Up}
    else
        ToggleMaximizeRestore()
return

; Win+Alt+Down: Restore if maximized, else maximize
#!Down::
    WinGet, windowState, MinMax, A
    if (windowState = 1)
        Send, #{Down}
    else
        ToggleMaximizeRestore()
return

; Default - Win+Alt+Left/Right moves windows in thirds
; Win+Left/Right => Win+Alt+Left/Right, move in thirds instead of in halfs/quarters
#Left:: Send, #!{Left}
#Right:: Send, #!{Right}
; Default - Win+Arrows moves windows in halfs/quarters
; Win+Alt+Left/Right => Win+Left/Right, move in halfs/quarters instead of in thirds
#!Left:: Send, #{Left}
#!Right:: Send, #{Right}

; Default - Win+Shift+Left/Right Moves the window across monitors
; Ctrl+Win+Left/Right => Shift+Win+Left/Right
#^Left:: Send, #+{Left}
#^Right:: Send, #+{Right}

; F12 to cycle windows through monitors
$F12:: Send, #+{Right}
$+F12:: Send, #+{Left}
$#F12:: Send {F12}
