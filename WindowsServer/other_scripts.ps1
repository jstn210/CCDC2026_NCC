[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get all PowerShell script files in the other_scripts directory, sorted by name.
$scriptFiles = Get-ChildItem -Path "./other_scripts" -Filter "*.ps1" | Sort-Object -Property Name

foreach ($script in $scriptFiles) {
    Write-Output "Running $($script.FullName)..."
    try {
        # Invoke the script and ignore errors.
        & $script.FullName -ErrorAction SilentlyContinue
    } catch {
        Write-Output "Error encountered in $($script.Name). Continuing to next script..."
    }
}

Write-Output "All scripts executed."
