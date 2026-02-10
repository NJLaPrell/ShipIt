# Headless mode scripts

Run ShipIt phases from the CLI without Cursor. Uses the same `.cursor/commands` and `.cursor/rules` as Cursor; calls OpenAI or Anthropic API to generate phase output.

- **run-phase.sh** — Run one phase (1–5) for an intent. Requires `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`.
- **call-llm.js** — Helper that sends a prompt to the LLM and prints the response (used by run-phase.sh).

See [docs/headless-mode.md](../../docs/headless-mode.md) for full documentation, human gates, and how to approve.
