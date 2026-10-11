#!/usr/bin/env python3
"""Emit fish completions from `umbriel --help` and `umbriel msg --help`.

Used at Nix build time. Drop this sidecar when upstream ships
share/fish/vendor_completions.d/umbriel.fish.

`umbriel --help` prints rows as `  {:<30} {}`. A spec shorter than 30
columns is separated from its description by at least two spaces. Longer
specs have a single space, and the description starts after the argument
tokens. The usage placeholder `umbriel <command>` is not a subcommand:
emitting it unquoted makes fish redirect a file named `command`.
"""

from __future__ import annotations

import re
import subprocess
import sys
from dataclasses import dataclass

ACTION_LINE = re.compile(r"^  (\S+)\s{2,}(\S.*)$")
EVENTS_LINE = re.compile(r"events:\s*(.+)$")
OPTIONAL_OPT = re.compile(r"^\[(-{1,2}[A-Za-z0-9-]+)(?:\s+(<[^>]+>))?\]$")
POSITIONAL = re.compile(r"^<([^>]+)>$")
BARE_WORD = re.compile(r"^[A-Za-z][A-Za-z0-9_-]*$")
# Hardcoded below; the Other: rows would duplicate them.
SKIP_FLAGS = {"-h", "--help", "-v", "-V", "--version"}
FILE_WORDS = {"path", "config", "file"}
REQUIRED_COMMANDS = ("msg", "windows", "subscribe", "config", "help")


@dataclass(frozen=True)
class Command:
    name: str
    description: str


@dataclass(frozen=True)
class Option:
    flag: str
    description: str
    takes_file: bool
    requires_value: bool


@dataclass(frozen=True)
class Nested:
    parent: str
    name: str
    description: str
    file_flag: str


@dataclass(frozen=True)
class Help:
    commands: list[Command]
    events: list[str]
    options: list[Option]
    nested: list[Nested]
    file_positionals: list[str]


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


def tokenize(text: str) -> list[str]:
    """Split on whitespace, keeping bracketed argument specs intact."""
    tokens: list[str] = []
    i = 0
    while i < len(text):
        if text[i].isspace():
            i += 1
            continue
        start = i
        depth_angle = 0
        depth_square = 0
        while i < len(text):
            char = text[i]
            if char == "<":
                depth_angle += 1
            elif char == ">" and depth_angle:
                depth_angle -= 1
            elif char == "[":
                depth_square += 1
            elif char == "]" and depth_square:
                depth_square -= 1
            elif char.isspace() and depth_angle == 0 and depth_square == 0:
                break
            i += 1
        tokens.append(text[start:i])
    return tokens


def split_spec_desc(body: str) -> tuple[str, str]:
    """Split one help row into its spec and description."""
    depth_angle = 0
    depth_square = 0
    i = 0
    while i < len(body):
        char = body[i]
        if char == "<":
            depth_angle += 1
        elif char == ">" and depth_angle:
            depth_angle -= 1
        elif char == "[":
            depth_square += 1
        elif char == "]" and depth_square:
            depth_square -= 1
        elif char.isspace() and depth_angle == 0 and depth_square == 0:
            j = i
            while j < len(body) and body[j].isspace():
                j += 1
            if j - i >= 2:
                return body[:i].rstrip(), body[j:]
            i = j
            continue
        i += 1

    # Spec was at least 30 columns, so the formatter inserted one space.
    tokens = tokenize(body)
    if not tokens:
        return "", ""
    idx = 1
    if idx < len(tokens) and tokens[idx] == "|":
        while idx < len(tokens) and (
            tokens[idx] == "|" or tokens[idx].startswith("-")
        ):
            idx += 1
        return " ".join(tokens[:idx]), " ".join(tokens[idx:])
    if (
        idx < len(tokens)
        and BARE_WORD.match(tokens[idx])
        and any(tok[:1] in "<[" for tok in tokens[idx + 1 :])
    ):
        idx += 1
    while idx < len(tokens) and tokens[idx][:1] in "<[":
        idx += 1
    return " ".join(tokens[:idx]), " ".join(tokens[idx:])


def is_file_placeholder(text: str) -> bool:
    words = set(re.findall(r"[a-z]+", text.lower()))
    return bool(words & FILE_WORDS)


def command_parts(tokens: list[str]) -> tuple[str, str | None, list[str]]:
    """Return command name, optional second word, and argument specs."""
    name = tokens[0]
    idx = 1
    # `help | -h | --help`: the flags are aliases, not arguments.
    if idx < len(tokens) and tokens[idx] == "|":
        return name, None, []
    sub = None
    if idx < len(tokens) and BARE_WORD.match(tokens[idx]):
        sub = tokens[idx]
        idx += 1
    args: list[str] = []
    while idx < len(tokens) and tokens[idx][:1] in "<[":
        args.append(tokens[idx])
        idx += 1
    return name, sub, args


def file_flag_from_args(args: list[str]) -> str:
    for arg in args:
        match = OPTIONAL_OPT.match(arg)
        if not match:
            continue
        value = match.group(2) or ""
        if value and is_file_placeholder(value):
            return match.group(1)
    return ""


