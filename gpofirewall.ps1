Import-Module GroupPolicy

# Create a new GPO
$gpoName = "Firewall Rules"
$gpo = New-GPO -Name $gpoName

# Define the list of firewall rules
$firewallRules = @(
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

# Apply firewall rules to the GPO
foreach ($rule in $firewallRules) {
    New-NetFirewallRule -DisplayName $rule.Name -Direction Inbound -Action Allow -Protocol $rule.Protocol -LocalPort $rule.Port -GroupPolicyObject $gpo
}

# Link the GPO to the desired OU or domain
$ouPath = "OU=YourOU,DC=YourDomain,DC=com"
New-GPLink -Name $gpoName -Target $ouPath
