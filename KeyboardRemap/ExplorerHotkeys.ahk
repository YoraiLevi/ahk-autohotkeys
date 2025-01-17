#Include ../std/ENV.ahk
#Persistent
; Win+E hotkey
#e::
; Check if Explorer window exists
if WinExist("ahk_class CabinetWClass")
{
    ; Activate the existing Explorer window
    WinActivate
    ; Send Ctrl+T to open new tab
    Send ^t
}
else
{
    ; Start a new Explorer window
    Run explorer.exe
    
    ; Wait for the window to appear and be ready
    WinWait ahk_class CabinetWClass
    WinActivate
}
return