#!/usr/bin/env python3
"""Bridge Grok (Content-Length MCP) ↔ official 1password-mcp (NDJSON lines).

The app-shipped 1password-mcp speaks newline-delimited JSON-RPC. Grok's MCP
host uses Content-Length framing. Without this bridge the child exits on
initialize and Grok reports "connection failed".
"""
from __future__ import annotations

import os
import select
import subprocess
import sys


def read_frame(stream) -> bytes | None:
    headers = b""
    while b"\r\n\r\n" not in headers:
        chunk = stream.read(1)
        if not chunk:
            return None
        headers += chunk
        if len(headers) > 65536:
            raise RuntimeError("MCP headers too large")
    header_blob, _ = headers.split(b"\r\n\r\n", 1)
    length: int | None = None
    for line in header_blob.split(b"\r\n"):
        if line.lower().startswith(b"content-length:"):
            length = int(line.split(b":", 1)[1].strip())
    if length is None:
        raise RuntimeError(f"missing Content-Length: {header_blob!r}")
    body = b""
    while len(body) < length:
        chunk = stream.read(length - len(body))
        if not chunk:
            raise RuntimeError("short MCP body")
        body += chunk
    return body


def write_frame(stream, body: bytes) -> None:
    stream.write(f"Content-Length: {len(body)}\r\n\r\n".encode() + body)
    stream.flush()


def main() -> int:
    # Prefer explicit binary; fall back to PATH (must not recurse into this wrapper).
    binary = os.environ.get("ONEPASSWORD_MCP_RAW", "1password-mcp-raw")
    child = subprocess.Popen(
        [binary],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=sys.stderr.buffer,
        bufsize=0,
    )
    assert child.stdin is not None and child.stdout is not None

    host_in = sys.stdin.buffer
    host_out = sys.stdout.buffer
    out_buf = b""

    try:
        while True:
            want = [host_in, child.stdout]
            readable, _, _ = select.select(want, [], [], 0.5)

            if child.poll() is not None and host_in not in readable and child.stdout not in readable:
                rest = child.stdout.read()
                if rest:
                    out_buf += rest
                while b"\n" in out_buf:
                    line, out_buf = out_buf.split(b"\n", 1)
                    if line.strip():
                        write_frame(host_out, line)
                return child.returncode or 0

            if host_in in readable:
                body = read_frame(host_in)
                if body is None:
                    child.stdin.close()
                    # drain child then exit
                    continue
                child.stdin.write(body + b"\n")
                child.stdin.flush()

            if child.stdout in readable:
                chunk = child.stdout.read(8192)
                if not chunk:
                    while b"\n" in out_buf:
                        line, out_buf = out_buf.split(b"\n", 1)
                        if line.strip():
                            write_frame(host_out, line)
                    return child.returncode or 0
                out_buf += chunk
                while b"\n" in out_buf:
                    line, out_buf = out_buf.split(b"\n", 1)
                    if line.strip():
                        write_frame(host_out, line)
    except BrokenPipeError:
        child.kill()
        return 1
    except Exception as exc:
        print(f"1password-mcp-adapter: {exc}", file=sys.stderr)
        child.kill()
        return 1
    finally:
        try:
            child.kill()
        except Exception:
            pass


if __name__ == "__main__":
    raise SystemExit(main())
