function Invoke-FeaturesAudit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ESXiHost,
        
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Config
    )
    
    $Results = @()
    
    # 6.1 CIM Service
    $Results += Test-CIMAccess -ESXiHost $ESXiHost
    
    # 6.2 Storage Communications
    $Results += Test-StorageIsolation -ESXiHost $ESXiHost
    $Results += Test-DatastoreNames -ESXiHost $ESXiHost
    
    # 6.3 iSCSI Configuration
    $Results += Test-ISCSIAuthentication -ESXiHost $ESXiHost
    $Results += Test-ISCSISecrets -ESXiHost $ESXiHost
    
    # 6.4 SNMP Configuration
    $Results += Test-SNMPAccess -ESXiHost $ESXiHost
    
    # 6.5 SSH Configuration
    $Results += Test-SSHCiphers -ESXiHost $ESXiHost
    $Results += Test-SSHModules -ESXiHost $ESX