# Run as Administrator

try {
    # Registry path for PIN sign-in policy
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"

    # Create the key if it doesn't exist
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Enable convenience PIN sign-in (0 = enabled, 1 = disabled)
    Set-ItemProperty -Path $regPath -Name "AllowDomainPINLogon" -Type DWord -Value 1

    # Enable PIN sign-in for local accounts
    Set-ItemProperty -Path $regPath -Name "AllowConvenienceLogon" -Type DWord -Value 1

    Write-Host "Convenience PIN sign-in has been enabled. Please restart your PC." -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
