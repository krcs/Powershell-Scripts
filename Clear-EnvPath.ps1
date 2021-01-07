<#
.SYNOPSIS
Removes non-existent paths in PATH environment variable.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param()

$reg_path = "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment";
$envPath = (Get-ItemProperty -Path $reg_path | Select-Object -Exp PATH) -split ';'
$result = @()

ForEach ($path in $envPath) {
    if ($path.Length -eq 0) {
        write-host "Empty."
        continue
    }
    if (!(Test-Path $path)) {
        Write-Host "Removed: $path"
    }
    $result += $path
}
$result = $result -join ';'
Set-ItemProperty -PATH $reg_path -Name PATH $result