def takes_positional_file(args: list[str]) -> bool:
    for arg in args:
        match = POSITIONAL.match(arg)
        if match and is_file_placeholder(match.group(1)):
            return True
    return False


def parse_option_row(tokens: list[str], description: str) -> list[Option]:
    flags: list[str] = []
    value = ""
    for token in tokens:
        if token == "|":
            continue
        if token.startswith("-"):
            flags.append(token)
        elif token.startswith("<") and token.endswith(">"):
            value = token[1:-1]
    options: list[Option] = []
    takes_file = bool(value) and is_file_placeholder(value)
    for flag in flags:
        if flag in SKIP_FLAGS:
            continue
        options.append(Option(flag, description, takes_file, bool(value)))
    return options


def parse_top(help_text: str) -> Help:
    commands: list[Command] = []
    seen: set[str] = set()
    nested: list[Nested] = []
    options: list[Option] = []
    events: list[str] = []
    file_positionals: list[str] = []
    heading = ""

    for raw in help_text.splitlines():
        if raw.strip().startswith("events:"):
            event_match = EVENTS_LINE.search(raw)
            if event_match:
                events = [
                    part.strip()
                    for part in event_match.group(1).split(",")
                    if part.strip()
                ]
            continue
        if raw.endswith(":") and raw.strip() == raw and not raw.startswith("-"):
            heading = raw[:-1]
            continue
        # Command rows are indented two spaces. The events continuation
        # is indented further, and usage lines are indented more than that.
        if not (raw.startswith("  ") and not raw.startswith("   ")):
            continue
        spec, desc = split_spec_desc(raw[2:])
        tokens = tokenize(spec)
        if not tokens or tokens[0].startswith("<"):
            continue
        if tokens[0].startswith("-"):
            options.extend(parse_option_row(tokens, desc))
            continue
        name, sub, args = command_parts(tokens)
        if not name or "<" in name or ">" in name:
            continue
        if sub:
            if name not in seen:
                seen.add(name)
                parent_desc = heading[:1].lower() + heading[1:] if heading else ""
                commands.append(Command(name, parent_desc))
            nested.append(Nested(name, sub, desc, file_flag_from_args(args)))
            continue
        if name in seen:
            continue
        seen.add(name)
        commands.append(Command(name, desc))
        if takes_positional_file(args):
            file_positionals.append(name)
    return Help(commands, events, options, nested, file_positionals)


def parse_actions(help_text: str) -> list[Command]:
    actions: list[Command] = []
    seen: set[str] = set()
    for raw in help_text.splitlines():
        match = ACTION_LINE.match(raw)
        if not match:
            continue
        token = complete_token(match.group(1))
        if token in seen or "<" in token:
            continue
        seen.add(token)
        actions.append(Command(token, match.group(2).strip()))
    if "spawn:" in seen and "spawn" not in seen:
        spawn_desc = next(cmd.description for cmd in actions if cmd.name == "spawn:")
        actions.insert(0, Command("spawn", spawn_desc))
    return actions


def flag_args(flag: str) -> str:
    if flag.startswith("--") and len(flag) > 2:
        return f"-l {flag[2:]}"
    if flag.startswith("-") and len(flag) == 2:
        return f"-s {flag[1:]}"
    return ""


def emit(parsed: Help, actions: list[Command]) -> str:
    lines = [
        "# Generated from umbriel --help / umbriel msg --help. Do not edit.",
        "complete -c umbriel -f",
        "complete -c umbriel -n '__fish_use_subcommand' -s h -l help -d 'show this help'",
        "complete -c umbriel -n '__fish_use_subcommand' -s v -s V -l version -d 'print version'",
        # --json is accepted by IPC subcommands but never listed in help.
        "complete -c umbriel -n 'not __fish_use_subcommand' -s j -l json -d 'format output as JSON'",
    ]
    for opt in parsed.options:
        args = flag_args(opt.flag)
        if not args:
            continue
        extra = ""
        if opt.requires_value:
            extra += " -r"
            if opt.takes_file:
                extra += " -F"
            elif opt.flag == "-s":
                # Run at completion time. Single quotes keep fish from
                # expanding it while sourcing this file.
                extra += " -a '(__fish_complete_command)'"
        desc = f" -d '{fish_escape(opt.description)}'" if opt.description else ""
        lines.append(
            "complete -c umbriel -n '__fish_use_subcommand'"
            f" {args}{extra}{desc}"
        )
    for cmd in parsed.commands:
        desc = f" -d '{fish_escape(cmd.description)}'" if cmd.description else ""
        lines.append(
            "complete -c umbriel -n '__fish_use_subcommand' "
            f"-a '{fish_escape(cmd.name)}'{desc}"
        )

    by_parent: dict[str, list[Nested]] = {}
    for item in parsed.nested:
        by_parent.setdefault(item.parent, []).append(item)
    for parent, items in by_parent.items():
        names = " ".join(item.name for item in items)
        cond = (
            f"__fish_seen_subcommand_from {parent}; "
            f"and not __fish_seen_subcommand_from {names}"
        )
        for item in items:
            desc = f" -d '{fish_escape(item.description)}'" if item.description else ""
            lines.append(
                f"complete -c umbriel -n '{cond}' "
                f"-a '{fish_escape(item.name)}'{desc}"
            )
        for item in items:
            args = flag_args(item.file_flag)
            if not args:
                continue
            file_cond = (
                f"__fish_seen_subcommand_from {parent}; "
                f"and __fish_seen_subcommand_from {item.name}"
            )
            lines.append(
                f"complete -c umbriel -n '{file_cond}' {args} -r -F -d 'config file'"
            )

    for name in parsed.file_positionals:
        lines.append(
            "complete -c umbriel "
            f"-n '__fish_seen_subcommand_from {name}' -F"
        )
    for action in actions:
        desc = f" -d '{fish_escape(action.description)}'" if action.description else ""
        lines.append(
            "complete -c umbriel -n '__fish_seen_subcommand_from msg' "
            f"-a '{fish_escape(action.name)}'{desc}"
        )
    for event in parsed.events:
        lines.append(
            "complete -c umbriel -n '__fish_seen_subcommand_from subscribe' "
            f"-a '{fish_escape(event)}'"
        )
    lines.append("")
    return "\n".join(lines)


