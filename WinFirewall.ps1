# Define the ports to keep open
$portsToKeepOpen = @(21, 22, 80, 443, 3000, 3306)

# Get the current inbound firewall rules
$inboundRules = Get-NetFirewallRule -Direction Inbound

# Loop through each inbound rule
foreach ($rule in $inboundRules) {
    # Get the associated port(s) for the rule
    $ports = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $rule

    # Check if the rule is for any of the specified ports
    $isPortAllowed = $ports | Where-Object { $portsToKeepOpen -contains $_.PortNumber }

    # If the rule is not for an allowed port, disable it
    if (-not $isPortAllowed) {
        Write-Host "Disabling rule: $($rule.DisplayName)"
        Disable-NetFirewallRule -Name $rule.Name
    }
}

Write-Host "Completed disabling all inbound ports except: $($portsToKeepOpen -join ', ')"
