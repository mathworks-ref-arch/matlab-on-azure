# MATLAB on Microsoft Azure

# Requirements
Before starting, you will need the following:

- A MATLAB® license. For more information, see [Configure MATLAB Licensing on the Cloud](http://www.mathworks.com/support/cloud/configure-matlab-licensing-on-the-cloud.html).
- A [MathWorks Account](https://www.mathworks.com/login?uri=%2Fmwaccount%2F).
- A Microsoft Azure account.

# Costs

You are responsible for the cost of the Azure services used when you create cloud resources using this guide. Resource settings, such as instance type, will affect the cost of deployment. For cost estimates, see the pricing pages for each Azure service you will be using. Prices are subject to change.

# Introduction
The following guide will help you automate the process of running the MATLAB desktop on Microsoft Azure and connect to it using the Remote Desktop Protocol (RDP). The automation is accomplished using an Azure Resource Manager (ARM) template. The template is a JSON
file that defines the resources needed to run MATLAB on Azure. For information about the architecture of this solution, see [Architecture and Resources](#architecture-and-resources).

# Deployment Steps

## Step 1. Launch the Template
Click the **Deploy to Azure** button to deploy MATLAB on
    Azure. This will open the Azure Portal in your web browser.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure%2Fmaster%2Ftemplates%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

> VM Platform: Ubuntu 16.04

> MATLAB Release: R2018a


## Step 2. Configure Cloud Resources
Provide values for parameters in the custom deployment template on the Azure Portal :

| Parameter Name          | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Subscription**            | Choose an Azure subscription to use for purchasing resources.<p><em>Example:</em> Massachusetts</p>                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| **Resource group**          | Choose a name for the resource group that will hold the resources. It is recommended you create a new resource group for each deployment. This allows all resources in a group to be deleted simultaneously. <p><em>Example:</em> Boston311</p>                                                                                                                                                                                                                                                                       |
| **Location**                | Choose the region to start resources in. Ensure that you select a location which supports your requested instance types. To check which services are supported in each location, see [Azure Region Services](<https://azure.microsoft.com/en-gb/regions/services/>). We recommend you use East US or East US 2. <p><em>Example:</em> East US</p>                                                                                                                                                                                                                          |
| **VM Size**                 | Specify the size of the VM you plan on using for deployment. Use [MATLAB system requirements](https://www.mathworks.com/support/sysreq.html) as a guide in choosing the appropriate VM size. The template defaults to: *Standard_D3_v2*. This configuration has 4 vCPUs and 14 GiB of Memory. For more information, see Azure [documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general). <p><em>Example:</em> Standard_D3_v2</p> |
| **Client IP Addresses**     | This is the IP address range that will be allowed to connect to this instance using the Remote Desktop Protocol. The format for this field is IP Address/Mask. <p><em>Example</em>: </p>10.0.0.1/32 <ul><li>This is the public IP address which can be found by searching for "what is my ip address" on the web. The mask determines the number of IP addresses to include.</li><li>A mask of 32 is a single IP address.</li><li>Use a [CIDR calculator](https://www.ipaddressguide.com/cidr) if you need a range of more than one IP addresses.</li><li>You may need to contact your IT administrator to determine which address is appropriate.</li></ul></p> |
| **User Name**               | Enter a username you would like to use to connect to the virtual machine in the cloud using remote desktop.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **User Password**           | Enter a password you would like to use to connect to the virtual machine in the cloud using remote desktop.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

<br />

Agree to the Azure Marketplace terms and conditions and click **Purchase** to begin the deployment. Creating a resource group on Azure can take at least 10 minutes.

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

Double-click the MATLAB icon on the instance desktop to launch MATLAB. The first time you start MATLAB you will get a login dialog. Enter a valid MathWorks Account email address and password and click **Sign In**. If you have the correct license rights, MATLAB starts. For more information, see [Configure MATLAB Licensing on the Cloud](http://www.mathworks.com/support/cloud/configure-matlab-licensing-on-the-cloud.html).

>**Note**:It may take a few minutes for activation to complete and MATLAB to start. You will experience this delay only the first time you start MATLAB.


# Additional Information

## Delete Your Resource Group
You can remove the resource group and all associated cluster resources when you
are done with them. Note that there is no undo.

1.  Login to the Azure Portal.
2.  Select the resource group containing your cluster resources.
3.  Select the **Delete resource group** icon to destroy all resources deployed
    in this group.
4.  You will be prompted to enter the name of the resource group to confirm the
    deletion.


## Architecture and Resources
Deploying this reference architecture will create several resources in your
resource group.

![MATLAB on AWS Reference Architecture](images/azure-matlab-diagram.png)

Deploying this reference architecture sets up a single Azure virtual machine running Linux and MATLAB, a network interface with a public IP address to connect to the virtual machine, a network security group that controls network traffic, and a virtual network for communication between resources. 

A preconfigured Ubuntu 16.04 VM is provided to make deployment easy. The VM image contains the following software:
* MATLAB, Simulink, Toolboxes, and support for GPUs.<p>To see a list of installed products, type `ver` at the MATLAB command prompt.</p> 
* Add-Ons: Neural Network Toolbox Model for AlexNet Network, Neural Network Toolbox Model for GoogLeNet Network, and Neural Network Toolbox(TM) Model for ResNet-50 Network

### Resources

| Resource Name                     | Resource Name in Azure  | Number of Resources | Description                                                                                |
|-----------------------------------|-------------------------|---------------------|--------------------------------------------------------------------------------------------|
| Virtual Machine                 | `matlab-vm`            | 1                   | The virtual machine instance with pre-installed desktop MATLAB.|
| Network interface                 | `matlab-nic`            | 1                   | Enables the virtual machine to communicate with internet, Azure, and on-premises resources.|
| Public IP address                 | `matlab-publicIP`       | 1                   | Public IP address to connect to the virtual machine running MATLAB.                        |
| Network security group            | `matlab-rdp-nsg`        | 1                   | Allows or denies traffic to and from sources and destinations.                             |
| Virtual network                   | `matlab-vnet`           | 1                   | Enables resources to communicate with each other.                                          |
| Disk                 | `matlab-vm-disk-<unique id>`            | 1                   | The disk attached to the VM.|
| Image                 | `matlab-base-image`            | 1                   | The original image used to create the VM.|



## FAQ

### How do I save my changes in the VM?
All your files and changes are stored locally on the virtual machine.  They will persist until you either terminate the virtual machine instance or delete the resource group.  Stopping the instance does not destroy the data on the instance.  If you want your changes to persist before you terminate an instance you’ll need to:
* copy your files to another location, or  
* create an image of the virtual machine.

### What happens to my data if I shutdown the instance?
You may want to shutdown the instance when you aren’t using it.  Any files or changes made to the virtual machine will persist when shutting down and will be there when you restart. 

### How do I save an image?
You can save a copy of your current virtual machine.  Locate the Azure VM in your resource group in the Azure Portal, click “Capture Image” and follow the instructions. 

### How do I customize the image?
You can customize an image by launching the reference architecture, applying any changes you want to the virtual machine such as installing additional software, drivers and files and then saving an image of that virtual machine using the Azure Portal. For more information, see [How do I save an image?](#how-do-i-save-an-image). When you launch the reference architecture, click “Edit Template”, replace the `baseImageUri` in the “variables” section with the URL from your custom image. Save and finish the deployment steps by filling out parameters, accepting the terms and clicking “Purchase”.

### How do I use a different license manager?
The VM image uses MathWorks Hosted License Manager by default.  For information on using other license managers, see [Configure MATLAB Licensing on the Cloud](http://www.mathworks.com/support/cloud/configure-matlab-licensing-on-the-cloud.html). 

### How do I deploy into an existing virtual network?
You will need to edit the template and replace the appropriate sections with your own virtual network and subnet resource ids.

# Enhancement Request
Provide suggestions for additional features or capabilities using the following link: https://www.mathworks.com/cloud/enhancement-request.html

# Technical Support
Email: `cloud-support@mathworks.com`


