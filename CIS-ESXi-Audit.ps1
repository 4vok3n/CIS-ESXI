<#
.SYNOPSIS
    VMware ESXi CIS Compliance Audit Script
.DESCRIPTION
    Performs a comprehensive CIS compliance audit on VMware ESXi hosts
.NOTES
    Version: 1.0
    Author: GitHub Copilot
    Last Updated: 2025-02-28
#>

# Script Parameters
param(
    [Parameter(Mandatory=$true)]
    [string[]]$ESXiHosts,
    
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credentials,
    
    [string]$ConfigPath = ".\config",
    [string]$OutputPath = ".\reports",
    [switch]$ExportToCSV,
    [switch]$ExportToHTML,
    [switch]$DetailedLog
)

# Import required modules
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModulesPath = Join-Path $ScriptPath "Modules"

# Import custom modules
. (Join-Path $ModulesPath "Hardware-Checks.ps1")
. (Join-Path $ModulesPath "Base-Checks.ps1")
. (Join-Path $ModulesPath "Management-Checks.ps1")
. (Join-Path $ModulesPath "Logging-Checks.ps1")
. (Join-Path $ModulesPath "Network-Checks.ps1")
. (Join-Path $ModulesPath "Features-Checks.ps1")
. (Join-Path $ModulesPath "VM-Checks.ps1")
. (Join-Path $ModulesPath "VMTools-Checks.ps1")
. (Join-Path $ModulesPath "Common-Functions.ps1")

# Import configuration
$Config = Get-Content (Join-Path $ConfigPath "config.json") | ConvertFrom-Json

# Initialize results collection
$AuditResults = @()

# Connect to vCenter/ESXi
try {
    Connect-VIServer -Server $ESXiHosts -Credential $Credentials
} catch {
    Write-Error "Failed to connect to ESXi hosts: $_"
    exit 1
}

foreach ($ESXiHost in $ESXiHosts) {
    Write-Host "Auditing host: $ESXiHost" -ForegroundColor Green
    
    # Run all audit modules
    $Results = @{
        "Hostname" = $ESXiHost
        "Timestamp" = Get-Date
        "Hardware" = Invoke-HardwareAudit -ESXiHost $ESXiHost -Config $Config
        "Base" = Invoke-BaseAudit -ESXiHost $ESXiHost -Config $Config
        "Management" = Invoke-ManagementAudit -ESXiHost $ESXiHost -Config $Config
        "Logging" = Invoke-LoggingAudit -ESXiHost $ESXiHost -Config $Config
        "Network" = Invoke-NetworkAudit -ESXiHost $ESXiHost -Config $Config
        "Features" = Invoke-FeaturesAudit -ESXiHost $ESXiHost -Config $Config
        "VirtualMachine" = Invoke-VMAudit -ESXiHost $ESXiHost -Config $Config
        "VMwareTools" = Invoke-VMToolsAudit -ESXiHost $ESXiHost -Config $Config
    }
    
    $AuditResults += $Results
}

# Generate reports
if ($ExportToCSV) {
    Export-AuditResultsToCSV -Results $AuditResults -Path $OutputPath
}

if ($ExportToHTML) {
    Export-AuditResultsToHTML -Results $AuditResults -Path $OutputPath
}

# Disconnect from vCenter/ESXi
Disconnect-VIServer -Server $ESXiHosts -Confirm:$false