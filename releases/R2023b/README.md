# MATLAB on Microsoft Azure (Linux VM)

## Prerequisites

To deploy this reference architecture, you must have the following permissions that allow you to create and assign Azure&reg; roles in your subscription:

1. `Microsoft.Authorization/roleDefinitions/write`
2. `Microsoft.Authorization/roleAssignments/write`

To check if you have these permissions for your Azure subscription, follow the steps mentioned in [Check access for a user to Azure resources](https://learn.microsoft.com/en-us/azure/role-based-access-control/check-access).

If you do not have these permissions, you can obtain them in two ways:

1. The built-in Azure role [User Access Administrator](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#user-access-administrator) contains the above-mentioned permissions. Administrators or Owners of the subscription can directly assign you this role in addition to your existing role. To assign roles using the Azure portal, see [Assign Azure roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal).

2. The Azure account administrator or Owner can also create a custom role containing these permissions and attach it along with your existing role. To create custom roles using the Azure portal, see [Create Custom roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles-portal).

To get a list of Owners in your subscription, see [List Owners of a Subscription](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-portal#list-owners-of-a-subscription).

## Step 1. Launch the Template

Click the **Deploy to Azure** button below to deploy the cloud resources on Azure. This will open the Azure Portal in your web browser.

| Create Virtual Network | Use Existing Virtual Network |
| --- | --- |
| Use this option to deploy the resources in a new virtual network<br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure%2Fmaster%2Freleases%2FR2023b%2Fazuredeploy-R2023b.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> | Use this option to deploy the resources in an existing virtual network <br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure%2Fmaster%2Freleases%2FR2023b%2Fazuredeploy-existing-vnet-R2023b.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> |

> VM Platform: Ubuntu 22.04
  
> MATLAB&reg; Release: R2023b

To deploy a custom machine image, see [Deploy Your Own Machine Image](#deploy-your-own-machine-image).

## Step 2. Configure the Cloud Resources

Clicking the **Deploy to Azure** button opens the "Custom deployment" page in your browser. You can configure the parameters on this page. It is easier to complete the steps if you position these instructions and the Azure Portal window side by side. Create a new resource group by clicking **Create New**. Alternatively, you can select an existing resource group, but this can cause conflicts if resources are already deployed in it.

1. Specify and check the defaults for these resource parameters:

| Parameter label | Description |
| --------------- | ----------- |
| **Vm Size** | The Azure instance type to use for the VM. For a list of instance types, see [Sizes for virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes). |
| **Client IP Addresses** | The IP address range that can be used to access the VM. This must be a valid IP CIDR range of the form x.x.x.x/x. Use the value &lt;your_public_ip_address&gt;/32 to restrict access to only your computer. |
| **Admin Username** | Admin username for the VM running MATLAB. To avoid any deployment errors, check the list of [disallowed values](https://docs.microsoft.com/en-us/rest/api/compute/virtual-machines/create-or-update?tabs=HTTP#osprofile) for adminUsername. |
| **Admin Password** | Choose the password for the admin username. This password is required when logging in remotely to the instance. For the deployment to succeed, your password must meet [Azure's password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm-). |
| **Virtual Network Resource ID** | The Resource ID of an existing virtual network to deploy your VM into. You can find this under the Properties of your virtual network. Specify this parameter only when deploying with the Existing Virtual Network option. |
| **Subnet Name** | The name of an existing subnet within your virtual network to deploy your VM into. Specify this parameter only when deploying with the Existing Virtual Network option. |
| **Auto Shutdown** | Select the duration after which the VM should be automatically shut down post launch. |
| **Access Protocol** | Access protocol to connect to this VM. Selecting 'NICE DCV' will enable [NICE DCV](https://aws.amazon.com/hpc/dcv/) using a 30-days demo license (unless a production license is provided). You can access the desktop on a browser using the NICE DCV connection URL in the Outputs section of the deployment page once the resource group is successfully deployed. By using NICE DCV, you agree to the terms and conditions outlined in [NICE DCV End User License Agreement](https://www.nice-dcv.com/eula.html). If you select 'RDP', NICE DCV will not be enabled, and you can connect to this VM using a RDP connection. |
| **NICE DCV License Server** | If you have selected NICE DCV as the remote access protocol and have a production license, use this optional parameter to specify the NICE DCV license server's port and hostname (or IP address) in the form of port@hostname. This field must be left blank if you have opted to use RDP or want to use NICE DCV with a demo license. |
| **MATLAB License Server** | Optional License Manager for MATLAB, specified as a string in the form port@hostname. If you do not provide this string, MATLAB uses online licensing. If you provide this string, ensure that the license manager is accessible from the specified virtual network and subnets. For more information, see [Network License Manager for MATLAB on Microsoft Azure](https://github.com/mathworks-ref-arch/license-manager-for-matlab-on-azure). |
| **Optional User Command** | Provide an optional inline shell command to run on machine launch. For example, to set an environment variable CLOUD=AZURE, use this command excluding the angle brackets: &lt;echo -e "export CLOUD=AZURE" &#124; sudo tee -a /etc/profile.d/setenvvar.sh && source /etc/profile&gt;. To run an external script, use this command excluding the angle brackets: &lt;wget -O /tmp/my-script.sh "https://example.com/script.sh" && bash /tmp/my-script.sh&gt;. Find the logs at '/var/log/mathworks/startup.log'. |


**NOTE**: If you are using network license manager, the port and hostname of the network license manager must be reachable from the MATLAB VMs. It is therefore recommended that you deploy into a subnet within the same virtual network as the network license manager.

2. Click the **Review + create** button.

3. Review the Azure Marketplace terms and conditions and click the **Create** button.

## Step 3. Connect to the Virtual Machine in the Cloud

>   **Note:** Complete these steps only after your resource group has been successfully created.

1. In the Azure Portal, on the navigation panel on the left, click **Resource groups**. This will display all your resource groups.

2. Select the resource group you created for this deployment from the list. This will display the Azure blade of the selected resource group with its own navigation panel on the left.

3. Select the resource labeled **matlab-publicIP**. This resource contains the public IP address to the virtual machine that is running MATLAB.

4. Copy the IP address from the IP address field.

5. If you chose not to enable NICE DCV during deployment, launch any remote desktop client, paste the IP address in the appropriate field, and connect. For example, on the Windows Remote Desktop Client, paste the IP address in the **Computer** field and click **Connect**.

6. If you enabled NICE DCV during deployment, you can access the virtual machine's desktop via the url `https://<public-ip-of-vm>:8443`. Note: While using NICE DCV, the desktop cannot be accessed using remote desktop clients other than the [NICE DCV client](https://download.nice-dcv.com/).

7. In the login screen, use the username and password you specified while configuring cloud resources in [Step 2](#step-2-configure-cloud-resources).

## Step 4. Start MATLAB

Double-click the MATLAB icon on the virtual machine desktop to start MATLAB. The first time you start MATLAB, you need to enter your MathWorks&reg; Account credentials to license MATLAB. For other ways to license MATLAB, see [MATLAB Licensing in the Cloud](https://www.mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html). 

>**Note**: It may take up to a minute for MATLAB to start the first time.

# Deploy Your Own Machine Image
For details of the scripts which form the basis of the MathWorks Linux VHD build process,
see [Build Your Own Machine Image](https://github.com/mathworks-ref-arch/matlab-on-azure/blob/master/packer/v1/README.md).
You can use these scripts to build your own custom Linux machine image for running MATLAB on Azure.
You can then deploy this custom image with the following MathWorks infrastructure as code (IaC) templates.
| Create Virtual Network for Custom Image | Use Existing Virtual Network for Custom Image|
| --- | --- |
| Use this option to deploy the custom image and other resources in a new virtual network<br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure%2Fmaster%2Freleases%2FR2023b%2Fazuredeploy-R2023b-test.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> | Use this option to deploy the custom image and other resources in an existing virtual network <br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure%2Fmaster%2Freleases%2FR2023b%2Fazuredeploy-existing-vnet-R2023b-test.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> |

To launch a custom image, the following fields are required by these templates.
| Argument Name | Description |
|---|---|
|`Custom VHD`                 | URL of custom VHD. This is the `artifact_id` listed in the `manifest.json`. |
|`Custom VHD Storage Account` | Storage account that contains the custom VHD. This is the storage account that was specified in the Packer build using the `STORAGE_ACCOUNT` parameter. |
|`Custom VHD Resource Group`  | Resource group that contains the custom VHD. This is the resource group that was specified in the Packer build using the `RESOURCE_GROUP_NAME` parameter. |

# Additional Information

## Switching remote protocols to access the MATLAB virtual machine

If you wish to switch from NICE DCV to xRDP, run the following command using [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/what-is-azure-cli) or [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview):
```
az vm run-command invoke --command-id RunShellScript --resource-group <RESOURCE_GROUP_NAME> --name <VM_NAME> --script "/usr/local/bin/swap-desktop-solution.sh rdp" 
```
To switch from xRDP to NICE DCV, run:
```
az vm run-command invoke --command-id RunShellScript --resource-group <RESOURCE_GROUP_NAME> --name <VM_NAME> --script "/usr/local/bin/swap-desktop-solution.sh dcv" 
```
Here, `<RESOURCE_GROUP_NAME>` denotes the name of the resource group created in [Step 2](#step-2-configure-cloud-resources) and `<VM_NAME>` is the name of the VM running MATLAB (for example - `matlab-vm`).

## Configuring production license for NICE DCV after deployment

If you want to configure the NICE DCV server running on the `matlab-vm` to use a production license, follow these instructions:

1. If you have a production license file, copy it to the `matlab-vm` under the path `/usr/share/dcv/license`. 

2. Navigate to `/etc/dcv/`, and open the `dcv.conf` with a text editor.

3. Locate the `license-file` parameter in the `[license]` section, and enter the full path to the license file copied in step 1. 

4. If you have an RLM (Reprise License Manager) server instead of a license file, modify the value of the `license-file` parameter to point to the port and hostname of the server in the format `port@hostname`.

5. Once you modify the `dcv.conf` file, restart the NICE DCV server and apply the changes using: `sudo systemctl restart dcvserver`.

For more information about licensing NICE DCV, see [Installing a production license](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-production.html).

## Delete Your Resource Group
You can remove the Resource Group and all associated resources when you are done with them. Note that you cannot recover resources once they are deleted.

1.  Login to the Azure Portal.
2.  Select the resource group containing your resources.
3.  Select the **Delete resource group** icon to destroy all resources deployed
    in this group.
4.  You will be prompted to enter the name of the resource group to confirm the
    deletion.

## Troubleshooting
If your resource group fails to deploy, check the Deployments section of the Resource Group. It will indicate which resource deployments failed and allow you to navigate to the causing error message.

----

Copyright 2018-2024 The MathWorks, Inc.

----