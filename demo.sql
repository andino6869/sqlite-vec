-- NBC News Headlines Demo with FTS5 and sqlite-vec
.load /home/andy/New-Projects/sqlite-vec/dist/vec0.so

.mode column
.headers on
.width 60 20

-- Show database stats
SELECT 'Database Overview' as section;
SELECT COUNT(*) as total_articles,
       MIN(year) as earliest_year,
       MAX(year) as latest_year
FROM articles;

-- Show articles by month
SELECT year, month, COUNT(*) as articles
FROM articles
GROUP BY year, month
ORDER BY year, month
LIMIT 10;

-- Test FTS5 search
SELECT 'FTS5 Full-Text Search Demo' as section;

-- Search for "climate change"
SELECT headline
FROM fts_articles
WHERE headline MATCH 'climate change'
LIMIT 5;

-- Search for "Trump election"
SELECT headline
FROM fts_articles
WHERE headline MATCH 'Trump election'
LIMIT 5;

-- Search for "Biden administration"
SELECT headline
FROM fts_articles
WHERE headline MATCH 'Biden administration'
LIMIT 5;

-- Show the sqlite-vec version
SELECT 'sqlite-vec Extension Info' as section;
SELECT vec_version() as version;

-- Example of creating a simple vec0 table (without embeddings for now)
-- This demonstrates the table structure that would be used with embeddings
CREATE VIRTUAL TABLE IF NOT EXISTS example_vectors USING vec0(
  article_id INTEGER PRIMARY KEY,
  dummy_vector FLOAT[5]  -- Small demo vector
);

-- Insert some dummy vectors to show the structure
INSERT INTO example_vectors(article_id, dummy_vector)
VALUES
  (1, '[1.0, 0.5, 0.2, 0.8, 0.3]'),
  (2, '[0.7, 1.0, 0.4, 0.1, 0.9]'),
  (3, '[0.3, 0.2, 1.0, 0.6, 0.5]');

-- Show the dummy vectors
SELECT 'Example Vector Table' as section;
SELECT article_id, dummy_vector FROM example_vectors;

-- Clean up
DROP TABLE example_vectors;