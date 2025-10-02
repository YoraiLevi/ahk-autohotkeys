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

F11::
WinGet, windowState, MinMax, A
if (windowState = 1) { ; Window is maximized
    WinRestore, A
} else { ; Window is not maximized (restored or minimized)
    WinMaximize, A
}
return

$#F11:: Send { F11 }