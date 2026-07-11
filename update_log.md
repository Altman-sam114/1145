# 项目版本更新记录

本文记录 `Desert Frontline` 的正式版本、重要维护事项、关键决策和遗留问题。它不是流水账，只保留影响后续开发判断的信息。

## 维护规则

- 每完成一个正式版本或重要任务后追加记录。
- 记录必须包含：版本/任务名、日期、核心变更、关键文件、验证结果、遗留事项。
- 文档整理、目录迁移、回滚、打捞等写入“历史维护记录”，不要伪装成新玩法版本。
- 若核心逻辑、测试规范或项目行为变化，必须同步更新本文。
- 测试结果必须写具体命令和结论；不得只写“已验证”。

## 当前状态

日期：2026-07-05

当前项目已经是一个可构建的 iOS RTS 原型，覆盖经济、建造、地图控制、旗点前线建造覆盖、雷达前哨、声呐浮标、防御炮塔、防空阵地、岸防炮、机动防空、陆军、空军、海军、战舰、航母、AI、地图、战争迷雾、老兵经验、支援技能、HUD、任务阶段和 HQ 胜负条件。当前主要逻辑集中在 `DesertFrontline/GameScene.swift`。

当前协作流程已升级为 `main` 直推触发 GitHub Actions 云端验证，并由 Agent C 下载未加密 CI 结果包复核。当前可靠构建命令仍是 generic iOS device build：

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

遗留事项：

- 移动端实际手感仍需要真机或可用模拟器验证。
- 当前没有独立 XCTest target 或自动化玩法回归，Stage / Full 回归仍依赖云端 build 加人工设备或模拟器检查。
- AI 战术分工、平衡、海军/航母深度和建筑科技层仍可继续增强。

## 历史记录

### 初始可玩原型

日期：2026-06-28 前

核心变更：

- 建立 iOS SwiftUI + SpriteKit RTS 原型。
- 实现等距沙漠地图、经济、建造、生产、陆海空单位、航母生产、海战、支援技能、战争迷雾、HUD、小地图、AI、任务阶段和 HQ 胜负。

关键文件：

- `README.md`
- `DesertFrontline/GameScene.swift`
- `DesertFrontline/GameView.swift`
- `DesertFrontline/DesertFrontlineApp.swift`
- `DesertFrontline.xcodeproj/project.pbxproj`

验证结果：

- README 记录：generic iOS device build succeeds。
- 当前环境历史上 CoreSimulatorService 不可用，模拟器启动未确认。

遗留事项：

- Git 历史很少，不能依赖提交推断功能演进；必须读取当前代码。

### v0.1 / 建立多 Agent 迭代文档体系

日期：2026-06-28

核心变更：

- 建立“人工目标 -> Agent A 设计提示词 -> Agent B 实现测试 -> Agent C 验收并更新核心逻辑文档 -> 人工复核 -> 下一轮”的长期迭代工作流。
- 将入口规则、历史记录、测试规范、核心流程和提示词目录拆分到标准位置。

关键文件：

- `AGENTS.md`
- `update_log.md`
- `md/prompt/README.md`
- `md/test/test.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`

验证结果：

- 仅文档变更，未运行 Xcode 构建。
- 需运行 `git diff --check` 作为静态检查。

遗留事项：

- 下一轮功能开发建议从老兵/经验系统开始，先由 Agent A 生成版本化实现提示词。

### v0.2 / 明确 Agent C 通过后版本提交规则

日期：2026-06-29

核心变更：

- Agent C 验收不通过时必须列出阻塞问题并退回 Agent B，不创建 git commit。
- Agent C 验收通过后必须更新核心文档和日志，并按版本号自动创建 git commit。
- commit subject 统一为 `版本号: 简要说明`，commit body 简要概括本版本工作内容、影响范围和验证结果。

关键文件：

- `AGENTS.md`
- `md/flow/flowchart.md`
- `README.md`
- `update_log.md`

验证结果：

- 仅文档变更，需运行 `git diff --check`。

遗留事项：

- 本规则从后续 Agent C 验收任务开始执行；普通文档编辑任务不自动提交，除非本轮角色就是 Agent C 且验收通过。

### v0.3 / 协作流程升级为 main 直推与云端结果包验收

日期：2026-07-03

核心变更：

- 将默认协作验证从本机完整构建改为本地轻量检查 + `main` 直推 + GitHub Actions 云端重验证。
- 明确 `agenta` / `a:`、`agentb` / `b:`、`agentc` / `c:` 召唤规则和 Agent A/B/C 最终回复身份标识。
- 明确 Agent B 基于最新 `origin/main` 在 `main` 上实现、commit、push；Agent C 下载未加密结果包，核对 manifest、JUnit、日志和失败摘要。
- 新增 `ci-results` workflow 设计，上传 Agent C 可追溯复核的 CI 结果包。
- 明确本轮制度不引入 `smalldata_test`、`develop`、`codeb/...`、候选分支或 PR 合并流，也不复制 AITRANS 的项目特例。

关键文件：

- `AGENTS.md`
- `README.md`
- `md/prompt/README.md`
- `md/test/test.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `.github/workflows/ci-results.yml`
- `update_log.md`

验证结果：

- 本轮是流程和 CI 改造，不涉及业务逻辑。
- 需运行 `git diff --check`、`plutil -lint DesertFrontline.xcodeproj/project.pbxproj` 和 workflow YAML 解析。
- 本地仓库当前没有 `origin` 远端，无法在本机完成真实 `git push origin main`、GitHub Actions run 和 artifact 下载复核；该限制必须在最终交付中说明，不得伪装为云端已通过。

遗留事项：

- 配置 `origin` 后，需要执行首次真实 `main` push，等待 `ci-results` workflow，下载 `/private/tmp/desert-frontline-c-review-<run_id>/` 下的结果包并核对 manifest。

### v0.5 / 引入 Agent X 循环迭代文档基线

日期：2026-07-04

核心变更：

- 新增 Agent X 召唤、职责、循环判断和停止条件。
- 将现有 Agent A/B/C 云端验证流程扩展为可被 Agent X 多轮调度。
- 更新 flow、flowchart、test、prompt README 和 README 中的协作说明。
- 明确本轮只做文档准备，不启动真实自动循环。

关键文件：

- `AGENTS.md`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/test/test.md`
- `md/prompt/README.md`
- `md/prompt/v0（协作自动化）/v0.5（引入AgentX循环迭代）.md`
- `update_log.md`

验证结果：

- `git diff --check` 通过。

遗留事项：

- 后续人工可用 `agentx:` 提供总目标 X，启动 Agent X 主控循环。
- Agent X 真正执行循环时，仍必须经过 Agent A 提示词、Agent B 实现 push、Agent C 云端 artifact 验收。

### v1.0 / 实现老兵经验系统

日期：2026-07-04

核心变更：

- 新增 `VeterancyRank`，按 XP 计算 Recruit / Hardened / Veteran / Elite 四档等级，不保存第二份可变等级状态。
- 直接开火击杀会为可移动作战单位增加 `killCount` 和 `veterancyXP`，支援技能击杀不计入任何单位 XP。
- 老兵等级影响有效伤害、攻击冷却和玩家视野，玩家与 AI 共享同一套 `fire`、有效数值和授 XP 逻辑。
- 非 Recruit 单位显示 SpriteKit 头顶徽章，徽章作为实体节点子节点随战争迷雾隐藏。
- 选择面板显示单体等级、XP、击杀、有效攻击/视野和多选等级分布。
- `README.md`、`md/flow/flow.md` 和 `md/flow/flowchart.md` 已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.0（实现老兵经验系统）.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 提交并推送：`551f9eb182e7b8ea8b65f2f5abfef451141f15f3`，commit subject 为 `v1.0: 实现老兵经验系统`。
- Agent C 复核：`git fetch origin` 成功；本地 `main`、`origin/main` 和 Actions run head SHA 均为 `551f9eb182e7b8ea8b65f2f5abfef451141f15f3`；`git diff --check` 通过。
- GitHub Actions：run `28671220109`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v1.0-main-551f9eb182e7-run28671220109-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28671220109/` 并核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，老兵击杀、徽章、HUD 和 `SKRM` 重置仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续微调老兵等级阈值、加成强度和 AI 对高等级单位的战术使用。

### v1.1 / 引入雷达前哨

日期：2026-07-04

核心变更：

- 新增 `EntityKind.radarOutpost` / Radar Outpost / `RAD`，作为可建造、可攻击、不可生产单位的普通陆地结构。
- `BASE` 建造轮换加入 Radar Outpost；玩家与 AI 共享现有施工、资金扣除、血条、死亡清理和缺失建筑补建链路。
- 未完工结构不会贡献视野、支援资产或基地覆盖；Radar Outpost 完工后提供 9 格静态视野，并可作为 `SCAN` 资产。
- `SCAN` 资产检查和 HUD 文案同步为 operational HQ 或 Radar Outpost；没有引入费用、冷却、半径折扣或科技树。
- Radar Outpost 已纳入选择信息、战略价值、AI 目标评分、README 和核心流程文档。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.1（引入雷达前哨）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 提交并推送：`6d00cb614addba4b76ab296eef3014efec0fd1d3`，commit subject 为 `v1.1: 引入雷达前哨`。
- Agent C 复核：`git fetch origin` 成功；本地 `main`、`origin/main` 和 Actions run head SHA 均为 `6d00cb614addba4b76ab296eef3014efec0fd1d3`；`git diff --check` 通过。
- GitHub Actions：run `28682629001`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v1.1-main-6d00cb614add-run28682629001-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28682629001/` 并核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Radar Outpost 的放置、未完工/完工视野、`SCAN` 资产失效、AI 补建、摧毁清理和 `SKRM` 重置仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展建筑科技层，例如科技中心、防御塔、SAM、岸防炮或 Radar Outpost 平衡，但这些不属于 v1.1。

### v1.2 / 引入防御炮塔

日期：2026-07-04

核心变更：

- 新增 `EntityKind.guardTower` / Guard Tower / `GT`，作为可由 `BASE` 轮换建造的普通陆地防御结构。
- Guard Tower 复用现有施工、资金扣除、血条、选择、死亡清理、迷雾隐藏和 AI 缺失建筑补建链路，不生产单位、不赚钱、不设置 rally point，也不作为支援技能资产。
- 未完工攻击型结构在 `updateCombat(dt:)` 中会清理攻击目标和计时器并跳过战斗，统一保证施工中结构不能搜索目标、保留目标或开火。
- Guard Tower 完工后共享 `canAttack(_:)`、目标搜索、`isKnownToFaction(...)` 和 `fire(attacker:target:)` 链路，自动攻击可见 land / air / structure 目标，不攻击 naval / submarine，不提供声呐。
- Guard Tower 已纳入选择信息、战略价值、AI 目标评分、README 和核心流程文档；HQ 胜负、任务阶段、经济、支援资产、单位生产列表和潜艇侦测链路保持不变。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.2（引入防御炮塔）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 提交并推送：`a214f35b62ff87ab9c71b2c4d04e0781711144da`，commit subject 为 `v1.2: 引入防御炮塔`。
- Agent C 复核：`git fetch origin` 成功；本地 `main`、`origin/main` 和 Actions run head SHA 均为 `a214f35b62ff87ab9c71b2c4d04e0781711144da`；`git diff --check 8f05554..a214f35b62ff87ab9c71b2c4d04e0781711144da` 通过。
- GitHub Actions：run `28702698407`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v1.2-main-a214f35b62ff-run28702698407-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28702698407/` 并核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Guard Tower 的 `BASE` 放置、未完工禁火/无视野、完工自动攻击、naval/submarine 排除、AI 补建、摧毁清理和 `SKRM` 重置仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展建筑科技层，例如科技中心、SAM、岸防炮、升级系统或 Guard Tower 平衡，但这些不属于 v1.2。

### v1.3 / 支持双击同类选择

日期：2026-07-04

核心变更：

- 玩家双击己方机动单位时，会选择当前摄像机视野内同 `kind` 的己方存活非结构单位。
- 同类选择使用当前相机位置、缩放和场景尺寸计算世界可见矩形，不退化为全地图选择。
- 双击建筑、敌方、中立实体或地面不会触发同类选择；pending 支援、建筑、集结点和 `AMOV` 模式仍优先于普通世界点击。
- 单击选择、框选、HUD、小地图、双指平移缩放、攻击命令、地面移动、集结点和 `SKRM` 重开链路保持原有状态流。
- README、flow 和 flowchart 已同步当前真实输入行为；Agent B 未预写本正式记录。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.3（双击同类选择）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 提交并推送：`bc89f7e8cb2240f8ef53dc09c5a52305d2ee807b`，commit subject 为 `v1.3: 支持双击同类选择`。
- Agent C 复核：`git fetch origin` 成功；本地 `main`、`origin/main` 和 Actions run head SHA 均为 `bc89f7e8cb2240f8ef53dc09c5a52305d2ee807b`；`git diff --check` 通过。
- GitHub Actions：run `28703292884`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v1.3-main-bc89f7e8cb22-run28703292884-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28703292884/` 并核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，双击 Tank / Humvee / Artillery / Mechanic / Helicopter / Fighter / Battleship / Submarine / Carrier 的屏幕内同类选择、屏幕外排除、建筑双击退化为单选、pending 模式和 `SKRM` 重置仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展控制编队、命令按钮高亮或非法命令反馈，但这些不属于 v1.3。

### v1.4 / 高亮命令按钮状态

日期：2026-07-04

核心变更：

- `BASE`、`RLY`、`AMOV`、`SCAN`、`REPR`、`AIRS` 和 `BARR` 在等待地图目标时显示明显 stroke/glow 高亮。
- 按钮高亮直接由 `pendingConstructionKind`、`isSettingRallyPoint`、`isSettingAttackMove` 和 `pendingSupportPower` 推导，不保存第二份 active 状态。
- `layoutHUD()` 重建 HUD 后会重新缓存当前按钮 shape 并刷新样式；`updateHUD()` 刷新 subtitle/cooldown 文案后也会刷新样式。
- 按钮命中区域、subtitle、支援冷却文案、pending 清理、触摸优先级、双击同类选择、移动/攻击/集结点/支援目标和游戏规则保持原有状态流。
- README、flow 和 flowchart 已同步当前真实 HUD 行为；Agent B 未预写本正式记录。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.4（命令按钮状态高亮）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 提交并推送：`c780ca0bbdcc25070f9557174586fc7d9a8775c1`，commit subject 为 `v1.4: 高亮命令按钮状态`。
- Agent C 复核：`git fetch origin` 成功；本地 `main`、`origin/main` 和 Actions run head SHA 均为 `c780ca0bbdcc25070f9557174586fc7d9a8775c1`；`git diff --check` 与 `git diff --check c780ca0bbdcc25070f9557174586fc7d9a8775c1^ c780ca0bbdcc25070f9557174586fc7d9a8775c1` 通过。
- GitHub Actions：run `28704548004`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v1.4-main-c780ca0bbdcc-run28704548004-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28704548004/` 并核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`BASE` / `RLY` / `AMOV` / 支援按钮高亮进入和清理、无效支援目标保留 pending、HUD 尺寸变化、`SKRM` 重置和 v1.3 双击同类选择仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展控制编队、非法命令反馈或按钮禁用态，但这些不属于 v1.4。

### v1.5 / 增加非法命令反馈

日期：2026-07-04

核心变更：

- 新增 `showDeniedMarker(at:reason:)`，在 `effectsLayer` 生成短生命周期红橙拒绝标记和短码 label，自动淡出移除，不保存持久状态。
- 建筑放置失败、玩家支援目标失败、失效 `RLY`、失效 `AMOV`、可见敌人但选中单位全不能攻击、选中非移动且非 rally 来源实体后点击空地时，会在世界点击位置补充 denied marker。
- 非法命令反馈只补充 `showMessage(...)`，不改变建筑合法性、支援费用/冷却/资产、pending 清理语义、迷雾边界、移动/攻击规则、AI 内部失败路径或 `SKRM` 重置链路。
- 普通攻击分支不再在没有任何选中单位能攻击目标时误报 `Attack order`，改为显示 `NO ATK` 和简短 HUD 文案，并保持选择与单位命令不变。
- README、flow 和 flowchart 已同步当前真实输入反馈行为；Agent B 未预写本正式记录。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.5（非法命令反馈）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 提交并推送：`4214af67969823990a4f540a389addfc2f786599`，commit subject 为 `v1.5: 增加非法命令反馈`。
- Agent C 复核：`git fetch origin` 成功；本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `4214af67969823990a4f540a389addfc2f786599`；`gh` 当前认证账号为 `Altman-sam114`；`git diff --check 4214af67969823990a4f540a389addfc2f786599^ 4214af67969823990a4f540a389addfc2f786599` 通过。
- GitHub Actions：run `28705182303`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v1.5-main-4214af679698-run28705182303-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28705182303/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=4214af67969823990a4f540a389addfc2f786599`、`runId=28705182303`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，建筑失败、支援失败、失效 `RLY` / `AMOV`、不可攻击敌人、非移动实体点地面、无选中空地点击不刷 marker、v1.4 按钮高亮保留和 `SKRM` 清理仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展控制编队、按钮禁用态或音效反馈，但这些不属于 v1.5。

### v1.6 / 控制组快速编队

日期：2026-07-04

核心变更：

- 底部 HUD 新增 `G1` / `G2` 控制组按钮，放在 `ARMY` 后作为触控编队入口。
- HUD 单击 `G1` / `G2` 会延迟召回对应控制组，以避免双击保存时第一下误触发召回；召回会过滤仍存活、玩家阵营、非结构的机动单位并回写 live ID 集。
- HUD 双击 `G1` / `G2` 会保存当前玩家机动单位选择的 ID 集；空选择或结构-only 选择不会覆盖旧组，也不改变当前选择。
- 控制组操作会清理 pending 建筑、支援技能、集结点、attack-move 和 construction preview；召回空组不会清空当前选择。
- 死亡清理会从控制组移除已清理 ID；`SKRM` 重开会取消待召回动作、重置召回 token 并清空两个控制组。
- README、flow 和 flowchart 已同步控制组保存/召回、subtitle 和 `SKRM` 重置行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.6（控制组快速编队）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`6fde9ab91b4e0dba9475f59213cb0a30acad5e4b`，commit subject 为 `v1.6: 增加控制组快速编队`；对应 GitHub Actions run `28705810539` 成功，但不是最终验收 run。
- Agent B 修复提交并推送：`b2c3ee081559d6b01ec36b23cc447966365cb27b`，commit subject 为 `v1.6: 修复控制组双击保存`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和最终 Actions run head SHA 均为 `b2c3ee081559d6b01ec36b23cc447966365cb27b`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions 最终 run：`28706014088`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v1.6-main-b2c3ee081559-run28706014088-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28706014088/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=b2c3ee081559d6b01ec36b23cc447966365cb27b`、`runId=28706014088`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`G1` / `G2` 双击保存、单击召回、空选择不覆盖、空组召回不清选择、pending 清理、死亡 ID 过滤、HUD subtitle 更新和 `SKRM` 清空控制组仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展编队管理深化、按钮禁用态、命令队列反馈或移动端手感优化，但这些不属于 v1.6。

### v1.7 / AI 跳过不可生产兵种

日期：2026-07-04

核心变更：

- AI 常规生产槽不再只尝试 `aiBuildCursor` 当前指向的兵种，而是从 cursor 开始最多扫描一次完整 `aiBuildPattern()`。
- 新增 `canQueueBuild(kind:faction:)` 和 `nextAvailableAIBuildKind(in:startingAt:)`，可生产判定复用 `productionSource(for:faction:)` 并检查资金，保持 War Factory、Airfield、Shipyard 和 Carrier 的现有 operational 来源规则。
- 当前缺 Airfield / Shipyard / Carrier 或资金不足时，AI 会跳过对应兵种并选择后续当前可生产单位；成功排队后 cursor 推进到命中项之后。
- 若整轮 pattern 都不可生产，AI 本槽不排队、不扣钱、不显示玩家 HUD message 或 denied marker，并将 cursor 有界推进 1，避免长期从同一不可生产起点开始扫描。
- 玩家生产、生产队列执行、AI 补建建筑、攻击波次、支援技能、经济、迷雾、战斗、老兵、胜负、控制组和 `SKRM` 重置链路保持不变。
- README、flow 和 flowchart 已同步当前 AI 生产选择行为；Agent B 未预写本正式记录。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.7（AI跳过不可生产兵种）.md`
- `update_log.md`

验证结果：

- Agent B 实现提交并推送：`82a30a580b05387d3606c78f7a6db1d2764676eb`，commit subject 为 `v1.7: 优化AI生产选择`。
- Agent B 本地轻量检查：交接未提供原始命令输出；本轮按提示词要求应为 `git diff --check` 和 `git diff --cached --check`，最终以云端 static checks 与 Agent C 本地复核为准。
- Agent C 复核：`git fetch origin` 成功；普通沙箱执行 `git pull --ff-only origin main` 因 `.git/FETCH_HEAD` 权限失败，提升权限重试成功且显示 `Already up to date`；本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `82a30a580b05387d3606c78f7a6db1d2764676eb`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28709813494`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v1.7-main-82a30a580b05-run28709813494-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28709813494/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=82a30a580b05387d3606c78f7a6db1d2764676eb`、`runId=28709813494`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，AI 在缺 Airfield / Shipyard / Carrier、资金不足、来源完工后重新纳入空海军、全部不可生产时无玩家反馈、cursor 失败推进 1 和 `SKRM` 重置 cursor 仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 AI 战术分工、编队管理深化、按钮禁用态、命令队列反馈或移动端手感优化，但这些不属于 v1.7。

### v1.8 / 支援命中潜艇短暂暴露

日期：2026-07-04

核心变更：

- `AIRS` / `BARR` 伤害型支援在 `applySupportDamage(...)` 中真实命中潜艇并扣血后，会把该潜艇 `revealedUntil` 延长到当前时间后 2.4 秒。
- 新增 `revealSubmarineHitBySupport(...)` 小 helper，使用 `max(...)` 延长暴露，避免缩短 `SCAN` 的 8 秒侦察暴露。
- 未命中的支援打击不暴露潜艇；`SCAN` 仍走 `revealSupportTargets(... duration: 8.0 ...)`，`REPR` 仍只走维修路径。
- 本轮没有新增 `showSonarPing(...)` 调用，不把支援命中表现成声呐扫描，也不新增可能泄露未知潜艇位置的 HUD 文案。
- 支援伤害路径仍不调用 `awardVeterancyKill(...)`，支援技能击杀不计入任何单位 XP。
- README、flow 和 flowchart 已同步当前真实海战 / 迷雾行为；Agent B 未预写本正式记录。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.8（支援命中潜艇短暂暴露）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`5a4c48c5776025ad1e2852c6efdb53fc23909c1c`，commit subject 为 `v1.8: 支援命中潜艇短暂暴露`。
- Agent C 复核：`git fetch origin` 成功；本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `5a4c48c5776025ad1e2852c6efdb53fc23909c1c`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28710696003`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v1.8-main-5a4c48c57760-run28710696003-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28710696003/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=5a4c48c5776025ad1e2852c6efdb53fc23909c1c`、`runId=28710696003`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`AIRS` / `BARR` 命中未死亡潜艇短暂可见、未命中不暴露、过期后无声呐重新隐藏、`SCAN` 仍保持 8 秒暴露、`REPR` 不暴露潜艇和支援击杀不授 XP 仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 AI 占点队保护、旗点建造覆盖、岸防炮或反潜 HUD 信息，但这些不属于 v1.8。

### v1.9 / AI 占点队保留任务

日期：2026-07-04

核心变更：

- AI 占点候选新增 `isAvailableEnemyCaptureUnit(...)` 小 helper，只选择当前空闲、存活、已完工、无攻击目标、无 attack-move 意图、无普通目的地的 Red 陆地单位。
- `updateAI(dt:)` 在同一指挥周期内记录已分配的占点 runner，避免同一个 Humvee / Mechanic 先被派去油井又立刻被改派去旗点。
- `commandEnemyAttackers(...)` 的主攻波次筛选新增 `destination == nil` 条件，正在执行普通移动 / 占点移动的作战单位不会被立即改派成 attack-move 波次。
- AI 生产、支援技能、波次目标、波次规模、玩家命令链路、占领规则、经济、迷雾、胜负和 `SKRM` 重置链路保持不变。
- README、flow 和 flowchart 已同步当前真实 AI 行为；Agent B 未预写本正式记录。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v1（核心玩法）/v1.9（AI占点队保留任务）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`646cf8fc7dfa92caf285746f4f2da39461d6da97`，commit subject 为 `v1.9: 保留AI占点队任务`。
- Agent C 复核：`git fetch origin` 成功；本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `646cf8fc7dfa92caf285746f4f2da39461d6da97`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28711230416`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v1.9-main-646cf8fc7dfa-run28711230416-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28711230416/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=646cf8fc7dfa92caf285746f4f2da39461d6da97`、`runId=28711230416`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，AI 油井 / 旗点 runner 同轮不复用、移动中的占点 runner 不被主攻波次抢走、真正 idle 作战单位仍能发起 attack-move、以及 v1.7 生产扫描行为仍建议在可用模拟器或真机上做人工 Stage Regression。
- 本轮只保护仍有普通 `destination` 的移动中占点 runner；单位到达占领半径且 `destination` 清空后，若占领尚未完成，后续周期仍可能被重新调度。若要长期占点 reservation，需要另开小版本设计。
- 后续可继续扩展旗点建造覆盖、岸防炮、长期 AI 角色 reservation 或反潜 HUD 信息，但这些不属于 v1.9。

### v2.0 / 旗点提供建造覆盖

日期：2026-07-05

核心变更：

- 新增结构建造覆盖、旗点建造覆盖和旗点中心 no-build 半径常量；己方已完工结构继续提供 390 像素覆盖，己方已占领旗点提供 180 像素有限覆盖。
- `constructionIssue(...)` 改为共享 `hasNearbyBuildCoverage(...)`，玩家和 AI 都使用己方已完工结构或己方已占旗点作为建造覆盖来源。
- 玩家建造仍必须有目标视野；Shipyard 海岸、Oil Derrick 油田、普通陆地结构、碰撞检查和资金扣除规则保持不变。
- `isOccupiedForConstruction(...)` 增加旗点中心 56 像素保护，避免普通建筑压住旗点视觉和交互中心，同时保留 Oil Derrick 复用 / 改建旧油井的既有例外。
- `setControlPointFaction(...)` 在玩家相关旗点归属变化时强制刷新 fog，让刚占旗后的视野和建造覆盖立即进入合法性判断。
- AI 普通建筑选点把 Red 已占旗点加入 build anchor，但最终仍走 `constructionIssue(...)`，不能绕过海岸、油田、陆地、碰撞或覆盖规则。
- README、flow、flowchart 和 v2.0 Agent A 提示词已同步当前真实行为；本轮没有新增建筑、科技树、支援资产、旗点武器或声呐能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.0（旗点建造覆盖）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`c943446a173704b973ae4fb89cef01b7531bebca`，commit subject 为 `v2.0: 旗点提供建造覆盖`。
- Agent X 并行只读子 agent 复核：代码审查和文档审查均返回 `No issues`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `c943446a173704b973ae4fb89cef01b7531bebca`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28712236687`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.0-main-c943446a1737-run28712236687-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28712236687/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=c943446a173704b973ae4fb89cef01b7531bebca`、`runId=28712236687`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，玩家占旗后立即放置 Radar Outpost / Guard Tower、敌方或中立旗点不提供玩家覆盖、AI 围绕已占旗点前线补建、旗点中心 no-build、Oil Derrick 复用、Shipyard 海岸限制和 `SKRM` 重置后旗点覆盖清空仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展岸防炮、SAM、长期 AI 角色 reservation、旗点争夺奖励或反潜 HUD 信息，但这些不属于 v2.0。

### v2.1 / 引入岸防炮

日期：2026-07-05

核心变更：

- 新增 `EntityKind.coastalBattery` / Coastal Battery / `CB`，作为可由 `BASE` 轮换建造的海岸防御结构。
- Coastal Battery 使用现有施工、资金扣除、血条、选择、死亡清理、迷雾隐藏和 `SKRM` 重置链路；未完工前不能开火、提供视野、提供 build coverage、生产、赚钱或成为支援资产。
- `constructionIssue(...)` 让 Coastal Battery 和 Shipyard 一样要求 coast tile，同时继续共享玩家视野、己方结构 / 旗点 build coverage、碰撞和旗点中心 no-build 规则。
- 完工 Coastal Battery 共享 `canAttack(...)`、目标搜索、`isKnownToFaction(...)` 和 `fire(attacker:target:)` 链路，只攻击可见水面海军目标，不攻击潜艇、陆地、空中或建筑目标，不提供 sonar，也不改变潜艇暴露逻辑。
- AI 缺失建筑补建列表纳入 Coastal Battery；目标价值、主攻目标优先级和 Red 防御结构评分已同步。
- README、flow、flowchart 和 v2.1 Agent A 提示词已同步当前真实行为；本轮没有新增 SAM、科技树、支援资产、声呐或外部素材。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.1（引入岸防炮）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`b666f6ebaf523e421ebff89e1b675984da39b80b`，commit subject 为 `v2.1: 引入岸防炮`。
- Agent X 并行只读子 agent 复核：代码审查返回 `No issues`；文档审查指出 `md/flow/flow.md` 未来扩展点仍把岸防炮列为未来项，已修正为岸防炮平衡 / 升级。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `b666f6ebaf523e421ebff89e1b675984da39b80b`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28713037948`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.1-main-b666f6ebaf52-run28713037948-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28713037948/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=b666f6ebaf523e421ebff89e1b675984da39b80b`、`runId=28713037948`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`BASE` 轮换到 Coastal Battery、coast-only 放置、旗点 build coverage 下的海岸放置、完工后只攻击 Battleship / Carrier 等水面海军、不攻击 Submarine / 陆空 / 建筑、AI 补建岸防炮、目标排序和 `SKRM` 重置仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 SAM、岸防炮平衡 / 升级、长期 AI 角色 reservation、旗点争夺奖励或反潜 HUD 信息，但这些不属于 v2.1。

### v2.2 / 引入防空阵地

日期：2026-07-05

核心变更：

- 新增 `EntityKind.samSite` / SAM Site / `SAM`，作为可由 `BASE` 轮换建造的普通陆地防空结构。
- SAM Site 使用现有施工、资金扣除、血条、选择、死亡清理、迷雾隐藏和 `SKRM` 重置链路；未完工前不能开火、提供视野、提供 build coverage、生产、赚钱或成为支援资产。
- `constructionIssue(...)` 没有为 SAM Site 增加特殊地形分支；它继续共享玩家视野、己方结构 / 旗点 build coverage、clear land、碰撞和旗点中心 no-build 规则。
- 完工 SAM Site 共享 `canAttack(...)`、目标搜索、`isKnownToFaction(...)` 和 `fire(attacker:target:)` 链路，只攻击可见空中目标，不攻击潜艇、陆地、海军或建筑目标，不提供 sonar，也不改变潜艇暴露逻辑。
- AI 缺失建筑补建列表纳入 SAM Site；目标价值、主攻目标优先级和 Red 防御结构评分已同步。
- README、flow、flowchart 和 v2.2 Agent A 提示词已同步当前真实行为；本轮没有新增科技树、升级、支援资产、声呐或外部素材。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.2（引入防空阵地）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`095a0c73314089de86a124d4db14b99ac350c2d6`，commit subject 为 `v2.2: 引入防空阵地`。
- Agent X 并行只读子 agent 复核：代码审查和文档审查均返回 `No issues`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `095a0c73314089de86a124d4db14b99ac350c2d6`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28714849676`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.2-main-095a0c733140-run28714849676-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28714849676/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=095a0c73314089de86a124d4db14b99ac350c2d6`、`runId=28714849676`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`BASE` 轮换到 SAM Site、普通陆地放置、旗点 build coverage 下的前线防空放置、完工后只攻击 Helicopter / Fighter、不攻击 Submarine / 陆地 / 海军 / 建筑、AI 补建防空阵地、目标排序和 `SKRM` 重置仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 SAM / 岸防炮平衡与升级、长期 AI 角色 reservation、旗点争夺奖励或反潜 HUD 信息，但这些不属于 v2.2。

### v2.3 / 引入机动防空车

日期：2026-07-05

核心变更：

- 新增 `EntityKind.aaTruck` / AA Truck / `AA`，作为 War Factory 生产的移动陆地防空单位。
- AA Truck 使用现有 War Factory 生产、资金扣除、队列、集结点、ready pulse、选择、控制组、移动、hold、attack-move、迷雾显示、血条、死亡清理、老兵 XP 和 `SKRM` 重置链路。
- HUD 新增 `AA` 生产按钮，成本、来源检查、队列深度和 selected factory routing 继续复用 `queueBuild(...)` / `productionSource(...)`。
- AA Truck 共享 `canAttack(...)`、目标搜索、`isKnownToFaction(...)` 和 `fire(attacker:target:)` 链路，只攻击可见空中目标，不攻击潜艇、陆地、海军或建筑目标，不提供 sonar，也不改变潜艇暴露逻辑。
- AI 常规 build pattern 纳入 AA Truck，仍通过 `queueBuild(...)` / `productionSource(...)` 排队；缺 War Factory、未完工 War Factory 或资金不足时自然跳过。
- README、flow、flowchart 和 v2.3 Agent A 提示词已同步当前真实行为；本轮没有新增科技树、支援资产、声呐、弹药系统或外部素材。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.3（引入机动防空车）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`b77e0f1166c42a5b3dee1612531df57a5e222645`，commit subject 为 `v2.3: 引入机动防空车`。
- Agent X 并行只读子 agent 复核：代码审查和文档审查均返回 `No issues`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `b77e0f1166c42a5b3dee1612531df57a5e222645`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28715392503`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.3-main-b77e0f1166c4-run28715392503-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28715392503/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=b77e0f1166c42a5b3dee1612531df57a5e222645`、`runId=28715392503`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build 或模拟器/真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，War Factory 生产 AA Truck、HUD `AA` 按钮、selected factory routing、集结点出兵、AA Truck 只攻击 Helicopter / Fighter、不攻击 Submarine / 陆地 / 海军 / 建筑、AI 混合生产 AA Truck、目标排序和 `SKRM` 重置仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 SAM / AA Truck 平衡与升级、长期 AI 角色 reservation、旗点争夺奖励或反潜 HUD 信息，但这些不属于 v2.3。

### v2.4 / 引入声呐浮标

日期：2026-07-05

核心变更：

