# Claude entry point

Read AGENTS.md and HANDOFF.md. The native project is in this folder, not the repository's unrelated root JavaScript project.

Priority: compile/sign iOS and execute docs/ACCEPTANCE.md on a real iPhone. Keep V1 lean. Do not expand the feature set to avoid the enforcement test. Update HANDOFF.md and push before ending or hitting a usage limit.

Checkout/entry:

```bash
git clone --branch codex/five-minute-limiter https://github.com/jamallarsen10-hub/gpt.git
cd gpt/five-minute
bash scripts/build-macos.sh
```

The user has a Mac but no paid developer membership. An unsigned simulator build is available without signing; Family Controls device provisioning requires an eligible paid team. No purchase is authorized. The trusted person controls the separate system Screen Time passcode; this app has no in-app PIN/override. Only the Instagram native app is to be shielded.
