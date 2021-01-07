<#
.SYNOPSIS
Returns localhost name.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param()
$(Get-WmiObject Win32_Computersystem).Name
