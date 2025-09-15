-- Create FTS5 index for full-text search
CREATE VIRTUAL TABLE fts_articles USING fts5(
  headline,
  content='articles',
  content_rowid='id'
);

-- Insert data into FTS5 table
INSERT INTO fts_articles(rowid, headline)
  SELECT rowid, headline
  FROM articles;

-- Optimize the FTS5 table
INSERT INTO fts_articles(fts_articles) VALUES('optimize');

-- Test the FTS5 index
.mode column
.headers on

SELECT 'FTS5 Test Results:' as test;
SELECT COUNT(*) as indexed_articles FROM fts_articles;

SELECT headline
FROM fts_articles
WHERE headline MATCH 'planned parenthood'
LIMIT 5;