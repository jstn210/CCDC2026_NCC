# mitigates weird dementor attack and printnightmare

# Check if the Print Spooler service exists
$spooler = Get-Service -Name "spooler" -ErrorAction SilentlyContinue
if ($spooler) {
    # Stop the service if it is running
    if ($spooler.Status -eq 'Running') {
        Write-Output "Stopping the Print Spooler service..."
        Stop-Service -Name "spooler" -Force -ErrorAction SilentlyContinue
        Write-Output "Print Spooler service stopped."
    } else {
        Write-Output "Print Spooler service is not running."
    }
    
    # Set the startup type to Disabled
    Write-Output "Disabling the Print Spooler service..."
    Set-Service -Name "spooler" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Output "Print Spooler service has been disabled."
} else {
    Write-Output "Print Spooler service not found on this system."
}
