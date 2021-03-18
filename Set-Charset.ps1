<# 
.SYNOPSIS
Converts file encoding.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param (
    [Parameter(Mandatory=$true,
     ValueFromPipeline = $true)]
    [Alias("in")]
    [string]$InputFile,
    [Alias("out")]
    [string]$OutputFile,
    [ValidateSet(
        "big5",
        "euc-jp",
        "euc-kr",
        "gb2312",
        "iso-2022-jp",
        "iso-2022-kr",
        "iso-8859-1",
        "iso-8859-2",
        "iso-8859-3",
        "iso-8859-4",
        "iso-8859-5",
        "iso-8859-6",
        "iso-8859-7",
        "iso-8859-8",
        "iso-8859-9",
        "koi8-r",
        "shift-jis",
        "us-ascii",
        "utf-7",
        "utf-8",
        "windows-1250",
        IgnoreCase = $true)]
    [string]$SourceCharset = "utf-8",
    [ValidateSet(
        "big5",
        "euc-jp",
        "euc-kr",
        "gb2312",
        "iso-2022-jp",
        "iso-2022-kr",
        "iso-8859-1",
        "iso-8859-2",
        "iso-8859-3",
        "iso-8859-4",
        "iso-8859-5",
        "iso-8859-6",
        "iso-8859-7",
        "iso-8859-8",
        "iso-8859-9",
        "koi8-r",
        "shift-jis",
        "us-ascii",
        "utf-7",
        "utf-8",
        "windows-1250",
        IgnoreCase = $true)]
    [string]$DestinationCharset = "windows-1250"
)

$InputFile = Resolve-Path $InputFile

if ($OutputFile.length -eq 0) {
    $OutputFile = $InputFile;
} else {
    $directory = [System.IO.Path]::GetDirectoryName($OutputFile);
    $file = [System.IO.Path]::GetFileName($OutputFile);
    $OutputFile = Join-Path $(Resolve-Path $directory) $file
}

$adoStream = New-Object -ComObject "ADODB.Stream";
$adoStream.Charset = $SourceCharset;
$adoStream.Open();
$adoStream.LoadFromFile($InputFile);
$content = $adoStream.ReadText(-1);
$adoStream.Close();

$adoStream.Charset = $DestinationCharset;
$adoStream.Open();
$adoStream.WriteText($content);
$adoStream.SaveToFile($OutputFile,2);
$adoStream.Close();

Write-Output $OutputFile
