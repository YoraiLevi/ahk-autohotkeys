global selection
GetSelectedText() {
    global
    tmp = %ClipboardAll% ; save (c)
    Clipboard = ; clear (c)
    sleep 50
    Sendinput ^c ; (simute)) Ctrl+C (=selection in clipboard)
    ClipWait, 0, 1 ; wait until clipboard contains data
    EL := ErrorLevel ; Zero if clipboard not empty, else one
    if (EL = 0) {
        ClipBoard = %ClipBoard% ; maybe needed, while you use second parameter for WinWait (waiting for pure text input)
        selection := Clipboard ; save the content of the clipboard
    }
    else
        selection := ""
    Clipboard = %tmp% ; restore old content of the clipboard
}