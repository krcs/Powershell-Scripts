<# 
.SYNOPSIS
Script will reinstall smartcard driver. Fix for Yubikey/GPG/OpenVPN.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param()
$pathToDevcon_x64 = "C:\Program Files (x86)\Windows Kits\10\Tools\x64\devcon.exe"

function CleanSCFILTER() {
    & $pathToDevcon_x64 findall "*SCFILTER*" | Where-Object { $_ -like '*SCFILTER*' } | ForEach-Object {
        $id = '@'+$_.Split(':')[0].Trim();
        $status = (& $pathToDevcon_x64 status $id) -Split '[\n]'
        if ($status[2] -notlike '*Driver is running*') {
            $driver = '@'+$status[0].Trim()
            & $pathToDevcon_x64 remove $driver
        }
    }
}

function RestartSmartcard() {
    & $pathToDevcon_x64 findall * | Where-Object { $_ -like '*WUDF*' } |
    ForEach-Object {
        $id =  '@'+($_ -split ':')[0].Trim()
        & $pathToDevcon_x64 remove $id
    }
}

if (!(Test-Path $pathToDevcon_x64)) {
    Write-Error "Devcon not found: $pathToDevcon_x64"
    exit
}

CleanSCFILTER;
RestartSmartcard;
& $pathToDevcon_x64 rescan
