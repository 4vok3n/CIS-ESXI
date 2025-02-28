function Export-AuditResultsToCSV {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Results,
        [string]$Path
    )
    
    $FlatResults = @()
    foreach ($HostResult in $Results) {
        foreach ($Category in @("Hardware", "Base", "Management", "Logging", "Network", "Features", "VirtualMachine", "VMwareTools")) {
            foreach ($Check in $HostResult.$Category) {
                $FlatResults += [PSCustomObject]@{
                    Hostname = $HostResult.Hostname
                    Timestamp = $HostResult.Timestamp
                    Category = $Category
                    CheckID = $Check.ID
                    Description = $Check.Description
                    Status = $Check.Status
                    Details = $Check.Details
                }
            }
        }
    }
    
    $FlatResults | Export-Csv -Path (Join-Path $Path "CIS_Audit_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv") -NoTypeInformation
}

function Export-AuditResultsToHTML {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Results,
        [string]$Path
    )
    
    $HTML = @"
<!DOCTYPE html>
<html>
<head>
    <title>ESXi CIS Audit Results</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background-color: #f2f2f2; }
        .Pass { color: green; }
        .Fail { color: red; }
        .Warning { color: orange; }
    </style>
</head>
<body>
"@
    
    foreach ($HostResult in $Results) {
        $HTML += "<h2>Host: $($HostResult.Hostname)</h2>"
        $HTML += "<p>Audit Date: $($HostResult.Timestamp)</p>"
        
        foreach ($Category in @("Hardware", "Base", "Management", "Logging", "Network", "Features", "VirtualMachine", "VMwareTools")) {
            $HTML += "<h3>$Category Checks</h3>"
            $HTML += "<table>"
            $HTML += "<tr><th>ID</th><th>Description</th><th>Status</th><th>Details</th></tr>"
            
            foreach ($Check in $HostResult.$Category) {
                $HTML += "<tr>"
                $HTML += "<td>$($Check.ID)</td>"
                $HTML += "<td>$($Check.Description)</td>"
                $HTML += "<td class='$($Check.Status)'>$($Check.Status)</td>"
                $HTML += "<td>$($Check.Details)</td>"
                $HTML += "</tr>"
            }
            
            $HTML += "</table>"
        }
    }
    
    $HTML += "</body></html>"
    $HTML | Out-File (Join-Path $Path "CIS_Audit_$(Get-Date -Format 'yyyyMMdd_HHmmss').html")
}