- 新增 `EntityKind.sonarBuoy` / Sonar Buoy / `SON`，作为可由 `BASE` 轮换建造的海岸侦测结构。
- Sonar Buoy 使用现有施工、资金扣除、血条、选择、死亡清理、迷雾隐藏和 `SKRM` 重置链路；未完工前不能提供视野、build coverage、sonar、生产、赚钱或成为支援资产。
- `constructionIssue(...)` 让 Sonar Buoy 和 Shipyard / Coastal Battery 一样要求 coast tile，同时继续共享玩家视野、己方结构 / 旗点 build coverage、碰撞和旗点中心 no-build 规则。
- 完工 Sonar Buoy 提供普通静态视野和 300 像素 sonar 检测；结构类 sonar 必须 `isOperational` 才能生效，移动 sonar 单位保持既有行为。
- Sonar Buoy 不攻击任何目标，不写入潜艇 `revealedUntil`，不作为 `SCAN`、`REPR`、`AIRS` 或 `BARR` 资产；`SCAN` 仍只认 operational HQ 或 Radar Outpost。
- AI 缺失建筑补建列表纳入 Sonar Buoy；战略价值、Red 结构目标评分和主目标优先级已同步。
- README、flow、flowchart 和 v2.4 Agent A 提示词已同步当前真实行为；本轮没有新增反潜武器、科技树、升级、音效、图片素材或外部依赖。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.4（引入声呐浮标）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`81928d3f9eedb92b21fcfb48007ada2eb0819cd6`，commit subject 为 `v2.4: 引入声呐浮标`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `81928d3f9eedb92b21fcfb48007ada2eb0819cd6`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28725950719`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.4-main-81928d3f9eed-run28725950719-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28725950719/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=81928d3f9eedb92b21fcfb48007ada2eb0819cd6`、`runId=28725950719`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`BASE` 轮换到 Sonar Buoy、coast-only 放置、旗点 build coverage 下的海岸放置、完工后侦测潜艇、不攻击任何目标、不作为 `SCAN` 资产、AI 补建声呐浮标、目标排序和 `SKRM` 重置仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 Sonar Buoy 平衡 / 升级、AI 空军威胁防空响应、长期 AI 角色 reservation、旗点争夺奖励或反潜 HUD 信息，但这些不属于 v2.4。

### v2.5 / AI 空军威胁防空响应

日期：2026-07-05

核心变更：

- AI 在保底 Mechanic 之后、常规 `aiBuildPattern()` 生产扫描之前，会根据 Red 当前认知评估玩家空军压力。
- Red 已知玩家空军只统计玩家存活 air 单位，并额外要求处于 Red 存活单位、Red 已完工建筑或 Red 已占旗点视野内；本轮不复用玩家 `visibleTiles`，也不全图作弊。
- AI 防空覆盖会统计 Red 存活 `.aaTruck` / `.fighter`，以及已完工 `.guardTower` / `.samSite`；同时统计已排队的 `.aaTruck` / `.fighter`，避免重复堆订单。
- 当已知玩家空军达到阈值且现有 / 已排队防空不足时，AI 每个指挥周期最多额外尝试排一个 `.aaTruck`，其次 `.fighter`。
- 动态防空仍走 `canQueueBuild(...)`、`queueBuild(...)` 和 `productionSource(...)`，缺资金、缺 operational War Factory / Airfield / Carrier 或队列来源时自然跳过；成功补防空后不阻断本周期常规生产扫描。
- 本轮没有改变玩家 HUD、单位 / 建筑数值、`canAttack(...)`、支援技能、潜艇隐身、声呐检测或 Sonar Buoy 行为。
- README、flow、flowchart 和 v2.5 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.5（AI空军威胁防空响应）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`319032f94679523ebbdc310da38acc0831053f7c`，commit subject 为 `v2.5: AI响应空军威胁补防空`。
- Agent X 并行只读子 agent 复核：当前 diff 审查返回 `No issues`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `319032f94679523ebbdc310da38acc0831053f7c`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28728193870`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.5-main-319032f94679-run28728193870-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28728193870/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=319032f94679523ebbdc310da38acc0831053f7c`、`runId=28728193870`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Red 视野内 2 架以上玩家空军触发 AA Truck / Fighter 补单、视野外玩家空军不触发、已排队防空不重复堆单、缺生产来源 / 资金时自然跳过、补防空后常规生产仍继续、以及 `SKRM` 重置后 AI 正常重新评估仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展长期 AI 角色 reservation、旗点争夺奖励、AI 编队比例、高价值老兵保护或反潜 HUD 信息，但这些不属于 v2.5。

### v2.6 / AI 占点任务长期保留

日期：2026-07-05

核心变更：

- 新增 `EnemyCaptureReservation` 和 `enemyCaptureReservations`，记录 Red AI 自己分配的占油 / 占旗 runner 与目标关系。
- AI 在每个指挥周期开始维护 reservation：目标已归 Red、目标消失、单位死亡、单位不再有效或被 attack target / attack-move 外部战斗状态打断时自动释放。
- AI 分配 oil runner 和 flag runner 时会登记 reservation；有效 reservation 会让 runner 不再被重复挑为其他占点任务。
- `commandEnemyAttackers(...)` 的常规主攻波次会跳过有效 reservation 的 runner，即使该 runner 已到达占领半径且 `destination == nil`。
- 如果 runner 仍有有效 reservation、没有战斗目标或 attack-move 且不在目标占领半径内，AI 会重新给它设置到目标附近的 destination，避免路径结束在占领半径外。
- `cullDestroyedEntities()` 会清理死亡单位和失效目标对应 reservation；`SKRM` 重开会清空全部 reservation。
- 本轮没有改变玩家命令、占领半径、占领速度、收入、视野、build coverage、AI 生产、动态防空、支援技能或紧急基地防守响应。
- README、flow、flowchart 和 v2.6 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.6（AI占点任务长期保留）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`93242ef80e82f7f89d6b211d44341f2a8516e252`，commit subject 为 `v2.6: 保留AI占点任务`。
- Agent X 只读子 agent 调查确认最小实现位置；实现后按 diff 和云端 artifact 复核。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `93242ef80e82f7f89d6b211d44341f2a8516e252`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28729127625`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.6-main-93242ef80e82-run28729127625-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28729127625/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=93242ef80e82f7f89d6b211d44341f2a8516e252`、`runId=28729127625`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，AI 油井 / 旗点 runner 到达占领半径后持续完成占领、目标归 Red 后释放 reservation、runner 死亡 / 被防守反应打断后释放、多个未占旗点不会重复派同一目标、以及 `SKRM` 重置后 reservation 清空仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展旗点争夺奖励、AI 编队比例、高价值老兵保护、反潜 HUD 信息或更完整的 AI 角色系统，但这些不属于 v2.6。

### v2.7 / AI 旗点防守响应

日期：2026-07-05

核心变更：

- 玩家单位开始夺取 Red 已占旗点时，Red 会用自己的单位、已完工建筑或已占旗点视野确认抢点单位；确认后才触发防守响应，不复用玩家 `visibleTiles`，也不全图作弊。
- 新增 `lastEnemyControlPointDefenseResponseTime`，为旗点防守响应提供独立 cooldown；Red 确认抢点后即刷新尝试时间，避免无合格守军时每帧重复扫描。
- 旗点防守响应最多调附近少量 Red 非结构作战单位，要求单位存活、有伤害、能攻击抢点单位，并限制在旗点附近。
- 旗点防守响应会跳过 `isEnemyCaptureReserved(...)` 为 true 的占油 / 占旗 runner，避免破坏 v2.6 的长期占点任务保留。
- 防守单位继续复用现有 `attackTarget`、`attackDestination(for:target:)`、`setDestination(for:near:)`、移动和战斗链路；没有新增平行 AI、寻路或战斗系统。
- `SKRM` 重开会重置旗点防守 cooldown；本轮没有改变旗点占领半径、占领速度、收入、视野、build coverage、任务阶段、玩家命令、AI 生产或支援技能。
- README、flow、flowchart 和 v2.7 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.7（AI旗点防守响应）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`3907db50fe419a0e27276ecaa421ae83612f9be4`，commit subject 为 `v2.7: AI旗点防守响应`。
- Agent X 并行只读子 agent 调查建议本轮做 AI 旗点防守响应；diff reviewer 发现无 P0 / P1，指出无守军场景下 cooldown 语义可更严谨，已修正为确认 Red 感知后即刷新尝试 cooldown。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `3907db50fe419a0e27276ecaa421ae83612f9be4`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28729671852`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.7-main-3907db50fe41-run28729671852-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28729671852/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=3907db50fe419a0e27276ecaa421ae83612f9be4`、`runId=28729671852`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，玩家单位抢 Red 已占旗点时触发附近 Red 非 reservation 作战单位防守、Red 视野外抢点不触发、无合格守军时 cooldown 正常节流、占点 runner 不被抢走、以及 `SKRM` 重置后旗点防守 cooldown 清空仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展旗点争夺奖励、AI 编队比例、高价值老兵保护、反潜 HUD 信息或更完整的 AI 角色系统，但这些不属于 v2.7。

### v2.8 / AI 优先反夺旗点

日期：2026-07-05

核心变更：

- `enemyControlPointTarget(excludingReserved:)` 从单纯选择离 Red 基地最近的非 Red 旗点，改为按玩家控制、玩家正在占领和距离 Red 基地的组合评分选择旗点目标。
- 玩家已占旗点优先于中立旗点；玩家正在占领的旗点获得最高优先级，包含 Red 已占但正在被玩家夺取的旗点。
- 新增 `isPlayerPressuringControlPoint(...)`、`enemyControlPointNeedsAction(...)` 和 `enemyControlPointPriority(...)`，集中表达 Red 是否需要处理某个旗点以及对应排序分数。
- `enemyCaptureTargetNeedsCapture(.controlPoint)` 改为共享 `enemyControlPointNeedsAction(...)`，让 Red 已占但被玩家争夺的旗点可以维持占点 reservation。
- `excludingReserved: true` 仍跳过已有 `.controlPoint(point.id)` reservation 的目标，避免多个 runner 重复抢同一旗点。
- 占旗 runner 和主攻 attack-move 波次继续通过同一个 `enemyControlPointTarget(...)` 入口受益；本轮没有改变旗点占领半径、占领速度、收入、视野、build coverage、玩家命令、AI 防守响应、AI 生产或支援技能。
- README、flow、flowchart 和 v2.8 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.8（AI优先反夺旗点）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`13e3934bd3d6c9d729f7624de2b982e89d3599bc`，commit subject 为 `v2.8: AI优先反夺旗点`。
- Agent X 并行只读子 agent 调查确认该小增量合适，并指出 Red 已占但被玩家夺取的旗点也应进入候选；diff reviewer 返回 `No issues`，确认排序方向、reservation、`excludingReserved`、v2.7 sensor gate 和文档一致性。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `13e3934bd3d6c9d729f7624de2b982e89d3599bc`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28730096484`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.8-main-13e3934bd3d6-run28730096484-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28730096484/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=13e3934bd3d6c9d729f7624de2b982e89d3599bc`、`runId=28730096484`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Red 优先派 runner / attack-move 波次反夺玩家已占旗点、Red 已占但正在被玩家夺取的旗点进入候选、已有 reservation 不重复派同一旗点、没有玩家控制或争夺旗点时仍按距离选择中立旗点、以及 v2.7 抢点防守 sensor gate 不被绕开仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展旗点争夺奖励、AI 编队比例、高价值老兵保护、反潜 HUD 信息或更完整的 AI 角色系统，但这些不属于 v2.8。

### v2.9 / 旗点占领奖励

日期：2026-07-05

核心变更：

- 新增 `controlPointCaptureBonus = 260`，为前线旗点归属实际变化提供一次性资金奖励。
- `setControlPointFaction(_:,for:)` 在 `previousFaction != faction` 时通过共享 `changeMoney(for:by:)` 给新归属方发放奖金；玩家和 AI 共享同一经济入口，`.neutral` 通过 `changeMoney` no-op 保持安全。
- 玩家成功占领旗点时，原有 HUD 消息会显示 `+$260` 奖金；AI 占领旗点不新增玩家提示，但同样获得资金。
- `incomePerTick(for:)` 未改变，旗点持续收入仍为 `$95/s`；本轮没有把一次性奖金混入每秒收入。
- 本轮没有改变旗点占领半径、占领速度、视野、build coverage、任务阶段、AI 占点 reservation、AI 防守响应、AI 反夺优先级、AI 生产或玩家命令。
- README、flow、flowchart 和 v2.9 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v2（地图控制）/v2.9（旗点占领奖励）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`7872f2a1da18389175660c0873d95e37f1997dcd`，commit subject 为 `v2.9: 旗点占领奖励`。
- Agent X 并行只读子 agent 调查确认该小增量适合；diff reviewer 返回 `No issues`，确认奖金只在归属变化时发放、玩家 / AI 共享 `changeMoney(...)`、持续收入未改、文档一致且 v2.6-v2.8 AI 逻辑未被当前 diff 修改。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `7872f2a1da18389175660c0873d95e37f1997dcd`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28730455859`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v2.9-main-7872f2a1da18-run28730455859-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28730455859/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=7872f2a1da18389175660c0873d95e37f1997dcd`、`runId=28730455859`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，玩家占旗时资金立即增加并显示 `+$260`、AI 占旗同额加钱、同归属重复调用不重复发奖、旗点持续收入仍为 `$95/s`、`SKRM` 后资金重置自然清空奖金影响仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展旗点争夺奖励平衡、AI 编队比例、高价值老兵保护、反潜 HUD 信息或更完整的 AI 角色系统，但这些不属于 v2.9。

### v3.0 / 反潜 HUD 信息

日期：2026-07-05

核心变更：

- 选择面板新增 active sonar range 展示，已完工 Sonar Buoy 以及 Battleship、Carrier、Helicopter、Submarine 会显示 `Sonar <range>`；未完工 Sonar Buoy 仍显示 offline，不被当作 active sonar sensor。
- 潜艇单选状态从含糊的 `Stealth  Sonar yes` 改为区分 `Stealth while undetected` 与 `Temporary detected <Ns>`，sonar range 由统一 sonar 信息行展示。
- 多选 combat summary 在存在 active sonar asset 时追加 `Sonar <count>/<maxRange>`，不覆盖 hold、attack-move 或老兵分布行。
- Operational Sonar Buoy 的结构状态显示 `Sonar <range>  No SCAN`，继续明确它不作为 `SCAN` 资产。
- 本轮只改 HUD 可读性和文档，没有改变 `isSubmarineDetected(...)`、`sonarRange(for:)`、`revealedUntil`、`SCAN`、`AIRS` / `BARR`、AI、战斗、迷雾合法性、Sonar Buoy 放置或数值。
- README、flow、flowchart 和 v3.0 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.0（反潜HUD信息）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`dc15666f89d218aef31b331a9b0ec0c95ddfd423`，commit subject 为 `v3.0: 显示反潜HUD信息`。
- Agent X 并行只读子 agent 调查确认该小增量适合开启海战 / 反潜可读性阶段；diff reviewer 返回 `No issues`，确认当前 diff 只改 HUD 文案与文档、active sonar helper 有 operational 边界、未修改潜艇侦测 / 战斗 / AI / 迷雾规则。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `dc15666f89d218aef31b331a9b0ec0c95ddfd423`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28730937122`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.0-main-dc15666f89d2-run28730937122-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28730937122/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=dc15666f89d218aef31b331a9b0ec0c95ddfd423`、`runId=28730937122`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，单选 Submarine / Sonar Buoy / Battleship / Carrier / Helicopter、多选混编 sonar asset、未完工 Sonar Buoy offline 文案、潜艇 detected 倒计时显示和 HUD 文案是否在小屏不溢出仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展反潜交互反馈、Sonar Buoy 平衡 / 升级、AI 编队比例、高价值老兵保护或更完整的海军 / 航母机制，但这些不属于 v3.0。

### v3.1 / 反潜攻击 HUD 信息

日期：2026-07-05

核心变更：

- 选择面板区分 ASW attack capability 与 sonar sensor：单选 Fighter 会显示 `ASW attack  No sonar`，说明它能攻击潜艇但不能侦测潜艇。
- Battleship、Submarine、Carrier 和 Helicopter 单选会同时显示 `ASW attack` 与 `Sonar <range>`；Sonar Buoy 只显示 sonar / `No SCAN`，不显示 `ASW attack`。
- 多选 combat summary 追加 `ASW <count>  Sonar <count>/<maxRange>`，Fighter 只计入 ASW，不计入 sonar；active Sonar Buoy 只计入 sonar，不计入 ASW。
- 第 4 行 hold / attack-move / veterancy 优先级保持不变，选择面板仍维持 4 行信息结构。
- 本轮只改 HUD 可读性和文档，没有改变 `canAttack(...)`、`hasSonar`、`sonarRange(for:)`、`isSubmarineDetected(...)`、`revealedUntil`、`SCAN`、`AIRS` / `BARR`、AI、战斗、迷雾合法性、单位数值或建筑规则。
- README、flow、flowchart 和 v3.1 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.1（反潜攻击HUD信息）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`b82a89ccbb6bdcfc50a3b60d1814f359f9ddab4c`，commit subject 为 `v3.1: 区分ASW攻击与声呐HUD信息`。
- Agent A 子 agent 生成 v3.1 实现提示词；Agent X 并行只读 reviewer 返回 `No issues`，确认 diff 只改 HUD helper / 文案和必要文档，没有修改潜艇侦测、战斗、AI 或迷雾规则。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `b82a89ccbb6bdcfc50a3b60d1814f359f9ddab4c`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28731507221`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.1-main-b82a89ccbb6b-run28731507221-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28731507221/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=b82a89ccbb6bdcfc50a3b60d1814f359f9ddab4c`、`runId=28731507221`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Fighter 单选 `ASW attack  No sonar`、Battleship / Submarine / Carrier / Helicopter 同时显示 ASW 与 sonar、Sonar Buoy 不显示 ASW、多选 ASW / sonar 统计和小屏 HUD 文案长度仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展反潜交互反馈、Sonar Buoy 平衡 / 升级、AI 编队比例、高价值老兵保护或更完整的海军 / 航母机制，但这些不属于 v3.1。

### v3.2 / AI 已知潜艇压力补 ASW

日期：2026-07-05

核心变更：

- Red AI 在常规生产扫描前新增已知玩家潜艇压力评估；只有玩家 Submarine 同时满足 `isKnownToFaction(..., observer: .enemy)` 和 Red 单位 / 已完工建筑 / 已占旗点视野边界时，才计入已知潜艇威胁。
- 新增 Red ASW committed count，统计 Red 存活 ASW 攻击单位和已排队 ASW 订单，避免每个 AI 周期重复堆单。
- 当已知潜艇威胁至少为 1 且 Red 现有 / 已排队 ASW 不足时，每个 AI 指挥周期最多额外尝试排产一个 Helicopter、Fighter、Submarine、Battleship 或 Carrier。
- 动态 ASW 响应仍走 `canQueueBuild(...)`、`queueBuild(...)` 和 `productionSource(...)`；缺资金、缺 operational Airfield / Carrier / Shipyard 或队列来源时自然跳过，不直接生成单位。
- Fighter 计为 ASW attacker 但不是 sonar sensor；Sonar Buoy 计为 sonar sensor 但不是 ASW attacker。
- 本轮没有改变 `canAttack(...)`、`hasSonar`、`sonarRange(for:)`、`isSubmarineDetected(...)`、`revealedUntil`、`SCAN`、`AIRS` / `BARR`、战斗、迷雾、单位数值、建筑规则或 HUD 输入。
- README、flow、flowchart 和 v3.2 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.2（AI已知潜艇压力补ASW）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`a05570bb485e46977ced21d88d6ddec9eb8c72ac`，commit subject 为 `v3.2: AI已知潜艇压力补ASW`。
- Agent A 子 agent 生成 v3.2 实现提示词；Agent X 并行只读 reviewer 返回 `No issues`，确认 diff 只改 AI ASW helper / 接入和必要文档，没有修改潜艇侦测、战斗、迷雾或单位规则。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `a05570bb485e46977ced21d88d6ddec9eb8c72ac`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28732957239`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.2-main-a05570bb485e-run28732957239-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28732957239/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=a05570bb485e46977ced21d88d6ddec9eb8c72ac`、`runId=28732957239`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Red 只在自身视野 / sonar / `revealedUntil` 认知内响应玩家潜艇、不会全图补 ASW、不会把 Fighter 当 sonar、不会把 Sonar Buoy 当 ASW attacker、不会绕过生产来源和资金限制仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展反潜交互反馈、Sonar Buoy 平衡 / 升级、AI 编队比例、高价值老兵保护或更完整的海军 / 航母机制，但这些不属于 v3.2。

### v3.3 / 反潜命中战场反馈

日期：2026-07-05

核心变更：

- 直接火力命中玩家潜艇或玩家已知敌方潜艇时，会在目标位置显示短暂 `ASW HIT` 文案和水下冲击圈反馈。
- 新增 `shouldShowAntiSubmarineHitFeedback(for:)`，仅允许玩家潜艇或满足 `isKnownToFaction(..., observer: .player)` 的潜艇显示命中特效，避免泄露隐藏敌方潜艇位置。
- 新增 `showAntiSubmarineHit(at:faction:)`，复用 `effectsLayer`、`SKShapeNode` 和 `SKLabelNode(fontNamed: "Menlo-Bold")` 创建短生命周期 visual-only 特效。
- 本轮只接入 `fire(attacker:target:)` direct-fire 路径；`AIRS` / `BARR` / `applySupportDamage(...)` 不显示 `ASW HIT`，仍只负责既有支援命中短暂暴露。
- 本轮没有改变伤害公式、`armorMultiplier`、kill / XP、`canAttack(...)`、sonar、`revealedUntil`、AI、迷雾、单位数值、HUD 输入或建筑规则。
- README、flow、flowchart 和 v3.3 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.3（反潜命中战场反馈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`ed55fe662740fccbba612d3f6817a93d24fa8382`，commit subject 为 `v3.3: 反潜命中战场反馈`。
- Agent A 子 agent 生成 v3.3 实现提示词；Agent X 并行只读定位子 agent 确认 `fire(attacker:target:)` 是 direct-fire 入口；diff reviewer 返回 `No issues`，确认未修改伤害、`armorMultiplier`、kill / XP、`revealedUntil`、sonar、`SCAN` / `AIRS` / `BARR`、AI 或 HUD 输入。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `ed55fe662740fccbba612d3f6817a93d24fa8382`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28734041508`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.3-main-ed55fe662740-run28734041508-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28734041508/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=ed55fe662740fccbba612d3f6817a93d24fa8382`、`runId=28734041508`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，敌方 direct-fire 命中玩家潜艇、玩家 direct-fire 命中已知敌潜艇、隐藏敌潜艇不泄露 `ASW HIT`、`AIRS` / `BARR` 命中潜艇不显示该反馈、以及特效在实机 HUD / 迷雾层级下是否足够清楚仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 Sonar Buoy 平衡 / 升级、AI 编队比例、高价值老兵保护或更完整的海军 / 航母机制，但这些不属于 v3.3。

### v3.4 / 声呐覆盖选择反馈

日期：2026-07-05

核心变更：

- 玩家选中 active sonar sensor 时在战场显示声呐覆盖圈，范围由既有 `sonarRange(for:)` 推导。
- 多选多个玩家 active sonar sensor 时同时显示多个覆盖圈；未完工 Sonar Buoy 和敌方 sensor 不显示覆盖圈。
- 新增 `sonarCoverageNode`、`configureSonarCoverageNode(for:)` 和 `shouldShowSonarCoverage(for:)`，通过 `refreshSelection()` 与选择态同步显隐。
- 玩家建筑施工完成后刷新 selection visual，确保已选中的 Sonar Buoy 进入 operational 状态后能显示覆盖圈。
- 本轮是 visual-only 反馈，没有改变 `sonarRange(for:)`、`isSubmarineDetected(...)`、`revealedUntil`、迷雾数据、AI、伤害、HUD 按钮、单位数值或建筑规则。
- README、flow、flowchart 和 v3.4 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.4（声呐覆盖选择反馈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`4b26de43bb713fb40705c5e0ed7867c67ea8cffc`，commit subject 为 `v3.4: 声呐覆盖选择反馈`。
- Agent A 子 agent 生成 v3.4 实现提示词；只读评估子 agent 确认声呐覆盖圈可作为纯选择态 visual 接入；diff reviewer 返回 `No issues`，确认未修改 sonar、潜艇侦测、迷雾、AI、伤害或 HUD 按钮。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `4b26de43bb713fb40705c5e0ed7867c67ea8cffc`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28734758814`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.4-main-4b26de43bb71-run28734758814-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28734758814/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=4b26de43bb713fb40705c5e0ed7867c67ea8cffc`、`runId=28734758814`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，单选 Battleship / Submarine / Carrier / Helicopter / active Sonar Buoy、多选多个 sonar sensor、未完工 Sonar Buoy 不显示覆盖圈、施工完成后显示覆盖圈、敌方 sensor 不显示覆盖圈、取消选择 / 死亡 / SKRM 重开不残留、以及覆盖圈在迷雾和单位层级下的清晰度仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 Sonar Buoy 平衡 / 升级、AI 编队比例、高价值老兵保护或更完整的海军 / 航母机制，但这些不属于 v3.4。

### v3.5 / 收紧 AI 侦察反潜目标

日期：2026-07-05

核心变更：

