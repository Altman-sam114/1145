#!/usr/bin/env python3
"""Cloud watchdog: preserve command status and stop its process group."""
import errno
import os
import signal
import subprocess
import sys
import time


def run_bounded(command, seconds, *, stdout=None, env=None, receipt=None):
    """Own one command group; callers share their deadline without nested wrappers."""
    if seconds <= 0 or not command:
        raise ValueError("A positive timeout and command are required")
    started = time.monotonic()
    evidence = receipt if receipt is not None else {}
    evidence.update(schemaVersion=1, scope="owned-cli-process-group-only", limitSeconds=seconds,
                    trigger="spawn", reaped=False, term={"status": "not_needed"}, kill={"status": "not_needed"},
                    cleanupOutcome="not_needed", cleanupElapsedSeconds=0)
    try:
        process = subprocess.Popen(command, start_new_session=True, stdout=stdout,
                                   stderr=subprocess.STDOUT if stdout is not None else None,
                                   env=env)
    except BaseException as error:
        evidence.update(trigger="spawn_error", error=str(error), elapsedSeconds=time.monotonic() - started)
        raise
    evidence.update(pid=process.pid, pgid=process.pid)
    label = " ".join(command[:3])
    print(f"[watchdog] started {label}; limit={seconds:g}s", file=sys.stderr, flush=True)
    cleanup_entered = False

    def stop_group():
        nonlocal cleanup_entered
        if cleanup_entered:
            evidence.update(cleanupOutcome="failure", cleanupError="Cleanup reentry refused; no further signals")
            return
        cleanup_entered = True
        cleanup_started = time.monotonic()
        previous = {sig: signal.getsignal(sig) for sig in (signal.SIGTERM, signal.SIGINT)}
        for sig in previous:
            signal.signal(sig, signal.SIG_IGN)
        try:
            # Read cached state only: polling here could reap and release the PGID anchor.
            if process.returncode is not None:
                evidence.update(cleanupOutcome="failure", cleanupError="Leader identity unanchored before cleanup")
                return

            def send(name, sig):
                result = {"status": "sent"}
                try:
                    os.killpg(process.pid, sig)
                except OSError as error:
                    if error.errno == errno.ESRCH:
                        result["status"] = "already_gone"
                    else:
                        result.update(status="error", errno=error.errno, error=str(error))
                evidence[name] = result
                if receipt is not None:
                    try:
                        print(f"[watchdog] group={process.pid} {name} {result}", file=sys.stderr, flush=True)
                    except Exception as error:
                        evidence["cleanupError"] = f"Signal receipt logging failed: {error}"
            send("term", signal.SIGTERM)
            time.sleep(0.5)
            send("kill", signal.SIGKILL)
            try:
                evidence.update(returnCode=process.wait(timeout=1), reaped=True)
            except (subprocess.TimeoutExpired, OSError) as error:
                evidence.update(reaped=False, reapError=str(error))
            evidence["cleanupOutcome"] = ("success" if evidence["reaped"] and
                all(evidence[key]["status"] in ("sent", "already_gone") for key in ("term", "kill")) else "failure")
            if (evidence["term"]["status"] == "sent" and evidence["kill"]["status"] == "error"
                    and evidence["kill"].get("errno") == errno.EPERM and evidence["reaped"]
                    and evidence.get("returnCode") == -signal.SIGTERM):
                check = dict(pgid=process.pid, signal=0, phase="after-leader-reap", status="exists")
                evidence["postReapGroupCheck"] = check
                # No nonzero signal follows reap; a reused group can only fail this read-only check.
                try:
                    os.killpg(process.pid, 0)
                except OSError as error:
                    check.update(status="absent" if error.errno == errno.ESRCH else "error",
                                 errno=error.errno, diagnostic=str(error))
                except Exception as error:
                    check.update(status="error", diagnostic=str(error))
                if check["status"] == "absent":
                    evidence["cleanupOutcome"] = "group_absent_after_reap"
            if "cleanupError" in evidence:
                evidence["cleanupOutcome"] = "failure"
        finally:
            evidence["cleanupElapsedSeconds"] = round(time.monotonic() - cleanup_started, 6)
            for sig, handler in previous.items():
                signal.signal(sig, handler)
            if receipt is not None:
                try:
                    print(f"[watchdog] group={process.pid} reaped={evidence['reaped']} return={evidence.get('returnCode')} "
                          f"cleanup={evidence['cleanupOutcome']} check={evidence.get('postReapGroupCheck')}; "
                          "system services are outside this group", file=sys.stderr, flush=True)
                except Exception as error:
                    evidence.update(cleanupOutcome="failure", cleanupError=f"Cleanup receipt logging failed: {error}")

    try:
        while True:
            remaining = seconds - (time.monotonic() - started)
            if remaining <= 0:
                print(f"[watchdog] TIMEOUT {label} after {seconds:g}s", file=sys.stderr, flush=True)
                evidence.update(trigger="timeout", exitCode=124)
                stop_group()
                return 124
            try:
                result = process.wait(timeout=min(30, remaining))
                evidence.update(trigger="exit", reaped=True, returnCode=result, exitCode=result if result >= 0 else 128 - result)
                print(f"[watchdog] finished {label}; exit={result}; elapsed={time.monotonic()-started:.1f}s", file=sys.stderr, flush=True)
                return result if result >= 0 else 128 - result
            except subprocess.TimeoutExpired:
                print(f"[watchdog] waiting {label}; elapsed={time.monotonic()-started:.1f}s", file=sys.stderr, flush=True)
    except BaseException as error:
        code = getattr(error, "code", 130 if isinstance(error, KeyboardInterrupt) else 1)
        evidence.update(trigger="cancelled" if isinstance(code, int) and code >= 128 else "exception", exitCode=code)
        stop_group()
        raise
    finally:
        evidence["elapsedSeconds"] = round(time.monotonic() - started, 6)


def main():
    def cancelled(signum, frame):
        print(f"[watchdog] cancelled; signal={signum}", file=sys.stderr, flush=True)
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, cancelled)
    signal.signal(signal.SIGINT, cancelled)
    return run_bounded(sys.argv[2:], float(sys.argv[1]))


if __name__ == "__main__":
    sys.exit(main())
