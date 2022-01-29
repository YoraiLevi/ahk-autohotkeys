#Include ../std/ENV.ahk
#Include balcon.ahk
#Include libsamplerate.ahk

extract_resources(){
    FileCreateDir % A_ScriptDir "/balcon/"
    if !FileExist(A_ScriptDir "/balcon/" libsamplerate_Get("Name"))
        Extract_libsamplerate(A_ScriptDir "/balcon/" libsamplerate_Get("Name"))
    if !FileExist(A_ScriptDir "/balcon/" balcon_Get("Name"))
        Extract_balcon(A_ScriptDir "/balcon/" balcon_Get("Name"))
}