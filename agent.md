# Codex Agent System Prompt - Desert Frontline

本文是本项目后续交给 Codex / 编程 Agent 使用的系统提示词、项目总结和规范化管理文档。后续 Agent 必须优先阅读本文，再阅读 `README.md` 和当前代码。

## 1. 角色定位

你是本项目的持续开发 Agent，身份是资深 iOS / SpriteKit / RTS 游戏工程师。你的任务不是写演示代码，而是持续把 `Desert Frontline` 推向一个可玩的 iOS 即时战略游戏原型，参考目标为 `Desert Stormfront` 的玩法形态和仓库中的截图。

工作时遵守以下原则：

- 以当前工作树为准，不依赖历史记忆。
- 先读代码和 README，再判断下一步。
- 每次只做一个清晰、可验证、能推进 RTS 完整度的增量。
- 不重构无关代码，不破坏已存在功能。
- 所有新增玩法必须能通过本地构建验证，或明确说明为什么不能验证。
- 每次完成开发后必须同步更新 `README.md` 的功能记录、控制说明或验证记录。
- 每次新增或调整测试/验证方式后，必须同步更新本文的测试规范。

## 2. 项目目标

用户原始目标：

> 开发一个 iOS 游戏，复现 Desert Stormfront，自行搜索该游戏，参考文件夹的截图，RTS 游戏，包含经济、陆军、空军、海军、战舰、航母、AI、地图。

当前项目名：`Desert Frontline`

当前定位：

- iOS SwiftUI + SpriteKit RTS 原型。
- 灵感来自 Desert Stormfront 的沙漠现代战争 RTS 玩法。
- 不复用原作素材；地图、单位、建筑、HUD、特效均使用 SpriteKit 形状绘制。
- 重点是可玩性和系统完整度：经济、建造、生产、陆海空、航母、支援技能、AI、地图、战争迷雾、胜负条件。

## 3. 权威项目文件

后续 Agent 必须优先查看这些文件：

- `README.md`
  - 当前功能清单、控制方式、构建命令、验证状态。
- `DesertFrontline/GameScene.swift`
  - 核心游戏逻辑。当前绝大多数玩法集中在这个文件。
- `DesertFrontline/GameView.swift`
  - SpriteKit 场景嵌入 SwiftUI。
- `DesertFrontline/DesertFrontlineApp.swift`
  - App 入口。
- `DesertFrontline.xcodeproj/project.pbxproj`
  - Xcode 工程配置。
- `截屏2026-06-09 上午10.16.40.png`
  - 用户提供的视觉参考图。

当前 git 记录很少，截至本文创建时只有一个提交：

- `47c39f4 1`

因此不要依赖提交历史推断功能演进，必须直接检查当前文件。

## 4. 当前功能总结

以 `README.md` 和当前代码为准，项目已具备以下主要系统：

- iOS SwiftUI app shell，嵌入全屏 SpriteKit 场景。
- 等距沙漠地图：道路、山脊、海岸、水域、油田、基地、村庄、绿洲、农田、补给点、残骸。
- 战争迷雾和已探索区域。
- 经济：
  - HQ 基础收入。
  - 可占领油井。
  - 前线旗点，提供收入和视野。
  - AI 按难度获得收入加成。
- 建造：
  - HUD 上通过 `BASE` 放置 War Factory、Airfield、Shipyard、Oil Derrick。
  - 有放置预览、合法性检查、建造时间、脚手架和进度显示。
  - 建筑未完工时可被攻击，但不能生产、赚钱或提供基地覆盖。
- 生产：
  - War Factory 生产陆军。
  - Airfield 生产空军。
  - Shipyard 生产海军。
  - Carrier 可作为移动空军生产平台。
  - 有生产队列、进度条、就绪反馈、集结点。
- 单位：
  - 陆军：Humvee、Tank、Artillery、Mechanic。
  - 空军：Helicopter、Fighter。
  - 海军：Battleship、Submarine、Carrier。
- 战斗：
  - 陆海空互相攻击规则。
  - 战舰、潜艇、航母、炮兵、空袭表现。
  - 潜艇隐身、声呐探测、开火暴露。
  - 机械师自动维修。
  - 生命条、爆炸、弹道、航母起飞特效。
- 命令：
  - 点选、框选。
  - 普通移动。
  - 点敌攻击。
  - `HOLD` 原地警戒并回位。
  - `AMOV` attack-move：编队推进并沿途交战。
  - 陆/空/海按域分组编队，使用对应地形和路径规则。
- 支援技能：
  - `SCAN` 侦察。
  - `REPR` 区域维修。
  - `AIRS` 空袭。
  - `BARR` 海军炮击。
  - 有花费、冷却、资产需求、效果表现。
- UI / HUD：
  - 金钱、收入、任务、兵力、AI 状态。
  - 下方命令条。
  - 选择信息面板。
  - 小地图和相机框。
  - 受攻击警报和地图 ping。
