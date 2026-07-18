# 测试规范

本文指导 Agent B 和 Agent C 为 `Desert Frontline` 选择验证层级。每次实现前必须先读本文件。

## 1. 默认策略

- 默认云端重验证，本机只跑轻量检查。
- 本轮固定使用 `main` 作为唯一上传、提交、推送和云端验证分支。
- Agent B 完成实现后在本机跑轻量检查，commit 后直接 `git push origin main`，由 GitHub Actions 执行 Xcode build 和结果包归档。
- Agent C 不只看 Agent B 文字汇报；必须下载 `origin/main` 最新 commit 对应的未加密 CI 结果包，核对 manifest、JUnit、日志和失败摘要。
- Agent X 循环下，每一轮仍必须遵守 Agent B 本地轻量检查、GitHub Actions artifact、Agent C 下载复判的顺序。
- Agent X 不得跳过 Agent C artifact 验收；失败时不得继续下一轮或伪装成功。
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
- iOS Simulator launch probe：额外构建 simulator app、安装到可用 iPhone simulator，并用 `DESERT_CI_HUD_PAGE=tactical/build/air/naval/support` 依次重启 App；五页截图分别为 `simulator-screenshot.png`、`simulator-hud-build.png`、`simulator-hud-air.png`、`simulator-hud-naval.png`、`simulator-hud-support.png`。随后以 tactical 页和 `DESERT_CI_COMMAND_MARKER=move/attack-move/attack-target` 再启动三次，生成 `simulator-command-move.png`、`simulator-command-attack-move.png`、`simulator-command-attack-target.png`；前八次均使用 `DESERT_CI_CAMERA_FOCUS=air`。第九次使用 tactical 页与 `DESERT_CI_CAMERA_FOCUS=land`，生成 `simulator-land-combat.png`，验证 Blue / Red Mechanic / Humvee / Tank / Artillery、双方维修链路、方向化扬尘、炮口 / 炮线和爆炸样本。第十次使用 tactical 页与 `DESERT_CI_CAMERA_FOCUS=coast`，生成 `simulator-map-terrain.png`，验证确定性沙地色差与低密度沙丘等高线 / 风纹、按正交邻格连续的道路肩 / 路床 / 标记、ridge 落影 / 亮暗面 / 碎石、oil 污环 / 裂纹、海岸浅水 / 泡沫、开阔水面、玩家海军航迹与水面命中样本。前十次启动都在等待后截图并用宿主机 `kill -0` 确认该次 PID 仍存活，最后统一抓取 App 日志；用于捕捉启动闪退 / 白屏黑屏、页签或动作丢失、单排溢出、HUD 遮挡、既有空战 / 命令 / 战斗证据缺失，以及工程模型 / 维修链路 / 地面模型 / 地貌层次 / 海岸与海军反馈探针缺失。任一截图或 PID 检查失败都会令 simulator launch probe 失败。所有 launch 都通过 `DESERT_CI_CAPTURE_MODE=1` 暂停经济、AI、战斗和胜负推进；air capture scene 保留既有空战证据，land capture scene 只在 CI 中编排地面单位和持久视觉样本，coast/default capture scene 复用既有玩家海军方向航迹与水面命中样本。普通 App 启动不设置这些变量，默认 `TACT`，三类 marker 使用短动画，初始单位、镜头和实时玩法不变。
- 第十一次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=combat-ui` 生成 `simulator-combat-ui.png`：四个玩家作战单位共享攻击约 43% HP 的敌方 Tank，其中一个处于 reload，用于核对右侧 `Combat / Engaged / Ready / Wounded / Critical / PRIMARY` 四行摘要、面板底部左对齐目标生命条、世界 `FOCUS n TNK 43%` 和八段耐久，同时保留 Mechanic 维修链路、炮线、爆炸与单排命令条。只有 combat-ui capture 会临时写共享目标、目标 HP 和 reload，普通 App 与原 land / coast / air capture 状态不变。
- 第十二次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=incoming-ui` 生成 `simulator-incoming-ui.png`：两个 Red Tank、Artillery 和 Humvee 共四个玩家已知攻击者分别锁定两个选中 Blue 目标，一个 Blue Tank 冻结在约 31% Critical HP，并冻结敌方炮线，用于核对标题与第四行 `IN` 数量、至少两个目标的红橙方向箭头 / `IN n` 标签、小地图告警外圈、Wounded / Critical 计数和镜像方向。workflow 总计十二次独立启动 / PID 存活检查；只有 incoming-ui capture 会临时写这些敌方目标、Blue Tank HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十三次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=naval-salvo` 生成 `simulator-naval-salvo.png`：单选 Blue Battleship 锁定约 47% HP Red Battleship 并冻结一个 reload，画面同时保留背景 Carrier、双方航迹、舰炮射程圈、两条分离炮迹 / 弹体 / 炮口闪光、Red 舰体闪光 / 火花和主 / 副水柱，用于核对分层舰体、两座双联装主炮、舰桥 / 舷窗 / 桅杆 / 雷达 / 二级火炮 / 救生艇、单选目标 HP / 距离 / reload 和单排命令条。workflow 总计十三次独立启动 / PID 存活检查；只有 naval-salvo capture 会临时写双方位置 / 目标、Red Battleship HP 和 reload，普通 App 与其他 capture 状态不变。
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
- `simulator-launch.log`
- `simulator-app.log`
- `simulator-screenshot.png`
- `simulator-hud-build.png`
- `simulator-hud-air.png`
- `simulator-hud-naval.png`
- `simulator-hud-support.png`
- `simulator-command-move.png`
- `simulator-command-attack-move.png`
- `simulator-command-attack-target.png`
- `simulator-land-combat.png`
- `simulator-map-terrain.png`
- `simulator-combat-ui.png`
- `simulator-incoming-ui.png`
- `simulator-naval-salvo.png`
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
- simulatorLaunchOutcome
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
- `buildOutcome=success`、`simulatorLaunchOutcome=success` 且 workflow conclusion 成功，才可把云端构建与启动探针视为通过。

CI 失败时，Agent C 输出退回清单；默认由 Agent B 在 `main` 上追加修复 commit 后再次 push。不要回滚式处理远端 `main`，除非人工明确要求。

## 6. Agent X 循环验证规则

Agent X 只负责调度和判断，不新增绕过验证的捷径。

每轮必须满足：

- Agent A 生成版本化提示词，明确本轮目标、非目标、关键文件、验证、CI、artifact 和 Agent C 验收要求。
- Agent B 从最新 `origin/main` 开始，在 `main` 上实现，先跑本地轻量检查，再 commit 并 push 到 `origin/main`。
- GitHub Actions 为本轮最新 commit 生成未加密 artifact。
- Agent C 下载并核对最新 `origin/main` run 的 artifact，确认 manifest、JUnit、日志、失败摘要和 run 元数据一致。
- Agent X 只能在 Agent C 明确验收通过后继续下一轮或宣布总目标完成。

失败处理：

- Agent C 验收失败时，Agent X 必须退回 Agent B 修复或暂停等待人工确认。
- 同一原因 CI 连续失败时，Agent X 必须暂停并说明失败原因，不得继续消耗轮次。
- 连续 2 轮无有效 diff 或连续 3 轮遇到同一阻塞时，Agent X 必须暂停或结束循环。
- 需要账号、权限、密钥、付费服务、人工产品决策或冲突归属判断时，Agent X 必须暂停等待人工。

## 7. 测试数据与下载容量限制

本项目默认采用小数据量验证策略，避免下载过大 artifact、模型、数据集、缓存或结果包，把本机、CI runner 或临时目录容量撑爆。

规则：

- 测试数据必须尽量小，只覆盖必要边界。
- CI artifact 只上传必要文件：manifest、JUnit 或测试摘要、关键日志、失败摘要、必要结果包。
- 不上传大体积 DerivedData、完整 build cache、无关截图、视频、模型文件、历史 artifact 或重复压缩包。
- Agent C 下载 artifact 前优先确认只下载最新 run 对应的必要结果包。
- 下载缓存默认放在 `/private/tmp/desert-frontline-c-review-<run_id>/`。
- 下载后应检查目录大小：

```sh
du -sh /private/tmp/desert-frontline-c-review-<run_id>/
```

- 禁止使用非 `Altman-sam114` 的 GitHub 账号伪装完成 push、CI 或 artifact 验收。
- 禁止默认下载大体积测试数据、模型、历史 artifact 或无关产物，导致本机或 CI 容量被撑爆。

## 8. 人工明确要求时的本机构建

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

## 9. 回归层级

### Smoke

触发条件：

- 任意 Swift 源码修改。
- Xcode 工程配置修改。
- 影响资源、入口、Scene 初始化或 build setting 的修改。

默认执行方式：

- Agent B 本机跑轻量检查后 push 到 `origin/main`。
- GitHub Actions 跑 generic iOS device build 并上传结果包。
- Agent C 下载结果包复核。

人工要求本机验证时，补充运行第 8 节本机构建命令。

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

## 10. 规则

- 每次实现前先读本文件。
- 默认从本地轻量检查开始，再由云端 Actions 重验证。
- 文档-only 修改可以不跑 Xcode build，但必须说明原因。
- 改 Swift 代码后必须至少获得云端 Smoke 结果包；人工明确要求时再补本机 Smoke。
- UI、HUD、触摸交互改动在构建外还应尽量做设备/模拟器检查；如果 CoreSimulatorService 不可用，要明确记录。
- 不得伪造测试结果。
- Agent X 循环不得跳过 Agent C 对最新 artifact 的复判。
- 新增测试方式、脚本、XCTest target 或验证流程时，必须更新本文、`README.md` 和必要的 `update_log.md`。
