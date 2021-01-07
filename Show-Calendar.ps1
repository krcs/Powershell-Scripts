<#
.SYNOPSIS
Shows interactive calendar.
K!2019

.DESCRIPTION
 Cursor keys (Up/Down/Left/Right) - change day
 a/d - change month
 w/s - change year
 r   - reset to current date 
 ESC/ENTER - exit

.PARAMETER date
Sets date

.EXAMPLE
.\Show-Calendar.ps1 "2018-09-26"

.OUTPUTS
DateTime. Returns selected date.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param([datetime] $date = [DateTime]::Now)

if ($PSVersionTable.PSVersion.Major -lt 5) {
    throw "Unsupported Powershell Version."
}

class Calendar {
     [void] SetDate([datetime] $date) {
         $this._currentDate = $date
         $this.Init_matrix()
     }
    
     [DateTime] GetDate() { return $this._currentDate }

     [int] $X = 0
     [int] $Y = 0

     [datetime] hidden $_currentDate
     [int] hidden $_row
     [int] hidden $_column
     [object[]] hidden $_matrix
     [int] hidden $_lastRow

 
    Calendar() { 
        $this.SetDate([datetime]::Now) 
        $this | Add-Member -Name Row -MemberType ScriptProperty -Value {
            return $this._row
        } -SecondValue {
            param($value)
            $this.SelectDay($value, $this._column)
        }

        $this | Add-Member -Name Column -MemberType ScriptProperty -Value {
            return $this._column
        } -SecondValue {
            param($value)
            $this.SelectDay($this._row, $value)
        }
    }

    [void] Draw() {
        [console]::SetCursorPosition($this.X, $this.Y)
        write-host -NoNewline (" {0,-3}{1,-11:d1} {2,-3}{3,2}" -f "Y:", $this._currentDate.Year, "M:", $this._currentDate.Month)
        [console]::SetCursorPosition($this.X, $this.Y + 1)
        write-host -NoNewline (" Mo Tu We Th Fr Sa Su")
        [console]::SetCursorPosition($this.X, $this.Y + 2)

        for ($r = 0; $r -lt $this._matrix.Count; $r++) {
            for ($c = 0; $c -lt $this._matrix[$r].Count; $c++) {
                if ($this._matrix[$r][$c] -ne 0) 
                    { write-host -NoNewline ("{0,3:d1}" -f $this._matrix[$r][$c]) } 
                else 
                    { write-host -NoNewline ("{0,3}" -f " ") }
            }
            [console]::SetCursorPosition($this.X, $this.Y + 2 + $r + 1 )
        }
        $this.SelectDay($this._row, $this._column)
    }

    [void] hidden SelectDay([int] $row, [int] $column) {
        if (!($this.CanSelect($row, $column))) { 
            return  
        }
        $this.Select($false)
        $this._column = $column
        $this._row = $row
        $this.Select($true)
    }

    [bool] hidden CanSelect([int] $row, [int] $column) {
        if ( $column -lt 0 -or $column -gt 6 )   { return $false }
        if ( $row -lt 0 -or $row -gt 5 )         { return $false }
        if ( $this._matrix[$row][$column] -eq 0 ) { return $false }
        return $true
    }

    [void] hidden Select([bool] $selected) {
        $day = $this._matrix[$this._row][$this._column]
        $selection = "{0,2}" -f $day
        $position_x = $this.X + ($this._column * 3) + 1
        $position_y = $this.Y + $this._row + 2
        
        [console]::setcursorposition($position_x, $position_y)
        if ($selected) {
            write-host $selection -nonewline -fore ([console]::BackgroundColor) -back ([console]::ForegroundColor)
            $this._currentDate = [DateTime]::new($this._currentDate.Year, $this._currentDate.Month, $day)
        } else {
            write-host $selection -nonewline -fore ([console]::ForegroundColor) -back ([console]::BackgroundColor)
        }
        [console]::SetCursorPosition(0, $this.Y + 3 + $this._lastRow + 1)
    }

    [void] hidden Init_matrix() {
        $this._matrix = @( 
            (0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0),
            (0, 0, 0, 0, 0, 0, 0)
        )

        $lastDay = [datetime]::DaysInMonth($this._currentdate.Year, $this._currentdate.Month)
        $firstDayDate = [DateTime]::new($this._currentDate.Year, $this._currentDate.Month, 1)

        $offset = [Calendar]::GetDayOffset($firstDayDate)

        $row, $column = 0, 0
        1..$lastDay | ForEach-Object {
            $idx = $_ + $offset - 1
            $row = [math]::Truncate($idx / 7)
            $column = [math]::Truncate($idx % 7)
            
            $this._matrix[$row][$column] = $_
            
            if ($_ -eq $this._currentDate.Day) {
                $this._column, $this._row = $column, $row
            }
        }
        $this._lastRow = $row
    }

    static [int] hidden GetDayOffset([datetime] $datetime) {
        $counter = 1
        while ([int]$datetime.DayOfWeek -ne 0) { 
            $counter++
            $datetime = $datetime.AddDays(1)
        }
        return 7 - $counter
    }
}

function GetDateWithDay([datetime] $date) {
    $currentDate = [DateTime]::Now
    if ($date.Year -eq $currentDate.Year -and 
        $date.Month -eq $currentDate.Month) {
            return $currentDate
        }
    return [DateTime]::new($date.Year, $date.Month, 1)
}

write-host 
$calendar = [Calendar]::new()
$calendar.SetDate($date)
$calendar.X = $host.UI.RawUI.CursorPosition.X
$calendar.Y = $host.UI.RawUI.CursorPosition.Y
$calendar.Draw()

[console]::CursorVisible = $false
while ($key -ne 27 -and $key -ne 13) {
    switch ($key) {
        37 { $calendar.Column-- }
        39 { $calendar.Column++ }
        38 { $calendar.Row-- }
        40 { $calendar.Row++ }
        65 { $calendar.SetDate( (GetDateWithDay( $calendar.GetDate().AddMonths(-1) ) ) )
             $calendar.Draw()
        }
        68 { $calendar.SetDate( (GetDateWithDay( $calendar.GetDate().AddMonths(1) ) ) ) 
             $calendar.Draw()
        }
        87 { $calendar.SetDate( (GetDateWithDay( $calendar.GetDate().AddYears(1) ) ) )
             $calendar.Draw()
        }
        83 { $calendar.SetDate( (GetDateWithDay( $calendar.GetDate().AddYears(-1) ) ) )
             $calendar.Draw()
        }
        82 { $calendar.SetDate( [datetime]::Now )
             $calendar.Draw()
       }
    }
    $readkey = $host.ui.rawui.readKey("NoEcho, IncludeKeyDown")
    $key = $readkey.virtualkeycode;
}
[console]::CursorVisible = $true

return $calendar.GetDate()
