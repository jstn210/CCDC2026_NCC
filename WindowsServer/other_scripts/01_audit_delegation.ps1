# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Define admin groups to exclude (adjust as needed)
$adminGroups = @("Domain Admins", "Enterprise Admins", "Administrators", "Schema Admins")

# The flag for unconstrained delegation (Trust this user for delegation to any service)
$TRUSTED_FOR_DELEGATION = 0x80000

# Get all user accounts with delegation-related properties
$allUsers = Get-ADUser -Filter * -Properties msDS-AllowedToDelegateTo, userAccountControl, memberOf

# Filter to non-administrative accounts that have either:
#  - A non-empty msDS-AllowedToDelegateTo attribute (constrained delegation)
#  - The unconstrained delegation flag set in userAccountControl
$delegatingUsers = $allUsers | Where-Object {
    # Check if the user is a member of any of the admin groups. We assume memberOf contains the full DN for each group.
    $isAdmin = $false
    if ($_.memberOf) {
        foreach ($group in $adminGroups) {
            if ($_.memberOf -match "CN=$group,") {
                $isAdmin = $true
                break
            }
        }
    }
    if (-not $isAdmin) {
        # Check for overly permissive delegation:
        # Either unconstrained delegation flag is set OR msDS-AllowedToDelegateTo is not empty.
        ($_.userAccountControl -band $TRUSTED_FOR_DELEGATION) -eq $TRUSTED_FOR_DELEGATION -or
        ($_."msDS-AllowedToDelegateTo" -and $_."msDS-AllowedToDelegateTo".Count -gt 0)
    }
}

Write-Output "Found $($delegatingUsers.Count) non-admin accounts with overly permissive delegation settings."
$delegatingUsers | Format-Table Name, SamAccountName, msDS-AllowedToDelegateTo, userAccountControl -AutoSize

# Remove delegation settings for each found account.
foreach ($user in $delegatingUsers) {
    Write-Output "Processing account: $($user.SamAccountName)"
    try {
        # If msDS-AllowedToDelegateTo attribute exists, clear it.
        if ($user."msDS-AllowedToDelegateTo") {
            Set-ADUser -Identity $user.DistinguishedName -Clear msDS-AllowedToDelegateTo
            Write-Output "Cleared msDS-AllowedToDelegateTo attribute."
        }
        
        # Remove the unconstrained delegation flag if it is set.
        if (($user.userAccountControl -band $TRUSTED_FOR_DELEGATION) -eq $TRUSTED_FOR_DELEGATION) {
            $newUAC = $user.userAccountControl -band (-bnot $TRUSTED_FOR_DELEGATION)
            Set-ADUser -Identity $user.DistinguishedName -Replace @{userAccountControl = $newUAC}
            Write-Output "Removed unconstrained delegation flag from userAccountControl."
        }
    } catch {
        Write-Error "Failed to update $($user.SamAccountName): $_"
    }
}

Write-Output "Delegation cleanup complete."
