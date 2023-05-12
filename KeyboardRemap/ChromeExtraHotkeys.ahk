#Include ../std/ENV.ahk
#IfWinActive ahk_exe msedge.exe

/*
  Wait for a window to be created, returns 0 on timeout and ahk_id otherwise
  Parameter are the same as WinWait, see http://ahkscript.org/docs/commands/WinWait.htm
  Forum: http://ahkscript.org/boards/viewtopic.php?f=6&t=1274&p=8517#p8517
*/
WinWaitCreated( WinTitle:="", WinText:="", Seconds:=0, ExcludeTitle:="", ExcludeText:="" ) {
    ; HotKeyIt - http://ahkscript.org/boards/viewtopic.php?t=1274
    static Found := 0, _WinTitle, _WinText, _ExcludeTitle, _ExcludeText 
         , init := DllCall( "RegisterShellHookWindow", "UInt",A_ScriptHwnd )
         , MsgNum := DllCall( "RegisterWindowMessage", "Str","SHELLHOOK" )
         , cleanup:={base:{__Delete:"WinWaitCreated"}}
  If IsObject(WinTitle)   ; cleanup
    return DllCall("DeregisterShellHookWindow","PTR",A_ScriptHwnd)
  else if (Seconds <> MsgNum){ ; User called the function
    Start := A_TickCount, _WinTitle := WinTitle, _WinText := WinText
    ,_ExcludeTitle := ExcludeTitle, _ExcludeText := ExcludeText
    ,OnMessage( MsgNum, A_ThisFunc ),  Found := 0
    While ( !Found && ( !Seconds || Seconds * 1000 < A_TickCount - Start ) ) 
      Sleep 16                                                         
    Return Found,OnMessage( MsgNum, "" )
  }
  If ( WinTitle = 1   ; window created, check if it is our window
    && ExcludeTitle = A_ScriptHwnd
    && WinExist( _WinTitle " ahk_id " WinText,_WinText,_ExcludeTitle,_ExcludeText))
    WinWait % "ahk_id " Found := WinText ; wait for window to be shown
}

^f::^g ; traverse search results with ctrl+f
^g::Send {CtrlDown}{t}{CtrlUp}{AltDown}{g}{AltUp} ; Alt + G - new tab in new group
^t::Send {CtrlUp}{AltDown}{t}{AltUp} ; Ctrl + T - new tab in this group, this is required for ^g to work
; !t::Send {AltUp}{CtrlDown}{t}{CtrlUp}{AltDown}{g} ; Alt + T - new tab in new group
^n::Send {CtrlDown}{n}{CtrlUp}{AltDown}{g}{AltUp} ; Ctrl + N - new window in new group
^/::Send ^0
^\::
    WinGet, winid ,, A
    WinActivate ahk_id %winid%
    Send {CtrlDown}{n}{CtrlUp}{AltDown}{g}{AltUp}
    WinWaitCreated("ahk_exe msedge.exe")
    WinGet, new_winid ,, A
    Gosub, GetCurrentMonitorWorkArea
    WinGet, MinMaxState, MinMax, ahk_id %winid%
    if (MinMaxState = 1)	; window is maximized
      WinRestore, ahk_id %winid%	; unmaximize it
    WinMove, ahk_id %winid%,, _Left-10, _Top, _Width//2+20, _Height+10 ; move left
    WinGet, MinMaxState, MinMax, ahk_id %new_winid%
    if (MinMaxState = 1)	; window is maximized
      WinRestore, ahk_id %new_winid%	; unmaximize it
    WinMove, ahk_id %new_winid%,, _Width//2-10, _Top, _Width//2+20, _Height+10 ; move right
    Return
#If

;---------------------------------------------------------------------------
GetCurrentMonitorWorkArea:
;---------------------------------------------------------------------------
    SysGet, _, MonitorWorkArea
    _Width  := _Right - _Left
    _Height := _Bottom - _Top
Return