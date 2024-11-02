[![Building release for AHK scripts](https://github.com/YoraiLevi/ahk-autohotkeys/actions/workflows/releaseAHK.yml/badge.svg)](https://github.com/YoraiLevi/ahk-autohotkeys/actions/workflows/releaseAHK.yml)
```ps1
$owner = "YoraiLevi"
$repo = "ahk-autohotkeys"
$baseboard_product = Get-CimInstance -Class Win32_BaseBoard | Select -ExpandProperty Product
$path = Join-Path $ENV:UserProfile "bin"; mkdir -p $path -ErrorAction SilentlyContinue
$request = @{Headers = @{"Accept"="application/json"}; Uri = "https://api.github.com/repos/$OWNER/$REPO/releases?per_page=1"}
# Get assets
$json = Invoke-WebRequest @request | Select -ExpandProperty Content | ConvertFrom-Json
$assets = $json.assets | %{ @{Uri=$_.browser_download_url; Outfile=(Join-Path $path $_.Name)}} 
# Download
Stop-Process -Name "*_ahk"
$assets | % { Write-Information "Downloading $($_.Name) to $($_.Outfile)"; Invoke-WebRequest @_ }
$assets.OutFile | % { if( ($_ -match $baseboard_product) -or ($_ -match "_all_") ) {Start-Process $_} }
```