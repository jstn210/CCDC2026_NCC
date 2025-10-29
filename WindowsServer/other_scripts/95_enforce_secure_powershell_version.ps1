# Define the minimum safe version (or latest version you wish to enforce)
$MinSafeVersion = [version]"7.3.0"   # adjust as needed; this example requires at least PowerShell 7.3.0
$LatestInstallerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.5/PowerShell-7.3.5-win-x64.msi"  # update as necessary

# Function to get installed PowerShell Core versions (installed via MSI typically show in registry)
function Get-InstalledPowerShellCore {
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )
    $installedPS = @()
    foreach ($path in $registryPaths) {
        Get-ChildItem $path -ErrorAction SilentlyContinue | ForEach-Object {
            $displayName = ($_ | Get-ItemProperty -Name DisplayName -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -and $displayName -like "PowerShell *") {
                $versionStr = ($_ | Get-ItemProperty -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
                try {
                    $version = [version]$versionStr
                }
                catch {
                    $version = $null
                }
                $uninstallString = ($_ | Get-ItemProperty -Name UninstallString -ErrorAction SilentlyContinue).UninstallString
                $installedPS += [PSCustomObject]@{
                    Name            = $displayName
                    Version         = $version
                    UninstallString = $uninstallString
                }
            }
        }
    }
    return $installedPS
}

# Function to download and install the latest PowerShell MSI package silently
function Install-LatestPowerShell {
    param (
        [string]$InstallerUrl,
        [string]$DownloadPath = "$env:TEMP\pwsh_latest.msi"
    )
    
    Write-Output "Downloading latest PowerShell installer from $InstallerUrl..."
    Invoke-WebRequest -Uri $InstallerUrl -OutFile $DownloadPath -UseBasicParsing

    Write-Output "Installing latest PowerShell..."
    $msiArgs = "/i `"$DownloadPath`" /qn /norestart"
    $process = Start-Process -FilePath msiexec.exe -ArgumentList $msiArgs -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Output "Latest PowerShell installed successfully."
    } else {
        Write-Error "Installation failed with exit code $($process.ExitCode)."
    }
}

# Function to uninstall an old PowerShell version based on its uninstall string
function Uninstall-PowerShellVersion {
    param (
        [string]$UninstallString
    )
    
    Write-Output "Attempting to uninstall PowerShell using command: $UninstallString"
    
    # Some uninstall strings are wrapped in quotes and may include command-line parameters.
    # We assume the uninstall string can be executed silently.
    try {
        # If the uninstall string starts with "MsiExec", we add silent switches if not already present.
        if ($UninstallString -match "msiexec\.exe") {
            if ($UninstallString -notmatch "/qn") {
                $UninstallString += " /qn /norestart"
            }
        }
        Invoke-Expression $UninstallString
        Write-Output "Uninstallation initiated."
    } catch {
        Write-Error "Failed to uninstall PowerShell: $_"
    }
}

# Main script logic
Write-Output "Identifying installed PowerShell versions..."
$installedPS = Get-InstalledPowerShellCore
if ($installedPS.Count -eq 0) {
    Write-Output "No standalone PowerShell Core installations found."
} else {
    foreach ($ps in $installedPS) {
        Write-Output "Found: $($ps.Name) - Version: $($ps.Version)"
    }
}

# Check if any installed version is below the safe version threshold
$oldVersions = $installedPS | Where-Object { $_.Version -and $_.Version -lt $MinSafeVersion }
$latestInstalled = $installedPS | Where-Object { $_.Version -and $_.Version -ge $MinSafeVersion }

if ($latestInstalled) {
    Write-Output "A safe PowerShell version is already installed."
} else {
    Write-Output "No safe PowerShell version found. Proceeding to install the latest version..."
    Install-LatestPowerShell -InstallerUrl $LatestInstallerUrl
}

# Uninstall old vulnerable versions (if any)
if ($oldVersions) {
    foreach ($old in $oldVersions) {
        Write-Output "Old version detected: $($old.Name) - Version: $($old.Version)"
        if ($old.UninstallString) {
            Uninstall-PowerShellVersion -UninstallString $old.UninstallString
        } else {
            Write-Output "No uninstall string found for $($old.Name). Manual removal may be required."
        }
    }
} else {
    Write-Output "No vulnerable (old) PowerShell versions found for removal."
}

Write-Output "Script execution complete."
