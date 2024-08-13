# Azure VM Alerts Configuration Script

This PowerShell script is designed to configure alert rules for an Azure Virtual Machine (VM) to monitor CPU and memory usage. It creates alerts based on specified thresholds and configurations, retrieves the alert history, and saves the logs to a file.

## How the Script Works

1. **Connects to Azure**: The script uses `Connect-AzAccount` to authenticate to your Azure account.

2. **Selects Subscription**: It selects the Azure subscription to work with using `Select-AzSubscription`.

3. **Retrieves VM**: The script fetches the VM details using `Get-AzVM` to ensure it exists and is accessible.

4. **Creates CPU Alert Rule**:
   - It defines the condition for the alert based on CPU usage percentage.
   - It uses `New-AzMetricAlertRule` to create the alert rule with specified parameters like window size, frequency, and severity.

5. **Creates Memory Alert Rule**:
   - It defines the condition for the alert based on available memory.
   - It uses `New-AzMetricAlertRule` to create the alert rule similar to the CPU alert.

6. **Retrieves and Displays Alert History**:
   - It fetches the alert history using `Get-AzAlert`.
   - Displays the alert details if any alerts have been triggered.

7. **Retrieves and Saves Logs**:
   - It fetches the logs for the VM using `Get-AzLog`.
   - The logs are saved to a file named using the VM name and a timestamp to ensure uniqueness and traceability.

## Customizing the Alerts

To customize the alert rules for CPU and memory usage:

1. **Modify Parameters**: Update the script parameters according to your needs:
   - Set the threshold percentage for CPU usage alerts.
   - Define the time window for evaluating the CPU metric.
   - Set how often the alert rule is evaluated.
   - Specify the severity level for the alert.

   Similarly, update parameters for memory alerts:
   - Set the threshold for available memory.
   - Adjust the time window, frequency, and severity for memory alerts.

2. **Adjust Metric Names**: If needed, adjust metric names to match those used in your Azure environment.

## Example

To execute the script, run it with the required parameters. For example:

```powershell
.\Configure-VMAlerts.ps1 -SubscriptionId "YOUR_SUBSCRIPTION_ID" `
                          -ResourceGroupName "YOUR_RG_NAME" `
                          -VMName "YOUR_VM_NAME" `
                          -Location "East US 2" `
                          -CpuAlertRuleName "HighCPUUsageAlert" `
                          -CpuUsageThresholdPercentage 80 `
                          -CpuAlertWindowSize "00:05:00" `
                          -CpuAlertFrequency "00:05:00" `
                          -CpuAlertSeverity 4 `
                          -MemoryAlertRuleName "HighMemoryUsageAlert" `
                          -MemoryAvailableThreshold 2 `
                          -MemoryAlertWindowSize "00:05:00" `
                          -MemoryAlertFrequency "00:05:00" `
                          -MemoryAlertSeverity 4
```

### Parameters

- **`-SubscriptionId`**: Azure subscription ID.
- **`-ResourceGroupName`**: Name of the Azure resource group.
- **`-VMName`**: Name of the Azure VM.
- **`-Location`**: Azure region where the VM is located.
- **`-CpuAlertRuleName`**: Name of the CPU alert rule.
- **`-CpuUsageThresholdPercentage`**: Threshold percentage for CPU usage.
- **`-CpuAlertWindowSize`**: Time window for CPU alert evaluation.
- **`-CpuAlertFrequency`**: Frequency of CPU alert evaluations.
- **`-CpuAlertSeverity`**: Severity level of the CPU alert.
- **`-MemoryAlertRuleName`**: Name of the memory alert rule.
- **`-MemoryAvailableThreshold`**: Threshold for available memory in GB.
- **`-MemoryAlertWindowSize`**: Time window for memory alert evaluation.
- **`-MemoryAlertFrequency`**: Frequency of memory alert evaluations.
- **`-MemoryAlertSeverity`**: Severity level of the memory alert.

## Additional Notes

- Ensure you have the `Az` module installed and imported in your PowerShell session.
- You may need appropriate permissions to create and manage alerts in your Azure subscription.
- Logs are saved to a file named using the VM name and a timestamp (e.g., `VMNAME_TIMESTAMP_log.txt`) for easier tracking and management.
