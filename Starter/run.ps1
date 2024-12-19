using namespace System.Net

param($Request, $TriggerMetadata)

$FunctionName = 'Orchestrator' # $Request.Params.FunctionName
$InstanceId = Start-DurableOrchestration -FunctionName $FunctionName -Input 'context'
Write-Output "Started orchestration with ID = '$InstanceId'"

