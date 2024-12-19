# Input bindings are passed in via param block.
param($name, $TokenTable, $SyncTokenTable)

# Constants
$STRAVA_BASE_URL = "https://www.strava.com/api/v3"
$MAX_CALLS_PER_MINUTE = 5
$ACTIVITY_TYPES = @('Run', 'Ride', 'VirtualRide', 'EBikeRide', 'Walk')


function Get-NewAccessToken {
    param (
        [string]$RefreshToken
    )

    try {
        $tokenUrl = "https://www.strava.com/oauth/token"
        $body = @{
            client_id     = $env:STRAVA_CLIENT_ID
            client_secret = $env:STRAVA_CLIENT_SECRET
            refresh_token = $RefreshToken
            grant_type    = "refresh_token"
        }

        $restParams = @{
            Uri    = $tokenUrl
            Method = 'Post'
            Body   = $body
        }

        $response = Invoke-RestMethod @restParams

        # Store new tokens in Azure Table
        $tokenEntity = @{
            PartitionKey = "StravaTokens"
            RowKey       = "CurrentToken"
            AccessToken  = $response.access_token
            RefreshToken = $response.refresh_token
            ExpiresAt    = $response.expires_at
        }
        $ctx = New-AzDataTableContext -ConnectionString $env:StravaAzureStorageConnection -TableName "StravaTokens"
        $tokenEntity = Get-AzDataTableEntity -Context $ctx  -Filter "RowKey eq 'CurrentToken'"

        $tokenEntity.AccessToken = $response.access_token
        $tokenEntity.RefreshToken = $response.refresh_token
        $tokenEntity.ExpiresAt = $response.expires_at
        Update-AzDataTableEntity -Context $ctx -Entity $tokenEntity -Force

        return $response.access_token
    } catch {
        Write-CustomLog "Failed to refresh access token: $_" -Level "Error"
        throw
    }
}

function Get-ActivitySplits {
    param (
        [string]$ActivityId,
        [string]$AccessToken
    )

    Write-CustomLog "Getting split information for [$ActivityId]"

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
    }

    $restParams = @{
        Uri     = "$STRAVA_BASE_URL/activities/$ActivityId"
        Headers = $headers
        Method  = 'Get'
    }

    try {
        $response = Invoke-RestMethod @restParams

        if ($null -eq $response.splits_metric) {
            return $null
        }

        $splits = $response.splits_metric | ForEach-Object {
            $_ | Add-Member -NotePropertyName 'activity_id' -NotePropertyValue $ActivityId
            $_ | Add-Member -NotePropertyName 'activity_date' -NotePropertyValue $response.start_date
            $_
        }

        # Filter splits that are approximately 1km
        $splits = $splits | Where-Object {
            $_.distance -gt 950 -and $_.distance -lt 1050
        }

        return $splits
    } catch {
        Write-CustomLog "Error getting splits for activity $ActivityId : $_" -Level "Error"
        return $null
    }
}

function Get-StravaActivities {
    param (
        [string]$AccessToken,
        [datetime]$After,
        [int]$PerPage = 25,
        [int]$MaxPages = 2
    )

    $activities = @()
    $page = 1
    $unixTime = [int][double]::Parse((Get-Date $After  -UFormat %s))

    while ($page -le $MaxPages) {
        Write-CustomLog "Checking for activities on page [$page]"

        $restParams = @{
            Uri     = "$STRAVA_BASE_URL/athlete/activities"
            Headers = @{ Authorization = "Bearer $AccessToken" }
            Method  = 'Get'
            Body    = @{
                'per_page' = $PerPage
                'page'     = $page
                'after'    = $unixTime
            }
        }

        try {
            $response = Invoke-RestMethod @restParams

            if ($response.Count -eq 0) {
                Write-CustomLog "No more activities found"
                break
            }

            foreach ($activity in $response) {
                if ($activity.type -in $ACTIVITY_TYPES) {
                    Write-CustomLog "Found activity id $($activity.id), type $($activity.type)"

                    # Get splits for the activity
                    $splits = Get-ActivitySplits -ActivityId $activity.id -AccessToken $AccessToken

                    # Add splits to activity object if they exist
                    if ($splits) {
                        $activity | Add-Member -NotePropertyName 'splits' -NotePropertyValue $splits
                    }

                    $activities += $activity
                } else {
                    Write-CustomLog "Activity type $($activity.type) is not processed"
                }
            }

            Start-Sleep -Seconds 10  # Rate limiting
            $page++
        } catch {
            Write-CustomLog "Error retrieving activities: $_" -Level "Error"
            break
        }
    }

    return $activities
}


# Main execution
try {
     Write-CustomLog "Starting Strava activity sync"

    # Get current tokens

    $tokens = $TokenTable

    # Check if token refresh is needed
    $currentTime = [int][double]::Parse((Get-Date -UFormat %s))
    if ($tokens.ExpiresAt -lt $currentTime) {
         Write-CustomLog "Refreshing access token"
        $accessToken = Get-NewAccessToken -RefreshToken $tokens.RefreshToken
    } else {
         Write-CustomLog "Getting access token from storage"
        $accessToken = $tokens.AccessToken
    }

    # Get last sync time from storage

     Write-CustomLog "Getting Last sync time"
    $lastSync = [datetime]$SyncTokenTable.LastSyncTime

    $lastSyncTime = if ($lastSync) {
         Write-CustomLog "Last Sync Time found: $lastSync"
        [datetime]$lastSync
    } else {
         Write-CustomLog "No Last Sync Time so defaulting to yesterday"
        [datetime]::Now.AddDays(-1)
    }

    # Get activities
    $activityParams = @{
        AccessToken = $accessToken
        After       = $lastSyncTime
    }
     Write-CustomLog "Getting Activites"

    $activities = Get-StravaActivities @activityParams

    if ($activities.Count -gt 0) {
         Write-CustomLog "Found $($activities.Count) new activities"
        return $activities

    } else {
        return "No new activities found"
    }
} catch {

   #  Write-CustomLog "Error in main execution: $_" -Level "Error"
    throw
}


