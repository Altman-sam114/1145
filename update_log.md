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
