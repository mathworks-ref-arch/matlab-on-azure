# Copyright 2022 The MathWorks, Inc.

# Input bindings are passed in via param block.
param($Timer)

$ErrorActionPreference = "Stop"

# The required parameters are fed in from the ARM template as environment variables
$ResourceGroup = ${env:RESOURCE_GROUP_NAME}
$NumberOfHoursBeforeShutdown = ${env:HOURS_BEFORE_SHUTDOWN}

# Retrieve the VM name
$VM = Get-AzVM -Status | Where-Object {$_.ResourceGroupName -eq $ResourceGroup}
$CurrentSub = (Get-AzContext).Subscription.Id
$VMName = $VM.Name

# Messages to be logged are defined here
$LogMessages = @{
    instanceStopped =  "Instance is stopped."
    tagNever = "Autoshutdown is not enabled. Change the value of mw-autoshutdown tag of the VM instance to enable the autoshutdown feature."
    tagInvalid = "The value of the mw-autoshutdown tag you have set is not valid. The format of the timestamp must be a valid RFC 1123 UTC timestamp, such as Thu, 16 Dec 2021 12:28:47 GMT."
    instanceJustBooted = "Instance has just started. Setting mw-autoshutdown tag value."
    readyForShutdown = "Shutdown time has been reached. Shutting instance down."
    tooEarlyToShutdown = "Shutdown time has not been reached yet. Too early to shutdown instance."
    inbuiltScheduleActive = "An Azure DevTest Labs auto-shutdown schedule is already active for this VM instance. Please disable it and set shut-down time in the mw-autoshutdown tag attached to the matlab-vm to enable auto-shutdown using this app."  
    }

# Helper function to print information
function LogInformation {
    param(
        [Parameter (Mandatory = $True)] [String] $MessageToLog
    )
    Write-Host $LogMessages[$MessageToLog]
}

function GetStartTime {
    # This function utilizes the app's permissions over the resource group to generate token in order to fetch the boot time of the VM
    $TokenResponse = Get-AzAccessToken -ResourceUrl "https://management.azure.com" 
    $AccessToken = $TokenResponse.Token
    $AzureUrl = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Compute/virtualMachines/{2}/instanceView?api-version=2017-03-30" -f $CurrentSub, $ResourceGroup, $VMName  
    $Response =  Invoke-RestMethod -Method GET -Uri $AzureUrl -Headers @{ Authorization= "Bearer $AccessToken"}
    $BootTime = $Null
    if ($response) {
        $BootTime = [String] $Response.statuses.time
        $BootTime = [Datetime] $BootTime
    }
    return $BootTime
}

# Retrieve the shutdown tag's value
function GetShutDownTag {
    $InstanceTags = $VM.tags."mw-autoshutdown"
    return $InstanceTags
}

# Set the calculated value for shutdown
function SetShutDownTag {
    param(
        [Parameter (Mandatory = $True)] [String] $ShutDownTime
    )
    $Tag = @{"mw-autoshutdown" = $ShutDownTime}
    Update-AzTag -Tag $Tag -ResourceId $VM.Id -Operation Merge | Out-Null
}

# Calculate the shut down time for the VM
function SetShutDownTime {
    # Regex that extracts the integer value provided from the "AutoShutdown" parameter
    $TimeIntervalBeforeShutdown = $NumberOfHoursBeforeShutdown -replace "[^0-9]",''
    $LaunchTime = GetStartTime
    if ($LaunchTime){
        # Add the number of hours post launch 
        $ShutDownTime = $LaunchTime.AddHours($TimeIntervalBeforeShutdown)
        #Convert the DateTime object to the recommended format
        $ShutDownTime = $ShutDownTime.ToString('ddd, dd MMM yyyy HH:mm:ss') + " GMT"
        SetShutDownTag($ShutDownTime)
    }
}

# Set the value of last autoshutdown triggered by the function app
function SetLastAutoshutdownEventTag {
    param(
        [Parameter (Mandatory = $True)] [String] $LastShutDownTime
    )
    $Tag = @{"mw-last-autoshutdown-event" = $LastShutDownTime}
    Update-AzTag -Tag $Tag -ResourceId $VM.Id -Operation Merge | Out-Null
}

