# 项目核心流程文档

`Desert Frontline` 当前核心链路是：SwiftUI 全屏承载 SpriteKit 场景，`GameScene` 在单个实时循环中驱动地图、实体、玩家输入、经济、生产、战斗、AI、战争迷雾、HUD 和胜负状态。

## 1. 当前核心数据流

```text
触摸输入 / HUD 按钮 / AI 计时器
  -> GameScene 状态字段
  -> GameEntity / EntityKind / VeterancyRank / BuildOrder / ControlPoint / SupportPower
  -> 移动、生产、经济、战斗、占领、迷雾、任务、胜负规则
  -> SKNode / SKShapeNode / SKLabelNode 渲染
  -> README、测试规范、更新日志记录当前事实
```

协作验证数据流：

```text
人工单轮目标 / Agent X 总目标
  -> Agent X（可选）拆分轮次目标并调度 Agent A/B/C
  -> Agent A 生成版本化提示词
  -> Agent B 在 main 上实现、本地轻量检查、commit、push origin/main
  -> GitHub Actions 云端 build / 静态检查
  -> 未加密 CI 结果包
  -> Agent C 下载并核对 manifest / JUnit / xcodebuild.log / failure summary
  -> Agent X 或人工根据验收结果判断继续、退回、暂停或完成
```

## 2. 当前核心执行流

1. `DesertFrontlineApp` 创建 `GameView`。
2. `GameView` 用 `SpriteView` 挂载 `SceneHolder.scene`。
3. `SceneHolder` 创建固定尺寸 `GameScene(size: 1366x1024)`，`scaleMode = .aspectFill`。
4. `GameScene.didMove(to:)` 初始化 world、map、entity、effect、fog、HUD、camera 节点。
5. 初始化流程依次构建地形、绘制地图、生成控制点、生成初始单位/建筑、布局 HUD、刷新迷雾、刷新 HUD。
6. `GameScene.update(_:)` 每帧推进施工、生产、支援冷却、经济、占领、维修、移动、战斗、AI、迷雾、死亡清理、任务进度、胜负和 HUD。
7. 触摸事件在 `touchesBegan/Moved/Ended` 中分流到 HUD、迷你地图、双指平移缩放、框选、建筑预览、支援技能目标、集结点、attack-move、选中、移动和攻击。

## 3. 核心状态对象 / 模块

### `EntityKind`

单位和建筑的静态定义来源：名称、短码、域、成本、建造时间、HP、速度、射程、伤害、冷却、视野、占地、生产来源、可生产项、可攻击目标。当前建筑包含 HQ、War Factory、Airfield、Radar Outpost、Guard Tower、SAM Site、Coastal Battery、Shipyard 和 Oil Derrick；Radar Outpost 是普通陆地结构，完工后提供较大静态视野并可作为 `SCAN` 资产；Guard Tower 是普通陆地防御结构，完工后自动攻击可见 land / air / structure 目标，不攻击 naval / submarine，也不提供声呐；SAM Site 是普通陆地防空结构，完工后只攻击可见 air 目标，不攻击 land / naval / submarine / structure，也不提供声呐；Coastal Battery 是海岸防御结构，完工后只攻击可见水面海军目标，不攻击潜艇，也不提供声呐。AA Truck 是 War Factory 生产的移动陆地防空单位，只攻击可见 air 目标，不攻击 land / naval / submarine / structure，也不提供声呐。

### `GameEntity`

运行态实体：id、kind、faction、hp、destination、path、attackTarget、holdPosition、attackMoveDestination、attackTimer、revealedUntil、captureProgress、施工进度、rallyPoint、`veterancyXP`、`killCount` 和各类 SpriteKit 节点。

`veterancyRank` 由 XP 计算得到，不保存第二份等级状态；`veterancyNode` 作为实体节点子节点显示非 Recruit 单位的老兵徽章，并随实体迷雾隐藏。

### `BuildOrder`

生产队列项：产品、阵营、来源建筑/航母、总时长、剩余时间。`updateBuildOrders(dt:)` 完成出兵，`productionSource(...)` 决定来源。

### `BattlefieldControlPoint`

前线旗点状态：阵营、占领进度、占领方和对应节点。已占领旗点提供收入、视野和有限建造覆盖，并影响任务阶段。

### `SupportPower`

支援技能定义：侦察、区域维修、空袭、海军炮击。包含成本、冷却、半径、伤害/维修量和资产需求。`SCAN` 需要 operational HQ 或 Radar Outpost；未完工 Radar Outpost 不满足资产需求。

