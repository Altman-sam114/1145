#!/usr/bin/env python3
"""Always package truthful outcomes, including interrupted/missing probe evidence."""
import datetime
import json
import os
from pathlib import Path
import xml.etree.ElementTree as ET

from simulator_probe import load_probes, validate_hud_contract, validate_results


def main():
    results = Path("ci-results")
    results.mkdir(exist_ok=True)
    identity = {"version": os.environ.get("CI_VERSION", "unversioned"), "branch": os.environ["GITHUB_REF_NAME"],
                "commitSha": os.environ["GITHUB_SHA"], "runId": os.environ["GITHUB_RUN_ID"],
                "runAttempt": os.environ["GITHUB_RUN_ATTEMPT"]}
    probes = []
    summary = {}
    integrity = "failure"
    hud_integrity = "failure"
    hud_error = "HUD contract or runner summary unavailable"
    integrity_error = ""
    try:
        probes = load_probes()
        summary = json.loads((results / "simulator-probe-summary.json").read_text())
        if any(summary.get(key) != value for key, value in identity.items()):
            raise ValueError("Probe summary identity does not match this run/attempt/commit/version")
        try:
            validate_hud_contract(summary, results)
            hud_integrity, hud_error = "success", ""
        except Exception as error:
            hud_error = str(error)
            raise
        if summary.get("status") != "success" or summary.get("integrityOutcome") != "success":
            raise ValueError(summary.get("error", "Probe runner did not complete its integrity gate"))
        if summary.get("counts") != {"expected": 24, "completed": 24, "failed": 0, "notRun": 0, "running": 0}:
            raise ValueError("Probe completion counts are not 24/24")
        if not any(item.get("status") == "success" and item.get("aliveAfterWait") is True for item in summary.get("prewarm", [])):
            raise ValueError("Successful prewarm evidence missing")
        validate_results(probes, summary, results)
        integrity = "success"
    except Exception as error:
        integrity_error = str(error)
        print(f"Artifact integrity: failure: {error}", flush=True)
    if not (results / "simulator-probe-summary.json").exists():
        summary = dict(identity, status="failure", failureStage="runner-not-started-or-interrupted",
                       error="Runner summary missing; no simulator success can be inferred",
                       probes=[dict(probe, status="not_run") for probe in probes])
        (results / "simulator-probe-summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    simulator_step_outcome = os.environ.get("SIMULATOR_LAUNCH_OUTCOME", "unknown")
    simulator_outcome = simulator_step_outcome if integrity == "success" else "failure"
    checks = [
        ("static-checks", os.environ.get("STATIC_OUTCOME", "unknown"), "static-checks.log"),
        ("project-lint", os.environ.get("PROJECT_LINT_OUTCOME", "unknown"), "project-lint.log"),
        ("xcode-build", os.environ.get("BUILD_OUTCOME", "unknown"), "xcodebuild.log"),
        ("simulator-launch", simulator_outcome, "simulator-launch.log"),
        ("probe-artifact-integrity", integrity, "simulator-probe-summary.json"),
        ("hud-layout-contract", hud_integrity, "hud-layout-contract.json"),
    ]
    suite = ET.Element("testsuite", name="DesertFrontlineCI", tests=str(len(checks) + 1),
                       failures=str(sum(outcome != "success" for _, outcome, _ in checks)), skipped="1")
    for name, outcome, log in checks:
        case = ET.SubElement(suite, "testcase", classname="DesertFrontlineCI", name=name)
        if outcome != "success":
            ET.SubElement(case, "failure", message=outcome).text = f"See ci-results/{log}"
    case = ET.SubElement(suite, "testcase", classname="DesertFrontlineCI", name="xctest")
    ET.SubElement(case, "skipped", message="No XCTest target exists in the current project")
    ET.ElementTree(suite).write(results / "junit.xml", encoding="utf-8", xml_declaration=True)
    reports = ["DesertFrontline.xcresult", "simulator-launch.log", "simulator-build.log", "simulator-app.log",
               "simulator-runtimes.json", "simulator-boot-state.json", "simulator-probe-summary.json",
               "ci-regression-results.json", "probes.json", "hud-layout-contract.json"] + [probe["png"] for probe in probes]
    manifest = dict(identity, shortSha=identity["commitSha"][:12], workflowName=os.environ["WORKFLOW_NAME"],
                    createdAt=datetime.datetime.now(datetime.timezone.utc).isoformat(), projectName="Desert Frontline",
                    scheme="DesertFrontline", destination="generic/platform=iOS",
                    resultBundlePath="ci-results/DesertFrontline.xcresult", junitPath="ci-results/junit.xml",
                    buildLogPath="ci-results/xcodebuild.log", simulatorLaunchLogPath="ci-results/simulator-launch.log",
                    failureSummaryPath="ci-results/ci-failure-summary.md", probeSummaryPath="ci-results/simulator-probe-summary.json",
                    hudLayoutContractPath="ci-results/hud-layout-contract.json", hudLayoutContractOutcome=hud_integrity,
                    staticChecksOutcome=checks[0][1], projectLintOutcome=checks[1][1], buildOutcome=checks[2][1],
                    simulatorLaunchOutcome=simulator_outcome, simulatorStepOutcome=simulator_step_outcome,
                    probeIntegrityOutcome=integrity, testOutcome="skipped",
                    projectSpecificReports=[f"ci-results/{report}" for report in reports])
    (results / "ci-artifact-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    lines = ["# Desert Frontline CI Failure Summary", ""]
    lines += [f"- {key}: {value}" for key, value in identity.items()]
    lines += [f"- {name}: {outcome} (ci-results/{log})" for name, outcome, log in checks]
    lines += [f"- Raw simulator step: {simulator_step_outcome}",
              f"- Failure stage: {summary.get('failureStage', 'none')}",
              f"- Last completed probe: {summary.get('lastCompletedProbe', 'none')}",
              f"- Probe counts: {summary.get('counts', 'unavailable')}",
              f"- HUD contract: {hud_integrity}; {hud_error or '25 Swift production frame/route cases; state restored; prewarm producer verified'}",
              f"- Integrity detail: {integrity_error or '24 complete launches, live PIDs, raw/rotation evidence, landscape PNGs and current HUD contract'}",
              "- XCTest: skipped (no XCTest target exists)",
              "- Forced runner destruction/GitHub cancellation can prevent final evidence upload."]
    (results / "ci-failure-summary.md").write_text("\n".join(lines) + "\n")
    artifact_name = (f"desert-frontline-ci-{identity['version']}-{identity['branch'].lower().replace('/', '-')}-"
                     f"{identity['commitSha'][:12]}-run{identity['runId']}-attempt{identity['runAttempt']}")
    with open(os.environ["GITHUB_OUTPUT"], "a") as output:
        output.write(f"artifact_name={artifact_name}\nintegrity_outcome={integrity}\n")
    print(f"Packaged {artifact_name}; integrity={integrity}", flush=True)


if __name__ == "__main__":
    main()
