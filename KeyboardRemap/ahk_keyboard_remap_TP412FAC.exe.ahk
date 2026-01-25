#Include ../std/ENV.ahk
#Include BaseRemap.ahk

; Winkey instead of fn?
$#Volume_Mute::
    if (laptopKeyboard) {
        Send {F1}
    }
Return

$#Volume_Down::
    if (laptopKeyboard) {
        Send {F2}
    }
Return

$#Volume_Up::
    if (laptopKeyboard) {
        Send {F3}
    }
Return
; Modifier + Volume = Fkey
$*+Volume_Mute::
    if (laptopKeyboard) {
        Send {Blind}{F1}
    }
Return
$*+Volume_Down::
    if (laptopKeyboard) {
        Send {Blind}{F2}
    }
Return
$*+Volume_Up::
    if (laptopKeyboard) {
        Send {Blind}{F3}
    }
Return

$*!Volume_Mute::
    if (laptopKeyboard) {
        Send {Blind}{F1}
    }
Return
$*!Volume_Down::
    if (laptopKeyboard) {
        Send {Blind}{F2}
    }
Return
$*!Volume_Up::
    if (laptopKeyboard) {
        Send {Blind}{F3}
    }
Return

$*^Volume_Mute::
    if (laptopKeyboard) {
        Send {Blind}{F1}
    }
Return
$*^Volume_Down::
    if (laptopKeyboard) {
        Send {Blind}{F2}
    }
Return
$*^Volume_Up::
    if (laptopKeyboard) {
        Send {Blind}{F3}
    }
Return

$F1::
    if (laptopKeyboard) {
    }
    else{
        Send {Volume_Mute}
    }
Return

$F2::
    if (laptopKeyboard) {
        Send {Volume_Down}
    }
    else{
        Send {Volume_Down}
    }
Return

$F3::
    if (laptopKeyboard) {
        Send {Volume_Up}
    }
    else{
        Send {Volume_Up}
    }
Return

$#F1::
    if (laptopKeyboard) {
        Send {F1} ; Required for vscode
    }
    else{
        Send {F1} ; Required for vscode
    }
Return

$#F2::
    if (laptopKeyboard) {
        Send {F2} ; Required for vscode
    }
    else{
        Send {F2} ; Required for vscode
    }
Return

$#F3::
    if (laptopKeyboard) {
        Send {F3} ; Required for vscode
    }
    else{
        Send {F3} ; Required for vscode
    }
Return

$ScrollLock::
    if (laptopKeyboard) {
        Send {Media_Next}
    }
    else{
        Send {Media_Next}
    }
Return

$+ScrollLock::
    if (laptopKeyboard) {
        Send {Media_Prev}
    }
    else{
        Send {Media_Prev}
    }
Return

Pause::
if (laptopKeyboard) {
    Send {Media_Play_Pause}
}
else{
    Send {Media_Play_Pause}
}
Return

$#ScrollLock::
    if (laptopKeyboard) {
        Send {ScrollLock}
    }
    else{
        Send {ScrollLock}
    }
Return

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
