#!/usr/bin/env python3
"""Emit fish completions from `umbriel --help` and `umbriel msg --help`.

Used at Nix build time. Drop this sidecar when upstream ships
share/fish/vendor_completions.d/umbriel.fish.
"""

from __future__ import annotations

import re
import subprocess
import sys

JSON_SUBCOMMANDS = frozenset(
    {
        "msg",
        "windows",
        "workspaces",
        "submap",
        "layers",
        "color",
        "tearing",
        "keyboard-layouts",
        "output-create",
        "output-destroy",
        "outputs",
    }
)

ACTION_LINE = re.compile(r"^  (\S+)\s{2,}(\S.*)$")
EVENTS_LINE = re.compile(r"events:\s*(.+)$")


def run_help(binary: str, *args: str) -> str:
    proc = subprocess.run(
        [binary, *args],
        check=True,
        capture_output=True,
        text=True,
    )
    return proc.stdout


def fish_escape(text: str) -> str:
    return text.replace("\\", "\\\\").replace("'", "\\'")


def complete_token(name: str) -> str:
    """Strip help param syntax so fish completes the typed prefix."""
    optional = re.search(r":\[", name)
    if optional:
        return name[: optional.start()]
    required = re.search(r":[^[]", name)
    if required:
        return name[: required.start() + 1]
    return name


def parse_subcommands(help_text: str) -> tuple[list[tuple[str, str]], list[str]]:
    commands: list[tuple[str, str]] = []
    events: list[str] = []
    for raw in help_text.splitlines():
        event_match = EVENTS_LINE.search(raw)
        if event_match:
            events = [e.strip() for e in event_match.group(1).split(",") if e.strip()]
            continue
        # Title line is `umbriel 0.1.0: …`; usage rows are `Usage:` or indented.
        if not (raw.startswith("Usage:") or (raw.startswith(" ") and "umbriel " in raw)):
            continue
        line = re.sub(r"^Usage:\s+", "", raw).strip()
        if not line.startswith("umbriel "):
            continue
        rest = line[len("umbriel ") :]
        token, _, tail = rest.partition(" ")
        if token.startswith("-") or token.startswith("["):
            continue
        if token == "help":
            commands.append(("help", "show this help"))
            continue
        desc = ""
        parts = re.split(r"\s{2,}", tail.strip(), maxsplit=1)
        if len(parts) == 2:
            desc = parts[1]
        elif parts and not parts[0].startswith("<") and not parts[0].startswith("["):
            desc = parts[0]
        commands.append((token, desc))
    return commands, events


def parse_actions(help_text: str) -> list[tuple[str, str]]:
    actions: list[tuple[str, str]] = []
    seen: set[str] = set()
    for raw in help_text.splitlines():
        match = ACTION_LINE.match(raw)
        if not match:
            continue
        token = complete_token(match.group(1))
        if token in seen:
            continue
        seen.add(token)
        actions.append((token, match.group(2).strip()))
    if "spawn:" in seen and "spawn" not in seen:
        spawn_desc = next((d for n, d in actions if n == "spawn:"), "Run a command")
        actions.insert(0, ("spawn", spawn_desc))
    return actions


def emit(commands: list[tuple[str, str]], events: list[str], actions: list[tuple[str, str]]) -> str:
    lines = [
        "# Generated from umbriel --help / umbriel msg --help. Do not edit.",
        "complete -c umbriel -f",
        "complete -c umbriel -n '__fish_use_subcommand' -s s -r -d 'spawn command once the compositor starts'",
        "complete -c umbriel -n '__fish_use_subcommand' -s c -r -F -d 'config file'",
        "complete -c umbriel -n '__fish_use_subcommand' -s h -l help -d 'show this help'",
        "complete -c umbriel -n '__fish_use_subcommand' -s v -s V -l version -d 'print version'",
        "complete -c umbriel -n '__fish_seen_subcommand_from validate' -s c -r -F -d 'config file'",
    ]
    for name, desc in commands:
        extra = f" -d '{fish_escape(desc)}'" if desc else ""
        lines.append(f"complete -c umbriel -n '__fish_use_subcommand' -a {name}{extra}")
        if name in JSON_SUBCOMMANDS:
            lines.append(
                f"complete -c umbriel -n '__fish_seen_subcommand_from {name}' "
                "-s j -l json -d 'format output as JSON'"
            )
    for name, desc in actions:
        extra = f" -d '{fish_escape(desc)}'" if desc else ""
        lines.append(
            "complete -c umbriel -n '__fish_seen_subcommand_from msg' "
            f"-a '{fish_escape(name)}'{extra}"
        )
    for event in events:
        lines.append(
            f"complete -c umbriel -n '__fish_seen_subcommand_from subscribe' -a {event}"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: gen-fish-completions.py /path/to/umbriel", file=sys.stderr)
        return 2
    binary = sys.argv[1]
    commands, events = parse_subcommands(run_help(binary, "--help"))
    actions = parse_actions(run_help(binary, "msg", "--help"))
    if not commands or not actions:
        print("error: failed to parse umbriel help", file=sys.stderr)
        return 1
    sys.stdout.write(emit(commands, events, actions))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
