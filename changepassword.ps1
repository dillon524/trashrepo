# Define the admin and other user lists
$AdminUsers = @("president", "vicepresident", "defenseminister", "secretary") # List of admin users
$OtherUsers = @("general", "admiral", "judge", "bodyguard", "cabinetofficial", "treasurer") # List of other users

# Function to generate a random password
function New-RandomPassword {
    $Length = 12
    [System.Web.Security.Membership]::GeneratePassword($Length, 2)
}

# Set passwords for the specified admin users
Write-Output "Admin Users:"
foreach ($AdminUser in $AdminUsers) {
    $AdminPassword = New-RandomPassword
    Set-LocalUser -Name $AdminUser -Password (ConvertTo-SecureString -AsPlainText $AdminPassword -Force)
    Write-Output "${AdminUser}: ${AdminPassword}"  # Print with colon separator
}

Write-Output "Local Users:"
# Set random passwords for other specified users
foreach ($User in $OtherUsers) {
    $UserPassword = New-RandomPassword
    Set-LocalUser -Name $User -Password (ConvertTo-SecureString -AsPlainText $UserPassword -Force)
    Write-Output "${User}: ${UserPassword}"  # Print with colon separator
}

# Remove users who are not in the specified lists
$AllUsers = Get-LocalUser
foreach ($User in $AllUsers) {
    if ($User.Name -notin $AdminUsers -and $User.Name -notin $OtherUsers) {
        try {
            Remove-LocalUser -Name $User.Name
            Write-Output "Deleted unauthorized user: $($User.Name)"
        } catch {
            Write-Output "Failed to delete user: $($User.Name). Error: $_"
        }
    }
}

Write-Output "Password changes complete. Unauthorized users have been deleted."
