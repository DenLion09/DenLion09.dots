# Skill Registry

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

See `_shared/skill-resolver.md` for the full resolution protocol.

## User Skills

| Trigger                                                       | Skill      | Path                                                      |
| ------------------------------------------------------------- | ---------- | --------------------------------------------------------- |
| When writing Go tests, using teatest, or adding test coverage | go-testing | /home/diorges/.config/opencode/skills/go-testing/SKILL.md |
| Web design, CSS, color palette, typography, component styling | web-design | /home/diorges/.config/opencode/skills/web-design/SKILL.md |

## Compact Rules

Pre-digested rules per skill. Delegators copy matching blocks into sub-agent prompts as `## Project Standards (auto-resolved)`.

### go-testing

- Use table-driven tests for multiple test cases
- Test Model.Update() directly for TUI state changes
- Use teatest.NewTestModel() for full TUI flow testing
- Use golden files for view rendering comparison
- Mock system dependencies with interfaces
- Run: go test ./..., go test -cover ./..., go test -update ./... (update golden files)

### web-design

- PROHIBIDO: colores puros #000000 y #FFFFFF
- Usar CSS custom properties (tokens) del tema definido
- Light mode: fondo #F2F0E9, texto principal #1A1B1E, acento #6B705C
- Dark mode: fondo #121214, texto principal #E2E2E2, acento #8B947E
- Whitespace generoso: 2rem entre secciones, 1.5rem padding en tarjetas
- Contraste WCAG AA mínimo: 4.5:1 texto normal, 3:1 texto grande
- Iconos deben usar tokens del tema, NO colores hardcodeados
- Transiciones: --transition-fast (150ms), --transition-base (300ms), --transition-slow (500ms)

## Project Conventions

| File         | Path | Notes                        |
| ------------ | ---- | ---------------------------- |
| (none found) | —    | No convention files detected |

Read the convention files listed above for project-specific patterns and rules. All referenced paths have been extracted — no need to read index files to discover more.
