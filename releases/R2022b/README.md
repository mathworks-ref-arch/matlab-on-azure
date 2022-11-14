# MATLAB on Microsoft Azure (Linux VM)

## Prerequisites

To deploy this reference architecture, you must have the following permissions that allow you to create and assign Azure roles in your subscription:

1. `Microsoft.Authorization/roleDefinitions/write`
2. `Microsoft.Authorization/roleAssignments/write`

To check if you have these permissions for your Azure subscription, please follow the steps mentioned in [Check access for a user to Azure resources](https://learn.microsoft.com/en-us/azure/role-based-access-control/check-access).

If you do not have these permissions, you can obtain them in one of the two ways:

1. The built-in Azure role [User Access Administrator](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#user-access-administrator) contains the above-mentioned permissions. Administrators or Owners of the subscription can directly assign you this role in addition to your existing role. To assign roles using the Azure portal, see [Assign Azure roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal).

2. The Azure account administrator or Owner can also create a custom role containing these permissions and attach it along with your existing role. To create custom roles using the Azure portal, see [Create Custom roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles-portal).

To get a list of Owners in your subscription, see [List Owners of a Subscription](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-portal#list-owners-of-a-subscription).

## Step 1. Launch the Template

Click the **Deploy to Azure** button below to deploy the cloud resources on Azure. This will open the Azure Portal in your web browser.

| Create Virtual Network | Use Existing Virtual Network |
| --- | --- |
| Use this option to deploy the resources in a new virtual network<br><br><a href="{{ARTIFACTS_BASE_RAW}}azuredeploy-{{CURRENT_RELEASE}}.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> | Use this option to deploy the resources in an existing virtual network <br><br><a href="{{ARTIFACTS_BASE_RAW}}azuredeploy-existing-vnet-{{CURRENT_RELEASE}}.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> |

> VM Platform: Ubuntu 20.04
  
> MATLAB Release: {{ CURRENT_RELEASE }}

## Step 2. Configure the Cloud Resources

Clicking the Deploy to Azure button opens the "Custom deployment" page in your browser. You can configure the parameters on this page. It is easier to complete the steps if you position these instructions and the Azure Portal window side by side.

1. Specify and check the defaults for these resource parameters:

| Parameter label | Description |
| --------------- | ----------- |
{% for parameter in parameters -%}
| **{{ parameter.label }}** | {{ parameter.description }} |
{% endfor %}

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

## Step 4. Launch MATLAB

Double-click the MATLAB icon on the instance desktop to launch MATLAB. The first time you start MATLAB you will get a login dialog. Enter a valid MathWorks Account email address and password and click **Sign In**. If you have the correct license rights, MATLAB starts. For more information, see [Confirm Licensing for MathWorks Products Running on the Cloud](https://mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html).

>**Note**: It may take a few minutes for activation to complete and MATLAB to start. You will experience this delay only the first time you start MATLAB.

# Additional Information

## Switching remote protocols to access the MATLAB virtual machine

>   **Note:** These directions are valid only if you choose to enable NICE DCV in the virtual machine.

If you wish to switch from NICE DCV to xRDP, run the following command using [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/what-is-azure-cli) or [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview):
```
az vm run-command invoke --command-id RunShellScript --resource-group <RESOURCE_GROUP_NAME> --name <VM_NAME> --script "/usr/local/bin/swap-desktop-solution.sh rdp" 
```
To switch from xRDP to NICE DCV, run:
```
az vm run-command invoke --command-id RunShellScript --resource-group <RESOURCE_GROUP_NAME> --name <VM_NAME> --script "/usr/local/bin/swap-desktop-solution.sh dcv" 
```
Here, `<RESOURCE_GROUP_NAME>` denotes the name of the resource group created in [Step 2](#step-2-configure-cloud-resources) and `<VM_NAME>` is the name of the VM running MATLAB (for example - `matlab-vm`).
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