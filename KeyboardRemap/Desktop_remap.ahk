#Include ../std/ENV.ahk

$F1::Send {Volume_Mute}
$F2::Send {Volume_Down}
$F3::Send {Volume_Up}
$#F1::Send {F1} ; Required for vscode
$#F2::Send {F2} ; Required for vscode
$#F3::Send {F3} ; Required for vscode

#Include BaseRemap.ahk
