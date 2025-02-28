function Invoke-NetworkAudit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ESXiHost,
        
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Config
    )
    
    $Results = @()
    
    # 5.1-5.3 Firewall Configuration
    $Results += Test-FirewallRules -ESXiHost $ESXiHost
    $Results += Test-DefaultDeny -ESXiHost $ESXiHost
    $Results += Test-DVFilterAPI -ESXiHost $ESXiHost
    
    # 5.4 BPDU Filter
    $Results += Test-BPDUFilter -ESXiHost $ESXiHost
    
    # 5.5 Hardware Management Network
    $Results += Test-HardwareManagementNetwork -ESXiHost $ESXiHost
    
    # 5.6-5.8 Virtual Switch Security
    $Results += Test-ForgedTransmits -ESXiHost $ESXiHost
    $Results += Test-MACChanges -ESXiHost $ESXiHost
    $Results += Test-PromiscuousMode -ESXiHost $ESXiHost
    
    # 5.9-5.11 VLAN Configuration
    $Results += Test-DefaultVLAN -ESXiHost $ESXiHost
    $Results += Test-VGTConfiguration -ESXiHost $ESXiHost
    $Results += Test-ManagementNetwork -ESXiHost $ESXiHost
    
    return $Results
}

function Test-FirewallRules {
    param([string]$ESXiHost)
    
    try {
        $FirewallRules = Get-VMHostFirewallException -VMHost $ESXiHost
        $Allowed = $FirewallRules | Where-Object { $_.Enabled }
        return @{
            ID = "5.1"
            Description = "Host firewall must only allow traffic from authorized networks"
            Status = if ($Allowed.Count -gt 0) { "Review" } else { "Pass" }
            Details = "Found $($Allowed.Count) enabled firewall rules"
        }
    } catch {
        return @{
            ID = "5.1"
            Description = "Host firewall must only allow traffic from authorized networks"
            Status = "Error"
            Details = "Error checking firewall rules: $_"
        }
    }
}

# Implement remaining test functions following similar pattern