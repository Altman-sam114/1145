# 测试规范

本文指导 Agent B 和 Agent C 为 `Desert Frontline` 选择验证层级。每次实现前必须先读本文件。

## 1. 默认策略

- 默认云端重验证，本机只跑轻量检查。
- 本轮固定使用 `main` 作为唯一上传、提交、推送和云端验证分支。
- Agent B 完成实现后在本机跑轻量检查，commit 后直接 `git push origin main`，由 GitHub Actions 执行 Xcode build 和结果包归档。
- Agent C 不只看 Agent B 文字汇报；必须下载 `origin/main` 最新 commit 对应的未加密 CI 结果包，核对 manifest、JUnit、日志和失败摘要。
- 只有人工明确说“本机测试”“本地 build”“本地 xcodebuild”“本地跑探针”等，本机完整构建或模拟器验证才成为默认路径。
- 纯文档修改仍需本地通过 `git diff --check`。

## 2. 本地轻量检查

### Probe / Fast

触发条件：

- 纯文档修改。
- 提交前快速检查。
- Agent C 验收开始时。
- GitHub Actions workflow、Xcode project 或脚本配置修改后的本地格式检查。

命令：

```sh
git diff --check
```

Xcode 工程配置修改时补充：

```sh
plutil -lint DesertFrontline.xcodeproj/project.pbxproj
```

GitHub Actions workflow 修改时补充：

```sh
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ci-results.yml"); puts "yaml ok"'
```

当前基线：

- 文档-only 任务最低要求通过 `git diff --check`。
- workflow 修改最低要求通过 YAML 解析。
- 本机轻量检查通过不等于游戏构建已通过；构建结论以云端结果包或人工要求的本机构建为准。

## 3. 云端重验证

### 触发条件

`.github/workflows/ci-results.yml` 在以下情况运行：

```yaml
on:
  push:
    branches:
      - main
  workflow_dispatch:
```

### 云端检查内容

GitHub Actions 负责运行：

- `git diff --check`，检查最新提交的空白和补丁残留。
- `plutil -lint DesertFrontline.xcodeproj/project.pbxproj`。
- generic iOS device build。
- 结果包生成和上传。

云端 Xcode build 命令：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project DesertFrontline.xcodeproj \
  -scheme DesertFrontline \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath .derivedData-ci \
  -resultBundlePath ci-results/DesertFrontline.xcresult \
  CODE_SIGNING_ALLOWED=NO \
  build
```

本机历史命令使用 `build/DerivedDataDevice`；云端为了避免污染工作区固定使用 `.derivedData-ci`。

### CI 结果包

结果包必须未加密，供 Agent C 下载复核，不复用任何带密码发布包。

最低内容：

- `ci-artifact-manifest.json`
- `ci-failure-summary.md`
- `junit.xml`
- `xcodebuild.log`
- `static-checks.log`
- `project-lint.log`
- `DesertFrontline.xcresult`

artifact 命名规则：

```text
desert-frontline-ci-${version}-${branch_slug}-${short_sha}-run${run_id}-attempt${run_attempt}
```

`ci-artifact-manifest.json` 至少记录：

- version
- branch
- commitSha / shortSha
- runId / runAttempt
- workflowName
- createdAt
- projectName
- scheme
- destination
- resultBundlePath
- junitPath
- buildLogPath
- failureSummaryPath
- staticChecksOutcome
- buildOutcome
- testOutcome
- projectSpecificReports

当前项目没有独立 XCTest target，所以 `testOutcome` 默认为 `skipped`；不要把没有运行的 XCTest 说成通过。

## 4. Agent B main 直推验证步骤

Agent B 默认步骤：

```sh
git fetch origin
git switch main
git pull --ff-only origin main
git status --short
```

实现并本地轻量检查后：

```sh
git add 相关文件
git commit -m "vX.Y: 简要说明本轮做了什么"
git push origin main
```

push 前必须确认：

- 当前分支是 `main`。
- 目标远端是 `origin/main`。
- `git status --short` 只包含本轮相关文件。
- 提交范围没有混入用户或其他 Agent 的无关改动。

如果没有 `origin`、没有网络、没有 push 权限或 GitHub Actions 不可用，必须明确写出阻塞点，不得伪装已完成云端验证。

## 5. Agent C 结果包验收步骤

Agent C 必须先有 GitHub 权限：

```sh
gh auth login
```

下载缓存位置：

```text
/private/tmp/desert-frontline-c-review-<run_id>/
```

下载并核对示例：

```sh
gh run view <run_id> --json headSha,headBranch,status,conclusion,runAttempt,workflowName
gh run download <run_id> --dir /private/tmp/desert-frontline-c-review-<run_id>/
```

必须核对：

- `headBranch` 是 `main`。
- `headSha` 等于 `origin/main` 最新 commit。
- manifest 的 `branch`、`commitSha`、`runId`、`runAttempt` 与 GitHub run 完全一致。
- `junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 可以打开并对应同一次 run。
- `buildOutcome=success` 且 workflow conclusion 成功，才可把云端构建视为通过。

