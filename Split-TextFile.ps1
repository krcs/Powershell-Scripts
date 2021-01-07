<# 
.SYNOPSIS
Split text file into separate files with specified number of lines.

.LINK
https://github.com/krcs/Powershell-Scripts

#>

Param( 
    [Parameter(Mandatory=$true)][string] $source = "",
    [Parameter(Mandatory=$true)][int] $lines = 0,
    [Parameter(Mandatory=$false)][string]$destinationFolder = ""
)

if ($destinationFolder.Length -eq 0) {
    $destinationFolder = Split-Path $source
}

$destinationName = [System.Io.Path]::GetFileNameWithoutExtension($source);
$destinationExtenstion = [System.Io.Path]::GetExtension($source);

$content = Get-Content $Source;
$counter = 1
$fileNumber = 1;

$content | % {
    $fileName = "{0}_{1}{2}" -f $destinationName, $fileNumber, $destinationExtenstion

    Add-Content -Path $fileName -Value $_

    if ($counter % $lines -eq 0 -or $counter -eq $content.Length) {
        $fileNumber++
    }
    $counter++
}
