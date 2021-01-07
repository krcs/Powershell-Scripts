<#
.SYNOPSIS
An interactive panel for changing screen brightness.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param()
function draw_interface() {
    write-host;
    write-host "+-[ESC]-back [Left/Right]-change [Up/Down]-inc/dec step [R/r]-reset [0/1]-min/max -------------------+";
    write-host "|                                                                                                    |";
    write-host "+-Step:[  ]-Current Value: [     ]---------------------------------------- SCREEN BRIGHTNESS K!2015 -+";
    write-host;
}

function get_brightness() {
    return (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightness).CurrentBrightness;
}

function set_brightness($prc) {
   (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1,$current_value);
}

function Set-ScreenBrightness() {
    $currentY = $host.ui.rawui.cursorposition.y;
    $initial_value = get_brightness;
    $current_value = $initial_value;
    $stepIdx = 0;
    $steps = 1,5,10,20,25;
    $key = 0;
    draw_interface;
    while ($key -ne 27 -and $key -ne 13) {
        if ($key -eq 37) { 
            $current_value-=$steps[$stepIdx]; 
            if ($current_value -lt 0) { $current_value = 0; } 
        } # left

        if ($key -eq 39) { 
            $current_value+=$steps[$stepIdx]; 
            if ($current_value -gt 100) { $current_value = 100; }
        } # right
 
        if ($key -eq 38) { 
            $stepIdx++ 
            if ($stepIdx -ge $steps.length) { $stepIdx = $steps.length-1 }
        } # up
        if ($key -eq 40) { 
            $stepIdx-- 
            if ($stepIdx -lt 0) { $stepIdx = 0; };
        } # down

        if ($key -eq 48) { $current_value=0 }   # min 0;
        if ($key -eq 49) { $current_value=100 } # max 1;

        if ($key -eq 82 -or $key -eq 114) { $current_value = $initial_value; }

        [console]::setcursorposition(29,$currentY+3);
        write-host ("{0,3}" -f $current_value) -nonewline; 

        [console]::setcursorposition(8,$currentY+3);
        write-host ("{0,2}" -f $steps[$stepIdx]) -nonewline;

        [console]::setcursorposition(1,$currentY+2);
        write-host ("{0,-100}" -f ("#"*$current_value)) -nonewline; 

        [console]::setcursorposition(0,$currentY+4);

        set_brightness $current_value;
 
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown");
        $key = $press.virtualkeycode;
    }
    write-host;
}

Set-ScreenBrightness
