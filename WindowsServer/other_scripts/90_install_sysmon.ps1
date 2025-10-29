# Define variables for download and paths
$SysmonDownloadUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$SysmonZipPath     = "C:\tmp\Sysmon.zip"
$SysmonExtractPath = "C:\tmp\Sysmon"
$ConfigRepoUrl     = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml"
$ConfigRepoPath    = "C:\tmp\sysmon-config"

if (-not (Test-Path "C:\tmp")) {
    New-Item -ItemType Directory -Path "C:\tmp"
}

if (-not (Test-Path $ConfigRepoPath)) {
    Write-Host "Cloning sysmon-config repository..."
    Invoke-WebRequest $ConfigRepoUrl -OutFile $ConfigRepoPath
} else {
    Write-Host "sysmon-config repository already exists"
}

# Download Sysmon if it is not already downloaded
if (-not (Test-Path "$SysmonExtractPath\Sysmon64.exe")) {
    Write-Host "Downloading Sysmon..."
    Invoke-WebRequest -Uri $SysmonDownloadUrl -OutFile $SysmonZipPath

    Write-Host "Extracting Sysmon..."
    Expand-Archive -Path $SysmonZipPath -DestinationPath $SysmonExtractPath -Force
} else {
    Write-Host "Sysmon is already downloaded."
}

# Define the path to the Sysmon executable and config file
$SysmonExe = "$SysmonExtractPath\Sysmon64.exe"
# The config file name might be "sysmonconfig-export.xml" or "sysmonconfig.xml" depending on your preference.
# Adjust the file name if necessary.
$ConfigFile = "$ConfigRepoPath"

# Check if the config file exists
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Config file not found at $ConfigFile. Please check the repository contents."
    exit 1
}

# Install Sysmon using the downloaded executable and configuration file.
Write-Host "Installing Sysmon with the provided configuration..."
& $SysmonExe -accepteula -i $ConfigFile

Write-Host "Sysmon installation complete."