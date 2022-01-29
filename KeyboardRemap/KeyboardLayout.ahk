; https://docs.microsoft.com/en-us/previous-versions/aa912040(v=msdn.10)?redirectedfrom=MSDN
GetKeyboardLanguage(_hWnd=0)
{
    if !_hWnd
        ThreadId=0
    else
        if !ThreadId := DllCall("user32.dll\GetWindowThreadProcessId", "Ptr", _hWnd, "UInt", 0, "UInt")
        return false

    if !KBLayout := DllCall("user32.dll\GetKeyboardLayout", "UInt", ThreadId, "UInt")
        return false

    return (KBLayout & 0xFFFF)
}