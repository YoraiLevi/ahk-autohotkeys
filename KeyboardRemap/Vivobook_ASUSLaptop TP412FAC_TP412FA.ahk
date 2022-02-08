#Include ../std/ENV.ahk
#include Lib\AutoHotInterception.ahk

; This Script keeps laptop builtin keyboard functioning as normal regardless of ahk remapping
AHI := new AutoHotInterception()
keyboardId := AHI.GetDeviceIdFromHandle(false, "ACPI\VEN_MSFT&DEV_0001") ;laptop builtin keyboard

AHI.SubscribeKey(keyboardId, GetKeySC("Volume_Mute"), true, Func("v_mute"))
AHI.SubscribeKey(keyboardId, GetKeySC("Volume_Down"), true, Func("v_down"))
AHI.SubscribeKey(keyboardId, GetKeySC("Volume_Up"), true, Func("v_up"))
AHI.SubscribeKey(keyboardId, GetKeySC("F1"), true, Func("fone"))
AHI.SubscribeKey(keyboardId, GetKeySC("F2"), true, Func("ftwo"))
AHI.SubscribeKey(keyboardId, GetKeySC("F3"), true, Func("fthree"))

AHI.SubscribeKey(keyboardId, GetKeySC("Home"), true, Func("home"))
AHI.SubscribeKey(keyboardId, GetKeySC("End"), true, Func("end"))
AHI.SubscribeKey(keyboardId, GetKeySC("PgUp"), true, Func("pgup"))
AHI.SubscribeKey(keyboardId, GetKeySC("PgDn"), true, Func("pgdn"))
AHI.SubscribeKey(keyboardId, GetKeySC("F9"), true, Func("fnine"))
AHI.SubscribeKey(keyboardId, GetKeySC("F10"), true, Func("ften"))
AHI.SubscribeKey(keyboardId, GetKeySC("F11"), true, Func("feleven"))
AHI.SubscribeKey(keyboardId, GetKeySC("F12"), true, Func("ftwelve"))

; Include general keybinds
#Include BaseRemap.ahk
v_up(state){
    If (state)
        Send, {Volume_Up down}
    else
        Send, {Volume_Up up}

}
v_down(state){
    If (state)
        Send, {Volume_Down down}
    else
        Send, {Volume_Down up}

}
v_mute(state){
    If (state)
        Send, {Volume_Mute down}
    else
        Send, {Volume_Mute up}

}
fone(state){
    If (state)
        Send, {F1 down}
    else
        Send, {F1 up}

}
ftwo(state){
    If (state)
        Send, {F2 down}
    else
        Send, {F2 up}

}
fthree(state){
    If (state)
        Send, {F3 down}
    else
        Send, {F3 up}

}

home(state){
    If (state)
        Send, {F9 down}
    else
        Send, {F9 up}

}
end(state){
    If (state)
        Send, {F10 down}
    else
        Send, {F10 up}

}
pgup(state){
    If (state)
        Send, {F11 down}
    else
        Send, {F11 up}

}
pgdn(state){
    If (state)
        Send, {F12 down}
    else
        Send, {F12 up}

}

fnine(state){
    If (state)
        Send, {Home down}
    else
        Send, {Home up}

}
ften(state){
    If (state)
        Send, {End down}
    else
        Send, {End up}

}
feleven(state){
    If (state)
        Send, {PgUp down}
    else
        Send, {PgUp up}

}
ftwelve(state){
    If (state)
        Send, {PgDn down}
    else
        Send, {PgDn up}

}