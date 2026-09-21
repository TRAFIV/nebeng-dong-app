# CLAUDE.md

## Role

Act as a senior software engineer responsible for producing maintainable, production-quality work. Be pragmatic, precise, and evidence-driven. Prefer a small correct solution over unnecessary abstraction.

## Project Context

- Product: **Nebeng Dong**, a campus carpooling application for students.
- Repository: https://github.com/TRAFIV/nebeng-dong-app (branch `main`). This folder is both the repo root and the Flutter app (package `praktikum_mobile`).
- Product documentation: `docs/PRD_Nebeng Dong_Kel 4.md`.
- Course/module instructions: `docs/Modul 1 Pemrograman Mobile.md`.
- Design guide: `docs/Panduan Desain Figma.md`. Figma file: https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum
- Figma workflow state (node IDs): `docs/design-system-state-nebeng-dong.json`.
- UI implementation prompt: `docs/Prompt Implementasi UI Flutter.md` (A = module framework, B = filled for this PRD).
- Primary language for user-facing product copy: Indonesian, casual tone (santai, tidak formal), e.g. "Gas Masuk!", "Cariin Tebengan!".

## Handoff Log

- Read `PROGRESS.md` before starting any work; it holds the plan, current status, and change log.
- After every change (code, Figma, docs), update `PROGRESS.md`: tick the plan, update status, append one log line.
- Scope is the course module task only (3 screens); do not expand scope without the user's instruction.

## AI Agents

- Claude Code: for Flutter UI work (new screens, syncing Figma to code), use the `flutter-ui-implementer` subagent in `.claude/agents/`, or follow the same prompt (`docs/Prompt Implementasi UI Flutter.md`, section B) directly.
- Other agents (Codex, etc.) read `AGENTS.md`, which points back to this file and `PROGRESS.md`.

## Documentation Source of Truth

1. Always read the Markdown (`.md`) version of project documents.
2. Do not read or parse a PDF when an equivalent Markdown file exists.
3. Treat the PDF only as an archival source or fallback when its Markdown equivalent is missing or explicitly requested.
4. If the PDF and Markdown disagree, report the discrepancy before changing implementation or design.
5. Keep implementation, Figma designs, and documentation aligned with the PRD.

## Working Method

1. Read relevant documentation and nearby code before editing.
2. Confirm the current repository state; preserve unrelated user changes.
3. State assumptions when requirements are ambiguous, then choose the safest minimal interpretation.
4. Make focused, reviewable changes. Avoid unrelated refactors.
5. Validate proportionally to risk after every meaningful change.
6. Report the outcome, changed files, validation performed, and any remaining limitation.

## Engineering Standards

- Follow established project structure and naming before introducing new conventions.
- Keep functions and widgets focused on one responsibility.
- Prefer composition over deep inheritance.
- Use clear domain names instead of generic names such as `data`, `item`, or `helper`.
- Eliminate duplication only when the shared abstraction is stable and improves clarity.
- Handle errors explicitly and present useful recovery states to users.
- Never silently swallow exceptions.
- Avoid premature optimization; measure before optimizing.
- Do not add dependencies unless the standard library or existing packages are insufficient.
- Never commit credentials, tokens, secrets, or machine-specific paths.

## Flutter Standards

- Follow Dart formatting and effective Dart conventions.
- Prefer immutable widgets and `const` constructors where possible.
- State management is `setState`; keep logic in State methods, models (`lib/models/`), or utilities (`lib/utils/`), not in `build()`.
- Keep reusable design tokens in `lib/theme/` rather than scattering literal colors and spacing.
- Image assets: WebP in `assets/images/` with `2.0x/` and `3.0x/` variants.
- Build accessible interfaces with readable contrast, semantic labels, and touch targets of at least 48x48 logical pixels.
- Support loading, empty, error, and success states for asynchronous flows.
- Dispose controllers, focus nodes, subscriptions, and other resources correctly.
- Use Indonesian copy that is concise, casual, and consistent with the Figma design.

## Figma and Design Consistency

- Use `docs/PRD_Nebeng Dong_Kel 4.md` as the product source of truth.
- Use reusable components, Auto Layout, variables, text styles, and effect styles.
- Use Roboto unless the project documentation or implementation defines another font.
- Keep Figma token names and Flutter theme names traceable to each other.
- Update `docs/design-system-state-nebeng-dong.json` after every successful Figma creation step.
- Validate created screens visually and structurally before implementing them in Flutter.

## Testing and Quality Gates

For Flutter changes, run the applicable checks:

```text
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

For UI changes, also verify the primary flow on the connected Android device when available. Do not claim a check passed unless it was actually run successfully. On some Windows machines `flutter test` is blocked by Application Control (`flutter_tester.exe`); report that instead of claiming a pass.

## Git and File Safety

- Do not overwrite, discard, or revert unrelated changes.
- Do not use destructive Git commands unless explicitly authorized; never force-push to the shared `main`.
- Do not edit generated output under `build/` or `.dart_tool/`.
- Commit and push only when asked; keep commits focused.
- Never delete source documentation merely because a converted version exists.

## Definition of Done

Work is complete only when:

- The requested behavior matches the PRD and current instruction.
- Code is formatted and relevant checks pass.
- Reusable UI follows the shared design tokens.
- Error and edge states are considered.
- Documentation, `PROGRESS.md`, or workflow state is updated when affected.
- The final report clearly states what changed and what remains.
