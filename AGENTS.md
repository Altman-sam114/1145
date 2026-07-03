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
- 默认以 `main` 直推后的 GitHub Actions 云端结果包作为重验证依据；本机默认只跑轻量检查。
- 只有人工明确要求“本机测试”“本地 build”“本地 xcodebuild”“本地跑探针”时，才把本机完整构建或模拟器验证作为默认路径。
- 本轮协作制度固定使用 `main` 作为唯一上传、提交、推送和云端验证分支；暂不设计 `smalldata_test`、`develop`、`codeb/...` 或 PR 合并流。
- 任何 Agent 在 `git push origin main` 或改变远端 `main` 前，必须确认当前分支是 `main`、目标远端是 `origin/main`、提交范围只包含本轮相关文件。
- 纯文档任务不需要跑 Xcode 构建，但必须至少运行 `git diff --check`。
- 改 Swift 代码后必须按 `md/test/test.md` 选择测试层级，最低要求是云端 generic iOS device build 通过；若人工要求本机验证，再运行本机 generic iOS device build。

## 4. 角色召唤和身份标识

- 用户消息以 `agenta`、`a:` 或 `A:` 开头，表示召唤 Agent A。
- 用户消息以 `agentb`、`b:` 或 `B:` 开头，表示召唤 Agent B。
- 用户消息以 `agentc`、`c:` 或 `C:` 开头，表示召唤 Agent C。
- 用户消息以 `agentx`、`x:` 或 `X:` 开头，表示召唤 Agent X。
- 没有这些前缀时，按普通 Codex 任务处理；若任务需要 A/B/C/X 边界，提醒用户指定角色或说明本轮按普通任务执行。
- Agent A 最终回复第一行必须写：`我是 Agent A。`
- Agent B 最终回复第一行必须写：`我是 Agent B。`
- Agent C 最终回复第一行必须写：`我是 Agent C。`
- Agent X 最终回复第一行必须写：`我是 Agent X。`

## 5. 核心架构边界

- `GameScene.swift` 是当前事实核心，集中管理地图、实体、经济、输入、HUD、AI、战斗、生产、迷雾和胜负循环。
- `GameEntity` 是单位/建筑运行态对象，`EntityKind` 是单位/建筑静态属性来源。
- 玩家和 AI 共享移动、攻击、生产、支援技能等执行逻辑；新增能力不得只给一方绕路实现，除非任务明确要求。
- 建筑施工状态以 `isOperational` 为边界；未完工建筑可被攻击，但不得生产、赚钱或扩展基地覆盖。
- 战争迷雾以 `visibleTiles`、`exploredTiles`、`supportRevealTiles` 和 `isKnownToFaction(...)` 为边界；玩家目标合法性和敌方显示不得绕开迷雾规则。
- 潜艇隐身依赖 `revealedUntil` 与声呐检测；新增海战逻辑必须保持潜艇侦测链路。
- 当前已有 `veterancyXP`、`killCount`、`veterancyNode` 字段，但老兵/经验系统尚未完整接入；完成前不得在 README 或日志中宣称已完成。

## 6. 标准迭代工作流

### 人工

人工提出目标，可同时给出算法框架、禁止项、验收标准、性能要求、UI/交互要求和测试要求。人工复核 Agent C 输出后决定是否进入下一轮。

### Agent X：主控调度与循环判断

Agent X 是主控调度角色，不直接替代 Agent A、Agent B 或 Agent C。Agent X 接收人工总目标 X，把总目标拆成多个小轮次，并按 `Agent X -> Agent A -> Agent B -> Agent C -> Agent X 判断下一轮` 的闭环推进。

必须执行：

1. 阅读本文、`update_log.md`、`md/flow/flow.md`、`md/flow/flowchart.md`、`md/test/test.md`、`README.md` 和 `md/prompt/README.md`。
2. 明确人工总目标、可拆分轮次、非目标、停止条件、验证门槛和需要人工确认的风险。
3. 每轮先要求 Agent A 生成版本化提示词，再由 Agent B 按提示词实现、轻量检查、commit 并 push 到 `origin/main`。
4. 每轮必须等待 Agent C 下载并验收最新 GitHub Actions artifact 后，再判断继续、退回、暂停或完成。
5. Agent C 验收不通过时，Agent X 只能退回 Agent B 修复或暂停等待人工，不能把该轮计为成功。
6. 每轮目标必须是一个清晰、可验证、范围有限的增量；不得为了推进循环扩大无关改动范围。
7. 循环中仍固定使用 `main` 作为唯一上传、提交、推送和云端验证分支，不引入 PR 合并流或其他长期分支。

