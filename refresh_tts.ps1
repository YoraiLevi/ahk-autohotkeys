# Kill TTS: compiled exe or AHK running the TTS script
$killed = 0
taskkill /IM "ahk_TTS_all.exe" /F 2>$null; if ($LASTEXITCODE -eq 0) { Write-Host "Killed ahk_TTS_all.exe"; $killed++ }
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*ahk_TTS*" } | ForEach-Object {
    Write-Host "Killed PID $($_.ProcessId): $($_.Name)"
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    $killed++
}
if ($killed -eq 0) { Write-Host "No TTS processes were running" }
Start-Sleep -Milliseconds 200

# Start TTS from its folder
$ttsDir = Join-Path $PSScriptRoot "TTS"
$ttsScript = Join-Path $ttsDir "ahk_TTS_all.exe.ahk"
$ahkExe = "C:\Program Files\AutoHotkey\AutoHotkey.exe"
if (-not (Test-Path $ahkExe)) { $ahkExe = "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" }
Start-Process -FilePath $ahkExe -ArgumentList "`"$ttsScript`"" -WorkingDirectory $ttsDir
Write-Host "Started $ttsScript"