# Check if the instance is stopped, if yes, then return
function IsInstanceStopped {
    $status = $VM.PowerState
    if ($status -eq "VM deallocated"){
        return $True
    }
    return $False
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
        $AutoShutDownDateTime = $AutoShutDownDateTime.ToString('ddd, dd MMM yyyy HH:mm:ss') + " GMT"

        return $AutoShutDownDateTime
    }
    #Schedule exists but disabled
    return $null
}

function main {
    # If instance is stopped, no action required
    if (IsInstanceStopped){
        LogInformation("instanceStopped")
        return
    }

    # Else, retrieve information about in-built auto-shutdown schedule
    $AutoShutDownDateTime = getDevTestLabsSchedule
    $Tag = $VM.tags."user-managed-shutdown"

    if ($AutoShutDownDateTime){
        <# 
        If an Azure DevTest Labs auto-shutdown schedule if active for the VM, we check and set the user-managed-shutdown tag to true
        We do not interfere with this schedule, just log this information and return 
        #>
        if (!$Tag -or ($Tag -eq "False")){
            <# 
            If tag does not exists or is set to False, then add it to the VM with value as "True"
            #>
            $TagValue = @{"user-managed-shutdown" = "True"}
            Update-AzTag -Tag $TagValue -ResourceId $VM.Id -Operation Merge | Out-Null
        }
        SetShutDownTag($AutoShutDownDateTime)
        LogInformation("inbuiltScheduleActive")
        return
    }

    # If in-built auto-shutdown is not active and the user-managed-shutdown tag is 'True' or non-existent, set it to true
    if ($Tag -ne "False"){
        $TagValue = @{"user-managed-shutdown" = "False"}
        Update-AzTag -Tag $TagValue -ResourceId $VM.Id -Operation Merge | Out-Null
    }
    
    # Once in-built auto-shutdown is handled, retrieve mw-autoshutdown tag
    $ShutDownTag = GetShutDownTag

    # Initialize the mw-autoshutdown tag according to user's choice for shut down
    if (!$ShutDownTag){
        <# if tag doesn't exists, then it means this is the first function app execution or the tag has been explicitly deleted
         in such cases, create the tag and attach it to the VM #>
        if ($NumberOfHoursBeforeShutdown -eq "Never"){
            SetShutDownTag("never")
            LogInformation("tagNever")
            return
        }
        else {
            # Calculate the shut down time according user input
            SetShutDownTime
            LogInformation("instanceJustBooted")
            return
        }
    }

    # This is to check the status of the mw-autoshutdown tag in subsequent runs
    if ($ShutDownTag -eq "change_me_on_boot"){
        # This tag value reflects that the VM was shutdown by the app in a previous run
        SetShutDownTime
        LogInformation("instanceJustBooted")
    }
    elseif ($ShutDownTag -eq "Never"){
        LogInformation("tagNever")
    }
    else {
        # In this case, the tag must be containing a timestamp, we validated if this value is in the correct format
        try{
            $ShutdownTime = [DateTime]::ParseExact($ShutDownTag,'ddd, dd MMM yyyy HH:mm:ss GMT',$null)   
        }
        catch [System.FormatException]
        {
            LogInformation("tagInvalid")
            return
        }
        $CurrentTime = (Get-Date).ToUniversalTime()
        if ($CurrentTime -gt $ShutdownTime){
            # If the shutdown time in the tag has reached/passed, force stop the VM
            Stop-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Confirm:$False -Force
            LogInformation("readyForShutdown")
            $LastShutDownTime = $CurrentTime.ToString('ddd, dd MMM yyyy HH:mm:ss') + " GMT"
            SetLastAutoshutdownEventTag($LastShutDownTime)

            # Prepare tag for next runs
            if ($NumberOfHoursBeforeShutdown -eq "Never"){
                # If the default choice for auto-shutdown was 'Never', set tag accordingly
                SetShutDownTag("never")
            }
            else{
                # Else, set it to a phrase that relates to shutdown by app
                SetShutDownTag("change_me_on_boot")
            }
            return
        }
        else{
            # If shutdown time has not been reached, log the same information
            LogInformation("tooEarlyToShutdown")
            return
        } 
    }
}

main