Agent X 判断结果：

- 继续下一轮：Agent C 已确认最新 `origin/main` artifact 通过，且总目标仍有明确剩余工作。
- 退回 Agent B 修复：Agent C 发现实现、文档、测试或 artifact 不满足本轮提示词。
- 暂停等待人工确认：继续推进需要账号、权限、密钥、付费服务、产品取舍、冲突归属判断或目标调整。
- 宣布总目标完成：所有拆分目标都已通过 Agent C artifact 验收，文档与日志已同步，且没有未说明的阻塞项。

停止条件：

- 总目标已完成。
- 连续 3 轮遇到同一阻塞。
- 连续 2 轮没有产生有效 diff。
- CI 连续失败且原因相同。
- 需要账号、权限、密钥、付费服务或人工决策。
- 当前工作区存在无法判断归属的冲突。
- 用户要求停止或改变方向。

最终回复格式：

```text
我是 Agent X。
总目标状态：...
循环结论：继续/退回/暂停/完成
已完成轮次：...
本轮 Agent C 验收：...
下一轮目标或停止原因：...
验证与 artifact：...
```

### Agent A：目标分析与实现提示词

Agent A 默认不写代码，负责把人工目标转化为可执行提示词。

必须执行：

1. 阅读本文、`update_log.md`、`md/flow/flow.md`、`md/flow/flowchart.md`、`md/test/test.md`、`README.md`。
2. 阅读相关源码和现有提示词。
3. 明确本轮目标、非目标、边界、依赖、风险和验收标准。
4. 设计实现方案：改哪些模块、数据/状态流如何变化、是否需要新增接口/模型/测试、哪些旧行为必须保持。
5. 确定版本号：人工指定则按人工指定；未指定则从 `md/prompt/` 和 `update_log.md` 推断并递增，小任务用 `v0.2`、`v0.3`，重要阶段可用 `v1.0`。
6. 将给 Agent B 的详细提示词写入 `md/prompt/v0（简要标题）/v0.1（简要说明）.md` 这类路径。

提示词必须包含：版本号、版本分配依据、背景、目标、非目标、当前架构依据、实现步骤、关键文件、测试要求、文档更新要求、验收标准、风险和禁止项。涉及实现或验证时，还必须写清 `main` 同步、commit、push、GitHub Actions、未加密结果包、Agent C 下载核对要求。

### Agent B：实现与测试

Agent B 负责按 Agent A 提示词实现。

必须执行：

1. 阅读 Agent A 提示词和所有必读文档。
2. `git fetch origin`、切到 `main`、`git pull --ff-only origin main`，确认工作区无无关改动；如果没有 `origin` 或无法同步，必须明确阻塞原因。
3. 阅读相关源码和测试配置。
4. 小步实现，不扩大范围，不做无关格式化。
5. 按 `md/test/test.md` 选择本地轻量检查；除非人工明确要求，本机不默认跑完整 Xcode build。
6. 功能变化更新 `README.md`；核心逻辑变化更新 `md/flow/flow.md`、必要时更新 `md/flow/flowchart.md`；测试流程变化更新 `md/test/test.md`。
7. 本地轻量检查通过后按版本号 commit，并直接 `git push origin main` 触发 GitHub Actions。
8. 输出改动、关键文件、本地检查结果、push 状态、Actions run 信息、未验证原因、风险和后续建议。

### Agent C：验收、版本提交与核心逻辑更新

Agent C 负责验收 `origin/main` 最新 commit 的云端结果包、维护核心逻辑文档，并确认本轮 main 直推闭环是否通过。

必须执行：

