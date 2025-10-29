# Ensure the script is run with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

# Get the Application Identity service (AppIDSvc) which is required for AppLocker
$serviceName = "AppIDSvc"
$svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($svc) {
    Write-Output "Found service '$serviceName'."

    # If the service is running, stop it.
    if ($svc.Status -eq "Running") {
        Write-Output "Stopping the '$serviceName' service..."
        try {
            Stop-Service -Name $serviceName -Force -ErrorAction Stop
            Write-Output "'$serviceName' service stopped."
        } catch {
            Write-Error "Failed to stop the '$serviceName' service: $_"
        }
    } else {
        Write-Output "'$serviceName' service is not running."
    }

    # Disable the service to prevent it from starting at reboot
    Write-Output "Disabling the '$serviceName' service..."
    try {
        Set-Service -Name $serviceName -StartupType Disabled -ErrorAction Stop
        Write-Output "'$serviceName' service has been disabled."
    } catch {
        Write-Error "Failed to disable the '$serviceName' service: $_"
    }
} else {
    Write-Output "Service '$serviceName' not found. AppLocker enforcement may not be active on this system."
}

Write-Output "AppLocker should now be effectively disabled (via the Application Identity service)."
