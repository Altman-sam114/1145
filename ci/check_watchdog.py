"""Run only in CI: verify exit propagation and bounded process-group cleanup."""
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time

assert os.environ.get("GITHUB_ACTIONS") == "true", "Cloud-only regression"
watchdog = [sys.executable, "ci/run_bounded.py"]
for code in (0, 7):
    result = subprocess.run(watchdog + ["10", sys.executable, "-c", f"raise SystemExit({code})"], timeout=15)
    assert result.returncode == code, result.returncode
with tempfile.TemporaryDirectory() as directory:
    sentinel = Path(directory) / "child-survived"
    child = f"import time; from pathlib import Path; time.sleep(5); Path({str(sentinel)!r}).touch()"
    parent = f"import subprocess, sys, time; subprocess.Popen([sys.executable, '-c', {child!r}]); time.sleep(30)"
    result = subprocess.run(watchdog + ["1", sys.executable, "-c", parent], timeout=10)
    assert result.returncode == 124, result.returncode
    time.sleep(5)
    assert not sentinel.exists(), "Timed-out descendant survived"
with tempfile.TemporaryDirectory() as directory:
    ready = Path(directory) / "ready"
    sentinel = Path(directory) / "cancelled-child-survived"
    child = f"import time; from pathlib import Path; Path({str(ready)!r}).touch(); time.sleep(5); Path({str(sentinel)!r}).touch()"
    parent = f"import subprocess, sys, time; subprocess.Popen([sys.executable, '-c', {child!r}]); time.sleep(30)"
    process = subprocess.Popen(watchdog + ["20", sys.executable, "-c", parent])
    try:
        deadline = time.monotonic() + 5
        while not ready.exists() and time.monotonic() < deadline:
            time.sleep(0.05)
        assert ready.exists(), "Cancellation fixture did not start"
        process.send_signal(signal.SIGTERM)
        time.sleep(0.1)
        process.send_signal(signal.SIGTERM)
        assert process.wait(timeout=5) == 143
        time.sleep(5)
        assert not sentinel.exists(), "Cancelled descendant survived"
    finally:
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=5)
print("watchdog regression: 5 cases passed (success, nonzero, timeout, descendant cleanup, repeated SIGTERM descendant cleanup)", flush=True)
