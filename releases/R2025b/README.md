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

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure%2Fmaster%2Freleases%2FR2025b%2Fazuredeploy-R2025b.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a>

> VM Platform: Ubuntu 24.04
  
> MATLAB&reg; Release: R2025b

To deploy a custom machine image, see [Deploy Your Own Machine Image](#deploy-your-own-machine-image).

## Step 2. Configure the Cloud Resources

Clicking the **Deploy to Azure** button opens the "Custom deployment" page in your browser. You can configure the parameters on this page. It is easier to complete the steps if you position these instructions and the Azure Portal window side by side. Create a new resource group by clicking **Create New**. Alternatively, you can select an existing resource group, but this can cause conflicts if resources are already deployed in it.

1. Specify and check the defaults for these resource parameters:

| Parameter label | Description |
| --------------- | ----------- |
| **Vm Size** | The Azure instance type to use for the VM. For a list of instance types, see [Sizes for virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes). |
| **Create Public IP Address** | Choose whether to attach a public IP address to the MATLAB VM. For details about using a private network configuration, see [Configure Private Network](#configure-private-network). |
| **Client IP Addresses** | Comma-separated list of IPv4 address ranges that will be allowed to connect to the MATLAB VM. Each IP CIDR must have the format \<ip_address>/\<mask>. The mask determines the number of IP addresses to include. A mask of 32 specifies a single IP address. Examples of allowed values: 10.0.0.1/32 or 10.0.0.0/16,192.34.56.78/32. To build a specific range, you can use this tool: https://www.ipaddressguide.com/cidr. To determine which address is appropriate, contact your IT administrator. |
| **Admin Username** | Admin username for the VM running MATLAB. To avoid any deployment errors, check the list of [disallowed values](https://docs.microsoft.com/en-us/rest/api/compute/virtual-machines/create-or-update?tabs=HTTP#osprofile) for adminUsername. |
| **Admin Password** | Choose the password for the admin username. You need this password to log in remotely to the instance.  If you enabled the setting to access MATLAB in a browser, you need to enter this password as an authentication token. Your password must meet the [Azure password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm-). |
| **Virtual Network Resource ID** | (Optional) The Resource ID of an existing virtual network to deploy your VM into. You can find this under the Properties of your virtual network. If left empty, a new virtual network with a default subnet will be created. |
| **Subnet Name** | (Optional) The name of an existing subnet within your chosen virtual network to deploy your VM into. Required if a Virtual Network Resource ID is specified. |
| **New Vnet Address Space** | (Optional) Address space to use for the new Virtual Network that the template creates, effective only if not using an existing virtual network. |
| **New Subnet Address Space** | (Optional) Address space of the default subnet in the new Virtual Network that the template creates, effective only if not using an existing virtual network. This address range must be a subset of the address space defined for the new Virtual Network. |
| **Auto Shutdown** | Select the duration after which the VM should be automatically shut down post launch. |
| **Access Protocol** | Access protocol to connect to this VM. Selecting 'NICE DCV' will enable [NICE DCV](https://aws.amazon.com/hpc/dcv/) using a 30-days demo license (unless a production license is provided). You can access the desktop on a browser using the NICE DCV connection URL in the Outputs section of the deployment page once the resource group is successfully deployed. By using NICE DCV, you agree to the terms and conditions outlined in [NICE DCV End User License Agreement](https://www.nice-dcv.com/eula.html). If you select 'RDP', NICE DCV will not be enabled, and you can connect to this VM using a RDP connection. |
| **Enable MATLAB Proxy** | Use this setting to access MATLAB in a browser on your cloud instance. Note that the MATLAB session in your browser is different from one you start from the desktop in your Remote Desktop Protocol (RDP) or NICE DCV session. |
| **MATLAB License Server** | Optional License Manager Server for MATLAB, specified as a string in the form \<port>@\<license-manager-hostname> or \<port>@\<license-manager-ip-address> (for example: 27000@netlm-server or 27000@10.0.0.4). Ensure that the MATLAB VM can reach or resolve the license manager's IP or hostname. If you do not provide this string, MATLAB uses online licensing. For more information, see [Network License Manager for MATLAB on Microsoft Azure](https://github.com/mathworks-ref-arch/license-manager-for-matlab-on-azure). |
| **NICE DCV License Server** | If you have selected NICE DCV as the remote access protocol and have a production license, use this optional parameter to specify the NICE DCV license server's port and hostname (or IP address) in the form of port@hostname. This field must be left blank if you have opted to use RDP or want to use NICE DCV with a demo license. |
| **Optional User Command** | Provide an optional inline shell command to run on machine launch. For example, to set an environment variable CLOUD=AZURE, use this command excluding the angle brackets: &lt;echo -e "export CLOUD=AZURE" &#124; sudo tee -a /etc/profile.d/setenvvar.sh && source /etc/profile&gt;. To run an external script, use this command excluding the angle brackets: &lt;wget -O /tmp/my-script.sh "https://example.com/script.sh" && bash /tmp/my-script.sh&gt;. Find the logs at '/var/log/mathworks/startup.log'. |
| **Image ID** | Optional Resource ID of a custom managed image in the target region. To use a prebuilt MathWorks image instead, leave this field empty. If you customize the build, for example by removing or modifying the included scripts, this can make the image incompatible with the provided ARM template. To ensure compatibility, modify the ARM template or image accordingly. |


**NOTE**: If you use network license manager, the port and hostname (or IP address) of the network license manager must be accessible from MATLAB VMs. MathWorks recommends that you deploy into a subnet within the same virtual network as the network license manager or in a peered network. If your network license manager is hosted on a peer network, MathWorks recommends you use the private IPv4 address of the network license manager instead of the hostname, to avoid name resolution issues. For more information about peered networks, see [Peered Networking (Azure)](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview).

2. Click the **Review + create** button.

3. Review the Azure Marketplace terms and conditions and click the **Create** button.

## Step 3. Connect to the Virtual Machine in the Cloud

>   **Note:** Complete these steps only after your resource group has been successfully created.

1. In the Azure Portal, on the navigation panel on the left, click **Resource groups**. This will display all your resource groups.

2. Select the resource group you created for this deployment from the list. This will display the Azure blade of the selected resource group with its own navigation panel on the left.

3. If you chose to create a Public IP address during deployment, select the resource labeled **matlab-publicIP**. This resource contains the public IP address of the MATLAB virtual machine. Otherwise, you must use the private IP address of the MATLAB virtual machine to connect to it.

4. Copy the IP address from the IP address field.

5. If you chose not to enable NICE DCV during deployment, launch any remote desktop client, paste the IP address in the appropriate field, and connect. For example, on the Windows Remote Desktop Client, paste the IP address in the **Computer** field and click **Connect**.

6. If you enabled NICE DCV during deployment, you can access the virtual machine desktop on a using the URL `https://<public-ip-of-vm>:8443`, or for a private VM, the URL `https://<private-ip-of-vm>:8443` on a [supported web browser](https://www.ni-sp.com/knowledge-base/dcv-general/clients/#h-supported-browsers). You can also access the desktop using the [NICE DCV Client](https://download.nice-dcv.com/). In the login screen, use the username and password you specified while configuring cloud resources in [Step 2](#step-2-configure-cloud-resources).

7. If you enabled the setting to access MATLAB in your browser, you can access the desktop on your virtual machine using the URL `https://<public-ip-of-vm>:8123`, or for a private VM, the URL `https://<private-ip-of-vm>:8123`. For the `auth token`, use the password you specified during deployment. 

Access to MATLAB in a browser is enabled through `matlab-proxy`, a Python&reg; package developed by  MathWorks&reg;. For details, see [MATLAB Proxy (Github)](https://github.com/mathworks/matlab-proxy).

## Step 4. Start MATLAB

To start MATLAB, double click the MATLAB icon on the desktop in your virtual machine. The first time you start MATLAB, you need to enter your MathWorks Account credentials. For more information about licensing MATLAB, see [MATLAB Licensing in the Cloud](https://www.mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html). 

>**Note**: It may take up to a minute for MATLAB to start the first time.

# Deploy Your Own Machine Image
For details of the scripts which form the basis of the MathWorks Linux managed image build process,
see [Build Your Own Machine Image](https://github.com/mathworks-ref-arch/matlab-on-azure/blob/master/packer/v1/README.md).
You can use these scripts to build your own custom Linux machine image for running MATLAB on Azure.
You can then deploy this custom image with the above MathWorks infrastructure as code (IaC) templates.

To launch a custom image, the following fields are required by the templates.
| Argument Name | Description |
|---|---|
|`Image ID` | Resource ID of the custom managed image. This is the `artifact_id` listed in the `manifest.json`. |

# Additional Information

## Configure Private Network

To set up a private networking configuration for the MATLAB VM, set the `createPublicIPAddress` parameter to `No` to avoid attaching a Public IPv4 address. Review the following configuration requirements.

### Configure Inbound Connectivity to VM
Without a public IP address, you will be unable to access the MATLAB VM directly from the internet. You must use RDP/SSH/NICE DCV using a method such as one of these:

- **[Azure Bastion (Azure)](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)**: Provides secure RDP/SSH access directly through the Azure portal via web browsers. Before using, see [Azure Bastion Pricing (Azure)](https://azure.microsoft.com/en-us/pricing/details/azure-bastion/).
- **[Jumpbox Virtual Machines (Azure)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/connect-to-environments-privately#overview-of-azure-bastion-host-and-jumpboxes)**: A separate VM with a public IP address acts as an intermediate layer between your machine and the MATLAB VM. The jumpbox VM must be deployed in the same virtual network as the MATLAB VM or in a peered network. Once deployed, you can log in to the jumpbox using its public IP address and connect to the MATLAB VM using its private IP address.
- **[VPN Gateway or ExpressRoute](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction)**: Establishes a private, secure tunnel between your local on-premises network and your Azure Virtual Network. If your on-premises network is already connected to the Azure Virtual Network hosting the MATLAB VM, you can directly connect to it using its private IP address.

You can use the `clientIPAddresses` parameter to specify the private IPv4 addresses of the existing jumpbox or client(s) that will access the MATLAB VM. Example: `10.0.0.1/32` or `172.31.0.0/16,192.168.0.0/24`.

### Licensing MATLAB
To use online licensing for MATLAB, the MATLAB virtual machine must be able to access domains at `*.mathworks.com` over the internet. Ensure that your virtual network is configured to allow outbound access from the MATLAB VM to these domains.

### Outbound Internet Access
New virtual networks created with this template have the [`defaultOutboundAccess` (Azure)](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access) property for default subnets set to `true`. This allows private VMs in the subnet to access the internet.

To use a private subnet for the MATLAB VM, use an existing virtual network with private subnets or configure the newly created subnet to be a [Private Subnet (Azure)](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access#how-to-configure-private-subnets).


## Switch Remote Protocols To Access MATLAB VM

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

Copyright 2018-2025 The MathWorks, Inc.

----