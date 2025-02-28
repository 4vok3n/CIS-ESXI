function Invoke-ManagementAudit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ESXiHost,
        
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Config
    )
    
    $Results = @()
    
    # 3.1-3.6 Service Status Checks
    $Results += Test-SSHStatus -ESXiHost $ESXiHost
    $Results += Test-ESXiShellStatus -ESXiHost $ESXiHost
    $Results += Test-MOBStatus -ESXiHost $ESXiHost
    $Results += Test-SLPStatus -ESXiHost $ESXiHost
    $Results += Test-CIMStatus -ESXiHost $ESXiHost
    $Results += Test-SNMPStatus -ESXiHost $ESXiHost
    
    # 3.7-3.10 Session Management
    $Results += Test-DCUITimeout -ESXiHost $ESXiHost
    $Results += Test-ShellTimeout -ESXiHost $ESXiHost
    $Results += Test-ShellAutoDeactivate -ESXiHost $ESXiHost
    $Results += Test-ShellWarnings -ESXiHost $ESXiHost
    
    # 3.11-3.15 Password Policy
    $Results += Test-PasswordComplexity -ESXiHost $ESXiHost
    $Results += Test-AccountLockout -ESXiHost $ESXiHost
    $Results += Test-AccountUnlock -ESXiHost $ESXiHost
    $Results += Test-PasswordHistory -ESXiHost $ESXiHost
    $Results += Test-PasswordAge -ESXiHost $ESXiHost
    
    # 3.16-3.17 Session Timeouts
    $Results += Test-APITimeout -ESXiHost $ESXiHost
    $Results += Test-ClientSessionTimeout -ESXiHost $ESXiHost
    
    # 3.18-3.21 Access Control
    $Results += Test-DCUIAccess -ESXiHost $ESXiHost
    $Results += Test-ExceptionUsers -ESXiHost $ESXiHost
    $Results += Test-NormalLockdown -ESXiHost $ESXiHost
    $Results += Test-StrictLockdown -ESXiHost $ESXiHost
    
    # 3.22-3.23 Shell Access
    $Results += Test-DCUIShellAccess -ESXiHost $ESXiHost
    $Results += Test-VPXUserShellAccess -ESXiHost $ESXiHost
    
    # 3.24-3.26 Login Banners and TLS
    $Results += Test-DCUIBanner -ESXiHost $ESXiHost
    $Results += Test-SSHBanner -ESXiHost $ESXiHost
    $Results += Test-TLSVersion -ESXiHost $ESXiHost
    
    return $Results
}

function Test-SSHStatus {
    param([string]$ESXiHost)
    
    try {
        $SSHService = Get-VMHostService -VMHost $ESXiHost | Where-Object { $_.Key -eq "TSM-SSH" }
        return @{
            ID = "3.1"
            Description = "Host should deactivate SSH"
            Status = if ($SSHService.Running) { "Fail" } else { "Pass" }
            Details = "SSH Service is $($SSHService.Running ? 'running' : 'stopped')"
        }
    } catch {
        return @{
            ID = "3.1"
            Description = "Host should deactivate SSH"
            Status = "Error"
            Details = "Error checking SSH status: $_"
        }
    }
}

# Implement remaining test functions following similar pattern