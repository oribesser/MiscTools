function Test-Ping
{
    <#
    .SYNOPSIS
    Parallel quick ping (1 ping, 1 second timeout) to array of destinations.

    .NOTES
    Ori Besser
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$TargetName
    )

    $TargetName | ForEach-Object -Parallel {
        Test-Connection $_ -Count 1 -TimeoutSeconds 1 -ErrorAction SilentlyContinue -ErrorVariable e
        if ($e)
        {
            [PSCustomObject]@{ Destination = $_; Status = $e.Exception.Message }
        }
    } | Group-Object Destination | Select-Object Name, @{n = 'Status'; e = { $_.Group.Status } }
}