# Import the Active Directory module
Import-Module ActiveDirectory

# Audit: Find all computer accounts that have msDS-AllowedToActOnBehalfOfOtherEntity set.
$affectedComputers = Get-ADComputer -Filter { msDS-AllowedToActOnBehalfOfOtherEntity -like "*" } -Properties msDS-AllowedToActOnBehalfOfOtherEntity

if ($affectedComputers.Count -eq 0) {
    Write-Output "No computer accounts found with msDS-AllowedToActOnBehalfOfOtherEntity set."
} else {
    Write-Output "Found the following computer accounts with msDS-AllowedToActOnBehalfOfOtherEntity set:"
    foreach ($comp in $affectedComputers) {
        Write-Output "$($comp.Name): $($comp."msDS-AllowedToActOnBehalfOfOtherEntity")"
    }

    # OPTIONAL: Remove the attribute from objects that should not have delegation.
    # CAUTION: Make sure you have verified that these settings are not needed before removal.
    foreach ($comp in $affectedComputers) {
        $confirm = Read-Host "Do you want to clear msDS-AllowedToActOnBehalfOfOtherEntity for $($comp.Name)? (Y/N)"
        if ($confirm -eq "Y") {
            try {
                Set-ADComputer -Identity $comp.DistinguishedName -Clear msDS-AllowedToActOnBehalfOfOtherEntity
                Write-Output "Cleared msDS-AllowedToActOnBehalfOfOtherEntity for $($comp.Name)."
            } catch {
                Write-Error "Failed to clear delegation for $($comp.Name): $_"
            }
        } else {
            Write-Output "Skipped $($comp.Name)."
        }
    }
}
