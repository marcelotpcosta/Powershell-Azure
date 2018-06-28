$sourceSubscriptionId=''

$sourceResourceGroupName=''

$snapshotName=''

$destinationSubscriptionId=''

$destinationResourceGroupName=''

#2. Set the context of source Subscription ID
Select-AzureRmSubscription -SubscriptionId $sourceSubscriptionId

#3. Get the snapshot
$snapshot= Get-AzureRmSnapshot -ResourceGroupName $sourceResourceGroupName -Name $snapshotName

#4. Set the context of the destination Subscription ID
Select-AzureRmSubscription -SubscriptionId $destinationSubscriptionId

#5. Instantiate the Snapshot Configuration
$snapshotConfig = New-AzureRmSnapshotConfig -SourceResourceId $snapshot.Id -Location $snapshot.Location -CreateOption Copy

#6. Instantiate new snaphot in destination subscription and resource group
New-AzureRmSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $destinationResourceGroupName
