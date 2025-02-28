function Invoke-BaseAudit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ESXiHost,
        
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Config
    )
    
    $Results = @()
    
    # 2.1 Software Support Status
    $Results += Test-SoftwareSupport -ESXiHost $ESXiHost
    
    # 2.2 Software Updates
    $Results += Test-SoftwareUpdates -ESXiHost $ESXiHost
    
    # 2.3 Secure Boot Enforcement
    $Results += Test-SecureBootEnforcement -ESXiHost $ESXiHost
    
    # 2.4 Image Profile Acceptance
    $Results += Test-ImageProfile -ESXiHost $ESXiHost
    
    # 2.5 Signed VIB Check
    $Results += Test-SignedVIB -ESXiHost $ESXiHost
    
    # 2.6-2.7 Time Synchronization
    $Results += Test-TimeSources -ESXiHost $ESXiHost
    $Results += Test-TimeSync -ESXiHost $ESXiHost
    
    # 2.8 TPM Configuration
    $Results += Test-TPMEncryption -ESXiHost $ESXiHost
    
    # 2.9 Hyperthreading Warning
    $Results += Test-HyperthreadingWarnings -ESXiHost $ESXiHost
    
    # 2.10 Page Sharing
    $Results += Test-PageSharing -ESXiHost $ESXiHost
    
    # 2.11 Entropy Check
    $Results += Test-EntropySource -ESXiHost $ESXiHost
    
    # 2.12 Volatile Key Management
    $Results += Test-VolatileKeyDestruction -ESXiHost $ESXiHost
    
    return $Results
}

function Test-SoftwareSupport {
    param([string]$ESXiHost)
    
    try {
        $ESXiVersion = Get-VMHost -Name $ESXiHost | Select-Object Version
        # Add version validation logic
        return @{
            ID = "2.1"
            Description = "Host must run software that has not reached End of General Support status"
            Status = "Pass"
            Details = "ESXi Version: $($ESXiVersion.Version)"
        }
    } catch {
        return @{
            ID = "2.1"
            Description = "Host must run software that has not reached End of General Support status"
            Status = "Fail"
            Details = "Error checking software version: $_"
        }
    }
}

# Implement remaining test functions following similar pattern