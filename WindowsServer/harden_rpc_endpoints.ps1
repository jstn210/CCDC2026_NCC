# Ensure the script is run with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

# Define trusted IP ranges for RPC access (adjust these to your environment)
$trustedRPCIPs = "192.168.1.0/24"

# Harden RPC Endpoint Mapper (port 135)
Write-Output "Restricting inbound RPC connections (port 135) to trusted IPs ($trustedRPCIPs)..."
# Allow inbound connections on port 135 only from the trusted range.
New-NetFirewallRule -DisplayName "Allow RPC Endpoint Mapper from Trusted IPs" `
    -Direction Inbound -Protocol TCP -LocalPort 135 -RemoteAddress $trustedRPCIPs -Action Allow -Profile Domain

# Block all other inbound connections on port 135
Write-Output "Blocking inbound RPC connections (port 135) from all other sources..."
New-NetFirewallRule -DisplayName "Block RPC Endpoint Mapper from Untrusted IPs" `
    -Direction Inbound -Protocol TCP -LocalPort 135 -RemoteAddress Any -Action Block -Profile Domain

# (Optional) Harden dynamic RPC port range (typically 49152-65535 on Windows Server 2012 and later)
# Only enable this if you can define a trusted IP range for dynamic RPC as well.
$dynamicRpcPortRange = "49152-65535"
Write-Output "Restricting inbound dynamic RPC connections ($dynamicRpcPortRange) to trusted IPs ($trustedRPCIPs)..."
New-NetFirewallRule -DisplayName "Allow Dynamic RPC from Trusted IPs" `
    -Direction Inbound -Protocol TCP -LocalPort $dynamicRpcPortRange -RemoteAddress $trustedRPCIPs -Action Allow -Profile Domain

Write-Output "Blocking inbound dynamic RPC connections from untrusted sources..."
New-NetFirewallRule -DisplayName "Block Dynamic RPC from Untrusted IPs" `
    -Direction Inbound -Protocol TCP -LocalPort $dynamicRpcPortRange -RemoteAddress Any -Action Block -Profile Domain

Write-Output "RPC endpoint hardening rules applied. Please verify that these changes do not interfere with legitimate operations."

#HKLM:\SYSTEM\CurrentControlSet\Control\Lsa : Restrictanonymous => 2