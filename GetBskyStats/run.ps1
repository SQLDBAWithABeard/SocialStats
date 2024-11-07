using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$stats = Invoke-RestMethod -Uri "https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=jpomfret.bsky.social" -Method GET |
Select-Object -property handle, displayName, avatar, createdAt, description, indexedAt, banner, followersCount, followsCount, postsCount

# {
#     "did": "did:plc:b4wi5dqywlknrgg7ofmczq2z",
#     "handle": "jpomfret.bsky.social",
#     "displayName": "Jess Pomfret",
#     "avatar": "https://cdn.bsky.app/img/avatar/plain/did:plc:b4wi5dqywlknrgg7ofmczq2z/bafkreihtiskntmngb7q4um2tmxs553h4z3kawxeuue3set5oqfhllmndeu@jpeg",
#     "associated": {
#         "lists": 1,
#         "feedgens": 0,
#         "starterPacks": 0,
#         "labeler": false
#     },
#     "labels": [],
#     "createdAt": "2023-08-14T15:58:44.594Z",
#     "description": "Database Engineer with a passion for automation, proper football and fitness. She/Her.",
#     "indexedAt": "2024-01-20T05:24:20.405Z",
#     "banner": "https://cdn.bsky.app/img/banner/plain/did:plc:b4wi5dqywlknrgg7ofmczq2z/bafkreifvg7zbvqi3nsyz6gmla5yv2exneajded7fzmoz2qtwhfkkwhshly@jpeg",
#     "followersCount": 278,
#     "followsCount": 242,
#     "postsCount": 167
# }


# CREATE TABLE dbo.bskyStats (
#     collectionId INT IDENTITY(1,1) PRIMARY KEY,
#     collectionDate DATETIME DEFAULT GETDATE(),
#     handle VARCHAR(50),
#     displayName VARCHAR(50),
#     avatar VARCHAR(255),
#     createdAt DATETIME,
#     description VARCHAR(255),
#     indexedAt DATETIME,
#     banner VARCHAR(255),
#     followersCount INT,
#     followsCount INT,
#     postsCount INT
# )

# Update req_body with the body of the request


# Assign the value we want to pass to the SQL Output binding. 
# The -Name value corresponds to the name property in the function.json for the binding
Push-OutputBinding -Name socialstats -Value $stats


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $stats
})
