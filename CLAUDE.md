# Claude Code Game Studios -- trimmed for the Platanus Hack 26 arcade challenge

A cut-down Claude Code Game Studios: the skills and agents needed to build one
browser arcade game for a cabinet challenge. Each agent owns a specific domain.

## Technology Stack

- **Engine**: Web, **Phaser 3.87.0** (loaded by the cabinet from a CDN; not Phaser 4)
- **Language**: vanilla JavaScript, one `game.js`, no `import`/`require`
- **Budget**: `game.js` at most 50 KB minified; no external assets — everything drawn
  and synthesized in code
- **Version Control**: Git with trunk-based development
- **Controls**: cabinet codes (`P1_U`, `P1_1`, `START1`); never modify `CABINET_KEYS`
- **Storage**: `window.platanusArcadeStorage` only
- **Deadline**: 18 November 2026, 23:59 Santiago (UTC−3)
- **Rules**: `.claude/skills/arcade/references/rules.md` (sourced, with what is not)

> **Main path**: `/arcade` builds and checks the game; `/brainstorm` finds the idea;
> `/prototype` for any other browser sketch; `/cut` to finish.

## Project Structure

@.claude/docs/directory-structure.md

## Engine Version Reference

<!-- ENGINE-REFERENCE-IMPORT: the line under this comment is engine-specific,
     and there is none until an engine is set. The grow's record step and
     /project-settings (engine.name) write
     @docs/engine-reference/<engine>/VERSION.md here for the chosen engine. Skills
     that need the pinned version read that file on demand either way. -->


## Technical Preferences

`project.yaml` at the repo root is the primary config store — engine, specialists,
naming, platform, performance, modes. Skills resolve it via `resolve_config`
(see `.claude/docs/config-resolution.md`).

`.claude/docs/technical-preferences.md` is the **legacy fallback**, read on demand
when a key is absent from `project.yaml`. It is not imported here: it is almost
entirely `[TO BE CONFIGURED]` placeholders, and `project.yaml` holds the real values.

## Coordination Rules

@.claude/docs/coordination-rules.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
  (exempt: `active.md` appends, agent memory, a subagent's new file at the path
  its orchestrating skill named; see `.claude/rules/agent-memory.md`)
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction
- A skipped or dismissed question is not an answer: act on nothing, re-ask in
  plain text and wait
- Started outside this file's folder? Warn first: hooks, deny rules and the
  ask-first mode load only when Claude Code starts here

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** Run `/arcade` with your game idea, or `/brainstorm` to find one.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

Read `.claude/docs/context-management.md` on demand — it is a reference, not
session context. Two of its conventions are load-bearing and cited by name
elsewhere in the repo, so they are restated here rather than lost:

- **`production/session-state/active.md` is the session checkpoint.** The file is
  the memory, not the conversation. Read it first after any compaction, crash, or
  `/clear`.
- **Helpers in `.claude/scripts/` emit observations, never verdicts.** A script
  that scores or judges will eventually contradict a mode or override it cannot
  see. (Cited by `artifact-check.sh` and `adr-dep-graph.sh`.)
