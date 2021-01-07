<#
.SYNOPSIS
Installing or updating 7zip.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param()
function IsInEnvPath ($path) {
    if ($path.Length -eq 0) {
        return $false;
    }
    if ($env:path | select-string -SimpleMatch $path) {
        return $true;
    }
    return $false;
}

function AddToEnvPath($folder) {
    if (-not (Test-Path $folder -PathType Container)) {
        throw [System.IO.DirectoryNotFoundException] "$folder folder does not exist."
    }
    if (IsInEnvPath($folder)) {
        return;
    }
    $environmentRegistryKey = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'
    $oldPath = (Get-ItemProperty -Path $environmentRegistryKey -Name PATH).Path
    $newPath = "$oldPath;$folder"
    $env:path += ";$folder";
    Set-ItemProperty -Path $environmentRegistryKey -Name PATH -Value $newPath;
}

function Install-7zip {
    $7zdomain = "7-zip.org";
    $outfile = Join-Path $env:Temp "7z.msi"
    
    $downloadPage = Invoke-WebRequest $7zdomain/download.html
    $href = ""

    if ([Environment]::Is64BitProcess) {
        $href = $downloadPage.Links | Where-Object { $_.innerHTML -eq 'Download' -and $_.outerHTML -like '*-x64.msi*' } | Select-Object outerHTML -First 1
    } else {
        $href = $downloadPage.Links | Where-Object { $_.innerHTML -eq 'Download' -and $_.outerHTML -like '*.msi*' } | Select-Object outerHTML -First 1
    }

    $msi=[regex]::Match($href.outerHTML, '".+"').Value -replace "\`""
    $downloadLink = "http://$7zdomain/$msi"

    Invoke-WebRequest $downloadLink -OutFile $outfile
    Start-Process "$outfile" -ArgumentList "/passive" -Wait
   
    # add to $env:path
    AddToEnvPath "C:\Program Files\7-Zip";
    
    if (Test-Path $outfile) {
        Remove-Item $outfile
    }
}

Install-7zip