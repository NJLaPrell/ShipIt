# Experimental

Tooling and artifacts that are **not part of the main ShipIt workflow**. Use at your own discretion; they may change or be removed.

- **agent-coordinator.sh** — Task queue and agent assignment. Writes `agent-queue.json` and `agent-status.json` in this directory. Schemas: `agent-queue-schema.json`, `agent-status-schema.json`. Not referenced by core scripts or documented in the main project structure.
