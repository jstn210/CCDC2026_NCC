# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Define the DONT_REQUIRE_PREAUTH flag (0x00400000 in hexadecimal, or 4194304 in decimal)
$DontRequirePreauth = 0x00400000

# Retrieve all domain users with their userAccountControl property
$users = Get-ADUser -Filter * -Properties userAccountControl, SamAccountName, DistinguishedName

foreach ($user in $users) {
    # Check if the "Do Not Require Kerberos Preauthentication" flag is set
    if (($user.userAccountControl -band $DontRequirePreauth) -eq $DontRequirePreauth) {
        Write-Output "User $($user.SamAccountName) has PreAuthNotRequired set. Clearing flag..."
        
        # Clear the flag while preserving other bits in userAccountControl
        $newUAC = $user.userAccountControl -band (-bnot $DontRequirePreauth)
        
        try {
            Set-ADUser -Identity $user.DistinguishedName -Replace @{userAccountControl = $newUAC}
            Write-Output "User $($user.SamAccountName) updated successfully."
        } catch {
            Write-Error "Failed to update user $($user.SamAccountName): $_"
        }
    } else {
        Write-Output "User $($user.SamAccountName) already requires preauthentication."
    }
}

Write-Output "PreAuthNotRequired flag removal process is complete."
