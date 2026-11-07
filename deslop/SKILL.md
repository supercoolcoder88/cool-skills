---
name: deslop
description: Remove AI-generated slop from code you just wrote, such as needless comments, one-use abstractions, defensive checks, type escapes and dead code, without changing behavior. Use whenever you have done extensive work in a codebase (a new feature, a multi-file change, a large refactor, or any task that touched more than a handful of lines), before reporting it as done. Also use when the user asks to deslop, clean up, or simplify recent changes. Skip it for small, targeted edits.
---

# Deslop

Clean up the code introduced by the current work so it reads like the
surrounding codebase was written by one careful person. Less code is the goal.
Behavior stays the same.

## 1. Find the change

Work only on lines this work added or changed:

- On a branch: `git diff $(git merge-base HEAD main)` (use the repo's default
  branch), plus uncommitted changes.
- On the default branch or with no commits yet: `git diff HEAD` and untracked
  files from `git status`.
- If you were handed a list of files or a base commit, use that instead.

Read each changed file in full, not just the hunks, so you can judge what is
normal for that file. Pre-existing code is out of scope, even if it is sloppy.

## 2. Remove the slop

**Comments**
- Comments that restate the code (`// increment counter`, `# loop over users`).
- Narration of the change or the process (`// new helper for X`, `// updated to
  use Y`, `// step 1:`), and banner or section-divider comments.
- Docstrings on private or obvious functions when the file does not use them.
- Commented-out code and `TODO`s you created and will not do.

Keep comments that explain *why*: a non-obvious constraint, a workaround with
its reason, a link to an issue. Keep license headers, tool directives
(`eslint-disable`, `# type: ignore`, `//go:build`), and public API docs where
the codebase documents its public API.

**Unnecessary abstractions**
- Wrappers, helpers, or classes with one caller that add no meaning: inline them.
- Interfaces, base classes, factories, or strategy patterns with one
  implementation.
- Config options, parameters, or flags that only ever take one value.
- New files or modules holding a single small function that belongs next to its
  caller.
- Intermediate variables that only rename a value used once.
- Re-implementations of something the codebase or standard library already
  provides: use the existing one.

**Defensive noise**
- `try`/`catch` that swallows, logs and rethrows, or wraps errors without adding
  information, on paths that are trusted by the surrounding code.
- Null, type, or range checks for values the types or callers already
  guarantee; validation repeated at several layers.
- Fallback defaults that hide bugs instead of surfacing them.
- Backwards-compatibility shims, aliases, or re-exports for code that has no
  existing users.

**Type and structure**
- Casts to `any`, `as unknown as`, `# type: ignore`, `!` assertions, or
  `interface{}` used only to silence the type checker: fix the type instead.
- Deep nesting that early returns or guard clauses would flatten.
- Dead code: unused imports, variables, parameters, branches, and exports added
  by this work.
- Debug logging and print statements left behind; log lines noisier than the
  file's norm.
- Names that are generic (`data`, `result`, `handleThing`, `utils`) or
  inconsistent with local naming.
- Anything else that is out of keeping with the file and its neighbors:
  formatting, error-handling style, test structure.

**Tests**
- Tests that duplicate each other, assert nothing meaningful, or test the mock.
  Do not delete a test that covers a real requirement.

## 3. Guardrails

- Keep behavior unchanged. Fix a bug only if it is clear, and call it out.
- Prefer small, focused edits over rewrites. When unsure whether something is
  slop, leave it.
- Match the codebase, not personal taste: if the file is full of docstrings,
  a docstring is not slop.
- Run the relevant tests, lint, and type checks after editing. If something
  fails because of a deslop edit, revert that edit rather than work around it.

## Output

Report in one to three sentences what you removed or simplified and the checks
you ran with their results. If nothing needed changing, say so.
