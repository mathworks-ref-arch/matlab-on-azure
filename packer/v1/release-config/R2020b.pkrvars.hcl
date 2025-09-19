# Copyright 2023-2025 The MathWorks, Inc.

// Use this Packer configuration file to build a VHD with R2020b MATLAB installed.
// For more information on these variables, see /packer/v1/build-azure-matlab.pkr.hcl.
RELEASE                     = "R2020b"
STARTUP_SCRIPTS             = [".env", "10_setup-machine.sh", "20_install-nicedcv.sh", "30_setup-rdp.sh", "40_setup-nicedcv.sh", "60_setup-matlab.sh", "80_warmup-matlab.sh", "90_run-optional-user-command.sh"]
RUNTIME_SCRIPTS             = ["swap-desktop-solution.sh"]
BUILD_SCRIPTS               = ["install-startup-scripts.sh", "install-swap-desktop-solution.sh", "install-dependencies.sh", "install-matlab-dependencies-ubuntu.sh", "install-ubuntu-desktop.sh", "setup-mate.sh", "install-matlab.sh", "install-glibc-ubuntu2004.sh", "install-fabric-manager-ubuntu.sh"]
PRODUCTS                    = "5G_Toolbox Antenna_Toolbox Aerospace_Blockset Mixed-Signal_Blockset Phased_Array_System_Toolbox AUTOSAR_Blockset Aerospace_Toolbox Audio_Toolbox Bioinformatics_Toolbox Curve_Fitting_Toolbox Communications_Toolbox MATLAB_Compiler Control_System_Toolbox Simulink_Coverage Database_Toolbox Datafeed_Toolbox Deep_Learning_HDL_Toolbox Parallel_Computing_Toolbox Automated_Driving_Toolbox DSP_System_Toolbox Simulink_Design_Verifier Embedded_Coder HDL_Verifier Econometrics_Toolbox Filter_Design_HDL_Coder Financial_Toolbox Fuzzy_Logic_Toolbox GPU_Coder Global_Optimization_Toolbox HDL_Coder SoC_Blockset Image_Acquisition_Toolbox Instrument_Control_Toolbox System_Identification_Toolbox Image_Processing_Toolbox Financial_Instruments_Toolbox Simscape_Driveline Wireless_HDL_Toolbox Lidar_Toolbox LTE_Toolbox MATLAB_Coder Mapping_Toolbox MATLAB_Compiler_SDK MATLAB Model_Predictive_Control_Toolbox MATLAB_Report_Generator Simscape_Multibody Motor_Control_Blockset Deep_Learning_Toolbox Navigation_Toolbox Optimization_Toolbox Partial_Differential_Equation_Toolbox Simulink_PLC_Coder Predictive_Maintenance_Toolbox Fixed-Point_Designer Simscape_Electrical Powertrain_Blockset Radar_Toolbox RF_Blockset Robust_Control_Toolbox RF_Toolbox Risk_Management_Toolbox Reinforcement_Learning_Toolbox Robotics_System_Toolbox Simulink_Requirements ROS_Toolbox Simulink_Coder SimBiology Simulink_Control_Design SimEvents Stateflow Signal_Processing_Toolbox Simscape_Fluids Simulink_Compiler Simulink Symbolic_Math_Toolbox Simulink_Design_Optimization Simulink_Report_Generator Simscape Statistics_and_Machine_Learning_Toolbox SerDes_Toolbox Simulink_Test Text_Analytics_Toolbox Sensor_Fusion_and_Tracking_Toolbox Trading_Toolbox UAV_Toolbox Vehicle_Dynamics_Blockset Vehicle_Network_Toolbox Computer_Vision_Toolbox Simulink_3D_Animation Vision_HDL_Toolbox Simulink_Check Wavelet_Toolbox WLAN_Toolbox System_Composer"
NVIDIA_CUDA_TOOLKIT         = ""
NVIDIA_CUDA_KEYRING_URL     = "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb"
NVIDIA_DRIVER_VERSION       = ""
DCV_INSTALLER_URL           = "https://d1uj6qtbmh3dt5.cloudfront.net/2022.2/Servers/nice-dcv-2022.2-13907-ubuntu2004-x86_64.tgz"
IMAGE_PUBLISHER             = "Canonical"
IMAGE_OFFER                 = "0001-com-ubuntu-server-focal"
IMAGE_SKU                   = "20_04-lts"
VM_SIZE                     = "Standard_NC4as_T4_v3"
