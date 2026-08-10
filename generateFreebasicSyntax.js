/*
 * Generates vim-freebasic/syntax/freebasic.vim from the FreeBASIC manual.
 *
 * Two passes over the manual:
 *
 *   1. Every "---- KeyPgXxx ----" page title gives the authoritative
 *      vocabulary. Nothing outside this set is ever emitted, so the file
 *      cannot contain a keyword that does not exist.
 *
 *   2. Every "---- CatPgXxx ----" page lists the keywords belonging to one
 *      documented category. That drives the highlight grouping, instead of
 *      someone deciding by hand which bucket LOBYTE belongs in.
 *
 * Keywords in the vocabulary that no category page claims are reported at
 * the end and land in a catch-all group, so nothing is silently dropped.
 *
 * Run: node scripts/generateFreebasicSyntax.js path/to/FreeBASIC_Manual.txt
 */

const fs = require("fs");
const path = require("path");

const manualPath =
  process.argv[2] || "/mnt/user-data/uploads/FreeBASIC_Manual.txt";

const raw = fs
  .readFileSync(manualPath, "utf8")
  .replace(/\r\n/g, "\n");

const lines = raw.split("\n");

// ---------------------------------------------------------------- pages
const pages = [];
lines.forEach((line, i) => {
  const m = /^-{10,}\s+(\S+)\s+----$/.exec(line);
  if (!m) {
    return;
  }
  let j = i + 1;
  while (j < lines.length && !lines[j].trim()) {
    j++;
  }
  pages.push({ slug: m.group ? m.group(1) : m[1], title: lines[j].trim(), line: i });
});

/** Normalises a page title into the words a user actually types. */
function wordsFromTitle(title) {
  let t = title.replace(/\s*\(.*?\)\s*$/, "").trim();
  t = t
    .replace(/\s+(Statement|Function|Directive|Overload|Intrinsic|Expression)$/i, "")
    .trim();

  if (!t) {
    return [];
  }

  // Symbolic operator pages contribute nothing to the keyword list.
  if (/^Operator\s*[^A-Za-z]/.test(t)) {
    return [];
  }

  const out = [];
  for (const part of t.split(/\.\.\./)) {
    for (const w of part.match(/[A-Za-z_][A-Za-z0-9_]*\$?/g) || []) {
      out.push(w.toUpperCase());
    }
  }
  return out;
}

// Prose words that appear in page titles but are not keywords.
const NOT_KEYWORDS = new Set(["TEMPORARY", "TYPES"]);

const vocabulary = new Set();
const directives = new Set();

