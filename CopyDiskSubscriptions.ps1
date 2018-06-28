#Provide the subscription Id of the subscription where managed disk exists
$sourceSubscriptionId='cdd5afd6-c1c6-4c56-8c77-edf30c4e0472'

#Provide the name of your resource group where managed disk exists
$sourceResourceGroupName='RG-SharePointComercial'

#Provide the name of the managed disk
$managedDiskName='EXDADGNSR402-OSDisk_Caso_00127628'

#Set the context to the subscription Id where Managed Disk exists
Select-AzureRmSubscription -SubscriptionId $sourceSubscriptionId

#Get the source managed disk
$managedDisk= Get-AzureRMDisk -ResourceGroupName $sourceResourceGroupName -DiskName $managedDiskName

#Provide the subscription Id of the subscription where managed disk will be copied to
#If managed disk is copied to the same subscription then you can skip this step
$targetSubscriptionId='fd3362a2-9173-419e-a06e-db6282bd9a2f'

#Name of the resource group where snapshot will be copied to
$targetResourceGroupName='Sharepoint_Desenvolvimento'

#Set the context to the subscription Id where managed disk will be copied to
#If snapshot is copied to the same subscription then you can skip this step
Select-AzureRmSubscription -SubscriptionId $targetSubscriptionId

$diskConfig = New-AzureRmDiskConfig -SourceResourceId $managedDisk.Id -Location $managedDisk.Location -CreateOption Copy 

#Create a new managed disk in the target subscription and resource group
New-AzureRmDisk -Disk $diskConfig -DiskName $managedDiskName -ResourceGroupName $targetResourceGroupName