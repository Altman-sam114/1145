#!/usr/bin/env python3
"""Cloud watchdog: preserve command status and stop its process group."""
import os
import signal
import subprocess
import sys
import time


def main():
    seconds = float(sys.argv[1])
    command = sys.argv[2:]
    if seconds <= 0 or not command:
        raise SystemExit("usage: run_bounded.py SECONDS COMMAND [ARG ...]")
    started = time.monotonic()
    process = subprocess.Popen(command, start_new_session=True)
    label = " ".join(command[:3])
    print(f"[watchdog] started {label}; limit={seconds:g}s", file=sys.stderr, flush=True)

    def stop_group():
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except (ProcessLookupError, PermissionError):
            pass
        time.sleep(2)
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except (ProcessLookupError, PermissionError):
            pass
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            return

    def cancelled(signum, frame):
        print(f"[watchdog] cancelled {label}; signal={signum}", file=sys.stderr, flush=True)
        stop_group()
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, cancelled)
    signal.signal(signal.SIGINT, cancelled)
    while True:
        remaining = seconds - (time.monotonic() - started)
        if remaining <= 0:
            print(f"[watchdog] TIMEOUT {label} after {seconds:g}s", file=sys.stderr, flush=True)
            stop_group()
            return 124
        try:
            result = process.wait(timeout=min(30, remaining))
            print(f"[watchdog] finished {label}; exit={result}; elapsed={time.monotonic()-started:.1f}s", file=sys.stderr, flush=True)
            return result if result >= 0 else 128 - result
        except subprocess.TimeoutExpired:
            print(f"[watchdog] waiting {label}; elapsed={time.monotonic()-started:.1f}s", file=sys.stderr, flush=True)


if __name__ == "__main__":
    sys.exit(main())
