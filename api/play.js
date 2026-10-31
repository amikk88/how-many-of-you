// Serves the game page for links like /how-many-davids-gk2m9xqa,
// rewriting the title and preview text so the link preview says "How many Davids?".
const fs = require("fs");
const path = require("path");

const cap = w => w.charAt(0).toUpperCase() + w.slice(1);

module.exports = async (req, res) => {
  const slug = String((req.query && req.query.slug) || "").toLowerCase();
  const m = /^how-many-([a-z0-9-]{1,80})-(g[a-z0-9]{8})$/.exec(slug);
  const host = String(req.headers["x-forwarded-host"] || req.headers.host || "").split(",")[0].trim();
  const proto = String(req.headers["x-forwarded-proto"] || "https").split(",")[0].trim();
  const base = /^[a-z0-9.:-]+$/i.test(host) ? `${proto}://${host}` : "";

  let html = null;
  try { html = fs.readFileSync(path.join(process.cwd(), "index.html"), "utf8"); } catch (e) {}
  if (!html && base) {
    try { const r = await fetch(base + "/index.html"); if (r.ok) html = await r.text(); } catch (e) {}
  }
  if (!html) { res.statusCode = 302; res.setHeader("Location", "/"); return res.end(); }

  if (m) {
    const words = m[1].split("-").filter(Boolean);
    const phrase = words[0] === "people" && words[1] === "named"
      ? "people named " + words.slice(2).map(cap).join("-")
      : words.map(cap).join("-");
    const title = `How many ${phrase}?`;
    const desc = `Two quick guesses: are there more ${phrase} than people in a mystery city, state or country? Tap to play.`;
    html = html
      .replace("<title>How Many of You?</title>", `<title>${title}</title>`)
      .replace('<meta property="og:title" content="How Many of You?">', `<meta property="og:title" content="${title}">`)
      .replace(/(<meta (?:name="description"|property="og:description") content=")[^"]*(")/g, `$1${desc}$2`);
    if (base) html = html.replace('<meta property="og:type"', `<meta property="og:url" content="${base}/${slug}">\n<meta property="og:type"`);
  }
  if (base) html = html.replace('content="/og.png"', `content="${base}/og.png"`);

  res.statusCode = 200;
  res.setHeader("Content-Type", "text/html; charset=utf-8");
  res.setHeader("Cache-Control", "public, s-maxage=86400, stale-while-revalidate=604800");
  res.end(html);
};
