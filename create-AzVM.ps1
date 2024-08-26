# Define variables
$ResourceGroupName = "myResourceGroup"
$Location = "EastUS"
$VMName = "myVM"
$VMSize = "Standard_DS1_v2"
$VNetName = "myVNet"
$SubnetName = "mySubnet"
$PublicIPName = "myPublicIP"
$NICName = "myNIC"
$OSDiskName = "myOSDisk"
$AdminUsername = "azureuser"
$AdminPassword = ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force
$ImagePublisher = "Canonical"
$ImageOffer = "UbuntuServer"
$ImageSku = "18.04-LTS"

# Authenticate to Azure
Connect-AzAccount

# Create a Resource Group
$resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Create a Virtual Network
$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $VNetName `
    -AddressPrefix "10.0.0.0/16"

# Create a Subnet
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -AddressPrefix "10.0.1.0/24" `
    -VirtualNetwork $vnet

# Commit the Subnet to the VNet
$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet

# Create a Public IP Address
$publicIP = New-AzPublicIpAddress `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $PublicIPName `
    -AllocationMethod Dynamic

# Create a Network Security Group (Optional, can be customized for specific rules)
$nsg = New-AzNetworkSecurityGroup `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name "myNSG"

# Create a NIC with the associated NSG, VNet, Subnet, and Public IP
$nic = New-AzNetworkInterface `
    -Name $NICName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SubnetId $vnet.Subnets[0].Id `
    -NetworkSecurityGroupId $nsg.Id `
    -PublicIpAddressId $publicIP.Id

# Create the VM configuration
$vmConfig = New-AzVMConfig `
    -VMName $VMName `
    -VMSize $VMSize

# Set the VM OS and Admin credentials
$vmConfig = Set-AzVMOperatingSystem `
    -VM $vmConfig `
    -Linux `
    -ComputerName $VMName `
    -Credential (New-Object PSCredential ($AdminUsername, $AdminPassword))

# Set the VM Image
$vmConfig = Set-AzVMSourceImage `
    -VM $vmConfig `
    -PublisherName $ImagePublisher `
    -Offer $ImageOffer `
    -Skus $ImageSku `
    -Version "latest"

# Attach the NIC to the VM
$vmConfig = Add-AzVMNetworkInterface `
    -VM $vmConfig `
    -Id $nic.Id

# Create the OS Disk
$osDisk = New-AzDiskConfig `
    -AccountType Standard_LRS `
    -CreateOption FromImage

# Create the VM
$vm = New-AzVM `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -VM $vmConfig `
    -OSDiskName $OSDiskName
