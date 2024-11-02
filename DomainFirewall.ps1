# List of allowed ports and their descriptions
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

# Function to apply firewall rules to a specific computer
function Set-FirewallRules {
    param (
        [string]$computerName
    )

    Invoke-Command -ComputerName $computerName -ScriptBlock {
        # Deny all inbound connections by default
        Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block

        # Allow specified ports
        foreach ($port in $using:allowedPorts) {
            New-NetFirewallRule -DisplayName $port.Name -Direction Inbound -Action Allow -Protocol $port.Protocol -LocalPort $port.Port
        }

        # Allow ICMP (ping)
        New-NetFirewallRule -DisplayName "Allow ICMP" -Direction Inbound -Action Allow -Protocol ICMPv4

        Write-Host "Firewall rules applied successfully on $env:COMPUTERNAME."
    } -ErrorAction Stop
}

# Get the list of computers in the domain
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# Apply firewall rules to each computer
foreach ($computer in $computers) {
    try {
        Set-FirewallRules -computerName $computer
    } catch {
        Write-Host "Failed to apply rules on $computer: $($_.Exception.Message)"
    }
}
