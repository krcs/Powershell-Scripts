<#
.SYNOPSIS
Creates a README.md file containing information collected from scripts.

#>
$folder = "."
$result_md = "README.md"

$title = "PowerShell-Scripts"
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

$keywords = @(
    "SYNOPSIS",
    "DESCRIPTION",
    "PARAMETER",
    "EXAMPLE",
    "INPUTS",
    "OUTPUTS",
    "NOTES",
    "LINK",
    "COMPONENT",
    "ROLE",
    "FUNCTIONALITY",
    "FORWARDHELPTARGETNAME",
    "FORWARDHELPCATEGORY",
    "REMOTEHELPRUNSPACE",
    "EXTERNALHELP"
)

$content = Get-Content "Create-READMEmd.ps1" -Raw
$helpCommentMatches = [regex]::Matches($content, "<#(.+?)#>", 16)




function GetHelp($fileName) {
    $content = Get-Content $fileName -Raw
    $helpCommentMatches = [regex]::Matches($content, "<#(.+?)#>", 16)

    if ($helpCommentMatches.Count -lt 0) { 
        Write-Warning  "$fileName - No description." 
    }

    $helpComment = $helpCommentMatches[0].Value
    
    $pattern = "\.({0})" -f ($keywords -join '|')

    $matches = [regex]::Match($helpComment, $pattern)
    $helpTable = @()

    while ($matches.Success) {
        $item = "" | Select-Object Keyword, Text
        $item.Keyword = $matches.Value.Substring(1)
        $startIdx = $matches.Index + $matches.Value.Length
        $matches = $matches.NextMatch()
        $endIdx = $matches.Index - $startIdx
        if (!($matches.Success)) {
            $endIdx = $helpComment.Length - 2 - $startIdx
        }
        $item.Text = $helpComment.Substring($startIdx, $endIdx)
        $item.Text = $item.Text.Trim()
        $helpTable += $item
    }
    return $helpTable
}

$result = [System.Text.StringBuilder]::new()

[void]$result.AppendLine("# $title")
[void]$result.AppendLine()

Get-ChildItem $folder -Filter "*.ps1" | ForEach-Object {
    $text = GetHelp($_.FullName) | Where-Object { $_.Keyword -eq "SYNOPSIS" } | Select-Object -ExpandProperty Text -First 1
    if ($text -eq $null) {
        continue
    }
    [void]$result.AppendLine("## {0}" -f [IO.Path]::GetFileNameWithoutExtension($_.Name))
    [void]$result.AppendLine("**File name:** {0}" -f $_.Name)
    [void]$result.AppendLine()
    [void]$result.AppendLine("$text")
    [void]$result.AppendLine()
}

$result.ToString() > $result_md