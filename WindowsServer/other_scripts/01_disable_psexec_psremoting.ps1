# ========================================================
# Mitigation Script: Disable PS Remoting and PsExec Vectors
# ========================================================

# 1. Disable PowerShell Remoting by stopping and disabling WinRM.
Write-Output "Disabling WinRM service (required for PS Remoting)..."
try {
    Stop-Service -Name WinRM -Force -ErrorAction Stop
    Set-Service -Name WinRM -StartupType Disabled
    Write-Output "WinRM service has been stopped and disabled."
} catch {
    Write-Error "Failed to disable WinRM: $_"
}

# Remove any existing firewall rules for WinRM to further block PS Remoting.
Write-Output "Removing WinRM firewall rules..."
try {
    Get-NetFirewallRule -DisplayGroup "Windows Remote Management" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    Write-Output "WinRM firewall rules removed."
} catch {
    Write-Error "Failed to remove WinRM firewall rules: $_"
}

# 2. Disable PsExec vectors by removing automatic administrative shares.
# PsExec relies on admin$ and other hidden shares to install remote services.
# Disabling auto-creation of admin shares can help mitigate unauthorized remote execution.
Write-Output "Disabling automatic creation of admin shares..."
try {
    # For server editions (admin$ is created via AutoShareServer)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name AutoShareServer -Value 0 -Force
    # For workstation editions (if applicable)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name AutoShareWks -Value 0 -Force
    Write-Output "Automatic admin share creation has been disabled. A restart is required for changes to take effect."
} catch {
    Write-Error "Failed to modify admin share settings: $_"
}

# 3. (Optional) Tighten remote service management firewall rules.
# PsExec typically leverages SMB and remote service management. 
# Removing or modifying these rules can further limit remote service creation.
Write-Output "Removing remote service management firewall rules..."
try {
    Get-NetFirewallRule -DisplayGroup "Remote Service Management" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    Write-Output "Remote service management firewall rules removed."
} catch {
    Write-Error "Failed to remove remote service management firewall rules: $_"
}

# Get all SMB shares on the local system
$allShares = Get-SmbShare

# Filter to administrative shares (names ending with '$').
# Exclude IPC$ if you want to keep it (it's often used for interprocess communication).
$adminShares = $allShares | Where-Object { $_.Name -match "\$$" -and $_.Name -ne "IPC$" }

if ($adminShares.Count -eq 0) {
    Write-Output "No administrative shares found to remove."
} else {
    foreach ($share in $adminShares) {
        try {
            Write-Output "Attempting to remove administrative share: $($share.Name)"
            # Remove the share forcibly without asking for confirmation
            Remove-SmbShare -Name $share.Name -Force -Confirm:$false
            Write-Output "Removed share: $($share.Name)"
        }
        catch {
            Write-Error "Failed to remove share $($share.Name): $_"
        }
    }
}

Write-Output "Script execution complete. Note that administrative shares may be re-created on reboot."
