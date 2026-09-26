"""Run only in CI: verify exit propagation and bounded process-group cleanup."""
import os
from pathlib import Path
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
    time.sleep(3)
    assert not sentinel.exists(), "Timed-out descendant survived"
print("watchdog regression: success, nonzero, timeout, descendant cleanup passed", flush=True)
