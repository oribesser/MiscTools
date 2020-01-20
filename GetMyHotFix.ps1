function Get-MyHotFix
{
    <#
    .SYNOPSIS
    Get updates both from QuickFixEngineering and ReliabilityRecords.

    .DESCRIPTION
    Get-Hotfix (Win32_QuickFixEngineering) does not return all updates. This function combines both outputs.

    .NOTES
    Ori Besser
    #>

    [CmdletBinding()]
    param
    (
        [string[]]$ComputerName
    )

    if ($ComputerName)
    {
        $rr = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_ReliabilityRecords -Property ComputerName, TimeGenerated, Message, ProductName -Filter "SourceName = 'Microsoft-Windows-WindowsUpdateClient'"
        $qfe = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_QuickFixEngineering -Property CSName, InstalledOn, HotFixID, Description
    }
    else
    {
        # Ommiting Computername to skip WinRM
        $rr = Get-CimInstance -ClassName Win32_ReliabilityRecords -Property ComputerName, TimeGenerated, Message, ProductName -Filter "SourceName = 'Microsoft-Windows-WindowsUpdateClient'"
        $qfe = Get-CimInstance -ClassName Win32_QuickFixEngineering -Property CSName, InstalledOn, HotFixID, Description
    }

    $out = $rr | ForEach-Object {
        [PSCustomObject]@{
            ComputerName = $_.ComputerName
            Time         = $_.TimeGenerated
            Result       = if ($_.Message -match '[^:]*') { $Matches[0] };
            KB           = if ($_.ProductName -match 'KB\d+') { $Matches[0] };
            ProductName  = $_.ProductName.Replace(" ($($Matches[0]))", '').Replace(" - $($Matches[0])", '')
        }
    }

    $out += $qfe | ForEach-Object {
        if ($_.HotFixID -notin $out.KB)
        {
            [PSCustomObject]@{
                ComputerName = $_.CSName
                Time         = $_.InstalledOn
                Result       = 'Installation Successful'
                KB           = $_.HotFixID
                ProductName  = $_.Description
            }
        }
    }

    $out | Sort-Object Time -Descending
}
