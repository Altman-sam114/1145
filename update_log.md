# 项目版本更新记录

本文记录 `Desert Frontline` 的正式版本、重要维护事项、关键决策和遗留问题。它不是流水账，只保留影响后续开发判断的信息。

## 维护规则

- 每完成一个正式版本或重要任务后追加记录。
- 记录必须包含：版本/任务名、日期、核心变更、关键文件、验证结果、遗留事项。
- 文档整理、目录迁移、回滚、打捞等写入“历史维护记录”，不要伪装成新玩法版本。
- 若核心逻辑、测试规范或项目行为变化，必须同步更新本文。
- 测试结果必须写具体命令和结论；不得只写“已验证”。

## 当前状态

日期：2026-06-28

当前项目已经是一个可构建的 iOS RTS 原型，覆盖经济、陆军、空军、海军、战舰、航母、AI、地图、战争迷雾、支援技能、HUD、任务阶段和 HQ 胜负条件。当前主要逻辑集中在 `DesertFrontline/GameScene.swift`。

当前可靠验证基线是 generic iOS device build：

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

- 老兵/经验系统未完成：`GameEntity` 已有 `veterancyXP`、`killCount`、`veterancyNode` 字段，但未完整接入击杀结算、等级、加成、HUD 和 README。
- 移动端实际手感仍需要真机或可用模拟器验证。
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
