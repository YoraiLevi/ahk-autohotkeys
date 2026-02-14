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
$#Left:: Send, {Blind}!{Left}
$#Right:: Send, {Blind}!{Right}
; Default - Win+Arrows moves windows in halfs/quarters
; Win+Alt+Left/Right => Win+Left/Right, move in halfs/quarters instead of in thirds
; Very slow?
; $#!Left:: Send, #{Left}
; $#!Right:: Send, #{Right}

; Default - Win+Shift+Left/Right Moves the window across monitors
; Ctrl+Win+Left/Right => Shift+Win+Left/Right
#^Left:: Send, #+{Left}
#^Right:: Send, #+{Right}

; F12 to cycle windows through monitors
$F12:: Send, #+{Right}
$+F12:: Send, #+{Left}
$#F12:: Send {F12}


$#F10::
    Send, #z
    WinWaitActive, ahk_class XamlExplorerHostlslandWindow,, 0.75
    WinGet, newPopupID, ID, A
    WinGetTitle, newPopupTitle, ahk_id %newPopupID%
    if (newPopupTitle = "") {
        Send 42
    } else {
        ; Retry the hotkey once if not successful
        Send, #z
        WinWaitActive, ahk_class XamlExplorerHostlslandWindow,, 0.75
        WinGet, retryPopupID, ID, A
        WinGetTitle, retryPopupTitle, ahk_id %retryPopupID%
        if (retryPopupTitle = "") {
            Send 42
        } else {
            ToolTip, % "Not PopupHost - retried"
        }
    }
return


$#F9::
    Send, #z
    WinWaitActive, ahk_class XamlExplorerHostlslandWindow,, 0.75
    WinGet, newPopupID, ID, A
    WinGetTitle, newPopupTitle, ahk_id %newPopupID%
    if (newPopupTitle = "") {
        Send 41
    } else {
        ; Retry the hotkey once if not successful
        Send, #z
        WinWaitActive, ahk_class XamlExplorerHostlslandWindow,, 0.75
        WinGet, retryPopupID, ID, A
        WinGetTitle, retryPopupTitle, ahk_id %retryPopupID%
        if (retryPopupTitle = "") {
            Send 41
        } else {
            ToolTip, % "Not PopupHost - retried"
        }
    }
return