<+<#F23::
    global LShiftState
    Send, {Blind}{LWin Up}
    if (!IsSet(LShiftState) || !(LShiftState>1))
        Send, {Blind}{LShift Up}
    Send, {Blind}{RCtrl Down}
return

<+<#F23 Up::
    global LShiftState
    Send, {Blind}{RCtrl Up}
return

~*LShift::
    global LShiftState, ShiftPressCount
    if (!IsSet(LShiftState)){
        LShiftState := 0
    }
    if (!IsSet(ShiftPressCount)){
        ShiftPressCount := 0
    }
    ; Check if this is a repeated press by checking prior hotkey
    if ((A_PriorHotkey == "$~*LShift" || A_PriorHotkey == "$~*LShift Up") && A_PriorKey == "LShift") {
        ShiftPressCount += 1
    } else {
        ShiftPressCount := 1
    }

    ; Reset if pressed 5 times in succession
    if (ShiftPressCount >= 5) {
        LShiftState := 0
        ShiftPressCount := 0
        Send, {Blind}{LShift Up}
        return
    }
    LShiftState += 1
    if (LShiftState > 2) {
        LShiftState := 2
    }
return

$~*LShift Up::
    global LShiftState
    if (!IsSet(LShiftState)){
        LShiftState := 0
    }

    ; If physical state is up, force state to be up
    if (!GetKeyState("LShift", "P")) {
        LShiftState := 0
        Send, {Blind}{LShift Up}
        return
    }

    LShiftState -= 1
    if (LShiftState < 0){
        LShiftState := 0
    }

    if(!IsSet(ResetLShiftState)){
        ResetLShiftState := 0
    }
    if(((A_PriorHotkey == "$~*LShift" || A_PriorHotkey == "$~*LShift Up") && A_PriorKey == "LShift")){
        ResetLShiftState += 1
    }
    else{
        ResetLShiftState := 0
    }
    if(ResetLShiftState > 5){
        LShiftState := 0
        ResetLShiftState := 0
        Send, {Blind}{LShift Up}
        return
    }

    if(LShiftState > 0){
        Send, {Blind}{LShift Down}
    }
Return