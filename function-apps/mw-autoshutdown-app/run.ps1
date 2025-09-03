# Copyright 2022-2025 The MathWorks, Inc.

# Input bindings are passed in via param block.
param($Timer)

$ErrorActionPreference = "Stop"

# Define constants used throughout the program
# Messages to be logged
$LogMessages = @{
    instanceStopped =  "Instance is stopped."
    tagNever = "Autoshutdown is not enabled. Change the value of mw-autoshutdown tag of the VM instance to enable the autoshutdown feature."
    tagInvalid = "The value of the mw-autoshutdown tag you have set is not valid. The format of the timestamp must be a valid RFC 1123 UTC timestamp, such as Thu, 16 Dec 2021 12:28:47 GMT."
    instanceJustBooted = "Instance has just started. Setting mw-autoshutdown tag value."
    readyForShutdown = "Shutdown time has been reached. Shutting instance down."
    tooEarlyToShutdown = "Shutdown time has not been reached yet. Too early to shutdown instance."
    inbuiltScheduleActive = "An Azure DevTest Labs auto-shutdown schedule is already active for this VM instance. Please disable it and set shut-down time in the mw-autoshutdown tag attached to the matlab-vm to enable auto-shutdown using this app."  
}

# Tag on the VM that dictates the shutdown behaviour
$TagToTrack = "mw-autoshutdown"

# Tag that depicts a user-defined shutdown is active for the instance
$UserDefinedShutdownTag = "user-managed-shutdown"

# Valid Tag Values
$TagNeverValue = 'never'
$ValidTimeStampFormat = 'ddd, dd MMM yyyy HH:mm:ss'

# The required parameters are fed in from the ARM template as environment variables
$ResourceGroup = ${env:RESOURCE_GROUP_NAME}
$NumberOfHoursBeforeShutdown = ${env:HOURS_BEFORE_SHUTDOWN}

# Normalize variable
if ($NumberOfHoursBeforeShutdown -eq 'Never') {
    $NumberOfHoursBeforeShutdown = $TagNeverValue
}

$VMName = ${env:INSTANCE_NAME}

# Retrieve VM information, contains information about instance tags, instance ID
$VM = Get-AzVM -Name "$VMName" -ResourceGroupName "$ResourceGroup"

# Retrieve VM instance view, contains information about Power state and last provisioning timestamp
$VMInstanceView = Get-AzVM -Name "$VMName" -ResourceGroupName "$ResourceGroup" -Status

# Retrieve Subscription ID
$CurrentSub = (Get-AzContext).Subscription.Id

# Helper function to print information
function Write-Information {
    param(
        [Parameter (Mandatory = $True)] [String] $MessageToLog
    )
    Write-Host $LogMessages[$MessageToLog]
}

function GetStartTime {
    <# Gets the VM's start time #>
    $BootTime = $null

    if ($VMInstanceView.Statuses) {
        # Find the most recent status with a Time property (if any)
        $StatusWithTime = $VMInstanceView.Statuses | Where-Object { $_.Time } | Sort-Object Time -Descending | Select-Object -First 1
        if ($StatusWithTime) {
            $BootTime = [datetime]$StatusWithTime.Time
        }
    }

    return $BootTime
}

# Retrieve the shutdown tag's value
function Get-ShutDownTag {
    $InstanceTags = $VM.tags.$TagToTrack
    return $InstanceTags
}

# Set the calculated value for shutdown
function Set-ShutDownTag {
    param(
        [Parameter (Mandatory = $True)] [String] $TagValue
    )
    $Tag = @{$TagToTrack = $TagValue}
    Update-AzTag -Tag $Tag -ResourceId $VM.Id -Operation Merge | Out-Null
}

# Calculate the shut down time for the VM
function Set-ShutDownTime {
    # Regex that extracts the integer value provided from the "AutoShutdown" parameter
    $TimeIntervalBeforeShutdown = $NumberOfHoursBeforeShutdown -replace "[^0-9]",''
    $LaunchTime = GetStartTime
    if ($LaunchTime){
        # Add the number of hours post launch 
        $ShutDownTime = $LaunchTime.AddHours($TimeIntervalBeforeShutdown)
        #Convert the DateTime object to the recommended format
        $ShutDownTime = $ShutDownTime.ToString($ValidTimeStampFormat) + " GMT"
        Set-ShutDownTag -TagValue $ShutDownTime
    }
}