- Red AI 的 `enemyReconSupportPoint()` 不再读取 Red 未知玩家潜艇的真实坐标来投放 `SCAN`。
- Red `SCAN` 精确反潜目标只来自 Red 已知玩家潜艇；已知条件复用 `isKnownPlayerSubmarineThreat(_:)`，同时要求 `isKnownToFaction(..., observer: .enemy)` 和 Red 单位 / 已完工建筑 / 已占旗点视野边界。
- 没有已知玩家潜艇时，Red 只能从己方 active sonar sensor 或已占旗点周边生成水域 / 海岸巡扫热点；找不到合法热点时不释放 `SCAN`，不会回退到隐藏潜艇坐标。
- 新增 `enemyReconKnownSubmarineScore(_:)`、`enemyReconPatrolHotspot()`、`enemyReconPatrolHotspotCandidates()`、`enemyReconPatrolAnchors()` 和 `enemyReconHotspotCandidates(around:)`，只使用 Red 自身 anchor 和地图地形生成巡扫点。
- 本轮没有改变 `sonarRange(for:)`、`isSubmarineDetected(...)`、`revealedUntil`、`SCAN` 半径 / 持续时间 / 费用 / 冷却 / 资产需求、玩家 `SCAN`、AI ASW 生产、伤害、单位数值或建筑规则。
- README、flow、flowchart 和 v3.5 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.5（收紧AI侦察反潜目标）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`018c0a0020739f40bfe118c229f52e81cc5ce4b3`，commit subject 为 `v3.5: 收紧AI侦察反潜目标`。
- Agent A 子 agent 生成 v3.5 实现提示词；候选目标子 agent 首推该 AI 侦察公平性修复；声呐 / 潜艇入口定位子 agent 标出 `isKnownToFaction(...)`、`isSubmarineDetected(...)`、`fire(...)` 和 AI ASW 语义边界；diff reviewer 返回 `No issues`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `018c0a0020739f40bfe118c229f52e81cc5ce4b3`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28735429615`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.5-main-018c0a002073-run28735429615-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28735429615/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=018c0a0020739f40bfe118c229f52e81cc5ce4b3`、`runId=28735429615`、`runAttempt=1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Red 已知玩家潜艇时 `SCAN` 精确落点、Red 未知玩家潜艇时只做己方旗点 / sonar 周边巡扫、隐藏玩家潜艇不被真实坐标点名、Fighter 不被当作 sonar anchor、未完工 Sonar Buoy 不参与巡扫 anchor、以及 Easy / Normal / Hard 下 `SCAN` 使用频率仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 AI 编队比例、高价值老兵保护、Sonar Buoy 平衡 / 升级或更完整的海军 / 航母机制，但这些不属于 v3.5。

### v3.6 / AI 高价值海军护航门槛

日期：2026-07-05

核心变更：

- Red routine attack-move 主攻波次会先形成 provisional wave，再过滤缺少护航的 Battleship / Carrier。
- Carrier 至少需要 2 个本轮 provisional wave escort，Battleship 至少需要 1 个本轮 provisional wave escort；如果本轮 provisional wave 已有足够非高价值可战斗单位形成混合大波次，高价值海军也可加入。
- Escort 必须是 Red 存活、非结构、operational、有伤害、非占点 reservation、非 Battleship / Carrier，且近距离同属本轮 provisional wave，避免附近但不会随行的单位让高价值海军孤立出击。
- 缺少护航的 Battleship / Carrier 会保持 idle，不设置 `attackMoveDestination`、`destination` 或 `attackTarget`；后续 AI 周期满足条件后仍可进入下一波。
- 本轮没有改变 `issueFormationMove(...)`、玩家 `AMOV`、生产、寻路、战斗、迷雾、支援技能、AI ASW / 防空、战术目标评分或单位数值。
- README、flow、flowchart 和 v3.6 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.6（AI高价值海军护航门槛）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`ecdd43bad3a0c39de4b1c2236b106846e4d30d72`，commit subject 为 `v3.6: AI高价值海军护航门槛`。
- 定位子 agent 确认 `commandEnemyAttackers(_:)` 是正确接入点；Agent A 生成 v3.6 实现提示词并要求 escort 必须同属本轮 provisional wave；diff reviewer 返回 `No issues`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `ecdd43bad3a0c39de4b1c2236b106846e4d30d72`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28736297558`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.6-main-ecdd43bad3a0-run28736297558-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28736297558/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=ecdd43bad3a0c39de4b1c2236b106846e4d30d72`、`runId=28736297558`、`runAttempt=1`、`version=v3.6`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，孤立 Red Carrier / Battleship 留在 idle、有足够同波次 escort 时加入 routine assault、足够混合大波次时加入、玩家 `AMOV` 不受影响、Red 防守响应和出厂 tactical target 不受影响、`SKRM` 后无残留仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展高价值老兵保护、AI 编队比例、Sonar Buoy 平衡 / 升级或更完整的航母 / 海军机制，但这些不属于 v3.6。

### v3.7 / AI 编队比例混编进攻

日期：2026-07-05

核心变更：

- Red routine attack-move 主攻波次不再只按距离截取最近单位，而是先形成 mixed provisional wave。
- mixed provisional wave 会优先尝试带入前排陆军、防空、远程火力、空军支援和海军支援，再用按距离 / `formationPriority(for:)` 排序的剩余单位补齐。
- 兵种不足时仍 fallback 到现有可战斗单位出击，不因缺少某个角色而卡死。
- v3.6 Battleship / Carrier 护航过滤仍在最终 `issueFormationMove(... attackMove: true)` 之前执行，高价值海军不会因混编选择绕过护航门槛。
- Easy / Normal / Hard 的常规 `aiBuildPattern()` 只做小顺序调整，更稳定穿插陆军核心、AA、空军和海军支援；实际排产仍走 `canQueueBuild(...)`、`queueBuild(...)` 和 `productionSource(...)`。
- 本轮没有改变玩家 `AMOV`、`issueFormationMove(...)`、动态 AA / ASW 生产、生产来源、寻路、战斗、迷雾、支援、防守响应、单位数值或 Xcode/workflow 配置。
- README、flow、flowchart 和 v3.7 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.7（AI编队比例混编进攻）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`d632b78644d731f20894e24e5bd21a9dac0d3aea`，commit subject 为 `v3.7: AI编队比例混编进攻`。
- 编队比例调查子 agent 推荐该小目标并定位 `commandEnemyAttackers(_:)`、`aiBuildPattern()` 和 v3.6 护航边界；只读 diff reviewer 返回 `No issues`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `d632b78644d731f20894e24e5bd21a9dac0d3aea`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28737636057`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.7-main-d632b78644d7-run28737636057-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28737636057/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=d632b78644d731f20894e24e5bd21a9dac0d3aea`、`runId=28737636057`、`runAttempt=1`、`version=v3.7`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Red 在具备多兵种时是否稳定形成混编主攻、兵种不足时是否继续出击、Battleship / Carrier 是否仍受护航门槛约束、占点 reservation 是否不被抢走、动态 AA / ASW 补单是否保持原语义仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展高价值老兵保护、AI 前线撤退 / 维修行为、Sonar Buoy 平衡 / 升级或更完整的航母 / 海军机制，但这些不属于 v3.7。

### v3.8 / AI 高价值老兵主攻保护

日期：2026-07-05

核心变更：

- Red routine attack-move 主攻波次会在最终入波过滤中排除低血 Veteran / Elite 机动战斗单位。
- 保护对象必须是 Red 存活、非结构、operational、有伤害、Veteran 或 Elite，且 HP 比例低于 55%。
- 受保护老兵不进入本轮 `issueFormationMove(... attackMove: true)`，因此不会被设置 `attackMoveDestination`、`destination` 或 `attackTarget`；HP 恢复到阈值以上后可按既有规则重新加入后续主攻。
- Battleship / Carrier 仍受 v3.6 护航门槛约束；若同时是低血 Veteran / Elite，会先被老兵保护过滤，不会因护航满足而带伤出击。
- Red `REPR` 支援评分会偏向低血 Veteran / Elite 作战单位；实际维修量、费用、冷却、半径、资产需求和玩家手动 `REPR` 行为不变。
- 本轮没有改变 XP 规则、老兵加成、玩家 `AMOV`、`issueFormationMove(...)`、v3.7 mixed provisional wave、生产、寻路、战斗、迷雾、声呐、支援技能数值、单位数值或 Xcode/workflow 配置。
- README、flow、flowchart 和 v3.8 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.8（AI高价值老兵主攻保护）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`4990612ae8faac2841f1fad07752faee38c4652b`，commit subject 为 `v3.8: AI高价值老兵主攻保护`。
- 老兵保护调查子 agent 推荐该小目标并定位 `VeterancyRank`、`GameEntity.veterancyRank`、`canJoinEnemyAssaultWave(...)`、`supportRepairScore(...)` 和 v3.6/v3.7 过滤边界。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `4990612ae8faac2841f1fad07752faee38c4652b`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28738199147`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.8-main-4990612ae8fa-run28738199147-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28738199147/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=4990612ae8faac2841f1fad07752faee38c4652b`、`runId=28738199147`、`runAttempt=1`、`version=v3.8`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，低血 Red Veteran / Elite 是否留在 idle、HP 恢复后是否重新入波、低血 Veteran / Elite Battleship / Carrier 是否仍被保护、Red `REPR` 是否更常覆盖这些单位、玩家手动 `REPR` 是否无变化仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 AI 前线撤退 / 回修行为、Sonar Buoy 平衡 / 升级、航母舰载机巡逻或更完整的海军机制，但这些不属于 v3.8。

### v3.9 / AI 低血单位撤退回修

日期：2026-07-05

核心变更：

- Red routine attack-move 主攻波次会在 provisional wave 形成后，把低血 Red 机动作战单位从本轮主攻中剥离并改派回修。
- 撤退对象必须是 Red 存活、非结构、operational、有伤害、非占点 reservation 的机动战斗单位，且 HP 比例低于 38%。
- 撤退单位会清理 `attackMoveDestination` 和 `attackTarget`，临时用 `holdPosition` 锚定维修点，并通过既有 `setDestination(for:near:)` 后撤；恢复到 62% HP 以上或被外部防守目标接管后会退出撤退集合。
- 回修目标优先选择最近 Red Mechanic；没有 Mechanic 时退回 `enemyBaseAnchorPoint()`，实际回血仍由既有 Mechanic 自动维修和 `REPR` 支援完成。
- Red `REPR` 支援评分会轻量偏向正在撤退回修或低血待撤退的作战单位；实际维修量、费用、冷却、半径、资产需求和玩家手动 `REPR` 行为不变。
- 本轮没有改变玩家 `AMOV`、`issueFormationMove(...)`、`updateMovement(...)`、`updateCombat(...)`、`updateRepair(...)`、`applySupportRepair(...)`、占点 reservation、防守响应、生产、寻路、迷雾、声呐、支援技能数值、单位数值或 Xcode/workflow 配置。
- README、flow、flowchart 和 v3.9 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v3（海战反潜）/v3.9（AI低血单位撤退回修）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`85590418f0851645e0a6854777a8d62cb95f1bcb`，commit subject 为 `v3.9: AI低血单位撤退回修`。
- 初次云端验证失败：run `28740172701`，attempt `1`，manifest 记录 `buildOutcome=failure`，`xcodebuild.log` 指向 `enemyRepairAnchor(for:)` 的 Swift `guard` 链式写法编译错误。
- Agent B 追加修复提交并推送：`aca9f80cc067d0fb9e8ceb87874db048a555eafd`，commit subject 为 `v3.9: 修复AI撤退回修编译`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `aca9f80cc067d0fb9e8ceb87874db048a555eafd`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28740622459`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v3.9-main-aca9f80cc067-run28740622459-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28740622459/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=aca9f80cc067d0fb9e8ceb87874db048a555eafd`、`runId=28740622459`、`runAttempt=1`、`version=v3.9`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Red 低血主攻单位是否稳定脱离本轮 wave、是否优先回到 Mechanic、无 Mechanic 时是否退回基地锚点、HP 恢复后是否重入后续波次、防守响应是否能接管撤退单位、玩家命令和 `REPR` 数值是否无变化仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展 Sonar Buoy 平衡 / 升级、航母舰载机巡逻、AI 撤退反馈或更完整的海军机制，但这些不属于 v3.9。

### v4.0 / 声呐浮标专职反潜再平衡

日期：2026-07-05

核心变更：

- 将 Sonar Buoy 调整为更便宜、更快部署、更脆弱、普通视野更小但 sonar 覆盖更大的沿海专职反潜传感器。
- Sonar Buoy 成本从 1150 降到 850，建造时间从 9.0 秒降到 7.0 秒，HP 从 540 降到 360。
- Sonar Buoy 普通视野从 6 降到 4，`sonarRange(for:)` 中的 Sonar Buoy 检测范围从 300 提升到 340。
- Sonar Buoy 仍然不攻击、不生产、不赚钱、不作为 `SCAN` 资产，不计入 ASW attacker，且仍只有 operational 后才提供视野、sonar 检测、选择态覆盖圈和 AI 巡扫 anchor。
- 本轮没有改变 `isSubmarineDetected(...)`、`isKnownToFaction(...)`、`revealedUntil`、`supportRevealTiles`、`SCAN` / `AIRS` / `BARR`、AI 动态 ASW、Red `SCAN` 公平认知、玩家命令、建造海岸规则、战斗数值或 Xcode/workflow 配置。
- README、flow、flowchart 和 v4.0 Agent A 提示词已同步当前真实行为。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.0（声呐浮标专职反潜再平衡）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`02e4ade21a67be359433ffac16e89a0df73b3556`，commit subject 为 `v4.0: 声呐浮标专职反潜再平衡`。
- Agent X 使用只读子 agent 对比 Sonar Buoy 平衡与航母视觉增强两个候选后，选择 Sonar Buoy 专职反潜再平衡作为 v4.0 小目标。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `02e4ade21a67be359433ffac16e89a0df73b3556`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28741939923`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.0-main-02e4ade21a67-run28741939923-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28741939923/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=02e4ade21a67be359433ffac16e89a0df73b3556`、`runId=28741939923`、`runAttempt=1`、`version=v4.0`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Sonar Buoy 新成本 / HP / 普通视野 / sonar 覆盖在实机手感中的平衡、覆盖圈与 HUD range 是否足够清楚、AI 巡扫热点是否因为更大 sonar range 更频繁覆盖海岸入口仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展航母舰载机巡逻 / launch 反馈、Sonar Buoy 升级、海军海岸争夺或更多地图目标，但这些不属于 v4.0。

### v4.1 / 航母舰载机弹射反馈增强

日期：2026-07-05

核心变更：

- Carrier 生产 Helicopter / Fighter 完成时，除通用 ready pulse 外，会显示更明确的短暂甲板 launch 反馈。
- Carrier launch visual 现在接收产物类型，可用不同短暂机体 cue 和 `CV HLO LAUNCH` / `CV JET LAUNCH` 文案区分 Helicopter 与 Fighter。
- Carrier 直接开火时会显示短暂 deck pulse 和 wing-strike 视觉，但仍走既有 `fire(attacker:target:)` 直接火力结算。
- 新增视觉全部是 `effectsLayer` 上的短生命周期 SpriteKit 节点，动画结束后移除；没有新增持久舰载机实体、状态字段、HUD 命令或外部素材。
- 本轮没有改变 Carrier / Helicopter / Fighter 数值、生产来源、队列推进、spawn point、rally point、AI build pattern、AI 进攻、防空 / 反潜、支援技能、潜艇侦测、迷雾合法性、伤害、冷却、射程、XP、胜负或 Xcode/workflow 配置。
- README、flow、flowchart 和 v4.1 Agent A 提示词已同步当前真实行为，未宣称已实现舰载机巡逻、CAP、截击或舰载机 AI。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.1（航母舰载机弹射反馈增强）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`df16f14f079782137054f9665283f08d50516bf8`，commit subject 为 `v4.1: 航母舰载机弹射反馈增强`。
- Agent X 使用两个只读子 agent 调查 v4.1 候选，均推荐“航母 launch 反馈增强”并明确不做真实巡逻 / CAP；diff reviewer 返回 `No issues`，确认未修改生产、AI、伤害、迷雾、单位数值或文档边界。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `df16f14f079782137054f9665283f08d50516bf8`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28742553955`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.1-main-df16f14f0797-run28742553955-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28742553955/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=df16f14f079782137054f9665283f08d50516bf8`、`runId=28742553955`、`runAttempt=1`、`version=v4.1`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Carrier 生产 Helicopter / Fighter 时的 deck launch 视觉清晰度、Carrier 高频开火时 wing-strike 反馈是否遮挡战场、敌方可见 Carrier 的反馈是否符合预期、以及 `SKRM` 后是否无特效残留仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展真实舰载机巡逻 / CAP、航母护航行为、海军海岸争夺或 Sonar Buoy 升级，但这些不属于 v4.1。

### v4.2 / AI 海岸目标权重微调

日期：2026-07-05

核心变更：

- Red routine assault 的战略结构评分新增海岸基础设施权重：当 Red 拥有可攻击结构的 operational 海军压力时，已知玩家 Shipyard、Sonar Buoy 和 Coastal Battery 会获得额外目标分。
- Red 海军单位的战术目标评分会更重视已知且可攻击的玩家海岸基础设施。
- 新增 `isCoastalInfrastructure(...)`、`hasActiveCoastalAssaultNavy(...)`、`isCoastalAssaultNavalUnit(...)` 和 `isCoastalInfrastructureAttackCapable(...)`，只用于局部 AI 评分。
- 该权重仍在 `enemyStrategicAssaultTarget()` 和 `tacticalTarget(for:)` 既有过滤之后生效，不绕过 `isKnownToFaction(...)` 或 `canAttack(...)`。
- 只有能攻击 Shipyard / Sonar Buoy / Coastal Battery 至少一种结构的 Red operational 海军会触发战略加分；单独潜艇不会触发海岸结构优先。
- 本轮没有改变生产队列、AI build pattern、动态 AA / ASW、单位数值、伤害、射程、冷却、迷雾、潜艇侦测、支援技能、建造海岸规则、路径、XP、胜负或 Xcode/workflow 配置。
- README、flow、flowchart 和 v4.2 Agent A 提示词已同步当前真实行为，未宣称新增地图目标、任务阶段、海岸旗点或科技升级。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.2（AI海岸目标权重微调）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`1010ec4eb9ad2eaa6109ec7a897c63093c881fee`，commit subject 为 `v4.2: AI海岸目标权重微调`。
- 只读调查子 agent 推荐该小目标，确认 `enemyStrategicAssaultScore(_:)` 与 `targetScore(for:target:)` 是合适接入点；diff reviewer 返回 `No issues`，确认未绕过 `isKnownToFaction` / `canAttack`，只有潜艇不会触发海岸结构优先，也未修改生产、AI build pattern、单位数值、伤害、迷雾或支援技能。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `1010ec4eb9ad2eaa6109ec7a897c63093c881fee`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28743446836`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.2-main-1010ec4eb9ad-run28743446836-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28743446836/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=1010ec4eb9ad2eaa6109ec7a897c63093c881fee`、`runId=28743446836`、`runAttempt=1`、`version=v4.2`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Red 具备 Battleship / Carrier 时是否更稳定压制玩家 Shipyard / Sonar Buoy / Coastal Battery、只有 Submarine 时是否不会错误偏向岸上结构、旗点 / 油井优先级是否仍符合预期、以及不同 AI 难度下海岸战斗节奏仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展真实舰载机巡逻 / CAP、航母护航行为、海岸任务目标、Sonar Buoy 升级或更多地图目标，但这些不属于 v4.2。

### v4.3 / 建立海岸据点任务阶段

日期：2026-07-05

核心变更：

- 任务链新增 `Secure Coast` 阶段，顺序为占油、夺旗、建立海岸据点、混合军种、摧毁 Red 生产、摧毁 Red HQ。
- `Secure Coast` 要求玩家拥有 2 个存活且已完工的海岸资产，计入 Shipyard、Sonar Buoy 和 Coastal Battery。
- 新增 `coastalAssetCount(for:)` 作为任务专用计数 helper；未完工建筑、死亡建筑和非目标阵营建筑不计入。
- HUD 任务详情会显示 `Hold 2 coastal assets. X/2 secured.`，进度最多显示 2/2；初始玩家 Shipyard 若仍 operational，则进入该阶段时通常显示 1/2。
- 启动提示文案同步加入 secure coast，避免玩家可见任务摘要遗漏新增阶段。
- `SKRM` 仍通过清空 `completedMissionStages` 并重建实体自然重置任务进度，没有新增独立状态。
- 本轮没有改变海岸建造规则、奖励、AI、生产队列、单位数值、伤害、射程、冷却、迷雾、潜艇侦测、支援技能、路径、XP、胜负或 Xcode/workflow 配置。
- README、flow、flowchart 和 v4.3 Agent A 提示词已同步当前真实行为，未宣称新增海岸旗点、奖励、战役地图、科技升级或 AI 新能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.3（建立海岸据点任务阶段）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`474569bdf51d060427c23aee67842713c9e45c8e`，commit subject 为 `v4.3: 新增海岸据点任务阶段`。
- Agent B 文案修复提交并推送：`c4b59498825edc12a071829ab837cb411bc7cb09`，commit subject 为 `v4.3: 同步海岸任务启动提示`。
- 只读调查子 agent 推荐该小目标，认为它比 Sonar Buoy 升级或航母 CAP / 巡逻前置更小、更贴近现有任务系统；diff reviewer 未发现阻塞问题，并确认阶段顺序、HUD 文案、完成判定、operational 计数、SKRM 重置和文档同步均符合边界。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `c4b59498825edc12a071829ab837cb411bc7cb09`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28744114432`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.3-main-c4b59498825e-run28744114432-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28744114432/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=c4b59498825edc12a071829ab837cb411bc7cb09`、`runId=28744114432`、`runAttempt=1`、`version=v4.3`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，任务链中 Secure Coast 进入时是否稳定显示 1/2、完工 Sonar Buoy / Coastal Battery 是否立即完成阶段、未完工海岸建筑是否不计入、任务文案在实际 HUD 宽度下是否足够清晰仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展真实舰载机巡逻 / CAP、航母护航行为、海岸任务奖励、Sonar Buoy 升级或更多地图目标，但这些不属于 v4.3。

### v4.4 / 海岸据点任务奖励

日期：2026-07-05

核心变更：

- `Secure Coast` 任务阶段首次完成时，现在通过 `changeMoney(for: .player, by: 600)` 给玩家一次性 `$600` 资源奖励。
- 新增 `missionReward(for:)` 作为任务奖励 helper；当前只有 `.secureCoast` 返回 `600`，其他阶段返回 `0`。
- 奖励发放发生在 `updateMissionProgress()` 将阶段写入 `completedMissionStages` 的首次完成路径中，不新增独立奖励状态，依赖既有完成集合避免重复发放。
- 若同一帧连续完成多个阶段，奖励仍按实际发奖阶段在循环内发放，完成消息以最后完成阶段为标题并附本轮累计奖励，避免消息停留在早先阶段。
- `Secure Coast` HUD 详情追加 `+$600`，让玩家进入该阶段时能看到完成奖励。
- README、flow、flowchart 和 v4.4 Agent A 提示词已同步当前真实行为，未宣称新增完整战役奖励系统、海岸旗点、科技升级、AI 新能力或新地图。
- 本轮没有改变 `Secure Coast` 完成条件、海岸建造规则、AI、生产队列、单位数值、伤害、射程、冷却、迷雾、潜艇侦测、支援技能、路径、XP、胜负或 Xcode/workflow 配置。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.4（海岸据点任务奖励）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`0650c5fb445ab4608441a9d980106afd4985d776`，commit subject 为 `v4.4: 增加海岸据点任务奖励`。
- 只读候选评估子 agent 推荐该小目标，认为它比 Sonar Buoy 升级或 Carrier CAP / 巡逻前置更小、更贴合 v4.3 的新增任务阶段。
- diff reviewer 初次发现同一帧连续完成多个阶段时，完成消息可能停留在 `Secure Coast`；Agent B 已在提交前修正为最后完成阶段标题加本轮累计奖励，并确认未发现重复发奖、SKRM 重置或范围控制问题。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `0650c5fb445ab4608441a9d980106afd4985d776`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28744577617`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.4-main-0650c5fb445a-run28744577617-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28744577617/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=0650c5fb445ab4608441a9d980106afd4985d776`、`runId=28744577617`、`runAttempt=1`、`version=v4.4`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Secure Coast 首次完成时 `$600` 是否在 HUD 金钱上即时可感知、同一帧连续完成 Secure Coast / Combined Arms 时的顶部消息是否最符合玩家预期、任务详情 `+$600` 在实际 HUD 宽度下是否足够清晰仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续扩展更多任务阶段奖励、真实舰载机巡逻 / CAP、航母护航行为、Sonar Buoy 升级或更多地图目标，但这些不属于 v4.4。

### v4.5 / 混合军种任务奖励

日期：2026-07-05

核心变更：

- `Deploy Combined Arms` 任务阶段首次完成时，现在通过 `changeMoney(for: .player, by: 800)` 给玩家一次性 `$800` 资源奖励。
- `missionReward(for:)` 当前奖励表为：`Secure Coast` `$600`，`Deploy Combined Arms` `$800`，其他阶段 `$0`。
- 奖励仍只在 `updateMissionProgress()` 将阶段写入 `completedMissionStages` 的首次完成路径中发放，不新增独立奖励状态，依赖既有完成集合避免重复发放。
- 同一帧连续完成 `Secure Coast` 和 `Deploy Combined Arms` 时，会分别发放 `$600` 和 `$800`，完成消息沿用 v4.4 语义显示最后完成阶段标题和本轮累计奖励。
- `Deploy Combined Arms` HUD 详情追加 `+$800`，让玩家在混编目标阶段看到主攻前补给奖励。
- README、flow、flowchart 和 v4.5 Agent A 提示词已同步当前真实行为，未宣称新增完整战役奖励系统、支援冷却、免费技能、科技升级、AI 新能力或新地图。
- 本轮没有改变 `Deploy Combined Arms` 完成条件、`playerMobileDomainCounts()`、AI、生产队列、单位数值、伤害、射程、冷却、迷雾、潜艇侦测、支援技能、路径、XP、胜负或 Xcode/workflow 配置。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.5（混合军种任务奖励）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`c9626e4f6dab4dafbc3eaea6a194774aab9ca78a`，commit subject 为 `v4.5: 增加混合军种任务奖励`。
- 只读候选评估子 agent 推荐 `Deploy Combined Arms` 奖励，认为它比 `Break Red Production` 奖励更早进入主攻前补给窗口，且明显小于支援冷却、Sonar Buoy 升级或 Carrier CAP / 巡逻。
- diff reviewer 返回 `Findings: none`，确认奖励仍只在首次完成路径发放、同帧 `Secure Coast` + `Deploy Combined Arms` 会累计 `$1400` 并显示最后完成阶段标题、完成条件 / AI / 单位数值 / 建造 / 迷雾 / 支援 / 测试规范未变。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `c9626e4f6dab4dafbc3eaea6a194774aab9ca78a`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28745016027`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.5-main-c9626e4f6dab-run28745016027-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28745016027/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=c9626e4f6dab4dafbc3eaea6a194774aab9ca78a`、`runId=28745016027`、`runAttempt=1`、`version=v4.5`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`Deploy Combined Arms` 首次完成时 `$800` 是否在 HUD 金钱上即时可感知、同一帧连续完成 `Secure Coast` / `Deploy Combined Arms` 时 `+$1400` 顶部消息是否最符合玩家预期、任务详情 `+$800` 在实际 HUD 宽度下是否足够清晰仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续补齐 `Break Red Production` 奖励、真实舰载机巡逻 / CAP、航母护航行为、Sonar Buoy 升级或更多地图目标，但这些不属于 v4.5。

### v4.6 / 摧毁生产任务奖励

日期：2026-07-05

核心变更：

- `Break Red Production` 任务阶段首次完成时，现在通过 `changeMoney(for: .player, by: 900)` 给玩家一次性 `$900` 资源奖励。
- `missionReward(for:)` 当前奖励表为：`Secure Coast` `$600`，`Deploy Combined Arms` `$800`，`Break Red Production` `$900`，其他阶段 `$0`。
- 奖励仍只在 `updateMissionProgress()` 将阶段写入 `completedMissionStages` 的首次完成路径中发放，不新增独立奖励状态，依赖既有完成集合避免重复发放。
- `Break Red Production` HUD 详情在剩余 Red 生产来源计数旁追加 `+$900`，完成态文案也保留终局推进提示和奖励数值。
- README、flow、flowchart 和 v4.6 Agent A 提示词已同步当前真实行为，未宣称新增完整战役奖励系统、支援冷却、免费技能、科技升级、AI 新能力或新地图。
- 本轮没有改变 `Break Red Production` 完成条件、`enemyProductionCount()`、AI、生产队列、单位数值、伤害、射程、冷却、迷雾、潜艇侦测、支援技能、路径、XP、胜负或 Xcode/workflow 配置。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.6（摧毁生产任务奖励）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`aac32fc47a8bac7218211862c5116f9ba68bb796`，commit subject 为 `v4.6: 增加摧毁生产任务奖励`。
- diff reviewer 返回 `No issues`，确认未发现越界改动；只读定位子 agent 因并发限制断开，未影响主线程已完成的源码定位和实现复核。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `aac32fc47a8bac7218211862c5116f9ba68bb796`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28745659738`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.6-main-aac32fc47a8b-run28745659738-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28745659738/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=aac32fc47a8bac7218211862c5116f9ba68bb796`、`runId=28745659738`、`runAttempt=1`、`version=v4.6`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`Break Red Production` 首次完成时 `$900` 是否在 HUD 金钱上即时可感知、终局任务详情 `+$900` 在实际 HUD 宽度下是否足够清晰、以及摧毁最后生产来源后玩家补给节奏是否合适仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做真实舰载机巡逻 / CAP、航母护航行为、Sonar Buoy 升级、更多地图目标或任务奖励平衡，但这些不属于 v4.6。

### v4.7 / 终局 HQ 任务情报

日期：2026-07-05

核心变更：

- `Destroy Red HQ` 任务阶段现在会在 Red HQ 存活且满足 `isKnownToFaction(redHQ, observer: .player)` 时显示 `Red HQ HP 当前/最大`，帮助玩家组织终局攻势。
- Red HQ 存活但玩家未知时，任务详情只提示用 scouts 或 `SCAN` 侦察后再进攻，不显示隐藏 HQ 的 HP、位置、距离或路径。
- Red HQ 已不存在时，任务详情显示 `Red Command HQ destroyed.`，胜利状态仍由现有 `updateVictoryState()` 和 `victoryState` 文案负责。
- 新增 `enemyHQ()` 作为任务详情专用的 Red HQ 查找 helper；没有改变 `Destroy Red HQ` 完成条件、胜负触发、迷雾、支援侦察、潜艇侦测、AI 或战斗逻辑。
- README、flow、flowchart 和 v4.7 Agent A 提示词已同步当前真实行为，未宣称新增地图 ping、小地图标记、战役系统、任务奖励或新 AI 能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.7（终局HQ任务情报）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`55be31620ffea8af2126835c076e2d93163c695c`，commit subject 为 `v4.7: 增加终局HQ任务情报`。
- diff reviewer 返回 `No issues`，确认未发现迷雾泄露、任务完成条件 / 胜负 / AI / 单位数值 / 支援 / Xcode workflow 越界，也未看到本地测试、构建或静态检查证据。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `55be31620ffea8af2126835c076e2d93163c695c`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28746496986`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.7-main-55be31620ffe-run28746496986-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28746496986/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=55be31620ffea8af2126835c076e2d93163c695c`、`runId=28746496986`、`runAttempt=1`、`version=v4.7`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，终局 Red HQ 未知 / 已知 / 已毁三种任务详情状态、`SCAN` 暴露 HQ 后 HP 是否立即显示、以及文案在实际 HUD 宽度下是否足够清晰仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做真实舰载机巡逻 / CAP、航母护航行为、Sonar Buoy 升级、更多地图目标或终局攻势反馈，但这些不属于 v4.7。

### v4.8 / 终局 HQ 攻击指引

日期：2026-07-05

核心变更：

- `Destroy Red HQ` 阶段中，玩家选中可 attack-move 的作战单位并点击 `AMOV` 时，如果 Red HQ 存活且满足 `isKnownToFaction(redHQ, observer: .player)`，会显示 `Red HQ known: tap HQ or map for attack-move.`。
- 同一条件下会在 Red HQ 位置显示短暂 `HQ` 目标标记，作为终局攻势的视觉指引。
- Red HQ 未知时仍只显示通用 `Tap the map to attack-move.`，不显示隐藏 HQ 的位置、距离、标记或额外状态。
- 新增 `playerKnownEnemyHQ()` 复用 `enemyHQ()` 和 `isKnownToFaction(...)` 作为唯一已知边界；v4.7 的 HP 任务详情也改为复用该 helper。
- `AMOV` 仍只进入 pending attack-move，玩家随后点击地图或可见敌人时才下达命令；没有改变 attack-move 目标选择、编队、寻路、沿途交战、AI、胜负、单位数值、迷雾、潜艇侦测或支援技能。
- README、flow、flowchart 和 v4.8 Agent A 提示词已同步当前真实行为，未宣称自动攻击、小地图标记、新奖励、战役系统或新 AI 能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.8（终局HQ攻击指引）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`c02bb55dfb9beea54b4f50032a920753bcc87f68`，commit subject 为 `v4.8: 增加终局HQ攻击指引`。
- diff reviewer 返回 `No issues`，确认未发现迷雾泄露、AMOV 命令语义改变、Swift 编译风险或文档夸大；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `c02bb55dfb9beea54b4f50032a920753bcc87f68`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28746995064`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.8-main-c02bb55dfb9b-run28746995064-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28746995064/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=c02bb55dfb9beea54b4f50032a920753bcc87f68`、`runId=28746995064`、`runAttempt=1`、`version=v4.8`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，终局 Red HQ 已知时 `AMOV` 文案与短暂 HQ 标记是否在真实 HUD 宽度和触摸节奏下足够清晰、未知 Red HQ 时是否保持无标记、以及玩家点击 HQ / 地面后的攻势手感仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.8。

### v4.9 / 恢复 AMOV 按钮入口

日期：2026-07-05

核心变更：

- `layoutHUD()` 的底部命令条 actions 重新加入 `.attackMove`，位置在 `.holdPosition` 后，使 `HOLD` / `AMOV` 基础军队命令相邻且玩家可直接从 HUD 触发 attack-move。
- 保持既有 `HudAction.attackMove` title/subtitle/color/highlight、`handleHudAction(.attackMove)`、`issueAttackMoveOrder(...)` 和 `issueFormationMove(... attackMove: true)` 语义不变。
- 保持 v4.8 终局 Red HQ 已知提示和短暂 HQ 标记逻辑不变，仍只在 `isKnownToFaction(..., observer: .player)` 成立时显示。
- 为 24 个命令按钮补上响应式布局保护：`compactHUD` 现在会按按钮数量、48pt 最小按钮宽度、7pt 间距和 32pt 横向边距计算 non-compact 所需宽度；中等宽度不足以容纳单行时自动走现有 compact 双行布局，避免边缘按钮溢出。
- README、flow、flowchart 和 v4.9 Agent A 提示词已同步当前真实行为，未宣称新增自动攻击、地图导航、AI 能力、任务奖励或 HUD 重做。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.9（恢复AMOV按钮入口）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`0dc94bbb86cc843d75540c3f259b1cc59fde2a5d`，commit subject 为 `v4.9: 恢复AMOV按钮入口`。
- diff reviewer 首轮指出 24 个按钮在 1180-1313 宽的 non-compact HUD 下可能因 48pt 最小按钮宽度溢出；Agent B 已通过按按钮数量计算 compact 阈值修复。
- diff reviewer 复查返回 `No issues`，确认之前的溢出风险已解决，attack-move 语义、迷雾、AI 和文档仍保持一致；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `0dc94bbb86cc843d75540c3f259b1cc59fde2a5d`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28747360775`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.9-main-0dc94bbb86cc-run28747360775-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28747360775/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=0dc94bbb86cc843d75540c3f259b1cc59fde2a5d`、`runId=28747360775`、`runAttempt=1`、`version=v4.9`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，恢复后的 `AMOV` 按钮在真机触摸尺寸、1366 固定场景缩放和较窄设备 aspect-fill 显示下的实际手感仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.9。

### v4.10 / AMOV 终局目标面板

日期：2026-07-06

核心变更：

- `AMOV` armed 且当前任务阶段为 `Destroy Red HQ` 时，选择信息面板现在会在 Red HQ 满足 `playerKnownEnemyHQ()` 的同一合法认知边界下显示终局目标摘要。
- 终局目标摘要保持 4 行：选中玩家存活机动作战单位数量、Red HQ 当前 / 最大 HP、最近选中作战单位到 Red HQ 的 approximate 直线距离或 `Select combat units`、以及 `Tap map to push formation`。
- Red HQ 未知或非终局阶段时，`AMOV` armed 面板保持通用 attack-move 文案，不显示隐藏 HQ 的 HP、位置、距离或路线。
- 本轮只新增选择面板文案 helper，没有改变 `handleHudAction(.attackMove)`、`issueAttackMoveOrder(...)`、地图点击下令、编队、沿途交战、AI、战斗、胜负、迷雾、潜艇侦测或支援技能。
- README、flow、flowchart 和 v4.10 Agent A 提示词已同步当前真实行为，未宣称自动攻击、路径距离、ETA、新任务奖励、新 AI 能力或 HUD 重做。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.10（AMOV终局目标面板）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查或本机构建作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`203858e03e2ce7bbd1a57863c440eb67cca23dce`，commit subject 为 `v4.10: 增强AMOV终局目标面板`。
- diff reviewer 返回 `No issues`，确认未发现迷雾泄露、AMOV 命令语义改变、README / flow 夸大或明显 Swift 编译风险；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `203858e03e2ce7bbd1a57863c440eb67cca23dce`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28760150087`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.10-main-203858e03e2c-run28760150087-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28760150087/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=203858e03e2ce7bbd1a57863c440eb67cca23dce`、`runId=28760150087`、`runAttempt=1`、`version=v4.10`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试或本地静态检查；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，终局 Red HQ 已知 / 未知时 `AMOV` armed 面板切换、nearest approximate 距离在真实地图尺度下是否足够可读、以及玩家点击地图推进时的终局操作节奏仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.10。

### v4.11 / 航母甲板状态面板

日期：2026-07-06

核心变更：

- 单选 Carrier 时，选择信息面板现在用专用行显示 `Deck builds Helicopter/Fighter`，明确既有甲板空军生产能力。
- 单选 Carrier 时，选择信息面板现在显示 `Rally set` 或 `Rally unset`，并保留当前 Carrier 队列状态：无队列显示 `Queue idle`，有队列显示 `Queue <shortCode> <remaining>s` 和额外排队数。
- Carrier 的 HP、攻击 / 射程 / 视野、ASW attack / sonar 信息仍沿用现有选择面板链路；`selectionCapabilityInfoLine(for:)` 仍统一追加到攻击信息行。
- 本轮只增强 Carrier 单选 HUD 文案，没有改变 `EntityKind.canProduce(_:)`、`productionSource(for:faction:)`、`queueBuild(...)`、`updateBuildOrders(dt:)`、出机点、deck-launch 反馈、rally 执行、AI、战斗、迷雾、潜艇侦测、支援技能、任务或胜负。
- README、flow、flowchart 和 v4.11 Agent A 提示词已同步当前真实行为，未宣称新增生产系统、自动巡逻、CAP、AI 新能力或新单位。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.11（航母甲板状态面板）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`5427a7dd1c9d5b763b636e08d4d82a03414e943e`，commit subject 为 `v4.11: 增强航母甲板状态面板`。
- diff reviewer 返回 `No issues`，确认只增强 Carrier 单选 selection info，未误改生产、rally、AI、战斗或迷雾路径，Carrier ASW / sonar 信息仍会追加，文档未夸大，且未发现明显 Swift 编译风险；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `5427a7dd1c9d5b763b636e08d4d82a03414e943e`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28760524538`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.11-main-5427a7dd1c9d-run28760524538-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28760524538/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=5427a7dd1c9d5b763b636e08d4d82a03414e943e`、`runId=28760524538`、`runAttempt=1`、`version=v4.11`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Carrier 单选面板在实际 HUD 宽度下的 `Deck builds Helicopter/Fighter`、`Rally set/unset` 与队列文案可读性仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.11。

### v4.12 / 海岸据点任务摘要

日期：2026-07-06

核心变更：

- `Secure Coast` 任务详情现在在总进度之外显示 operational player coastal assets 的分项摘要，例如 `SY1 SON0 CB1`。
- 新增 `coastalAssetBreakdown(for:)`，用同一口径统计指定阵营、存活、已完工 operational 的 Shipyard、Sonar Buoy 和 Coastal Battery。
- `coastalAssetCount(for:)` 现在复用分项统计并返回三项总和，`.secureCoast` 完成条件仍是任意 2 个 operational coastal assets，不要求三类各一个。
- `missionReward(for: .secureCoast)` 仍为 `$600`，`completedMissionStages` 防重复发奖、任务顺序、完成消息和胜负逻辑不变。
- README、flow、flowchart 和 v4.12 Agent A 提示词已同步当前真实行为，未宣称新增任务系统、新奖励、新建筑能力、AI 新能力或海岸资产新规则。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.12（海岸据点任务摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`2869abc41ae8dcb28cfc7046585c40bf4ea0033e`，commit subject 为 `v4.12: 增强海岸据点任务摘要`。
- diff reviewer 返回 `No issues`，确认 Secure Coast 完成条件仍是 `coastalAssetCount(for: .player) >= 2`，分项计数只统计指定 faction、存活、operational 的三类海岸资产，奖励、任务顺序、AI、建造、战斗、迷雾路径未改，文档未夸大，且未发现明显 Swift 编译风险；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `2869abc41ae8dcb28cfc7046585c40bf4ea0033e`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28760867129`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.12-main-2869abc41ae8-run28760867129-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28760867129/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=2869abc41ae8dcb28cfc7046585c40bf4ea0033e`、`runId=28760867129`、`runAttempt=1`、`version=v4.12`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`Secure Coast` 任务详情在不同 HUD 宽度下的 `SY` / `SON` / `CB` 摘要可读性，以及任意 2 个已完工海岸资产完成任务的玩家理解度，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.12。

### v4.13 / 支援按钮资产提示

日期：2026-07-06

核心变更：

- `SCAN`、`REPR`、`AIRS` 和 `BARR` 的底部 HUD subtitle 现在按冷却秒数、`need asset`、价格的优先级显示状态。
- 新增 `supportButtonSubtitle(for:)`，缺资产提示复用 `hasOperationalSupportAsset(for:faction:)` 的真实 operational asset 口径。
- 资金不足但资产满足且未冷却时仍显示价格；点击后仍由 `supportIssue(for:faction:)` 按原顺序处理冷却、资金和资产提示。
- 本轮只增强支援按钮可读性，没有改变支援技能费用、冷却、资产需求、执行效果、pending support、denied marker、AI、迷雾、潜艇暴露、维修、伤害、任务或胜负。
- README、flow、flowchart 和 v4.13 Agent A 提示词已同步当前真实行为，未宣称按钮禁用、灰化、资金状态提示或新支援系统。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.13（支援按钮资产提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`18abd75c3a634dd422c66f00600b4793571c389c`，commit subject 为 `v4.13: 增强支援按钮资产提示`。
- diff reviewer 返回 `No issues`，确认本轮只改支援 HUD subtitle，冷却优先于缺资产，缺资产复用 `hasOperationalSupportAsset`，不检查资金，未改变 `supportIssue`、执行、AI 或迷雾路径，文档未夸大为禁用按钮；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `18abd75c3a634dd422c66f00600b4793571c389c`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28763108746`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.13-main-18abd75c3a63-run28763108746-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28763108746/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=18abd75c3a634dd422c66f00600b4793571c389c`、`runId=28763108746`、`runAttempt=1`、`version=v4.13`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，支援按钮在实际设备 HUD 宽度下显示 `need asset` 的可读性，以及四个支援按钮在资产缺失 / 冷却 / 可用三态之间切换的触感，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.13。

### v4.14 / 海岸资产职责面板

日期：2026-07-06

核心变更：

- 单选 Shipyard、Sonar Buoy 或 Coastal Battery 时，选择信息面板现在显示对应海岸资产职责摘要。
- Shipyard 显示 `Builds BB/SUB/CV`，operational 时同一行附带短队列 / rally 状态；这只是文案压缩，不改变生产来源、队列、rally 或 AI。
- Sonar Buoy 显示 `Coastal sonar  No SCAN`，继续明确它不是 `SCAN` 支援资产；Coastal Battery 显示 `Coastal anti-ship  No sonar`，继续明确它不提供声呐。
- 新增 `Secure Coast: counted/pending/not counted` 单体状态；只有 Blue 存活且 operational 的三类海岸资产显示 counted，未完工 Blue 显示 pending，非 Blue 显示 not counted。
- 本轮只增强 selection info 文案，没有改变 `Secure Coast` 完成条件、任务奖励、`coastalAssetBreakdown(for:)`、建造、生产、sonar、战斗、支援、AI、迷雾、胜负或 HUD 布局。
- README、flow、flowchart 和 v4.14 Agent A 提示词已同步当前真实行为，未宣称新增建筑能力、新任务系统、新奖励、新 AI 能力或新 sonar / combat 规则。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.14（海岸资产职责面板）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`7a3c320bb40dcabe29a321d5caf2a5ce4858c69a`，commit subject 为 `v4.14: 增强海岸资产职责面板`。
- diff reviewer 返回 `No issues`，确认单选 Shipyard / Sonar Buoy / Coastal Battery 显示职责和 `Secure Coast` 状态，未改任务计数、建造、生产、sonar、战斗、支援、AI 或迷雾，Shipyard 队列仍可读，Sonar Buoy 保留 `No SCAN`，Coastal Battery 保留 `No sonar`，文档未夸大；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `7a3c320bb40dcabe29a321d5caf2a5ce4858c69a`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28764079979`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.14-main-7a3c320bb40d-run28764079979-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28764079979/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=7a3c320bb40dcabe29a321d5caf2a5ce4858c69a`、`runId=28764079979`、`runAttempt=1`、`version=v4.14`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，三类海岸资产单选面板在真实设备 HUD 宽度下的短文案可读性，以及 `counted/pending/not counted` 对玩家的理解度，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做支援目标面板资产状态、集结点 pending 摘要、航母生产来源提示、航母 CAP / 巡逻、航母护航行为或更多地图目标，但这些不属于 v4.14。

### v4.15 / 集结点 pending 面板摘要

日期：2026-07-06

核心变更：

- 玩家点击 `RLY` 并进入 rally pending 后，选择信息面板现在显示 `RALLY POINT` 专用摘要。
- 摘要显示当前 `selectedPlayerRallyFactories()` 来源数量、按 `rallyDomain(for:)` 计算的 `Land` / `Air` / `Naval` 类型数量、已有 rally point 的 set/unset 数量，以及 `Tap map to set rally` 操作提示。
- 本轮只读现有选择和 `rallyPoint` 状态，没有改变 `selectedPlayerRallyFactories()`、`handleHudAction(.setRally)`、`handleWorldTap(at:)`、`setRallyPoint(to:for:)`、`rallyDomain(for:)`、生产来源、出兵、AI、移动路径、按钮布局或 pending 优先级。
- README、flow、flowchart 和 v4.15 Agent A 提示词已同步当前真实行为，未宣称 rally 合法性变化、生产系统变化、AI 新能力或移动路径变化。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.15（集结点pending面板摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`7c076ecc58e7d60d0b588115ccd970c383522074`，commit subject 为 `v4.15: 增强集结点pending面板摘要`。
- diff reviewer 返回 `No issues`，确认 `RLY` pending 面板显示 title、sources、land/air/naval、set/unset 和 tap map 提示，来源口径复用 `selectedPlayerRallyFactories()`，类型复用 `rallyDomain(for:)`，未改变 rally 执行、生产、AI、路径或按钮布局，construction/support/AMOV pending 未被错误覆盖，文档未夸大；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `7c076ecc58e7d60d0b588115ccd970c383522074`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28764856393`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.15-main-7c076ecc58e7-run28764856393-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28764856393/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=7c076ecc58e7d60d0b588115ccd970c383522074`、`runId=28764856393`、`runAttempt=1`、`version=v4.15`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`RLY` pending 面板在真实设备 HUD 宽度下的 land/air/naval 与 set/unset 文案可读性，以及多来源 rally 设置时的触感，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做支援目标面板资产状态、航母生产来源提示、航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级或更多地图目标，但这些不属于 v4.15。

### v4.16 / 支援目标面板资产状态

日期：2026-07-06

核心变更：

- 玩家点击 `SCAN`、`REPR`、`AIRS` 或 `BARR` 并进入 support pending 后，选择信息面板的资产行现在显示真实资产状态。
- 资产满足时显示 `Asset ready: HQ/RAD`、`Asset ready: HQ/MECH`、`Asset ready: AF/CV` 或 `Asset ready: BB/CV`；资产不满足时显示对应 `Need ...` 文案。
- 资产状态复用 `hasOperationalSupportAsset(for:faction:)` 的现有 operational asset 口径，不在 HUD helper 中重写资产搜索规则。
- 本轮只增强 pending support 目标面板的只读文案，没有改变 `supportIssue`、支援费用、冷却、资产需求、`selectSupportPower`、`executeSupportPower`、AI、迷雾、潜艇暴露、支援效果、pending 行为或按钮 subtitle / layout。
- README、flow、flowchart 和 v4.16 Agent A 提示词已同步当前真实行为，未宣称新增支援能力、资产需求变化、按钮禁用、费用变化、冷却变化或 AI 新能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.16（支援目标面板资产状态）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`54c51214312ea85426f89a0f82fffeb8daff2183`，commit subject 为 `v4.16: 增强支援目标面板资产状态`。
- diff reviewer 返回 `No issues`，确认 support pending 面板资产行通过 `hasOperationalSupportAsset(for:faction:)` 判断并显示 `Asset ready` / `Need`，未改变 `supportIssue`、费用、冷却、资产需求、`selectSupportPower`、`executeSupportPower`、AI、fog、submarine reveal、support effects、pending 行为或按钮 subtitle / layout，文档未夸大；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `54c51214312ea85426f89a0f82fffeb8daff2183`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28765877621`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.16-main-54c51214312e-run28765877621-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28765877621/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=54c51214312ea85426f89a0f82fffeb8daff2183`、`runId=28765877621`、`runAttempt=1`、`version=v4.16`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，support pending 面板在真实设备 HUD 宽度下的 `Asset ready` / `Need` 文案可读性，以及支援进入 pending 后资产状态与按钮 subtitle 的一致理解，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母生产来源提示、航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.16。

### v4.17 / 空军生产按钮来源提示

日期：2026-07-06

核心变更：

- `HELI` 和 `JET` 底部按钮 subtitle 现在显示当前实际空军生产来源。
- 当 `productionSource(for:faction:)` 选择 Airfield 时显示 `AF $...`，选择 Carrier 时显示 `CV $...`；没有 operational Airfield 或 Carrier 时显示 `need AF/CV`。
- 其他生产按钮 subtitle 保持 `$<cost>`，没有新增 land / naval 来源提示。
- 本轮只增强 HUD 只读文案，没有改变 `queueBuild`、`productionSource`、`BuildOrder`、费用、建造时间、资金检查、队列排序、AI 生产、Carrier launch、rally point、支援、迷雾、任务或按钮布局。
- README、flow、flowchart 和 v4.17 Agent A 提示词已同步当前真实行为，未宣称新增生产规则、按钮禁用、队列变化、新单位或 AI 新能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.17（空军生产按钮来源提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`8beff04b44ad98a71e3961df8527d9721764b80e`，commit subject 为 `v4.17: 增强空军生产按钮来源提示`。
- diff reviewer 返回 `No issues`，确认 `HELI` / `JET` subtitle 通过 `productionSource(for:faction:)` 显示 `AF` / `CV` 来源或 `need AF/CV`，其他 build subtitle 仍显示价格，未改变 `queueBuild`、`productionSource`、`BuildOrder`、AI、支援、fog、任务、Carrier launch、rally 或按钮布局，文档未夸大；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `8beff04b44ad98a71e3961df8527d9721764b80e`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28766534937`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.17-main-8beff04b44ad-run28766534937-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28766534937/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=8beff04b44ad98a71e3961df8527d9721764b80e`、`runId=28766534937`、`runAttempt=1`、`version=v4.17`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，`HELI` / `JET` subtitle 在真实设备 HUD 宽度下显示 `AF $...`、`CV $...` 和 `need AF/CV` 的可读性，以及选中 Carrier 或 Airfield 后来源提示随选择变化的玩家理解度，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航行为、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.17。

### v4.18 / 高价值海军护航状态面板

日期：2026-07-06

核心变更：

- 玩家单选 Carrier 时，选择信息面板现在在 deck 行显示 `Deck HEL/JET  Escort x/2`，并继续保留 rally set/unset 与 queue 状态。
- 玩家单选 Battleship 时，移动信息行现在显示 `Escort x/1`，HP、攻击 / 射程 / 视野、移动 / domain 和老兵信息仍保留。
- 新增只读护航统计 helper：统计同阵营、存活、operational、非结构、可攻击、非当前实体、非 Battleship / Carrier、距离不超过 620 的附近单位。
- 本轮只增强 HUD 只读文案，没有改变 Red AI 高价值海军护航门槛、attack-move wave、reservation、玩家命令、移动、战斗、生产、Carrier launch、rally point、支援、迷雾、任务、胜负或 HUD 布局。
- README、flow、flowchart 和 v4.18 Agent A 提示词已同步当前真实行为，未宣称自动护航、CAP、巡逻、战斗加成、AI 行为变化或新命令。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.18（高价值海军护航状态面板）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`558af7b46d7f876607d57ba223af5869f2ee96aa`，commit subject 为 `v4.18: 增强高价值海军护航状态面板`。
- diff reviewer 返回 `No issues`，确认 Carrier 单选显示 `Deck HEL/JET  Escort x/2` 且 rally / queue 保留，Battleship 单选追加 `Escort x/1` 且核心信息仍可读，escort helper 是只读统计，未触碰 AI wave、玩家命令、战斗、生产、支援、fog、任务或 HUD 布局，文档未夸大；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `558af7b46d7f876607d57ba223af5869f2ee96aa`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28767124714`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.18-main-558af7b46d7f-run28767124714-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28767124714/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=558af7b46d7f876607d57ba223af5869f2ee96aa`、`runId=28767124714`、`runAttempt=1`、`version=v4.18`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Carrier / Battleship 单选面板在真实设备 HUD 宽度下显示 `Escort x/y` 的可读性，以及玩家对护航状态只是只读提示而非自动护航命令的理解度，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.18。

### v4.19 / 高价值海军护航半径圈

日期：2026-07-06

核心变更：

- 玩家选中 operational Carrier 或 Battleship 时，场景中现在显示独立的暖色护航半径圈，对应高价值海军单位的 620 护航统计范围。
- 多选多个玩家高价值海军单位时，可同时显示多个护航半径圈；取消选择或单位不再满足条件时自动隐藏。
- 新增独立 `escortCoverageNode`，与声呐覆盖圈分离；声呐显示规则、潜艇侦测、护航计数口径和选择状态刷新链路保持原语义。
- 本轮只增加选中态可视化提示，没有改变 Red AI 高价值海军护航门槛、attack-move wave、reservation、玩家命令、移动、战斗、生产、Carrier launch、rally point、支援、迷雾、任务、胜负或 HUD 布局。
- README、flow、flowchart 和 v4.19 Agent A 提示词已同步当前真实行为，未宣称自动护航、CAP、巡逻、侦测加成、战斗加成、AI 行为变化或新命令。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.19（高价值海军护航半径圈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`9c94c42a3e290d6c2b88c492d703299577bf7961`，commit subject 为 `v4.19: 增强高价值海军护航半径圈`。
- diff reviewer 返回 `No issues`，确认暖色护航半径圈只在玩家选中 operational Carrier / Battleship 时显示，使用独立 `escortCoverageNode`，未改变 sonar、escort count、AI、玩家命令、战斗、生产、支援、fog、任务或 HUD 文案，文档未夸大；该 reviewer 曾误运行一次 `git diff --check --quiet` 且无输出，本轮不把该命令作为验证依据。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `9c94c42a3e290d6c2b88c492d703299577bf7961`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28767811686`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.19-main-9c94c42a3e29-run28767811686-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28767811686/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=9c94c42a3e290d6c2b88c492d703299577bf7961`、`runId=28767811686`、`runAttempt=1`、`version=v4.19`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，Carrier / Battleship 护航半径圈在真实设备 HUD 和战场缩放下的可读性，以及多个半径圈与声呐圈同时显示时的视觉区分，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.19。

### v4.20 / 多选高价值海军护航摘要

日期：2026-07-06

核心变更：

- 玩家多选或框选包含 Carrier / Battleship 的编队时，选择信息面板现在显示只读高价值海军护航满足摘要。
- 摘要按每艘被选中的高价值海军逐个判断自身护航需求：Carrier 需要 2 个 escort，Battleship 需要 1 个 escort；满足数显示为 `HV Navy x/y escorted`，不足时追加 `Need n`。
- 摘要复用 `highValueNavalEscortRequirement(for:)` 与 `nearbyNavalEscortCount(for:)`，继续使用 620 护航半径和既有 escort 口径，没有复制或分叉统计规则。
- 多选面板仍保持 `Holding ...` 和 `Attack move ...` 状态优先；没有 HOLD / AMOV 状态且存在高价值海军时才用护航摘要替代老兵分布行。
- 本轮只增强 HUD 只读文案，没有改变 Red AI 高价值海军护航门槛、attack-move wave、reservation、玩家命令、移动、战斗、生产、Carrier launch、rally point、支援、迷雾、声呐、护航半径圈、任务或胜负。
- README、flow、flowchart 和 v4.20 Agent A 提示词已同步当前真实行为，未宣称自动护航、CAP、巡逻、follow、侦测加成、战斗加成、AI 行为变化或新命令。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.20（多选高价值海军护航摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`707532f3b7eb80d7bf7dfe355ab7e234e13554a9`，commit subject 为 `v4.20: 增强多选高价值海军护航摘要`。
- diff reviewer 返回 `No issues`，确认当前 diff 只新增多选高价值海军护航摘要和必要文档，HOLD / AMOV 优先级不回归，摘要逐个 Carrier / Battleship 复用现有 `nearbyNavalEscortCount` 和 `highValueNavalEscortRequirement`，未改变 AI、命令、战斗、生产、支援、fog、sonar 或 escort coverage；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `707532f3b7eb80d7bf7dfe355ab7e234e13554a9`。
- GitHub Actions：run `28768399462`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.20-main-707532f3b7eb-run28768399462-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28768399462/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=707532f3b7eb80d7bf7dfe355ab7e234e13554a9`、`runId=28768399462`、`runAttempt=1`、`version=v4.20`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `HV Navy x/y escorted  Need n` 文案的可读性，以及多选同时含 HOLD / AMOV 状态时玩家是否理解护航摘要被战术状态优先隐藏，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.20。

