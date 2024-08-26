Azure PowerShell Scripts
This repository contains a collection of PowerShell scripts used for various Azure projects that I’ve worked on. These scripts are designed to automate tasks, provision resources, manage virtual machines, and streamline Azure administration and configuration.

Projects and Use Cases
1. VM Provisioning
This script provisions a new Virtual Machine (VM) in Azure, including setting up the necessary network components such as virtual networks, subnets, and public IP addresses.

Script: Create-AzVM.ps1
Features:
Automated creation of Azure VMs.
Configurable VM size, location, and OS.
Automatic resource group, VNet, and storage creation.
2. Azure SQL Database Deployment
This script uses Terraform to deploy an Azure SQL Database instance and demonstrates a basic CRUD web application for data storage.

Script: Deploy-AzureSQLDatabase.ps1
Features:
Automates SQL Database setup.
Integration with a simple CRUD app.
3. FSLogix Profile Management
This script automates the deployment and configuration of FSLogix profiles, ensuring seamless user profile management across multiple virtual machines.

Script: Deploy-FSLogixProfiles.ps1
Features:
Streamlines FSLogix profile deployment.
Configurable settings for profile storage locations.
4. Azure Backup and Restore
Automates the backup and restoration of Azure VMs to ensure data integrity and disaster recovery.

Script: Backup-RestoreAzureVM.ps1
Features:
Automates backup scheduling.
One-click VM restoration to previous states.
5. Cost Optimization
This script helps analyze and optimize Azure costs by identifying underutilized resources and recommending scaling or decommissioning actions.

Script: Optimize-AzureCosts.ps1
Features:
Resource analysis for cost reduction.
Automated scaling recommendations.
Prerequisites
PowerShell 7.x or above.
Azure PowerShell module (Az) installed. You can install it using:
powershell
Copy code
Install-Module -Name Az -AllowClobber -Force
Proper permissions and access to your Azure account. You can connect to your Azure account using:
powershell
Copy code
Connect-AzAccount
Usage
Clone the repository:

bash
Copy code
git clone https://github.com/yourusername/azure-powershell-scripts.git
cd azure-powershell-scripts
Ensure that you have proper credentials and permissions for Azure services.

Run the desired script. For example:

powershell
Copy code
.\Create-AzVM.ps1
Follow any on-screen prompts for input or configuration as required.

Contributions
Feel free to fork the repository and submit pull requests with enhancements or new scripts.

License
This project is licensed under the MIT License. See the LICENSE file for details.

