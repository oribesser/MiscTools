function Close-OpenWindows
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [string]$Name = '\w'
    )

    function KillExplorerWindows
    {
        $e = (New-Object -ComObject Shell.Application).Windows() | Where-Object { $_.FullName -ne $null } | Where-Object { $_.FullName.ToLower().Endswith('\explorer.exe') }
        $e | ForEach-Object { $_.Quit() }
    }

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    if ( ([Security.Principal.WindowsPrincipal] $currentUser).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) )
    {
        $includeUsers = $true
    }
    else
    {
        $includeUsers = $false
        $currentUser = $null
    }

    if ($PSBoundParameters.Name -eq 'explorer')
    {
        if ($PSCmdlet.ShouldProcess('All Explorer windows', 'Kill'))
        {
            KillExplorerWindows
        }
    }
    else
    {
        (Get-Process -IncludeUserName:$includeUsers).Where{ ($_.Id -ne $PID) -and ($_.UserName -eq $currentUser.Name) } | Where-Object { $_.MainWindowTitle -match $Name } | Stop-Process -ErrorAction SilentlyContinue
        if (! $PSBoundParameters.Name)
        {
            if ($PSCmdlet.ShouldProcess('All Explorer windows', 'Kill'))
            {
                KillExplorerWindows
            }
        }
    }
}
