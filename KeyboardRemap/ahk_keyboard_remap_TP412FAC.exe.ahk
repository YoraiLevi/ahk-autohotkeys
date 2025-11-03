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

$*Home::
    if(laptopKeyboard){
        Send {Blind}{F9}
    }
    else{
        Send {Blind}{Home}
    }
Return
$*F9::
    if(laptopKeyboard){
        Send {Blind}{Home}
    }
    else {
        Send {Blind}{F9}
    }
Return

$*End::
    if (laptopKeyboard){
        Send {Blind}{F10}
    }
    else{
        Send {Blind}{End}
    }
Return
$*F10::
    if (laptopKeyboard){
        Send {Blind}{End}
    }
    else{
    }

Return
$*PgUp::
    if (laptopKeyboard){
        Send {Blind}{F11}
    }
    else{
        Send {Blind}{PgUp}
    }

Return
$*F11::
    if (laptopKeyboard){
        Send {Blind}{PgUp}
    }
    else{
        Send {Blind}{F11}
    }

Return
$*PgDn::
    if (laptopKeyboard){
        Send {Blind}{F12}
    }
    else{
        Send {Blind}{PgDn}
    }
Return
$*F12::
    if (laptopKeyboard){
        Send {Blind}{PgDn}
    }
    else{
        Send {Blind}{F12}
    }
