#!/usr/bin/env node
/**
 * Export dashboard JSON for the React dashboard.
 * Reads: work/intent/, work/workflow-state/, _system/artifacts/, _system/drift/
 * Layout: Supports both flat and per-intent workflow-state per workflow-state-layout.md
 * Output: dashboard-app/public/dashboard.json
 */

import {
  readFileSync,
  readdirSync,
  existsSync,
  writeFileSync,
  mkdirSync,
} from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { execSync } from "node:child_process";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = join(__dirname, "..");

function readText(path) {
  try {
    return readFileSync(path, "utf-8");
  } catch {
    return null;
  }
}

function readJson(path) {
  const text = readText(path);
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function findIntentFiles(dir, files = []) {
  if (!existsSync(dir)) return files;
  const entries = readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const p = join(dir, e.name);
    if (e.isDirectory()) {
      if (e.name !== "templates") findIntentFiles(p, files);
    } else if (e.name.endsWith(".md") && e.name !== "_TEMPLATE.md") {
      files.push(p);
    }
  }
  return files;
}

function parseIntentStatus(content) {
  const m = content.match(/##\s*Status\s*\n\s*(\w+)/i);
  return m ? m[1].toLowerCase() : "unknown";
}

function getIntentId(path) {
  const base = path.split(/[/\\]/).pop() || "";
  return base.replace(/\.md$/, "");
}

function collectIntents() {
  const intentDir = join(REPO_ROOT, "work", "intent");
  const files = findIntentFiles(intentDir);
  const intents = [];
  for (const f of files) {
    const content = readText(f);
    if (!content) continue;
    const status = parseIntentStatus(content);
    const id = getIntentId(f);
    intents.push({ id, status });
  }
  const byStatus = { planned: 0, active: 0, shipped: 0, killed: 0 };
  for (const i of intents) {
    if (i.status in byStatus) byStatus[i.status]++;
  }
  return { intents, counts: byStatus };
}

function getWorkflowState() {
  const flatActive = join(REPO_ROOT, "work", "workflow-state", "active.md");
  const content = readText(flatActive);
  let currentPhase = "none";
  let activeIntent = "none";
  let waitingForApproval = false;

  const workflowDir = join(REPO_ROOT, "work", "workflow-state");
  if (!existsSync(workflowDir)) {
    return { currentPhase, activeIntent, waitingForApproval };
  }

  const entries = readdirSync(workflowDir, { withFileTypes: true });
  const perIntentDirs = entries.filter(
    (e) => e.isDirectory() && /^[FBT]-\d+$/.test(e.name)
  );

  if (content) {
    const phaseM = content.match(/Current Phase:\s*(\S+)/i);
    const idM = content.match(/Intent ID:\s*(\S+)/i);
    if (phaseM) currentPhase = phaseM[1];
    if (idM && idM[1] !== "none") activeIntent = idM[1];
    waitingForApproval = /waiting|approval|gate/i.test(content);
  }

  return { currentPhase, activeIntent, waitingForApproval };
}

function getCalibration() {
  try {
    const out = execSync("pnpm calibration-report --json", {
      cwd: REPO_ROOT,
      encoding: "utf-8",
    });
    return JSON.parse(out);
  } catch {
    return { decisions_count: 0, message: "No calibration data" };
  }
}

function getDocLinks() {
  const base = REPO_ROOT;
  const links = [];
  const candidates = [
    ["_system/artifacts/SYSTEM_STATE.md", "System State"],
    ["work/release/plan.md", "Release Plan"],
    ["work/roadmap/now.md", "Roadmap (Now)"],
    ["work/roadmap/next.md", "Roadmap (Next)"],
    ["work/roadmap/later.md", "Roadmap (Later)"],
    ["_system/drift/metrics.md", "Drift Metrics"],
    ["_system/artifacts/dependencies.md", "Dependencies"],
  ];
  for (const [rel, label] of candidates) {
    if (existsSync(join(base, rel))) {
      links.push({ path: rel, label });
    }
  }
  return links;
}

function getDriftSummary() {
  const p = join(REPO_ROOT, "_system", "drift", "metrics.md");
  const content = readText(p);
  if (!content) return null;
  return { raw: content.slice(0, 2000), hasMetrics: true };
}

function getUsageSummary() {
  const p = join(REPO_ROOT, "_system", "artifacts", "usage.json");
  const data = readJson(p);
  if (!data) return null;
  const entries = Array.isArray(data) ? data : data.entries || [];
  return { entryCount: entries.length, hasUsage: entries.length > 0 };
}

function getProjectName() {
  const pj = readJson(join(REPO_ROOT, "project.json"));
  if (pj?.name) return pj.name;
  const pkg = readJson(join(REPO_ROOT, "package.json"));
  return pkg?.name || "project";
}

function exportDashboard() {
  const intents = collectIntents();
  const workflow = getWorkflowState();
  const calibration = getCalibration();
  const docLinks = getDocLinks();
  const drift = getDriftSummary();
  const usage = getUsageSummary();

  const payload = {
    generated: new Date().toISOString(),
    projectName: getProjectName(),
    intents,
    workflow,
    calibration,
    docLinks,
    drift,
    usage,
    testSummary: null,
  };

  const outDir = join(REPO_ROOT, "dashboard-app", "public");
  const outPath = join(outDir, "dashboard.json");
  mkdirSync(outDir, { recursive: true });
  writeFileSync(outPath, JSON.stringify(payload, null, 2), "utf-8");
  console.log(`Wrote ${outPath}`);
}

try {
  exportDashboard();
} catch (err) {
  console.error(err);
  process.exit(1);
}
