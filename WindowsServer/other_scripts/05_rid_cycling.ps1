# Prevent NULL sessions for enumaration of SAM accounts

# Set the "restrictanonymous" key to 1 to disable enumeration of SAM accounts
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "restrictanonymous" -Value 1
# Disable the Guest account
Disable-LocalUser -Name "Guest"

# For SMB configurations, you can disable insecure guest authentication:
Set-SmbServerConfiguration -RejectUnencryptedAccess $true -Force
Set-SmbServerConfiguration -EnableInsecureGuestAuth $false -Force
# Import the Group Policy module (if not already loaded)
Import-Module GroupPolicy

# Create or update a GPO with the required registry setting for restricting anonymous access
$GPOName = "Harden Domain Controller - Restrict Anonymous"
New-GPO -Name $GPOName -ErrorAction SilentlyContinue

# Configure the registry setting in the GPO
Set-GPRegistryValue -Name $GPOName -Key "HKLM\System\CurrentControlSet\Control\Lsa" -ValueName "restrictanonymous" -Type DWord -Value 1

# Link the GPO to the appropriate OU (adjust the distinguished name as needed)
New-GPLink -Name $GPOName -Target "OU=DomainControllers,DC=yourdomain,DC=com"

# Check which DC holds the RID Master FSMO role
Get-ADDomain | Select-Object -ExpandProperty RIDMaster

# Check replication status across domain controllers
repadmin /replsummary
