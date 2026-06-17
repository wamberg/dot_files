#!/usr/bin/env node
// Headless Obsidian daily-note generator.
//
// Obsidian's Templater plugin only runs inside the desktop GUI, so the headless
// sync client (`ob`) can't expand templates. This script reproduces, generically,
// what Obsidian does when it creates a daily note: it reads the vault's own
// daily-notes config + template and renders the note for a given date. It holds
// NO personal content of its own -- the template (with its private frontmatter,
// goals, weekday tasks) lives in the vault and is read at runtime. That keeps this
// public dotfiles script generic and the private content in the (private) vault.
//
// Supported template syntax:
//   {{date:FMT}} / {{time:FMT}} / {{title}}   (core daily-notes placeholders)
//   <%* js %>  <% expr %>  <%= expr %>          (Templater tags)
// with a `tp` shim covering tp.file.title and tp.date.now/tomorrow/yesterday --
// the subset a date-driven daily note needs. Exotic tp.* calls aren't supported;
// extend makeTp() if the template grows to use them.
//
// Usage: obsidian-diary-ensure.js [--dry-run] [--date YYYY-MM-DD ...]
//   no --date  -> ensures today AND tomorrow exist (the boot/daily-timer case)
//   --dry-run  -> print what would be written, touch nothing

const fs = require("fs");
const os = require("os");
const path = require("path");

// ---- moment-style date formatting (the only real "engine") -----------------
const MONTHS = ["January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December"];
const DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
  "Saturday"];
const pad = (n) => String(n).padStart(2, "0");
const ordinal = (n) => {
  const s = ["th", "st", "nd", "rd"], v = n % 100;
  return n + (s[(v - 20) % 10] || s[v] || s[0]);
};

function formatMoment(d, fmt) {
  const t = {
    YYYY: () => String(d.getFullYear()),
    YY: () => String(d.getFullYear()).slice(-2),
    MMMM: () => MONTHS[d.getMonth()],
    MMM: () => MONTHS[d.getMonth()].slice(0, 3),
    MM: () => pad(d.getMonth() + 1),
    M: () => String(d.getMonth() + 1),
    Do: () => ordinal(d.getDate()),
    DD: () => pad(d.getDate()),
    D: () => String(d.getDate()),
    dddd: () => DAYS[d.getDay()],
    ddd: () => DAYS[d.getDay()].slice(0, 3),
    HH: () => pad(d.getHours()),
    H: () => String(d.getHours()),
    mm: () => pad(d.getMinutes()),
    m: () => String(d.getMinutes()),
    ss: () => pad(d.getSeconds()),
    s: () => String(d.getSeconds()),
  };
  // [literal] escapes pass through; tokens ordered longest-first.
  const re = /\[([^\]]*)\]|YYYY|YY|MMMM|MMM|MM|M|Do|DD|D|dddd|ddd|HH|H|mm|m|ss|s/g;
  return fmt.replace(re, (m, lit) =>
    lit !== undefined ? lit : (t[m] ? t[m]() : m));
}

function parseMoment(str, fmt) {
  const map = { YYYY: "(\\d{4})", MM: "(\\d{2})", DD: "(\\d{2})", M: "(\\d{1,2})", D: "(\\d{1,2})" };
  const order = [];
  const reStr = fmt.replace(/YYYY|MM|DD|M|D/g, (tok) => { order.push(tok); return map[tok]; });
  const m = new RegExp("^" + reStr + "$").exec(str);
  if (!m) { const d = new Date(str); return isNaN(d) ? null : d; }
  let y = 1970, mo = 0, da = 1;
  order.forEach((tok, i) => {
    const v = +m[i + 1];
    if (tok === "YYYY") y = v; else if (tok[0] === "M") mo = v - 1; else da = v;
  });
  return new Date(y, mo, da);
}

const addDays = (d, n) => {
  const x = new Date(d);
  x.setDate(x.getDate() + (Number(n) || 0));
  return x;
};

// ---- Templater `tp` shim (date subset) -------------------------------------
function makeTp(baseDate, title) {
  return {
    file: { title },
    date: {
      now: (fmt = "YYYY-MM-DD", off = 0, ref = null, refFmt = "YYYY-MM-DD") => {
        let d = ref != null ? parseMoment(String(ref), refFmt) : baseDate;
        if (!d) d = baseDate;
        return formatMoment(addDays(d, off), fmt);
      },
      tomorrow: (fmt = "YYYY-MM-DD") => formatMoment(addDays(baseDate, 1), fmt),
      yesterday: (fmt = "YYYY-MM-DD") => formatMoment(addDays(baseDate, -1), fmt),
    },
  };
}

