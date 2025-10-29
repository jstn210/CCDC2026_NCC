# Ensure the script is running with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

# Check if the EFS (Encrypting File System) service exists
$efsService = Get-Service -Name "EFS" -ErrorAction SilentlyContinue

if ($efsService) {
    Write-Output "EFS service found. Proceeding to disable it to mitigate PetitPotam."
    
    # If the service is running, stop it
    if ($efsService.Status -eq 'Running') {
        Write-Output "Stopping the EFS service..."
        try {
            Stop-Service -Name "EFS" -Force -ErrorAction Stop
            Write-Output "EFS service stopped."
        } catch {
            Write-Error "Failed to stop the EFS service: $_"
        }
    } else {
        Write-Output "EFS service is not running."
    }
    
    # Disable the service so it does not start on reboot
    Write-Output "Disabling the EFS service..."
    try {
        fsutil behavior set disableencryption 1
        Set-Service -Name "EFS" -StartupType Disabled -ErrorAction Stop
        Write-Output "EFS service has been disabled."
    } catch {
        Write-Error "Failed to disable the EFS service: $_"
    }
} else {
    Write-Output "EFS service not found on this system. No changes required."
}

Write-Output "Mitigation complete. PetitPotam attack surface (via EFSRPC) should now be reduced."
