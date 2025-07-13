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

$*Home::Send {Blind}{F9}
$*F9::Send {Blind}{Home}

$*End::Send {Blind}{F10}
$*F10::Send {Blind}{End}

$*PgUp::Send {Blind}{F11}
$*F11::Send {Blind}{PgUp}

$*PgDn::Send {Blind}{F12}
$*F12::Send {Blind}{PgDn}
