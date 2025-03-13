# MATLAB on Microsoft Azure

## Step 1. Launch the Template

Click the **Deploy to Azure** button below to deploy the cloud resources on Azure. This will open the Azure Portal in your web browser.

| Create Virtual Network | Use Existing Virtual Network |
| --- | --- |
| Use this option to deploy the resources in a new virtual network<br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure%2Fmaster%2Freleases%2FR2020a%2Fazuredeploy-R2020a.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a></br></br> | Use this option to deploy the resources in an existing virtual network <br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure%2Fmaster%2Freleases%2FR2020a%2Fazuredeploy-existing-vnet-R2020a.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a></br></br> |

> VM Platform: Ubuntu 18.04

> MATLAB Release: R2020a

## Step 2. Configure the Cloud Resources
Clicking the Deploy to Azure button opens the "Custom deployment" page in your browser. You can configure the parameters on this page. It is easier to complete the steps if you position these instructions and the Azure Portal window side by side.

1. Specify and check the defaults for these resource parameters:

| Parameter label | Description |
| --------------- | ----------- |
| **Vm Size** | The Azure instance type to use for the VM. See https://docs.microsoft.com/en-us/azure/virtual-machines/sizes for a list of instance types. |
| **Client IP Addresses** | The IP address range that can be used to access the VM. This must be a valid IP CIDR range of the form x.x.x.x/x. Use the value <your_public_ip_address>/32 to restrict access to only your computer. |
| **Admin Username** | Choose the admin username for the instance. This username is required when logging into the instance using remote desktop protocol. |
| **Admin Password** | Choose the admin password for the instance. This password is required when logging into the instance using remote desktop protocol. For the deployment to succeed, your password must meet Azure's password requirements. See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm- for information on the password requirements. |
| **Virtual Network Resource ID** | The Resource ID of an existing virtual network to deploy your VM into. You can find this under the Properties of your virtual network. Specify this parameter only when deploying with the Existing Virtual Network option. |
| **Subnet Name** | The name of an existing subnet within your virtual network to deploy your VM into. Specify this parameter only when deploying with the Existing Virtual Network option. |
| **License Server** | Optional License Manager for MATLAB string in the form port@hostname. If not specified, online licensing is used. If specified, the license manager must be accessible from the specified virtual network and subnets. |


2. Tick the box to accept the Azure Marketplace terms and conditions.

3. Click the **Purchase** button.

## Step 3. Connect to the Virtual Machine in the Cloud

>   **Note:** Complete these steps only after your resource group has been successfully created.

1.  In the Azure Portal, on the navigation panel on the left, click **Resource
    groups**. This will display all your resource groups.

2.  Select the resource group you created for this deployment from the list. This
    will display the Azure blade of the selected resource group with its own
    navigation panel on the left.

3.  Select the resource labeled **matlab-public-ip**. This resource
    contains the public IP address to the virtual machine that is running MATLAB.

4.  Copy the IP address from the IP address field.

5.  Launch any remote desktop client, paste the IP address in the appropriate field, and connect. On the Windows Remote Desktop Client you need to paste the IP address in the **Computer** field and click **Connect**.

6. In the login screen that's displayed, use the username and password you specified while configuring cloud resources in [Step 2](#step-2-configure-cloud-resources).

## Step 4. Launch MATLAB

Double-click the MATLAB icon on the instance desktop to launch MATLAB. The first time you start MATLAB, you should see a login dialog in the terminal. Enter a valid MathWorks account email address and password. Choose one of the listed licenses associated with your account (you only need to do this the first time you start MATLAB). For more information, see [MATLAB Licensing in the Cloud](https://www.mathworks.com/help/licensingoncloud/matlab-on-the-cloud.html).

>**Note**: It may take a few minutes for activation to complete and MATLAB to start. You will experience this delay only the first time you start MATLAB.

# Deploy Your Own Machine Image

> [!IMPORTANT]
> To deploy images built with the latest Public Packer scripts, use the ARM template corresponding to the most recent MATLAB release. The latest ARM templates are designed to work with managed images generated by the Public Packer scripts. Azure will retire unmanaged disks (VHDs) on September 30, 2025. For details, see [Unmanaged Disks Deprecation (Azure)](https://learn.microsoft.com/en-us/azure/virtual-machines/unmanaged-disks-deprecation).

For details of the scripts which form the basis of the MathWorks Linux managed image build process,
see [Build Your Own Machine Image](https://github.com/mathworks-ref-arch/matlab-on-azure/blob/master/packer/v1/README.md).
You can use these scripts to build your own custom Linux machine image for running MATLAB on Azure.
You can then deploy this custom image with the above MathWorks infrastructure as code (IaC) templates.

To launch a custom image, the following fields are required by the templates.
| Argument Name | Description |
|---|---|
|`Image ID` | Resource ID of the custom managed image. This is the `artifact_id` listed in the `manifest.json`. |

# Additional Information

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
