# Copyright 2023-2025 The MathWorks, Inc.

packer {
  required_plugins {
    azure = {
      source = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

# The following variables may have different values across MATLAB releases.
# MathWorks recommends that you modify them via the configuration file specific to each release.
# To see the release-specific values, open the configuration file
# in the /packer/v1/release-config/ folder.

variable "PRODUCTS" {
  type        = string
  default     = "5G_Toolbox AUTOSAR_Blockset Aerospace_Blockset Aerospace_Toolbox Antenna_Toolbox Audio_Toolbox Automated_Driving_Toolbox Bioinformatics_Toolbox Bluetooth_Toolbox C2000_Microcontroller_Blockset Communications_Toolbox Computer_Vision_Toolbox Control_System_Toolbox Curve_Fitting_Toolbox DDS_Blockset DSP_HDL_Toolbox DSP_System_Toolbox Database_Toolbox Datafeed_Toolbox Deep_Learning_HDL_Toolbox Deep_Learning_Toolbox Econometrics_Toolbox Embedded_Coder Filter_Design_HDL_Coder Financial_Instruments_Toolbox Financial_Toolbox Fixed-Point_Designer Fuzzy_Logic_Toolbox GPU_Coder Global_Optimization_Toolbox HDL_Coder HDL_Verifier Image_Acquisition_Toolbox Image_Processing_Toolbox Industrial_Communication_Toolbox Instrument_Control_Toolbox LTE_Toolbox Lidar_Toolbox MATLAB MATLAB_Coder MATLAB_Compiler MATLAB_Compiler_SDK MATLAB_Production_Server MATLAB_Report_Generator MATLAB_Test MATLAB_Web_App_Server Mapping_Toolbox Medical_Imaging_Toolbox Mixed-Signal_Blockset Model_Predictive_Control_Toolbox Motor_Control_Blockset Navigation_Toolbox Optimization_Toolbox Parallel_Computing_Toolbox Partial_Differential_Equation_Toolbox Phased_Array_System_Toolbox Powertrain_Blockset Predictive_Maintenance_Toolbox RF_Blockset RF_PCB_Toolbox RF_Toolbox ROS_Toolbox Radar_Toolbox Reinforcement_Learning_Toolbox Requirements_Toolbox Risk_Management_Toolbox Robotics_System_Toolbox Robust_Control_Toolbox Satellite_Communications_Toolbox Sensor_Fusion_and_Tracking_Toolbox SerDes_Toolbox Signal_Integrity_Toolbox Signal_Processing_Toolbox SimBiology SimEvents Simscape Simscape_Battery Simscape_Driveline Simscape_Electrical Simscape_Fluids Simscape_Multibody Simulink Simulink_3D_Animation Simulink_Check Simulink_Coder Simulink_Compiler Simulink_Control_Design Simulink_Coverage Simulink_Design_Optimization Simulink_Design_Verifier Simulink_Desktop_Real-Time Simulink_Fault_Analyzer Simulink_PLC_Coder Simulink_Real-Time Simulink_Report_Generator Simulink_Test SoC_Blockset Stateflow Statistics_and_Machine_Learning_Toolbox Symbolic_Math_Toolbox System_Composer System_Identification_Toolbox Text_Analytics_Toolbox UAV_Toolbox Vehicle_Dynamics_Blockset Vehicle_Network_Toolbox Vision_HDL_Toolbox WLAN_Toolbox Wavelet_Toolbox Wireless_HDL_Toolbox Wireless_Testbench"
  description = "Target products to install in the machine image, e.g. MATLAB Simulink."
}

variable "SPKGS" {
  type        = string
  default     = "Deep_Learning_Toolbox_Model_for_AlexNet_Network Deep_Learning_Toolbox_Model_for_EfficientNet-b0_Network Deep_Learning_Toolbox_Model_for_GoogLeNet_Network Deep_Learning_Toolbox_Model_for_ResNet-101_Network Deep_Learning_Toolbox_Model_for_ResNet-18_Network Deep_Learning_Toolbox_Model_for_ResNet-50_Network Deep_Learning_Toolbox_Model_for_Inception-ResNet-v2_Network Deep_Learning_Toolbox_Model_for_Inception-v3_Network Deep_Learning_Toolbox_Model_for_DenseNet-201_Network Deep_Learning_Toolbox_Model_for_Xception_Network Deep_Learning_Toolbox_Model_for_MobileNet-v2_Network Deep_Learning_Toolbox_Model_for_Places365-GoogLeNet_Network Deep_Learning_Toolbox_Model_for_NASNet-Large_Network Deep_Learning_Toolbox_Model_for_NASNet-Mobile_Network Deep_Learning_Toolbox_Model_for_ShuffleNet_Network Deep_Learning_Toolbox_Model_for_DarkNet-19_Network Deep_Learning_Toolbox_Model_for_DarkNet-53_Network Deep_Learning_Toolbox_Model_for_VGG-16_Network Deep_Learning_Toolbox_Model_for_VGG-19_Network"
  description = "Target support packages to install in the machine image, e.g. Deep_Learning_Toolbox_Model_for_AlexNet_Network."
}

variable "RELEASE" {
  type        = string
  default     = "R2024b"
  description = "Target MATLAB release to install in the machine image, must start with \"R\"."

  validation {
    condition     = can(regex("^R20[0-9][0-9](a|b)(U[0-9])?$", var.RELEASE))
    error_message = "The RELEASE value must be a valid MATLAB release, starting with \"R\"."
  }
}

variable "BUILD_SCRIPTS" {
  type        = list(string)
  default     = ["install-startup-scripts.sh", "install-swap-desktop-solution.sh", "install-dependencies.sh", "install-matlab-proxy.sh", "install-matlab-dependencies-ubuntu.sh", "install-ubuntu-desktop.sh", "setup-mate.sh", "install-matlab.sh", "install-support-packages.sh", "setup-startup-accelerator.sh", "install-fabric-manager-ubuntu.sh"]
  description = "The list of installation scripts Packer will use when building the image."
}

variable "STARTUP_SCRIPTS" {
  type        = list(string)
  default     = [".env", "10_setup-machine.sh", "20_install-nicedcv.sh", "30_setup-rdp.sh", "40_setup-nicedcv.sh", "50_setup-matlab-proxy.sh", "60_setup-matlab.sh", "80_warmup-matlab.sh", "85_warmup-mathworks-service-host.sh", "90_run-optional-user-command.sh"]
  description = "The list of startup scripts Packer will copy to the remote machine image build, which can be used during the deployment creation."
}

variable "RUNTIME_SCRIPTS" {
  type        = list(string)
  default     = ["swap-desktop-solution.sh", "launch-matlab-proxy.sh"]
  description = "The list of runtime scripts Packer will copy to the remote machine image builder, which can be used after the ARM template Stack creation."
}

variable "DCV_INSTALLER_URL" {
  type        = string
  default     = "https://d1uj6qtbmh3dt5.cloudfront.net/2023.0/Servers/nice-dcv-2023.0-15065-ubuntu2204-x86_64.tgz"
  description = "The URL to install NICE DCV, a remote display protocol to use."
}

variable "MATLAB_PROXY_VERSION" {
  type        = string
  default     = ""
  description = "The version of matlab-proxy to install. Installs the latest version by default."
}

variable "NVIDIA_DRIVER_VERSION" {
  type        = string
  default     = "535"
  description = "The version of target NVIDIA Driver to install."
}

variable "NVIDIA_CUDA_TOOLKIT" {
  type        = string
  default     = "https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run"
  description = "The URL to install NVIDIA CUDA Toolkit into the target machine image."
}

variable "NVIDIA_CUDA_KEYRING_URL" {
  type        = string
  default     = "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb"
  description = "NVIDIA CUDA keyring url."
}

variable "MATLAB_SOURCE_LOCATION" {
  type        = string
  default     = ""
  description = "Optional variable to specify the location from which to download a MATLAB and toolbox source file, for use with the mpm --source option."
}

variable "SPKG_SOURCE_LOCATION" {
  type        = string
  default     = ""
  description = "Optional URL from which to download a support packages source file, for use with the mpm --source option."
}

variable "CLIENT_ID" {
  type        = string
  description = "The Microsoft Entra ID service principal associated with your builder."
  sensitive   = true
}

variable "CLIENT_SECRET" {
  type        = string
  description = "The password or secret for your service principal."
  sensitive   = true
}

variable "RESOURCE_GROUP_NAME" {
  type        = string
  default     = ""
  description = "Resource group under which the final artifact will be stored"
}

variable "SUBSCRIPTION_ID" {
  type        = string
  description = "Subscription under which the build will be performed."
  sensitive   = true
}

variable "TENANT_ID" {
  type        = string
  description = "The Microsoft Entra ID tenant identifier with which your client_id and subscription_id are associated."
  sensitive   = true
}

variable "AZURE_TAGS" {
  type = map(string)
  default = {
    Name  = "Packer Build"
    Build = "MATLAB"
    Type  = "matlab-on-azure"
  }
  description = "The tags Packer applies to every deployed resource."
}

variable "MANIFEST_OUTPUT_FILE" {
  type        = string
  default     = "manifest.json"
  description = "The name of the resultant manifest file."
}

variable "IMAGE_PUBLISHER" {
  type        = string
  default     = "Canonical"
  description = "The publisher of the base image used for customization."
}

variable "IMAGE_OFFER" {
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
  description = "The offer of the base image used for customization."
}

variable "IMAGE_SKU" {
  type        = string
  default     = "22_04-lts"
  description = "Version of the base image used for customization."
}

variable "VM_SIZE" {
  type        = string
  default     = "Standard_NC4as_T4_v3"
  description = "Size of base AZURE VM."
}

variable "USER_ASSIGNED_MANAGED_IDENTITIES" {
  type        = list(string)
  default     = []
  description = "Optional list of resource IDs of user-assigned managed identities to assign to the Packer builder Virtual Machine."
  sensitive   = true
}

variable "AZURE_KEY_VAULT" {
  type        = string
  default     = ""
  description = "(Optional) Name of an Azure Key vault containing secrets to be used during the Packer build."
  sensitive   = true
}

# Set up local variables used by provisioners.
locals {
  image_uuid      = uuidv4()
  timestamp       = regex_replace(timestamp(), "[- TZ:]", "")
  build_scripts   = [for s in var.BUILD_SCRIPTS : format("build/%s", s)]
  startup_scripts = [for s in var.STARTUP_SCRIPTS : format("startup/%s", s)]
  runtime_scripts = [for s in var.RUNTIME_SCRIPTS : format("runtime/%s", s)]
}

# Configure the AZURE instance that is used to build the machine image.
source "azure-arm" "Image_Builder" {
  client_id                         = "${var.CLIENT_ID}"
  client_secret                     = "${var.CLIENT_SECRET}"
  managed_image_resource_group_name = "${var.RESOURCE_GROUP_NAME}"
  managed_image_name                = "ml-ubuntu--image-${var.RELEASE}-${local.image_uuid}"
  subscription_id                   = "${var.SUBSCRIPTION_ID}"
  tenant_id                         = "${var.TENANT_ID}"
  os_type                           = "Linux"
  image_publisher                   = "${var.IMAGE_PUBLISHER}"
  image_offer                       = "${var.IMAGE_OFFER}"
  image_sku                         = "${var.IMAGE_SKU}"
  azure_tags                        = "${var.AZURE_TAGS}"
  location                          = "East US"
  vm_size                           = "${var.VM_SIZE}"
  os_disk_size_gb                   = "128"
  user_assigned_managed_identities  = "${var.USER_ASSIGNED_MANAGED_IDENTITIES}"
}

# Build the machine image.
build {
  sources = ["source.azure-arm.Image_Builder"]

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    inline = ["mkdir /tmp/startup"]
  }

  provisioner "file" {
    destination = "/var/tmp/"
    source      = "build/config"
  }

  provisioner "file" {
    destination = "/tmp/startup/"
    sources     = "${local.startup_scripts}"
  }

  provisioner "file" {
    destination = "/tmp/"
    sources     = "${local.runtime_scripts}"
  }

  provisioner "shell" {
    environment_vars = [
      "RELEASE=${var.RELEASE}",
      "SPKGS=${var.SPKGS}",
      "PRODUCTS=${var.PRODUCTS}",
      "MATLAB_PROXY_VERSION=${var.MATLAB_PROXY_VERSION}",
      "DCV_INSTALLER_URL=${var.DCV_INSTALLER_URL}",
      "NVIDIA_DRIVER_VERSION=${var.NVIDIA_DRIVER_VERSION}",
      "NVIDIA_CUDA_TOOLKIT=${var.NVIDIA_CUDA_TOOLKIT}",
      "NVIDIA_CUDA_KEYRING_URL=${var.NVIDIA_CUDA_KEYRING_URL}",
      "MATLAB_SOURCE_LOCATION=${var.MATLAB_SOURCE_LOCATION}",
      "SPKG_SOURCE_LOCATION=${var.SPKG_SOURCE_LOCATION}",
      "AZURE_KEY_VAULT=${var.AZURE_KEY_VAULT}",
      "MATLAB_ROOT=/usr/local/matlab"
    ]
    expect_disconnect = true
    scripts           = "${local.build_scripts}"
  }

  provisioner "shell" {
    scripts = [
    "build/cleanup.sh"]
  }

  post-processor "manifest" {
    output     = "${var.MANIFEST_OUTPUT_FILE}"
    strip_path = true
    custom_data = {
      release                           = "MATLAB ${var.RELEASE}"
      specified_products                = "${var.PRODUCTS}"
      specified_spkgs                   = "${var.SPKGS}"
      build_scripts                     = join(", ", "${var.BUILD_SCRIPTS}")
      managed_image_resource_group_name = "${var.RESOURCE_GROUP_NAME}"
    }
  }
}
