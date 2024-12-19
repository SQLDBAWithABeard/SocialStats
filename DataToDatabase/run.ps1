param($activity)

if ($activity -eq "No new activities found") {
    $output = "Nothing to process for DataToDatabase"
} else {

    $output = "DataToDatabase is processing activity {0}" -f $activity
}

$output