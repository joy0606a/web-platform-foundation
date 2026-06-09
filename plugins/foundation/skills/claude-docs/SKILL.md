---
name: claude-docs
description: Fetch the latest official Claude Code / SDK docs on demand and answer from them, instead of relying on stale memory. Use whenever configuring Claude Code (plugins, agents, skills, hooks, settings) or any SDK/framework config where the current authoritative answer matters.
argument-hint: <topic to look up, e.g. "plugin hooks", "subagent frontmatter", "settings enabledPlugins">
allowed-tools: WebFetch, WebSearch, Read
---

# /claude-docs — always check the latest docs

Answer about **"$ARGUMENTS"** from the _current_ official documentation, never from memory.
Claude Code, its SDK, and framework config change frequently; a remembered answer is often
stale or subtly wrong. Do this every time:

1. **Fetch the docs index.** `WebFetch` `https://code.claude.com/docs/llms.txt` — this is the
   authoritative index of every documentation page.
2. **Find the relevant page(s).** From the index, pick the page(s) whose topic matches
   "$ARGUMENTS" (e.g. plugins-reference, sub-agents, skills, hooks, settings, mcp). If the
   index is ambiguous, use `WebSearch` scoped to `code.claude.com` to disambiguate, then come
   back to the docs.
3. **Fetch and read the page(s).** `WebFetch` each relevant doc URL and extract the exact,
   current answer — field names, JSON shapes, allowed values, defaults, version notes.
4. **Answer with the source.** Give the authoritative current answer and **cite the exact doc
   URL(s)** you used. If the docs contradict what you'd have said from memory, trust the docs
   and say so. If a detail isn't covered, say it's not documented rather than guessing.

Keep the answer tight: the correct shape/values, a minimal example if relevant, and the URL.
This skill exists so configuration is grounded in the live docs — use it before writing any
plugin manifest, agent/skill frontmatter, hook config, or settings key from memory.