def check_parsed(parsed: Help, label: str) -> None:
    names = [cmd.name for cmd in parsed.commands]
    missing = [name for name in REQUIRED_COMMANDS if name not in names]
    if missing:
        raise SystemExit(f"error: {label} help parse missed {', '.join(missing)}")
    bad = [name for name in names if "<" in name or ">" in name or " " in name]
    if bad:
        raise SystemExit(f"error: {label} help parse produced {bad}")
    nested = {(item.parent, item.name) for item in parsed.nested}
    if ("config", "validate") not in nested or ("config", "schema") not in nested:
        raise SystemExit(f"error: {label} help parse missed config subcommands")
    if "windows" not in parsed.events:
        raise SystemExit(f"error: {label} help parse missed subscribe events")
    flags = {opt.flag: opt for opt in parsed.options}
    if "-c" not in flags or not flags["-c"].takes_file:
        raise SystemExit(f"error: {label} help parse missed -c <config>")
    if "-s" not in flags or flags["-s"].takes_file:
        raise SystemExit(f"error: {label} help parse missed -s <command>")
    if "config-replace" not in parsed.file_positionals:
        raise SystemExit(f"error: {label} help parse missed config-replace <path>")


def self_check() -> None:
    """Lock the row shapes that broke the previous generator."""
    sample = """
umbriel 0.1.0: a wayland compositor

Usage: umbriel [-s <command>] [-c <config>]   run the compositor
       umbriel <command> [args...]            run a command

Compositor options:
  -s <command>                   spawn <command> once the compositor starts
  -c <config>                    use <config> instead of the default config path

Control the running compositor:
  msg <action> [args...]         send an action to the compositor
  config-replace <path>          load and watch a different config file

Inspect the running compositor:
  windows                        list windows (app id and title)
  subscribe <event>[,<event>…]   stream events as JSON lines
                                 events: theme, windows, outputs

Configuration, without a running compositor:
  config validate [-c <config>]  check the config file
  config schema [--json]         count or describe every config key

Test harness:
  swipe-test <begin|update|end> <ms> [dx dy|cancelled] inject three-finger swipe events (harness only)
  animation-capture-fail <on|off> inject animation capture failure (harness only)

Other:
  help | -h | --help             show this help
  -v | -V | --version            print version
"""
    parsed = parse_top(sample)
    check_parsed(parsed, "fixture")
    swipe = next(cmd for cmd in parsed.commands if cmd.name == "swipe-test")
    if not swipe.description.startswith("inject "):
        raise SystemExit(f"error: swipe-test description parsed as {swipe.description!r}")
    capture = next(cmd for cmd in parsed.commands if cmd.name == "animation-capture-fail")
    if not capture.description.startswith("inject "):
        raise SystemExit(
            f"error: animation-capture-fail description parsed as {capture.description!r}"
        )
    validate = next(item for item in parsed.nested if item.name == "validate")
    if validate.file_flag != "-c":
        raise SystemExit(f"error: config validate file flag parsed as {validate.file_flag!r}")


def main() -> int:
    self_check()
    if len(sys.argv) != 2:
        print("usage: gen-fish-completions.py /path/to/umbriel", file=sys.stderr)
        return 2
    binary = sys.argv[1]
    parsed = parse_top(run_help(binary, "--help"))
    actions = parse_actions(run_help(binary, "msg", "--help"))
    check_parsed(parsed, "umbriel")
    if not actions:
        print("error: failed to parse umbriel msg help", file=sys.stderr)
        return 1
    text = emit(parsed, actions)
    if re.search(r"-a\s+[^'\"]*<", text):
        print("error: completion would redirect an unquoted <token>", file=sys.stderr)
        return 1
    sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
