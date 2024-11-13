using namespace System.Net

# Input bindings are passed in via param block.
param($dailyTimer)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$stats = Invoke-RestMethod -Uri "https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=jpomfret.co.uk" -Method GET |
Select-Object -property handle, displayName, avatar, createdAt, description, indexedAt, banner, followersCount, followsCount, postsCount

$stats

# Assign the value we want to pass to the SQL Output binding. 
# The -Name value corresponds to the name property in the function.json for the binding
Push-OutputBinding -Name socialstats -Value $stats

