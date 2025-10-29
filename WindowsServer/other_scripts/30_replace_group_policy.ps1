# Ensure you run this script with Domain Admin privileges
# Import the GroupPolicy module
Import-Module GroupPolicy

# Define backup folder
$backupPath = "C:\GPOBackup"
if (-not (Test-Path $backupPath)) {
    Write-Output "Creating backup folder at $backupPath..."
    New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
}

# Define the names of the default GPOs
$defaultDomainPolicy = "Default Domain Policy"
$defaultDCPolicy = "Default Domain Controller Policy"

# Backup the current default GPOs
Write-Output "Backing up '$defaultDomainPolicy'..."
Backup-GPO -Name $defaultDomainPolicy -Path $backupPath -ErrorAction Stop

Write-Output "Backing up '$defaultDCPolicy'..."
Backup-GPO -Name $defaultDCPolicy -Path $backupPath -ErrorAction Stop

# Remove the default GPOs
Write-Output "Removing '$defaultDomainPolicy'..."
Remove-GPO -Name $defaultDomainPolicy -Confirm:$false -ErrorAction Stop

Write-Output "Removing '$defaultDCPolicy'..."
Remove-GPO -Name $defaultDCPolicy -Confirm:$false -ErrorAction Stop

# Restore default GPOs using DCGPOFix (resets both default GPOs to their original state)
$dcgpofixPath = "$env:SystemRoot\system32\dcgpofix.exe"
if (Test-Path $dcgpofixPath) {
    Write-Output "Running DCGPOFix to restore default GPOs..."
    # /q for quiet mode; remove it if you want to see prompts.
    Start-Process -FilePath $dcgpofixPath -ArgumentList "/q" -Wait
    Write-Output "Default GPOs have been restored to their default settings."
} else {
    Write-Error "DCGPOFix not found at $dcgpofixPath. Cannot restore default GPOs automatically."
}
