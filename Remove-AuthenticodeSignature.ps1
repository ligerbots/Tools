<#
.SYNOPSIS
    Removes Authenticode signature from a PowerShell script file.

.DESCRIPTION
    This script removes the digital signature block from a signed PowerShell file
    by reading the content and removing the signature comment block.

.PARAMETER Path
    The path to the PowerShell script file to remove the signature from.

.PARAMETER BackupOriginal
    If specified, creates a backup of the original file with .bak extension.

.EXAMPLE
    .\Remove-Signature.ps1 -Path "C:\Scripts\SignedScript.ps1"
    
.EXAMPLE
    .\Remove-Signature.ps1 -Path "C:\Scripts\SignedScript.ps1" -BackupOriginal
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [switch]$BackupOriginal
)

# Verify file exists
if (-not (Test-Path $Path)) {
    Write-Error "File not found: $Path"
    exit 1
}

# Verify it's a PowerShell file
if ($Path -notmatch '\.ps1$|\.psm1$|\.psd1$') {
    Write-Warning "File doesn't appear to be a PowerShell script file."
}

try {
    # Read the file content
    $content = Get-Content -Path $Path -Raw
    
    # Check if file is signed
    $signature = Get-AuthenticodeSignature -FilePath $Path
    if ($signature.Status -eq 'NotSigned') {
        Write-Host "File is not signed. No action needed." -ForegroundColor Yellow
        exit 0
    }
    
    # Create backup if requested
    if ($BackupOriginal) {
        $backupPath = "$Path.bak"
        Copy-Item -Path $Path -Destination $backupPath -Force
        Write-Host "Backup created: $backupPath" -ForegroundColor Green
    }
    
    # Remove signature block (everything after '
    $unsignedContent = $content -replace $signaturePattern, ''
    
    # Remove trailing whitespace
    $unsignedContent = $unsignedContent.TrimEnd()
    
    # Write the unsigned content back to file
    Set-Content -Path $Path -Value $unsignedContent -NoNewline
    
    # Verify signature was removed
    $newSignature = Get-AuthenticodeSignature -FilePath $Path
    if ($newSignature.Status -eq 'NotSigned') {
        Write-Host "Signature successfully removed from: $Path" -ForegroundColor Green
    } else {
        Write-Warning "Signature may not have been completely removed. Please verify."
    }
    
} catch {
    Write-Error "An error occurred: $_"
    exit 1
}