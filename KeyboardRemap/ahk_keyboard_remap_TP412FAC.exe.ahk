#Include ../std/ENV.ahk
#Include BaseRemap.ahk

; Laptop keyboard behavior
#If (laptopKeyboard)
    $#Volume_Mute::       Send {F1}
    $#Volume_Down::       Send {F2}
    $#Volume_Up::         Send {F3}

    $*+Volume_Mute::      Send {Blind}{F1}
    $*+Volume_Down::      Send {Blind}{F2}
    $*+Volume_Up::        Send {Blind}{F3}

    $*!Volume_Mute::      Send {Blind}{F1}
    $*!Volume_Down::      Send {Blind}{F2}
    $*!Volume_Up::        Send {Blind}{F3}

    $*^Volume_Mute::      Send {Blind}{F1}
    $*^Volume_Down::      Send {Blind}{F2}
    $*^Volume_Up::        Send {Blind}{F3}

    $F1::                 Send {Blind}{F1}
    $F2::                 Send {Blind}{F2}
    $F3::                 Send {Blind}{F3}

    $#F1::                Send {F1} ; Required for vscode
    $#F2::                Send {F2} ; Required for vscode
    $#F3::                Send {F3} ; Required for vscode

    $Insert::             Send {Media_Next}
    $+Insert::            Send {Media_Prev}
    Pause::               Send {Media_Play_Pause}
    $#Insert::            Send {Insert}

    ; Swap top row fn functionality
    $*Home::              Send {Blind}{F9}
    $*F9::                Send {Blind}{Home}

    $*End::               Send {Blind}{F10}
    $*F10::               Send {Blind}{End}

    $*PgUp::              Send {Blind}{F11}
    $*F11::               Send {Blind}{PgUp}

    $*PgDn::              Send {Blind}{F12}
    $*F12::               Send {Blind}{PgDn}

#If  ; end if directive

; External keyboard behavior
#If !(laptopKeyboard)
    $F1::                 Send {Volume_Mute}
    $F2::                 Send {Volume_Down}
    $F3::                 Send {Volume_Up}

    $#F1::                Send {F1}
    $#F2::                Send {F2}
    $#F3::                Send {F3}

    $ScrollLock::         Send {Media_Next}
    $+ScrollLock::        Send {Media_Prev}
    Pause::               Send {Media_Play_Pause}
    $#ScrollLock::        Send {ScrollLock}

#If  ; end if directive
