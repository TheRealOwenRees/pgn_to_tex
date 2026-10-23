"use strict";

const assert = require("node:assert");
const path = require("node:path");

const artifact = path.resolve(
  __dirname,
  "../../_build/default/bin/pgn_to_tex_js.bc.js",
);

require(artifact);

const toTex = globalThis.to_tex;
assert.strictEqual(
  typeof toTex,
  "function",
  "the generated artifact should export a global to_tex function",
);

const latex = toTex("1. e4 e5 2. Nf3", "{}", false);

assert.strictEqual(typeof latex, "string", "to_tex should return a string");
assert.ok(
  latex.includes("\\textbf{1.}"),
  "rendered LaTeX should contain the first move number",
);
assert.ok(
  latex.includes("\\textbf{e4}"),
  "rendered LaTeX should contain the first move",
);
assert.ok(
  latex.includes("\\textbf{Nf3}"),
  "rendered LaTeX should contain the third move",
);

console.log("js smoke test passed");
