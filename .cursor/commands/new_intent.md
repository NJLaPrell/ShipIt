# /new_intent

Interactive wizard to create a new intent file.

## Usage

```
/new_intent
```

This command will guide you through creating a new intent with an interactive wizard.

## Interactive Prompts

The wizard will ask for:

1. **Intent Type** - Feature (F-###), Bug (B-###), or Tech Debt (T-###)
2. **Title** - Short, descriptive title
3. **Motivation** - Why it exists (1-3 bullets, type 'done' when finished)
4. **Priority** - p0 (Critical), p1 (High), p2 (Medium), p3 (Low)
5. **Effort** - Small (s), Medium (m), Large (l)
6. **Release Target** - R1 (Next), R2 (Following), R3 (Future), R4 (Backlog)
7. **Dependencies** - Other intent IDs (e.g., F-001, F-002) or 'none'
8. **Risk Level** - Low, Medium, High

## What It Creates

- New intent file (by type):
  - Feature: `work/intent/features/<intent-id>.md`
  - Bug: `work/intent/bugs/<intent-id>.md`
  - Tech debt: `work/intent/tech-debt/<intent-id>.md`
- All fields pre-filled based on your inputs
- Automatically regenerates roadmap files
- Automatically regenerates release plan

## Example

```bash
/new_intent
→ Intent Type: [1] Feature
→ Title: Add user authentication
→ Motivation: [Enter bullets, type 'done']
→ Priority: [2] p1
→ Effort: [2] Medium
→ Release Target: [1] R1
→ Dependencies: F-001, F-002 [or 'none']
→ Risk Level: [3] High

✓ Intent created successfully!
  ID: F-003
  Title: Add user authentication
  ...
```

## Next Steps

After creating an intent:

1. Review the generated file
2. Fill in acceptance criteria, invariants, and other details
3. Run `/ship <intent-id>` to start the workflow

## Related Commands

- `/ship <id>` - Start working on an intent
- `/status` - See all intents and their status
- `/help new_intent` - Detailed help
