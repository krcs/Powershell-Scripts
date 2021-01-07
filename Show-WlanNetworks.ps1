<#
.SYNOPSIS
Displays detailed information about available wireless networks.

.LINK
https://github.com/krcs/Powershell-Scripts

#>
param ($ifname = $(throw "Specifiy interface name")) 
# Windows Vista/2008/7
if ([int](Get-WmiObject win32_operatingsystem).Version.Split(".")[0] -lt 6) {
    throw "This script works on Windows Vista or higher."
}
if ((Get-Service "wlansvc").Status -ne "Running" ) {
    throw "WLAN AutoConfig service must be running."
}
$GLOBAL:ActiveNetworks = @();
$CurrentIfName = "";	
$n = -1;
$iftest = $false;

netsh wlan show network mode=bssid | % {
    if ( $_ -match "interf") {
        $CurrentIfName = [regex]::match($_, "[:].*$").Value.Substring(2).Trim(" "); 
        $iftest = [regex]::IsMatch($CurrentIfName, $ifname, "IgnoreCase");
    }	 
    $buf = [regex]::replace($_, "[ ]", "");
    if ([regex]::IsMatch($buf, "^SSID\d{1,}(.)*") -and $iftest) {
        $item = "" | Select-Object SSID, NetType, Auth, Encryption, BSSID, Signal, Radiotype, Channel;
        $n += 1;
        $item.SSID = [regex]::Replace($buf, "^SSID\d{1,}:", "");
        $GLOBAL:ActiveNetworks += $item;
    }
    if ([regex]::IsMatch($buf, "Networktype|Typ.sieci") -and $iftest) {
        $GLOBAL:ActiveNetworks[$n].NetType = [regex]::Replace($buf, "(Networktype|Typ.sieci):", ""); 
    }
    if ([regex]::IsMatch($buf, "Authentication|Uwierzytelnianie") -and $iftest) {
        $GLOBAL:ActiveNetworks[$n].Auth = [regex]::Replace($buf, "(Authentication|Uwierzytelnianie):", ""); 
    }
    if ([regex]::IsMatch($buf, "Encryption|Szyfrowanie") -and $iftest) {
        $GLOBAL:ActiveNetworks[$n].Encryption = [regex]::Replace($buf, "(Szyfrowanie|Encryption):", ""); 
    }
    if ([regex]::IsMatch($buf, "BSSID1") -and $iftest) {
        $GLOBAL:ActiveNetworks[$n].BSSID = $buf.Replace("BSSID1:", "");
    }
    if ([regex]::IsMatch($buf, "Sygnał|Signal") -and $iftest) {
        $GLOBAL:ActiveNetworks[$n].Signal = [regex]::Replace($buf, "(Sygnał|Signal):", "");
    }
    if ([regex]::IsMatch($buf, "Radiotype|Typ.radia") -and $iftest) {
        $GLOBAL:ActiveNetworks[$n].Radiotype = [regex]::Replace($buf, "(Radiotype|Typ.radia):", "");
    }
    if ([regex]::IsMatch($buf, "Channel|Kanał") -and $iftest) {
        $GLOBAL:ActiveNetworks[$n].Channel = [regex]::Replace($buf, "(Channel|Kanał):", "");
    }
}
if ( ($CurrentIfName.ToLower() -eq $ifname.ToLower()) -or ($ifname.length -eq 0) ) {
    write-host -ForegroundColor Yellow "`nInterface: $CurrentIfName";
    if (($GLOBAL:ActiveNetworks.length -gt 0)) {
        $GLOBAL:ActiveNetworks | Sort-Object Signal -Descending | 
            Format-Table @{Label = "BSSID"; Expression = {$_.BSSID }; width = 18},
        @{Label = "Channel"; Expression = {$_.Channel}; width = 8},
        @{Label = "Signal"; Expression = {$_.Signal}; width = 7},
        @{Label = "Encryption"; Expression = {$_.Encryption}; width = 11},
        @{Label = "Authentication"; Expression = {$_.Auth}; width = 15},
        SSID
    }
    else { Write-Warning "`nNo active networks found.`n"; }
}
else { Write-Error "`nCould not find interface: $ifname`n"; }
