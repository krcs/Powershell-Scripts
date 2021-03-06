<# 
.SYNOPSIS
This script will download and upgrade Sysinternals Suit.
Source : http://download.sysinternals.com/files/SysinternalsSuite.zip

.LINK
https://github.com/krcs/Powershell-Scripts

#>
Param( 
    [string] $destination = "$Env:SYS\SysinternalsSuite"
)

$suitZipFile = "$Env:TEMP\sysinternals.zip";
$downloadURL = "http://download.sysinternals.com/files/SysinternalsSuite.zip";

if (!(Test-Path $destination)) { Write-host -ForeGroundColor Red "$destination does not exists."; exit; }

Write-Output "-=- Sysinternals update -=-"
Write-Output "Downloading file: $downloadURL";

if (!(Test-Path $suitZipFile)) {
    Invoke-WebRequest $downloadURL -OutFile $suitZipFile
} else {
    Write-Warning "$suitZipFile already exists."
}

Write-Output "Extracting from: $suitZipFile";

Expand-Archive -Path $suitZipFile -DestinationPath $destination -Force

if ($LASTEXITCODE -eq 0) {
    Remove-Item "$Env:TEMP\sysinternals.zip"
}
