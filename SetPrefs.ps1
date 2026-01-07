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