### v4.21 / 海军生产按钮来源提示

日期：2026-07-06

核心变更：

- `SHIP`、`SUB` 和 `CV` 底部生产按钮 subtitle 现在显示当前实际海军生产来源。
- 当 `productionSource(for:faction:)` 找到 operational Shipyard 时显示 `SY $...`；没有 operational Shipyard 可生产对应海军单位时显示 `need SY`。
- `HELI` / `JET` 继续显示 `AF $...`、`CV $...` 或 `need AF/CV`；陆军生产按钮仍显示 `$<cost>`。
- 本轮只增强 HUD 只读文案，没有改变 `queueBuild`、`productionSource`、`canQueueBuild`、`BuildOrder`、费用、建造时间、资金检查、队列排序、AI 生产、Shipyard、Carrier、rally point、支援、迷雾、任务、胜负或按钮布局。
- README、flow、flowchart 和 v4.21 Agent A 提示词已同步当前真实行为，未宣称新增生产来源、按钮禁用、队列变化、新海军能力、AI 行为变化或任务变化。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.21（海军生产按钮来源提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`f8fedd378dc24d2441ed17210a8ed30b3c8ccf8e`，commit subject 为 `v4.21: 增强海军生产按钮来源提示`。
- diff reviewer 返回 `No issues`，确认当前 diff 只扩展 `SHIP` / `SUB` / `CV` subtitle 为 `SY $cost` 或 `need SY`，复用 `productionSource`，未改变 `queueBuild`、`productionSource`、`BuildOrder`、AI、生产规则、支援、fog、任务或按钮布局，`HELI` / `JET` 与陆军按钮不回归，文档未夸大；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `f8fedd378dc24d2441ed17210a8ed30b3c8ccf8e`。
- GitHub Actions：run `28769017078`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.21-main-f8fedd378dc2-run28769017078-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28769017078/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=f8fedd378dc24d2441ed17210a8ed30b3c8ccf8e`、`runId=28769017078`、`runAttempt=1`、`version=v4.21`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `SY $...` 和 `need SY` 在 `SHIP` / `SUB` / `CV` subtitle 中的可读性，以及玩家对该提示只是来源提示而非按钮禁用的理解度，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.21。

### v4.22 / 声呐选中面板潜艇接触数

日期：2026-07-06

核心变更：

- 玩家单选 active sonar sensor 时，选择信息面板现在显示 sonar range 和该 sensor 范围内已知敌方潜艇 contact 数，文案为 `Sonar <range> Ctc <count>`。
- contact count 只统计敌方、存活、kind 为 Submarine，且 `isKnownToFaction(..., observer: .player)` 已成立、距离不超过该 sensor `sonarRange(for:)` 的目标。
- 统计 helper 继续复用 `isActiveSonarSensor(_:)`，未完工 Sonar Buoy 不显示 contacts；非玩家 sensor 保留原 `Sonar <range>` 文案，避免混用玩家观测口径。
- 本轮只增强 HUD 只读文案，没有改变 `isKnownToFaction`、`isSubmarineDetected`、`sonarRange`、`revealedUntil`、`visibleTiles`、`exploredTiles`、`supportRevealTiles`、声呐覆盖圈、支援、AI、战斗、目标合法性、任务或胜负。
- README、flow 和 v4.22 Agent A 提示词已同步当前真实行为；`flowchart.md` 现有 HUD 节点已覆盖「选择/反潜/声呐信息」，本轮未强行改图。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.22（声呐选中面板潜艇接触数）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`8f04d68b05435273319f9eb6c240ab4805c4537a`，commit subject 为 `v4.22: 显示声呐潜艇接触数`。
- diff reviewer 返回 `No issues`，确认 contact count 只统计 enemy live submarine，必须经过 `isKnownToFaction(..., observer: .player)` 和选中 sensor 的 `sonarRange(for:)`，未写入 `revealedUntil`、fog、AI、combat、support 或 targeting 状态，文档未夸大；该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `8f04d68b05435273319f9eb6c240ab4805c4537a`。
- GitHub Actions：run `28769815270`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.22-main-8f04d68b0543-run28769815270-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28769815270/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=8f04d68b05435273319f9eb6c240ab4805c4537a`、`runId=28769815270`、`runAttempt=1`、`version=v4.22`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `Sonar 340 Ctc n` 文案的可读性，以及已知 / 未知敌方潜艇不会被 contact count 泄露的实战场景，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.22。

### v4.23 / Mechanic 维修选择反馈

日期：2026-07-06

核心变更：

- 玩家单选 Mechanic 时，选择信息面板现在显示自动维修范围和范围内己方受损可修目标数，文案为 `Repair 95  Damaged n`。
- 玩家选中 Mechanic 时，战场显示独立绿色维修范围圈；多选多个玩家 Mechanic 时可同时显示多个圈。
- 新增 `repairCoverageNode`，与 `sonarCoverageNode` 和 `escortCoverageNode` 分离；范围圈只由选择状态派生，未选中、敌方 Mechanic、非 Mechanic 不显示。
- 将 Mechanic 自动维修范围和维修速度抽为私有常量，数值仍为范围 95、每秒 22；`updateRepair(dt:)` 仍保持同阵营、存活、非自身、受损目标的最近目标选择与 `< 95` 范围语义。
- 本轮只增强 HUD / selection-derived visual，没有改变 Field Repair 支援、AI 生产 / 回修 / `REPR` 评分、移动、战斗、迷雾、潜艇侦测、声呐、护航、任务、胜负或 `SKRM` 重置。
- README、flow、flowchart 和 v4.23 Agent A 提示词已同步当前真实行为，未宣称新增手动维修命令、维修升级、AI 新策略或规则变化。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.23（Mechanic维修选择反馈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`dd2524d3c4c78af1531cf79246d5dbb078f7ab9c`，commit subject 为 `v4.23: 增强Mechanic维修选择反馈`。
- diff reviewer 返回 `No issues`，确认 `updateRepair` 行为保持范围 95、维修量 22/s、候选过滤和 `<` 比较语义；damaged count 只读且与候选口径一致；维修范围圈只在选中玩家 Mechanic 时显示，未影响 fog、AI、support、combat 或 targeting；文档未夸大为手动维修或规则变化。该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `dd2524d3c4c78af1531cf79246d5dbb078f7ab9c`。
- GitHub Actions：run `28770957347`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.23-main-dd2524d3c4c7-run28770957347-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28770957347/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=dd2524d3c4c78af1531cf79246d5dbb078f7ab9c`、`runId=28770957347`、`runAttempt=1`、`version=v4.23`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `Repair 95  Damaged n` 文案可读性、多个 Mechanic 范围圈显示、取消选择 / 死亡 / `SKRM` 后范围圈不残留，以及 damaged count 随距离和 HP 变化，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.23。

### v4.24 / 受损机动单位维修来源提示

日期：2026-07-06

核心变更：

- 玩家单选受损、存活、己方、非结构、非 Mechanic 的机动单位时，选择信息面板现在显示最近己方存活 Mechanic 的维修来源提示。
- 范围内显示 `MECH in range`；没有存活己方 Mechanic 时显示 `Need MECH`；有 Mechanic 但不在自动维修范围内时显示 `Need MECH  <distance>`。
- 提示只在没有 Submarine、Mechanic、Carrier、AMOV 或 HOLD 等更高优先级状态时显示，避免覆盖潜艇状态、Mechanic 自身维修摘要、航母专用面板和战术命令状态。
- 新增最近己方 Mechanic 距离和受损单位维修来源的纯查询 helper，只读取同阵营、存活、kind 为 Mechanic 的实体位置。
- 本轮只增强 HUD 只读文案，没有改变 `updateRepair(dt:)`、`mechanicRepairRange = 95`、`mechanicRepairPerSecond = 22`、维修目标选择、Field Repair 支援、AI、移动、战斗、迷雾、声呐、护航、任务、胜负或 `SKRM` 重置。
- README、flow、flowchart 和 v4.24 Agent A 提示词已同步当前真实行为，未宣称新增手动维修、自动寻路回修、维修升级或 AI 新能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.24（受损机动单位维修来源提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`93942178f4a8c7fc5f608a4617f38bae161a4596`，commit subject 为 `v4.24: 增强受损单位维修来源提示`。
- diff reviewer 返回 `No issues`，确认提示只在玩家己方、存活、受损、非结构、非 Mechanic 单选机动单位显示；Submarine / Mechanic / Carrier / AMOV / HOLD 不被覆盖；最近 Mechanic 查询只读、同阵营、存活、kind 为 Mechanic，并用 `distance < mechanicRepairRange` 判断范围内；未改变 `updateRepair`、AI、Field Repair、移动、战斗、迷雾或任务；文档未夸大。该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `93942178f4a8c7fc5f608a4617f38bae161a4596`。
- GitHub Actions：run `28772435918`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.24-main-93942178f4a8-run28772435918-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28772435918/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=93942178f4a8c7fc5f608a4617f38bae161a4596`、`runId=28772435918`、`runAttempt=1`、`version=v4.24`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `MECH in range` / `Need MECH <distance>` 文案可读性、满血单位不显示提示、AMOV / HOLD 优先级，以及距离跨过 95 边界时的提示变化，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.24。

### v4.25 / 支援按钮具体缺失资产提示

日期：2026-07-06

核心变更：

- 支援技能按钮在无冷却但缺少 operational asset 时，不再显示泛化 `need asset`，而是显示具体缺失资产短码。
- `SCAN` 显示 `need HQ/RAD`，`REPR` 显示 `need HQ/MECH`，`AIRS` 显示 `need AF/CV`，`BARR` 显示 `need BB/CV`。
- 缺资产短码复用 `supportAssetRequirementLabel(for:)`，与支援 pending 目标面板的 `Asset ready` / `Need` 口径保持一致。
- 支援按钮仍保持冷却秒数优先，资产满足时仍显示价格。
- 本轮只增强 HUD 只读文案，没有改变 `supportIssue(for:faction:)`、`hasOperationalSupportAsset(for:faction:)`、`executeSupportPower(...)`、支援费用、冷却、半径、效果、AI、pending、目标合法性、任务或胜负。
- README、flow、flowchart 和 v4.25 Agent A 提示词已同步当前真实行为，未宣称新增支援资产、按钮禁用、AI 行为变化或支援规则变化。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.25（支援按钮具体缺失资产提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`493e1e883205445e753eb6ef3a31d7872816282b`，commit subject 为 `v4.25: 支援按钮具体缺失资产提示`。
- diff reviewer 返回 `No issues`，确认 `supportButtonSubtitle(for:)` 保持冷却优先，缺资产分支复用 `supportAssetRequirementLabel(for:)`，价格 fallback 保持不变，未修改 `supportIssue`、`hasOperationalSupportAsset`、`executeSupportPower`、AI、费用、冷却或效果，README / flow / flowchart 未夸大范围。该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `493e1e883205445e753eb6ef3a31d7872816282b`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28775057730`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.25-main-493e1e883205-run28775057730-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28775057730/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=493e1e883205445e753eb6ef3a31d7872816282b`、`runId=28775057730`、`runAttempt=1`、`version=v4.25`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `need HQ/RAD`、`need HQ/MECH`、`need AF/CV`、`need BB/CV` 的可读性，以及支援按钮冷却 / 缺资产 / 价格三种状态切换，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、终局攻势提示深化或更多地图目标，但这些不属于 v4.25。

### v4.26 / 单选高价值海军护航缺口文案

日期：2026-07-06

核心变更：

- 玩家单选 Carrier 或 Battleship 时，选择信息面板的护航行现在直接显示护航是否达标。
- Carrier 达标时显示 `Escort x/2 OK`，不足时显示 `Escort x/2 Need n`。
- Battleship 达标时显示 `Escort x/1 OK`，不足时显示 `Escort x/1 Need n`。
- 缺口 `n` 由 `max(0, requirement - nearby)` 得出，并继续复用 `highValueNavalEscortRequirement(for:)` 和 `nearbyNavalEscortCount(for:)` 的既有口径。
- 本轮只增强单选 HUD 只读文案，没有改变多选高价值海军护航摘要、escort radius ring、Red AI 护航门槛、attack-move wave、玩家命令、移动、战斗、生产、支援、迷雾、任务、胜负或 `SKRM` 重置。
- README、flow 和 v4.26 Agent A 提示词已同步当前真实行为；`flowchart.md` 现有 HUD 节点已覆盖高价值海军护航状态 / 半径圈 / 多选摘要，本轮未强行改图。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.26（单选高价值海军护航缺口文案）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`e4a5aa0bdff469ddeddfe69fea4ce8dc2a2a7272`，commit subject 为 `v4.26: 单选高价值海军护航缺口文案`。
- diff reviewer 返回 `No issues`，确认 `highValueNavalEscortLine(for:)` 复用 `highValueNavalEscortRequirement(for:)` 和 `nearbyNavalEscortCount(for:)`，非 Carrier / Battleship 仍返回 `nil`，满足显示 `OK`，不足显示 `Need n`；未修改多选摘要、escort ring、AI、移动、战斗、生产、支援或 fog；文档未夸大。该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `e4a5aa0bdff469ddeddfe69fea4ce8dc2a2a7272`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28775989654`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.26-main-e4a5aa0bdff4-run28775989654-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28775989654/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=e4a5aa0bdff469ddeddfe69fea4ce8dc2a2a7272`、`runId=28775989654`、`runAttempt=1`、`version=v4.26`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `Escort x/y OK` 与 `Escort x/y Need n` 在 Carrier deck 行和 Battleship 移动行中的可读性，以及 escort 数量跨过达标边界时的文案变化，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做多选声呐接触数摘要、潜艇声呐接触状态、陆军生产按钮来源提示、航母 CAP / 巡逻或更多地图目标，但这些不属于 v4.26。

### v4.27 / 多选声呐编队接触数摘要

日期：2026-07-06

核心变更：

- 玩家多选包含至少一个玩家 active sonar sensor 时，多选反潜 / 声呐摘要现在追加去重后的已知敌方潜艇接触数，文案为 `Ctc n`。
- 多选摘要仍保留原有 `ASW n  Sonar n/maxRange` 格式，只在存在玩家 active sonar sensor 时追加 `Ctc n`。
- `Ctc n` 只统计敌方、存活、kind 为 Submarine、`isKnownToFaction(..., observer: .player)` 已成立、且处于至少一个已选玩家 active sonar sensor 的 `sonarRange(for:)` 内的目标。
- 多个已选 sonar sensor 覆盖同一潜艇时，按实体 id 去重，只计 1 次。
- 本轮只增强 HUD 只读文案，没有改变单选 sonar contact、`isKnownToFaction(...)`、`isSubmarineDetected(...)`、`revealedUntil`、战争迷雾集合、声呐覆盖圈、AI、战斗、支援、targeting、任务、胜负或 `SKRM` 重置。
- README、flow 和 v4.27 Agent A 提示词已同步当前真实行为；`flowchart.md` 现有 HUD 节点已覆盖选择 / 反潜 / 声呐信息，本轮未强行改图。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.27（多选声呐编队接触数摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`84f1781fbc59a04a8ba514cb185ef38b1990abf9`，commit subject 为 `v4.27: 多选声呐编队接触数摘要`。
- diff reviewer 返回 `No issues`，确认多选含玩家 active sonar sensor 时追加 `Ctc`，contact 统计必须是敌方存活 submarine、玩家已知、位于至少一个已选玩家 sensor range 内，并按 Int id 去重；未修改单选 sonar、`isKnownToFaction`、`isSubmarineDetected`、`revealedUntil`、fog、AI、combat、support 或 targeting；文档未夸大。该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `84f1781fbc59a04a8ba514cb185ef38b1990abf9`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28777394287`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.27-main-84f1781fbc59-run28777394287-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28777394287/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=84f1781fbc59a04a8ba514cb185ef38b1990abf9`、`runId=28777394287`、`runAttempt=1`、`version=v4.27`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `Dmg ... Max rng ... ASW ... Sonar ... Ctc n` 第三行的可读性，以及多个 sonar sensor 重叠覆盖、隐藏潜艇不泄露、未完工 Sonar Buoy 不计入的实战场景，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做潜艇声呐接触状态、陆军生产按钮来源提示、支援资金不足提示、航母 CAP / 巡逻或更多地图目标，但这些不属于 v4.27。

### v4.28 / 陆军生产按钮来源提示

日期：2026-07-06

核心变更：

- `HMV` / `AA` / `TANK` / `ART` / `MECH` 陆军生产按钮 subtitle 现在复用 `productionSource(for:faction:)` 显示 War Factory 来源。
- 有玩家 operational War Factory 来源时，陆军按钮显示 `WF $cost`；没有可用 War Factory 来源时显示 `need WF`。
- 该提示与实际 `queueBuild(kind:faction:showFeedback:)` 的来源选择口径一致，继续过滤未完工、死亡、敌方、中立或不能生产对应单位的实体，并保留玩家选中来源优先和最短队列口径。
- 本轮只增强 HUD 只读文案，没有改变 `queueBuild`、`productionSource`、`canQueueBuild`、`BuildOrder`、费用、建造时间、资金检查、玩家或 AI 生产、支援、迷雾、任务、胜负、按钮布局或 `SKRM` 重置。
- README、flow 和 v4.28 Agent A 提示词已同步当前真实行为；`flowchart.md` 现有 HUD 节点已覆盖生产来源提示，本轮未强行改图。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.28（陆军生产按钮来源提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`9478ad649c38584bbf7d9928e68c6c0cb3587ff5`，commit subject 为 `v4.28: 陆军生产按钮来源提示`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `9478ad649c38584bbf7d9928e68c6c0cb3587ff5`。
- GitHub Actions：run `28778044804`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.28-main-9478ad649c38-run28778044804-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28778044804/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=9478ad649c38584bbf7d9928e68c6c0cb3587ff5`、`runId=28778044804`、`runAttempt=1`、`version=v4.28`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `WF $cost` 与 `need WF` 的可读性、War Factory 施工完成前后的按钮切换、资金不足但有来源时的文案和点击拒绝，以及空军 / 海军来源提示不回归，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做潜艇声呐接触状态、支援资金不足提示、航母 CAP / 巡逻、航母护航命令或更多地图目标，但这些不属于 v4.28。

### v4.29 / 支援按钮资金不足提示

日期：2026-07-06

核心变更：

- `SCAN` / `REPR` / `AIRS` / `BARR` 支援按钮在未冷却、支援资产满足但玩家资金不足时，现在显示短缺金额，文案为 `need $shortfall`。
- 支援按钮显示优先级保持为冷却秒数、具体缺失资产短码、资金短缺金额、价格；缺资产时仍显示 `need HQ/RAD`、`need HQ/MECH`、`need AF/CV` 或 `need BB/CV`。
- 本轮只增强 HUD 只读文案，没有改变 `supportIssue(for:faction:)`、`selectSupportPower(_:)`、`executeSupportPower(...)`、支援费用、冷却、资产需求、半径、伤害、维修量、AI 支援使用、pending、目标合法性、迷雾、任务、胜负或 `SKRM` 重置。
- README、flow、flowchart 和 v4.29 Agent A 提示词已同步当前真实行为，未宣称按钮禁用、规则变化、资金预扣或 AI 新能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.29（支援按钮资金不足提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`792173aba73f2b4b8b28ff73bf4acffb9f5b42e1`，commit subject 为 `v4.29: 支援按钮资金不足提示`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `792173aba73f2b4b8b28ff73bf4acffb9f5b42e1`。
- GitHub Actions：run `28778944403`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.29-main-792173aba73f-run28778944403-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28778944403/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=792173aba73f2b4b8b28ff73bf4acffb9f5b42e1`、`runId=28778944403`、`runAttempt=1`、`version=v4.29`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `need $shortfall` 的可读性、缺资产且缺钱时仍优先显示具体资产、资产满足但资金跨过费用阈值时的文案切换，以及点击资金不足支援仍保持原有拒绝反馈，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做潜艇声呐接触状态、航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级或更多地图目标，但这些不属于 v4.29。

### v4.30 / 玩家潜艇已知声呐接触状态

日期：2026-07-06

核心变更：