# Set the value of last autoshutdown triggered by the function app
function Set-LastAutoshutdownEventTag {
    param(
        [Parameter (Mandatory = $True)] [String] $LastShutDownTime
    )
    $Tag = @{"mw-last-autoshutdown-event" = $LastShutDownTime}
    Update-AzTag -Tag $Tag -ResourceId $VM.Id -Operation Merge | Out-Null
}

# Check if the instance is stopped
function IsInstanceStopped {
    # List of stopped/stopping/deallocating states
    $stoppedStates = @(
        "VM deallocated",
        "VM stopped",
        "VM stopping",
        "VM deallocating"
    )

    # Find the PowerState status
    $PowerStateStatus = $VMInstanceView.Statuses | Where-Object { $_.Code -like "*PowerState*" } | Select-Object -First 1

    if ($PowerStateStatus -and $PowerStateStatus.DisplayStatus -in $stoppedStates) {
        return $true
    }
    return $false
}

# Helper function to retrieve information about active in-built auto-shutdown schedule
function getDevTestLabsSchedule {
    <# 
    Check if user has enabled the in-built DevTest Labs Auto-shutdown feature for this VM
    If yes, we extract the schedule time and set the mw-autoshutdown tag accordingly. 
    #>    
    try{
        $AutoShutdownSchedule = Get-AzResource -ResourceId ("/subscriptions/{0}/resourceGroups/{1}/providers/microsoft.devtestlab/schedules/shutdown-computevm-{2}" -f $CurrentSub, $ResourceGroup, $VMName)
    }
    catch [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkClient.ResourceManagerCloudException] {
        # if the schedule does not exist return false
        return $null
    }
    if ($AutoShutdownSchedule.Properties.status -eq "Enabled"){
        #Schedule exists and is enabled
        
        #Get the scheduled time in HH:mm format
        $AutoShutDownTime =  ($AutoShutdownSchedule.Properties.dailyRecurrence.time).Insert(2,':')
        #Get the time zone for the DevTest Labs auto-shutdown schedule
        $TimeZoneId = $AutoShutdownSchedule.Properties.timeZoneId
        #Get current date 
        $CurrentTime = Get-Date
        #Convert to the time zone set in the schedule
        $CurrentTimeConverted = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($CurrentTime, $TimeZoneId)
        
        #Create date-time for the auto-shutdown schedule
        $CurrentDate = ($CurrentTimeConverted).ToString("dd/MM/yyyy")
        $DateTimeString = $CurrentDate + " " + $AutoShutDownTime
        $AutoShutDownDateTime = [DateTime]::ParseExact($DateTimeString,'dd/MM/yyyy HH:mm',$null)

        <# 
        Compare with the current time and if the shut down time has already passed that implies the VM will shut down
        at the same time the next day, else, the shut down time need not be altered 
        #>
        if ($CurrentTimeConverted -gt $AutoShutDownDateTime){
            $AutoShutDownDateTime = $AutoShutDownDateTime.AddDays(1)
        }

        # Convert the auto-shutdown date-time to GMT and change it to RFC 1123 UTC timestamp format
        $AutoShutDownDateTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($AutoShutDownDateTime, $TimeZoneId, "UTC");
        $AutoShutDownDateTime = $AutoShutDownDateTime.ToString($ValidTimeStampFormat) + " GMT"

        return $AutoShutDownDateTime
    }
    #Schedule exists but disabled
    return $null
}

