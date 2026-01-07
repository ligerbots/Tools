# Script to add Git Bash to Windows Terminal settings
# Only adds if Git Bash profile doesn't already exist

$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Check if Windows Terminal is installed
if (-not (Test-Path $settingsPath)) {
    Write-Host "Windows Terminal settings.json not found at: $settingsPath" -ForegroundColor Red
    Write-Host "Please ensure Windows Terminal is installed." -ForegroundColor Yellow
    exit 1
}

# Find Git Bash installation
$gitBashPaths = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
)

$gitBashExe = $gitBashPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $gitBashExe) {
    Write-Host "Git Bash not found. Please install Git for Windows first." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "Found Git Bash at: $gitBashExe" -ForegroundColor Green

$fragmentPath = "$env:ProgramData\Microsoft\Windows Terminal\Fragments\Git\git-bash.json"

if (Test-Path $fragmentPath) {
    $json = Get-Content $fragmentPath -Raw | ConvertFrom-Json
    $guid = $json.guid
    Write-Host "GUID found: $guid. Will use GUID"
} 

# Read and parse settings.json
try {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
} catch {
    Write-Host "Error reading settings.json: $_" -ForegroundColor Red
    exit 1
}

# Check if Git Bash profile already exists
$existingProfile = $settings.profiles.list | Where-Object { 
    $_.name -eq "Git Bash" -or $_.commandline -like "*bash.exe*"
}

if ($existingProfile) {
    Write-Host "Git Bash profile already exists in Windows Terminal!" -ForegroundColor Yellow
    Write-Host "Profile name: $($existingProfile.name)" -ForegroundColor Cyan
    exit 0
}

# Create Git Bash profile

if ($guid) {
    # By guid from fragment, if present
    $gitBashProfile = @{
        guid = $guid
        name = "Git Bash"
        icon = ($gitBashExe -replace "bin\\bash\.exe", "mingw64\share\git\git-for-windows.ico")
        startingDirectory = "%USERPROFILE%"
        hidden = $false
    }
} else {
    # by path, if guid not present
    $gitBashProfile = @{
        guid = "{$(New-Guid)}"
        name = "Git Bash"
        commandline = $gitBashExe
        icon = ($gitBashExe -replace "bin\\bash\.exe", "mingw64\share\git\git-for-windows.ico")
        startingDirectory = "%USERPROFILE%"
        hidden = $false
    }
}

# Add to profiles list
$settings.profiles.list += $gitBashProfile

# Backup original settings
$backupPath = "$settingsPath.backup"
Copy-Item $settingsPath $backupPath -Force
Write-Host "Backup created at: $backupPath" -ForegroundColor Cyan

# Save updated settings
try {
    $settings | ConvertTo-Json -Depth 100 | Set-Content $settingsPath -Encoding UTF8
    Write-Host "Successfully added Git Bash to Windows Terminal!" -ForegroundColor Green
    Write-Host "Restart Windows Terminal to see the new profile." -ForegroundColor Yellow
} catch {
    Write-Host "Error saving settings.json: $_" -ForegroundColor Red
    Write-Host "Restoring backup..." -ForegroundColor Yellow
    Copy-Item $backupPath $settingsPath -Force
    exit 1
}
