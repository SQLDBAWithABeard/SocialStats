CREATE VIEW [dbo].[Follows_By_Day]
AS
SELECT 
    [displayName]
    ,CAST([collectionDate] AS Date) AS DateCollected
    ,[followsCount]
    ,[followsCount] - LAG([followsCount], 1, 0) OVER (PARTITION BY [displayName] ORDER BY CAST([collectionDate] AS Date)) AS DailyChangeInFollows
FROM 
    [dbo].[bskyStats]
GROUP BY 
    [displayName]
    ,CAST([collectionDate] AS Date)
    ,[followsCount]
