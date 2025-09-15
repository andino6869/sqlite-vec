-- NBC News Headlines: Building FTS5 + vec0 indexes
-- Open the database created by the scraper
.open headlines-2024.db

-- Step 1: Create a FTS5 index
create virtual table fts_articles using fts5(
  headline,
  content='articles', content_rowid='id'
);

insert into fts_articles(rowid, headline)
  select rowid, headline
  from articles;

insert into fts_articles(fts_articles) values('optimize');

-- Test FTS5 search
select *
from fts_articles
where headline match 'planned parenthood'
limit 10;

-- Step 2: Load sqlite-vec extension (you'll need to build this first)
-- .load ../../dist/vec0

-- Note: The following commands require sqlite-vec and sqlite-lembed extensions
-- which need to be built first. For now, we'll just create the FTS5 index.

-- Test query to see our data
select count(*) as total_articles from articles;
select year, month, count(*) as count from articles group by year, month order by year, month;