# Define variables
$gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe"
$installerPath = "$env:TEMP\Git-Installer.exe"

# Test if Git is already installed
if (Test-Path -Path "C:\Program Files\Git") {
    Write-Output "Git is already installed. Exiting..."
    exit 0
}

# Download the Git for Windows installer
Write-Output "Downloading Git for Windows installer from $gitInstallerUrl..."
try {
    Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $installerPath -UseBasicParsing
    Write-Output "Download complete."
} catch {
    Write-Error "Failed to download Git installer: $_"
    exit 1
}

# Install Git silently
Write-Output "Starting silent installation of Git for Windows..."
try {
    # The following arguments use Inno Setup's silent switches:
    # /VERYSILENT - run installation without user interface
    # /NORESTART - do not restart after installation
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
    Write-Output "Git for Windows installed successfully."
} catch {
    Write-Error "Git installation failed: $_"
    exit 1
}

# Clean up the installer
Write-Output "Cleaning up installer..."
try {
    Remove-Item -Path $installerPath -Force
    Write-Output "Installer removed."
} catch {
    Write-Error "Failed to remove installer file: $_"
}
