#!/usr/bin/env python3
"""Optional bridge: host MCP framing ↔ setgid 1password-mcp (NDJSON).

Current MCP stdio is newline-delimited JSON-RPC. 1Password and current Grok
Build (rmcp AsyncRwTransport) both speak NDJSON. For that path you can point
config at /run/wrappers/bin/1password-mcp directly — no adapter required.

This script remains useful when:
  - you want a single command name (1password-mcp-grok) that always uses the
    setgid wrapper path, or
  - a host still sends LSP-style Content-Length frames.

Auto-detect from the first host byte: ``{``/``[`` → NDJSON pump; else CL.

Earlier Content-Length-only adapters hung on Grok (NDJSON initialize never
matched ``\\r\\n\\r\\n`` → 30–60s startup timeout, empty stderr).
"""
from __future__ import annotations

import os
import select
import subprocess
import sys
import threading


def read_cl_body(stream, already: bytes = b"") -> bytes | None:
    headers = already
    while b"\r\n\r\n" not in headers:
        chunk = stream.read(1)
        if not chunk:
            return None
        headers += chunk
        if len(headers) > 65536:
            raise RuntimeError("MCP headers too large")
    header_blob, rest = headers.split(b"\r\n\r\n", 1)
    length: int | None = None
    for line in header_blob.split(b"\r\n"):
        if line.lower().startswith(b"content-length:"):
            length = int(line.split(b":", 1)[1].strip())
    if length is None:
        raise RuntimeError(f"missing Content-Length: {header_blob!r}")
    body = rest
    while len(body) < length:
        chunk = stream.read(length - len(body))
        if not chunk:
            raise RuntimeError("short MCP body")
        body += chunk
    return body


def write_cl(stream, body: bytes) -> None:
    stream.write(f"Content-Length: {len(body)}\r\n\r\n".encode() + body)
    stream.flush()


def read_line(stream, already: bytes = b"") -> bytes | None:
    buf = already
    while b"\n" not in buf:
        chunk = stream.read(1)
        if not chunk:
            return buf if buf.strip() else None
        buf += chunk
        if len(buf) > 16 * 1024 * 1024:
            raise RuntimeError("line too large")
    return buf.split(b"\n", 1)[0]


def pump_ndjson(host_in, host_out, child: subprocess.Popen, first_line: bytes) -> int:
    """Line pump. first_line is the first host JSON-RPC message (no trailing NL)."""
    assert child.stdin is not None and child.stdout is not None
    errors: list[BaseException] = []

    def host_to_child() -> None:
        try:
            child.stdin.write(first_line + b"\n")
            child.stdin.flush()
            while True:
                line = read_line(host_in)
                if line is None:
                    child.stdin.close()
                    return
                if not line.strip():
                    continue
                child.stdin.write(line + b"\n")
                child.stdin.flush()
        except BrokenPipeError:
            return
        except BaseException as exc:
            errors.append(exc)

    def child_to_host() -> None:
        try:
            while True:
                line = child.stdout.readline()
                if not line:
                    return
                if not line.strip():
                    continue
                if not line.endswith(b"\n"):
                    line += b"\n"
                host_out.write(line)
                host_out.flush()
        except BrokenPipeError:
            return
        except BaseException as exc:
            errors.append(exc)

    t_out = threading.Thread(target=child_to_host, daemon=True)
    t_out.start()
    # Host→child on this thread so stdin buffering stays single-threaded.
    host_to_child()
    t_out.join(timeout=5)
    if errors:
        print(f"1password-mcp-adapter: {errors[0]}", file=sys.stderr)
        return 1
    rc = child.poll()
    return 0 if rc is None else rc


def pump_content_length(host_in, host_out, child: subprocess.Popen, first: bytes) -> int:
    assert child.stdin is not None and child.stdout is not None
    out_buf = b""
    host_closed = False
    try:
        body = read_cl_body(host_in, first)
        if body is None:
            return 0
        child.stdin.write(body + b"\n")
        child.stdin.flush()

        while True:
            want = [child.stdout] + ([] if host_closed else [host_in])
            readable, _, _ = select.select(want, [], [], 0.5)

            dead = child.poll() is not None
            if dead and child.stdout not in readable and (host_closed or host_in not in readable):
                rest = child.stdout.read() or b""
                out_buf += rest
                while b"\n" in out_buf:
                    line, out_buf = out_buf.split(b"\n", 1)
                    if line.strip():
                        write_cl(host_out, line)
                return child.returncode or 0

            if not host_closed and host_in in readable:
                body = read_cl_body(host_in)
                if body is None:
                    host_closed = True
                    try:
                        child.stdin.close()
                    except Exception:
                        pass
                else:
                    child.stdin.write(body + b"\n")
                    child.stdin.flush()

            if child.stdout in readable:
                chunk = child.stdout.read(8192)
                if not chunk:
                    while b"\n" in out_buf:
                        line, out_buf = out_buf.split(b"\n", 1)
                        if line.strip():
                            write_cl(host_out, line)
                    return child.returncode or 0
                out_buf += chunk
                while b"\n" in out_buf:
                    line, out_buf = out_buf.split(b"\n", 1)
                    if line.strip():
                        write_cl(host_out, line)
    except BrokenPipeError:
        return 1
    except Exception as exc:
        print(f"1password-mcp-adapter: {exc}", file=sys.stderr)
        return 1


def main() -> int:
    binary = os.environ.get(
        "ONEPASSWORD_MCP_RAW", "/run/wrappers/bin/1password-mcp"
    )
    child = subprocess.Popen(
        [binary],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=sys.stderr.buffer,
        bufsize=0,
    )
    host_in = sys.stdin.buffer
    host_out = sys.stdout.buffer
    try:
        first = host_in.read(1)
        if not first:
            return 0
        if first.lstrip()[:1] in (b"{", b"["):
            line = read_line(host_in, first)
            if line is None:
                return 0
            return pump_ndjson(host_in, host_out, child, line)
        return pump_content_length(host_in, host_out, child, first)
    finally:
        try:
            if child.poll() is None:
                child.kill()
        except Exception:
            pass


if __name__ == "__main__":
    raise SystemExit(main())
