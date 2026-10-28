#!/usr/bin/env python3
"""Always package truthful outcomes, including interrupted/missing probe evidence."""
import datetime
import json
import os
from pathlib import Path
import xml.etree.ElementTree as ET

from simulator_probe import (load_probes, validate_boot, validate_hud_contract, validate_installation,
                             validate_results, validate_scene_evidence)


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
    install_integrity = "failure"
    install_error = "Install evidence or runner summary unavailable"
    boot_integrity = "failure"
    boot_error = "Boot evidence or runner summary unavailable"
    scene_integrity = "failure"
    scene_error = "Scene readiness or runner summary unavailable"
    integrity_error = ""
    try:
        probes = load_probes()
        summary = json.loads((results / "simulator-probe-summary.json").read_text())
        if any(summary.get(key) != value for key, value in identity.items()):
            raise ValueError("Probe summary identity does not match this run/attempt/commit/version")
        try:
            validate_boot(summary, probes, results)
            boot_integrity, boot_error = "success", ""
        except Exception as error:
            boot_error = str(error)
        try:
            validate_installation(summary, probes, results)
            install_integrity, install_error = "success", ""
        except Exception as error:
            install_error = str(error)
        try:
            validate_scene_evidence(probes, summary, results)
            scene_integrity, scene_error = "success", ""
        except Exception as error:
            scene_error = str(error)
        try:
            validate_hud_contract(summary, results)
            hud_integrity, hud_error = "success", ""
        except Exception as error:
            hud_error = str(error)
        if any(outcome != "success" for outcome in (boot_integrity, install_integrity, scene_integrity, hud_integrity)):
            raise ValueError("; ".join(error for error in (boot_error, install_error, scene_error, hud_error) if error))
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
        ("simulator-install", install_integrity, "simulator-probe-summary.json"),
        ("scene-readiness", scene_integrity, "simulator-probe-summary.json"),
        ("simulator-boot", boot_integrity, "simulator-probe-summary.json"),
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
               "ci-regression-results.json", "probes.json", "hud-layout-contract.json", "simulator-launch-help.log",
               "render-diagnostics.json", "diagnostic-world.png", "diagnostic-hud.png",
               "unit-art-source.json", "unit-art-bundle.json", "unit-art-bundle.log"] + [probe["png"] for probe in probes]
    installation = summary.get("installation", {})
    boot = summary.get("boot", {})
    for record in boot.get("commands", []):
        path = record.get("output", {}).get("path")
        if path and Path(path).name == path:
            reports.append(path)
    for record in installation.get("attempts", []) + ([installation["recovery"]] if installation.get("recovery") else []):
        path = record.get("output", {}).get("path")
        if path and Path(path).name == path:
            reports.append(path)
    scenes = [record["scene"] for record in summary.get("prewarm", []) + summary.get("probes", []) if record.get("scene")]
    for scene in scenes:
        for evidence in [scene.get(key, {}) for key in ("stdout", "stderr")] + list(scene.get("directFiles", {}).values()):
            path = evidence.get("path")
            if path and Path(path).name == path:
                reports.append(path)
    manifest = dict(identity, shortSha=identity["commitSha"][:12], workflowName=os.environ["WORKFLOW_NAME"],
                    createdAt=datetime.datetime.now(datetime.timezone.utc).isoformat(), projectName="Desert Frontline",
                    scheme="DesertFrontline", destination="generic/platform=iOS",
                    resultBundlePath="ci-results/DesertFrontline.xcresult", junitPath="ci-results/junit.xml",
                    buildLogPath="ci-results/xcodebuild.log", simulatorLaunchLogPath="ci-results/simulator-launch.log",
                    failureSummaryPath="ci-results/ci-failure-summary.md", probeSummaryPath="ci-results/simulator-probe-summary.json",
                    hudLayoutContractPath="ci-results/hud-layout-contract.json", hudLayoutContractOutcome=hud_integrity,
                    simulatorInstallOutcome=install_integrity,
                    simulatorBootOutcome=boot_integrity,
                    sceneReadinessOutcome=scene_integrity,
                    renderDiagnosticsPath="ci-results/render-diagnostics.json",
                    renderDiagnosticsCollectionStatus=summary.get("renderDiagnostics", {}).get("collectionStatus", "unavailable"),
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
              f"- Boot: {boot_integrity}; {boot_error or 'same-device monitor-only bootstatus, normal final exit0, CLI receipts and reserved deadline verified'}",
              f"- Boot last stage: {boot.get('lastStage', 'none')}; stop reason: {boot.get('stopReason', 'none')}",
              f"- Installation: {install_integrity}; {install_error or 'bounded same-device attempts, successful exit0 and CLI receipts verified'}",
              f"- Install stop reason: {installation.get('stopReason', 'none')}",
              f"- HUD contract: {hud_integrity}; {hud_error or '25 Swift production frame/route cases; state restored; prewarm producer verified'}",
              f"- Scene readiness: {scene_integrity}; {scene_error or '24 distinct launch nonces, bound production stages/two stable frames, frozen direct trace and first-five page PNGs verified'}",
              f"- Offscreen diagnostics (non-gating): {summary.get('renderDiagnostics', {}).get('collectionStatus', 'unavailable')}; "
              f"producer={summary.get('renderDiagnostics', {}).get('producerStatus', 'unavailable')}; "
              f"{summary.get('renderDiagnostics', {}).get('error', 'not screen-presentation evidence; see render-diagnostics.json')}",
              f"- Integrity detail: {integrity_error or '24 complete launches, live PIDs, raw/rotation evidence, landscape PNGs and current HUD contract'}",
              "- XCTest: skipped (no XCTest target exists)",
              "- Forced runner destruction/GitHub cancellation can prevent final evidence upload."]
    lines += [f"- Boot {record.get('role', 'unknown')}: status={record.get('status', 'unknown')} "
              f"exit={record.get('exitCode', 'unavailable')} elapsed={record.get('elapsedSeconds', 'unavailable')}s "
              f"requested/effective cap={record.get('requestedCapSeconds', 'unavailable')}/{record.get('effectiveCapSeconds', 'unavailable')}s "
              f"remaining={record.get('remainingStartSeconds', 'unavailable')}->{record.get('remainingEndSeconds', 'unavailable')}s "
              f"classification={record.get('classification', 'none')} continuation={record.get('continuationDecision', 'none')} "
              f"output={record.get('output', {})}"
              for record in boot.get("commands", [])]
    lines += [f"- Boot admission {record.get('phase', 'unknown')}: allowed={record.get('allowed')} "
              f"remaining={record.get('remainingSeconds')}s cap={record.get('maxCapSeconds')}s "
              f"install/CLI reserves={record.get('installReserveSeconds')}/{record.get('cliCleanupReserveSeconds')}s"
              for record in boot.get("admissions", [])]
    lines += [f"- Scene {scene.get('probeID', 'unknown')}: nonce={scene.get('nonce', 'unknown')} pid={scene.get('pid', 'unavailable')} "
              f"status={scene.get('status', 'unknown')} lastStage={scene.get('lastStage', 'unavailable')} "
              f"sealed={scene.get('sealed', False)} stdout={scene.get('stdout', {})} stderr={scene.get('stderr', {})}"
              for scene in scenes]
    (results / "ci-failure-summary.md").write_text("\n".join(lines) + "\n")
    artifact_name = (f"desert-frontline-ci-{identity['version']}-{identity['branch'].lower().replace('/', '-')}-"
                     f"{identity['commitSha'][:12]}-run{identity['runId']}-attempt{identity['runAttempt']}")
    with open(os.environ["GITHUB_OUTPUT"], "a") as output:
        output.write(f"artifact_name={artifact_name}\nintegrity_outcome={integrity}\n")
    print(f"Packaged {artifact_name}; integrity={integrity}", flush=True)


if __name__ == "__main__":
    main()
