param($latest)

# Store new sync in Azure Table

 $ctx = New-AzDataTableContext -ConnectionString $env:StravaAzureStorageConnection -TableName "StravaTokens"
 $SyncEntity = Get-AzDataTableEntity -Context $ctx  -Filter "RowKey eq 'LastSync'"
 $SyncEntity.LastSyncTime = $latest
 Update-AzDataTableEntity -Context $ctx -Entity $SyncEntity -Force
return 'update finsihed'