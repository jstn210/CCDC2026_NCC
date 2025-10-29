# Import the Group Policy module (requires RSAT or the appropriate modules installed)
Import-Module GroupPolicy

# Specify the GPO name for the Default Domain Controller Policy
$gpoName = "Default Domain Controllers Policy"

# Define the registry keys and secure values

# 1. "Network access: Do not allow anonymous enumeration of SAM accounts and shares"
# Registry Path: HKLM\System\CurrentControlSet\Control\Lsa
# Value Name: restrictanonymous
# Secure Value: 2 (Disallow anonymous enumeration)
Write-Output "Configuring 'restrictanonymous' to 2 in $gpoName..."
Set-GPRegistryValue -Name $gpoName -Key "HKLM\System\CurrentControlSet\Control\Lsa" -ValueName "restrictanonymous" -Type DWord -Value 2

# 2. "Network access: Let Everyone permissions apply to anonymous users"
# Registry Path: HKLM\System\CurrentControlSet\Control\Lsa
# Value Name: everyoneincludesanonymous
# Secure Value: 0 (Do not apply Everyone permissions to anonymous users)
Write-Output "Configuring 'everyoneincludesanonymous' to 0 in $gpoName..."
Set-GPRegistryValue -Name $gpoName -Key "HKLM\System\CurrentControlSet\Control\Lsa" -ValueName "everyoneincludesanonymous" -Type DWord -Value 0

Write-Output "Secure defaults have been applied to the $gpoName."
Write-Output "Please run 'gpupdate /force' on target systems to apply the changes immediately."


## EXPAND THIS ONE