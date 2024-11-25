CREATE VIEW [dbo].[Followers_By_Day]
AS
SELECT 
    [displayName]
    ,CAST([collectionDate] AS Date) AS DateCollected
    ,[followersCount]
    ,[followersCount] - LAG([followersCount], 1, 0) OVER (PARTITION BY [displayName] ORDER BY CAST([collectionDate] AS Date)) AS DailyChangeInFollowers
FROM 
    [dbo].[bskyStats]
GROUP BY 
    [displayName] 
    ,CAST([collectionDate] AS Date)
    ,[followersCount]
GO