# /init-project

Initialize a new project with AI-Centric SDLC framework.

## Usage

```
/init-project [project-name]
```

Example: `/init-project "My Awesome App"`

## What It Does

This command initializes a new project with the AI-Centric SDLC framework:

1. **Project Setup:**
   - Creates project structure
   - Generates `project.json` metadata
   - Sets up directory structure
   - Initializes git repository (if needed)

2. **Tech Stack Selection:**
   - Interactive prompts for tech stack
   - Generates appropriate config files
   - Sets up dependencies

3. **Framework Integration:**
   - Creates AI-Centric SDLC directory structure
   - Generates initial architecture canon
   - Sets up CI/CD pipeline
   - Creates initial README

4. **Configuration:**
   - Project metadata in `project.json`
   - Initial invariants
   - Project settings

## Process

**Switch to Architect role** (read `.cursor/rules/architect.mdc`):

1. **Gather Project Information:**
   - Project name
   - Description
   - Tech stack (TypeScript/Node.js, Python, etc.)
   - High-risk domains
   - Initial requirements

2. **Generate Project Structure:**
   - Create all required directories
   - Generate config files
   - Set up framework structure

3. **Create Initial Files:**
   - `project.json` - Project metadata
   - `README.md` - Project overview
   - `architecture/CANON.md` - Architecture boundaries
   - `architecture/invariants.yml` - Initial constraints
   - CI/CD configuration

4. **Initialize Git:**
   - Create `.gitignore`
   - Initialize repository if needed
   - Create initial commit

## Output

Creates:
- Complete project structure
- `project.json` with metadata
- Initial configuration files
- Framework integration
- Git repository (if needed)

## Next Steps

After initialization:
1. Run `/scope-project` to break down into features
2. Review generated `project.json`
3. Customize `architecture/CANON.md` as needed
4. Start creating intents with `/new_intent`

## See Also

- `scripts/init-project.sh` - The underlying script
- `project.json` - Project metadata schema
- `/scope-project` - Next step after initialization