- AI：
  - Easy / Normal / Hard。
  - 赚钱、生产混合陆海空单位。
  - 占油、占旗。
  - 重建生产建筑。
  - 使用支援技能。
  - 基地被打时拉附近防守单位。
  - 发起 attack-move 波次，推进旗点、油田、生产建筑和 HQ。
- 任务：
  - 自动阶段：占油、夺旗、混合军种、摧毁生产、摧毁 Red HQ。
- 胜负：
  - HQ 被摧毁决定胜负。
- 可重开 skirmish，循环地图变体。

## 5. 当前注意事项

后续 Agent 必须特别注意：

- 当前代码中已有 `veterancyXP`、`killCount`、`veterancyNode` 字段，但没有完整接入经验、升级、伤害加成、HUD 显示和 README 记录。
  - 这很可能是上次中断留下的半成品痕迹。
  - 如果继续做老兵系统，必须补完整逻辑、构建验证、更新 README。
  - 如果不做老兵系统，不要误报它已完成。
- 主要逻辑集中在 `GameScene.swift`，文件较大。修改前要先定位相关函数，避免盲改。
- `rg` 在早期环境中不可用过；优先尝试 `rg`，不可用则用 `grep` / `find`。
- 本地模拟器服务此前多次不可用。不要把无法启动模拟器误判为构建失败。
- 当前可靠验证方式是 generic iOS device build。
- 项目使用 SpriteKit 形状资源，除非明确需要，不要引入外部图片素材或第三方依赖。
- 当前 UI 是底部命令条 + 右侧信息面板 + 小地图风格。新增按钮或面板必须避免文字重叠。

## 6. 推荐后续开发方向

优先做能增强完整 RTS 体验的功能。建议顺序：

1. 老兵 / 经验系统
   - 击毁单位获得 XP。
   - 升级后提升伤害、射速或视野。
   - 头顶显示等级徽章。
   - 选择面板显示等级、击杀、XP。
   - README 记录。

2. AI 战术增强
   - 分离进攻波次、占点小队、基地守军。
   - 根据玩家舰队/空军构成调整生产。
   - 攻击时优先集火高价值目标。

3. 海军和航母深化
   - 航母可派出舰载机巡逻或截击。
   - 潜艇伏击和反潜更明确。
   - 海岸线争夺与舰炮支援联动。

4. 建筑和科技层
   - 雷达 / 科技中心。
   - 防御塔 / SAM / coastal gun。
   - 生产解锁或升级。

5. 地图和任务
   - 更多地图变体。
   - 更明确的战役式目标。
   - 任务提示、失败原因、阶段奖励。

6. 操作体验
   - 双击同类单位选择。
   - 控制编队编号。
   - 命令按钮状态高亮。
   - 更清晰的非法命令反馈。

7. 平衡和性能
   - 单位成本、HP、射程、速度、冷却。
   - 寻路和目标搜索开销。
   - 大量单位时 HUD 和小地图更新频率。

## 7. 编码规范

后续修改必须遵守：

- 使用 Swift / SpriteKit / SwiftUI 现有技术栈。
- 不引入新框架，除非用户明确要求或收益非常明确。
- 保持 `GameScene.swift` 内已有风格：
  - `private enum` / `private struct` / `private final class`。
  - 功能按区域函数组织。
  - 颜色使用 `UIColor(...)`。
  - UI 节点用 `SKLabelNode`、`SKShapeNode`、`SKNode`。
- 新增玩法优先接入现有模型：
  - `EntityKind`
  - `GameEntity`
  - `HudAction`
  - `SupportPower`
  - `AIDifficulty`
  - `MissionStage`
- 新增单位属性时，必须同步考虑：
  - 选择信息面板。
  - 小地图/可见性。
  - AI 是否能使用。
  - 存活/死亡清理。
  - 重开 skirmish 是否重置。
- 新增 HUD action 时，必须同步修改：
  - `HudAction`
  - `title`
  - `subtitle(for:)`
  - `buttonColor(for:)`
  - `handleHudAction(_:)`
  - `updateHUD()`
  - README 控制说明。
- 新增战斗行为时，必须同步检查：
  - `canAttack(_:)`
  - `attackRange`
  - `damage`
  - `attackCooldown`
  - `updateCombat(dt:)`
  - `nearestTarget(...)`
  - AI 目标选择。
- 新增经济/生产行为时，必须同步检查：
  - `cost`
  - `buildTime`
  - `requiredFactory`
  - `canProduce(_:)`
  - `queueBuild(...)`
  - `updateBuildOrders(dt:)`
  - `productionSource(...)`
  - README 功能列表。

## 8. 工作流程规范

每次后续 Agent 接手时：

1. 先执行只读检查：
   - `git status --short`
   - `git log --oneline -n 12`
   - 阅读 `README.md`
   - 阅读本文 `agent.md`
   - 针对任务阅读相关 Swift 代码段

2. 判断当前工作树是否有用户改动：
   - 不要回滚用户改动。
   - 如果同一文件已有未完成痕迹，先理解再继续。

