---
name: explain-work
description: Explain newly implemented features with a concise, language-matched pseudocode flow and a simple walkthrough of how the code works and why. Use whenever the agent implements a brand-new feature, including when feature implementation is part of a larger task.
---

# Explain Work

After implementing a new feature, include a walkthrough in the final response so the user can understand the completed code's flow and the reasoning behind its key parts.

Start with a short statement of what the feature does. Then show the main flow as one cohesive fenced pseudocode block, using the syntax and idioms of the implementation language: for example, Python-style indentation, TypeScript-style functions and async/await, or Go-style functions and error handling. Label it as simplified pseudocode so it is not mistaken for runnable code. For features spanning languages, use the primary implementation language and clearly identify transitions to other components.

Trace the actual implementation from its entry point or user action through the important decisions, transformations, state changes or side effects, and resulting output. Include error handling or asynchronous behavior when it materially affects understanding. Use recognizable names from the code where helpful, and abstract away boilerplate and incidental helpers.

Follow the block with a short, connected walkthrough explaining the key aspects: what each major stage does, how the stages fit together, and why important design choices were made. Ground explanations in the code and known constraints; distinguish inferred rationale from established intent. Mention relevant files or symbols when they help the user find the implementation.

Keep this at the feature level, not a line-by-line explanation. Prefer one coherent flow and a few simple paragraphs over separate explanations for every file or function. Scale the detail to the feature's complexity and avoid repeating the pseudocode in prose. Explain the implemented behavior accurately, including any material unfinished portions, rather than describing planned behavior as complete.

This walkthrough accompanies the normal completion report; retain relevant validation results and limitations without duplicating them. Respect an explicit user request to omit explanations or use a different format. Routine fixes, refactors, and configuration-only edits do not require this walkthrough unless they introduce a new feature or the user asks for an explanation.