- 玩家单选己方 Submarine 时，选择信息面板的潜艇状态现在区分临时暴露、玩家已知敌方声呐接触和无已知声呐接触。
- `revealedUntil` 有效时继续显示 `Temporary detected Ns`；未临时暴露且处于玩家已知敌方 active sonar sensor 范围内时显示 `Known sonar contact`；否则显示 `Stealth / no known contact`。
- 已知声呐接触只统计玩家已知的敌方 active sonar sensor，必须满足 `isKnownToFaction(sensor, observer: .player)`，不会通过隐藏敌方 Sonar Buoy、Submarine、Battleship、Carrier 或 Helicopter 泄露玩家未知情报。
- 本轮只增强 HUD 只读文案，没有改变 `isSubmarineDetected(...)`、`isKnownToFaction(...)`、`revealedUntil` 写入、战争迷雾集合、敌方显示、声呐 contact count、多选 `Ctc` 摘要、AI ASW、支援、战斗、任务、胜负或 `SKRM` 重置。
- README、flow 和 v4.30 Agent A 提示词已同步当前真实行为；`flowchart.md` 现有 HUD 节点已覆盖选择 / 反潜 / 声呐信息，本轮未强行改图。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.30（玩家潜艇已知声呐接触状态）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`d057f9f3eec0de07e361cb2f56b21f45829dd604`，commit subject 为 `v4.30: 玩家潜艇已知声呐接触状态`。
- diff reviewer 返回 `No issues`，确认状态行只对玩家己方潜艇追加已知声呐接触判断，隐藏敌方 sensor 受 `isKnownToFaction(sensor, observer: .player)` 约束不会泄露；未修改 `isSubmarineDetected`、`isKnownToFaction`、`revealedUntil`、fog、AI、support、combat、任务或胜负。该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `d057f9f3eec0de07e361cb2f56b21f45829dd604`。
- GitHub Actions：run `28780647763`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.30-main-d057f9f3eec0-run28780647763-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28780647763/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=d057f9f3eec0de07e361cb2f56b21f45829dd604`、`runId=28780647763`、`runAttempt=1`、`version=v4.30`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `Known sonar contact` 和 `Stealth / no known contact` 的可读性、玩家已知 / 未知敌方 sonar sensor 边界、临时暴露倒计时优先级，以及单选 / 多选声呐摘要不回归，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、潜艇战术反馈深化或更多地图目标，但这些不属于 v4.30。

### v4.31 / 高价值海军护航缺口类型提示

日期：2026-07-06

核心变更：

- 玩家单选 Carrier 或 Battleship 且附近护航不足时，选择信息面板的护航行现在在 `Need n` 后追加短缺口类型提示。
- 缺口类型只来自当前合法 nearby escort 集合：没有 air escort 时提示 `Air`，否则没有 naval escort 时提示 `Sea`，否则没有 land escort 时提示 `Ground`，三类都有但数量仍不足时提示 `Mix`。
- 达标时仍显示 `Escort x/y OK`，不追加缺口类型。
- `nearbyNavalEscortCount(for:)` 和缺口类型提示现在共享 `nearbyNavalEscorts(for:)` 的同一合法 escort 集合口径，继续过滤敌方/中立、死亡、未 operational、结构、非作战、高价值海军自身和范围外单位。
- 本轮只增强单选 HUD 只读文案，没有改变多选 `HV Navy` 摘要、escort radius ring、sonar coverage、Red AI 护航门槛、attack-move wave、玩家命令、移动、战斗、生产、支援、迷雾、任务、胜负或 `SKRM` 重置。
- README、flow、flowchart 和 v4.31 Agent A 提示词已同步当前真实行为，未宣称自动护航、CAP、巡逻、战斗加成或新命令。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.31（高价值海军护航缺口类型提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`153562c2943a2e94b78342f1cef42cb0cd5fef93`，commit subject 为 `v4.31: 高价值海军护航缺口类型提示`。
- diff reviewer 返回 `No issues`，确认本轮只改 HUD 文案 helper；`nearbyNavalEscorts(for:)` 与原 `nearbyNavalEscortCount(for:)` 口径一致；未破坏多选摘要、AI、escort ring、sonar、移动或战斗。该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `153562c2943a2e94b78342f1cef42cb0cd5fef93`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28786905554`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.31-main-153562c2943a-run28786905554-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28786905554/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=153562c2943a2e94b78342f1cef42cb0cd5fef93`、`runId=28786905554`、`runAttempt=1`、`version=v4.31`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `Escort x/y Need n Air/Sea/Ground/Mix` 在 Carrier deck 行和 Battleship 移动行的可读性，以及护航单位组成变化时的文案切换，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、潜艇战术反馈深化或更多地图目标，但这些不属于 v4.31。

### v4.32 / 多选高价值海军护航缺口类型摘要

日期：2026-07-06

核心变更：

- 玩家多选包含 Carrier / Battleship 且至少一个高价值海军护航不足时，多选摘要现在在总缺口 `Need n` 后追加 Air / Sea / Ground / Mix 缺口类型。
- 多个不足项缺口类型一致时显示该类型；多个不足项类型不一致时显示 `Mix`。
- 所有被选中高价值海军护航达标时，仍显示原有 `HV Navy x/y escorted`，不追加缺口类型。
- 多选摘要复用 `nearbyNavalEscorts(for:)` 和 `highValueNavalEscortNeedType(for:)`，与单选 Carrier / Battleship 护航提示共享同一合法 escort 集合口径。
- 本轮只增强多选 HUD 只读文案，没有改变单选护航文案、HOLD / AMOV 多选优先级、escort radius ring、sonar coverage、Red AI 护航门槛、attack-move wave、玩家命令、移动、战斗、生产、支援、迷雾、任务、胜负或 `SKRM` 重置。
- README、flow 和 v4.32 Agent A 提示词已同步当前真实行为；`flowchart.md` 现有 HUD 节点已覆盖高价值海军护航状态 / 缺口类型 / 半径圈 / 多选摘要，本轮未强行改图。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.32（多选高价值海军护航缺口类型摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`ba42f2db151cd67e4b19811b8f65a7ae04257296`，commit subject 为 `v4.32: 多选高价值海军护航缺口类型摘要`。
- diff reviewer 返回 `No issues`，确认本轮只改多选 HUD 摘要生成，复用 `nearbyNavalEscorts(for:)` 和 `highValueNavalEscortNeedType(for:)`，保留 HOLD / AMOV 优先级，未触碰 AI、escort ring、sonar、移动、战斗或单选逻辑。该 reviewer 未运行本地测试、构建或静态检查。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `ba42f2db151cd67e4b19811b8f65a7ae04257296`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28787678569`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.32-main-ba42f2db151c-run28787678569-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28787678569/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=ba42f2db151cd67e4b19811b8f65a7ae04257296`、`runId=28787678569`、`runAttempt=1`、`version=v4.32`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `HV Navy x/y escorted  Need n Air/Sea/Ground/Mix` 的可读性，以及多艘高价值海军不同缺口类型汇总为 `Mix` 的场景，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续做航母 CAP / 巡逻、航母护航命令、Sonar Buoy 升级、潜艇战术反馈深化或更多地图目标，但这些不属于 v4.32。

### v4.33 / 航母空中翼队状态提示

日期：2026-07-06

核心变更：

- 玩家单选 Carrier 时，选择信息面板的 rally / queue 行现在追加附近友方 HEL/JET 空中翼队 readiness。
- 翼队状态统计同阵营、存活、operational、非结构、kind 为 Helicopter 或 Fighter、距离 Carrier 不超过 `highValueNavalEscortRadius` 的单位。
- 达标时显示 `Wing x/2 OK`，不足时显示 `Wing x/2 Need n`。
- 本轮只增强 Carrier 单选 HUD 只读文案，没有实现 CAP、巡逻、自动护航、follow、拦截、自动起飞、命令队列或新 HUD action。
- 本轮没有改变 Carrier 生产、deck launch、rally、air source hint、BuildOrder、queueBuild、高价值海军 escort 统计、AI 护航门槛、attack-move wave、玩家命令、移动、战斗、支援、迷雾、声呐、任务、胜负或 `SKRM` 重置。
- README、flow、flowchart 和 v4.33 Agent A 提示词已同步当前真实行为，未宣称 CAP、巡逻、自动护航、拦截、战斗加成或新命令。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.33（航母空中翼队状态提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`13eb2de0a411a2b98e8c2c6f1ddbef551c274505`，commit subject 为 `v4.33: 航母空中翼队状态提示`。
- diff reviewer 返回 `No issues`，确认本轮只做只读静态 review，未改文件、未运行测试 / 构建 / 本地检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `13eb2de0a411a2b98e8c2c6f1ddbef551c274505`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28788465753`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.33-main-13eb2de0a411-run28788465753-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28788465753/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=13eb2de0a411a2b98e8c2c6f1ddbef551c274505`、`runId=28788465753`、`runAttempt=1`、`version=v4.33`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 Carrier rally / queue 行追加 `Wing x/2 OK` 或 `Wing x/2 Need n` 后的可读性，以及 HEL/JET 进出航母半径时的文案切换，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续把本轮 wing readiness 扩展为航母 CAP / 巡逻的第一条真实命令链，或继续做 Sonar Buoy 升级、潜艇战术反馈深化或更多地图目标，但这些不属于 v4.33。

### v4.34 / 航母 HOLD 空中警戒翼队

日期：2026-07-06

核心变更：

- 玩家对选中 Carrier 下达 `HOLD` 时，Carrier 本身仍按普通 HOLD 记录当前位置并进入警戒。
- 同一次 HOLD 会把附近同阵营、存活、operational、非结构、位于 `highValueNavalEscortRadius` 内的 Helicopter / Fighter 一次性设为 guard wing。
- guard wing 不新增独立状态机或 Carrier 绑定，只把相关 HEL/JET 的 `holdPosition` 设置为飞机当前位置，并清理原攻击目标、attack-move、destination 和 path，复用现有 HOLD 警戒、交战和回位链路。
- Carrier 单选 HUD 未 HOLD 时继续显示 `Wing x/2 OK` 或 `Wing x/2 Need n` readiness；Carrier HOLD 时改为只统计附近已 HOLD 的 HEL/JET，并显示 `Guard wing x/2 OK` 或 `Guard wing x/2 Need n`。
- HOLD 反馈消息会在实际分配到 guard wing 时追加 `Guard wing n.`。
- 本轮没有实现 CAP、巡逻、自动跟随、拦截、自动起飞、新 HUD action、AI 航母策略、战斗加成、生产来源变化、集结点变化、声呐/潜艇隐身变化、任务或胜负变化。
- README、flow、flowchart 和 v4.34 Agent A 提示词已同步当前真实行为，未宣称未实现的自动护航能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.34（航母HOLD空中警戒翼队）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`fb8a0c0a4d52dc46b1948314ded57b83607ec0cf`，commit subject 为 `v4.34: 航母HOLD空中警戒翼队`。
- diff reviewer 首轮发现 `nearbyCarrierAirWing(for:)` 返回类型与残留 `.count` 不一致的 Swift 类型错误；已修复后，二审返回 `No issues`。两个 reviewer 均未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `fb8a0c0a4d52dc46b1948314ded57b83607ec0cf`。
- GitHub Actions：run `28789672979`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.34-main-fb8a0c0a4d52-run28789672979-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28789672979/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=fb8a0c0a4d52dc46b1948314ded57b83607ec0cf`、`runId=28789672979`、`runAttempt=1`、`version=v4.34`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `Guard wing x/2 OK` / `Need n` 的可读性、HOLD 航母时附近 HEL/JET 被正确设为警戒、后续单独移动/AMOV/攻击可自然脱离 HOLD、以及多艘 Carrier 半径重叠时的 guard wing 分配体验，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续在本轮 guard wing 基础上设计真正 CAP / 巡逻 / 截击或航母翼队 UI，但这些不属于 v4.34。

### v4.35 / 航母警戒翼队锚点绑定

日期：2026-07-06

核心变更：

- `GameEntity` 新增 `guardAnchorCarrierID` 运行态字段，用于 HEL/JET 记录当前 Carrier HOLD guard wing 的归属。
- Carrier HOLD 分配附近己方 operational HEL/JET 为 guard wing 时，会继续把飞机设为自身当前位置 HOLD，并写入当前 Carrier id。
- Carrier 单选 HUD 未 HOLD 时仍按附近 HEL/JET 显示 `Wing x/2 OK` 或 `Wing x/2 Need n` readiness；Carrier HOLD 时只把附近仍 HOLD 且 `guardAnchorCarrierID` 等于该 Carrier id 的 HEL/JET 计入 `Guard wing x/2 OK` 或 `Guard wing x/2 Need n`。
- HEL/JET 收到普通移动、AMOV、直接攻击或普通 HOLD 时会清理旧 Carrier guard anchor；再次被 Carrier HOLD 分配时可改写为新 Carrier id。
- 本轮没有实现 CAP、巡逻、自动跟随、拦截、新 HUD action、AI 航母策略、战斗加成、生产来源变化、集结点变化、声呐/潜艇隐身变化、任务或胜负变化。
- README、flow、flowchart 和 v4.35 Agent A 提示词已同步当前真实行为，未宣称未实现的自动护航能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.35（航母警戒翼队锚点绑定）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`b76a8cda05e075b4a15e4c568ce271c309a4af82`，commit subject 为 `v4.35: 航母警戒翼队锚点绑定`。
- diff reviewer 返回 `No issues`，确认本轮满足 v4.35 提示词，清理点覆盖普通 HOLD、普通移动 / AMOV 和直接攻击，未误改 AI、生产、迷雾、声呐或战斗公式。该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `b76a8cda05e075b4a15e4c568ce271c309a4af82`。
- GitHub Actions：run `28790651099`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.35-main-b76a8cda05e0-run28790651099-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28790651099/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=b76a8cda05e075b4a15e4c568ce271c309a4af82`、`runId=28790651099`、`runAttempt=1`、`version=v4.35`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下绑定后的 `Guard wing x/2 OK` / `Need n` 文案、多艘 Carrier 半径重叠时的改绑体验、HEL/JET 普通移动 / AMOV / 攻击 / HOLD 后旧绑定清理，以及 Carrier 移动后回到 readiness 的体验，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可在该 anchor 口径上继续设计真正 CAP / 巡逻 / 截击或航母翼队 UI，但这些不属于 v4.35。

### v4.36 / 航母警戒翼队站位保持

日期：2026-07-06

核心变更：

- Carrier HOLD guard wing 从只读绑定推进到轻量实际行为：已绑定到 Carrier 的 Helicopter / Fighter 会在 Carrier 仍 HOLD 时维护 Carrier 附近稳定站位。
- 新增 `updateCarrierGuardStation(for:)` 和 `carrierGuardStationPoint(for:carrier:)`，每帧移动更新先刷新绑定翼队的 `holdPosition`，再继续复用既有 HOLD 回位、警戒和交战链路。
- 站位点由 wing id 和单位类型派生，Helicopter / Fighter 使用不同相位和半径，避免所有翼队重叠；站位半径小于 `highValueNavalEscortRadius`。
- 绑定 Carrier 不存在、死亡、阵营不匹配、不是 Carrier 或不再 HOLD 时，只清理该 HEL/JET 的 `guardAnchorCarrierID`，不强行清理其普通 HOLD、目标、destination 或 path。
- v4.35 的普通移动、AMOV、直接攻击和普通 HOLD 清理旧 anchor 语义保持不变；再次 Carrier HOLD 仍可改写绑定。
- 本轮没有实现完整 CAP、巡逻路径、主动截击、新 HUD action、AI 航母策略、战斗加成、生产来源变化、集结点变化、声呐 / 潜艇隐身变化、任务或胜负变化。
- README、flow、flowchart 和 v4.36 Agent A 提示词已同步当前真实行为，未宣称未实现的 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.36（航母警戒翼队站位保持）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`5abe0e1c9d0949c5d4fc2151646afe83c85f0cc8`，commit subject 为 `v4.36: 航母警戒翼队站位保持`。
- 本轮未运行本地 diff reviewer 子 agent；由 Agent C 直接复核实际 diff、提示词、文档和云端 artifact。Agent C 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `5abe0e1c9d0949c5d4fc2151646afe83c85f0cc8`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28792235758`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.36-main-5abe0e1c9d09-run28792235758-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28792235758/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=5abe0e1c9d0949c5d4fc2151646afe83c85f0cc8`、`runId=28792235758`、`runAttempt=1`、`version=v4.36`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备 HUD 宽度下 `Guard wing x/2 OK` / `Need n` 与站位保持的体验、多艘 Carrier 半径重叠时的站位分配、Carrier 警戒交战时翼队回位表现、以及 Carrier 取消 HOLD 后翼队保留普通 HOLD 的体验，仍建议在可用模拟器或真机上做人工 Stage Regression。
- 后续可继续在该站位保持基础上设计真正 CAP / 巡逻 / 截击或航母翼队 UI，但这些不属于 v4.36。

### v4.37 / 航母警戒翼队近域威胁优先

日期：2026-07-06

核心变更：

- Carrier HOLD guard wing 在 v4.36 站位保持基础上新增近域威胁优先目标选择。
- 新增 `carrierGuardAnchor(for:)` 复用绑定 Carrier 有效性判断，减少站位保持和目标优先逻辑的条件重复。
- 新增 `carrierGuardPriorityTarget(for:)`，只在 HEL/JET 仍绑定到存活、同阵营、仍 HOLD 的 Carrier 且自身仍有 `holdPosition` 时生效。
- 绑定翼队没有当前攻击目标时，会优先选择 Carrier 近域内已知、敌对、可攻击且仍位于自身 HOLD 站位警戒半径内的威胁；无合法近域威胁时回落到原普通 HOLD / AMOV / 射程目标搜索。
- 目标过滤继续检查 `isKnownToFaction(...)`、`EntityKind.canAttack(...)`、Carrier 近域半径和翼队 HOLD 站位半径，不绕过迷雾、潜艇隐身或可攻击规则。
- 目标排序以靠近被守护 Carrier 为主，并给 Fighter 对空、Helicopter 对潜艇 / 海军目标一个轻量优先级；不改变伤害、射程、冷却或目标清理规则。
- 本轮没有实现完整 CAP、巡逻路径、主动截击状态机、新 HUD action、AI 航母策略、战斗加成、生产来源变化、集结点变化、声呐 / 潜艇隐身变化、任务或胜负变化。
- README、flow、flowchart 和 v4.37 Agent A 提示词已同步当前真实行为，未宣称未实现的完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.37（航母警戒翼队近域威胁优先）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`47916cca095d475114e58de887e107bed179d4ff`，commit subject 为 `v4.37: 航母警戒翼队近域威胁优先`。
- 本轮未运行本地 diff reviewer 子 agent；由 Agent C 直接复核实际 diff、提示词、文档和云端 artifact。Agent C 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `47916cca095d475114e58de887e107bed179d4ff`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28793777782`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.37-main-47916cca095d-run28793777782-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28793777782/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=47916cca095d475114e58de887e107bed179d4ff`、`runId=28793777782`、`runAttempt=1`、`version=v4.37`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Fighter guard wing 对 Carrier 近域空中威胁的优先级、Helicopter guard wing 对已知潜艇 / 海军威胁的优先级、威胁离开 HOLD 站位半径后的目标清理、隐藏潜艇不被 HUD 或目标选择泄露。
- 后续可继续在该目标优先基础上设计更明确的 CAP / 巡逻 / 截击 UI 或 AI 航母使用，但这些不属于 v4.37。

### v4.38 / 航母警戒翼队接触数提示

日期：2026-07-06

核心变更：

- Carrier HOLD guard wing 的单选 HUD 行在 `Guard wing x/2 OK` 或 `Guard wing x/2 Need n` 后追加 `Ctc n` 已知接触数。
- `Ctc n` 只统计当前 Carrier 附近仍 HOLD 且 `guardAnchorCarrierID` 等于该 Carrier id 的 HEL/JET 可处理的近域威胁，并按目标 entity id 去重。
- 新增 `boundCarrierGuardWing(for:)` 统一 Carrier HOLD guard wing 统计口径，避免 HUD 计数和绑定翼队列表分叉。
- 新增 `carrierGuardContactCount(for:guardWing:)` 和 `isCarrierGuardContact(...)`，让 HUD 接触数与 v4.37 的近域威胁优先目标过滤共享同一合法性判断。
- 接触过滤继续要求目标存活、敌对、非中立、对该 wing 可攻击、对 wing 阵营已知、位于 Carrier 近域半径内且仍满足 wing HOLD 站位警戒半径，不绕过迷雾、潜艇隐身或 `canAttack` 规则。
- 本轮只读增强 HUD，没有改变 combat/AI/visibility、`revealedUntil`、迷雾集合、攻击目标、命令状态、伤害、射程、冷却、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.38 Agent A 提示词已同步当前真实行为，未宣称未实现的完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.38（航母警戒翼队接触数提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`76c51dec39920afddbe2a9f905e1b49b592f0e79`，commit subject 为 `v4.38: 航母警戒翼队接触数提示`。
- diff reviewer 子 agent 返回 `No issues`，确认 `Ctc n` 统计复用 guard wing 目标合法性 predicate，按目标 id 去重，未发现写入 combat/AI/visibility/命令状态的路径；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `76c51dec39920afddbe2a9f905e1b49b592f0e79`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28795132865`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.38-main-76c51dec3992-run28795132865-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28795132865/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=76c51dec39920afddbe2a9f905e1b49b592f0e79`、`runId=28795132865`、`runAttempt=1`、`version=v4.38`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Carrier HOLD 面板中 `Guard wing x/2 ...  Ctc n` 的宽度、多个 wing 共同发现同一目标时的去重、隐藏潜艇不被接触数泄露、目标离开 Carrier 近域或 wing HOLD 半径后的接触数回落。
- 后续可继续在该接触数提示基础上设计更明确的 CAP / 巡逻 / 截击 UI、航母翼队命令或 AI 航母使用，但这些不属于 v4.38。

### v4.39 / 航母警戒翼队接触类型提示

日期：2026-07-06

核心变更：

- Carrier HOLD guard wing 的单选 HUD 行在 `Ctc n` 非零时追加接触类型摘要：`Air`、`Sea`、`Sub`、`Ground` 或 `Mix`。
- `Ctc 0` 不追加类型，避免无接触时显示无意义的类型。
- `carrierGuardContactCount(for:guardWing:)` 升级为 `carrierGuardContactSummary(for:guardWing:)`，同时返回去重数量和类型摘要。
- 新增 `carrierGuardContactType(for:)`，将已合法 contact 分为空中、水面、潜艇和地面 / 结构四类；多类型集合显示 `Mix`。
- 类型摘要和接触数使用同一个 `Set<Int>` 目标 id 去重集合，同一个目标被多个 wing 看到或可攻击时只贡献一次数量和一次类型。
- 类型摘要继续复用 `isCarrierGuardContact(...)` 过滤结果，保持 `isKnownToFaction(...)`、`canAttack(...)`、Carrier 近域半径和 wing HOLD 站位警戒半径边界，不泄露隐藏潜艇或未知目标。
- 本轮只读增强 HUD，没有改变 combat/AI/visibility、`revealedUntil`、迷雾集合、攻击目标、命令状态、伤害、射程、冷却、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.39 Agent A 提示词已同步当前真实行为，未宣称未实现的完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.39（航母警戒翼队接触类型提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`a87c213270263e93b17631d55e58be97a551c6ea`，commit subject 为 `v4.39: 航母警戒翼队接触类型提示`。
- diff reviewer 子 agent 返回 `No issues`，确认 `Ctc n` 类型摘要复用 `isCarrierGuardContact(...)` 过滤后的同一去重 contact 集合，未发现写入 combat、AI、visibility、命令或迷雾状态的路径；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `a87c213270263e93b17631d55e58be97a551c6ea`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28796279462`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.39-main-a87c21327026-run28796279462-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28796279462/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=a87c213270263e93b17631d55e58be97a551c6ea`、`runId=28796279462`、`runAttempt=1`、`version=v4.39`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Carrier HOLD 面板中 `Ctc n Air/Sea/Sub/Ground/Mix` 的宽度、多个类型混合时显示 `Mix`、`Ctc 0` 不显示类型、隐藏潜艇不会通过 `Sub` 类型泄露。
- 后续可继续在该接触类型提示基础上设计更明确的 CAP / 巡逻 / 截击 UI、航母翼队命令或 AI 航母使用，但这些不属于 v4.39。

### v4.40 / 航母警戒翼队优先接触提示

日期：2026-07-06

核心变更：

- Carrier HOLD guard wing 的单选 HUD 行在 `Ctc n` 非零时追加 `Tgt XXX`，用目标 `shortCode` 只读显示当前 guard wing 合法接触集合中的优先接触。
- `Ctc 0` 不追加类型或 `Tgt`，避免无接触时显示伪目标。
- `carrierGuardContactSummary(for:guardWing:)` 继续用同一循环统计去重数量和类型摘要，并新增 `targetCode` 返回值。
- 优先接触候选只来自已通过 `isCarrierGuardContact(...)` 的 wing-target pair，继续要求目标已知、敌对、非中立、可被该 wing 攻击、位于 Carrier 近域内并满足 wing HOLD 站位警戒半径。
- `Tgt XXX` 镜像现有优先规则：`carrierGuardTargetPriority(for:target:)` 值更小者优先，优先级相同时距离 Carrier 更近者优先，距离近似相同时 entity id 更小者优先。
- 本轮只读增强 HUD，没有改变 `carrierGuardPriorityTarget(for:)` 的 combat 目标选择，没有写入 `attackTarget`、`destination`、`revealedUntil`、迷雾集合、命令状态、AI 评分、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.40 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 真实锁定 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.40（航母警戒翼队优先接触提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent B 实现提交并推送：`f2d5d013b122b0885e3db690f907304bea56a76c`，commit subject 为 `v4.40: 航母警戒翼队优先接触提示`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `f2d5d013b122b0885e3db690f907304bea56a76c`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28798004734`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.40-main-f2d5d013b122-run28798004734-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28798004734/`，缓存目录大小 `100K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=f2d5d013b122b0885e3db690f907304bea56a76c`、`runId=28798004734`、`runAttempt=1`、`version=v4.40`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Carrier HOLD 面板中 `Ctc n ... Tgt XXX` 的宽度、`Ctc 0` 不显示 `Tgt`、多个 wing 可攻击不同目标时 `Tgt` 与实际优先口径一致、隐藏潜艇不会通过 `Tgt SUB` 泄露。
- 后续可继续在该优先接触提示基础上设计更明确的 CAP / 巡逻 / 截击 UI、航母翼队命令或 AI 航母使用，但这些不属于 v4.40。

### v4.41 / 航母警戒翼队 HUD 紧凑化

日期：2026-07-06

核心变更：

- Carrier HOLD guard wing 的单选 HUD 行从较长的 `Guard wing ... Ctc ...` 格式压缩为 `GW ... Cn` 格式，降低与 Carrier queue / rally 行拼接后的宽度压力。
- Carrier 未 HOLD 时仍显示 `Wing x/2 OK` 或 `Wing x/2 Need n` readiness；Carrier HOLD 时显示 `GW x/2 OK C0`、`GW x/2 Need n C0` 或非零接触时的 `GW x/2 ... Cm Air/Sea/Sub/Ground/Mix Tgt XXX`。
- `C0` 只表示 0 接触，不追加 Air / Sea / Sub / Ground / Mix 类型或 `Tgt XXX`，保留 v4.40 的 0 接触不显示伪目标语义。
- 非零接触仍只消费 `carrierGuardContactSummary(for:guardWing:)` 的 `count`、`type` 和 `targetCode`，没有改变 contact predicate、目标排序、去重、迷雾或潜艇侦测边界。
- 本轮只读压缩 HUD 文案，没有改变 `isCarrierGuardContact(...)`、`carrierGuardTargetPriority(for:target:)`、`carrierGuardPriorityTarget(for:)`、guard wing 绑定 / 站位、combat、AI、visibility、`revealedUntil`、迷雾集合、攻击目标、命令状态、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.41 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 真实锁定 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.41（航母警戒翼队HUD紧凑化）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.41 实现提示词；Agent X 并行只读 scout 建议优先处理 v4.38-v4.40 叠加后的 HUD 行宽风险。
- Agent B 实现提交并推送：`59150246cde68cc6d7b45b0c5c0acdf78fa11d32`，commit subject 为 `v4.41: 航母警戒翼队HUD紧凑化`。
- diff reviewer 子 agent 返回 `No issues`，确认本轮只压缩 Carrier HOLD guard wing HUD 文案并同步文档，未发现 contact predicate、目标排序、迷雾、潜艇侦测、AI、移动、战斗、生产或 `SKRM` 被误改；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `59150246cde68cc6d7b45b0c5c0acdf78fa11d32`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28800608099`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.41-main-59150246cde6-run28800608099-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28800608099/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=59150246cde68cc6d7b45b0c5c0acdf78fa11d32`、`runId=28800608099`、`runAttempt=1`、`version=v4.41`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Carrier HOLD 面板中 `GW x/2 ... Cn ...` 的可读性、`C0` 不显示类型 / `Tgt`、非零接触类型和 `Tgt` 仍与实际优先口径一致、隐藏潜艇不会通过 `Sub` 或 `Tgt SUB` 泄露。
- 后续可在该紧凑格式基础上继续设计更明确的 guard wing 交战状态、CAP / 巡逻 / 截击 UI、航母翼队命令或 AI 航母使用，但这些不属于 v4.41。

### v4.42 / 航母警戒翼队交战数提示

日期：2026-07-06

核心变更：

- Carrier HOLD guard wing 的单选 HUD 紧凑行在存在实际交战翼队时追加非零 `Eng n`，例如 `GW 2/2 OK C1 Air Tgt JET Eng 1`。
- `Eng n` 统计当前绑定该 Carrier 的 HEL/JET 中，当前 `attackTarget` 仍满足 `isCarrierGuardContact(...)` 的翼队成员数量；两个翼队攻击同一合法目标时计为 `Eng 2`。
- `Eng 0` 不显示，以保持 v4.41 后的紧凑 HUD 宽度；0 交战时仍只显示 `GW ... C0` 或现有非零 contact / type / `Tgt` 摘要。
- 新增 `carrierGuardEngagedCount(for:guardWing:)` 作为只读 helper，只读取 `holdPosition` 与 `attackTarget` 并复用 `isCarrierGuardContact(...)`，不写入任何实体、命令、迷雾或战斗状态。
- 本轮没有改变 `isCarrierGuardContact(...)`、`carrierGuardPriorityTarget(for:)`、`updateCombat(dt:)` 的目标写入 / 清理、contact 去重、类型摘要、`Tgt` 排序、迷雾、潜艇侦测、AI、移动、战斗、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.42 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 真实锁定 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.42（航母警戒翼队交战数提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.42 实现提示词；Agent X 只读 scout 确认 `carrierAirWingLine(...)` 是安全入口，`Eng n` 应只读 `guardWing.attackTarget` 且复用 `isCarrierGuardContact(...)`。
- Agent B 实现提交并推送：`1c3055528aa4ba1c7b623a77f0f4a84a25aafd24`，commit subject 为 `v4.42: 航母警戒翼队交战数提示`。
- diff reviewer 子 agent 返回 `No issues`，确认本轮只给单选 HOLD Carrier 的 `GW ... Cn` HUD 行追加非零 `Eng n`，未发现 contact predicate、目标排序、attackTarget 写入、迷雾、潜艇侦测、AI、移动、战斗、生产或 `SKRM` 被误改；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `1c3055528aa4ba1c7b623a77f0f4a84a25aafd24`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28803820429`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.42-main-1c3055528aa4-run28803820429-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28803820429/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=1c3055528aa4ba1c7b623a77f0f4a84a25aafd24`、`runId=28803820429`、`runAttempt=1`、`version=v4.42`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Carrier HOLD 面板中非零 `Eng n` 的可读性、翼队目标过期 / 离开合法半径后 `Eng` 回落、两个翼队攻击同一目标时显示翼队数量而不是去重目标数、隐藏潜艇不会通过 `Eng` 与 `Tgt SUB` 泄露。
- 后续可继续在该 guard wing 可读性基础上设计更明确的 CAP / 巡逻 / 截击 UI、航母翼队命令或 AI 航母使用，但这些不属于 v4.42。

### v4.43 / 多选航母警戒翼队摘要

日期：2026-07-06

核心变更：

- 多选面板在选中集合包含玩家 HOLD Carrier 时，会在 HOLD 状态行追加紧凑 `CV GW x/y OK/Need Cn Eng n` 摘要。
- `x` 统计选中 HOLD Carrier 当前绑定的 HEL/JET 总数，复用 `boundCarrierGuardWing(for:)` 口径；`y` 为选中 HOLD Carrier 数量乘以 2。
- `C` 按目标 entity id 跨选中 HOLD Carrier 去重，只统计仍满足 `isCarrierGuardContact(...)` 的合法 guard contact。
- `Eng n` 只在非零时显示，统计绑定 wing 中当前 `attackTarget` 仍满足 `isCarrierGuardContact(...)` 的 HEL/JET 数量；两个 wing 攻击同一合法目标时仍按 wing 数计。
- 没有选中 HOLD Carrier 时，多选 HOLD 行仍保持普通 `Holding n  Guard ...`；单选 Carrier 的 `GW ... Cn ... Tgt ... Eng n` 行、AMOV、高价值海军 escort 摘要和老兵摘要优先级保持原语义。
- 本轮只读增强 HUD，没有改变 `isCarrierGuardContact(...)`、`carrierGuardPriorityTarget(for:)`、`updateCombat(dt:)` 的目标写入 / 清理、guard anchor 写入 / 清理、迷雾、潜艇侦测、AI、移动、战斗、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.43 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.43（多选航母警戒翼队摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.43 实现提示词；Agent X 并行只读 scout 确认多选面板会丢失 Carrier guard wing 信息，适合补只读摘要。
- Agent B 实现提交并推送：`4e685d7109406d7c4ac34cb27d1550ab69d7b424`，commit subject 为 `v4.43: 多选航母警戒翼队摘要`。
- diff reviewer 子 agent 返回 `No issues`，确认本轮新增 `groupCarrierGuardWingSummary` 为只读统计，复用 `boundCarrierGuardWing`、`carrierGuardEngagedCount` 和 `isCarrierGuardContact`，未发现单选 Carrier、普通 HOLD、AMOV、高价值海军 escort、迷雾或潜艇边界被误改；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `4e685d7109406d7c4ac34cb27d1550ab69d7b424`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28805154005`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.43-main-4e685d710940-run28805154005-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28805154005/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=4e685d7109406d7c4ac34cb27d1550ab69d7b424`、`runId=28805154005`、`runAttempt=1`、`version=v4.43`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：多选 HOLD Carrier 编队时 `CV GW x/y OK/Need Cn Eng n` 的宽度、多个 Carrier 共享同一目标时 `C` 是否按目标去重、多个 wing 攻击同一目标时 `Eng` 是否按 wing 计数、隐藏潜艇不会通过 `C` 或 `Eng` 泄露。
- 后续可继续在 guard wing 可读性基础上设计 HOLD 下达时的短视觉反馈、CAP / 巡逻 / 截击 UI、航母翼队命令或 AI 航母使用，但这些不属于 v4.43。

### v4.44 / 航母HOLD警戒翼队分配反馈

日期：2026-07-07

核心变更：

- 玩家对包含 Carrier 的选择下达 `HOLD` 且本次确实绑定至少一个 guard wing 时，会在拥有绑定翼队的 Carrier 甲板位置显示短暂 `CV GUARD` cue。
- 该 cue 复用现有 `showCarrierDeckPulse(at:faction:label:)`，自动淡出，不新增持久节点、命令状态或实体字段。
- `issueHoldPositionOrder(units:)` 现在先保存本次 HOLD 的 Carrier 集合，再调用原有 `assignCarrierGuardWing(for:)`；绑定成功后只读回查 `boundCarrierGuardWing(for:)`，避免无翼队 Carrier 显示误导性 guard cue。
- 原普通 `showHoldMarker(at:)` 和 `Hold position: ... Guard wing n.` 顶部消息保留。
- 本轮没有改变 `assignCarrierGuardWing(for:)` 的筛选条件、`guardAnchorCarrierID` 写入 / 清理、`isCarrierGuardContact(...)`、`carrierGuardPriorityTarget(for:)`、单选 `GW` 行、多选 `CV GW` 摘要、迷雾、潜艇侦测、AI、移动、战斗、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.44 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.44（航母HOLD警戒翼队分配反馈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.44 实现提示词；Agent X 并行只读 scout 确认最小安全实现是不改 `assignCarrierGuardWing` 返回结构，绑定后用 `boundCarrierGuardWing(for:)` 回查并复用 `showCarrierDeckPulse(...)`。
- Agent B 实现提交并推送：`76d7eab1d221ca2f1cca241110e3a61040e97eb1`，commit subject 为 `v4.44: 航母HOLD警戒翼队分配反馈`。
- diff reviewer 子 agent 返回 `No issues`，确认本轮只改 `issueHoldPositionOrder` 的视觉反馈，未发现 `assignCarrierGuardWing`、`guardAnchorCarrierID`、目标搜索、AI、迷雾、战斗或目标逻辑被误改；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `76d7eab1d221ca2f1cca241110e3a61040e97eb1`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28806217987`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.44-main-76d7eab1d221-run28806217987-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28806217987/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=76d7eab1d221ca2f1cca241110e3a61040e97eb1`、`runId=28806217987`、`runAttempt=1`、`version=v4.44`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Carrier HOLD 成功绑定时 `CV GUARD` cue 的位置与可读性、多个 Carrier 同时 HOLD 时 cue 是否可辨认、无可绑定 HEL/JET 时不会显示 guard cue、重新 HOLD 已绑定翼队时 cue 是否符合操作预期。
- 后续可继续在 guard wing 可读性基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统或 AI 航母使用，但这些不属于 v4.44。

### v4.45 / 航母警戒翼队飞机状态提示

日期：2026-07-07

核心变更：

- 单选已被有效 Carrier guard anchor 绑定的玩家 Helicopter / Fighter 时，选择面板状态行显示 `CV GUARD Dn  Guard ...`，用只读方式展示其到 anchor Carrier 的近似距离。
- 多选这些已绑定 HEL/JET 且未选中 HOLD Carrier 时，HOLD 行显示紧凑 `CV GUARD n Dm` 摘要，`n` 统计当前选中且 anchor 有效的 guard aircraft，`D` 使用最近 anchor 距离。
- 多选含 HOLD Carrier 时，仍优先显示既有 `CV GW x/y OK/Need Cn Eng n` Carrier 聚合摘要，不被飞机自身摘要覆盖。
- 新增 `carrierGuardWingStatusLine(for:)` 和 `groupSelectedCarrierGuardWingSummary(for:)`，二者都复用 `carrierGuardAnchor(for:)` 判断 anchor 是否仍有效；anchor 无效时保守回落既有普通 HOLD 文案，不清理字段、不显示误导性 lost 状态。
- 本轮没有改变 `assignCarrierGuardWing(for:)`、`clearCarrierGuardAnchor(for:)`、`updateCarrierGuardStation(for:)`、`carrierGuardStationPoint(...)`、`isCarrierGuardContact(...)`、`carrierGuardPriorityTarget(for:)`、combat、AI、迷雾、潜艇侦测、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.45 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.45（航母警戒翼队飞机状态提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.45 实现提示词；Agent X 并行只读 scout 确认最小安全入口是 `mobileStatusLine(for:)` 和 `groupSelectionInfo(for:)`，并复用 `carrierGuardAnchor(for:)`。
- Agent B 实现提交并推送：`d35d721a47c1ab6364cc2290f4d41be76384b196`，commit subject 为 `v4.45: 航母警戒翼队飞机状态提示`。
- diff reviewer 子 agent 返回 `No issues`，确认本轮只改选择面板 HUD 文案和文档，未发现 HOLD / AMOV / Carrier / Mechanic / Submarine 文案优先级、guard anchor、combat 或文档范围问题；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `d35d721a47c1ab6364cc2290f4d41be76384b196`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28807423249`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.45-main-d35d721a47c1-run28807423249-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28807423249/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=d35d721a47c1ab6364cc2290f4d41be76384b196`、`runId=28807423249`、`runAttempt=1`、`version=v4.45`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：单选已绑定 HEL/JET 时 `CV GUARD Dn` 的可读性、多选纯 guard aircraft 时 `CV GUARD n Dm` 的宽度、多选含 HOLD Carrier 时仍显示 `CV GW ...`、移动 / AMOV / 直接攻击 / 普通 HOLD 后飞机状态是否回落既有文案。
- 后续可继续在 guard wing 可读性基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统或 AI 航母使用，但这些不属于 v4.45。

### v4.46 / 航母警戒翼队锚点范围圈

日期：2026-07-07

核心变更：

- 选中已被有效 Carrier guard anchor 绑定的玩家 Helicopter / Fighter 时，会在其 anchor Carrier 上显示只读 guard anchor 范围圈。
- 多选多个已绑定 HEL/JET 时，所有有效 anchor Carrier 都显示范围圈；未绑定飞机、敌方飞机、失效 anchor 或非 HOLD Carrier 不显示额外范围圈。
- 新范围圈挂在 Carrier 实体节点下，半径使用 `carrierGuardThreatRadius`，避免复用 `highValueNavalEscortRadius` 的护航半径造成语义混淆。
- 新增 `carrierGuardAnchorCoverageNode`、`configureCarrierGuardAnchorCoverageNode(for:)` 和 `shouldShowCarrierGuardAnchorCoverage(for:)`，显隐仍由 `refreshSelection()` 统一驱动，并复用 `carrierGuardAnchor(for:)` 判断 anchor 是否有效。
- 现有 sonar / escort / repair coverage、Carrier / Battleship escort ring、`CV GUARD Dn` HUD 行、Carrier `GW ... Cn ... Tgt ... Eng n`、多选 `CV GW ...` 摘要保持原语义。
- 本轮没有改变 `assignCarrierGuardWing(for:)`、`clearCarrierGuardAnchor(for:)`、`updateCarrierGuardStation(for:)`、`carrierGuardAnchor(for:)`、`isCarrierGuardContact(...)`、`carrierGuardPriorityTarget(for:)`、combat、AI、迷雾、潜艇侦测、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.46 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.46（航母警戒翼队锚点范围圈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.46 实现提示词；Agent X 并行只读 scout 确认最小安全入口是现有 selection-derived coverage visual 链路，推荐使用独立 guard anchor 范围圈并复用 `carrierGuardAnchor(for:)`。
- Agent B 实现提交并推送：`75577319e7646b8d10914d6fd59276fc7fd4850a`，commit subject 为 `v4.46: 航母警戒翼队锚点范围圈`。
- diff reviewer 子 agent 返回 `No issues`，确认本轮新增 coverage node / 显隐逻辑不破坏 sonar / escort / repair coverage、selection、guard anchor、combat、AI、fog，文档未夸大为 CAP / 巡逻 / 截击；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `75577319e7646b8d10914d6fd59276fc7fd4850a`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28808841103`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.46-main-75577319e764-run28808841103-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28808841103/`，缓存目录大小 `116K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=75577319e7646b8d10914d6fd59276fc7fd4850a`、`runId=28808841103`、`runAttempt=1`、`version=v4.46`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：单选 bound HEL/JET 时 anchor Carrier 范围圈的颜色和半径可读性、多选多个 guard aircraft 时多个 anchor Carrier 是否同时显示、未绑定 / anchor 失效飞机不会显示、与 Carrier / Battleship escort ring 同屏时是否容易区分。
- 后续可继续在 guard wing 可读性基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统或 AI 航母使用，但这些不属于 v4.46。


### v4.47 / 选中航母显示警戒锚点范围圈

日期：2026-07-06

核心变更：

- 玩家选中正在 HOLD 且拥有至少一个有效绑定 HEL/JET guard wing 的 Carrier 时，会在该 Carrier 上显示基于 `carrierGuardThreatRadius` 的只读 guard anchor 范围圈。
- v4.46 的“选中 bound HEL/JET 时在 anchor Carrier 上显示 guard anchor 范围圈”路径保持不变；同选 Carrier 与 bound aircraft 时仍复用同一个 Carrier 节点上的同一个范围圈。
- 没有绑定翼队的 HOLD Carrier、非 HOLD Carrier、敌方 Carrier、死亡 Carrier、未绑定或 anchor 无效的 HEL/JET 不会触发额外 guard anchor 范围圈。
- 现有 Carrier / Battleship escort ring、sonar ring、repair ring、`CV GUARD Dn` HUD 行、Carrier `GW ... Cn ... Tgt ... Eng n` 和多选 `CV GW ...` 摘要保持原语义。
- 本轮没有改变 `assignCarrierGuardWing(for:)`、`clearCarrierGuardAnchor(for:)`、`updateCarrierGuardStation(for:)`、`carrierGuardAnchor(for:)`、`isCarrierGuardContact(...)`、`carrierGuardPriorityTarget(for:)`、combat、AI、迷雾、潜艇侦测、生产、支援、任务或胜负。
- README、flow、flowchart 和 v4.47 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.47（选中航母显示警戒锚点范围圈）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`29310c72e3a6ddab8dc4bb3e507af8a338b4c294`，commit subject 为 `v4.47: 选中航母显示警戒锚点范围圈`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `29310c72e3a6ddab8dc4bb3e507af8a338b4c294`；`gh` 当前认证账号为 `Altman-sam114`；`git diff --check 29310c72e3a6ddab8dc4bb3e507af8a338b4c294^ 29310c72e3a6ddab8dc4bb3e507af8a338b4c294` 通过。
- GitHub Actions：run `28811684483`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.47-main-29310c72e3a6-run28811684483-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28811684483/`，缓存目录大小 `132K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=29310c72e3a6ddab8dc4bb3e507af8a338b4c294`、`runId=28811684483`、`runAttempt=1`、`version=v4.47`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：单选 HOLD Carrier 且有绑定翼队时 guard anchor 范围圈是否可读、多选多个 HOLD Carrier 时多个范围圈是否同时显示、HOLD Carrier 无绑定翼队时不显示额外范围圈、与高价值海军 escort ring 同屏时是否容易区分。
- 后续可继续在 guard wing 可读性基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统或 AI 航母使用，但这些不属于 v4.47。


