# AGENTS.md

本文是 `Desert Frontline` 的入口记忆、项目总览、基本规则和多 Agent 迭代工作流。后续 Codex / 编程 Agent 必须先读本文，再按顺序读取项目文档和源码。

## 1. 一句话总览

`Desert Frontline` 是一个 iOS SwiftUI + SpriteKit 即时战略原型，目标是参考 Desert Stormfront 的玩法形态，持续完善经济、建造、陆海空单位、战舰、航母、AI、地图、战争迷雾、HUD 和胜负条件。

## 2. 必读文件顺序

1. `AGENTS.md`：入口规则、Agent A/B/C 工作流、禁止项。
2. `update_log.md`：正式版本、历史决策、完成事项、遗留问题。
3. `md/flow/flow.md`：当前真实核心架构、数据流、执行流。
4. `md/flow/flowchart.md`：核心逻辑和 Agent 迭代流程图。
5. `md/test/test.md`：测试分层、命令、触发条件、当前基线。
6. `README.md`：玩家可见功能清单、控制方式、构建说明。
7. `DesertFrontline/GameScene.swift`：核心游戏逻辑。
8. `DesertFrontline/GameView.swift`、`DesertFrontline/DesertFrontlineApp.swift`、`DesertFrontline.xcodeproj/project.pbxproj`：SwiftUI 宿主、App 入口、Xcode 配置。

## 3. 项目基本规则

- 以当前工作树和当前文档为准，不依赖外部记忆推断代码状态。
- 每轮只做一个清晰、可验证、能推进 RTS 完整度的增量。
- 不做无关重构，不删除旧能力，不回滚用户或其他 Agent 的改动。
- 所有玩法变更必须同步考虑玩家操作、AI 使用、HUD 展示、战争迷雾、胜负/任务影响和重开 skirmish 后的重置。
- 纯文档任务不需要跑 Xcode 构建，但必须至少运行 `git diff --check`。
- 改 Swift 代码后必须按 `md/test/test.md` 选择测试层级，最低要求是 generic iOS device build。

## 4. 核心架构边界

- `GameScene.swift` 是当前事实核心，集中管理地图、实体、经济、输入、HUD、AI、战斗、生产、迷雾和胜负循环。
- `GameEntity` 是单位/建筑运行态对象，`EntityKind` 是单位/建筑静态属性来源。
- 玩家和 AI 共享移动、攻击、生产、支援技能等执行逻辑；新增能力不得只给一方绕路实现，除非任务明确要求。
- 建筑施工状态以 `isOperational` 为边界；未完工建筑可被攻击，但不得生产、赚钱或扩展基地覆盖。
- 战争迷雾以 `visibleTiles`、`exploredTiles`、`supportRevealTiles` 和 `isKnownToFaction(...)` 为边界；玩家目标合法性和敌方显示不得绕开迷雾规则。
- 潜艇隐身依赖 `revealedUntil` 与声呐检测；新增海战逻辑必须保持潜艇侦测链路。
- 当前已有 `veterancyXP`、`killCount`、`veterancyNode` 字段，但老兵/经验系统尚未完整接入；完成前不得在 README 或日志中宣称已完成。

## 5. 标准迭代工作流

### 人工

人工提出目标，可同时给出算法框架、禁止项、验收标准、性能要求、UI/交互要求和测试要求。人工复核 Agent C 输出后决定是否进入下一轮。

### Agent A：目标分析与实现提示词

Agent A 默认不写代码，负责把人工目标转化为可执行提示词。

必须执行：

1. 阅读本文、`update_log.md`、`md/flow/flow.md`、`md/flow/flowchart.md`、`md/test/test.md`、`README.md`。
2. 阅读相关源码和现有提示词。
3. 明确本轮目标、非目标、边界、依赖、风险和验收标准。
4. 设计实现方案：改哪些模块、数据/状态流如何变化、是否需要新增接口/模型/测试、哪些旧行为必须保持。
5. 确定版本号：人工指定则按人工指定；未指定则从 `md/prompt/` 和 `update_log.md` 推断并递增，小任务用 `v0.2`、`v0.3`，重要阶段可用 `v1.0`。
6. 将给 Agent B 的详细提示词写入 `md/prompt/v0（简要标题）/v0.1（简要说明）.md` 这类路径。

提示词必须包含：版本号、版本分配依据、背景、目标、非目标、当前架构依据、实现步骤、关键文件、测试要求、文档更新要求、验收标准、风险和禁止项。

### Agent B：实现与测试

Agent B 负责按 Agent A 提示词实现。

必须执行：

1. 阅读 Agent A 提示词和所有必读文档。
2. 阅读相关源码和测试配置。
3. 小步实现，不扩大范围，不做无关格式化。
4. 按 `md/test/test.md` 选择测试层级，运行命令并记录结果。
5. 功能变化更新 `README.md`；核心逻辑变化更新 `md/flow/flow.md`、必要时更新 `md/flow/flowchart.md`；测试流程变化更新 `md/test/test.md`。
6. 输出改动、关键文件、测试命令和结果、未验证原因、风险和后续建议。

### Agent C：验收与核心逻辑更新

Agent C 负责验收 Agent B 的结果并维护核心逻辑文档。

必须执行：

1. 阅读 Agent B 输出、实际 diff、必读文档和相关源码。
2. 核对实现是否满足人工目标和 Agent A 提示词。
3. 检查架构边界、测试充分性、文档同步和未说明风险。
4. 基于已完成实现更新 `md/flow/flow.md` 和 `md/flow/flowchart.md`。
5. 形成正式版本或重要历史事项时更新 `update_log.md`。
6. 输出通过/不通过、问题清单、已更新文档、建议下一步。

## 6. 测试规则

- 每次实现前先读 `md/test/test.md`。
- 默认从最小测试开始，根据改动范围扩大到 Smoke、Stage Regression 或 Full。
- 改 Swift 代码最低验证是 generic iOS device build。
- UI、HUD、触摸交互改动在构建成功之外，能启动模拟器时还要做交互检查。
- 不得伪造测试结果，不得用“已验证”替代具体命令和结果。
- 环境问题必须明确写出，例如 CoreSimulatorService 不可用。

## 7. 文档规则

- `README.md` 是当前玩家可见功能事实清单，不写半成品，不夸大。
- `update_log.md` 记录正式版本、重要维护事项、关键决策和遗留问题，不写成流水账。
- `md/flow/flow.md` 只写当前真实架构和流程，不堆历史。
- `md/flow/flowchart.md` 必须与 `flow.md` 同步，图前要有中文读图说明。
- `md/test/test.md` 保存测试规范；新增或调整测试方式必须同步更新。
- `md/prompt/` 只保存 Agent A 给 Agent B 的版本化实现提示词。

## 8. 交付格式

最终回复优先使用：

```text
已完成：...
修改文件：...
验证：...
注意：...
```

如果是 Agent C 验收，使用：

```text
验收结论：通过/不通过
问题清单：...
已更新文档：...
验证复核：...
下一步建议：...
```

## 9. 禁止项

- 禁止不读文档直接改代码。
- 禁止擅自扩大目标范围或顺手重构大文件。
- 禁止绕过 `GameScene.swift` 现有状态流另建平行玩法系统。
- 禁止把半成品写进 `README.md` 的 Current Features。
- 禁止删除或覆盖用户未要求删除的改动。
- 禁止伪造测试、隐藏失败命令、把环境失败说成源码失败。
- 禁止新增外部依赖或素材，除非人工明确要求或先说明收益与风险。
