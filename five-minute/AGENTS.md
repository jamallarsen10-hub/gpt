# Engineering instructions

Read README.md, docs/DESIGN.md, HANDOFF.md, docs/ACCEPTANCE.md before editing.

- Keep the product to one app, 300 seconds, daily reset. iPhone only.
- Do not claim un-bypassable, zero-delay or millisecond iOS tracking.
- Do not add a server, SDK, accounts, polling loops, widgets or custom shield targets before the physical-device gate passes.
- Keep system settings, permission revocation and emergency paths accessible.
- Do not commit tokens, certificates, provisioning profiles, signing credentials or device usage records.
- Verify Apple signatures against official docs when changing SDK behavior.
- Report compilation, unit checks and physical-device validation separately.
- If a check cannot run, state the blocker; never mark it passed.
- Reference repositories are not licensed code donors; check licenses before copying anything.

## Checkpoint protocol

Before a long investigation, context handoff or quota boundary, update HANDOFF.md with:
1. Completed files/behavior and latest branch/commit.
2. Commands run and actual outcomes.
3. Known failures/assumptions, ordered next steps, exact reproduction steps.
4. Any human-only signing/entitlement/device steps.

Commit and push a coherent checkpoint. Never rely on chat memory as the only state. Agents cannot reliably see their remaining account quota; checkpoint at milestones instead.