### `HudAction`

底部命令条动作：选军、`G1` / `G2` 控制组保存与召回、hold、attack-move、生产、集结点、基地建造、支援技能、AI 难度、HQ 聚焦、重开 skirmish。

### `AIDifficulty`

AI 参数：指挥间隔、收入加成、每轮建造数、进攻组规模、支援技能消费保留和支援阈值。

### `MissionStage`

自动任务阶段：占油、夺旗、混合军种、摧毁 Red 生产、摧毁 Red HQ。

## 4. 关键运行流程

### 输入与命令

- HUD 点击先于世界点击处理。
- 双指触摸进入相机平移/缩放。
- 单指拖动可框选玩家移动单位。
- 建筑放置、支援技能、集结点和 attack-move 都是 pending 模式；进入新模式时必须清理冲突模式。
- `BASE`、`RLY`、`AMOV` 和支援技能按钮的高亮由 `pendingConstructionKind`、`isSettingRallyPoint`、`isSettingAttackMove`、`pendingSupportPower` 直接推导，只提供等待地图目标的视觉反馈，不改变 pending 优先级或命令语义。
- HUD 单击 `G1` / `G2` 会召回对应控制组中仍存活的玩家机动单位，并过滤死亡、移除、结构或非玩家 ID；HUD 双击 `G1` / `G2` 会把当前玩家机动单位选择保存到对应组，空选择不会覆盖旧组。
- 使用控制组会清理 pending 建筑、支援技能、集结点、attack-move 和 construction preview；召回空组不会清空当前选择；`SKRM` 重开会清空两个控制组。
- 世界点击优先处理 pending 支援、pending 建筑、pending 集结点、pending attack-move，然后才处理选中、攻击或移动。
- pending 建筑、支援、集结点、attack-move 和普通攻击 / 空地命令的无效世界目标会通过 `showDeniedMarker(at:reason:)` 在点击位置显示短暂红橙拒绝标记；该反馈只补充 `showMessage(...)`，不改变合法性、pending 清理、迷雾边界或执行优先级。
- 普通世界点击中，双击玩家己方机动单位会选择当前摄像机视野内同 `kind` 的己方存活机动单位；建筑、敌方、中立和屏幕外同类不纳入该选择。

### 经济与生产

- HQ、已占领油井、已占领旗点提供收入。
- 建筑覆盖由己方已完工结构和己方已占领旗点提供；旗点覆盖范围小于结构覆盖范围。玩家建造仍需要目标位置可见，SAM Site 走普通陆地结构规则，Shipyard 和 Coastal Battery 仍需要海岸，Oil Derrick 仍需要油田，建筑不能压住旗点中心。
- 建筑只有 `isOperational` 后才能生产、赚钱、提供基地覆盖、贡献视野、提供支援技能资产或使用自身武器。
- 陆军来自 War Factory，AA Truck 作为移动防空陆军也来自 War Factory；空军来自 Airfield 或 Carrier，海军来自 Shipyard。
- Carrier 是移动空军生产平台，可生产 Helicopter/Fighter 并使用空军集结点。

### 移动与战斗

- 陆、空、海按 `Domain` 使用不同移动和地形规则；空军直飞，陆海需要路径点。
- 普通移动会清理攻击/hold/attack-move 意图。
- `HOLD` 记录 `holdPosition`，单位会在警戒半径内交战并回位。
- `AMOV` 记录 `attackMoveDestination`，编队推进并沿途寻找可见敌人。
- `updateCombat(dt:)` 会先跳过并清理未完工攻击型结构的攻击目标和计时器；完工结构与移动单位再选择目标、用老兵等级计算有效冷却并调用 `fire(attacker:target:)`。
- Guard Tower 共享 `canAttack(_:)`、目标搜索、迷雾合法性和 `fire(attacker:target:)` 链路，只攻击 land / air / structure，不攻击 naval / submarine。
- SAM Site 共享 `canAttack(_:)`、目标搜索、迷雾合法性和 `fire(attacker:target:)` 链路，只攻击可见 air 目标，不攻击 land / naval / submarine / structure，也不提供 sonar。
- Coastal Battery 共享 `canAttack(_:)`、目标搜索、迷雾合法性和 `fire(attacker:target:)` 链路，只攻击可见水面海军目标，不攻击潜艇，不提供 sonar，也不触发潜艇暴露。
- AA Truck 共享移动单位 `canAttack(_:)`、目标搜索、迷雾合法性和 `fire(attacker:target:)` 链路，只攻击可见 air 目标，不攻击 land / naval / submarine / structure，也不提供 sonar。
- `fire(attacker:target:)` 使用有效伤害结算直接开火；击杀发生时为可移动作战单位增加 `killCount` 和 XP，XP 推动 Recruit / Hardened / Veteran / Elite 等级，并更新头顶徽章。
- 支援技能伤害仍走 `applySupportDamage(...)`，没有虚拟击杀者，因此不会把支援技能击杀计入任何单位 XP；`AIRS` / `BARR` 真实命中潜艇时会短暂设置该潜艇的 `revealedUntil`。

