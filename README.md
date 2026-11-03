# `@work` – your time tracking agent

An [OpenCode](https://opencode.ai) agent and skill for interactive time tracking with the
[`work`](https://vauhoch.zett.cc/work/) command-line tool.

You can ask for things like "I started at 9", "log the last hour as review", or "how long
until I can leave today ?" and the agent runs the matching `work` commands for you.

The most elegant part is that `work` makes sure that the agent acts reliably.
Deterministic where it makes sense, dynamic where it's fun!

## Concept

The agent only exists to limit permissions and load the `work` skill. If you prefer to
ask your main agent for work commands, you can explicity have it delegate to `@work` or
ask it directly and have it load the skill itself.

## Installation

First, install `work` (e.g. by running `uv tool install work`).

Then:

```sh
./install.sh [--copy]  # symlink or copy the files into your OpenCode directory
```
