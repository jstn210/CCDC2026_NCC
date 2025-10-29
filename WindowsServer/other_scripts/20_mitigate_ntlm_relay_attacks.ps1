# Ensure the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

# 1. Enforce SMB signing and strong encryption on the domain controller
Write-Output "Enforcing SMB signing and rejecting unencrypted access..."
try {
    # Require SMB signing for the server
    Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
    # Reject any unencrypted SMB connections
    Set-SmbServerConfiguration -RejectUnencryptedAccess $true -Force
    # (Optional) Require strong (128-bit) session keys
    Set-SmbServerConfiguration -RequireStrongKey $true -Force
    Write-Output "SMB server configuration updated."
}
catch {
    Write-Error "Failed to update SMB server configuration: $_"
}

# 2. Configure NTLM settings via registry
$ntlmRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"

# Set NTLMMinServerSec to require 128-bit encryption and signing
# Recommended value: 0x20080000 (hex) ensures that NTLM responses use strong crypto
$desiredNTLMMinServerSec = 0x20080000
try {
    Write-Output "Setting NTLMMinServerSec to $($desiredNTLMMinServerSec) to enforce strong NTLM authentication..."
    Set-ItemProperty -Path $ntlmRegistryPath -Name "NTLMMinServerSec" -Value $desiredNTLMMinServerSec -Type DWord
    Write-Output "NTLMMinServerSec set successfully."
}
catch {
    Write-Error "Failed to set NTLMMinServerSec: $_"
}

# 3. (Optional) Restrict NTLM usage further by controlling sending and receiving NTLM
# These settings may help block legacy clients from using NTLM:
try {
    Write-Output "Optionally restricting NTLM traffic..."
    # Restrict sending NTLM (1 means block NTLM from being sent)
    Set-ItemProperty -Path $ntlmRegistryPath -Name "RestrictSendingNTLM" -Value 1 -Type DWord
    # Restrict receiving NTLM (1 means block NTLM authentication attempts)
    Set-ItemProperty -Path $ntlmRegistryPath -Name "RestrictReceivingNTLM" -Value 1 -Type DWord
    Write-Output "NTLM sending and receiving restrictions applied."
}
catch {
    Write-Error "Failed to apply NTLM restrictions: $_"
}

Write-Output "NTLM relay mitigations have been configured. A system restart may be required for some changes to take effect."
