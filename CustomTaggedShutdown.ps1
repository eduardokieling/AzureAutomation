<#
    .DESCRIPTION
        A runbook which Shuts Down all running VM's tagged with custom tags matching the key and value outlined below,
        using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Eduardo José Kieling
#>


#If you used a custom RunAsConnection during the Automation Account setup this will need to reflect that.
$connectionName = "AzureRunAsConnection" 
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
    
    "Logging in to Azure..."
    Login-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
<#
 Get all VMs in the subscription with the Tag StartStop:1 and Shut them down if they are running
 In this section we are filtering our Get-AzureRMVM statement by selecting VM's that have a Key of Tier and Value of 2, We also have implemented an If statement to only
 run against VMs that are already running.
#>
                                            #This is where you would set your custom Tags Keys and Values
[array]$VMs = Get-AzureRMVm -Status | `
Where-Object {$PSItem.Tags.Keys -eq "StartStop" -and $PSItem.Tags.Values -eq "1" `
-and $PSItem.PowerState -eq "VM running"}
 
ForEach ($VM in $VMs) 
{
    Write-Output "Shutting down: $($VM.Name)"
    Stop-AzureRMVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force
}     



