
# Use PowerShell bitwise operations to determine the first and last IPs in a subnet based on IP address and subnet mask
function GetNetworkAddress
{
    param
    (
        [Parameter(Mandatory)]
        $IPAddress,
        [Parameter(Mandatory)]
        $SubnetMask
    )

    $ipAddressBytes = ([IPAddress]$IPAddress).GetAddressBytes()
    $subnetMaskBytes = ([IPAddress]$SubnetMask).GetAddressBytes()

    $networkBytes = @()
    for ($i = 0; $i -lt $ipAddressBytes.Count; $i++)
    {
        $networkBytes += $ipAddressBytes[$i] -band $subnetMaskBytes[$i]
    }

    $networkAddress = [IPAddress]::new($networkBytes)
    $networkAddress.IPAddressToString
}

function GetBroadcastAddress
{
    param
    (
        [Parameter(Mandatory)]
        $IPAddress,
        [Parameter(Mandatory)]
        $SubnetMask
    )

    $ipAddressBytes = ([IPAddress]$IPAddress).GetAddressBytes()
    $subnetMaskBytes = ([IPAddress]$SubnetMask).GetAddressBytes()

    $broadcastBytes = @()
    for ($i = 0; $i -lt $ipAddressBytes.Count; $i++)
    {
        $broadcastBytes += $ipAddressBytes[$i] -bor ($subnetMaskBytes[$i] -bxor 255)
    }

    $networkAddress = [IPAddress]::new($broadcastBytes)
    $networkAddress.IPAddressToString
}

# Examples
GetNetworkAddress '10.114.32.64' '255.255.255.192'
GetBroadcastAddress '10.114.32.64' '255.255.255.192'
