param($Context)

$activity1results = Invoke-DurableActivity -FunctionName 'GetData' -Input 'Start'
$message = "There are {0} activities" -f $activity1results.Count

Write-Information $message

foreach ($result in $activity1results) {
    if ($result -ne "No new activities found") {
        Write-CustomLog "Processing activity $($result.id)"

        Invoke-DurableActivity -FunctionName 'DataToStorage' -Input $result
        # Invoke-DurableActivity -FunctionName 'DataToDatabase' -Input @($result)
    }
}

if ($activity1results.start_date) {
    $startdates = $activity1results | Select-Object -ExpandProperty start_date
    $latest = $startdates | Sort-Object -Unique -Descending -Top 1
    Write-CustomLog "Latest activity is $latest from $startdates"

    Invoke-DurableActivity -FunctionName 'UpdateData' -Input $latest
} else {
    Write-CustomLog "No Start Date found"
}
