# Social Stats

This project is an Azure Function, written in PowerShell, that calls the bluesky api for a username and then stores the information in a SQL Database.

If you want to replicate this project you need some infra
- An Azure Function app - PowerShell - I'd set this up to use a managed identity

- An Azure SQL Database - There is a SQL Project that you can use to deploy the database in the repository, although it is just a single table.

- An Azure Function App setting for `SqlConnectionString` with the details of the database. We suggest using

`Server=tcp:>>YOURAZURE SQLSERVERNAME<<.database.windows.net,1433;Authentication=Active Directory Managed Identity; Database=>>YOURDATABASENAME<<; ConnectRetryCount=10;ConnectTimeout=60`

- the Function Managed Identity needs write access to the database

- Change the usernames in the API call within `run.ps` for the one you want to monitor

## TODO
I will update this to be more dynamic at some point, and provide the option of passing in more than one.

## Table Code

If you just need the table code, the database should contain a table like so:

```sql
CREATE TABLE dbo.bskyStats (
[collectionId] INT IDENTITY(1,1) PRIMARY KEY,
[collectionDate] DATETIME DEFAULT GETDATE(),
[handle] VARCHAR(50),
[displayName] VARCHAR(50),
[avatar] VARCHAR(255),
[createdAt] DATETIME,
[description] VARCHAR(255),
[indexedAt] DATETIME,
[banner] VARCHAR(255),
[followersCount] INT,
[followsCount] INT,
[postsCount] INT
)
```

The database could also contain a view like so

```sql
CREATE VIEW dbUseful_View
AS
SELECT
[displayName]
,CAST([collectionDate] AS Date) AS DateCollected
,[followersCount]
,[followsCount]
,[postsCount]
FROM [dbo].[bskyStats]
GROUP BY
[displayName]
,CAST([collectionDate] AS Date)
,[followersCount]
,[followsCount],[postsCount]
```