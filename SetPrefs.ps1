# Customizations first

# Left align task bar
Set-ItemProperty -Path HKCU:\software\microsoft\windows\currentversion\explorer\advanced -Name 'TaskbarAl' -Type 'DWord' -Value 0

# set dark mode
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force

# enable Clipboard history (Windows-key V)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type DWord -Value 1

# use rational date/time formats
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sLongDate -Value "dddd, d. MMMM yyyy";
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortDate -Value "yyyy.MM.dd";
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value "HH:mm";
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat -Value "HH:mm:ss";
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sYearMonth -Value "yyyy MMMM";

# start app installs
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient

# enable ICMP (ping)
Enable-NetFirewallRule -displayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
Enable-NetFirewallRule -displayName "File and Printer Sharing (Echo Request - ICMPv6-In)"

# Git customizations
. $PSScriptRoot/SetupGitBash-Claude.ps1

# Enable "Ask where to save each file before downloading" in Microsoft Edge
# This sets the PromptForDownloadLocation policy

try {
    # Registry path for Edge user policy
    $regPath = "HKCU:\Software\Policies\Microsoft\Edge"

    # Create the registry path if it doesn't exist
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set the policy value (1 = Enabled, 0 = Disabled)
    Set-ItemProperty -Path $regPath -Name "PromptForDownloadLocation" -Value 1 -Type DWord
}
catch {
    Write-Host "❌ Failed to update the setting: $($_.Exception.Message)"
}

# Define the homepage URL
$HomeURL = 'about:blank'

# Define the registry paths
$EdgeHome = 'HKCU:\Software\Policies\Microsoft\Edge'
$EdgeSUURL = "$EdgeHome\RestoreOnStartupURLs"

# Ensure the main Edge policy key exists
If (-Not (Test-Path $EdgeHome)) {
    New-Item -Path $EdgeHome | Out-Null
}

# Set the RestoreOnStartup value to 4 (opens a list of specific URLs)
# This is a REG_DWORD value
$IPHT_Startup = @{
    Path = $EdgeHome
    Name = 'RestoreOnStartup'
    Value = 4
    Type = 'DWORD'
}
Set-ItemProperty @IPHT_Startup -Force | Out-Null

# Ensure the Startup URLs sub-key exists
If (-Not (Test-Path $EdgeSUURL)) {
    New-Item -Path $EdgeSUURL | Out-Null
}

# Set the specific URL(s)
# Each URL requires a unique name (e.g., '1', '2', etc.)
Set-ItemProperty -Path $EdgeSUURL -Name '1' -Value $HomeURL -Force

Write-Host "Microsoft Edge start page set to: $HomeURL"
