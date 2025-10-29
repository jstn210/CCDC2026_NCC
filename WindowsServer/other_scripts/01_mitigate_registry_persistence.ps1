# Define the registry path for startup entries.
$runKeyPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"

try {
    # Retrieve current registry values.
    $currentEntries = Get-ItemProperty -Path $runKeyPath -ErrorAction Stop

    Write-Output "Current entries in $runKeyPath :"
    # List out each entry (excluding system properties)
    $currentEntries.PSObject.Properties | Where-Object {
        $_.Name -notmatch "^PS"
    } | ForEach-Object {
        Write-Output "Name: $($_.Name) - Value: $($_.Value)"
    }

    # Ask for confirmation before clearing the entries.
    $confirmation = Read-Host "Do you want to remove all entries from this key? (Y/N)"
    if ($confirmation -eq "Y") {
        # Remove each entry under the Run key.
        $currentEntries.PSObject.Properties | Where-Object {
            $_.Name -notmatch "^PS"
        } | ForEach-Object {
            Remove-ItemProperty -Path $runKeyPath -Name $_.Name -Force
            Write-Output "Removed entry: $($_.Name)"
        }
        Write-Output "All entries removed from $runKeyPath."
    } else {
        Write-Output "No changes made to $runKeyPath."
    }
} catch {
    Write-Error "Error accessing or modifying the registry: $_"
}
