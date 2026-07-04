# 项目版本更新记录

本文记录 `Desert Frontline` 的正式版本、重要维护事项、关键决策和遗留问题。它不是流水账，只保留影响后续开发判断的信息。

## 维护规则

- 每完成一个正式版本或重要任务后追加记录。
- 记录必须包含：版本/任务名、日期、核心变更、关键文件、验证结果、遗留事项。
- 文档整理、目录迁移、回滚、打捞等写入“历史维护记录”，不要伪装成新玩法版本。
- 若核心逻辑、测试规范或项目行为变化，必须同步更新本文。
- 测试结果必须写具体命令和结论；不得只写“已验证”。

## 当前状态

日期：2026-07-04

当前项目已经是一个可构建的 iOS RTS 原型，覆盖经济、建造、雷达前哨、陆军、空军、海军、战舰、航母、AI、地图、战争迷雾、老兵经验、支援技能、HUD、任务阶段和 HQ 胜负条件。当前主要逻辑集中在 `DesertFrontline/GameScene.swift`。

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
