-- Complete NBC Headlines Demo - Replicating notebook functionality
.load /home/andy/New-Projects/sqlite-vec/dist/vec0.so
.mode column
.headers on

-- ========================================
-- Part 1: Database Overview
-- ========================================
.print "=== NBC Headlines Database Overview ==="
SELECT
    COUNT(*) as total_articles,
    MIN(year) as earliest_year,
    MAX(year) as latest_year,
    COUNT(DISTINCT year || '-' || month) as total_months
FROM articles;

.print ""
.print "Articles by month (first 12 months):"
SELECT
    printf('%04d-%02d', year, month) as month,
    COUNT(*) as articles
FROM articles
GROUP BY year, month
ORDER BY year, month
LIMIT 12;

-- ========================================
-- Part 2: FTS5 Full-Text Search
-- ========================================
.print ""
.print "=== FTS5 Full-Text Search Examples ==="

.print ""
.print "Search: 'planned parenthood'"
SELECT headline
FROM fts_articles
WHERE headline MATCH 'planned parenthood'
LIMIT 5;

.print ""
.print "Search: 'abortion ban'"
SELECT headline
FROM fts_articles
WHERE headline MATCH 'abortion ban'
LIMIT 5;

.print ""
.print "Search: 'climate change'"
SELECT headline
FROM fts_articles
WHERE headline MATCH 'climate change'
LIMIT 3;

-- ========================================
-- Part 3: sqlite-vec Capabilities Demo
-- ========================================
.print ""
.print "=== sqlite-vec Extension Demo ==="
.print "Extension version:"
SELECT vec_version() as sqlite_vec_version;

-- Demonstrate vec0 virtual table creation (structure only)
.print ""
.print "Creating example vector table structure..."

-- Create a demonstration vector table
CREATE VIRTUAL TABLE demo_vectors USING vec0(
    article_id INTEGER PRIMARY KEY,
    sample_embedding FLOAT[3]  -- Small 3D vectors for demo
);

-- Insert some sample vectors to demonstrate functionality
INSERT INTO demo_vectors(article_id, sample_embedding) VALUES
    (1, '[0.1, 0.5, 0.8]'),
    (2, '[0.7, 0.2, 0.6]'),
    (3, '[0.4, 0.9, 0.3]'),
    (4, '[0.8, 0.1, 0.7]'),
    (5, '[0.2, 0.6, 0.9]');

.print "Sample vectors inserted:"
SELECT article_id, sample_embedding FROM demo_vectors;

.print ""
.print "Demonstrating KNN search (finding 3 nearest to [0.5, 0.5, 0.5]):"
SELECT
    article_id,
    vec_distance_l2(sample_embedding, '[0.5, 0.5, 0.5]') as distance
FROM demo_vectors
WHERE sample_embedding MATCH '[0.5, 0.5, 0.5]' AND k = 3
ORDER BY distance;

-- Clean up demo table
DROP TABLE demo_vectors;

-- ========================================
-- Part 4: Combined Search Possibilities
-- ========================================
.print ""
.print "=== Hybrid Search Potential ==="
.print "With embeddings, you could combine:"
.print "1. FTS5 keyword search (exact matches)"
.print "2. Vector similarity search (semantic matches)"
.print ""
.print "Example workflow would be:"
.print "- Create embeddings for all headlines using an AI model"
.print "- Store embeddings in vec0 virtual table"
.print "- Combine FTS5 and vector results for better search"

-- ========================================
-- Part 5: Sample Advanced Queries
-- ========================================
.print ""
.print "=== Advanced FTS5 Query Examples ==="

.print ""
.print "Boolean search - Trump AND (election OR campaign):"
SELECT headline
FROM fts_articles
WHERE headline MATCH 'Trump AND (election OR campaign)'
LIMIT 5;

.print ""
.print "Phrase search - \"Supreme Court\":"
SELECT headline
FROM fts_articles
WHERE headline MATCH '"Supreme Court"'
LIMIT 5;

.print ""
.print "Prefix search - climat*:"
SELECT headline
FROM fts_articles
WHERE headline MATCH 'climat*'
LIMIT 3;

-- ========================================
-- Summary
-- ========================================
.print ""
.print "=== Summary ==="
.print "✅ SQLite environment: Ready"
.print "✅ FTS5 full-text search: Working"
.print "✅ sqlite-vec extension: Loaded"
.print "⏳ Embeddings: Requires sqlite-lembed or external embedding generation"
.print ""
.print "Your database is ready for:"
.print "- Full-text search with FTS5"
.print "- Vector operations with sqlite-vec"
.print "- Hybrid search once embeddings are added"