### 迷雾与隐身

- 玩家可见性由单位、已完工建筑有效视野、控制点视野和支援侦察共同决定；Radar Outpost 完工后提供较大静态侦察范围，Guard Tower、SAM Site 和 Coastal Battery 完工后提供普通防御建筑视野，Veteran 和 Elite 单位会在基础视野上获得轻量加成。
- 敌方实体只有满足 `isKnownToFaction(..., observer: .player)` 时才应被玩家看见或成为合法交互目标。
- 潜艇依赖 `revealedUntil` 和声呐单位检测；开火会暴露，伤害型支援技能真实命中潜艇时也会短暂暴露。`SCAN` 仍使用 8 秒区域侦察暴露潜艇，未命中的 `AIRS` / `BARR` 不暴露潜艇。

### AI

- AI 按 `AIDifficulty` 周期执行。
- AI 会赚钱、补生产建筑、Radar Outpost、Guard Tower、SAM Site 和 Coastal Battery、生产含 AA Truck 的混合陆海空单位、占油/旗、重建、使用支援技能、基地被打时拉防守单位。
- AI 常规生产按难度 build pattern 轮转；每个生产槽从 `aiBuildCursor` 开始扫描当前有 operational 生产来源且资金足够的单位，跳过暂时缺 War Factory / Airfield / Shipyard / Carrier 或资金不足的项，成功后仍通过 `queueBuild` / `productionSource` 排队，未完工建筑不能生产。
- AI 占点分配只使用当前空闲陆地单位；同一轮被派去油井的 runner 不会再被派去旗点，主攻 attack-move 波次也会跳过已有普通 `destination`、attack target 或 attack-move 意图的单位，避免覆盖正在执行的占点移动。
- AI 建造选点可把已占领旗点作为前线 anchor，但最终仍走 `constructionIssue(...)`，不能绕过海岸、油田、陆地、碰撞或覆盖规则。
- AI 进攻使用 attack-move 波次，目标包括旗点、油田、生产建筑、防御结构和 HQ；SAM Site 会作为有价值防御结构参与战略目标排序。

### HUD / 小地图

- HUD 每帧由 `updateHUD()` 汇总金钱、收入、队列、任务、兵力、AI 状态、选择信息和按钮状态。
- `G1` / `G2` subtitle 显示 `empty` 或当前 live 玩家机动单位数量；控制组只保存实体 ID，不保存单位快照、命令、位置或状态。
- `layoutHUD()` 重建按钮后、`updateHUD()` 刷新 subtitle 后都会按当前 pending 字段刷新按钮 stroke/glow 高亮，支援技能冷却文案和按钮命中区域保持原逻辑。
- 选择信息来自 `singleSelectionInfo(...)` 或 `groupSelectionInfo(...)`，会显示有效攻击/视野、老兵等级、XP、击杀数和多选等级分布。
- 小地图显示地形、控制点、可见单位和相机框，点击可跳转相机。

## 5. 用户入口

- App 入口：`DesertFrontlineApp`
- 游戏视图：`GameView`
- 游戏场景：`GameScene`
- 玩家主要操作：点击选择、双击视野内同类机动单位、拖框、点击移动/攻击、HUD 命令、双指移动缩放、点击小地图、`SKRM` 重开。

## 6. 前端 / 数据层 / 模型层 / 测试层关系

- 前端显示：SpriteKit 节点和 SwiftUI `SpriteView`。
- 数据/状态层：`GameScene` 字段、`GameEntity`、`BuildOrder`、`BattlefieldControlPoint`。
- 模型层：`EntityKind`、`VeterancyRank`、`SupportPower`、`HudAction`、`AIDifficulty`、`MissionStage`。
- 规则层：`GameScene` 内的 update、command、build、combat、AI、fog、victory 系列函数。
- 测试层：默认本地轻量检查加 GitHub Actions 云端 generic iOS build 结果包；人工明确要求时补本机 `xcodebuild` 和设备/模拟器检查，规范见 `md/test/test.md`。

