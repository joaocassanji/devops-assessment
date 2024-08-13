param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]$VMName,

    [Parameter(Mandatory = $true, Position = 3)]
    [string]$Location,

    [Parameter(Mandatory = $true, Position = 4)]
    [string]$CpuAlertRuleName,

    [Parameter(Mandatory = $true, Position = 5)]
    [int]$CpuUsageThresholdPercentage,

    [Parameter(Mandatory = $true, Position = 6)]
    [string]$CpuAlertWindowSize,

    [Parameter(Mandatory = $true, Position = 7)]
    [string]$CpuAlertFrequency,

    [Parameter(Mandatory = $true, Position = 8)]
    [int]$CpuAlertSeverity,

    [Parameter(Mandatory = $true, Position = 9)]
    [string]$MemoryAlertRuleName,

    [Parameter(Mandatory = $true, Position = 10)]
    [int]$MemoryAvailableThreshold,

    [Parameter(Mandatory = $true, Position = 11)]
    [string]$MemoryAlertWindowSize,

    [Parameter(Mandatory = $true, Position = 12)]
    [string]$MemoryAlertFrequency,

    [Parameter(Mandatory = $true, Position = 13)]
    [int]$MemoryAlertSeverity
)

# Connect to Azure account
try {
    Connect-AzAccount -UseDeviceAuthentication
} catch {
    Write-Error "Failed to connect to Azure account. $_"
    exit
}

# Select the subscription
try {
    Select-AzSubscription -SubscriptionId $SubscriptionId
} catch {
    Write-Error "Failed to select subscription. $_"
    exit
}

# Get the VM
try {
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
} catch {
    Write-Error "Failed to retrieve VM. $_"
    exit
}

# Create an alert rule for CPU usage
try {
    $cpuAlertCondition = New-AzMetricAlertRuleV2Criteria -MetricName "Percentage CPU" -MetricNameSpace "Microsoft.Compute/virtualMachines" -TimeAggregation Average -Operator GreaterThan -Threshold $CpuUsageThresholdPercentage

    $cpuAlertRule = Add-AzMetricAlertRuleV2 -ResourceGroupName $ResourceGroupName `
                                            -Name $CpuAlertRuleName `
                                            -TargetResourceScope $vm.Id `
                                            -TargetResourceRegion $Location `
                                            -TargetResourceType "Microsoft.Compute/virtualMachines" `
                                            -WindowSize $CpuAlertWindowSize `
                                            -Frequency $CpuAlertFrequency `
                                            -Severity $CpuAlertSeverity `
                                            -Condition $cpuAlertCondition
} catch {
    Write-Error "Failed to create CPU alert rule. $_"
}

# Create an alert rule for memory usage
try {
    $memoryAlertCondition = New-AzMetricAlertRuleV2Criteria -MetricName "Available Memory Bytes" -MetricNameSpace "Microsoft.Compute/virtualMachines" -TimeAggregation Average -Operator LessThan -Threshold ($MemoryAvailableThreshold * 1GB)

    $memoryAlertRule = Add-AzMetricAlertRuleV2 -ResourceGroupName $ResourceGroupName `
                                              -Name $MemoryAlertRuleName `
                                              -TargetResourceScope $vm.Id `
                                              -TargetResourceRegion $Location `
                                              -TargetResourceType "Microsoft.Compute/virtualMachines" `
                                              -WindowSize $MemoryAlertWindowSize `
                                              -Frequency $MemoryAlertFrequency `
                                              -Severity $MemoryAlertSeverity `
                                              -Condition $memoryAlertCondition
} catch {
    Write-Error "Failed to create memory alert rule. $_"
}

Write-Output "Monitoring and alerts configured successfully."

# Retrieve the alert history for the VM
try {
    Get-AzAlert -TargetResourceGroup $ResourceGroupName

} catch {
    Write-Output "An error occurred: $_"
}

# Retrieve and save the log
try {
    $log = Get-AzLog -ResourceId $vm.Id

    # Create a filename with VMName and timestamp
    $timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
    $filename = "$VMName`_$timestamp`_log.txt"

    # Save the log to a file
    $log | Out-File -FilePath $filename
    Write-Output "Log saved to $filename"
} catch {
    Write-Error "Failed to retrieve or save log. $_"
}