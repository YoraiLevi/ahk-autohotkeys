Install
```ps1
$owner = "YoraiLevi"
$repo = "ahk-autohotkeys"
$baseboard_product = Get-CimInstance -Class Win32_BaseBoard | Select -ExpandProperty Product

$releasesURL = "https://api.github.com/repos/$OWNER/$REPO/releases?per_page=1"
$latestRelease = Invoke-WebRequest -Uri $releasesURL -Headers @{"Accept"="application/json"}
$json = $latestRelease.Content | ConvertFrom-Json

$path = $ENV:UserProfile+"\"+"bin"; mkdir -p $path -ErrorAction SilentlyContinue
$artifacts = $json.assets | %{ @{Uri=$_.browser_download_url;Outfile=(Join-Path $path $_.Name)}} 

# Download
Stop-Process -Name "*_ahk"
$artifacts | % { Write-Information "Downloading $($_.Name) to $($_.Outfile)"; Invoke-WebRequest @_ }
$artifacts.OutFile | %{if (($baseboard_product -in $_) -or "_all_" -in $_) {Start-Process $_} }
```