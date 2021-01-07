<#
.SYNOPSIS
Returns localhost uptime.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param()
$wmi = Get-WmiObject -Class Win32_OperatingSystem
$wmi.ConvertToDateTime($wmi.LocalDateTime) - $wmi.ConvertToDateTime($wmi.LastBootUpTime)
