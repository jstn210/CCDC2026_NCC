# Ensure the script is run with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

# Define the registry path for LSA settings
$lsaRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

Write-Output "Enabling LSA Protection (RunAsPPL) on the Domain Controller..."
try {
    # Enable LSA Protection by setting RunAsPPL to 1.
    # This forces LSASS to run as a protected process.
    Set-ItemProperty -Path $lsaRegPath -Name "RunAsPPL" -Value 1 -Type DWord -Force
    Write-Output "LSA Protection (RunAsPPL) enabled. LSASS will run as a protected process."
}
catch {
    Write-Error "Failed to set RunAsPPL: $_"
}

# (Optional) Set LsaCfgFlags to 1, which is sometimes used in conjunction with RunAsPPL
try {
    Set-ItemProperty -Path $lsaRegPath -Name "LsaCfgFlags" -Value 1 -Type DWord -Force
    Write-Output "LsaCfgFlags set to 1."
}
catch {
    Write-Output "LsaCfgFlags not modified: $_"
}

Write-Output "NOTE: A system reboot is required for these changes to take effect."

# Additional recommendations:
Write-Output "Consider these additional measures to mitigate LSA and secret dumping attacks:"
Write-Output "1. Restrict the SeDebugPrivilege to only trusted administrators to reduce unauthorized LSASS access."
Write-Output "2. Use Windows Firewall or Group Policy to restrict remote access to LSASS and RPC endpoints."
Write-Output "3. Monitor event logs and use EDR solutions to detect attempts to dump LSASS memory."
