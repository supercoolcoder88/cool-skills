# cool-skills

The primary skills source for Codex and Claude Code.

Each skill is a top-level folder containing a `SKILL.md`:

```
my-skill/
  SKILL.md
  ...
```

## Install

```sh
./install.sh
```

- **Codex:** `~/.agents/skills` is a symlink to this repo, so Codex reads it
  directly. New skills and edits show up automatically.
- **Claude Code:** each skill is symlinked into `~/.claude/skills/<name>`. That
  folder also holds Claude-managed content (`synced/`), so it can't be replaced
  wholesale. Edits show up immediately; re-run `./install.sh` after adding or
  removing a skill.

`./install.sh --uninstall` removes every link into this repo.
