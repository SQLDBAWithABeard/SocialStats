CREATE TABLE [dbo].[bskyStats] (
    [collectionId]   INT           IDENTITY (1, 1) NOT NULL,
    [collectionDate] DATETIME      DEFAULT (getdate()) NULL,
    [handle]         VARCHAR (50)  NULL,
    [displayName]    VARCHAR (50)  NULL,
    [avatar]         VARCHAR (255) NULL,
    [createdAt]      DATETIME      NULL,
    [description]    VARCHAR (255) NULL,
    [indexedAt]      DATETIME      NULL,
    [banner]         VARCHAR (255) NULL,
    [followersCount] INT           NULL,
    [followsCount]   INT           NULL,
    [postsCount]     INT           NULL,
    PRIMARY KEY CLUSTERED ([collectionId] ASC)
);
GO

