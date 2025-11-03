#Include ../std/ENV.ahk
#Include BaseRemap.ahk

; Winkey instead of fn?
$#Volume_Mute::Send {F1}
$#Volume_Down::Send {F2}
$#Volume_Up::Send {F3}
; Modifier + Volume = Fkey
$*+Volume_Mute::Send {Blind}{F1}
$*+Volume_Down::Send {Blind}{F2}
$*+Volume_Up::Send {Blind}{F3}
$*!Volume_Mute::Send {Blind}{F1}
$*!Volume_Down::Send {Blind}{F2}
$*!Volume_Up::Send {Blind}{F3}
$*^Volume_Mute::Send {Blind}{F1}
$*^Volume_Down::Send {Blind}{F2}
$*^Volume_Up::Send {Blind}{F3}