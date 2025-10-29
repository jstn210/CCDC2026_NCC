# Define the target directory and ensure it exists
$targetDir = "C:\tmp"
if (-not (Test-Path -Path $targetDir)) {
    Write-Output "Directory $targetDir does not exist. Creating it..."
    New-Item -Path $targetDir -ItemType Directory -Force
} else {
    Write-Output "Directory $targetDir already exists."
}

# Define the download URL and output file path
$url = "https://github.com/SnaffCon/Snaffler/releases/download/1.0.184/Snaffler.exe"
$outputFile = Join-Path $targetDir "Snaffler.exe"

# Download Snaffler.exe
Write-Output "Downloading Snaffler.exe from $url to $outputFile..."
try {
    Invoke-WebRequest -Uri $url -OutFile $outputFile -UseBasicParsing
    Write-Output "Download complete."
}
catch {
    Write-Error "Failed to download Snaffler.exe: $_"
    exit 1
}

# Run Snaffler.exe with specified parameters
Write-Output "Executing Snaffler.exe with parameters '-s -o snaffler_output.log'..."
try {
    Start-Process -FilePath $outputFile -ArgumentList "-s", "-o snaffler_output.log" -NoNewWindow -Wait
    Write-Output "Snaffler.exe has finished executing."
}
catch {
    Write-Error "Failed to execute Snaffler.exe: $_"
}
