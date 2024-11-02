# Define the allowed ports
$allowedPorts = @(
    @{ Port = 3306; Protocol = "TCP"; Name = "MySQL" },
    @{ Port = 3000; Protocol = "TCP"; Name = "Grafana" },
    @{ Port = 445; Protocol = "TCP"; Name = "SMB" },
    @{ Port = 139; Protocol = "TCP"; Name = "SMB" },
    @{ Port = 80; Protocol = "TCP"; Name = "IIS_HTTP" },
    @{ Port = 443; Protocol = "TCP"; Name = "IIS_HTTPS" },
    @{ Port = 5985; Protocol = "TCP"; Name = "WinRM_HTTP" },
    @{ Port = 5986; Protocol = "TCP"; Name = "WinRM_HTTPS" },
    @{ Port = 53; Protocol = "TCP"; Name = "DNS" },
    @{ Port = 53; Protocol = "UDP"; Name = "DNS" },
    @{ Port = 80; Protocol = "TCP"; Name = "Docker_HTTP" },
    @{ Port = 143; Protocol = "TCP"; Name = "IMAP" },
    @{ Port = 25; Protocol = "TCP"; Name = "SMTP" },
    @{ Port = 21; Protocol = "TCP"; Name = "FTP" },
    @{ Port = 20; Protocol = "TCP"; Name = "FTP_Data" }
)

# Loop through each allowed port and create a rule if it doesn't exist
foreach ($portInfo in $allowedPorts) {
    $port = $portInfo.Port
    $protocol = $portInfo.Protocol
    $name = $portInfo.Name

    # Check if the rule already exists
    $existingRule = Get-NetFirewallRule | Where-Object { $_.DisplayName -eq $name }
    
    if (-not $existingRule) {
        Write-Host "Opening port $port ($protocol) for $name"
        
        # Create the firewall rule
        New-NetFirewallRule -DisplayName $name -Direction Inbound -Action Allow -Protocol $protocol -LocalPort $port
    } else {
        Write-Host "Rule for $name already exists."
    }
}

Write-Host "Completed opening the specified ports."

