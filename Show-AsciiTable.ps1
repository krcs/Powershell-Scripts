<#
.SYNOPSIS
Shows interactive ASCII table.

.DESCRIPTION
Use arrow keys to change character.
Press Enter or Esc to back to command prompt.

Selected ascii code (in decimal) is stored in $asciicode variable.

Table:
HEX  00  01  02  03  04  05  06  07  08  09  0A  0B  0C  0D  0E  0F
---+----------------------------------------------------------------
  0: NUL SOH STX ETX EOT ENQ ACK BEL BS  HT  LF  VT  FF  CR  SO  SI
  1: DLE DC1 DC2 DC3 DC4 NAK SYN ETB CAN EM  SUB ESC FS  GS  RS  US
  2: SP  !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /
  3: 0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?
  4: @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
  5: P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _
  6: `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o
  7: p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~   DEL

.LINK
https://github.com/krcs/Powershell-Scripts

#>
Param()

function Show-AsciiTable() {
    write-host "`nASCII TABLE v1.0 (K!2015)";
    write-host ("{0,-68}" -f "[UP][DOWN][LEFT][RIGHT] - select,  [ENTER] or [ESC] - return");
    write-host;
    drawTable;
    $currentY = $host.ui.rawui.cursorposition.y;
    $sx, $sy = 5, ($currentY-9);
    $lsx, $lsy = 0, 0;
    $minX, $maxX = 5, 65;
    $minY, $maxY = ($currentY-9), ($currentY-2);
    $key = 0;
    $fc = $host.UI.RawUI.ForegroundColor;
    $bc = $host.UI.RawUI.BackgroundColor;
    $rec = new-object System.Management.Automation.Host.Rectangle $sx, $sy, ($sx+3), $sy;
    $charOffset = 0; 
    while ($key -ne 27 -and $key -ne 13) {
        if ($key -eq 37) { $sx-=4; $charOffset--; }
        if ($key -eq 39) { $sx+=4; $charOffset++; }
        if ($key -eq 38) { $sy--;  $charOffset-=16; }
        if ($key -eq 40) { $sy++;  $charOffset+=16; }
   
        if ($sx -lt $minX) { $sx = $maxX; $charOffset+=16; }
        if ($sx -gt $maxX) { $sx = $minX; $charOffset-=16; }
        if ($sy -lt $minY) { $sy = $maxY; $charOffset+=128; } 
        if ($sy -gt $maxY) { $sy = $minY; $charOffset-=128; }
        $Global:asciicode = $charOffset;
         
        _select $rec $lsx $lsy $false;
        _select $rec $sx  $sy $true;
       
        [console]::setcursorposition(2,($maxY+2));
        write-host ("Dec: {0,-3} Hex: {1,-2:X2} Char: {2,-42}" -f $charOffset, $charOffset, (getChar $charOffset $true));
        
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown");
        $key = $press.virtualkeycode;
        $lsx, $lsy = $sx, $sy;
    }
    write-host;
}


function getChar($num, $showDesc=$false) {
    $char = "";
    $desc = "";
    switch ($num) {
        0 { $char = "NUL"; $desc="(null)"; }
        1 { $char = "SOH"; $desc="(start of heading)"; }
        2 { $char = "STX"; $desc="(start of text)"; }
        3 { $char = "ETX"; $desc="(end of text)"; }
        4 { $char = "EOT"; $desc="(end of transmission)"; }
        5 { $char = "ENQ"; $desc="(enquiry)"; }
        6 { $char = "ACK"; $desc="(acknowledge)"; }
        7 { $char = "BEL"; $desc="(``a - bell)"; }
        8 { $char = "BS" ; $desc="(``b - backspace)"; }
        9 { $char = "HT" ; $desc="(``t - horizontal tab)"; }
       10 { $char = "LF" ; $desc="(``n - new line)"; }      
       11 { $char = "VT"; $desc = "(``v - vertical tab)"; }
       12 { $char = "FF"; $desc = "(``f - form feed)"; } 
       13 { $char = "CR"; $desc = "(``r - carriage ret)"; }  
       14 { $char = "SO"; $desc = "(shift out)"; }          
       15 { $char = "SI"; $desc = "(shift in)"; }           
       16 { $char = "DLE"; $desc = "(data link escape)"; }   
       17 { $char = "DC1"; $desc = "(device control 1)"; }   
       18 { $char = "DC2"; $desc = "(device control 2)"; }   
       19 { $char = "DC3"; $desc = "(device control 3)"; }   
       20 { $char = "DC4"; $desc = "(device control 4)"; }   
       21 { $char = "NAK"; $desc = "(negative ack.)"; }      
       22 { $char = "SYN"; $desc = "(synchronous idle)"; }   
       23 { $char = "ETB"; $desc = "(end of trans. blk)"; }  
       24 { $char = "CAN"; $desc = "(cancel)"; }             
       25 { $char = "EM"; $desc = "(end of medium)"; }      
       26 { $char = "SUB"; $desc = "(substitute)"; }         
       27 { $char = "ESC"; $desc = "(escape)"; }            
       28 { $char = "FS"; $desc = "(file separator)"; }
       29 { $char = "GS"; $desc = "(group separator)"; }    
       30 { $char = "RS"; $desc = "(record separator)"; }   
       31 { $char = "US"; $desc = "(unit separator)"; }     
       32 { $char = "SP"; $desc = "(space)"; }                    
      127 { $char = "DEL"; $desc = ""; }
      default { $char = [char]$num; $desc=""; }
    }
    if ($showDesc -eq $true) { 
        return "$char $desc"
    }
    else {
        return $char;
    }  
}

function drawTable() {
    $result = "";
    $hex = 0..15 | % { "{0,-3:X2}" -f $_ };
    $header = "{0,-5}{1}" -f "HEX", "$hex";
    $result += $header+"`n";
    $line = "---+"+("-"*64);
    $result += $line+"`n";
    0..7 | % {
        $rowIndex = ($_*16);
        $row = $rowIndex..($rowIndex+15) | % {
           "{0,-3}" -f (getChar $_);
        }
        $result += "{0,3:X}`: {1}`n" -f $_, "$row";
    }
    $result
}

function _select($rec, $x, $y, $selected) {
    $rec.Top, $rec.Left, $rec.Right, $rec.Bottom = $y, $x, ($x+3), $y;
    $c = $host.ui.rawui.GetBufferContents($rec);
    $str = $c[0,0].Character+$c[0,1].Character+$c[0,2].Character;
    [console]::setcursorposition($x, $y);
    if ($selected -eq $true) {
        write-host $str -nonewline -fore $bc -back $fc; 
    } else {
        write-host $str -nonewline -fore $fc -back $bc; 
    }
}

Show-AsciiTable
