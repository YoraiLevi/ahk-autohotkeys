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

Home::F9
End::F10
PgUp::F11
PgDn::F12

F9::Home
F10::End
F11::PgUp
F12::PgDn
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
