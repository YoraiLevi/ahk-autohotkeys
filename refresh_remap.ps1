# Auto-detect system by board name
$systemName = if ($ENV:SYSTEM_NAME) { $ENV:SYSTEM_NAME } else { (Get-WmiObject -class Win32_BaseBoard).Product }

# Kill ahk_REMAP.exe and the keyboard remap .ahk script
$killed = 0
taskkill /IM "ahk_REMAP.exe" /F 2>$null; if ($LASTEXITCODE -eq 0) { Write-Host "Killed ahk_REMAP.exe"; $killed++ }
taskkill /IM "ahk_keyboard_remap_$systemName.exe" /F 2>$null; if ($LASTEXITCODE -eq 0) { Write-Host "Killed ahk_keyboard_remap_$systemName.exe"; $killed++ }
taskkill /IM "ahk_keyboard_remap_all.exe" /F 2>$null; if ($LASTEXITCODE -eq 0) { Write-Host "Killed ahk_keyboard_remap_all.exe"; $killed++ }
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*ahk_keyboard_remap*" -or $_.CommandLine -like "*ahk_REMAP*" } | ForEach-Object {
    Write-Host "Killed PID $($_.ProcessId): $($_.Name)"
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    $killed++
}
if ($killed -eq 0) { Write-Host "No remap processes were running" }
Start-Sleep -Milliseconds 200

# Start keyboard remap: system-specific if exists, else fallback to all
$kbRemapDir = Join-Path $PSScriptRoot "KeyboardRemap"
$kbRemapScript = Join-Path $kbRemapDir "ahk_keyboard_remap_$systemName.exe.ahk"
if (-not (Test-Path $kbRemapScript)) {
    $kbRemapScript = Join-Path $kbRemapDir "ahk_keyboard_remap_all.exe.ahk"
}
$ahkExe = "C:\Program Files\AutoHotkey\AutoHotkey.exe"
if (-not (Test-Path $ahkExe)) { $ahkExe = "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" }
Start-Process -FilePath $ahkExe -ArgumentList "`"$kbRemapScript`"" -WorkingDirectory $kbRemapDir
Write-Host "Started $kbRemapScript"
