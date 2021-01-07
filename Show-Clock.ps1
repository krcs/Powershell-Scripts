<#
.SYNOPSIS
Displays a large clock. You can use it as a screensaver.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param()
$chars = @(
  (
    ('  .sS$$Ss.  '),
    ('.$$$$P?$$$$.'),
    ('S$$$`  `$$$S'),
    ('$$$$    $$$$'),
    ('$$$$    $$$$'),
    ('$$$$    $$$$'),
    ('S$$$.  .$$$S'),
    ('`?$$$ss$$$P`'),
    ('  `?S$$SP`  ')
  ),(
    ('      .s$$$$'),
    ('   .sS$$$$$$'),
    ('.sS$$P`$$$$$'),
    ('       $$$$$'),
    ('       $$$$$'),
    ('       $$$$$'),
    ('       $$$$$'),
    ('       $$$$$'),
    ('       $$$$$')
  ),(
    ('  .sS$$$s.  '),
    ('.$$$$P?$$$$.'),
    ('$$$$`  `$$$$'),
    ('      .d$$$P'),
    ('    .d$$$P` '),
    ('   d$$$P`  .'),
    ('.d$$$P`  .s$'),
    ('$$$$S. .s$$$'),
    ('$$$$$$$$$$$$')
  ),(
    ('  .sS$$$s.  '),
    ('.$$$$P?$$$$.'),
    ('$$$$`  `$$$$'),
    ('        $$S`'),
    ('    $$$$$$  '),
    ('        $$S,'),
    ('S$$$.  .$$$S'),
    ('`?$$$ss$$$P`'),
    ('  `?S$$SP`  ')
  ),(
    ('      .d$$$$'),
    ('    .d$$$$$$'),
    ('  .d$P` $$$$'),
    ('.d$P`   $$$$'),
    ('$$$     $$$$'),
    ('$$$$$$$$$$$$'),
    ('        $$$$'),
    ('        $$$$'),
    ('        $$$$')
  ),(
    ('$$$$$$$$$$$$'),
    ('$$$$    $$$$'),
    ('$$$$        '),
    ('$$$$$$$Ss.  '),
    ('      `?$$$,'),
    ('        ?$$$'),
    ('$$$$.  .d$$$'),
    ('`?$$$ss$$$P`'),
    ('  `?S$$SP`  ')
  ),(  
    ('  .sS$$$s.  '),
    ('.$$$$P?$$$$.'),
    ('$$$$`  `?$$$'),
    ('$$$$        '),
    ('$$$$s$$$Ss, '),
    ('$$$$`  `$$$b'),
    ('S$$$.  .$$$$'),
    ('`?$$$ss$$$P`'),
    ('  `?S$$SP`  ')
  ),(  
    ('$$$$$$$$$$$$'),
    ('$$$$  .$$$$`'),
    ('     .$$$$` '),
    ('    .$$$$`  '),
    ('   .$$$$`   '),
    ('  .$$$$`    '),
    (' .$$$$`     '),
    ('.$$$$`      '),
    ('$$$$`       ')
  ),(  
    ('  .sS$$Ss.  '),
    ('.$$$$P?$$$$.'),
    ('$$$$    $$$$'),
    ('`?$$,  .$$P`'),
    ('  $$$sS$$$  '),
    ('.S$$P` `$$S,'),
    ('$$$$.  .$$$$'),
    ('`?$$$ss$$$P`'),
    ('  `?S$$SP`  ')
  ),(  
    ('  .sS$$Ss.  '),
    ('.$$$$P?$$$$.'),
    ('$$$$`  `$$$$'),
    ('?$$$.  .$$$$'),
    (' `?$$$$$$$$$'),
    ('       `$$$$'),
    ('$$$$.  .$$$$'),
    ('`?$$$ss$$$P`'),
    ('  `?S$$SP`  ')
  ),(
    ('            '),
    ('            '),
    ('     $$     '),
    ('            '),
    ('            '),
    ('            '),
    ('     $$     '),
    ('            '),
    ('            ')
  )
)
$charWidth = $chars[0][0].length
$charHeight = $chars[0].length;
$clockWidth = ($charWidth+1)*8
$x = [int](([console]::LargestWindowWidth-$clockWidth) / 2)
$y = [int](([console]::LargestWindowHeight-[int]$charHeight) / 2)-1
$posx, $posy = $x, $y
$xoffset = $charWidth+1
Clear-Host;
[console]::CursorVisible = $false;
while ($true) {
    if ([console]::KeyAvailable) {
        [console]::ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        break;
    }
    if ([console]::LargestWindowWidth -lt $x+$clockWidth+2) {
        Clear-Host;
        break;
    }
    $posx = $x
    (Get-date -UFormat "%H:%M:%S")[0..9] | % {
          $idx = 10
          if ($_ -ne ":") {
             $idx = [int]"$_";
          }
          0..9 | % {
              $posy = $y+$_
              [console]::SetCursorPosition($posx, $posy)
              $chars[$idx][$_]
           }
          $posx += $xoffset
    }
    [console]::SetCursorPosition(0,$posy+1)
    $result = Get-date -UFormat "%H:%M:%S"
    Start-sleep -Milliseconds 1000
}
[console]::CursorVisible = $true
Clear-Host
$result
