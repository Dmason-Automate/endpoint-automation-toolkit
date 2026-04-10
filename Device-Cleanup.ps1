<#
.SYNOPSIS
    Performs basic device cleanup tasks for Windows endpoints.

.DESCRIPTION
    This script removes temporary files from common locations, optionally clears
    the Recycle Bin, and writes actions to a log file. It is intended as a simple
    example of endpoint maintenance automation.

.NOTES
    Author: Daniel Mason
    Purpose: Example PowerShell script for endpoint management and automation
#>

[CmdletBinding()]
param (
    [switch]$ClearRecycleBin
)

$LogPath = "$env:TEMP\Device-Cleanup.log"

function Write-Log {
    param (
        [string]$Message
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Entry = "$Timestamp - $Message"
    Write-Host $Entry
    Add-Content -Path $LogPath -Value $Entry
}

function Remove-FilesFromPath {
    param (
        [string]$TargetPath
    )

    if (Test-Path $TargetPath) {
        try {
            Get-ChildItem -Path $TargetPath -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Cleaned: $TargetPath"
        }
        catch {
            Write-Log "Failed to clean ${TargetPath}: $($_.Exception.Message)"
        }
    }
    else {
        Write-Log "Path not found: $TargetPath"
    }
}

Write-Log "Starting device cleanup"

# Clear user temp files
Remove-FilesFromPath -TargetPath $env:TEMP

# Clear Windows temp files
Remove-FilesFromPath -TargetPath "C:\Windows\Temp"

# Optionally clear Recycle Bin
if ($ClearRecycleBin) {
    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Log "Recycle Bin cleared"
    }
    catch {
        Write-Log "Failed to clear Recycle Bin: $($_.Exception.Message)"
    }
}

Write-Log "Device cleanup completed"
