# SetupGitBash.ps1
# Adds a "Git Bash" profile to Windows Terminal settings.json if one doesn't already exist.

# Find settings.json (supports Store and non-Store installations)
$paths = @(
    Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json"
)
$settingsPath = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $settingsPath) {
    Write-Error "Windows Terminal settings.json not found in expected locations."
    exit 1
}

# Locate Git Bash executable
$possibleGit = @(
    Join-Path $env:ProgramFiles "Git\bin\bash.exe",
    Join-Path $env:ProgramFiles '(x86)\Git\bin\bash.exe' -Replace '\\\\','\'
) 2>$null
# Fallback explicit checks to avoid odd path parsing
$possibleGit = @(
    "$env:ProgramFiles\Git\bin\bash.exe",
    "$env:ProgramFiles(x86)\Git\bin\bash.exe",
    "$env:ProgramFiles\Git\usr\bin\bash.exe"
) | Where-Object { Test-Path $_ }

$gitExe = $possibleGit | Select-Object -First 1
if (-not $gitExe) {
    Write-Error "Git Bash executable not found. Install Git for Windows or update the script with the correct path."
    exit 1
}

# Read and parse settings.json
$raw = Get-Content -Raw -Path $settingsPath
try {
    $json = $raw | ConvertFrom-Json -ErrorAction Stop
} catch {
    Write-Error "Failed to parse settings.json as JSON. Aborting."
    exit 1
}

# Resolve profiles list (supports both legacy and current schema)
if ($null -ne $json.profiles.PSObject.Properties.Match('list')) {
    $profilesRef = $json.profiles.list
    $profilesContainer = 'profiles.list'
} elseif ($json.profiles -is [System.Collections.IEnumerable]) {
    $profilesRef = $json.profiles
    $profilesContainer = 'profiles'
} else {
    # If profiles structure is unexpected, try to create one
    if ($null -eq $json.profiles) {
        $json.profiles = @{ list = @() }
        $profilesRef = $json.profiles.list
        $profilesContainer = 'profiles.list'
    } else {
        Write-Error "Unrecognized profiles structure in settings.json. Aborting."
        exit 1
    }
}

# Determine if a Git Bash profile already exists
$exists = $false
foreach ($p in $profilesRef) {
    if ($p -and ($p.name -eq 'Git Bash' -or ($p.commandline -and $p.commandline -match 'bash\.exe') -or ($p.source -and $p.source -match 'Git'))) {
        $exists = $true
        break
    }
}
if ($exists) {
    Write-Output "Git Bash profile already present in settings.json. No changes made."
    exit 0
}

# Build new profile object
$guid = '{' + ([guid]::NewGuid().ToString()) + '}'
$cmd = "`"$gitExe`" -i -l"    # quote executable path and add interactive/login flags
$newProfile = [PSCustomObject]@{
    guid = $guid
    name = 'Git Bash'
    commandline = $cmd
    startingDirectory = '%USERPROFILE%'
}

# Optional: pick a reasonable icon if present
$iconCandidates = @(
    Join-Path (Split-Path $gitExe -Parent) '..\mingw64\share\git\git-for-windows.ico' | Resolve-Path -ErrorAction SilentlyContinue,
    Join-Path $env:ProgramFiles 'Git\mingw64\share\git\git-for-windows.ico' | Resolve-Path -ErrorAction SilentlyContinue
) | Where-Object { $_ } | ForEach-Object { $_.ProviderPath }
if ($iconCandidates) { $newProfile | Add-Member -NotePropertyName icon -NotePropertyValue $iconCandidates[0] }

# Append the new profile
if ($profilesContainer -eq 'profiles.list') {
    $json.profiles.list += $newProfile
} else {
    $json.profiles += $newProfile
}

# Backup original settings.json
$backup = "$settingsPath.bak.$((Get-Date).ToString('yyyyMMddHHmmss'))"
Copy-Item -Path $settingsPath -Destination $backup -Force

# Write updated JSON back (increase depth to preserve nested objects)
$json | ConvertTo-Json -Depth 64 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Output "Git Bash profile added to settings.json (backup saved as $backup)."