## 7. 云端协作验证流

- 角色召唤：`agenta` / `a:` / `A:` 召唤 Agent A，`agentb` / `b:` / `B:` 召唤 Agent B，`agentc` / `c:` / `C:` 召唤 Agent C，`agentx` / `x:` / `X:` 召唤 Agent X；无前缀时按普通 Codex 任务处理。
- Agent X 是主控调度角色，接收人工总目标后拆分小轮次，但不直接替代 Agent A、Agent B 或 Agent C。
- Agent X 的标准闭环是：拆分本轮目标 -> 要求 Agent A 写版本化提示词 -> Agent B 实现并 push -> GitHub Actions 生成 artifact -> Agent C 下载验收 artifact -> Agent X 判断继续、退回、暂停或完成。
- Agent X 每轮都必须以 Agent C 对最新 `origin/main` artifact 的结论为门槛；不能跳过 Agent C，也不能用旧 run、本地输出或文字汇报代替 artifact 验收。
- Agent X 遇到连续阻塞、连续无有效 diff、同因 CI 连续失败、权限/账号/密钥/付费服务需求、冲突归属不明或用户要求停止时，必须暂停或结束循环并说明原因。
- Agent A 只写版本化实现提示词，提示词必须包含 `main` 同步、commit、push、GitHub Actions、artifact 和 Agent C 下载核对要求。
- Agent B 每轮从最新 `origin/main` 开始，在 `main` 上小步实现，先跑本地轻量检查，再 commit 并 `git push origin main`。
- GitHub Actions 在 `main` push 或手动触发时运行 `ci-results.yml`，生成 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `.xcresult`。
- Agent C 必须用 `gh auth login` 后下载最新 run 的未加密结果包，默认放在 `/private/tmp/desert-frontline-c-review-<run_id>/`。
- Agent C 只验收 `origin/main` 最新 commit 对应的 run id、run attempt 和 artifact；不能验收旧 run 或只看文字说明。
- 验收失败时不默认回滚，退回 Agent B 在 `main` 上追加修复 commit，再 push 触发新 run。
- 本轮制度不引入 `smalldata_test`、`develop`、`codeb/...`、候选分支或 PR 合并流。

## 8. 已确认铁律

- README 只能记录已完成、可验证的当前功能。
- 改 Swift 代码后最低要求云端 generic iOS device build 结果包通过；人工明确要求本机构建时再运行本机 generic iOS device build。
- Pending 模式必须互斥清理，避免建筑、支援、集结点、attack-move 状态交叉。
- 新增单位/建筑必须同步考虑生产、AI、HUD、迷雾、支援资产、死亡清理、重开重置。
- 新增 HUD action 必须同步 `HudAction`、标题/副标题、按钮颜色、处理逻辑、HUD 更新和 README 控制说明。
- 新增战斗行为必须同步可攻击规则、射程、伤害、冷却、目标搜索、AI 选择、施工禁火边界和视觉反馈。

## 9. 未来扩展点

- 老兵/经验深化：等级平衡、更多战场反馈、AI 保护高价值老兵、战役持久化等。
- AI 战术增强：守军、占点队、主攻波次、针对玩家构成调整生产。
- 海军/航母深化：舰载机巡逻、截击、反潜、海岸争夺。
- 建筑科技层：科技中心、防御塔、SAM / 岸防炮后续平衡、升级解锁和 Radar Outpost 后续平衡。
- 单位克制层：AA Truck 平衡、更多机动反制单位、AI 编队比例和高价值单位保护。
- 地图与任务：更多地图变体、战役式目标、阶段奖励。
- 操作体验：更多移动端手感优化、命令队列反馈和编队管理深化。

## 10. 不允许破坏的行为

- HQ 被摧毁决定胜负。
- 建筑施工未完成前不得生产、赚钱、提供视野、提供支援资产、扩展基地覆盖或开火。
- 玩家不能可靠攻击迷雾中不可见敌人。
- AI 和玩家必须共享核心战斗/移动/生产规则。
- `SKRM` 必须重置比赛状态、实体、任务、迷雾、经济和 pending 模式。
- 潜艇隐身和声呐检测不得被新海战逻辑绕过。