### v4.48 / AI 航母警戒翼队

日期：2026-07-06

核心变更：

- Red AI 指挥周期现在会让空闲 operational Carrier 绑定附近空闲 Red Helicopter / Fighter 作为 guard wing，最多补齐 2 架。
- AI guard wing 复用现有 `holdPosition`、`guardAnchorCarrierID`、`updateCarrierGuardStation(for:)`、`carrierGuardPriorityTarget(for:)` 和 `isCarrierGuardContact(...)` 链路；Red wing 仍只会处理 Red 已知且自身可攻击的 Carrier 近域目标。
- 正在 attack-move、已有 target、正在普通移动、占点 reservation 或撤退中的 Red HEL/JET 不会被抢去当 guard wing；已被本周期其他 Carrier 使用的 wing 也不会重复分配。
- 后续 routine attack-move wave 仍可通过既有 `issueFormationMove(...)` 接管 Carrier / wing；本轮没有新增 CAP、巡逻、截击状态机、玩家按钮或 AI 作弊侦察。
- 玩家 Carrier HOLD、HUD、selection ring、`CV GUARD` 文案、护航摘要、生产、支援、迷雾、潜艇侦测和胜负逻辑保持原语义。
- README、flow、flowchart 和 v4.48 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.48（AI航母警戒翼队）.md`
- `update_log.md`

验证结果：

- Agent B 本地轻量检查：`git diff --check` 通过；`git diff --cached --check` 通过。
- Agent B 实现提交并推送：`ce5b46ed16bb679bfe6cb99b8170088b2958f98e`，commit subject 为 `v4.48: AI航母警戒翼队`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `ce5b46ed16bb679bfe6cb99b8170088b2958f98e`；`git diff --check ce5b46ed16bb679bfe6cb99b8170088b2958f98e^ ce5b46ed16bb679bfe6cb99b8170088b2958f98e` 通过。
- GitHub Actions：run `28812163374`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.48-main-ce5b46ed16bb-run28812163374-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28812163374/`，缓存目录大小 `132K`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=ce5b46ed16bb679bfe6cb99b8170088b2958f98e`、`runId=28812163374`、`runAttempt=1`、`version=v4.48`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器或真机交互检查；最低验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Red Carrier 空闲时是否稳定绑定附近 HEL/JET、正在移动 / attack-move / retreat 的空军不被抢走、routine attack-move 是否仍能接管 Carrier 与 wing、隐藏玩家目标不会被 guard wing 泄露或攻击。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或 Sonar Buoy 升级，但这些不属于 v4.48。


### v4.49 / 航母警戒翼队组成提示

日期：2026-07-07

核心变更：

- 单选 HOLD Carrier 时，既有 `GW` 行会在 readiness 后、`C...` 接触信息前追加当前绑定 guard wing 的 HEL/JET 组成，例如 `H1 J1`、`H2` 或 `J2`。
- 多选 HOLD Carrier 时，既有 `CV GW` 摘要会用同一口径聚合显示绑定 guard wing 组成，例如 `CV GW 3/4 Need 1 H2 J1 C2 Eng 1`。
- 组成统计只复用 `boundCarrierGuardWing(for:)` 返回的有效绑定翼队，不把附近但未绑定的 Helicopter / Fighter 计入。
- 0 数量类型会省略，空 guard wing 不追加组成，避免 HUD 文案无意义变长。
- `C` 接触数、Air / Sea / Sub / Ground / Mix 类型、`Tgt XXX`、`Eng n`、`CV GUARD` 飞机状态、anchor 范围圈、玩家 Carrier HOLD、Red AI guard wing、移动、战斗、迷雾、潜艇侦测、生产、支援、任务和胜负逻辑保持原语义。
- README、flow、flowchart 和 v4.49 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.49（航母警戒翼队组成提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.49 实现提示词；Agent X 复用并行只读 scout 结论，确认只读 HUD 组成提示是低风险小目标。
- Agent B 实现提交并推送：`a8f9a1aeb47930acb5b20aece742bc08fc9312f1`，commit subject 为 `v4.49: 航母警戒翼队组成提示`。
- diff reviewer 子 agent 返回 `No issues`，确认本轮只在 Carrier HOLD 的 `GW` / 多选 `CV GW` HUD 行追加 `Hn/Jn` 组成，复用 `boundCarrierGuardWing(for:)` 口径，未触碰 contact、`Eng`、AI、战斗或迷雾逻辑；该 reviewer 未运行本地测试、构建、静态检查或 `git diff --check`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `a8f9a1aeb47930acb5b20aece742bc08fc9312f1`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28838248006`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.49-main-a8f9a1aeb479-run28838248006-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28838248006/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=a8f9a1aeb47930acb5b20aece742bc08fc9312f1`、`runId=28838248006`、`runAttempt=1`、`version=v4.49`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：单选 HOLD Carrier 的 `GW ... Hn/Jn ...` 宽度、多选 HOLD Carrier 的 `CV GW ... Hn/Jn ...` 宽度、空 wing 不显示组成、隐藏或未绑定 HEL/JET 不会进入组成统计。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或 Sonar Buoy 升级，但这些不属于 v4.49。


### v4.50 / 航母警戒翼队脱离反馈

日期：2026-07-07

核心变更：

- 玩家对已被有效 Carrier guard anchor 绑定的 Helicopter / Fighter 成功下达普通移动、AMOV、直接攻击或 ordinary HOLD 时，原成功消息会追加 `CV guard released n.` 短反馈。
- 普通移动和 AMOV 在 `issueFormationMove(...)` 清理 guard anchor 前统计 release 数，并只在 `showFeedback == true` 的玩家命令路径显示消息；Red AI routine wave 的 `showFeedback=false` 路径不会外显。
- 直接攻击只统计本次实际 `canAttack` 且会被赋予 `attackTarget` 的玩家单位，避免混编选择中不能攻击目标的 bound wing 被误报。
- ordinary HOLD 会在清理前记录有效 bound wing，执行可能的 Carrier guard 重新绑定后再按最终有效 anchor 统计 release，避免同次 Carrier HOLD 重绑定误报。
- `clearCarrierGuardAnchor(for:)` 仍只清理字段，不显示消息；内部 anchor 失效维护、AI guard wing、routine wave、combat、迷雾、潜艇侦测、生产、支援、任务和胜负逻辑保持原语义。
- README、flow、flowchart 和 v4.50 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.50（航母警戒翼队脱离反馈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.50 实现提示词；Agent X 并行只读 scout 确认该目标适合做小增量，并指出必须避免在 `clearCarrierGuardAnchor(for:)` 内产生 UI 副作用。
- Agent B 实现提交并推送：`32d3ac42c8f12bca1a5640fe5e9bdface567b568`，commit subject 为 `v4.50: 航母警戒翼队脱离反馈`。
- scout 复核当前实现方向正确：普通移动 / AMOV 只在 `showFeedback=true` 时外显、直接攻击只统计 attackers、ordinary HOLD 重绑定后再统计最终 release，Red AI routine wave 不外显；该 scout 未运行本地测试、构建、静态检查或联网。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `32d3ac42c8f12bca1a5640fe5e9bdface567b568`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28838998545`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.50-main-32d3ac42c8f1-run28838998545-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28838998545/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=32d3ac42c8f12bca1a5640fe5e9bdface567b568`、`runId=28838998545`、`runAttempt=1`、`version=v4.50`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：移动 / AMOV / 直接攻击 / ordinary HOLD 的 release 消息是否可读，Carrier + wing 同次 HOLD 重绑定时不误报，AI wave 和内部 anchor 失效清理不会产生玩家消息。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或未 HOLD Carrier 的 `Wing Hn/Jn` 组成提示，但这些不属于 v4.50。


### v4.51 / 航母翼队组成提示

日期：2026-07-07

核心变更：

- 单选未 HOLD Carrier 时，既有 `Wing` readiness 行会追加附近 HEL/JET 组成，例如 `Wing 2/2 OK H1 J1`、`Wing 1/2 Need 1 H1` 或 `Wing 2/2 OK J2`。
- 组成统计复用 `nearbyCarrierAirWing(for:)` 口径，只统计同阵营、存活、operational、非结构、位于 `highValueNavalEscortRadius` 内的 Helicopter / Fighter。
- 空翼队不追加 `H0` 或 `J0`，0 数量类型仍省略，避免 HUD 文案无意义变长。
- v4.49 的 HOLD Carrier `GW ... Hn/Jn ...` 和多选 `CV GW ... Hn/Jn ...` 语义保持不变，只把 composition helper 泛化为 `carrierAirWingCompositionSuffix(for:)`。
- Guard anchor、Carrier HOLD、Red AI guard wing、`CV guard released n.` 反馈、combat、迷雾、潜艇侦测、生产、支援、任务和胜负逻辑保持原语义。
- README、flow、flowchart 和 v4.51 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.51（航母翼队组成提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.51 实现提示词；Agent X 基于 v4.50 遗留建议和当前代码确认未 HOLD Carrier `Wing` 行尚无组成提示。
- Agent B 实现提交并推送：`800109cdd66b681c091e61d52cae9b34256c6f5c`，commit subject 为 `v4.51: 航母翼队组成提示`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `800109cdd66b681c091e61d52cae9b34256c6f5c`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28839427071`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.51-main-800109cdd66b-run28839427071-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28839427071/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`ci-run.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=800109cdd66b681c091e61d52cae9b34256c6f5c`、`runId=28839427071`、`runAttempt=1`、`version=v4.51`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：未 HOLD Carrier 的 `Wing ... Hn/Jn` 宽度、附近空翼队进出范围时组成是否刷新、空翼队不显示组成、HOLD Carrier 的 `GW` / 多选 `CV GW` 组成和接触信息不回退。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或多选 bound guard aircraft 的 `CV GUARD Hn/Jn` 摘要，但这些不属于 v4.51。


### v4.52 / 航母警戒翼队多选组成提示

日期：2026-07-07

核心变更：

- 多选已被有效 Carrier guard anchor 绑定的玩家 Helicopter / Fighter，且未选中 HOLD Carrier 时，HOLD 行摘要从 `CV GUARD n Dm` 扩展为 `CV GUARD n Hn/Jn Dm`。
- 组成统计复用 `carrierAirWingCompositionSuffix(for:)` 口径，只统计当前选中且 `carrierGuardAnchor(for:)` 仍有效的玩家 HEL/JET；未选中、敌方、非 HEL/JET、anchor 失效或未绑定的飞机不会计入。
- 单一类型时只显示存在的类型，例如 `CV GUARD 2 H2 D140` 或 `CV GUARD 1 J1 D95`；混合翼队显示如 `CV GUARD 2 H1 J1 D180`。
- 多选 HOLD Carrier 时仍优先显示 `CV GW x/y OK/Need Hn/Jn Cn Eng n`，不会被 bound HEL/JET 自身摘要覆盖。
- Guard anchor、Carrier HOLD、Red AI guard wing、`CV guard released n.` 反馈、combat、迷雾、潜艇侦测、生产、支援、任务和胜负逻辑保持原语义。
- README、flow、flowchart 和 v4.52 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.52（航母警戒翼队多选组成提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.52 实现提示词；Agent X 基于 v4.51 遗留建议选定多选 bound guard aircraft 组成提示作为低风险 HUD-only 小目标。
- 并行只读 explorer 子 agent 复核确认：只改 `groupSelectedCarrierGuardWingSummary(for:)` 字符串组装并复用 `carrierAirWingCompositionSuffix(for:)` 是安全范围；不得改变 `groupSelectionInfo` 优先级、guard 绑定/释放、目标选择、迷雾、AI、生产或战斗逻辑。该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`8d9c0349bbdb27f4e4aa8035c1e823e297542a7a`，commit subject 为 `v4.52: 航母警戒翼队多选组成提示`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `8d9c0349bbdb27f4e4aa8035c1e823e297542a7a`；`gh` 当前认证账号为 `Altman-sam114`。
- GitHub Actions：run `28840037641`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.52-main-8d9c0349bbdb-run28840037641-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28840037641/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=8d9c0349bbdb27f4e4aa8035c1e823e297542a7a`、`runId=28840037641`、`runAttempt=1`、`version=v4.52`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：多选 bound HEL/JET 的 `CV GUARD ... Hn/Jn ...` 宽度、混合 / 单一类型显示、未绑定或 anchor 失效飞机不计入、多选 HOLD Carrier 仍显示 `CV GW ...` 优先摘要。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或海军科技层，但这些不属于 v4.52。


### v4.53 / 航母警戒翼队分配组成反馈

日期：2026-07-07

核心变更：

- 玩家对包含 Carrier 的选择下达 `HOLD` 且实际绑定 guard wing 时，顶部成功消息从只显示 `Guard wing n.` 扩展为 `Guard wing n Hn/Jn.`。
- 每艘本次 HOLD 后拥有 bound guard wing 的玩家 Carrier，甲板短 cue 从泛化 `CV GUARD` 改为该 Carrier 自身组成的 `GW Hn/Jn`，例如 `GW H1 J1`、`GW H2` 或 `GW J1`。
- 组成统计复用 `carrierAirWingCompositionSuffix(for:)` 和 `boundCarrierGuardWing(for:)` 口径，0 数量类型省略，不另写 HEL/JET 统计逻辑。
- 没有可绑定 HEL/JET 时不显示 guard wing 组成或 deck cue；多 Carrier 同时 HOLD 时顶部组成按去重 bound wing 聚合，deck cue 按每艘 Carrier 自身 bound wing 显示。
- `assignCarrierGuardWing(for:)` 的绑定条件、去重逻辑和返回数量保持不变；guard anchor、Carrier HOLD、Red AI guard wing、`CV guard released n.` 反馈、combat、迷雾、潜艇侦测、生产、支援、任务和胜负逻辑保持原语义。
- README、flow、flowchart 和 v4.53 Agent A 提示词已同步当前真实行为，未宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.53（航母警戒翼队分配组成反馈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.53 实现提示词；Agent X 基于 v4.52 后的当前代码选定 Carrier HOLD 分配反馈组成提示作为低风险操作反馈小目标。
- 并行只读 explorer 子 agent 复核确认：该目标适合作为小步增量，推荐在 `issueHoldPositionOrder(units:)` 中复用 `boundCarrierGuardWing(for:)` 和 `carrierAirWingCompositionSuffix(for:)`，不得改变 `assignCarrierGuardWing` 绑定条件、AI、release 反馈、选择状态、guard ring、威胁优先、迷雾或 HOLD 回位逻辑。该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`f4e56097ad4b1192c39826936741e67242420f64`，commit subject 为 `v4.53: 航母警戒翼队分配组成反馈`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `f4e56097ad4b1192c39826936741e67242420f64`。
- GitHub Actions：run `28840639326`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.53-main-f4e56097ad4b-run28840639326-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28840639326/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=f4e56097ad4b1192c39826936741e67242420f64`、`runId=28840639326`、`runAttempt=1`、`version=v4.53`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Carrier HOLD 成功消息的 `Guard wing n Hn/Jn` 宽度、每艘 Carrier 的 `GW Hn/Jn` deck cue 可读性、多 Carrier 同时 HOLD 时 cue 是否可接受、无可绑定 wing 时不显示误导 cue。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或海军科技层，但这些不属于 v4.53。

### v4.54 / 航母警戒翼队规模口径统一

日期：2026-07-07

核心变更：

- 新增 `carrierGuardWingRequirement = 2` 作为 Carrier guard wing 的统一规模口径。
- 玩家 Carrier 下达 `HOLD` 时，每艘 Carrier 只从现有 `nearbyCarrierAirWing(for:)` 候选中绑定最近的最多 2 架 Helicopter / Fighter，并继续用 `assignedWingIDs` 避免同一架 wing 被多艘 Carrier 重复分配。
- 候选排序按距 Carrier 近到远，等距时按 entity id 固定 tie-breaker，避免等距分配结果不稳定。
- 单选 Carrier `Wing x/2` / `GW x/2`、多选 HOLD Carrier `CV GW x/y` 需求合计、Red AI 空闲 Carrier 自动补 wing 的 `missing` 均复用同一 2 架口径。
- 不改变 `nearbyCarrierAirWing(for:)` 的候选资格、guard anchor、station keeping、target priority、combat、fog、潜艇侦测、生产、支援、任务、胜负或 SKRM 重置语义。
- README、flow、flowchart 和 v4.54 Agent A 提示词已同步当前真实行为，未新增或宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.54（航母警戒翼队规模口径统一）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.54 实现提示词；Agent X 基于 v4.53 后的当前代码选定玩家 Carrier HOLD 绑定规模和 HUD / Red AI 口径一致性作为低风险小目标。
- 并行只读 explorer 子 agent 复核确认：该目标适合作为小步玩法增量，推荐统一常量、玩家每 Carrier 最近最多 2 架、保留 `assignedWingIDs`，并建议排序加入 id tie-breaker；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`ff8e311e36a43520ec5d7fcabcf05196692db5bc`，commit subject 为 `v4.54: 航母警戒翼队规模口径统一`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `ff8e311e36a43520ec5d7fcabcf05196692db5bc`。
- GitHub Actions：run `28841188673`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.54-main-ff8e311e36a4-run28841188673-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28841188673/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=ff8e311e36a43520ec5d7fcabcf05196692db5bc`、`runId=28841188673`、`runAttempt=1`、`version=v4.54`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：一艘 Carrier 附近超过 2 架 HEL/JET 时只绑定最近 2 架、多艘 Carrier 同时 HOLD 时 wing 不重复归属、额外飞机未被误报为 `CV GUARD`。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或海军科技层，但这些不属于 v4.54。

### v4.55 / 航母警戒翼队脱离组成反馈

日期：2026-07-07

核心变更：

- 玩家移动、AMOV、直接攻击或 ordinary HOLD 让有效 bound Carrier guard HEL/JET 脱离 anchor 时，顶部成功消息从 `CV guard released n.` 扩展为 `CV guard released n Hn/Jn.`。
- 新增 `carrierGuardReleaseWing(for:)` 作为 release feedback 的统一只读 wing 列表口径，并让 `carrierGuardReleaseSuffix(for:)` 复用现有 `carrierAirWingCompositionSuffix(for:)` 生成 HEL/JET 组成。
- 直接攻击、普通移动和 AMOV 都在清理 anchor 前保存本次会释放的 bound wing 列表，再复用同一 suffix 输出消息。
- ordinary HOLD 继续先记录旧 bound wing id，执行 HOLD 和可能的 Carrier 重新绑定后，再只统计最终已经脱离 anchor 的 wing 及组成，保持“同次重新绑定不误报 released”的语义。
- 不改变 `clearCarrierGuardAnchor(for:)`、`assignCarrierGuardWing(for:)`、`boundCarrierGuardWing(for:)`、候选资格、guard anchor、station keeping、target priority、combat、fog、潜艇侦测、AI、生产、支援、任务、胜负或 SKRM 重置语义。
- README、flow 和 v4.55 Agent A 提示词已同步当前真实行为，未新增或宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.55（航母警戒翼队脱离组成反馈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.55 实现提示词；Agent X 基于 v4.54 后的当前代码选定 Carrier guard wing release feedback 组成补齐作为低风险小目标。
- 并行只读 explorer 子 agent 复核确认：该目标合理，推荐只在 `carrierGuardReleaseSuffix(for:)` 复用组成 helper，并避免改变 release 候选、ordinary HOLD 统计时机、AI、combat、fog、selection ring、HOLD 绑定和 guard contact；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`f3ce1920e5679b4dc1bdc2bc64fcb8a2dec559ca`，commit subject 为 `v4.55: 航母警戒翼队脱离组成反馈`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `f3ce1920e5679b4dc1bdc2bc64fcb8a2dec559ca`。
- GitHub Actions：run `28841685944`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.55-main-f3ce1920e567-run28841685944-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28841685944/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=f3ce1920e5679b4dc1bdc2bc64fcb8a2dec559ca`、`runId=28841685944`、`runAttempt=1`、`version=v4.55`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：移动、AMOV、直接攻击和 ordinary HOLD 四条释放路径的顶部消息是否都显示 `CV guard released n Hn/Jn.`，以及同次 Carrier HOLD 重新绑定时不会误报 release。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或海军科技层，但这些不属于 v4.55。

### v4.56 / 航母 HOLD 警戒范围空翼可见

日期：2026-07-07

核心变更：

- 玩家选中己方存活 HOLD Carrier 时，即使当前没有 bound HEL/JET guard wing，也会显示该 Carrier 自身基于 `carrierGuardThreatRadius` 的 guard anchor 范围圈。
- 选中有效 bound Carrier guard HEL/JET 时，仍继续在 anchor Carrier 上显示同一个 guard anchor 范围圈。
- 实现只移除 `shouldShowCarrierGuardAnchorCoverage(for:)` 中选中 Carrier 自身分支对 `boundCarrierGuardWing(for:)` 非空的要求；未改范围圈颜色、半径、zPosition 或 node 配置。
- `boundCarrierGuardWing(for:)` 仍只用于真实绑定统计和 HUD `GW` 口径；HOLD Carrier 没有 wing 时仍显示 `GW 0/2 Need 2` 等真实状态，不被范围圈视觉误改。
- 不改变 Carrier HOLD 绑定 HEL/JET 的条件、数量、排序、guard anchor 写入、station keeping、target priority、combat、fog、潜艇侦测、AI、生产、支援、任务、胜负或 SKRM 重置语义。
- README、flow、flowchart 和 v4.56 Agent A 提示词已同步当前真实行为，未新增或宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.56（航母HOLD警戒范围空翼可见）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.56 实现提示词；Agent X 基于 v4.55 后的当前代码选定 HOLD Carrier 空翼状态下 guard anchor 范围可见性作为低风险 visual-only 小目标。
- 并行只读 explorer 子 agent 复核确认：该目标合理，推荐只移除 `!boundCarrierGuardWing(for: entity).isEmpty`，保留 bound HEL/JET 显示 anchor ring 的现有分支，并避免改变 HUD 绑定统计、迷雾、目标合法性、contact 统计、AI、站位或攻击优先级；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`e79b6e7518d1fc12b48159c5613229d78ead6bcc`，commit subject 为 `v4.56: 航母HOLD警戒范围空翼可见`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `e79b6e7518d1fc12b48159c5613229d78ead6bcc`。
- GitHub Actions：run `28842142026`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.56-main-e79b6e7518d1-run28842142026-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28842142026/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=e79b6e7518d1fc12b48159c5613229d78ead6bcc`、`runId=28842142026`、`runAttempt=1`、`version=v4.56`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：HOLD Carrier 无 bound wing 时选中是否显示 guard anchor 范围圈、未 HOLD Carrier 是否仍不显示该圈、bound HEL/JET 选中时 anchor ring 是否保持。
- 后续可继续在 guard wing 基础上设计更明确的舰载机命令 UI、CAP / 巡逻 / 截击系统、AI 航母进攻节奏或海军科技层，但这些不属于 v4.56。

### v4.57 / AI 航母警戒翼队保留护航

日期：2026-07-07

核心变更：

- Red routine attack-move 波次在构造普通 idle assault candidates 时，会排除当前仍有有效 Carrier anchor 的 Red Helicopter / Fighter。
- 新增 `isEnemyCarrierGuardWingReservedForAnchor(_:)` 作为 AI routine wave 候选过滤 helper，只命中 Red HEL/JET 且 `carrierGuardAnchor(for:) != nil` 的有效绑定翼队。
- 已绑定 Red Carrier guard wing 的 HEL/JET 会继续走现有 Carrier HOLD anchor、station keeping 和近域已知威胁优先链路，不会在同一指挥周期被 ordinary routine assault wave 立即通过 `issueFormationMove(... attackMove: true)` 抽走。
- 未绑定 Red HEL/JET、Red Carrier、Battleship 和其他作战单位仍按原 routine wave、低血撤退、Veteran / Elite 保护和高价值海军 escort 门槛参与 AI 行为。
- README、flow 和 v4.57 Agent A 提示词已同步当前真实行为，未新增或宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.57（AI航母警戒翼队保留护航）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.57 实现提示词；Agent X 基于 v4.56 后的当前代码选定 Red AI routine wave 保留已绑定 Carrier guard wing 作为低风险 AI 稳定性小目标。
- 并行只读 explorer 子 agent 复核确认：当前修复已经放在 `commandEnemyAttackers(_:)` 的 routine wave 入口过滤，避免修改 `issueFormationMove(...)` 的通用释放语义；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`fb90cc3ca8019479e07cf2fac882a4b66c1e406d`，commit subject 为 `v4.57: AI航母警戒翼队保留护航`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `fb90cc3ca8019479e07cf2fac882a4b66c1e406d`。
- GitHub Actions：run `28842809505`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.57-main-fb90cc3ca801-run28842809505-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28842809505/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=fb90cc3ca8019479e07cf2fac882a4b66c1e406d`、`runId=28842809505`、`runAttempt=1`、`version=v4.57`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Red Carrier 绑定 guard wing 后普通进攻波不再马上抽走 HEL/JET、未绑定 Red 空军仍能加入进攻波、玩家命令释放 guard wing 的语义不变。
- 后续可继续单独设计 Carrier battle group，让 Carrier 真正出击时按明确规则携带 escort / wing；这不属于 v4.57。