// ---- rendering --------------------------------------------------------------
function subBraces(s, baseDate, title, defFmt) {
  return s.replace(/\{\{\s*(date|time|title)\s*(?::\s*([^}]*?))?\s*\}\}/g,
    (m, kind, fmt) => {
      if (kind === "title") return title;
      const f = fmt || (kind === "date" ? (defFmt || "YYYY-MM-DD") : "HH:mm");
      return formatMoment(baseDate, f);
    });
}

// Minimal EJS-lite for Templater tags. `<%* %>` = statements (whole-line tags are
// slurped so they don't leave blank lines); `<% %>`/`<%= %>`/`<%~ %>` = output.
function renderEjs(tpl, tp) {
  let code = "let __o='';\n";
  const re = /<%(\*|=|~|-)?\s?([\s\S]*?)%>/g;
  let last = 0, m;
  while ((m = re.exec(tpl))) {
    let text = tpl.slice(last, m.index);
    const mod = m[1], body = m[2];
    last = re.lastIndex;
    if (mod === "*") {
      text = text.replace(/[ \t]+$/, "");          // drop indentation before tag
      code += "__o+=" + JSON.stringify(text) + ";\n" + body + "\n";
      if (tpl[last] === "\r" && tpl[last + 1] === "\n") last += 2;
      else if (tpl[last] === "\n") last += 1;        // drop the tag's own newline
    } else {
      code += "__o+=" + JSON.stringify(text) + ";\n__o+=(" + body + ");\n";
    }
  }
  code += "__o+=" + JSON.stringify(tpl.slice(last)) + ";\nreturn __o;";
  return new Function("tp", code)(tp);
}

function render(tpl, baseDate, title, defFmt) {
  let s = subBraces(tpl, baseDate, title, defFmt);
  s = renderEjs(s, makeTp(baseDate, title));
  return s.replace(/\n{3,}/g, "\n\n");             // tidy blank lines from slurp
}

// ---- main -------------------------------------------------------------------
function main() {
  const argv = process.argv.slice(2);
  const dryRun = argv.includes("--dry-run");
  const dates = [];
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--date") dates.push(argv[++i]);
  }

  const vault = process.env.OBSIDIAN_VAULT || path.join(os.homedir(), "dev/garden");
  let cfg = {};
  try {
    cfg = JSON.parse(fs.readFileSync(path.join(vault, ".obsidian/daily-notes.json"), "utf8"));
  } catch (e) {
    console.error(`! No daily-notes config in ${vault} (${e.code || e.message}); nothing to do.`);
    return 0;
  }
  const folder = cfg.folder || "";
  const fmt = cfg.format || "YYYY-MM-DD";
  if (!cfg.template) { console.error("! No template configured in daily-notes.json; skipping."); return 0; }
  const templatePath = path.join(vault, cfg.template + ".md");
  let tpl;
  try {
    tpl = fs.readFileSync(templatePath, "utf8");
  } catch (e) {
    console.error(`! Template not found: ${templatePath} (${e.code}); skipping.`);
    return 0;
  }

  // Default targets: today + tomorrow.
  let targets;
  if (dates.length) {
    targets = dates.map((s) => parseMoment(s, "YYYY-MM-DD")).filter(Boolean);
  } else {
    const today = new Date(); today.setHours(0, 0, 0, 0);
    targets = [today, addDays(today, 1)];
  }

  const dir = path.join(vault, folder);
  for (const date of targets) {
    const title = formatMoment(date, fmt);
    const dest = path.join(dir, title + ".md");
    if (fs.existsSync(dest)) { console.log(`= exists  ${folder}/${title}.md`); continue; }
    const out = render(tpl, date, title, fmt);
    if (dryRun) {
      console.log(`+ would create ${folder}/${title}.md:\n${out}\n---`);
    } else {
      fs.mkdirSync(dir, { recursive: true });
      fs.writeFileSync(dest, out);
      console.log(`+ created ${folder}/${title}.md`);
    }
  }
  return 0;
}

process.exit(main());
