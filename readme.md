# Social Stats

This project is an Azure Function, written in PowerShell, that calls the bluesky api for a username and then stores the information in a SQL Database.

If you want to replicate this project you need some infra
- An Azure Function app - PowerShell - I'd set this up to use a managed identity
- An Azure SQL Database - and then add an app setting for `SqlConnectionString` with the details
    - the Function Managed Identity needs write access to the database
- Change the username in the API call within `run.ps` for the one you want to monitor
    - I will update this to be more dynamic at some point, and provide the option of passing in more than one.

