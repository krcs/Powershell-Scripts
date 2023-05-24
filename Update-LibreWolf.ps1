<# 
.SYNOPSIS
Installs or updates the LibreWolf browser.

#>
param([switch]$dry)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$librewolf_reg = 
    'Registry::HKEY_CURRENT_USER\SOFTWARE\LibreWolf\Firefox\Launcher';

$releases_url = 
    'https://gitlab.com/api/v4/projects/44042130/releases';

$installed_version = "";

if(test-path $librewolf_reg) {
    $exe=((Get-Item $librewolf_reg | Select-Object -ExpandProperty Property | 
        ? { $_ -match 'Image' }) -split "\|")[0];

    $installed_version = "v$((Get-Item $exe).VersionInfo.ProductVersion)";
}

$releases = Invoke-WebRequest -uri $releases_url | 
    select -ExpandProperty Content | 
    ConvertFrom-Json;

$latest_release = $releases[0];

if ($dry) {
    write-host "Installed version: $installed_version";
    write-host "  Current version: $($latest_release.tag_name)";
    exit;
}

if ($latest_release.tag_name -ne $installed_version) {
    $links = ($latest_release.assets.links | 
        ? { $_.link_type -eq 'package' -and $_.name -match 'setup.exe$' })[0];

    $sha256sums_link = ($latest_release.assets.links | 
        ? { $_.name -match 'sha256sums.txt'})[0];

    $sha256sums_content = (Invoke-WebRequest -uri $sha256sums_link.url).Content
    $sha256sums = [System.Text.Encoding]::ASCII.GetString($sha256sums_content)  -split "\n";
    $sha256 = 
        (($sha256sums | select-string -Pattern $links[0].name) -split " ")[0];

    $download_path = join-path $env:TEMP $links[0].name;

    if (!(test-path $download_path)) {
        Invoke-WebRequest -uri $links[0].url -outfile $download_path;
    }

    $file_hash = (get-filehash -algorithm sha256 -path $download_path).Hash;
    if ($file_hash -ne $sha256) {
        write-host -Foreground Red "Invalid hash. Run the script again."
        rm $download_path;
        exit;
    }

    ps -Name librewolf -ErrorAction Ignore | kill
    start-process $download_path -wait -ErrorAction Ignore;
    rm $download_path;
    write-host "Done.";
} else {
    write-host "LibreWolf is up to date.";
}
