Connect-azaccount
$subscription=get-azsubscription
$output = @()
foreach($sub in $subscription)
{$storageaccount= Get-azstorageaccount
 foreach($account in $storageaccount)
 {
  if ($account.PublicNetworkAccess -eq "Enabled")
  {$item = New-Object PSObject
  $item | Add-Member -Type NoteProperty -Name "Subscription Name" -Value $sub.Name
  $item | Add-Member -Type NoteProperty -Name "Storage account name" -Value $account.StorageAccountName
  $item | Add-Member -Type NoteProperty -Name "Resource group name" -Value $account.ResourceGroupName
  $item | Add-Member -Type NoteProperty -Name "Public Access" -Value $account.PublicNetworkAccess
  if ($account.Tags.Owner -eq $Null)
   {$item | Add-Member -Type NoteProperty -Name "Owner" -Value "N/A"}
  else
   {$item | Add-Member -Type NoteProperty -Name "Owner" -Value $account.Tags.Owner}
  if ($account.Tags.OwnerSupervisor -eq $Null)
   {$item | Add-Member -Type NoteProperty -Name "Owner Supervisor" -Value "N/A"}
  else
   {$item | Add-Member -Type NoteProperty -Name "Owner Supervisor" -Value $account.Tags.OwnerSupervisor}
  if ($account.Tags.CreatedBy -eq $Null)
   {$item | Add-Member -Type NoteProperty -Name "Created by" -Value "N/A"}
  else
   {$item | Add-Member -Type NoteProperty -Name "Created by" -Value $account.Tags.CreatedBy}
  if ($account.Tags.DateCreated -eq $Null)
   {$item | Add-Member -Type NoteProperty -Name "Creation Date" -Value "N/A"} 
  else
   {$item | Add-Member -Type NoteProperty -Name "Creation Date" -Value $account.Tags.DateCreated}
   if ($account.Tags.ProjectName -eq $Null)
   {$item | Add-Member -Type NoteProperty -Name "ProjectName" -Value "N/A"} 
  else
   {$item | Add-Member -Type NoteProperty -Name "ProjectName" -Value $account.Tags.ProjectName}
  $output += $item
  }
 }
}
$output
$output | export-csv -Path C:\Users\vats.76\finaloutput2.csv -NoTypeInformation


