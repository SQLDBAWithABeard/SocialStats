CREATE VIEW [dbo].[Useful_View]
AS
SELECT 
    [displayName]
    ,CAST([collectionDate] AS Date) AS DateCollected
    ,[followersCount]
    ,[followsCount]
    ,[postsCount]
    ,[followersCount] - LAG([followersCount], 1, 0) OVER (PARTITION BY [displayName] ORDER BY CAST([collectionDate] AS Date)) AS DailyChangeInFollowers
    ,[postsCount] - LAG([postsCount], 1, 0) OVER (PARTITION BY [displayName] ORDER BY CAST([collectionDate] AS Date)) AS DailyChangeInposts
    ,[followsCount] - LAG([followsCount], 1, 0) OVER (PARTITION BY [displayName] ORDER BY CAST([collectionDate] AS Date)) AS DailyChangeInFollows
FROM 
    [dbo].[bskyStats]
GROUP BY 
    [displayName], 
    CAST([collectionDate] AS Date), 
    [followersCount], 
    [followsCount], 
    [postsCount]
GO

