Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Install Az module if not already installed
if (-not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -AllowClobber -Force
}


# Connect to Azure and capture the output
$output = Connect-AzAccount -UseDeviceAuthentication -ErrorAction Stop
$deviceCode = ($output | Select-String -Pattern 'code\s+\w+' | ForEach-Object { ($_ -split ' ')[1] }).Trim()
# Display only the code
$deviceCode


#Set azure variables

$resourceGroupName = "myResourceGroup"
$location = "East US"
$vmName = "myVM"
$vmSize = "Standard_DS1_v2"
$adminUsername = "azureuser"
$adminPassword = ConvertTo-SecureString "Password1234!" -AsPlainText -Force
$imagePublisher = "MicrosoftWindowsServer"
$imageOffer = "WindowsServer"
$imageSku = "2019-Datacenter"


#Create a new resource group if it does not exist.
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
    Write-Host "Creating a new resource group... $resourceGroupName"
}

#function to create a new VM
function Create-VM {

    Write-Host "Creating a new VM... $vmName"

    # Create the virtual network
    $vnet = New-AzVirtualNetwork -Name "${vmName}Vnet" -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix "10.0.0.0/16" -Subnet @(New-AzVirtualNetworkSubnetConfig -Name 'default' -AddressPrefix "10.0.0.0/24")

    if ($null -eq $vnet) {
        Write-Host "Failed to create Virtual Network."
        return
    }
    
    Write-Host "Virtual Network created successfully."

    # Create Network Interface
    $nic = New-AzNetworkInterface -Name "${vmName}Nic" -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId (New-AzPublicIpAddress -Name "${vmName}Ip" -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static).Id

    if ($null -eq $nic) {
        Write-Host "Failed to create Network Interface."
        return
    }

    Write-Host "Network Interface created successfully."

#Define the VM config

    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize |
        Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object PSCredential($adminUsername, $adminPassword)) |
        Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version latest |
        Add-AzVMNetworkInterface -Id (New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name "${vmName}Nic" -Location $location -SubnetId (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (New-AzVirtualNetwork -Name "${vmName}Vnet" -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix "10.0.0.0/16" | Add-AzVirtualNetworkSubnetConfig -Name 'default' -AddressPrefix "10.0.0.0/24" | Set-AzVirtualNetwork).Subnets[0].Id) -PublicIpAddressId (New-AzPublicIpAddress -Name "${vmName}Ip" -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Dynamic).Id).Id

        #Create the VM
        New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
        Write-Host "Virtual Machine $vmName has been created."

}

#Function to start the VM
function Start-VM {
    Write-Host "Starting the VM... $vmName"
    Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
    Write-Host "Virtual Machine $vmName has been started."
}

#function to stop the VM
function Stop-VM {
    Write-Host "Stopping the VM... $vmName"
    Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
}

#function to deallocate the VM
function Deallocate {
    Write-Host "Deallocating the VM... $vmName"
    Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
    Write-Host "Virtual Machine $vmName has been deallocated."
}

#menu for operations
function Main-Menu {
    $option = $null
    while ($option -ne 5) {
        Write-Host "1. Create a new VM"
        Write-Host "2. Start the VM"
        Write-Host "3. Stop the VM"
        Write-Host "4. Deallocate the VM"
        Write-Host "5. Exit"
        $option = Read-Host "Select an option"
        switch ($option) {
            1 { Create-VM }
            2 { Start-VM }
            3 { Stop-VM }
            4 { Deallocate }
            5 { break }
            default { Write-Host "Invalid option. Please try again." }
        }
    }
}

#run the main menu
Main-Menu