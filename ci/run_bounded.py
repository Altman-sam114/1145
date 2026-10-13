#!/usr/bin/env python3
"""Cloud watchdog: preserve command status and stop its process group."""
import os
import signal
import subprocess
import sys
import time


def run_bounded(command, seconds, *, stdout=None, env=None):
    """Own one command group; callers share their deadline without nested wrappers."""
    if seconds <= 0 or not command:
        raise ValueError("A positive timeout and command are required")
    started = time.monotonic()
    process = subprocess.Popen(command, start_new_session=True, stdout=stdout,
                               stderr=subprocess.STDOUT if stdout is not None else None,
                               env=env)
    label = " ".join(command[:3])
    print(f"[watchdog] started {label}; limit={seconds:g}s", file=sys.stderr, flush=True)

    def stop_group():
        previous = {sig: signal.getsignal(sig) for sig in (signal.SIGTERM, signal.SIGINT)}
        for sig in previous:
            signal.signal(sig, signal.SIG_IGN)
        try:
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except (ProcessLookupError, PermissionError):
                pass
            time.sleep(0.5)
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except (ProcessLookupError, PermissionError):
                pass
            try:
                process.wait(timeout=1)
            except subprocess.TimeoutExpired:
                return
        finally:
            for sig, handler in previous.items():
                signal.signal(sig, handler)

    try:
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
    except BaseException:
        stop_group()
        raise


def main():
    def cancelled(signum, frame):
        print(f"[watchdog] cancelled; signal={signum}", file=sys.stderr, flush=True)
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, cancelled)
    signal.signal(signal.SIGINT, cancelled)
    return run_bounded(sys.argv[2:], float(sys.argv[1]))


if __name__ == "__main__":
    sys.exit(main())