CI 失败时，Agent C 输出退回清单；默认由 Agent B 在 `main` 上追加修复 commit 后再次 push。不要回滚式处理远端 `main`，除非人工明确要求。

## 6. 人工明确要求时的本机构建

项目是 iOS SwiftUI + SpriteKit app，当前没有独立 XCTest target。命令行验证以 Xcode build 为主。

推荐使用完整 Xcode 路径，避免命令行工具路径不一致：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
```

本机 generic iOS device build：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project DesertFrontline.xcodeproj \
  -scheme DesertFrontline \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath build/DerivedDataDevice \
  CODE_SIGNING_ALLOWED=NO \
  build
```

成功标准：输出包含 `** BUILD SUCCEEDED **`。

当前环境历史上 CoreSimulatorService 多次不可用；模拟器失败不能直接判定为源码回归。能启动模拟器时，UI、HUD、触摸交互改动需要补充人工交互检查。

## 7. 回归层级

### Smoke

触发条件：

- 任意 Swift 源码修改。
- Xcode 工程配置修改。
- 影响资源、入口、Scene 初始化或 build setting 的修改。

默认执行方式：

- Agent B 本机跑轻量检查后 push 到 `origin/main`。
- GitHub Actions 跑 generic iOS device build 并上传结果包。
- Agent C 下载结果包复核。

人工要求本机验证时，补充运行第 6 节本机构建命令。

### Stage Regression

触发条件：

- 修改战斗、移动、生产、经济、AI、迷雾、HUD、支援技能、任务或胜负逻辑。
- Agent A 提示词要求验证某条玩法链路。
- Smoke 通过但存在高风险行为变化。

默认执行方式：

- 云端 build 结果包是最低门槛。
- 能启动模拟器或真机时，补充人工检查。

人工检查清单：

- 启动 skirmish 后地图、HUD、小地图、迷雾显示正常。
- 选择、框选、移动、攻击、`HOLD`、`AMOV` 不互相破坏。
- 生产队列、建筑施工、集结点和经济收入仍工作。
- AI 能生产、占点、进攻并使用相关新能力。
- 若修改海战，检查潜艇隐身、声呐和海军路径。

### Full

触发条件：

- 大版本合并。
- 多系统联动修改。
- 发布前、人工要求或 Agent C 判断需要。

默认执行方式：

- 云端结果包通过。
- 有可用设备/模拟器时至少跑一局从开局到明显胜负趋势的 skirmish。

人工检查清单：

- 检查三类军种、支援技能、建造、生产、AI 进攻、任务阶段、HQ 胜负。
- 尝试 `SKRM` 重开，确认状态重置。

当前基线：

- 暂无自动化 Stage Regression 或 Full；依赖云端 generic build 加可用 iOS target 的人工检查。

## 8. 规则

- 每次实现前先读本文件。
- 默认从本地轻量检查开始，再由云端 Actions 重验证。
- 文档-only 修改可以不跑 Xcode build，但必须说明原因。
- 改 Swift 代码后必须至少获得云端 Smoke 结果包；人工明确要求时再补本机 Smoke。
- UI、HUD、触摸交互改动在构建外还应尽量做设备/模拟器检查；如果 CoreSimulatorService 不可用，要明确记录。
- 不得伪造测试结果。
- 新增测试方式、脚本、XCTest target 或验证流程时，必须更新本文、`README.md` 和必要的 `update_log.md`。
