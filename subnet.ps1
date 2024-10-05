# Author: Sean Coggeshall
# About: 
# This program takes an IP Address and Subnet Mask and converts each to its binary
# representation, gets the network address, the broadcast address, and the wildcard mask.

function DecimalToBinary($octet) {
    # Convert a decimal octet to an 8-bit binary string
    $binaryRepresentation = ""
    $powersOfTwo = @(128, 64, 32, 16, 8, 4, 2, 1)
    
    foreach ($power in $powersOfTwo) {
        if ($octet -ge $power) {
            $binaryRepresentation += '1'
            $octet -= $power
        } else {
            $binaryRepresentation += '0'
        }
    }
    return $binaryRepresentation
}

function IpToBinary($ipAddress) {
    # Convert an IP address to its binary representation
    $octets = $ipAddress -split '\.'
    $binaryIp = @()
    
    foreach ($octet in $octets) {
        $binaryIp += DecimalToBinary([int]$octet)
    }

    return ($binaryIp -join ".")
}

function SubnetToBinary($subnetMask) {
    # Convert a subnet mask to its binary representation
    $octets = $subnetMask -split '\.'
    $binarySubnet = @()
    
    foreach ($octet in $octets) {
        $binarySubnet += DecimalToBinary([int]$octet)
    }

    return ($binarySubnet -join ".")
}

function Calculate-NetworkAndBroadcast($ipAddress, $subnetMask) {
    # Calculate the network and broadcast addresses from IP and subnet mask
    $ipOctets = $ipAddress -split '\.' | ForEach-Object { [int]$_ }
    $subnetOctets = $subnetMask -split '\.' | ForEach-Object { [int]$_ }
    
    # Calculate network address using bitwise AND
    $networkAddress = @()
    for ($i = 0; $i -lt 4; $i++) {
        $networkAddress += ($ipOctets[$i] -band $subnetOctets[$i])
    }
    
    # Calculate broadcast address using bitwise OR with inverted subnet mask
    $invertedSubnet = @()
    for ($i = 0; $i -lt 4; $i++) {
        $invertedSubnet += (255 - $subnetOctets[$i])
    }

    $broadcastAddress = @()
    for ($i = 0; $i -lt 4; $i++) {
        $broadcastAddress += ($ipOctets[$i] -bor $invertedSubnet[$i])
    }
    
    # Join the octets to form the final addresses
    return @($networkAddress -join ".", $broadcastAddress -join ".")
}

function Calculate-WildcardMask($subnetMask) {
    # Calculate the wildcard mask from the subnet mask
    $subnetOctets = $subnetMask -split '\.' | ForEach-Object { [int]$_ }
    $wildcardMask = @()
    foreach ($subnet in $subnetOctets) {
        $wildcardMask += (255 - $subnet)
    }
    return ($wildcardMask -join ".")
}

function IsValidIP($ip) {
    # Check if the IP address is valid
    $octets = $ip -split '\.'
    if ($octets.Count -ne 4) { return $false }
    foreach ($octet in $octets) {
        if (-not (0 -le [int]$octet -and [int]$octet -le 255)) {
            return $false
        }
    }
    return $true
}

function IsValidSubnet($subnet) {
    # Check if the subnet mask is valid
    $octets = $subnet -split '\.'
    if ($octets.Count -ne 4) { return $false }
    foreach ($octet in $octets) {
        if (-not (0 -le [int]$octet -and [int]$octet -le 255)) {
            return $false
        }
    }
    return $true
}

# User Input for IP address and Subnet mask
do {
    $ipAddress = Read-Host "Enter your IP Address"
} until (IsValidIP $ipAddress)

do {
    $subnetMask = Read-Host "Enter your Subnet Mask"
} until (IsValidSubnet $subnetMask)

# Convert IP address and Subnet mask to binary
$binaryIp = IpToBinary $ipAddress
$binarySubnet = SubnetToBinary $subnetMask

# Calculate Network and Broadcast Addresses
$addresses = Calculate-NetworkAndBroadcast $ipAddress $subnetMask
$networkAddress = $addresses[0]
$broadcastAddress = $addresses[1]

# Calculate Wildcard Mask
$wildcardMask = Calculate-WildcardMask $subnetMask

# Display results
Write-Host "`nBinary representation of IP Address ${ipAddress}: ${binary_ip}"
Write-Host "Binary representation of Subnet Mask ${subnetMask}: ${binary_subnet}"

Write-Host "Network Address: $networkAddress"
Write-Host "Broadcast Address: $broadcastAddress"
Write-Host "Wildcard Mask: $wildcardMask"

# Display Network and Broadcast in Binary
Write-Host "Binary Network Address: $(IpToBinary $networkAddress)"
Write-Host "Binary Broadcast Address: $(IpToBinary $broadcastAddress)"
Write-Host "Binary Wildcard Mask: $(SubnetToBinary $wildcardMask)"
