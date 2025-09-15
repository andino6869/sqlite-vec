import { Database, Statement } from "jsr:@db/sqlite@0.11";
import { parseHTML } from "npm:linkedom";
import * as d3 from "npm:d3-time";
import * as sqlitePath from "npm:sqlite-path";
import * as sqliteUrl from "npm:sqlite-url";
import * as sqliteRegex from "npm:sqlite-regex";

const months = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"];

class Db {
  db: Database;
  #stmtInsertArticle: Statement;

  constructor(path: string) {
    this.db = new Database(path);
    this.db.enableLoadExtension = true;
    this.db.loadExtension(sqlitePath.getLoadablePath());
    this.db.loadExtension(sqliteUrl.getLoadablePath());
    this.db.loadExtension(sqliteRegex.getLoadablePath());
    this.db.enableLoadExtension = false;

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS articles(
        id integer primary key autoincrement,
        year integer,
        month integer,
        slug TEXT,
        slug_id TEXT,
        headline TEXT,
        url TEXT,
        category1 TEXT,
        category2 TEXT
      )
    `);

    this.#stmtInsertArticle = this.db.prepare(`
      insert into articles(year, month, slug, slug_id, headline, url, category1, category2)
      select
        :year as year,
        :month as month,
         regex_capture(
          '(?P<slug>.+)-(?P<id>[^-]+)$',
          path_at(url_path(:url), -1),
          'slug'
        ) as slug,
        regex_capture(
          '(?P<slug>.+)-(?P<id>[^-]+)$',
          path_at(url_path(:url), -1),
          'id'
        ) as slug_id,
        :headline as headline,
        :url as url,
        path_at(url_path(:url), 0) as category1,
        iif(
          path_length(url_path(:url)) > 2,
          path_at(url_path(:url), 1),
          null
        ) as category2
    `);
  }

  insertArticles(year: number, month: string, articles: {headline: string, url: string}[]) {
    const tx = this.db.transaction((year: number, month: number, articles: {headline: string, url: string}[]) => {
      for(const article of articles) {
        this.#stmtInsertArticle.run({...article, year, month});
      }
    });
    tx(year, months.findIndex(m => m === month) + 1, articles);
  }
}

async function insertMonth(db: Db, year: number, month: string) {
  let url = `https://www.nbcnews.com/archive/articles/${year}/${month}`;
  while(true) {
    console.log(`Scraping ${url}...`);
    const monthPage = await fetch(url).then(r => r.text());
    const {document: monthPageDoc} = parseHTML(monthPage);
    const monthEntries = monthPageDoc
      .querySelectorAll('.MonthPage a')
      .map(a => ({headline: a.innerText, url: a.getAttribute('href')}));

    console.log(`Found ${monthEntries.length} articles for ${year}/${month}`);
    db.insertArticles(year, month, monthEntries);

    const next = monthPageDoc.querySelector('a.Pagination__next.Pagination__enable');
    if(!next) {
      break;
    }
    url = `https://www.nbcnews.com${next.getAttribute('href')}`;
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
db.db.exec("vacuum into 'headlines-2024.db'");
console.log("Done!");