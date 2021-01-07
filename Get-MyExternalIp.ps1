<#
.SYNOPSIS
Returns current external IP address.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param()
$urls = 
    "whatismyip.akamai.com", 
    "b10m.swal.org/cgi-bin/whatsmyip.cgi?just-ip",
    "www.whatismyip.com/automation/n09230945.asp",
    "icanhazip.com",
    "b10m.swal.org/ip",
    "www.whatismyip.org/"

Foreach ($url in $urls) { 
    try{
        if ( (Invoke-WebRequest $url) -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
        {
            write-host $Matches[0]
            exit;
        }
    } catch {
        write-error "Address not found."
    }
}
