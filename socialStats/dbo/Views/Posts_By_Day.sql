CREATE VIEW [dbo].[Posts_By_Day]
AS
SELECT 
    [displayName]
    ,CAST([collectionDate] AS Date) AS DateCollected
    ,[postsCount]
    ,[postsCount] - LAG([postsCount], 1, 0) OVER (PARTITION BY [displayName] ORDER BY CAST([collectionDate] AS Date)) AS DailyChangeInposts
FROM 
    [dbo].[bskyStats]
GROUP BY 
    [displayName], 
    CAST([collectionDate] AS Date), 
    [postsCount]
GO


