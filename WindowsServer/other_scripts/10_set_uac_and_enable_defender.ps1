# Ensure the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

# UAC Registry Path
$uacRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

Write-Output "Configuring UAC to the maximum (most secure) settings..."
try {
    # Enable UAC
    Set-ItemProperty -Path $uacRegPath -Name "EnableLUA" -Value 1 -Force
    # Set Administrator consent prompt to "Always notify"
    # 2 = Always Notify (i.e. prompt on secure desktop and for elevation requests)
    Set-ItemProperty -Path $uacRegPath -Name "ConsentPromptBehaviorAdmin" -Value 2 -Force
    # Ensure that prompts are shown on the secure desktop
    Set-ItemProperty -Path $uacRegPath -Name "PromptOnSecureDesktop" -Value 1 -Force

    Write-Output "UAC settings have been configured. A system restart is required for changes to take full effect."
}
catch {
    Write-Error "Failed to configure UAC settings: $_"
}

Write-Output "Forcing Windows Defender to be enabled..."
try {
    # Remove any policy that might disable Windows Defender
    $defenderPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    if (Test-Path $defenderPolicyPath) {
        # If the "DisableAntiSpyware" or "DisableAntiVirus" keys exist, set them to 0.
        if (Get-ItemProperty -Path $defenderPolicyPath -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue) {
            Set-ItemProperty -Path $defenderPolicyPath -Name "DisableAntiSpyware" -Value 0 -Force
        }
        if (Get-ItemProperty -Path $defenderPolicyPath -Name "DisableAntiVirus" -ErrorAction SilentlyContinue) {
            Set-ItemProperty -Path $defenderPolicyPath -Name "DisableAntiVirus" -Value 0 -Force
        }
    }

    # Use the Defender cmdlet to re-enable real-time monitoring
    Import-Module Defender -ErrorAction SilentlyContinue
    if (Get-Command -Name Set-MpPreference -ErrorAction SilentlyContinue) {
        Set-MpPreference -DisableRealtimeMonitoring $false
        Write-Output "Windows Defender real-time monitoring has been enabled."
    } else {
        Write-Output "Set-MpPreference cmdlet not found. Ensure that Windows Defender is installed and the Defender module is available."
    }
}
catch {
    Write-Error "Failed to enable Windows Defender: $_"
}

Write-Output "Script execution complete. Please restart your computer for all changes to take effect."
