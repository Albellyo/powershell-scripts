#define the parameters for the deployment

$resourceGroupName = "myResourceGrouptest"
$location = "West US"
$serverName = "myservertest0000111"
$adminUsername = "myadmin"
$adminPassword = "myP@ssw0rd"
$databaseName = "mySampleDatabase-test"
$firewallRuleName = "AllowYourIp"
$startIpAddress = "0.0.0.0"
$endIpAddress = "0.0.0.0"
$edition = "Standard"
$computerGeneration = "Gen5"

#login to azure

Connect-AzAccount


#Create new resource group
new-AzResourceGroup -Name $resourceGroupName -Location $location

#Create a new SQL server

New-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUsername, $(ConvertTo-SecureString -String $adminPassword -AsPlainText -Force))


#Create a firewall rule for the SQL server

New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -FirewallRuleName $firewallRuleName `
    -StartIpAddress $startIpAddress `
    -EndIpAddress $endIpAddress

#Create a new SQL database in the server
New-AzSqlDatabase -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName "S0"
    -Edition $edition `
    -ComputeGeneration $computerGeneration

#Output connection String
$connectionString = "Server=tcp:$serverName.database.windows.net,1433;Initial Catalog=$databaseName;Persist Security Info=False;User ID=$adminUsername;Password=$adminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
Write-Output "Connection String $connectionString"

#Connect to the Azure database
#Install-Module -Name sqlServer -AllowClobber -Force

Invoke-Sqlcmd -ServerInstance "$serverName.database.windows.net" `
    -Database $databaseName ` 
    -Username $adminUsername ` 
    -Password $adminPassword `
    -Query "SELECT GETDATE() AS TimeOfQuery"
