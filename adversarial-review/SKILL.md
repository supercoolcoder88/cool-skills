---
name: adversarial-review
description: Adversarial review of a commit, branch, or local changes for code smells, anti-patterns, and performance issues. A fresh-context subagent finds issues; the main agent verifies each one and fixes the confirmed ones. Use only when the user explicitly asks for an adversarial review; do not invoke for ordinary review requests or on your own initiative.
disable-model-invocation: true
---

# Adversarial review

The review has two roles. A **finder** subagent with a fresh context hunts for
problems, so its judgment isn't shaped by how the change was written or explained.
You, the main agent, are the **assessor**: you verify each finding against the
code and fix the ones that hold up.

## 1. Brief the finder

Determine the target: a commit, a branch, or local changes (the default when none
is given). Then spawn one subagent with a **fresh context**:

- Claude Code: the Agent tool with a non-fork type such as `general-purpose`.
  Never use `fork`, which inherits this conversation.
- Codex or other tools: spawn a new subagent/thread that does not share this
  conversation's history.

The prompt must be self-contained and contain only:

- the repository path and the target (commit SHA, branch and base, or "local
  changes");
- the requested behavior, quoted verbatim from the user or linked issue, if any;
- the instruction to read and follow `finder.md` in this skill's directory, given
  as an absolute path, and to return only its findings table.

Do not pass your own reasoning, a summary of how the change works, suspected
issues, or the author's justifications. The point of the fresh context is that
the finder judges the code without them.

If no subagent mechanism is available, say so, then do the finder pass yourself
by following `finder.md`, and note in the report that the findings did not come
from an independent context.

## 2. Assess each finding

Treat the finder's table as candidates, not conclusions. For each row, open the
cited location and check the evidence yourself: confirm the quoted code exists,
the trigger is reachable, and the consequence follows. Check whether the change
actually introduced or exposed it. Mark each finding:

- `Confirmed`: the evidence and consequence hold.
- `Rejected`: the evidence is wrong, the path is unreachable, a guard or
  documented exception covers it, or it predates the change. Give the reason.

Severity can be adjusted when the evidence warrants it; say why.

## 3. Fix confirmed findings

Fix each confirmed finding with the smallest change that resolves it, following
repository conventions. Leave a confirmed finding unfixed, and say why, when:

- the user asked for a review only, or the target is not in the working tree
  (e.g. someone else's pushed branch you were asked to review, not change);
- the fix needs a design decision, an API or behavior change, or goes well
  beyond the scope of the change. Ask the user instead.

After fixing, run the repository's relevant tests, lint, or type checks for the
touched code when they exist. Report failures honestly; do not claim a fix is
verified if checks were not run or failed.

## Output

Report a single Markdown table, ordered by severity:

| Id | Severity | Category | Location | Finding | Verdict | Decision |
| --- | --- | --- | --- | --- | --- | --- |

Keep the finder's Id, Category, Location, and Finding (shorten evidence if long).
Verdict is `Confirmed` or `Rejected: <reason>`. Decision is `Fixed`,
`Not fixed: <reason>`, or `—` for rejected findings.

Carry over any `No confirmed findings.` or `Not checked: …` rows from the finder.
End with a row with `—` in the other cells and, in Finding, which checks ran
and their results (or `Not run: <checks>` and why). Below the table, list the
files changed by fixes, if any.
