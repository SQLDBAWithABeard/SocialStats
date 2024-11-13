# Social Stats

This project is an Azure Function, written in PowerShell, that calls the bluesky api for a username and then stores the information in a SQL Database.

If you want to replicate this project you need some infra
- An Azure Function app - PowerShell - I'd set this up to use a managed identity
- An Azure SQL Database - and then add an app setting for `SqlConnectionString` with the details
    - the Function Managed Identity needs write access to the database
    - the database should contain a table like so:
        ```sql
        CREATE TABLE dbo.bskyStats (
            collectionId INT IDENTITY(1,1) PRIMARY KEY,
            collectionDate DATETIME DEFAULT GETDATE(),
            handle VARCHAR(50),
            displayName VARCHAR(50),
            avatar VARCHAR(255),
            createdAt DATETIME,
            description VARCHAR(255),
            indexedAt DATETIME,
            banner VARCHAR(255),
            followersCount INT,
            followsCount INT,
            postsCount INT
        )
        ```
- Change the username in the API call within `run.ps` for the one you want to monitor
    - I will update this to be more dynamic at some point, and provide the option of passing in more than one.