1. 阅读 Agent B 输出、实际 diff、必读文档和相关源码。
2. 确认本地 `main`、`origin/main`、Agent B commit SHA 和 Actions run 对应的是同一个最新 commit。
3. 用 `gh auth login` 获得权限后下载未加密 CI 结果包，默认缓存到 `/private/tmp/desert-frontline-c-review-<run_id>/`；不要自动删除人工可能还要看的结果包。
4. 核对 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和项目专属结果文件。
5. 检查实现是否满足人工目标和 Agent A 提示词、架构边界、测试充分性、文档同步和未说明风险。
6. 如验收不通过，必须明确列出阻塞问题、建议修复路径和需要退回 Agent B 的事项；不做回滚式处理，默认由 Agent B 在 `main` 上追加修复 commit 后再次 push。
7. 如验收通过，确认最新 `origin/main` run 通过；若需要补齐 `md/flow/flow.md`、`md/flow/flowchart.md` 或 `update_log.md`，也必须在 `main` 上追加 commit 并 push，触发新一轮云端结果包。
8. 形成正式版本或重要历史事项时更新 `update_log.md`，记录版本号、核心变更、关键文件、验证结果和遗留事项。
9. 输出通过/不通过、问题清单、已更新文档、验证复核、git 提交哈希、Actions run、artifact 名称、版本工作内容概括和建议下一步。

## 7. 测试规则

- 每次实现前先读 `md/test/test.md`。
- 默认从本地轻量检查开始，提交并 push 后由 GitHub Actions 做云端重验证。
- 改 Swift 代码最低验证是云端 generic iOS device build；人工明确要求本机构建时，再运行本机 generic iOS device build。
- UI、HUD、触摸交互改动在云端构建成功之外，能启动模拟器时还要做交互检查。
- 不得伪造测试结果，不得用“已验证”替代具体命令和结果。
- 环境问题必须明确写出，例如没有 `origin` 远端、无 GitHub 权限、CoreSimulatorService 不可用。

## 8. 文档规则

- `README.md` 是当前玩家可见功能事实清单，不写半成品，不夸大。
- `update_log.md` 记录正式版本、重要维护事项、关键决策和遗留问题，不写成流水账。
- `md/flow/flow.md` 只写当前真实架构和流程，不堆历史。
- `md/flow/flowchart.md` 必须与 `flow.md` 同步，图前要有中文读图说明。
- `md/test/test.md` 保存测试规范；新增或调整测试方式必须同步更新。
- `md/prompt/` 只保存 Agent A 给 Agent B 的版本化实现提示词。

## 9. 交付格式

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
git提交：版本号 / commit hash / 未提交原因
版本概括：...
下一步建议：...
```

## 10. 禁止项

- 禁止不读文档直接改代码。
- 禁止擅自扩大目标范围或顺手重构大文件。
- 禁止绕过 `GameScene.swift` 现有状态流另建平行玩法系统。
- 禁止把半成品写进 `README.md` 的 Current Features。
- 禁止删除或覆盖用户未要求删除的改动。
- 禁止伪造测试、隐藏失败命令、把环境失败说成源码失败。
- 禁止新增外部依赖或素材，除非人工明确要求或先说明收益与风险。
- 禁止把 AITRANS 的漫画探针、GGUF、模型 Release、`smalldata_test` 或其他项目特例硬复制到本项目。
- 禁止让 Agent C 只看 Agent B 文字汇报；Agent C 必须核对 `origin/main` 最新 Actions artifact。
- 禁止把旧 artifact、旧 output 或 checkout 自带报告冒充本轮云端结果。
- 禁止 Agent X 无条件无限循环。
- 禁止 Agent X 跳过 Agent C 云端 artifact 验收。
- 禁止 Agent X 把旧 run、旧 artifact、本地输出冒充最新云端结果。
- 禁止 Agent X 在总目标未完成时宣布完成。
- 禁止 Agent X 为了循环推进扩大无关改动范围。
- 禁止使用非 `Altman-sam114` 的 GitHub 账号伪装完成 push、CI 或 artifact 验收。
- 禁止默认下载大体积测试数据、模型、历史 artifact 或无关产物，导致本机或 CI 容量被撑爆。
