import { Database } from "jsr:@db/sqlite@0.11";

const db = new Database("headlines-2024.db");

console.log("Database contents:");
console.log("==================");

// Count total articles
const countResult = db.prepare("SELECT COUNT(*) as count FROM articles").get();
console.log(`Total articles: ${countResult.count}`);

// Show some sample articles
console.log("\nSample articles:");
const samples = db.prepare("SELECT year, month, headline FROM articles LIMIT 10").all();
for (const article of samples) {
  console.log(`${article.year}/${article.month}: ${article.headline}`);
}

// Show articles by month
console.log("\nArticles by month:");
const byMonth = db.prepare(`
  SELECT year, month, COUNT(*) as count
  FROM articles
  GROUP BY year, month
  ORDER BY year, month
`).all();

for (const row of byMonth) {
  console.log(`${row.year}/${row.month.toString().padStart(2, '0')}: ${row.count} articles`);
}

db.close();