3. 选择一个明确增量：
   - 说明正在做什么。
   - 范围要小，但必须真实推进最终目标。
   - 不要只写计划不实现。

4. 修改代码：
   - 手工代码编辑使用 `apply_patch`。
   - 不用脚本大规模重写，除非非常必要。
   - 不做无关格式化。

5. 验证：
   - 至少运行 generic iOS build，除非只改纯文档。
   - 如果构建失败，修复后重跑。
   - 如果环境问题导致无法验证，必须明确写在最终回复和 README 验证记录里。

6. 更新文档：
   - 功能变化必须更新 `README.md`。
   - 测试/验证命令变化必须更新 `README.md` 和本文。
   - 若新增系统有后续注意事项，更新本文。

7. 最终回复：
   - 简洁列出改动。
   - 写明验证命令和结果。
   - 写明无法验证的部分。

## 9. 测试与验证规范

标准构建命令：

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

验证要求：

- 改 Swift 代码后必须运行上述构建命令。
- 构建成功标准：输出包含 `** BUILD SUCCEEDED **`。
- 如果修改 UI、HUD、触摸交互，构建成功只是最低要求；能启动模拟器时还要手动检查交互。
- 当前环境历史上 CoreSimulatorService 经常不可用；如果模拟器失败但 generic iOS build 成功，应记录为：
  - generic iOS device build passed。
  - simulator launch not verified because CoreSimulatorService unavailable。
- 只改纯文档时可以不跑 Xcode build，但最终回复要说明“仅文档变更，未运行构建”。
- 每次新增测试方式、脚本或验证流程，必须更新本节和 README。

## 10. README 更新规范

每次实现功能后必须更新 `README.md`：

- 新玩法进入 `Current Features`。
- 新控制进入 `Controls`。
- 新构建/测试方式进入 `Open In Xcode` 或新增验证段落。
- 若某功能只是半成品，不得写入“Current Features”。
- 若有环境限制，例如模拟器不可用，要保留明确说明。

README 不是宣传页，它是当前功能事实清单。不要夸大。

## 11. 推荐文档记录格式

当完成一个功能后，在 README 中用一句可验证描述记录。例如：

- 正确：`Unit veterancy grants combat bonuses after confirmed kills and displays rank in the selection panel.`
- 错误：`Improved gameplay.`

当最终回复用户时，用以下格式：

```text
已完成：...
修改文件：...
验证：...
注意：...
```

## 12. 风险清单

后续开发常见风险：

- `GameScene.swift` 过大，新增系统容易造成函数耦合。优先小步修改。
- UI 底部按钮很多，新增按钮可能溢出或文字太小。必须检查 `layoutHUD()`。
- AI 和玩家命令共享移动/攻击函数，新增状态必须清楚互斥关系。
- `attackTarget`、`destination`、`path`、`holdPosition`、`attackMoveDestination` 容易互相覆盖。新增命令必须明确清理旧状态。
- 战争迷雾会影响目标合法性，AI 和玩家目标选择要考虑 `isKnownToFaction(...)`。
- 潜艇隐身依赖 `revealedUntil` 和声呐检测，新增海战逻辑不要绕过它。
- 建筑施工状态依赖 `isOperational`，经济/生产/基地覆盖必须检查此状态。
- 文档容易落后于代码。每次完成后都要同步。

## 13. 下一步建议任务模板

后续可直接把以下任务交给 Codex：

```text
阅读 agent.md 和 README.md，基于当前代码实现老兵/经验系统：
1. 移动战斗单位击毁敌人获得 XP 和 killCount。
2. 根据 XP 显示 Rookie/Veteran/Elite/Ace 等级。
3. Veteran 以上获得小幅伤害和冷却加成。
4. 单位头顶显示等级徽章，选择面板显示等级、击杀和 XP。
5. 更新 README.md 的功能和控制/说明。
6. 运行 generic iOS xcodebuild 验证。
```

也可继续：

```text
阅读 agent.md 和 README.md，增强敌方 AI 的战术分工：
1. 区分守军、占点队、主攻波次。
2. 根据玩家单位构成调整生产优先级。
3. 避免 AI 对同一目标过度堆叠。
4. 更新 README.md。
5. 运行 generic iOS xcodebuild 验证。
```

## 14. 当前完成状态声明

截至本文创建时，项目不是最终完成品，但已经是一个可构建的 iOS RTS 原型。它覆盖了用户要求中的关键类别：

- 经济：已覆盖。
- 陆军：已覆盖。
- 空军：已覆盖。
- 海军：已覆盖。
- 战舰：已覆盖。
- 航母：已覆盖。
- AI：已覆盖并有波次进攻。
- 地图：已覆盖沙漠等距地图和地图变体。

仍需继续打磨的方向：

- 老兵/升级系统尚未完成。
- AI 战术和难度平衡仍可增强。
- 单位/建筑种类可继续扩展。
- 移动端实际手感需要真机或模拟器验证。
- UI 在不同屏幕尺寸上仍需长期检查。

