Install
```ps1
$user = "YoraiLevi"
$project = "autohotkeys"
$artifacts = @("main.exe", 'BaseRemap.exe', 'Vivobook_ASUSLaptop TP412FAC_TP412FA.exe')
$latestRelease = Invoke-WebRequest "https://github.com/$user/$project/releases/latest" -Headers @{"Accept"="application/json"}
$json = $latestRelease.Content | ConvertFrom-Json
$latestVersion = $json.tag_name
foreach ($artifact in $artifacts) {
    $artifact = $artifact -replace " ", "."
    $url = "https://github.com/$user/$project/releases/download/$latestVersion/$artifact"
    # $path = [Environment]::GetFolderPath(([Environment+SpecialFolder]::Startup))
    $path = $ENV:UserProfile+"\"+"bin"; mkdir -p $path -ErrorAction SilentlyContinue
    $file_path = $path+"\"+$artifact
    Write- Downloading
    Invoke-WebRequest -Uri $url -OutFile $file_path
}
```