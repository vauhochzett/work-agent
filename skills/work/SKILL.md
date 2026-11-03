---
name: work
description: >-
  Operate the user's `work` time-tracking CLI on their behalf: start, stop, or
  switch runs, log or correct entries (incl. overwriting with add --force), check
  hours and balance, list/export records, manage vacation and holidays. Use this
  whenever the user talks about tracking or logging their work time ("I started at
  9", "log the last hour as review", "lunch 12:30–13:15", "how long until I can
  leave?", "what did I do yesterday?"), even mid-way through other work.
---

You operate `work`, a git-inspired command-line time tracker, for the user. Translate
their requests into `work` commands, run them, and report the result briefly. Use
what you know from this session to write accurate categories and messages.

Always use long flags prefixed with two dashes (e.g., `--category`).

## Model

- One global status: active since a start time, or no active run.
- All validation is done by the `work` command-line tool.
- Output contains ANSI color codes; ignore them.

## Learning the CLI

The built-in help is the reference for modes, flags, and time/day formats.

- At the start, run `work --help` for the list of modes.
- Before using a mode for the first time in a session, run `work MODE --help`
  (e.g. `work export csv --help` for sub-modes).
- `work --help-verbose` explains rounding of `now`, expected hours, and balance.
- `work --dry-run MODE ...` previews any command without changing anything.
- Use full mode names, not the user's aliases that are in parantheses.

Not in the help:

- TIME also accepts `1230` (= 12:30). `start again` starts at the end of today's
  last record.
- When the user means the current time ("now", "just started", "I'm done"), pass
  the keyword `now`, never the clock time. Otherwise use their exact times.
- Run `date` only to resolve days and weekdays, not to fill in `now`.
- Filter patterns match the whole field, so use `'*review*'` for "contains".
  Always single-quote patterns.

## Tracking like the user does

The user also runs `work` by hand between your turns.

- Run `work status` at the start of every request.
- Use start/stop/switch:
  - "I started at 9" → `work start 9`
  - "Since 10:30 on the review, before that standup"
    → `work switch 10:30 --category CAT --message standup`
  - "Lunch 12:30–13:15" → `work switch 12:30 --category CAT --message MSG --start 13:15`
  - Durations are anchored at the active run start time; e.g.: "do X for 30, then 15 min
    of Y" → check the start time, switch 30 minutes later with X, then 15 minutes for Y.
  - "Done at 18" → `work stop 18 --category CAT --message MSG`
  - "Earlier I did X from 14 to 15", no run active → `work start 14`, then
    `work stop 15 --category CAT --message X`
- Use `add` only when that doesn't work: another day, an interval before the active
  run's start, a gap that would collide with a later record, or replacing existing
  records (`--force`, below).
- Don't start or stop runs unless the request implies it.
- A category for the active run can only be given at stop. Remember it from the
  conversation; otherwise ask, or infer from `work list --include-active`.
- Categories and even messages will repeat or mirror previous ones. Orient yourself on the
  logged ones by checking them (e.g., `work list --month` or `work list --since 1.1.`).

## Overwriting records: add --force

To replace what's recorded for a time slot, use
`work add FROM TO --category CAT --message MSG [--day DAY] --force`.
Overlapping records are removed (fully covered), shortened, or split around the new record.

1. `work list --day DAY`
2. `work --dry-run add ... --force` and tell the user what will be removed, shortened, or split.
3. Run it without `--dry-run`, then `work list --day DAY`.

- Give the full category and message; copy existing ones from the list if kept.
- Don't overlap the active run; use `switch`/`stop` or `start TIME --force` instead.
- Split parts keep the old category and message.

## edit and remove

Both work on one day (`--day DAY`, `--yesterday`, default today) and prompt on stdin;
answer via a pipe.

- Run `work list --day DAY` first. Indices start at 0 and count only records matching
  the filters.
- To skip interactive selection you can directly select all (matching) records with `--all`
  or the last one `--last`; both respect filters, e.g.
  `work remove --yesterday --filter-message '*test*' --all`.
  Pipe indices only for other selections: `printf '1 2\n' | work remove --day DAY`
- `edit` asks per record: start, end, category, message (empty = keep, `-` = clear),
  then `y` to confirm if something changed. E.g. record 2, end 12:00, category
  `meeting`: `printf '2\n\n12:00\nmeeting\n\ny\n' | work edit`
- Dry-run non-trivial pipes first.

## Rules

- Use `--force` freely only for `add` (always dry-run first); on other modes only
  if the user asks.
- Before `cancel`, `remove`, or `free-days --remove`, say what will be lost.
- Ask when the day, record, or time is ambiguous.
- Don't invent categories.
- On errors, explain the message or propose a fix; don't retry blindly.
- Never edit the log files directly.
- Reply briefly, e.g. with `work status --oneline` after changes.
- Conversations can span multiple days. Get context for time-based questions with `date`.
