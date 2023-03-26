
 $StorageAccountName="mystorage61"  
 $ResourceGroupName="DefaultResourceGroup-EUS"  
 $fileshareName = "filetodelete"  

  $StorageAccountAccessKey = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName | Where-Object {$_.KeyName -eq "key1"}  

  $ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountAccessKey.Value  

$DirIndex = 0  
$dirsToList = New-Object System.Collections.Generic.List[System.Object]  
  
# Get share root Dir  
$shareroot = Get-AzStorageFile -ShareName $shareName -Path . -context $ctx   
$dirsToList += $shareroot   
  
# List files recursively and remove file older than 14 days   
While ($dirsToList.Count -gt $DirIndex)  
{  
    $dir = $dirsToList[$DirIndex]  
    $DirIndex ++  
    $fileListItems = $dir | Get-AzStorageFile  
    $dirsListOut = $fileListItems | where {$_.GetType().Name -eq "AzureStorageFileDirectory"}  
    $dirsToList += $dirsListOut  
    $files = $fileListItems | where {$_.GetType().Name -eq "AzureStorageFile"}  
  
    foreach($file in $files)  
    {  
        # Fetch Attributes of each file and output  
        $task = $file.CloudFile.FetchAttributesAsync()  
        $task.Wait()  
  
        # remove file if it's older than 14 days.  
        if ($file.CloudFile.Properties.LastModified -lt (9Get-Date).AddDays(0))  
        {  
			Write-Host "file :",$file.Name  "is older than 0 days so removing it ..!"   
            ## print the file LMT  
            # $file | Select @{ Name = "Uri"; Expression = { $_.CloudFile.SnapshotQualifiedUri} }, @{ Name = "LastModified"; Expression = { $_.CloudFile.Properties.LastModified } }   
  
            # remove file  
            $file | Remove-AzStorageFile  
        }  
    }  
    #Debug log  
    # Write-Host  $DirIndex $dirsToList.Length  $dir.CloudFileDirectory.SnapshotQualifiedUri.ToString()   
}
