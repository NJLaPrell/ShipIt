#!/usr/bin/env node
/**
 * Call OpenAI or Anthropic API with a prompt; print the model response to stdout.
 * Requires OPENAI_API_KEY or ANTHROPIC_API_KEY. Used by run-phase.sh.
 * Usage: node scripts/headless/call-llm.js [--prompt "inline prompt"]
 *   Or: echo "prompt" | node scripts/headless/call-llm.js
 */

import { readFileSync } from "node:fs";

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;

function getStdin() {
  return new Promise((resolve) => {
    if (process.stdin.isTTY) resolve("");
    else {
      const chunks = [];
      process.stdin.on("data", (chunk) => chunks.push(chunk));
      process.stdin.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
    }
  });
}

async function main() {
  let prompt = "";
  const arg = process.argv[2];
  if (arg === "--prompt" && process.argv[3] != null) {
    prompt = process.argv[3];
  } else {
    prompt = (await getStdin()).trim();
  }
  if (!prompt) {
    console.error("Usage: echo 'prompt' | node call-llm.js   OR   node call-llm.js --prompt 'your prompt'");
    process.exit(1);
  }

  if (OPENAI_API_KEY) {
    const url = "https://api.openai.com/v1/chat/completions";
    const body = {
      model: process.env.OPENAI_MODEL || "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 4096,
    };
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify(body),
    });
    if (!res.ok) {
      const err = await res.text();
      console.error("OpenAI API error:", res.status, err);
      process.exit(1);
    }
    const data = await res.json();
    const text = data.choices?.[0]?.message?.content ?? "";
    if (!text) {
      console.error("OpenAI returned no content:", JSON.stringify(data).slice(0, 200));
      process.exit(1);
    }
    process.stdout.write(text);
    return;
  }

  if (ANTHROPIC_API_KEY) {
    const url = "https://api.anthropic.com/v1/messages";
    const body = {
      model: process.env.ANTHROPIC_MODEL || "claude-3-5-haiku-20241022",
      max_tokens: 4096,
      messages: [{ role: "user", content: prompt }],
    };
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(body),
    });
    if (!res.ok) {
      const err = await res.text();
      console.error("Anthropic API error:", res.status, err);
      process.exit(1);
    }
    const data = await res.json();
    const block = data.content?.find((c) => c.type === "text");
    const text = block?.text ?? "";
    if (!text) {
      console.error("Anthropic returned no text:", JSON.stringify(data).slice(0, 200));
      process.exit(1);
    }
    process.stdout.write(text);
    return;
  }

  console.error(
    "Set OPENAI_API_KEY or ANTHROPIC_API_KEY to run headless. Never commit API keys."
  );
  process.exit(1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
