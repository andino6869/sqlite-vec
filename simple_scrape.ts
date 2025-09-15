import { Database } from "jsr:@db/sqlite@0.11";
import { parseHTML } from "npm:linkedom";
import * as d3 from "npm:d3-time";

const months = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"];

class Db {
  db: Database;

  constructor(path: string) {
    this.db = new Database(path);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS articles(
        id integer primary key autoincrement,
        year integer,
        month integer,
        headline TEXT,
        url TEXT
      )
    `);
  }

  insertArticles(year: number, month: string, articles: {headline: string, url: string}[]) {
    const stmt = this.db.prepare(`
      INSERT INTO articles(year, month, headline, url)
      VALUES (?, ?, ?, ?)
    `);

    const monthNum = months.findIndex(m => m === month) + 1;

    this.db.transaction(() => {
      for(const article of articles) {
        stmt.run(year, monthNum, article.headline, article.url);
      }
    })();

    stmt.finalize();
  }
}

async function insertMonth(db: Db, year: number, month: string) {
  let url = `https://www.nbcnews.com/archive/articles/${year}/${month}`;
  while(true) {
    console.log(`Scraping ${url}...`);
    try {
      const monthPage = await fetch(url).then(r => r.text());
      const {document: monthPageDoc} = parseHTML(monthPage);
      const monthEntries = Array.from(monthPageDoc.querySelectorAll('.MonthPage a'))
        .map(a => ({
          headline: a.textContent?.trim() || '',
          url: a.getAttribute('href') || ''
        }))
        .filter(entry => entry.headline && entry.url);

      console.log(`Found ${monthEntries.length} articles for ${year}/${month}`);

      if (monthEntries.length > 0) {
        db.insertArticles(year, month, monthEntries);
      }

      const next = monthPageDoc.querySelector('a.Pagination__next.Pagination__enable');
      if(!next) {
        break;
      }
      const nextHref = next.getAttribute('href');
      if (!nextHref) {
        break;
      }
      url = `https://www.nbcnews.com${nextHref}`;
    } catch (error) {
      console.error(`Error scraping ${url}:`, error);
      break;
    }
  }
}

async function backfill(db: Db, start: Date, end: Date) {
  const targets = d3.timeMonths(start, end)
    .map(date => ({year: date.getFullYear(), monthIndex: date.getMonth()}));

  for(const target of targets) {
    console.log(`Processing ${target.year} ${target.monthIndex} (${months[target.monthIndex]})`);
    await insertMonth(db, target.year, months[target.monthIndex]);
  }
}

// Main execution
console.log("Starting NBC Headlines scraper...");
const db = new Db(":memory:");
await backfill(db, new Date('2024-01-01'), new Date());
console.log("Saving to headlines-2024.db...");
db.db.exec("VACUUM INTO 'headlines-2024.db'");
console.log("Done! Check headlines-2024.db for the scraped data.");