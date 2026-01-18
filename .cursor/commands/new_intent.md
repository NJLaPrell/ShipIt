# /new_intent

Create a new intent file from template.

## Usage

```
/new_intent
```

This command will:
1. Prompt you for intent details (title, type, motivation)
2. Create a new intent file in `/intent/` directory
3. Use the template from `/intent/_TEMPLATE.md`
4. Generate a unique intent ID (F-###, B-###, or T-###)
5. Regenerate the roadmap files
6. Regenerate the release plan

## Intent Types

- **F-###**: Feature
- **B-###**: Bug
- **T-###**: Tech debt

## Required Information

- Title (short, descriptive)
- Type (feature | bug | tech-debt)
- Motivation (why it exists, 1–3 bullets)
- Risk level (low | medium | high)

## Output

Creates `/intent/<intent-id>.md` with all required sections filled in.
