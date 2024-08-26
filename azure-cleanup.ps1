Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

#login to Azure
Connect-AzAccount -UseDeviceAuthentication

#Define the subscription to target
$subscriptionId = "yourSubscriptionId"
Select-AzSubscription -SubscriptionId $subscriptionId

#get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

#interate through each resource group

foreach ($rg in $resourceGroups){
    Write-Host "Checking resource group: $($rg.ResourceGroupName)"

    #identify unused VMs (deallocated)
    $vms = Get-AzVM -ResourceGroupName $rg.ResourceGroupName
    foreach ($vm in $vms){
        if ($vm.PowerState -eq "VM deallocated"){
            #check and confirm by typing "YES" to delete the VM
            $response = Read-Host "Delete VM: $($vm.Name)? (YES/NO)"
            if ($response -eq "YES"){
                Write-Host "Deleting VM: $($vm.Name)"
                Remove-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Force
            }
    }
}
    #identify unattached disks
    $disks = Get-AzDisk -ResourceGroupName $rg.ResourceGroupName
    foreach ($disk in $disks){
        if ($disk.ManagedBy -eq $null){
            #check and confirm by typing "YES" to delete the disk
            $response = Read-Host "Delete Disk: $($disk.Name)? (YES/NO)"
            if ($response -eq "YES"){
                Write-Host "Deleting Disk: $($disk.Name)"
                Remove-AzDisk -ResourceGroupName $rg.ResourceGroupName -Name $disk.Name -Force
            }
        }
    }

    #identify unused public IPS (deallocated)
    $publicIps = Get-AzPublicIpAddress -ResourceGroupName $rg.ResourceGroupName
    foreach ($publicIp in $publicIps){
        if ($publicIp.IpConfiguration -eq $null){
            #check and confirm by typing "YES" to delete the public IP
            $response = Read-Host "Delete Public IP: $($publicIp.Name)? (YES/NO)"
            if ($response -eq "YES"){
                Write-Host "Deleting Public IP: $($publicIp.Name)"
                Remove-AzPublicIpAddress -ResourceGroupName $rg.ResourceGroupName -Name $publicIp.Name -Force
            }
        }
    }

    #identify unused network interfaces (deallocated)
    $nics = Get-AzNetworkInterface -ResourceGroupName $rg.ResourceGroupName
    foreach ($nic in nics){
        if ($nics.VirtualMachine -eq $null){
            #check and confirm by typing "YES" to delete the network interface
            $response = Read-Host "Delete Network Interface: $($nic.Name)? (YES/NO)"
            if ($response -eq "YES"){
                Write-Host "Deleting Network Interface: $($nic.Name)"
                Remove-AzNetworkInterface -ResourceGroupName $rg.ResourceGroupName -Name $nic.Name -Force
            }
        }
    }

    Write-Host "Resource group: $($rg.ResourceGroupName) has been cleaned up."

}

Write-Host "All resource groups have been cleaned up."