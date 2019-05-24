###########################################################################################
#
# .Description
#   Script used for automatically resizing VMs
#
###########################################################################################
# .Author:  Eduardo Kieling
# .Blog:    https://eduardokieling.com 
# .Version:    1.0
###########################################################################################

###### User definition ####################################################################
#
#
$ResourceGroup = "GRPRD-TEEVO-KIELING-01" #Set a resource group
$VMName = "VMW-KIE-W10-01"   #Set a VM Name
$NewSize = "Standard_B2ms"  #Check the size you want: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes
$HaveaAvailabilitySet = "no"  #Is your VM part of a AvailabilitySet (no/yes)?
#
#
###########################################################################################

#Resize a VMs in an availability set, if $HaveaAvailabilitySet is equal to "yes"

if($HaveaAvailabilitySet -eq "yes"){
    $as = Get-AzAvailabilitySet -ResourceGroupName $ResourceGroup
    $vmIds = $as.VirtualMachinesReferences
    foreach ($vmId in $vmIDs){
        $string = $vmID.Id.Split("/")
        $VMName = $string[8]
        Write-Host "Stopping $VMName"
        Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Force
        $vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
        Write-Host "Changing $VMName size to $NewSize"
        $vm.HardwareProfile.VmSize = $NewSize
        Update-AzVM -ResourceGroupName $ResourceGroup -VM $vm
        Write-Host "Starting $VMName in a new size"
        Start-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
     }
} else {

#Resize a single VM

        Write-Host "Stopping $VMName"
        Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Force
        $vm = Get-AzVM -ResourceGroupName $ResourceGroup -VMName $VMName
        Write-Host "Changing $VMName size to $NewSize"
        $vm.HardwareProfile.VmSize = $NewSize
        Update-AzVM -VM $vm -ResourceGroupName $ResourceGroup
        Write-Host "Starting $VMName in a new size"
        Start-AzVM -ResourceGroupName $ResourceGroup -Name $VMName

}