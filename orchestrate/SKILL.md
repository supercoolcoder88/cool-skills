---
name: orchestrate
description: Orchestrate a multi-part task by writing a spec per subtask, delegating each subtask to its own test-first implementation subagent, then reviewing every implementation and sending it back for fixes until it meets the spec. Use only when the user explicitly asks to orchestrate; do not invoke on your own initiative.
disable-model-invocation: true
---

# Orchestrate

You, the main agent, are the **orchestrator**: you split the work, write the
specs, and judge the results. Each subtask goes to one **implementer** subagent
that writes tests first, then the implementation, then explains its work. You do
not write the implementation yourself.

## 1. Split the work and write specs

Take each numbered item or bullet from the user's request as one subtask by
default. You may merge several items into one subtask, handled by a single
implementer, when you judge it worth it: they cannot be done separately, they
touch the same files or code paths closely enough that separate implementers
would conflict, one is too small to justify its own subagent, or they share so
much context that one implementer would do them better together. Do not merge
just to reduce the number of subagents when the items are independent and
substantial. Split an item only when it is clearly several independent changes.
Keep the user's numbering so the report maps back to their list; a merged
subtask carries all of its items' numbers (for example `2+3`).

Before writing specs, read enough of the codebase to ground them: the relevant
files, existing conventions, the test framework, and how tests are run. Then write
one spec per subtask containing:

- **Goal**: the user's item quoted verbatim, followed by what "done" means. For
  a merged subtask, quote every item it covers, with its number, and say why
  they were merged.
- **Context**: repository path, the files and symbols involved, and relevant
  conventions (naming, error handling, style, test layout).
- **Scope**: the files the subagent may change, and what is out of scope.
- **Interfaces**: any signatures, data shapes, or contracts the subtask must
  provide or consume, especially ones another subtask depends on.
- **Acceptance criteria**: concrete, checkable behaviors, including edge cases
  and error paths. These become the subagent's tests.
- **Test command**: how to run the relevant tests.

If a subtask is ambiguous in a way that changes what gets built, ask the user
before spawning. Otherwise choose a sensible default and record it in the spec.

### Order and parallelism

Map dependencies between subtasks. Run independent subtasks in parallel; run a
dependent subtask only after the subtask it depends on has passed review, and
include the accepted interface in its spec. If parallel subtasks would edit the
same files, either sequence them or give each its own isolated worktree (Claude
Code: `isolation: "worktree"`) and merge the results yourself afterwards.

## 2. Spawn one implementer per subtask

For N subtasks, spawn N subagents, one per subtask, each with a **fresh
context**:

- Claude Code: the Agent tool with a non-fork type such as `general-purpose`.
  Never use `fork`; implementers should work from the spec, not this
  conversation. Give each a short name so you can message it again later.
- Codex or other tools: spawn a new subagent/thread that does not share this
  conversation's history.

Each prompt must be self-contained: the full spec, plus these instructions,
quoted as written:

> 1. **Tests first.** Before changing implementation code, write tests that
>    cover every acceptance criterion in the spec, following the repository's
>    existing test conventions. Run them and confirm they fail for the expected
>    reason (missing behavior, not a broken test).
> 2. **Implement.** Make the smallest change, within the spec's scope, that
>    makes the tests pass. Follow existing conventions. Do not weaken, skip, or
>    delete tests to make them pass. Do not change files outside the scope;
>    if you must, stop and explain why in your report.
> 3. **Verify.** Run the test command and any relevant lint or type checks.
>    Report results honestly, including failures.
> 4. **Explain.** Read and follow the explain-work skill at
>    `<absolute path to explain-work/SKILL.md>`, then produce its walkthrough
>    of what you implemented.
> 5. **Report** back with: files changed, tests added, the commands you ran
>    and their results, any assumptions or deviations from the spec, and the
>    explain-work walkthrough.
>
> Do not run the deslop skill; the orchestrator runs it once over all
> subtasks at the end.

Resolve the explain-work path to an absolute path before sending; it is the
`explain-work` skill directory next to this skill. If it cannot be found, tell
the implementer to finish with a short pseudocode flow and a plain walkthrough
of how and why the code works instead.

If no subagent mechanism is available, say so, then do each subtask yourself in
order following the same instructions, and note in the report that the reviews
were not independent.

## 3. Review each implementation

Treat an implementer's report as a claim, not a conclusion. For each subtask:

1. Read the actual diff of the files it changed, not just its summary.
2. Run the test command yourself and confirm the tests pass.
3. Judge it against the spec:
   - Every acceptance criterion is implemented **and** covered by a test that
     would fail without it. Tests that assert nothing meaningful, mock away the
     behavior under test, or merely mirror the implementation do not count.
   - Edge cases and error paths in the spec are handled.
   - The change stays in scope and follows repository conventions.
   - No obvious bugs, dead code, duplicated logic, or needless complexity.
   - The explain-work walkthrough matches the code that was written.
4. Give a verdict: `Accepted`, or `Needs fixes` with a numbered list of
   specific problems, each citing a file and line and saying what is expected.

For `Needs fixes`, send the list back to the **same** implementer so it keeps
its context (Claude Code: SendMessage to its name or ID). Tell it to add or fix
tests for each problem before fixing the code, rerun the checks, and report
again with an updated walkthrough. Then review again.

Allow up to three fix rounds per subtask. If it still falls short, stop and
tell the user what remains wrong and why, instead of accepting it or rewriting
it yourself. Fix nothing yourself beyond trivial integration glue (for example
resolving a merge between worktrees), and mention any such glue in the report.

## 4. Integrate and verify

Once every subtask is accepted, merge any worktree results, then run the full
relevant test suite, lint, and type checks across all changes together, since
subtasks that pass alone can conflict. If an integration failure traces to a
subtask, send it back to that implementer as a fix round.

## 5. Deslop

Once integration checks pass, spawn one more fresh subagent (Claude Code: a
non-fork type such as `general-purpose`) to deslop the combined change. Its
prompt must include:

- The absolute path to the deslop skill, the `deslop` directory next to this
  skill, with the instruction to read and follow `SKILL.md` there.
- The repository path, the base commit the work started from, and the full
  list of files changed across all subtasks.
- The test, lint, and type-check commands from the integration step.
- That it must not change behavior, and must report the files it edited and
  the checks it ran with their results.

When it reports, read its diff and rerun the integration checks yourself.
Revert any edit that changes behavior or breaks a check. If the deslop skill
cannot be found, do the same cleanup pass in the subagent using the skill's
description as the brief. If no subagent mechanism is available, run the deslop
pass yourself and say so in the report.

## Output

Start with a table, one row per subtask in the user's order:

| # | Subtask | Verdict | Fix rounds | Tests added | Files changed |
| --- | --- | --- | --- | --- | --- |

Verdict is `Accepted` or `Unresolved: <reason>`. A merged subtask gets one row
under its combined number (for example `2+3`). Then, for each accepted
subtask, include the implementer's explain-work walkthrough (corrected if your
review found it inaccurate) under a heading with the subtask's number and name.
Then give the deslop subagent's summary, noting any edits you reverted. End
with the integration checks that ran after deslop and their results, or `Not
run: <checks>` and why. Do not claim work is verified if checks were not run or
failed.