### v4.58 / AI 航母战斗群携带警戒翼队

日期：2026-07-07

核心变更：

- Red Carrier 进入 routine provisional assault wave 时，会把该 Carrier 当前有效、空闲、同 anchor 的 bound HEL/JET guard wing 追加到本轮 assault candidates。
- 追加的 bound wing 会先排除本轮应撤退的低血飞机；如果 anchor Carrier 本轮被低血撤退移出候选，该 wing 也不会参与 escort 计算或最终出击。
- `enemyAssaultWaveKeepingCarrierGuardAnchors(_:)` 确保 bound wing 只有在 anchor Carrier 也保留于 accepted wave 时才会随同进入最终 `issueFormationMove(... attackMove: true)`。
- 已绑定 Red Carrier guard wing 平时仍不会作为 ordinary idle assault candidate 被 routine wave 抽走；只有 anchor Carrier 自身被接受出击时，才随同形成小型 battle group。
- 不改变玩家 Carrier guard wing、玩家命令释放语义、HUD、范围圈、释放反馈、潜艇侦测、迷雾、生产、支援、任务、胜负或 SKRM 重置语义。
- README、flow 和 v4.58 Agent A 提示词已同步当前真实行为，未新增或宣称完整 CAP / 巡逻 / 截击能力。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.58（AI航母战斗群携带警戒翼队）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.58 实现提示词；Agent X 基于 v4.57 后的当前代码选定 Red Carrier 入波时携带自身 bound guard wing 作为低风险 AI battle group 小目标。
- 并行只读 explorer 子 agent 复核确认：当前代码不支持 Carrier 同波次带上 bound wing；推荐在 `commandEnemyAttackers(_:)` 的 provisional wave 之后追加 Carrier 的 `boundCarrierGuardWing(for:)`，并防止 Carrier 被过滤后 wing 孤立出击。该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`c9678ded5511561e7b47deb68e7d541dae8d2bf8`，commit subject 为 `v4.58: AI航母战斗群携带警戒翼队`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `c9678ded5511561e7b47deb68e7d541dae8d2bf8`。
- GitHub Actions：run `28844236580`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.58-main-c9678ded5511-run28844236580-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28844236580/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=c9678ded5511561e7b47deb68e7d541dae8d2bf8`、`runId=28844236580`、`runAttempt=1`、`version=v4.58`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Red Carrier 被接受出击时 bound HEL/JET 是否随队 attack-move、Carrier 被低血撤退或护航门槛过滤时 bound wing 是否继续留在 guard anchor、未绑定 Red 空军仍能按常规角色加入波次。
- 后续可继续细化 Carrier battle group 的出击可读性、战斗群组成反馈或更完整的舰载机命令 UI；这些不属于 v4.58。

### v4.59 / AI 主攻波 HUD 摘要

日期：2026-07-07

核心变更：

- 新增 `lastEnemyAssaultWaveSummary`，记录最近一次玩家可感知的 Red routine assault wave 子集摘要。
- Red 主攻波成功下发后，先用 `isKnownToFaction(..., observer: .player)` 过滤出玩家已知的 wave 单位；只有该子集非空时才更新 HUD 摘要。
- HUD Red 状态行从长文本压缩为 `R# F# ...`，默认显示 `AI <difficulty>`；有可感知主攻波时显示 `Wave n Lx/Ax/Nx`，并在非零时追加 `CVc`、`Hh`、`Jj`。
- 摘要只统计玩家已知的 wave 子集，不显示目标坐标、隐藏单位位置、隐藏单位组成或额外侦察信息；完全不可知的 Red wave 不更新玩家可见摘要。
- `SKRM` 重开会清空 `lastEnemyAssaultWaveSummary`。
- 不改变 AI 进攻选择、Carrier guard wing battle group、低血撤退、escort 门槛、fog、combat、production、support、mission 或 victory 语义。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.59（AI主攻波HUD摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.59 实现提示词；Agent X 基于 v4.58 后的当前代码选定 Red 最近主攻波可感知 HUD 摘要作为低风险 AI 可读性小目标。
- 并行只读 explorer 子 agent 复核确认：推荐使用现有 `aiStatusLabel`，不使用顶部消息；必须避免泄露隐藏 Carrier / wing 组成。该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`eba1215aef31c501942563cc1715543869ea61ec`，commit subject 为 `v4.59: AI主攻波HUD摘要`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `eba1215aef31c501942563cc1715543869ea61ec`。
- GitHub Actions：run `28846430390`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.59-main-eba1215aef31-run28846430390-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28846430390/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=eba1215aef31c501942563cc1715543869ea61ec`、`runId=28846430390`、`runAttempt=1`、`version=v4.59`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：HUD 状态行在无可感知 wave 时显示 `R# F# AI ...`，有可感知 wave 后显示 `R# F# Wave ...` 且不溢出，隐藏 Red wave 不提前泄露组成，`SKRM` 重开后摘要清空。
- 后续可继续细化 AI wave 状态的持续时间、更多玩家可感知事件摘要或 Carrier battle group 可读性，但这些不属于 v4.59。

### v4.60 / AI 主攻波 HUD 摘要过期

日期：2026-07-07

核心变更：

- 新增 `lastEnemyAssaultWaveSummaryTime` 和 `enemyAssaultWaveSummaryDuration = 12`，让 Red 主攻波 HUD 摘要成为有时效的显示状态。
- `updateEnemyAssaultWaveSummary(for:)` 仍只在玩家已知 wave 子集非空时更新摘要，并同步刷新摘要时间戳。
- `updateHUD()` 通过 `currentEnemyAssaultWaveSummary()` 判断摘要是否仍有效；超过约 12 秒后恢复显示 `AI <difficulty>`。
- `SKRM` 重开会同时清空 `lastEnemyAssaultWaveSummary` 和时间戳。
- 不改变 AI 进攻选择、Carrier guard wing battle group、低血撤退、escort 门槛、fog、combat、production、support、mission 或 victory 语义。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.60（AI主攻波HUD摘要过期）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.60 实现提示词；Agent X 基于 v4.59 后的当前代码选定 Red 主攻波 HUD 摘要过期作为低风险 AI 可读性小目标。
- 并行只读 explorer 子 agent 复核确认：时间戳使用 `lastUpdateTime`，过期 helper 只影响 HUD 展示，不参与 AI 决策、战斗、移动或目标选择；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`2309520f91d199f635be05da27b7ebe3a2a4ecdd`，commit subject 为 `v4.60: AI主攻波HUD摘要过期`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `2309520f91d199f635be05da27b7ebe3a2a4ecdd`。
- GitHub Actions：run `28846987775`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.60-main-2309520f91d1-run28846987775-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28846987775/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=2309520f91d199f635be05da27b7ebe3a2a4ecdd`、`runId=28846987775`、`runAttempt=1`、`version=v4.60`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：HUD 状态行在可感知 wave 后短暂显示 `R# F# Wave ...`，约 12 秒后恢复 `R# F# AI ...`，新的可感知 wave 能刷新摘要，隐藏 Red wave 不提前泄露组成，`SKRM` 重开后摘要清空。
- 后续可继续细化更多玩家可感知战场事件摘要、AI 主攻节奏提示或 Carrier battle group 可读性，但这些不属于 v4.60。

### v4.61 / AI 航母战斗群携带站位翼队

日期：2026-07-07

核心变更：

- 新增 `canEnemyCarrierGuardWingJoinAssault(_:with:)`，作为 Red Carrier 入波携带自身 bound guard wing 的专用过滤 helper。
- 当 Red anchor Carrier 自身进入 routine provisional assault wave 时，同 anchor、有效、无 attack target、无 attack-move、未撤退且不应低血回修的 bound HEL/JET 可加入本轮 assault candidates，即使它们正在返回 guard station。
- `isAvailableEnemyCarrierGuardWing(_:)` 保持原样，Red Carrier 自动绑定候选和 ordinary idle 语义仍要求 wing 没有 destination。
- ordinary routine assault candidates 仍排除已绑定 Red Carrier guard wing；只有 anchor Carrier 自身入波时，站位中的 wing 才可随队。
- 不改变玩家 Carrier guard wing、玩家命令释放语义、AI 目标、escort 门槛、低血撤退、fog、combat、production、support、mission 或 victory 语义。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.61（AI航母战斗群携带站位翼队）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.61 实现提示词；Agent X 基于 v4.60 后的当前代码选定 Red Carrier battle group 携带站位中的 guard wing 作为窄范围 AI 航母行为补齐。
- 并行只读 explorer 子 agent 复核候选目标；另一只读 explorer 子 agent 复核最终 diff，确认新 helper 只放宽 `destination == nil` 条件，未影响 ordinary routine candidates、自动绑定候选、玩家 release、低血撤退、迷雾或战斗；这些子 agent 均未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`4d8b604beb2e21ddb04267ad5f676d8134530205`，commit subject 为 `v4.61: AI航母战斗群携带站位翼队`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `4d8b604beb2e21ddb04267ad5f676d8134530205`。
- GitHub Actions：run `28848767781`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.61-main-4d8b604beb2e-run28848767781-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28848767781/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=4d8b604beb2e21ddb04267ad5f676d8134530205`、`runId=28848767781`、`runAttempt=1`、`version=v4.61`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Red Carrier 被接受出击时，正在返回 guard station 的同 anchor HEL/JET 是否随队 attack-move；有 attack target、attack-move、低血应撤退或其他 anchor 的 wing 是否仍不会被携带；普通 bound guard wing 是否仍不会在 anchor Carrier 未出击时被 routine wave 单独抽走。
- 后续可继续细化 AI wave HUD 的“已感知子集”措辞、多选 HOLD Carrier 接触类型 / 目标摘要，或更完整的舰载机命令 UI；这些不属于 v4.61。

### v4.62 / 多选航母警戒接触目标摘要

日期：2026-07-07

核心变更：

- 多选玩家 HOLD Carrier 的 `CV GW` 摘要继续聚合 bound wing 数、需求、HEL/JET 组成、去重 `C` 和非零 `Eng`。
- `C` 非零时，多选 `CV GW` 摘要现在追加合法 guard contact 类型：`Air` / `Sea` / `Sub` / `Ground` / `Mix`。
- `C` 非零且存在优先接触时，多选 `CV GW` 摘要追加 `Tgt XXX`，优先规则沿用单选 Carrier 的 priority、anchor 距离和 entity id tie-breaker。
- `C0` 时仍只显示 `C0`，不追加类型或目标。
- 所有 contact 仍来自 `isCarrierGuardContact(...)`，只读复用已知、可攻击、Carrier 近域和 wing HOLD 警戒半径边界；不写入 `attackTarget`、迷雾集合、命令状态、AI 状态或战斗状态。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.62（多选航母警戒接触目标摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.62 实现提示词；Agent X 基于 v4.61 后的当前代码选定多选 HOLD Carrier guard contact 类型 / 目标摘要作为小范围 HUD 可读性增强。
- 只读 explorer 子 agent 复核候选目标与最终 diff，确认改动只在 `groupCarrierGuardWingSummary(for:)` 内新增 HUD 聚合字段和字符串拼接，仍走 `isCarrierGuardContact(...)`，未泄露隐藏单位，未改命令、战斗、AI 或迷雾；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`bc42082a8e79d5090570fdadc66684c42cd1f9a2`，commit subject 为 `v4.62: 多选航母警戒接触目标摘要`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `bc42082a8e79d5090570fdadc66684c42cd1f9a2`。
- GitHub Actions：run `28849514163`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.62-main-bc42082a8e79-run28849514163-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28849514163/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=bc42082a8e79d5090570fdadc66684c42cd1f9a2`、`runId=28849514163`、`runAttempt=1`、`version=v4.62`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：多选多个 HOLD Carrier 且存在已知合法 guard contacts 时，`CV GW` 是否追加类型和 `Tgt XXX`；`C0` 时是否仍保持紧凑；隐藏敌方是否不会通过该摘要泄露。
- 后续可继续微调 AI wave HUD 的“已感知子集”措辞、Carrier guard wing 命令 UI 或更完整的舰载机巡逻 / 截击能力；这些不属于 v4.62。

### v4.63 / AI 主攻波已感知摘要措辞

日期：2026-07-07

核心变更：

- Red routine assault wave 成功下发后，HUD Red 状态行的玩家可感知 wave 子集摘要首段从 `Wave n` 改为 `Seen n`。
- `Seen n` 仍只统计 `knownWave = wave.filter { isKnownToFaction($0, observer: .player) }` 的玩家已知子集数量，不表示完整 Red wave 总规模。
- 组成摘要仍保持 `Lx/Ax/Nx`，非零时追加 `CVc`、`Hh`、`Jj`。
- 12 秒过期、`SKRM` 清空、隐藏单位过滤、AI 选波、目标、护航门槛、低血撤退、Carrier guard wing、战斗、生产、支援、任务和胜负逻辑均未改变。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.63（AI主攻波已感知摘要措辞）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.63 实现提示词；Agent X 基于 v4.62 遗留事项选定 AI 主攻波 HUD “已感知子集”措辞作为小范围 HUD 可读性增量。
- 只读 explorer 子 agent 定位并确认：最小安全改动点是 `enemyAssaultWaveSummary(for:)` 中的字符串前缀；`wave.count` 实际来自已过滤的 `knownWave`，该 helper 只返回字符串，不影响 AI、战斗、移动、迷雾或感知状态；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`47dd836e0b30a077dc2f5417d7aa9973ab62c639`，commit subject 为 `v4.63: AI主攻波已感知摘要措辞`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `47dd836e0b30a077dc2f5417d7aa9973ab62c639`。
- GitHub Actions：run `28850163391`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.63-main-47dd836e0b30-run28850163391-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28850163391/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=47dd836e0b30a077dc2f5417d7aa9973ab62c639`、`runId=28850163391`、`runAttempt=1`、`version=v4.63`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：玩家看见 Red routine assault wave 子集时 HUD 是否显示 `R# F# Seen n Lx/Ax/Nx`，约 12 秒后是否恢复 `AI <difficulty>`，隐藏 Red wave 是否不会提前泄露数量或组成。
- 后续可继续细化 Carrier guard wing 命令 UI、更多玩家可感知战场事件摘要，或拆分更完整的舰载机巡逻 / 截击能力；这些不属于 v4.63。

### v4.64 / HOLD 按钮航母警戒提示

日期：2026-07-07

核心变更：

- `HOLD` 按钮 subtitle 不再固定只显示 `guard`，会根据当前玩家移动单位选择只读显示上下文提示。
- 当前选择包含玩家 Carrier 时，`HOLD` subtitle 显示 `CV GW`，提示本次 HOLD 会尝试让 Carrier 绑定附近 HEL/JET guard wing。
- 当前选择包含已绑定有效 Carrier guard anchor 的玩家 HEL/JET，且未选中 Carrier 时，`HOLD` subtitle 显示 `CV rel`，提示 ordinary HOLD 会释放旧 Carrier guard anchor。
- 其他选择仍显示 `guard`。
- 本轮只新增 `holdButtonSubtitle()` 并接入 `subtitle(for:)` 的 `.holdPosition` 分支；不改变 `issueHoldPositionOrder(...)`、`assignCarrierGuardWing(...)`、`clearCarrierGuardAnchor(...)`、`carrierGuardAnchor(...)`、AI、战斗、迷雾、生产、支援、任务或胜负逻辑。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.64（HOLD按钮航母警戒提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.64 实现提示词；Agent X 基于 v4.63 遗留事项选定 `HOLD` 按钮 Carrier guard wing subtitle 作为小范围命令 UI 可读性增量。
- 只读 explorer 子 agent 定位并确认：最小安全改动点是 `subtitle(for:)` 的 `.holdPosition` 分支和一个只读 helper；不得修改 HOLD 命令语义、Carrier guard anchor 写入 / 清理、AI guard wing、战斗或迷雾；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`b72b3f29771d3b08ef2d2d517d4f730209ccb0a5`，commit subject 为 `v4.64: HOLD按钮航母警戒提示`。
- Agent C 复核：本地 `main`、`origin/main`、`HEAD` 和 Actions run head SHA 均为 `b72b3f29771d3b08ef2d2d517d4f730209ccb0a5`。
- GitHub Actions：run `28851210871`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.64-main-b72b3f29771d-run28851210871-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28851210871/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=b72b3f29771d3b08ef2d2d517d4f730209ccb0a5`、`runId=28851210871`、`runAttempt=1`、`version=v4.64`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：选中普通移动单位时 `HOLD` subtitle 是否仍为 `guard`，选中 Carrier 时是否显示 `CV GW`，选中已绑定 Carrier guard HEL/JET 且未选中 Carrier 时是否显示 `CV rel`，点击 HOLD 后原有绑定 / 释放行为是否保持。
- 后续可继续细化 Carrier guard wing 命令 UI、更多玩家可感知战场事件摘要，或拆分更完整的舰载机巡逻 / 截击能力；这些不属于 v4.64。

### v4.65 / HOLD 航母警戒缺口反馈

日期：2026-07-07

核心变更：

- 玩家对包含 Carrier 的机动单位选择下达 `HOLD` 后，顶部成功消息现在总会只读汇总该次 Carrier guard wing 最终绑定结果。
- 单 Carrier 没有绑定到 HEL/JET 时，消息会显示 `Guard wing 0 Need 2.`；只绑定 1 架时显示 `Guard wing 1 Hn/Jn Need 1.`；满编时继续显示 `Guard wing 2 Hn/Jn.` 且不显示 `Need 0`。
- 多 Carrier 同选时，需求数按 `Carrier 数 * carrierGuardWingRequirement` 聚合，绑定 HEL/JET 按实体 id 去重，组成后缀继续复用 `carrierAirWingCompositionSuffix(for:)` 的 `Hn/Jn` 口径。
- 甲板 cue 仍只在实际绑定到 guard wing 时显示，不为 `0 Need n` 新增 cue。
- 本轮只改变 `issueHoldPositionOrder(units:)` 中成功消息的只读 suffix；不改变 `assignCarrierGuardWing(...)`、`guardAnchorCarrierID` 写入 / 清理、普通 HOLD、release 反馈、AI、战斗、迷雾、生产、支援、任务或胜负逻辑。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.65（HOLD航母警戒缺口反馈）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.65 实现提示词；Agent X 基于 v4.64 遗留事项和两个只读子 agent 侦查结果，选定 Carrier HOLD 后 guard wing 缺口反馈作为小范围命令 UI 可读性增量。
- 只读 reviewer 子 agent 复核当前 diff，结论为 `No issues`；该子 agent 未改文件、未运行本地测试、构建或静态检查。
- Agent B 实现提交并推送：`b031c32a6974b9cd333d8b81e5c9cb390ae75c75`，commit subject 为 `v4.65: HOLD航母警戒缺口反馈`。
- Agent C 复核：GitHub Actions run head branch 为 `main`，head SHA 为 `b031c32a6974b9cd333d8b81e5c9cb390ae75c75`，与本轮实现 commit 一致。
- GitHub Actions：run `28855983038`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.65-main-b031c32a6974-run28855983038-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28855983038/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=b031c32a6974b9cd333d8b81e5c9cb390ae75c75`、`runId=28855983038`、`runAttempt=1`、`version=v4.65`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。
- artifact 下载目录大小约 `100K`，未下载大体积无关产物。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：Carrier HOLD 附近无 HEL/JET、1 架 HEL/JET、满 2 架 HEL/JET 和多 Carrier 同选时的顶部消息是否分别显示预期 `Guard wing` / `Need` 结果，且普通 HOLD release 反馈是否保持。
- 后续可继续细化 Carrier guard wing 命令 UI、更多玩家可感知战场事件摘要，或拆分更完整的舰载机巡逻 / 截击能力；这些不属于 v4.65。

### v4.66 / 单机警戒目标状态

日期：2026-07-07

核心变更：

- 单选玩家已绑定有效 Carrier guard anchor 的 HEL/JET 时，`CV GUARD` 状态行现在会在存在合法 Carrier guard contact 时追加只读 `Tgt XXX Air/Sea/Sub/Ground` 摘要。
- 目标短码来自 `target.kind.shortCode`，类型复用 `carrierGuardContactType(for:)`；目标选择复用 `carrierGuardPriorityTarget(for:)`，继续间接遵守 `isCarrierGuardContact(...)`、`canAttack(...)`、Carrier 近域、HOLD 站位警戒半径和 `isKnownToFaction(...)` 迷雾边界。
- 没有合法 contact 时，单选 bound HEL/JET 状态行仍保持 `CV GUARD Dn  Guard ...`。
- 本轮只改变 `carrierGuardWingStatusLine(for:)` 的只读 HUD 文案；不写入 `attackTarget`、`revealedUntil`、迷雾集合、命令状态或 AI 状态，也不改变 Carrier 单选 / 多选摘要、`Eng n`、release feedback、guard ring、AI、战斗、生产、支援、任务或胜负逻辑。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.66（单机警戒目标状态）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.66 实现提示词；Agent X 基于 v4.65 遗留事项和只读子 agent 侦查结果，选定单选 bound HEL/JET 的合法 guard target 状态作为小范围命令 UI 可读性增量。
- 只读 reviewer 子 agent 复核当前 diff，结论为 `No issues`；该子 agent 未改文件、未运行本地测试、构建或静态检查。
- Agent B 实现提交并推送：`cedc0259f09bf5602c6f890704a9069d8b1e3d7d`，commit subject 为 `v4.66: 单机警戒目标状态`。
- Agent C 复核：GitHub Actions run head branch 为 `main`，head SHA 为 `cedc0259f09bf5602c6f890704a9069d8b1e3d7d`，与本轮实现 commit 一致。
- GitHub Actions：run `28862100898`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.66-main-cedc0259f09b-run28862100898-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28862100898/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=cedc0259f09bf5602c6f890704a9069d8b1e3d7d`、`runId=28862100898`、`runAttempt=1`、`version=v4.66`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。
- artifact 下载目录大小约 `100K`，未下载大体积无关产物。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：单选未绑定 HEL/JET、bound HEL/JET 无合法 contact、bound HEL/JET 有合法 contact 时的 `CV GUARD` 状态行是否分别保持/显示预期 `Tgt`，且隐藏目标不会通过 HUD 泄露。
- 后续可继续细化 Carrier guard wing 命令 UI、更多玩家可感知战场事件摘要，或拆分更完整的舰载机巡逻 / 截击能力；这些不属于 v4.66。

### v4.67 / 多机警戒目标摘要

日期：2026-07-07

核心变更：

- 多选玩家已绑定有效 Carrier guard anchor 的 HEL/JET，且未选中 HOLD Carrier 时，`CV GUARD n Hn/Jn Dm` 摘要现在会在存在合法 Carrier guard contact 时追加只读 `Tgt XXX Air/Sea/Sub/Ground`。
- 多个 selected guard wing 同时存在候选 contact 时，摘要目标按 `carrierGuardTargetPriority(for:target:)`、target 到 anchor Carrier 距离和 target id 稳定打平。
- 目标合法性继续来自 `carrierGuardPriorityTarget(for:)`，间接遵守 `isCarrierGuardContact(...)`、可攻击、Carrier 近域、HOLD 站位警戒半径和 `isKnownToFaction(...)` 迷雾边界。
- 没有合法 contact 时，多选摘要仍保持原有 `CV GUARD n Hn/Jn Dm`。
- 本轮只改变多选 bound HEL/JET 的只读 HUD 摘要；不写入 `attackTarget`、迷雾集合、命令状态或 AI 状态，也不改变单选 bound HEL/JET、Carrier `GW` 摘要、`Eng n`、release feedback、guard ring、AI、战斗、生产、支援、任务或胜负逻辑。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.67（多机警戒目标摘要）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.67 实现提示词；Agent X 基于 v4.66 遗留事项和只读子 agent 侦查结果，选定多选 bound HEL/JET 的合法 guard target 摘要作为小范围命令 UI 可读性增量。
- 只读 reviewer 子 agent 复核当前 diff，结论为 `No issues`；该子 agent 未改文件、未运行本地构建或联网，但误运行了一次 `git diff --check`，未作为本轮验收依据。
- Agent B 实现提交并推送：`de81741fc3cf5f3fdad5f314bbdd5a7645c027e8`，commit subject 为 `v4.67: 多机警戒目标摘要`。
- Agent C 复核：GitHub Actions run head branch 为 `main`，head SHA 为 `de81741fc3cf5f3fdad5f314bbdd5a7645c027e8`，与本轮实现 commit 一致。
- GitHub Actions：run `28864746853`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.67-main-de81741fc3cf-run28864746853-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28864746853/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=de81741fc3cf5f3fdad5f314bbdd5a7645c027e8`、`runId=28864746853`、`runAttempt=1`、`version=v4.67`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。
- artifact 下载目录大小约 `116K`，未下载大体积无关产物。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互或本地测试；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：多选 bound HEL/JET 无合法 contact 时是否保持 `CV GUARD n Hn/Jn Dm`，有合法 contact 时是否追加 `Tgt XXX Air/Sea/Sub/Ground`，且隐藏目标不会通过 HUD 泄露。
- 后续可继续细化 Carrier guard wing 命令 UI、更多玩家可感知战场事件摘要，或拆分更完整的舰载机巡逻 / 截击能力；这些不属于 v4.67。

### v4.68 / AMOV 按钮航母警戒释放提示

日期：2026-07-07

核心变更：

- `AMOV` 按钮 subtitle 不再固定只显示 `push`，会在当前 attack-move 选择会释放 Carrier guard 关系时只读显示 `CV rel`。
- 选中玩家可战斗移动单位中存在已绑定有效 Carrier guard anchor 的 HEL/JET 时，`AMOV` subtitle 显示 `CV rel`。
- 选中玩家 HOLD Carrier 且该 Carrier 当前有 bound guard wing 时，`AMOV` subtitle 显示 `CV rel`，预告该 Carrier 退出 HOLD 后会让相关 guard anchor 失效。
- 其他可战斗移动单位选择仍显示 `push`。
- 本轮只新增 `attackMoveButtonSubtitle()` 并接入 `subtitle(for:)` 的 `.attackMove` 分支；不改变 AMOV 执行、release feedback、`clearCarrierGuardAnchor(...)`、HOLD、Carrier guard station keeping、AI、战斗、迷雾、生产、支援、任务或胜负逻辑。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/prompt/v4（海军航母）/v4.68（AMOV按钮航母警戒释放提示）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.68 实现提示词；Agent X 基于 v4.67 遗留事项和只读子 agent 侦查结果，选定 `AMOV` 按钮 Carrier guard release 预告作为小范围命令 UI 可读性增量。
- 只读 reviewer 子 agent 复核当前 diff，结论为 `No issues`；该子 agent 未改文件、未运行本地测试、构建、静态检查或联网。
- Agent B 实现提交并推送：`23b052215bfc7f14178e7d596f29b567526227f0`，commit subject 为 `v4.68: AMOV按钮航母警戒释放提示`。
- Agent C 复核：GitHub Actions run head branch 为 `main`，head SHA 为 `23b052215bfc7f14178e7d596f29b567526227f0`，与本轮实现 commit 一致。
- GitHub Actions：run `28865889903`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.68-main-23b052215bfc-run28865889903-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28865889903/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=23b052215bfc7f14178e7d596f29b567526227f0`、`runId=28865889903`、`runAttempt=1`、`version=v4.68`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。
- artifact 下载目录大小约 `116K`，未下载大体积无关产物。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 当前没有独立 XCTest target，真实设备上仍建议人工检查：普通 combat selection 的 `AMOV` subtitle 是否仍为 `push`，bound HEL/JET 或带 bound guard wing 的 HOLD Carrier 选择是否显示 `CV rel`，点击 AMOV 后原有 release feedback 和 attack-move 行为是否保持。
- 后续可继续细化 bound HEL/JET `CV GUARD` 接触数 `C0/Cn`、Carrier guard wing 命令 UI、更多玩家可感知战场事件摘要，或拆分更完整的舰载机巡逻 / 截击能力；这些不属于 v4.68。

### v4.69 / 启动视口自适应修复

日期：2026-07-07

核心变更：

- `GameView` 改为用 `GeometryReader` 承载全屏 `SpriteView`，并显式设置 SpriteKit 视图 frame 为当前 SwiftUI 容器尺寸。
- `SpriteView` 和外层容器增加黑色背景兜底，降低场景尚未渲染或视图未铺满时露出系统白屏的风险。
- `SceneHolder` 保留非零初始 `GameScene(size: 1366x1024)`，但将 `scaleMode` 从 `.aspectFill` 改为 `.resizeFill`。
- 新增 `resizeScene(to:)`，在 `onAppear` 和窗口尺寸变化时把有效容器尺寸同步到 `scene.size`，让 HUD、camera clamp、小地图 camera box 和触摸坐标以真实窗口尺寸布局。
- 本轮只修改 SwiftUI / SpriteKit 宿主和启动视口适配；不改变 `GameScene.didMove(to:)` 初始化链路、地图、单位、AI、战斗、HUD 内容、命令、迷雾、任务、胜负或经济规则。
- 当前工作区存在用户本地 `DesertFrontline.xcodeproj/project.pbxproj` 的 `DEVELOPMENT_TEAM = C9YV46L3GA;` 签名改动；本轮提交未包含该无关改动。

关键文件：

- `DesertFrontline/GameView.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.69（启动视口自适应修复）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮不以本地测试、本地静态检查、本机构建或 `git diff --check` 作为验收依据；提交后通过 GitHub Actions 云端验证。
- Agent A 创建 v4.69 实现提示词；用户反馈打开后黑屏 / 白屏不可玩，Agent X 暂停继续扩展玩法，优先选择 SwiftUI / SpriteKit 视口自适应作为启动阻断热修。
- 只读 reviewer 子 agent 复核当前 diff，确认 `GameView` 修复方向无问题、文档已同步、暂存区未混入 `project.pbxproj`；该子 agent 未改文件、未构建、未联网，但误运行了一次仅针对已暂存文件的 `git diff --cached --check`，未作为本轮验收依据。
- Agent B 实现提交并推送：`53d82d9a4b4189948ab14b3869ba63e15b681a02`，commit subject 为 `v4.69: 修复启动视口空白`。
- Agent C 复核：GitHub Actions run head branch 为 `main`，head SHA 为 `53d82d9a4b4189948ab14b3869ba63e15b681a02`，与本轮实现 commit 一致。
- GitHub Actions：run `28868381367`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.69-main-53d82d9a4b41-run28868381367-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-28868381367/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=53d82d9a4b4189948ab14b3869ba63e15b681a02`、`runId=28868381367`、`runAttempt=1`、`version=v4.69`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`testOutcome=skipped`；`xcodebuild.log` 包含 `** BUILD SUCCEEDED **`。
- artifact 下载目录大小约 `100K`，未下载大体积无关产物。

遗留事项：

- 本轮未运行本机 Xcode build、模拟器、真机交互、本地测试、本地静态检查或 `git diff --check`；验证依据是云端 generic iOS device build 结果包。
- 黑屏 / 白屏是否完全消失仍需要人工打开最新 `origin/main` 构建在目标设备或云端可交互环境确认；若仍为空白，下一轮应优先采集启动日志或截图，而不是继续扩展玩法。
- 后续可继续细化 bound HEL/JET `CV GUARD` 接触数 `C0/Cn`、Carrier guard wing 命令 UI、更多玩家可感知战场事件摘要，或拆分更完整的舰载机巡逻 / 截击能力；这些不属于 v4.69。

### v4.70 / 启动闪退保护与云端探针

日期：2026-07-10

核心变更：

- `GameScene.didChangeSize(_:)` 在地形尚未初始化时提前返回，避免 `.resizeFill` 启动阶段过早调用 `layoutHUD()` 并由小地图读取空 `terrain` 导致数组越界。
- GitHub Actions 在 generic iOS device build 后增加 iOS Simulator 启动探针，动态选择可用 iPhone simulator，构建、安装并启动 App，等待后保存截图和 App 日志。
- 启动探针捕获 `simctl launch` 返回的 PID，并通过宿主机 `kill -0` 确认 App 在等待后仍存活；不再依赖模拟器运行时中不存在的 `ps`。
- CI manifest、JUnit、failure summary 和最终失败门禁加入 `simulatorLaunchOutcome`，结果包增加 `simulator-launch.log`、`simulator-app.log` 和 `simulator-screenshot.png`。
- `md/flow/flow.md` 和 `md/test/test.md` 已同步云端启动探针数据流、artifact 内容和 Agent C 验收门槛；玩法、AI、战斗、迷雾、任务、经济和胜负规则未改变。
- 当前工作区的 `DesertFrontline.xcodeproj/project.pbxproj` 团队签名改动保持未暂存，未进入 v4.70 提交。

关键文件：

- `DesertFrontline/GameScene.swift`
- `.github/workflows/ci-results.yml`
- `md/flow/flow.md`
- `md/test/test.md`
- `md/prompt/v4（海军航母）/v4.70（启动闪退保护与云端探针）.md`
- `update_log.md`

验证结果：

- Agent B 实现提交并推送：`c59b1793dcb3dd7aa5b4d40bf11f3e656587be72`，commit subject 为 `v4.70: 修复启动闪退并加入云端探针`。
- 首次 GitHub Actions run `29095993664` 的 generic iOS build、静态检查和工程检查成功，App 也已启动并生成截图，但模拟器运行时没有 `ps`，导致 `simulatorLaunchOutcome=failure`；Agent C 据此退回修复，未把该 run 计为通过。
- Agent B 追加修复提交并推送：`684913271101c0c9a48544a0cfca4c98f25255ee`，commit subject 为 `v4.70: 修复模拟器进程存活检查`。
- Agent C 独立复核：`origin/main`、Actions run head SHA 和 artifact manifest commit SHA 均为 `684913271101c0c9a48544a0cfca4c98f25255ee`。
- GitHub Actions：run `29098058752`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.70-main-684913271101-run29098058752-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-29098058752/`。
- 已核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md`、`static-checks.log`、`project-lint.log`、`simulator-launch.log`、`simulator-app.log`、`simulator-screenshot.png` 和 `DesertFrontline.xcresult`。
- manifest 记录 `branch=main`、`commitSha=684913271101c0c9a48544a0cfca4c98f25255ee`、`runId=29098058752`、`runAttempt=1`、`version=v4.70`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`simulatorLaunchOutcome=success`、`testOutcome=skipped`。
- JUnit 记录 4 个 CI testcase、0 失败、1 skipped；skipped 仅表示当前没有独立 XCTest target。generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`。
- `simulator-launch.log` 确认 `DesertFrontline process 10507 is still running.`；App 日志未发现启动崩溃或数组越界关键字，`1206x2622` PNG 截图显示真实游戏画面而非空白页。

