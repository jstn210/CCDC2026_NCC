# Define the target directory
$targetDir = "C:\tmp"

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $targetDir)) {
    Write-Output "Directory $targetDir does not exist. Creating it..."
    New-Item -Path $targetDir -ItemType Directory -Force
} else {
    Write-Output "Directory $targetDir already exists."
}

# Define the download URL and the destination file path
$url = "https://github.com/peass-ng/PEASS-ng/releases/download/20250301-c97fb02a/winPEAS.bat"
$outputFile = Join-Path $targetDir "winPEAS.bat"

# Download the winPEAS.bat file
Write-Output "Downloading winPEAS.bat from $url to $outputFile..."
try {
    Invoke-WebRequest -Uri $url -OutFile $outputFile -UseBasicParsing
    Write-Output "Download complete."
} catch {
    Write-Error "Failed to download winPEAS.bat: $_"
    exit 1
}

# Execute the BAT file
Write-Output "Executing winPEAS.bat..."
try {
    $outputLogFile = Join-Path $targetDir "winPEAS.log"
    & $outputFile 2>&1 | Tee-Object -FilePath $outputLogFile

    Write-Output "winPEAS.bat execution completed."
} catch {
    Write-Error "Failed to execute winPEAS.bat: $_"
}
