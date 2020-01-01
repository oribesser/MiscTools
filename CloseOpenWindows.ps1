function Close-OpenWindows
{
    <#
    .SYNOPSIS
    Close all open windows or a specific one.

    .PARAMETER Name
    A regex pattern of a window title to close. If multiple matches returned - multiple windows will be closed.

    .EXAMPLE
    Close-OpenWindows -Name explorer
    Only close file explorer windows

    .EXAMPLE
    Close-OpenWindows
    Close all open windows, including file explorer windows
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [string]$Name = '\w'
    )

    function KillExplorerWindows
    {
        # Explorer windows have no title and can be closed only with the Shell COM object.
        $e = (New-Object -ComObject Shell.Application).Windows() | Where-Object { $_.FullName -ne $null } | Where-Object { $_.FullName.ToLower().Endswith('\explorer.exe') }
        $e | ForEach-Object { $_.Quit() }
    }

    # Detect if elevated in order to close only the windows of the running user. If not elevated, only the current user's windows will close anyway
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

    # For killing only explorer windows
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
        # Check if the Name parameter was explicitly used, if it wasn't - all windows should be closed - so close also explorer windows.
        if (! $PSBoundParameters.Name)
        {
            if ($PSCmdlet.ShouldProcess('All Explorer windows', 'Kill'))
            {
                KillExplorerWindows
            }
        }
    }
}