遗留事项：

- 云端启动探针验证了 App 可启动、可渲染并在短等待后存活，但不能替代真机上的触摸、旋转、性能和长时间玩法检查。
- 当前没有独立 XCTest target；`didChangeSize(_:)` 的初始化时序保护仍缺少自动化单元测试，主要由云端 simulator launch probe 覆盖。
- 若目标设备仍发生闪退，应采集对应设备 crash log，与本轮 `simulator-app.log` 对照定位；在启动阻断确认解除前不应以新增玩法掩盖设备问题。

### v4.71 / 小地图海空态势图标

日期：2026-07-11

核心变更：

- 小地图实体符号从主要依赖同类圆点，升级为按领域区分的轻量图形：结构方块、陆军圆点、空军三角和海军菱形。
- 潜艇使用低填充空心菱形，Battleship / Carrier 使用更大的菱形和高对比描边，密集混合编队中更容易判断海空单位和高价值舰艇。
- 当前 `selectedIDs` 中的实体在小地图上显示青白色选择外圈，便于快速定位当前编队或建筑。
- 敌方实体仍在创建小地图符号前经过 `isKnownToFaction(..., observer: .player)`；本轮没有修改战争迷雾、声呐、潜艇暴露或目标合法性，不会通过新符号泄露未知敌人。
- 控制点、小地图相机框、点击跳转、单位命令、AI、战斗、生产、经济、任务和胜负规则保持不变。
- `README.md`、`md/flow/flow.md` 和 `md/flow/flowchart.md` 已同步当前真实行为。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队签名改动保持未暂存，未进入 v4.71 提交。

关键文件：

- `DesertFrontline/GameScene.swift`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/prompt/v4（海军航母）/v4.71（小地图海空态势图标）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；验证依据是 GitHub Actions 云端结果包。
- Agent B 实现提交并推送：`42ad136c2f1c461a8eb136d10c7a5fafc39c5201`，commit subject 为 `v4.71: 强化小地图海空态势图标`。
- Agent C 复核：本地 `main`、`origin/main`、Actions run head SHA 和 artifact manifest commit SHA 均为 `42ad136c2f1c461a8eb136d10c7a5fafc39c5201`。
- GitHub Actions：run `29117377034`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.71-main-42ad136c2f1c-run29117377034-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-29117377034/`。
- manifest 记录 `branch=main`、`commitSha=42ad136c2f1c461a8eb136d10c7a5fafc39c5201`、`runId=29117377034`、`runAttempt=1`、`version=v4.71`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`simulatorLaunchOutcome=success`、`testOutcome=skipped`。
- JUnit 记录 4 个 CI testcase、0 失败、1 skipped；skipped 仅表示当前没有独立 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`。
- `simulator-launch.log` 确认 `DesertFrontline process 8904 is still running.`；App 日志未发现启动崩溃、数组越界、未捕获异常或异常退出关键字。
- simulator screenshot 显示真实游戏画面而非黑屏 / 白屏，小地图已渲染方形结构、圆形陆军、三角空军、菱形海军、空心潜艇符号、高价值舰艇描边和选择外圈。

遗留事项：

- 云端截图证明新符号已渲染，但不能替代真机上对密集编队、缩放、触摸跳转和长时间性能的人工检查。
- 当前没有独立 XCTest target，小地图迷雾过滤和选择外圈主要由现有逻辑审阅、云端 build 与 simulator screenshot 覆盖。
- 下一轮可继续做海岸浅滩、浪线和近岸水面层次，强化 Desert Stormfront 风格海战区域；该视觉增量不属于 v4.71。

### v4.72 / 海岸浅滩与浪线细节

日期：2026-07-11

核心变更：

- 邻接陆地的水格增加内缩浅水菱形，形成深水到近岸青绿色的层次过渡。
- 水格四个正交邻格映射到等距菱形四边；每条真实水陆边绘制低透明度青白冲洗带和细白泡沫线，开阔水格保留稀疏方向波纹。
- 岸线节点只在静态 `drawMap()` 阶段生成，位于 terrain detail 层，不增加每帧动画，不修改 fog、entity 或 HUD 层级。
- `terrain`、`isWaterCoordinate(_:)`、`isCoastal(_:)`、陆海寻路、海岸建造、AI、战斗、声呐、潜艇、经济、任务和胜负规则保持不变。
- 云端 simulator launch 通过 `DESERT_CI_CAMERA_FOCUS=coast` 聚焦玩家 Shipyard 海岸，普通玩家默认启动镜头保持原中央 tile。
- Agent C 首次截图复核发现 runner 延迟期间 skirmish 已推进到玩家失败，Shipyard 被摧毁，无法稳定证明初始海岸资产；追加 `DESERT_CI_CAPTURE_MODE=1`，仅云端截图时保持 HUD 渲染并暂停经济、AI、战斗和胜负推进。普通玩家不设置该变量，实时循环不变。
- `README.md`、`md/flow/flow.md`、`md/flow/flowchart.md` 和 `md/test/test.md` 已同步当前行为与云端截图规则。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.72 提交。

关键文件：

- `DesertFrontline/GameScene.swift`
- `.github/workflows/ci-results.yml`
- `README.md`
- `md/flow/flow.md`
- `md/flow/flowchart.md`
- `md/test/test.md`
- `md/prompt/v4（海军航母）/v4.72（海岸浅滩与浪线细节）.md`
- `update_log.md`

验证结果：

- 按人工要求，本轮未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端结果包。
- Agent B 实现提交并推送：`e3aa719f215dd761d626f90f071704944ef78051`，commit subject 为 `v4.72: 增强海岸浅滩与浪线细节`。
- 首次实现 run：`29119227669`，conclusion `success`；manifest、JUnit、两类 build 和 PID 存活均通过，海岸聚焦截图已显示浅水层和岸线泡沫。
- Agent C 未直接接受首次 run：截图时显示 `$15340`、Blue 0、任务失败且玩家 Shipyard 已消失，说明 runner 延迟让 skirmish 继续推进，不能稳定满足初始海岸视觉验收。
- Agent B 追加修复提交并推送：`fd3ad07849d2c6b7086bfcbf73fb906ecce88860`，commit subject 为 `v4.72: 稳定云端海岸截图状态`。
- GitHub Actions 修复 run：`29119817302`，attempt `1`，workflow `Desert Frontline CI Results`，conclusion `success`，head branch 为 `main`。
- artifact：`desert-frontline-ci-v4.72-main-fd3ad07849d2-run29119817302-attempt1`，已下载到 `/private/tmp/desert-frontline-c-review-29119817302/`。
- manifest 记录 `branch=main`、`commitSha=fd3ad07849d2c6b7086bfcbf73fb906ecce88860`、`runId=29119817302`、`runAttempt=1`、`version=v4.72`、`buildOutcome=success`、`staticChecksOutcome=success`、`projectLintOutcome=success`、`simulatorLaunchOutcome=success`、`testOutcome=skipped`。
- JUnit 记录 4 个 CI testcase、0 失败、1 skipped；skipped 仅表示当前没有独立 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`。
- `simulator-launch.log` 确认 `DesertFrontline process 11962 is still running.`；App 日志未发现启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 修复后的 simulator screenshot 在长 runner 延迟后仍保持初始 `$5200`、Blue 8 / Red 7、Oil 1、任务未失败，并显示玩家 Shipyard、Battleship、Carrier、浅滩、冲洗带、泡沫线、小地图和 HUD，不是黑屏或白屏。

遗留事项：

- 云端截图模式用于稳定视觉证据，会暂停玩法推进；普通实时循环仍由 generic iOS build 覆盖，但真机长时间玩法、触摸和性能仍需人工检查。
- 当前没有独立 XCTest target，四边岸线映射和默认镜头 / CI 镜头分流主要由源码审阅、云端 build 和 simulator screenshot 覆盖。
- 后续可继续增加海军航迹、舰炮命中水柱或空军投影等海空战细节，但应保持每轮一个可验证增量。

### v4.73 / 移动海军方向航迹

日期：2026-07-11

核心变更：

- Battleship、Submarine 和 Carrier 各自预创建方向化 `navalWakeNode`，包含双侧青白冲洗、细泡沫线和中心扰流，尺寸按舰种区分。
- `updateMovement(dt:)` 只在海军单位实际位移时按世界方向和实体镜像换算局部舰艉方向，显示并轻微调制航迹；idle 时隐藏。
- 航迹是实体子节点，随敌方实体迷雾可见性一起隐藏，不创建独立残留效果，不泄露隐藏海军位置，节点数量不按帧增长。
- 航迹不修改速度、寻路、编队、碰撞、攻击、AI、声呐、潜艇暴露、经济、任务或胜负。
- CI capture scene 仅在 `DESERT_CI_CAPTURE_MODE=1` 时把初始玩家 Carrier 临时编排到可见近岸水域，并给玩家海军设置确定性移动意图以稳定展示 BB/CV 航迹；普通启动的初始位置和实时玩法不变。
- README、核心 flow、flowchart、测试规则和 v4.73 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.73 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部重验证来自 GitHub Actions 云端 artifact。
- 实现提交：`691dab259add2168f4e7b0bba4f4a20c1c457012`，run `29121258596` 成功，artifact 的 manifest、JUnit、两类 build、PID 和日志检查通过。
- Agent C 首次截图未直接接受：Battleship 航迹可见，但初始 Carrier 被底部 HUD / 取景边缘遮挡，不能同时证明 Carrier 航迹。
- 取景修复提交：`105d783dc9c4b47e99f151c8f2b89d3730645f10`，run `29121967218` 成功。
- 修复 artifact：`desert-frontline-ci-v4.73-main-105d783dc9c4-run29121967218-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29121967218/`。
- manifest 记录 `branch=main`、`commitSha=105d783dc9c4b47e99f151c8f2b89d3730645f10`、`runId=29121967218`、`version=v4.73`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；启动 PID `6430` 等待后仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 1206x2622 simulator screenshot 显示稳定的 `$5200` 初始战场、玩家 Shipyard、Carrier `CV`、Battleship `BB`、两艘舰体后的方向泡沫 / 冲洗航迹、海岸层次、小地图和 HUD，不是黑屏或白屏。

遗留事项：

- 当前云端截图只证明确定性 BB/CV 航迹和启动稳定性；真实连续转向、不同缩放、密集舰队、敌方迷雾切换和真机性能仍需人工玩法检查。
- 当前没有独立 XCTest target，航迹方向与迷雾同步主要由源码边界、云端 build 和 simulator screenshot 覆盖。
- 下一轮可增加舰炮命中水柱和水面冲击圈，继续保持单一海战视觉增量。

### v4.74 / 舰炮命中水柱与冲击圈

日期：2026-07-11

核心变更：

- 参考 Noble Master 官方 Desert Stormfront 产品页、官方预告片入口和官方截图资源，采用适合俯视等距战场的短促高对比海战反馈。
- Battleship、Coastal Battery、Artillery 通过共享 `fire(attacker:target:)` 链路命中水面舰艇时，显示双层椭圆冲击圈、窄水柱、冠状泡沫和四个碎滴。
- 命中位置按目标 id 确定性偏离舰体中心，减少水柱完全遮挡舰体；Battleship 使用较大效果，岸防炮和火炮使用较小效果。
- 玩家舰艇被命中时可显示；敌方舰艇必须满足玩家已知边界。Submarine 继续使用既有 `ASW HIT`，Carrier 继续使用 wing-strike，不叠加错误反馈。
- 普通战斗效果约 0.56 秒后整体移除，不持续增加节点；CI capture mode 才在 BB/CV 附近保留两个确定性效果，经 runner 长延迟仍可截图。
- 伤害、射速、射程、护甲、攻击合法性、AI、路径、经济、任务、胜负、声呐和潜艇暴露均未改变。
- README、核心 flow、flowchart、测试规范和 v4.74 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.74 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`9a423cb70de22b2587a9567815d31fb37b9e1eff`，commit subject 为 `v4.74: 增强舰炮水面命中反馈`。
- GitHub Actions run：`29123274761`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.74-main-9a423cb70de2-run29123274761-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29123274761/`。
- manifest 记录 `branch=main`、`commitSha=9a423cb70de22b2587a9567815d31fb37b9e1eff`、`runId=29123274761`、`version=v4.74`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；启动 PID `11581` 等待后仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 1206x2622 simulator screenshot 显示稳定的 `$5200` 初始战场、Shipyard、BB/CV、舰艉航迹、两组水柱、冲击圈、泡沫冠、碎滴、小地图和 HUD，不是黑屏或白屏。

遗留事项：

- 云端截图证明持久化 CI 样例的构图和层级；真实 0.56 秒动画节奏、连续齐射、多个舰队密集命中、缩放和真机性能仍需人工玩法检查。
- 当前没有独立 XCTest target，攻击者 / 目标过滤与迷雾边界主要由源码审阅、云端 build 和 simulator screenshot 覆盖。
- 下一轮可强化空战：加入战机投影、导弹尾迹或防空命中反馈，仍保持每轮一个可验证增量。

### v4.75 / 空军投影与导弹尾迹

日期：2026-07-11

核心变更：

- 参考 Noble Master 官方 1 分钟 trailer、TouchGameplay 15 分钟 gameplay 和官方产品页中的 Helicopter / Plane 俯视战斗表现。
- Helicopter 新增机身、尾梁和旋翼轮廓投影；Fighter 新增缩小 jet 轮廓投影。旧通用椭圆影子只对空军隐藏，不影响陆海单位。
- 空军投影作为 `GameEntity.airShadowNode` 子节点随实体迷雾隐藏；实际移动时按方向和实体镜像调整局部偏移，并轻微调制透明度，不按帧创建节点。
- Fighter、SAM Site、AA Truck 的 `showProjectile(...)` 分支改为宽低透明度烟迹、阵营弹道色高亮线和沿轨迹移动的发光弹体。
- 上述三类攻击命中玩家空军或玩家已知敌方空军时显示双环和六向火花；隐藏敌方空军不通过反馈泄露位置。
- 普通导弹烟迹和命中反馈约 0.38 / 0.42 秒后清理；CI air capture scene 才临时编排 Blue / Red HEL/JET 并持久化一条 Fighter 导弹和命中环。
- workflow 从 coast screenshot 切换到 `DESERT_CI_CAMERA_FOCUS=air`，当前版本优先验证空战主体；普通启动的单位、镜头和实时循环不变。
- 飞行速度、高度、路径、伤害、射速、射程、目标合法性、AI、Carrier guard、经济、任务、胜负和迷雾规则均未改变。
- README、核心 flow、flowchart、测试规范和 v4.75 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.75 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`f10bbaca59ad9bbb8247ee7c68c6739488e85fa1`，commit subject 为 `v4.75: 强化空军投影与导弹尾迹`。
- GitHub Actions run：`29124625386`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.75-main-f10bbaca59ad-run29124625386-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29124625386/`。
- manifest 记录 `branch=main`、`commitSha=f10bbaca59ad9bbb8247ee7c68c6739488e85fa1`、`runId=29124625386`、`version=v4.75`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；启动 PID `15703` 等待后仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 1206x2622 air screenshot 显示 `$5200` 稳定战场、Blue / Red HEL/JET、空军轮廓投影、导弹高亮线、烟迹、白色弹体、双环 / 六向命中火花、小地图和 HUD，不是黑屏或白屏。

遗留事项：

- 云端截图证明持久化空战样例的构图和层级；真实 0.38 秒导弹运动、连续防空齐射、密集空军、缩放和真机性能仍需人工玩法检查。
- 当前没有独立 XCTest target，三类导弹分流、目标可见性和节点清理主要由源码审阅、云端 build 与 simulator screenshot 覆盖。
- 下一轮可细化空军模型：Fighter 机翼挂点、Helicopter 旋翼盘 / 尾桨或空军编队间距，保持单一可验证增量。

### v4.76 / 空军模型几何细化

日期：2026-07-11

核心变更：

- 再次参考 Desert Stormfront 官方截图、官方 trailer 和 TouchGameplay 15 分钟 gameplay，以移动端俯视辨识为目标细化 HEL/JET 几何。
- Helicopter 增加阵营化座舱玻璃、双侧武器短舱、主旋翼盘和轴心、动画尾桨、双侧滑橇和四根起落架支杆。
- Fighter 增加阵营化座舱玻璃、机身脊线、双侧翼下挂弹和挂架、尾部稳定翼及机鼻传感器。
- Blue / Red 继续使用原机身阵营色；Blue 玻璃偏青蓝，Red 玻璃偏橙红，在同一 air screenshot 中保持阵营可读性。
- 所有新部件都位于现有 `addAirUnitBody(...)` 的 `base` 子树内，随实体移动、镜像、迷雾、选择和销毁，不新增独立玩法对象或逐帧节点。
- 模型细节保持在现有 footprint 内，不修改碰撞、弹药、挂载消耗、攻击、速度、路径、AI、Carrier guard、经济、任务或胜负。
- README、核心 flow、flowchart、测试规范和 v4.76 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.76 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`c3b645d5a6349105153b01b23ff4c690cf09a306`，commit subject 为 `v4.76: 细化空军机体模型`。
- GitHub Actions run：`29127209976`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.76-main-c3b645d5a634-run29127209976-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29127209976/`。
- manifest 记录 `branch=main`、`commitSha=c3b645d5a6349105153b01b23ff4c690cf09a306`、`runId=29127209976`、`version=v4.76`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；启动 PID `8602` 等待后仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 1206x2622 air screenshot 清楚显示 Red HEL 的座舱、短舱、旋翼盘 / 轴心、尾桨、滑橇，以及 Red JET 的座舱、挂弹、挂架、尾翼和机鼻传感器；空军投影、导弹、命中环、小地图和 HUD 仍正常，不是黑屏或白屏。

遗留事项：

- 云端静态截图不能证明主旋翼 / 尾桨动画节奏、快速镜像转向或密集编队性能，仍需人工真机玩法检查。
- 当前没有独立 XCTest target，模型层级和 footprint 主要由源码审阅、云端 build 和 simulator screenshot 覆盖。
- 下一轮可优化空军编队间距和同域避让，减少 HEL/JET 密集叠放，同时保持移动命令语义不变。

### v4.77 / 空军编队间距与同域避让

日期：2026-07-11

核心变更：

- 空军 formation slot 间距由 58 提高到 84；陆军 40、海军 70 保持不变，玩家和 AI 继续共享既有编队命令入口。
- 空军实际移动时对 76pt 内同阵营存活空军叠加轻量分离方向，并要求调整方向保留到目的地的正向分量；不推开敌军、结构或其他领域单位，也不引入物理碰撞。
- 空军攻击接近点按 attacker id 分配为目标周围 8 个确定性椭圆站位，减少 HEL/JET 同时收敛到目标中心造成的机体、投影和生命条重叠；射程、伤害、目标合法性和开火链路保持不变。
- CI air capture scene 改用真实 `formationOffsets(...)` 编排 Blue / Red 各 3 架 HEL/JET，并保留 Fighter 导弹和命中环证据。
- README、核心 flow、flowchart、测试规范和 v4.77 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.77 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`c51e104882fbf2011925665d4e52fe0731f11116`，commit subject 为 `v4.77: 优化空军编队间距与避让`。
- GitHub Actions run：`29129470381`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.77-main-c51e104882fb-run29129470381-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29129470381/`。
- manifest 记录 `branch=main`、`commitSha=c51e104882fbf2011925665d4e52fe0731f11116`、`runId=29129470381`、`version=v4.77`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；启动 PID `49193` 等待后仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 1206x2622 air screenshot 显示 Blue / Red 各 3 架 HEL/JET 以清晰间距分组，机体、投影、生命条、队旗、导弹和命中环均已渲染，不是黑屏或白屏。

遗留事项：

- 云端静态 capture scene 冻结玩法循环，可证明编队初始间距和渲染层级，但不能覆盖真实移动中的持续避让、目标移动、密集空战和长时间性能，仍需人工真机玩法检查。
- 当前没有独立 XCTest target，同域过滤、正向分量和攻击站位主要由源码审阅、云端 build 和 simulator screenshot 覆盖。
- 下一轮可继续优化空军战斗可读性，例如防空威胁提示或选择态航线，但应保持单一、可云端验证的增量。

### v4.78 / 选中空军防空威胁态势

日期：2026-07-11

核心变更：

- 参考 Noble Master 官方 Desert Stormfront itch.io 产品页的 5 张 1280x800 截图，借鉴其密集战场中橙色顶标、红色地面标记、高对比投影和紧凑态势反馈，不复制原素材或 UI 布局。
- 玩家选中 Helicopter / Fighter 时，只收集玩家当前已知、存活、operational 且真实射程覆盖至少一架选中空军的敌方 SAM Site / AA Truck。
- 合法威胁显示低填充红橙射程圈、三重橙色顶标和核心警示点；节点随实体迷雾隐藏，不为未知敌军扩大视野或泄露位置。
- 选择状态行及普通单选 / 多选信息显示紧凑 `AA THRn Sn Mn Cx/y` 摘要，其中 `S` 为 SAM、`M` 为 mobile AA、`C` 为被覆盖的选中空军；无合法威胁显示 `CLEAR`。HOLD、CV GUARD 和 attack-move 原状态行保持不变。
- 覆盖判断复用 `isKnownToFaction(...)`、`canAttack(...)`、静态 `attackRange`、存活与 operational 边界；不修改防空射程、伤害、冷却、目标获取、AI、移动、生产或迷雾。
- CI air capture scene 选中 Blue 三架 HEL/JET，并在真实覆盖距离内布置 Red SAM Site / AA Truck，继续保留空军模型、投影、导弹、命中环和 v4.77 编队证据。
- README、核心 flow、flowchart、测试规范和 v4.78 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.78 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`3d7fa81a2068ae563151bca58ea120f444c3de9c`，commit subject 为 `v4.78: 增强空军防空威胁态势`。
- GitHub Actions run：`29134910857`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.78-main-3d7fa81a2068-run29134910857-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29134910857/`。
- manifest 记录 `branch=main`、`commitSha=3d7fa81a2068ae563151bca58ea120f444c3de9c`、`runId=29134910857`、`version=v4.78`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；启动 PID `9520` 等待后仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 1206x2622 air screenshot 显示 Blue 三机绿色选择环、Red SAM / AA 机体、两个红橙覆盖圈、两处橙色三重顶标、`AA THR2 S1 M1 C3/3` 状态摘要、空军投影、导弹和命中环，不是黑屏或白屏；圈线未完全遮挡战场主体。

遗留事项：

- 云端冻结截图证明确定性覆盖判定、HUD 和视觉层级，但不能覆盖真实飞入 / 飞出射程、敌方移动 AA、迷雾切换、密集防空区和长时间性能，仍需人工真机玩法检查。
- 当前没有独立 XCTest target，威胁过滤、覆盖计数和未知敌军不泄露主要由源码边界、云端 build 与 simulator screenshot 覆盖。
- 下一轮可依据官方截图继续压缩战场 HUD 占用或增强移动 / 攻击目标标记，优先改善小屏幕战场可见面积与操作效率。

### v4.79 / 五页单排战术 HUD

日期：2026-07-11

核心变更：

- 继续参考 Noble Master 官方 Desert Stormfront 产品截图与玩法视频中紧凑、按作战域分组的移动端命令区，优先扩大横屏战场可视面积和降低常用命令查找成本，不复制原素材或 UI 布局。
- 原固定两排 24 个按钮改为 `TACT`、`BUILD`、`AIR`、`SEA`、`SUP` 五个常驻页签和单排动作区，底部命令区高度由约 114pt 压缩至约 54pt。
- `TACT` 提供 `ARMY / G1 / G2 / HOLD / AMOV / RLY / HQ`；`BUILD` 提供 `HMV / AA / TANK / ART / MECH / BASE`；`AIR` 提供 `HELI / JET`；`SEA` 提供 `SHIP / SUB / CV`；`SUP` 提供 `SCAN / REPR / AIRS / BARR / AI / SKRM`。
- 当前页签使用金色描边与辉光；隐藏页若持有已武装的待执行命令，也保留提示辉光，避免切页后遗忘支援、建造或攻击移动状态。
- 切换页面只重建 HUD，不清空选择、编队、生产队列或 pending mode；重新开始 skirmish 时命令页恢复为 `TACT`。
- GitHub Actions 新增 `DESERT_CI_HUD_PAGE=tactical/build/air/naval/support`，同一 run 分别启动并截图五个页面，覆盖页面映射、页签高亮和单排布局。
- README、核心 flow、flowchart、测试规范和 v4.79 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.79 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`ddf0c3e2ae5fdcc0660937f7886ae68ef08a5071`，commit subject 为 `v4.79: 重构五页单排战术HUD`。
- GitHub Actions run：`29138765401`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.79-main-ddf0c3e2ae5f-run29138765401-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29138765401/`。
- manifest 记录 `branch=main`、`commitSha=ddf0c3e2ae5fdcc0660937f7886ae68ef08a5071`、`runId=29138765401`、`version=v4.79`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；五次页面启动 PID `29927`、`31194`、`32381`、`33116`、`33847` 等待后均仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 五张 1206x2622 云端截图均显示真实战场而非黑屏或白屏；`TACT / BUILD / AIR / SEA / SUP` 各页正确金色高亮，页面动作完整显示在一排且无文字或按钮裁切。
- 战场纵向可视面积相较 v4.78 双排 HUD 明显增加；空军编队、SAM / AA 威胁圈、导弹与命中反馈、小地图和 `AA THR2 S1 M1 C3/3` 状态摘要仍正常显示。

遗留事项：

- 云端五页截图和进程存活证明页面构成与启动稳定性，但真实触摸切页、连续快速切页、跨页 pending mode 辉光和真机横屏适配仍需人工玩法检查。
- 当前没有独立 XCTest target，页签状态保持、skirmish 重置和武装态跨页提示主要由源码边界、云端 build 与确定性截图覆盖。
- 下一轮可增强移动、攻击移动和攻击目标的落点反馈，使压缩 HUD 后的战场操作意图更清晰，并保持单一可云端验证增量。

### v4.80 / 三类战场命令落点反馈

日期：2026-07-12

核心变更：

- 参考 Noble Master 官方 Desert Stormfront 产品截图与 trailer 中“瞬时、高对比、贴地、低遮挡”的命令确认方式，不复制原素材或 UI 布局。
- 普通移动在 domain anchor 显示青绿色 `MOVE` 贴地环、方向箭头与短刻度。
- 攻击移动显示琥珀色双环 `AMOV`、十字推进箭头和标签，视觉上与 `MOVE` 明显区分。
- 直接攻击仅在 `assignedAttackers > 0` 后，对 `entity(at:)` 已通过玩家迷雾认知过滤的目标显示红色 footprint-aware `ATK <shortCode>` 四角框。
- 三类组合节点进入 `effectsLayer`，普通启动约 0.68 秒淡出移除；CI 通过 `DESERT_CI_COMMAND_MARKER=move|attack-move|attack-target` 持久冻结以便云端截图。
- 不修改目的地、攻击合法性、编队、伤害、射程、AI、HUD 五页映射或迷雾集合。
- README、核心 flow、flowchart、测试规范和 v4.80 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.80 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`3e55966d9f9292d6880a755303104825a95f0baa`，commit subject 为 `v4.80: 强化战场命令落点反馈`。
- GitHub Actions run：`29144924115`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.80-main-3e55966d9f92-run29144924115-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29144924115/`。
- manifest 记录 `branch=main`、`commitSha=3e55966d9f9292d6880a755303104825a95f0baa`、`runId=29144924115`、`version=v4.80`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；八次启动 PID `12536`、`13706`、`14056`、`14572`、`14600`、`15130`、`15909`、`16316` 等待后均仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 八张 1206x2622 云端截图均显示真实战场而非黑屏或白屏。对 command 截图与 baseline HUD 截图做像素差分：`MOVE` 热区以青绿色为主（cyan_frac≈0.51），`AMOV` 热区以琥珀色为主（amber_frac≈0.72），`ATK` 热区以红色为主（red_frac≈0.61）；三类 marker 彼此可区分，目标框不遮挡机体主体。
- 源码审阅确认 `showAttackTargetMarker` 仅在分配成功后调用，目标来自 `entity(at:)` 迷雾过滤；普通 marker 经 `presentCommandMarker` 自动移除，CI `persistent` 不进入普通启动。

遗留事项：

- 云端冻结截图证明三类落点反馈的颜色、标签与启动稳定性，但不能覆盖真实触摸落点、多 domain 同时下达、密集单位遮挡和长时间性能，仍需人工真机玩法检查。
- 当前没有独立 XCTest target，命令 marker 生命周期与迷雾边界主要由源码边界、云端 build 与差分截图覆盖。
- 下一轮可继续增强战斗可读性，例如选中单位当前命令意图线 / 目标连线，或海军 / 空战命中反馈细化，并保持单一可云端验证增量。
### v4.81 / 选中单位命令意图线

日期：2026-07-12

核心变更：

- 玩家选中且存活的己方机动单位显示只读命令意图线，优先级为已知 `attackTarget`（红虚线）>`attackMoveDestination`（琥珀虚线）>`destination/path`（青绿虚线）>`holdPosition`（淡金虚线）。
- 节点挂在实体 `commandIntentNode`，经 `refreshSelection` / `updateHUD` 刷新；取消选中即隐藏并清空子节点。
- 直接攻击线仅当目标存活且 `isKnownToFaction(..., observer: .player)` 时绘制，不泄露隐藏敌军或潜艇。
- CI air capture 场景为选中玩家空军冻结代表性意图：主战 Fighter 指向已知敌机，一架 HEL 保留 AMOV 终点，其余 Fighter 保留 move destination，便于主截图验证分色意图线。
- 不修改命令语义、寻路、伤害、射程、AI、HUD 五页映射或迷雾集合。
- README、核心 flow、flowchart、测试规范和 v4.81 提示词已同步。
- 同步清理 v4.80 验收日志末尾多余空行，避免 `git diff --check` static checks 失败。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.81 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`9319000131a647266a43df608c6ed541e16e0ff8`，commit subject 为 `v4.81: 增加选中单位命令意图线`。
- GitHub Actions run：`29165208722`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.81-main-9319000131a6-run29165208722-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29165208722/`。
- manifest 记录 `branch=main`、`commitSha=9319000131a647266a43df608c6ed541e16e0ff8`、`runId=29165208722`、`version=v4.81`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；八次启动 PID `10811`、`12084`、`12838`、`12994`、`13656`、`13992`、`14670`、`15354` 等待后均仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 八张 1206x2622 云端截图均为真实战场而非黑屏或白屏。相对 v4.80 baseline 主截图差分热区约 0.34%，热区颜色同时覆盖青绿 / 琥珀 / 红色意图反馈；command marker 三张图继续可用。
- 源码审阅确认意图线只读、选中边界正确，攻击线复用玩家迷雾认知过滤。

遗留事项：

- 云端冻结截图证明选中态分色意图线与启动稳定性，但不能覆盖真实连续下令、目标死亡 / 迷雾切换、多 domain 混选和长时间性能，仍需人工真机玩法检查。
- 当前没有独立 XCTest target，意图优先级与隐藏逻辑主要由源码边界、云端 build 与差分截图覆盖。
- 下一轮可继续增强战斗可读性，例如命中飘字 / 伤害数字、海军交战方位扇区或选中编队共用目标标记，并保持单一可云端验证增量。
### v4.82 / 命中伤害飘字

日期：2026-07-12

核心变更：

- `fire(attacker:target:)` 对玩家单位或玩家已知敌方目标显示短促伤害飘字 `-\(Int)`，进入 `effectsLayer` 后上浮淡出。
- 显示边界复用 `isKnownToFaction(..., observer: .player)`；未知敌军不显示，不改变伤害、目标、AI 或迷雾。
- CI air capture 在导弹命中附近冻结 persistent 示例飘字，便于主截图核对。
- README、核心 flow、flowchart、测试规范和 v4.82 提示词已同步。
- 工作区中的 `DesertFrontline.xcodeproj/project.pbxproj` 团队号改动保持未暂存，未进入 v4.82 提交。

验证结果：

- 按人工要求未运行本地测试、本地静态检查、本机 Xcode build、本地模拟器或本地探针；全部验证来自 GitHub Actions 云端 artifact。
- 实现提交：`09c728597b7b0cba0ba838da26eab8ffd4a5b027`，commit subject 为 `v4.82: 增加命中伤害飘字反馈`。
- GitHub Actions run：`29166263191`，attempt `1`，conclusion `success`。
- artifact：`desert-frontline-ci-v4.82-main-09c728597b7b-run29166263191-attempt1`，缓存于 `/private/tmp/desert-frontline-c-review-29166263191/`。
- manifest 记录 `branch=main`、`commitSha=09c728597b7b0cba0ba838da26eab8ffd4a5b027`、`runId=29166263191`、`version=v4.82`，build、static checks、project lint、simulator launch 均为 success。
- JUnit 记录 4 项 CI 检查、0 失败、1 skipped；skipped 仅表示当前没有 XCTest target。
- generic iOS device build 和 simulator build 均包含 `** BUILD SUCCEEDED **`；八次启动 PID `19362`、`20538`、`21233`、`22123`、`22639`、`23091`、`23401`、`23868` 等待后均仍存活，App 日志未命中启动崩溃、数组越界、未捕获异常或异常退出关键字。
- 1206x2622 云端截图为真实战场而非黑屏或白屏；相对 v4.81 baseline 差分热区约 0.12%，空战区域可见黄橙色伤害飘字样本，command marker 与意图线探针继续可用。
- 源码审阅确认飘字只读、迷雾边界正确，CI persistent 示例不进入普通启动。

遗留事项：

- 云端冻结截图证明可见命中飘字与启动稳定性，但不能覆盖真实连射、多单位重叠、目标移出迷雾和长时间性能，仍需人工真机玩法检查。
- 当前没有独立 XCTest target，显示过滤主要由源码边界、云端 build 与差分截图覆盖。
- 下一轮可继续增强战斗/海空细节，例如选中编队共用目标标线、舰炮方位扇区或更细的爆炸分层，并保持单一可云端验证增量。
