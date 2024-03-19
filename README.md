# MATLAB on Microsoft Azure

This repository shows how to automate the process of running MATLAB&reg; on Microsoft&reg; Azure&reg; using a virtual machine, and connecting to it using the Remote Desktop Protocol (RDP) or SSH. The automation uses an Azure Resource Manager (ARM) template. The template is a JSON file that defines the resources needed to run MATLAB on Azure. For information about the architecture of this solution, see [Learn about Architecture](#learn-about-architecture).

# Requirements
You need:

- A MATLAB&reg; license. For more information, see [License Requirements for MATLAB on Cloud Platforms](https://www.mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html).
- A [MathWorks&reg; account](https://www.mathworks.com/login?uri=%2Fmwaccount%2F).
- An Azure&reg; account.

# Costs

You are responsible for the cost of the Azure services used when you create cloud resources using this guide. Resource settings, such as instance type, affect the cost of deployment. For cost estimates, see the pricing pages for each Azure service you will be using. Prices are subject to change.


# Deployment Steps
By default, the MATLAB reference architectures below launch prebuilt machine images, described in [Learn about Architecture](#learn-about-architecture).
Using a prebuilt machine image is the easiest way to deploy a MATLAB reference architecture.
Alternatively, to build your own machine image with MATLAB using MathWorks build scripts,
see [Build and Deploy Your Own Machine Image](#build-and-deploy-your-own-machine-image).
## Deploy Prebuilt Machine Image

To view instructions for deploying the MATLAB reference architecture, select a MATLAB release:

| Linux | Windows |
| ----- | ------- |
| [R2024a](releases/R2024a/README.md) | [R2024a](https://github.com/mathworks-ref-arch/matlab-on-azure-win/tree/master/releases/R2024a/README.md) |
| [R2023b](releases/R2023b/README.md) | [R2023b](https://github.com/mathworks-ref-arch/matlab-on-azure-win/tree/master/releases/R2023b/README.md) |
| [R2023a](releases/R2023a/README.md) | [R2023a](https://github.com/mathworks-ref-arch/matlab-on-azure-win/tree/master/releases/R2023a/README.md) |
| [R2022b](releases/R2022b/README.md) | [R2022b](https://github.com/mathworks-ref-arch/matlab-on-azure-win/tree/master/releases/R2022b/README.md) |
| [R2022a](releases/R2022a/README.md) | [R2022a](https://github.com/mathworks-ref-arch/matlab-on-azure-win/tree/master/releases/R2022a/README.md) |
| [R2021b](releases/R2021b/README.md) | [R2021b](https://github.com/mathworks-ref-arch/matlab-on-azure-win/tree/master/releases/R2021b/README.md) |
| [R2021a](releases/R2021a/README.md) | [R2021a](https://github.com/mathworks-ref-arch/matlab-on-azure-win/tree/master/releases/R2021a/README.md) |
| [R2020b](releases/R2020b/README.md) | [R2020b](https://github.com/mathworks-ref-arch/matlab-on-azure-win/tree/master/releases/R2020b/README.md) |
| [R2020a](releases/R2020a/README.md) |  |
| [R2019b](releases/R2019b/README.md) |  |
| [R2019a\_and\_older](releases/R2019a_and_older/README.md) |  |


The above instructions allow you to launch instances based on the latest prebuilt MathWorks marketplace images.
MathWorks periodically replaces older machine images with new images.
For more details, see
[When are the MathWorks machine images updated?](#when-are-the-mathworks-machine-images-updated)

## Build and Deploy Your Own Machine Image
For details of the scripts which form the basis of the MathWorks Linux reference architecture build process,
see [Build Your Own Machine Image](./packer/v1).
You can use these scripts to build your own custom Linux machine image for running MATLAB on Azure,
which you can deploy with the MathWorks infrastructure as code (IaC) templates.
To launch the built image, see [Deploy Your Own Machine Image](releases/R2024a/README.md#deploy-your-own-machine-image).

# Learn about Architecture
Deploying this reference architecture will create several resources in your resource group.

![MATLAB on Azure Reference Architecture](img/azure-matlab-diagram.png)

Deploying this reference architecture sets up a single Azure virtual machine containing MATLAB, a network interface with a public IP address to connect to the virtual machine, a network security group that controls network traffic, and a virtual network for communication between resources.

The VM image contains the following:
* MATLAB, Simulink, toolboxes, and support for GPUs.
* Add-ons: Several pretrained deep neural networks for classification, feature extraction, and transfer learning with Deep Learning Toolbox&trade;, including GoogLeNet, ResNet-50, and NASNet-Large.

### Resources

| Resource Name                     | Resource Name in Azure         | Number of Resources | Description                                                                                |
|-----------------------------------|-------------------------       |---------------------|--------------------------------------------------------------------------------------------|
| Virtual Machine                   | `matlab-vm`                    | 1                   | The virtual machine instance with pre-installed desktop MATLAB.                            |
| Network interface                 | `matlab-nic`                   | 1                   | Enables the virtual machine to communicate with internet, Azure, and on-premises resources.|
| Public IP address                 | `matlab-publicIP`              | 1                   | Public IP address to connect to the virtual machine running MATLAB.                        |
| Network security group            | `matlab-rdp-nsg`               | 1                   | Allows or denies traffic to and from sources and destinations.                             |
| Virtual network                   | `matlab-vnet`                  | 1                   | Enables resources to communicate with each other.                                          |
| Disk                              | `matlab-vm-disk-<unique id>`   | 1                   | The disk attached to the VM.                                                               |
| Image                             | `matlab-base-image`            | 1                   | The original image used to create the VM.                                                  |

## FAQ

### When are the MathWorks machine images updated?
The links in [Deployment Steps](#deployment-steps) launch instances based on the latest MathWorks
machine images for at least the four most recent MATLAB releases. MATLAB releases occur twice each year.

For each MATLAB release, MathWorks periodically replaces the corresponding image with a newer image
that includes the latest MATLAB updates and important security updates of the base OS image.

### How do I save my changes in the VM?
All your files and changes are stored locally on the virtual machine. They persist until you either terminate the virtual machine instance or delete the resource group. Stopping the instance does not destroy the data on the instance. If you want your changes to persist before you terminate an instance, you need to:
* copy your files to another location, or
* create an image of the virtual machine.

### What happens to my data if I shut down the instance?
You might want to shut down the instance when you are not using it. Any files or changes you make to the virtual machine will persist when you shut it down and will be present when you restart it.

### How do I customize the image?
To build your own custom machine image using MathWorks build scripts,
see [Build and Deploy Your Own Machine Image](#build-and-deploy-your-own-machine-image).

Alternatively, you can customize an image by launching the reference architecture, applying changes to the virtual machine, and then saving an image of that virtual machine using the Azure Portal.
For more information, see [Create an image of a VM in the portal](https://learn.microsoft.com/en-us/azure/virtual-machines/capture-image-portal) in the Azure documentation.

### How do I use a different license manager?
The VM image uses MathWorks Hosted License Manager by default. For information on using other license managers, see [MATLAB Licensing in the Cloud](https://www.mathworks.com/help/licensingoncloud/matlab-on-the-cloud.html).

### How do I deploy into an existing virtual network?
You need to edit the template and replace the appropriate sections with your own virtual network and subnet resource IDs.

# Technical Support
To request assistance or additional features, contact [MathWorks Technical Support](https://www.mathworks.com/support/contact_us.html).

----

Copyright 2018-2024 The MathWorks, Inc.

----