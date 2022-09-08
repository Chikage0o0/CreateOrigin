$PSDefaultParameterValues['Out-File:Encoding'] = "ASCII"
Remove-Item *.mrpack -Force


$version = Read-Host "Please Input version"
if ($version) {
        (Get-Content -path .\pack.toml)`
        -replace '(?<=version = ")[\d\.]+', "$version" | Out-File .\pack.toml
}


foreach ($line in Get-Content -path .\pack.toml) { 
    if ($line -match '(?<=version = ")[\d\.]+') { 
        $version = $matches[0] 
    }
    if ($line -match '(?<=name = ").*(?=")') { 
        $name = $matches[0] 
    } 
}



if (Test-Path -path .\config\bcc.json) {
    (Get-Content -path .\config\bcc.json) `
        -replace '(?<="modpackVersion":")[\d\.]+', "$version" | Out-File .\config\bcc.json
}

if (Test-Path -path .\client-overrides\config\customwindowtitle-client.toml) {
    (Get-Content -path .\client-overrides\config\customwindowtitle-client.toml) `
        -replace '(?<=title = ")[\w\d\.-]*', "$name-$version" | Out-File .\client-overrides\config\customwindowtitle-client.toml
}

 


.\packwiz.exe update -a
.\packwiz.exe refresh
.\packwiz.exe modrinth export --output $name-$version.zip
#Compress-Archive -update "client-overrides", "server-overrides" "$name-$version.zip"
Rename-Item $name-$version.zip $name-$version.mrpack -Force