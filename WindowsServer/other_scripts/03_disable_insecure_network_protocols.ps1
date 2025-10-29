# Disable LLMNR by configuring the registry.
# This creates (or updates) the following key:
# HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient\EnableMulticast (DWORD) = 0
try {
    $llmnrRegPath = "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient"
    if (-not (Test-Path $llmnrRegPath)) {
        Write-Output "Creating registry path for LLMNR settings..."
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT" -Name "DNSClient" -Force | Out-Null
    }
    Write-Output "Disabling LLMNR..."
    New-ItemProperty -Path $llmnrRegPath -Name "EnableMulticast" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Output "LLMNR disabled. A restart or a gpupdate /force may be required for changes to take effect."
} catch {
    Write-Error "Failed to disable LLMNR: $_"
}

# Disable NBNS (NetBIOS over TCP/IP) using WMI.
# The SetNetBIOS method accepts a parameter of:
# 2 = Disable NetBIOS over TCP/IP.
try {
    Write-Output "Disabling NetBIOS over TCP/IP on all IP-enabled adapters..."
    Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" | ForEach-Object {
        $result = $_.SetNetBIOS(2)
        if ($result.ReturnValue -eq 0) {
            Write-Output "NetBIOS disabled on adapter: $($_.Description)"
        } else {
            Write-Output "Failed to disable NetBIOS on adapter: $($_.Description) - Return code: $($result.ReturnValue)"
        }
    }
} catch {
    Write-Error "Failed to disable NBNS: $_"
}

# Disable mDNS.
# On Windows, mDNS may be provided by the Bonjour Service (mDNSResponder). 
# If installed, stop the service and set its startup type to Disabled.
try {
    $mDnsService = Get-Service -Name "mDNSResponder" -ErrorAction SilentlyContinue
    if ($mDnsService) {
        Write-Output "Disabling mDNS (Bonjour Service)..."
        Stop-Service -Name "mDNSResponder" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "mDNSResponder" -StartupType Disabled
        Write-Output "mDNS (Bonjour) service disabled."
    } else {
        Write-Output "mDNS (Bonjour) service not found. It may not be installed on this system."
    }
} catch {
    Write-Error "Failed to disable mDNS: $_"
}

Write-Output "Protocol hardening complete. Please verify that these settings meet your environment’s needs and test for any unintended impact."
