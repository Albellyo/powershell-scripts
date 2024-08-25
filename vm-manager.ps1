Connect-AzAccount

#Set azure variables

$resourceGroupName = "myResourceGroup"
$location = "East US"
$vmName = "myVM"
$vmSize = "Standard_DS1_v2"
$adminUsername = "azureuser"
$adminPassword = "Password1234!"
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