for (const p of pages) {
  if (!p.slug.startsWith("KeyPg")) {
    continue;
  }

  const t = p.title.trim();
  if (/^[#$]/.test(t)) {
    directives.add(t.split(/[.\s]/)[0]);
    continue;
  }

  for (const w of wordsFromTitle(t)) {
    if (!NOT_KEYWORDS.has(w)) {
      vocabulary.add(w);
    }
  }
}

// ------------------------------------------------------------ categories
/** Category page slug -> vim highlight group. */
const CATEGORY_GROUP = {
  CatPgArray: "freebasicArrays",
  CatPgBits: "freebasicBitManipulation",
  CatPgConsole: "freebasicConsole",
  CatPgDate: "freebasicDateTime",
  CatPgError: "freebasicErrorHandling",
  CatPgFile: "freebasicFiles",
  CatPgMath: "freebasicMath",
  CatPgMemory: "freebasicMemory",
  CatPgOpsys: "freebasicShell",
  CatPgString: "freebasicString",
  CatPgThreading: "freebasicMultithreading",
  CatPgInput: "freebasicUserInput",
  CatPgGfx2D: "freebasicGraphics",
  CatPgGfxInput: "freebasicUserInput",
  CatPgGfxScreen: "freebasicGraphics",
  CatPgVariables: "freebasicDataTypes",
  CatPgUserDefTypes: "freebasicDataTypes",
  CatPgStdDataTypes: "freebasicDataTypes",
  CatPgCasting: "freebasicTypeCasting",
  CatPgControlFlow: "freebasicProgramFlow",
  CatPgProcedures: "freebasicFunctions",
  CatPgModularizing: "freebasicModularizing",
  CatPgPreProcess: "freebasicPreProcessor",
  CatPgCompilerSwitches: "freebasicCompilerSwitches",
  CatPgDddefines: "freebasicPredefined",
  CatPgOpIndex: "freebasicLogical",
};

/** Reads the keyword entries listed on one category page. */
function keywordsOnPage(startLine) {
  const out = new Set();

  for (let i = startLine + 1; i < lines.length; i++) {
    if (/^-{10,}\s+\S+\s+----$/.test(lines[i])) {
      break;
    }

    // Entries are indented three spaces; their descriptions six or more.
    const m = /^ {3}(\S.*)$/.exec(lines[i]);
    if (!m) {
      continue;
    }

    const entry = m[1].trim();

    // Skip sub-headings, which have no indented description under them and
    // read as prose. Keeping them would add words like "Defining Arrays".
    if (/^[A-Z][a-z]+ing\b/.test(entry) || /^Retrieving\b/.test(entry)) {
      continue;
    }

    for (const w of wordsFromTitle(entry)) {
      out.add(w);
    }
  }

  return out;
}

const groupOf = new Map();
const claimedBy = new Map();

for (const p of pages) {
  const group = CATEGORY_GROUP[p.slug];
  if (!group) {
    continue;
  }

  for (const w of keywordsOnPage(p.line)) {
    if (!vocabulary.has(w)) {
      continue; // prose picked up from a description line
    }
    // First category page to claim a keyword wins, which keeps the result
    // stable regardless of page order.
    if (!groupOf.has(w)) {
      groupOf.set(w, group);
      claimedBy.set(w, p.slug);
    }
  }
}

// ------------------------------------------------------- manual overrides
// A few keywords are either uncategorised in the manual or land somewhere
// unhelpful for an editor. Each override below is a deliberate decision.
const OVERRIDE = {
  // Handled by a syn match so the comment and multi word rules can win.
  REM: null,
  ON: null,

  IF: "freebasicConditional",
  THEN: "freebasicConditional",
  ELSE: "freebasicConditional",
  ELSEIF: "freebasicConditional",
  IIF: "freebasicConditional",
  SELECT: "freebasicConditional",
  CASE: "freebasicConditional",
  WITH: "freebasicConditional",

  FOR: "freebasicLoops",
  NEXT: "freebasicLoops",
  DO: "freebasicLoops",
  LOOP: "freebasicLoops",
  WHILE: "freebasicLoops",
  WEND: "freebasicLoops",
  UNTIL: "freebasicLoops",
  STEP: "freebasicLoops",
  CONTINUE: "freebasicLoops",

  AND: "freebasicLogical",
  ANDALSO: "freebasicLogical",
  OR: "freebasicLogical",
  ORELSE: "freebasicLogical",
  NOT: "freebasicLogical",
  XOR: "freebasicLogical",
  EQV: "freebasicLogical",
  IMP: "freebasicLogical",
  MOD: "freebasicLogical",
  SHL: "freebasicLogical",
  SHR: "freebasicLogical",

  TRUE: "freebasicBoolean",
  FALSE: "freebasicBoolean",

  CLASS: "freebasicOOP",
  OBJECT: "freebasicOOP",
  BASE: "freebasicOOP",
  EXTENDS: "freebasicOOP",
  IMPLEMENTS: "freebasicOOP",
  THIS: "freebasicOOP",
  VIRTUAL: "freebasicOOP",
  ABSTRACT: "freebasicOOP",
  OVERRIDE: "freebasicOOP",
  PROPERTY: "freebasicOOP",
  OPERATOR: "freebasicOOP",
  NAMESPACE: "freebasicOOP",
  PROTECTED: "freebasicOOP",
  EVENT: "freebasicOOP",

  PTR: "freebasicPointer",
  PROCPTR: "freebasicPointer",
  SADD: "freebasicPointer",
  STRPTR: "freebasicPointer",
  VARPTR: "freebasicPointer",

  ASM: "freebasicMisc",
  DATA: "freebasicMisc",
  LET: "freebasicMisc",
  READ: "freebasicMisc",
  RESTORE: "freebasicMisc",
  SIZEOF: "freebasicMisc",
  SWAP: "freebasicMisc",
  TO: "freebasicMisc",
  OFFSETOF: "freebasicMisc",
  TYPEOF: "freebasicMisc",
  USING: "freebasicMisc",

  STOP: "freebasicDebug",
  ASSERT: "freebasicErrorHandling",
  ASSERTWARN: "freebasicErrorHandling",

  INP: "freebasicHardware",
  OUT: "freebasicHardware",
  WAIT: "freebasicHardware",
  LPT: "freebasicHardware",
  LPOS: "freebasicHardware",
  LPRINT: "freebasicHardware",
  STICK: "freebasicHardware",
  STRIG: "freebasicHardware",

  // The manual documents these on pages that no CatPg index claims. Each
  // assignment below was checked against the page it comes from.
  DATEADD: "freebasicDateTime",
  DATEDIFF: "freebasicDateTime",
  DATEPART: "freebasicDateTime",
  DATESERIAL: "freebasicDateTime",
  DATEVALUE: "freebasicDateTime",
  DAY: "freebasicDateTime",
  HOUR: "freebasicDateTime",
  MINUTE: "freebasicDateTime",
  MONTH: "freebasicDateTime",
  MONTHNAME: "freebasicDateTime",
  SECOND: "freebasicDateTime",
  TIMESERIAL: "freebasicDateTime",
  TIMEVALUE: "freebasicDateTime",
  WEEKDAY: "freebasicDateTime",
  WEEKDAYNAME: "freebasicDateTime",
  YEAR: "freebasicDateTime",
  ISDATE: "freebasicDateTime",

  // Blitting methods for PUT (KeyPgAddGfx, KeyPgAlphaGfx, ...).
  ADD: "freebasicGraphics",
  ALPHA: "freebasicGraphics",
  CUSTOM: "freebasicGraphics",
  TRANS: "freebasicGraphics",

  APPEND: "freebasicFiles",
  BEEP: "freebasicConsole",
  SLEEP: "freebasicProgramFlow",
  SHARED: "freebasicDataTypes",
  FBARRAY: "freebasicDataTypes",

  // Variadic argument macros and calling conventions.
  CVA_ARG: "freebasicFunctions",
  CVA_COPY: "freebasicFunctions",
  CVA_END: "freebasicFunctions",
  CVA_LIST: "freebasicFunctions",
  CVA_START: "freebasicFunctions",
  __FASTCALL: "freebasicFunctions",
  __THISCALL: "freebasicFunctions",

  SADD: "freebasicPointer",
};

for (const [w, group] of Object.entries(OVERRIDE)) {
  if (group === null) {
    groupOf.delete(w);
    vocabulary.delete(w);
  } else if (vocabulary.has(w)) {
    groupOf.set(w, group);
  }
}

// -------------------------------------------------------- catch-all group
const uncategorised = [];
for (const w of vocabulary) {
  if (!groupOf.has(w)) {
    groupOf.set(w, "freebasicKeyword");
    uncategorised.push(w);
  }
}

// Predefined __XXX__ symbols always belong with the preprocessor.
for (const w of vocabulary) {
  // __FASTCALL and __THISCALL are calling conventions, not predefined
  // symbols, and an explicit override already placed them.
  if (/^__.*__$/.test(w) && !OVERRIDE[w]) {
    groupOf.set(w, "freebasicPredefined");
  }
}

// ---------------------------------------------------------------- emit
const byGroup = new Map();
for (const [w, g] of groupOf) {
  if (!byGroup.has(g)) {
    byGroup.set(g, new Set());
  }
  byGroup.get(g).add(w);
}

function keywordLines(group, names, width = 66) {
  const sorted = [...names].sort();
  const out = [];
  let cur = "";

  for (const n of sorted) {
    const cand = cur ? `${cur} ${n}` : n;
    if (cand.length > width && cur) {
      out.push(`syn keyword ${group} ${cur}`);
      cur = n;
    } else {
      cur = cand;
    }
  }
  if (cur) {
    out.push(`syn keyword ${group} ${cur}`);
  }
  return out.join("\n");
}

// ------------------------------------------------- QB $-suffixed spellings
// Detected by scanning each page body for the manual's own note about the
// string type suffix, rather than by guessing which functions take one.
const suffixed = new Set();
for (let k = 0; k < pages.length; k++) {
  const p = pages[k];
  if (!p.slug.startsWith("KeyPg")) {
    continue;
  }
  const end = k + 1 < pages.length ? pages[k + 1].line : lines.length;
  const body = lines.slice(p.line, end).join("\n");
  if (!/string type suffix/i.test(body)) {
    continue;
  }
  const t = p.title
    .replace(/\s*\(.*?\)\s*$/, "")
    .replace(/\s+(Statement|Function)$/i, "")
    .trim();
  if (/^[A-Za-z_][A-Za-z0-9_]*$/.test(t)) {
    suffixed.add(t.toUpperCase() + "$");
  }
}
byGroup.set("freebasicQBSuffix", suffixed);


const GROUP_ORDER = [
  ["freebasicConditional", "conditional"],
  ["freebasicLoops", "loops"],
  ["freebasicProgramFlow", "control flow"],
  ["freebasicErrorHandling", "error handling"],
  ["freebasicDebug", "debugging"],
  ["freebasicDataTypes", "data types"],
  ["freebasicTypeCasting", "type conversion"],
  ["freebasicBoolean", "boolean literals"],
  ["freebasicFunctions", "procedures"],
  ["freebasicOOP", "object model"],
  ["freebasicArrays", "arrays"],
  ["freebasicModularizing", "modules and linkage"],
  ["freebasicCompilerSwitches", "compiler switches"],
  ["freebasicLogical", "operators"],
  ["freebasicMisc", "statements"],
  ["freebasicConsole", "console"],
  ["freebasicFiles", "file i/o"],
  ["freebasicUserInput", "user input"],
  ["freebasicString", "string functions"],
  ["freebasicMath", "maths"],
  ["freebasicMemory", "memory"],
  ["freebasicPointer", "pointers"],
  ["freebasicBitManipulation", "bit manipulation"],
  ["freebasicDateTime", "date and time"],
  ["freebasicGraphics", "graphics"],
  ["freebasicHardware", "hardware"],
  ["freebasicMultithreading", "threading"],
  ["freebasicShell", "operating system"],
  ["freebasicPreProcessor", "preprocessor"],
  ["freebasicPredefined", "predefined symbols"],
  ["freebasicQBSuffix", "QB $-suffixed spellings (-lang qb / fblite)"],
  ["freebasicKeyword", "other keywords"],
];

const sections = [];
for (const [group, title] of GROUP_ORDER) {
  const set = byGroup.get(group);
  if (set && set.size) {
    sections.push(`" ${title}\n${keywordLines(group, set)}`);
  }
}

const emitted = [...byGroup.values()].reduce((n, s) => n + s.size, 0);

const template = fs.readFileSync(
  path.join(__dirname, "freebasic.template.vim"),
  "utf8",
);

const output = template
  .replace("@@KEYWORDS@@", sections.join("\n\n"))
  .replace("@@COUNT@@", String(emitted));

const outPath = path.join(
  __dirname,
  "..",
  "vim-freebasic",
  "syntax",
  "freebasic.vim",
);

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, output, "utf8");

console.log(`Wrote ${outPath}`);
console.log(`  vocabulary from manual: ${vocabulary.size}`);
console.log(`  keywords emitted:       ${emitted}`);
console.log(`  directives found:       ${directives.size}`);
console.log("");
for (const [group] of GROUP_ORDER) {
  const set = byGroup.get(group);
  if (set && set.size) {
    console.log(`  ${group.padEnd(28)} ${set.size}`);
  }
}
if (uncategorised.length) {
  console.log(
    `\n  no category page claimed these ${uncategorised.length}, ` +
      `emitted as freebasicKeyword:`,
  );
  console.log("  " + uncategorised.sort().join(" "));
}
