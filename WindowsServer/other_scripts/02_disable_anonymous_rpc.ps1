# Ensure the script is running with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

# Define the registry path for LSA settings.
$lsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

# Set RestrictAnonymous to 2 to disallow anonymous enumeration and access.
$restrictAnonymousKey = "restrictanonymous"
$desiredRestrictAnonymousValue = 2

$currentRestrictAnonymous = (Get-ItemProperty -Path $lsaPath -Name $restrictAnonymousKey -ErrorAction SilentlyContinue).$restrictAnonymousKey

if ($null -eq $currentRestrictAnonymous -or $currentRestrictAnonymous -ne $desiredRestrictAnonymousValue) {
    Write-Output "Setting $restrictAnonymousKey to $desiredRestrictAnonymousValue to restrict anonymous RPC access..."
    Set-ItemProperty -Path $lsaPath -Name $restrictAnonymousKey -Value $desiredRestrictAnonymousValue
} else {
    Write-Output "$restrictAnonymousKey is already set to $desiredRestrictAnonymousValue."
}

# Optionally, also set RestrictAnonymousSAM to 1 to further limit anonymous access to the SAM database.
$restrictAnonymousSAMKey = "restrictanonymoussam"
$desiredRestrictAnonymousSAMValue = 1

$currentRestrictAnonymousSAM = (Get-ItemProperty -Path $lsaPath -Name $restrictAnonymousSAMKey -ErrorAction SilentlyContinue).$restrictAnonymousSAMKey

if ($null -eq $currentRestrictAnonymousSAM -or $currentRestrictAnonymousSAM -ne $desiredRestrictAnonymousSAMValue) {
    Write-Output "Setting $restrictAnonymousSAMKey to $desiredRestrictAnonymousSAMValue..."
    Set-ItemProperty -Path $lsaPath -Name $restrictAnonymousSAMKey -Value $desiredRestrictAnonymousSAMValue
} else {
    Write-Output "$restrictAnonymousSAMKey is already set to $desiredRestrictAnonymousSAMValue."
}

Write-Output "Anonymous RPC access restrictions have been updated. A system reboot may be required for all changes to take effect."