function Set-UserManagedShutdownTag {
    # Retrieve information about in-built auto-shutdown schedule
    $AutoShutDownDateTime = getDevTestLabsSchedule
    $Tag = $VM.tags.$UserDefinedShutdownTag

    if ($AutoShutDownDateTime){
        <# 
        If an Azure DevTest Labs auto-shutdown schedule if active for the VM, we check and set the user-managed-shutdown tag to true
        We do not interfere with this schedule, just log this information and return 
        #>
        if (!$Tag -or ($Tag -eq "False")){
            <# 
            If tag does not exists or is set to False (which can happen if user set the devtestlab schedule after VM deployment), 
            then add it to the VM with value as "True"
            #>
            $TagValue = @{$UserDefinedShutdownTag = "True"}
            Update-AzTag -Tag $TagValue -ResourceId $VM.Id -Operation Merge | Out-Null
        }
        Set-ShutDownTag -TagValue $AutoShutDownDateTime
        Write-Information -MessageToLog "inbuiltScheduleActive"
        return $true
    }

    # If in-built auto-shutdown is not active and the user-managed-shutdown tag is 'True' or non-existent, set it to False
    if ($Tag -ne "False"){
        $TagValue = @{$UserDefinedShutdownTag = "False"}
        Update-AzTag -Tag $TagValue -ResourceId $VM.Id -Operation Merge | Out-Null
    }

    return $false
}

function main {
    # If instance is stopped, no action required
    if (IsInstanceStopped){
        Write-Information -MessageToLog "instanceStopped"
        return
    }

    # Validate if the instance already has an Azure DevTest Labs auto-shutdown schedule
    $UserManagedScheduleActive = Set-UserManagedShutdownTag

    # If yes, no action needed by the app
    if ($UserManagedScheduleActive) {
        return
    }

    # Retrieve mw-autoshutdown tag
    $ShutDownTag = Get-ShutDownTag

    # Initialize the mw-autoshutdown tag according to user's choice for shut down
    if (-not $ShutDownTag){
        <# if tag doesn't exists, then it means this is the first function app execution or the tag has been explicitly deleted
         in such cases, create the tag and attach it to the VM #>
        if ($NumberOfHoursBeforeShutdown -eq $TagNeverValue){
            Set-ShutDownTag -TagValue $TagNeverValue
            Write-Information -MessageToLog "tagNever"
            return
        }
        
        # Calculate the shut down time according user input
        Set-ShutDownTime
        Write-Information -MessageToLog "instanceJustBooted"
        return
    }

    # This is to check the status of the mw-autoshutdown tag in subsequent runs
    if ($ShutDownTag -eq "change_me_on_boot"){
        # This tag value reflects that the VM was shutdown by the app in a previous run
        Set-ShutDownTime
        Write-Information -MessageToLog "instanceJustBooted"
    }
    elseif ($ShutDownTag -eq $TagNeverValue){
        Write-Information -MessageToLog "tagNever"
    }
    else {
        # In this case, the tag must be containing a timestamp, we validate if this value is in the correct format
        try{
            $ShutdownTime = [DateTime]::ParseExact($ShutDownTag,"${ValidTimeStampFormat} GMT",$null)   
        }
        catch [System.FormatException]
        {
            Write-Information -MessageToLog "tagInvalid"
            return
        }
        $CurrentTime = (Get-Date).ToUniversalTime()
        if ($CurrentTime -gt $ShutdownTime){
            # If the shutdown time in the tag has reached/passed, force stop the VM
            Stop-AzVM -Name "$VMName" -ResourceGroupName "$ResourceGroup" -Confirm:$False -Force
            Write-Information -MessageToLog "readyForShutdown"
            $LastShutDownTime = $CurrentTime.ToString($ValidTimeStampFormat) + " GMT"
            Set-LastAutoshutdownEventTag -LastShutDownTime $LastShutDownTime

            # Prepare tag for next runs
            if ($NumberOfHoursBeforeShutdown -eq $TagNeverValue){
                # If the default choice for auto-shutdown was 'Never', set tag accordingly
                Set-ShutDownTag -TagValue $TagNeverValue
            }
            else{
                # Else, set it to a phrase that relates to shutdown by app
                Set-ShutDownTag -TagValue "change_me_on_boot"
            }
            return
        }
        else{
            # If shutdown time has not been reached, log the same information
            Write-Information -MessageToLog "tooEarlyToShutdown"
            return
        } 
    }
}

main
