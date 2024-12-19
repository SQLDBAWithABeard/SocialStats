param($activity)
$ActivityId = $activity.id
Get-Module Az.Storage
$containerName = "strava-activities"

if ($activity -eq "No new activities found") {
    Write-CustomLog = "Nothing to process for DataToStorage"
} elseif ($null -eq $activity) {
    Write-CustomLog "Nothing to see here"
    $setAzStorageBlobContentSplat = @{}
} else {
    $ActivityId = $activity.id
    Write-CustomLog "DataToStorage is processing activity $ActivityId" # {0}" -f ($activity | Out-String)
    # Store activities in blob storage
    $activityDate = [datetime]$activity.start_date

    $blobContent = @{
        activity          = $activity
        activityStartDate = $activityDate
        processedDate     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        source            = "StravaSync"
    } | ConvertTo-Json -Depth 64

    # New-TemporaryFile uses [System.IO.Path]::GetTempPath() location
    $tempFile = New-TemporaryFile
    $blobContent | Set-Content $tempFile.FullName

    $ctx = New-AzStorageContext -ConnectionString $env:StravaAzureStorageConnection
    $blobName = "strava-activities/{0}/{1}/{2}/{3}.json" -f $activityDate.Year, $activityDate.Month, $activityDate.Day, $ActivityId

    $blob = Get-AzStorageBlob -Container $containerName -Blob $blobName -Context $ctx -ErrorAction SilentlyContinue
    if ($blob) {
        Write-CustomLog "Blob $blobName exists."
        $dupeblobname = "strava-activities/dupes/{0}/{1}/{2}/{3}.json" -f $activityDate.Year, $activityDate.Month, $activityDate.Day, $ActivityId
        $dupeblob = Get-AzStorageBlob -Container $containerName -Blob $dupeblobname -Context $ctx -ErrorAction SilentlyContinue
        if (-not $dupeblob) {

            # Upload the temp file to blob storage
            $setAzStorageBlobContentSplat = @{
                Container   = $containerName
                File        = $tempFile.FullName
                Blob        = $dupeblobname
                Context     = $ctx
                Properties  = @{
                    ContentType = 'text/plain'
                }
                ErrorAction = 'Stop'
            }
            Write-CustomLog "Blob $blobName exists. Uploading as $dupeblobname"

        } else {
            $setAzStorageBlobContentSplat = @{}
            Write-CustomLog "Blob $dupeblobname exists. Skipping."
        }
    } else {

        # Upload the temp file to blob storage
        $setAzStorageBlobContentSplat = @{
            Container   = $containerName
            File        = $tempFile.FullName
            Blob        = $blobName
            Context     = $ctx
            Properties  = @{
                ContentType = 'text/plain'
            }
            ErrorAction = 'Stop'
        }
        Write-CustomLog "Blob $blobName will be created."

    }
}
try {
    if ($setAzStorageBlobContentSplat.Keys.count -ne 0) {
        Write-CustomLog "Write activity to blob storage using" # {0}" -f ($setAzStorageBlobContentSplat | Out-String)
        Set-AzStorageBlobContent @setAzStorageBlobContentSplat | Out-Null
        return "data storage finishedfor $ActivityId"
    } else {
        Write-CustomLog "skipping set content"
        return "data storage finishedfor $ActivityId"
    }

} catch {
    Write-CustomLog "failed to set content using {0}" -f ($setAzStorageBlobContentSplat | Out-String)
    return "data storage finishedfor $ActivityId"
}

