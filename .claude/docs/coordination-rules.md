# Agent Coordination Rules

1. **Vertical Delegation**: Leadership agents delegate to department leads, who
   delegate to specialists. Never skip a tier for complex decisions.
2. **Horizontal Consultation**: Agents at the same tier may consult each other
   but must not make binding decisions outside their domain.
3. **Conflict Resolution**: When two agents disagree, escalate to the shared
   parent. If no shared parent, escalate to `creative-director` for design
   conflicts or `technical-director` for technical conflicts.
4. **Change Propagation**: When a design change affects multiple domains, the
   `producer` agent coordinates the propagation.
5. **No Unilateral Cross-Domain Changes**: An agent must never modify files
   outside its designated directories without explicit delegation.
6. **Read Design Docs by Section**: A brief names the sections an agent needs
   by heading. Find a heading in a GDD, ADR or the art bible with the Grep
   tool (`^#`, content mode) and Read that range with offset and limit; read a doc
   whole only when the task needs all of it, and say why. `validate-read.sh`
   refuses a whole-file read of a doc over 40 KB.
7. **Trimmed roster**: this repo keeps only the agents in `.claude/agents/`.
   An agent file that names another agent (`lead-programmer`, `producer`,
   `technical-director`, ...) not in that folder names one that does not exist
   here: the decision it would escalate goes to the user instead.
8. **Nothing Goes Upstream**: Never file, open or comment on an issue or pull
   request in an engine, plugin or vendor repository, even when asked. Write a
   draft and the user submits it.

## Model Tier Assignment

Read `.claude/docs/model-tiers.md` on demand. It carries the tier table, the
per-skill assignments and the authoring rule.

**Key point:** whether a skill's `model:` is used
depends on how the skill starts. Typed as `/skill-name`: yes, except a `haiku`
pin in auto mode. Started by Claude through the Skill tool: no. Never tell a
user a `haiku` skill saves money; an `opus` skill typed in a Sonnet session
costs more. The agent-side `model:` is a different mechanism, and is applied.

## Subagents vs Agent Teams

This project uses two distinct multi-agent patterns:

### Subagents (current, always active)
Spawned via the `Agent` tool within a single Claude Code session. Subagents share the session's
permission context, run sequentially or in parallel within the session, and
return results to the parent.

**When to spawn in parallel**: If two subagents' inputs are independent (neither
needs the other's output to begin), spawn both `Agent` calls simultaneously
rather than waiting. Example: asking `art-director` for a palette and
`sound-designer` for a sound list for the same game are independent — spawn both
at the same time. A review of what one of them produced depends on it, so it
must NOT be parallelised.

### Agent Teams (experimental — opt-in)
Multiple independent Claude Code *sessions* coordinated via a shared task list.
Opt-in only — read `.claude/docs/agent-teams.md` on demand before proposing one.

## Parallel Task Protocol

When an orchestration skill spawns multiple independent agents:

1. Issue all independent `Agent` calls before waiting for any result
2. Collect all results before proceeding to dependent phases
3. If any agent is BLOCKED, surface it immediately — do not silently skip
4. Always produce a partial report if some agents complete and others block
