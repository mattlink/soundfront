-- Soundfront.CreateAlbum
--	Creates an Album
CREATE OR ALTER PROCEDURE Soundfront.CreateAlbum
	@UserId INT,
	@Title NVARCHAR(50),
	@AlbumArt NVARCHAR(256),
	@Price DECIMAL,
	@Description NVARCHAR(1024)
AS
BEGIN
	SET NOCOUNT ON
	INSERT Soundfront.Album(UserID, Title, AlbumArt, Price, [Description])
	OUTPUT Inserted.AlbumID, Inserted.Title, Inserted.AlbumArt, Inserted.Price, Inserted.Description, Inserted.UserID
	VALUES
		(@UserId, @Title, @AlbumArt, @Price, @Description)
END

GO

-- Soundfront.CreateAlbumWithDate
-- 	Creates an Album with a specified UploadDate
CREATE OR ALTER PROCEDURE Soundfront.CreateAlbumWithDate
	@UserID INT,
	@Title NVARCHAR(50),
	@AlbumArt NVARCHAR(256),
	@Price DECIMAL,
	@Description NVARCHAR(1024),
	@UploadDate DATETIME
AS
BEGIN
	SET NOCOUNT ON
	INSERT Soundfront.Album(UserID, Title, AlbumArt, Price, [Description], UploadDate)
	OUTPUT Inserted.AlbumID, Inserted.Title, Inserted.AlbumArt, Inserted.Price, Inserted.Description, Inserted.UploadDate, Inserted.UserID
	VALUES
		(@UserID, @Title, @AlbumArt, @Price, @Description, @UploadDate)
END

GO

-- Soundfront.GetAlbum
-- Get a single Album given its ID
CREATE OR ALTER PROCEDURE Soundfront.GetAlbum
	@AlbumID INT
AS

SELECT A.AlbumID, A.UserID, A.Title, A.AlbumArt, A.Price, A.UploadDate, A.[Description], U.DisplayName
FROM Soundfront.Album A
	INNER JOIN Soundfront.[User] U ON U.UserID = A.UserID
WHERE A.AlbumID = @AlbumID
GO

-- Soundfront.DeleteAlbum
-- Deletes an album
CREATE OR ALTER PROCEDURE Soundfront.DeleteAlbum
	@AlbumID INT
AS

DELETE FROM Soundfront.Album
WHERE AlbumID = @AlbumID
GO

-- Soundfront.ListAlbumSongs
-- Lists all Songs from an Album
CREATE OR ALTER PROCEDURE Soundfront.ListAlbumSongs
	@AlbumID INT
AS

SELECT A.AlbumID, A.Title AS AlbumTitle, S.Title, A.AlbumArt, S.[Length], S.Price, S.UploadDate, U.DisplayName as Artist, U.UserID, S.SongID
FROM Soundfront.Album A
	INNER JOIN Soundfront.Song S ON S.AlbumID = A.AlbumID
    INNER JOIN Soundfront.[User] U ON U.UserID = A.UserID
WHERE A.AlbumID = @AlbumID
ORDER BY S.SongID
GO

-- Soundfront.GetTopRatedAlbums
--	Gets the top 5 highest rated album in the past @TimeFrameInDays days.
CREATE OR ALTER PROCEDURE Soundfront.GetTopRatedAlbums
	@TimeFrameInDays INT
AS

SELECT TOP 5
	A.AlbumID, U.DisplayName, A.Title, A.AlbumArt, A.Price, AVG(AR.Rating) AS "Average Rating"
FROM Soundfront.AlbumRating AR
    INNER JOIN Soundfront.Album A ON A.AlbumID = AR.AlbumID
    INNER JOIN Soundfront.[User] U ON U.UserID = A.UserID
WHERE DATEDIFF(DAY, A.UploadDate, SYSDATETIMEOFFSET()) < @TimeFrameInDays
GROUP BY A.AlbumID, U.DisplayName, A.Title, A.AlbumArt, A.Price
ORDER BY AVG(AR.Rating) DESC, A.Price DESC

GO

-- Soundfront.ListAlbums
-- Lists Albums ordered by most recent
CREATE OR ALTER PROCEDURE Soundfront.ListAlbums
	@Page INT,
	@PageSize INT
AS
BEGIN
	SET NOCOUNT ON
	SELECT A.AlbumID, A.UserID, A.Title, A.AlbumArt, U.DisplayName
	FROM Soundfront.Album A
		INNER JOIN Soundfront.[User] U ON A.UserID = U.UserID
	ORDER BY A.UploadDate DESC
	OFFSET ((@Page * @PageSize) - @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
END

GO

-- Soundfront.ListAlbumsByUser
-- Lists all Albums by a User
CREATE OR ALTER PROCEDURE Soundfront.ListAlbumsByUser
	@UserID INT
AS

SELECT A.AlbumID, A.UserID, A.Title, A.AlbumArt, A.Price, A.UploadDate, A.[Description]
FROM Soundfront.Album A
WHERE A.UserID = @UserID
ORDER BY A.UploadDate DESC;
GO

-- Soundfront.SearchForAlbum
-- Search for album
CREATE OR ALTER PROCEDURE Soundfront.SearchForAlbum
	@Search NVARCHAR(100)
AS

SELECT TOP(10) *
FROM Soundfront.Album A
WHERE A.Title LIKE @Search
ORDER BY A.Title
GO

-- Soundfront.ListSimilarAlbums
-- Lists albums with similar Tags
CREATE OR ALTER PROCEDURE Soundfront.ListSimilarAlbums
	@AlbumID INT
AS
WITH TagCountCTE(AlbumID, SharedTagCount) AS (
    SELECT TOP 5 SS.AlbumID, COUNT(*) as SharedTagCount
    FROM Soundfront.SongTag IST
        INNER JOIN Soundfront.SongTag SST ON SST.TagID = IST.TagID
        INNER JOIN Soundfront.Song S ON S.SongID = IST.SongID
        INNER JOIN Soundfront.Song SS ON SS.SongID = SST.SongID
    WHERE S.AlbumID = @AlbumID AND SS.AlbumID != @AlbumID
    GROUP BY SS.AlbumID
    ORDER BY COUNT(*) DESC
)
SELECT DISTINCT S.AlbumID, T.Name, TC.SharedTagCount, A.Title, A.AlbumID, T.TagID
FROM TagCountCTE TC
    INNER JOIN Soundfront.Song S ON S.AlbumID = TC.AlbumID
    INNER JOIN Soundfront.SongTag ST ON ST.SongID = S.SongID
    INNER JOIN Soundfront.Tag T on T.TagID = ST.TagID
		INNER JOIN Soundfront.Album A ON S.AlbumID = A.AlbumID
ORDER BY TC.SharedTagCount DESC
